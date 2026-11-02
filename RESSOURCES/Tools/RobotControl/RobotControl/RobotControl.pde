/**
 * Robot + LIDAR Control & Map (version Processing)
 * Inspiré de l'appli HTML fournie.
 *
 * Contrôles :
 *  - Souris : déplacer le robot (cliquer près du triangle et déplacer)
 *  - Molette sur le robot : rotation (±5°)
 *  - Clavier :
 *      ↑ ↓ ← →  : déplacer le robot sur la carte (0.05 m)
 *      PageUp   : tourner +5°
 *      PageDown : tourner -5°
 *      'p'      : envoyer la pose au robot (/pose)
 *      's'      : lancer un scan unique (/scan)
 *      'a'      : activer/désactiver l'auto-scan
 *      'c'      : export CSV du scan
 *      'v'      : importer une carte vectorielle (fichier texte)
 *      I/K, J/L, U/O : moteurs pendant 300 ms (rotations 150 ms côté robot)
 *      Espace : arrêt des moteurs
 * 
 * Il faut que l'ESP32 soit joignable par HTTP comme dans ton code JS.
 */

import java.net.*;
import java.io.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.Locale;
import java.nio.*;                 // ByteBuffer, ByteOrder
import java.awt.event.KeyEvent;    // POUR VK_PAGE_UP / VK_PAGE_DOWN
import processing.event.MouseEvent; // pour mouseWheel

// ================================
// CONFIG
// ================================
final String ROBOT_IP = "http://192.168.4.1";  // IP de l'ESP32 en AP

// ================================
// ÉTAT GLOBAL
// ================================
float worldW = 4.0;    // largeur carte (m)
float worldH = 4.0;    // hauteur carte (m)
float cell   = 0.10;   // taille de la grille (m)

class Robot {
  float x = 2.0;
  float y = 2.0;
  float thDeg = 0.0;
}
Robot robot = new Robot();

// Vue (transform monde -> écran)
class View {
  float scale = 100;
  float ox = 20;
  float oy = 20;
}
View view = new View();

class LidarPoint {
  int angle_cd;
  int distance;    // mm
  int intensity;
}
ArrayList<LidarPoint> lidarPoints = new ArrayList<LidarPoint>();

class Segment {
  float x1, y1, x2, y2;
}
ArrayList<Segment> segments = new ArrayList<Segment>();

boolean draggingRobot = false;

boolean autoScan = false;
int autoScanIntervalMs = 200; // 5 Hz, une seule requête de scan à la fois
int lastAutoScan = 0;

int lastScanTimeMs = 0;
float scanFreq = 0;  // en Hz

// logs simples
ArrayList<String> logs = new ArrayList<String>();
int maxLogs = 15;

// Les résultats sont appliqués uniquement par draw(), jamais par le réseau.
ConcurrentLinkedQueue<Runnable> uiUpdates = new ConcurrentLinkedQueue<Runnable>();
ExecutorService scanWorker = Executors.newSingleThreadExecutor();
ExecutorService commandWorker = Executors.newSingleThreadExecutor();
ExecutorService stopWorker = Executors.newSingleThreadExecutor();
AtomicBoolean scanPending = new AtomicBoolean(false);
AtomicBoolean commandPending = new AtomicBoolean(false);
AtomicBoolean stopPending = new AtomicBoolean(false);

byte[] httpGet(String path, int maxBytes) throws IOException {
  HttpURLConnection connection = (HttpURLConnection)new URL(ROBOT_IP + path).openConnection();
  connection.setConnectTimeout(1500);
  connection.setReadTimeout(1500);
  try {
    int status = connection.getResponseCode();
    if (status != 200) throw new IOException("HTTP " + status);
    try (InputStream input = connection.getInputStream();
         ByteArrayOutputStream output = new ByteArrayOutputStream()) {
      byte[] chunk = new byte[512];
      long deadline = System.nanoTime() + 3000000000L;
      int count;
      while ((count = input.read(chunk)) != -1) {
        if (System.nanoTime() > deadline) throw new IOException("Délai de lecture dépassé");
        if (output.size() + count > maxBytes) throw new IOException("Réponse trop grande");
        output.write(chunk, 0, count);
      }
      return output.toByteArray();
    }
  } finally { connection.disconnect(); }
}

void requestCommand(final String path, final boolean stop) {
  final AtomicBoolean pending = stop ? stopPending : commandPending;
  if (!stop && stopPending.get()) return;
  if (!pending.compareAndSet(false, true)) return;
  (stop ? stopWorker : commandWorker).submit(() -> {
    try {
      httpGet(path, 256);
      uiUpdates.add(() -> addLog("Commande OK : " + path));
    } catch (Exception error) {
      final String message = error.getMessage();
      uiUpdates.add(() -> addLog("Erreur commande : " + message));
    } finally { pending.set(false); }
  });
}

public void dispose() {
  scanWorker.shutdownNow();
  commandWorker.shutdownNow();
  stopWorker.shutdownNow();
  super.dispose();
}

// ================================
// SETUP / DRAW
// ================================
void setup() {
  size(1000, 700); // grand canvas
  surface.setTitle("Robot + LIDAR – Processing");
  smooth();
  textFont(createFont("SansSerif", 12));
  fitView();
  addLog("Sketch démarré.");
}

void draw() {
  Runnable update;
  while ((update = uiUpdates.poll()) != null) update.run();
  background(30, 41, 59); // #1e293b sombre

  // Dessin de la zone carte (en blanc)
  drawWorld();

  // Logs + infos à droite ou en bas
  drawUI();

  // AutoScan
  if (autoScan) {
    int now = millis();
    if (now - lastAutoScan >= autoScanIntervalMs) {
      manualScan();
      lastAutoScan = now;
    }
  }
}

// ================================
// VIEW / COORDONNÉES
// ================================
void fitView() {
  // On garde une marge
  float margin = 40;
  float w = width - margin * 2;
  float h = height - margin * 2;

  float sX = w / worldW;
  float sY = h / worldH;
  view.scale = min(sX, sY);

  float usedW = worldW * view.scale;
  float usedH = worldH * view.scale;

  view.ox = (width - usedW) / 2.0;
  view.oy = (height - usedH) / 2.0;
}

// monde -> écran
PVector worldToScreen(float x, float y) {
  float sx = view.ox + x * view.scale;
  float sy = height - (view.oy + y * view.scale);
  return new PVector(sx, sy);
}

// écran -> monde
PVector screenToWorld(float sx, float sy) {
  float x = (sx - view.ox) / view.scale;
  float y = (height - sy - view.oy) / view.scale;
  return new PVector(x, y);
}

// ================================
// DESSIN CARTE + ROBOT + LIDAR
// ================================
void drawWorld() {
  // fond carte blanche
  PVector p0 = worldToScreen(0, 0);
  PVector p1 = worldToScreen(worldW, worldH);
  noStroke();
  fill(255);
  rectMode(CORNERS);
  rect(p1.x, p1.y, p0.x, p0.y);

  // grille
  drawGrid();

  // segments
  drawSegments();

  // LIDAR
  drawLidar();

  // robot
  drawRobot();
}

void drawGrid() {
  stroke(209, 213, 219); // #d1d5db
  strokeWeight(1);

  // verticales
  for (float x = 0; x <= worldW + 1e-6; x += cell) {
    PVector p1 = worldToScreen(x, 0);
    PVector p2 = worldToScreen(x, worldH);
    line(p1.x, p1.y, p2.x, p2.y);
  }

  // horizontales
  for (float y = 0; y <= worldH + 1e-6; y += cell) {
    PVector p1 = worldToScreen(0, y);
    PVector p2 = worldToScreen(worldW, y);
    line(p1.x, p1.y, p2.x, p2.y);
  }
}

void drawSegments() {
  stroke(239, 68, 68); // rouge
  strokeWeight(2);
  for (Segment s : segments) {
    PVector p1 = worldToScreen(s.x1, s.y1);
    PVector p2 = worldToScreen(s.x2, s.y2);
    line(p1.x, p1.y, p2.x, p2.y);
  }
}

void drawRobot() {
  PVector p = worldToScreen(robot.x, robot.y);
  float sizePix = 0.15 * view.scale;

  pushMatrix();
  translate(p.x, p.y);
  rotate(-radians(robot.thDeg));

  fill(56, 189, 248);
  stroke(14, 165, 233);
  strokeWeight(2);

  beginShape();
  vertex(sizePix, 0);
  vertex(-sizePix * 0.6, sizePix * 0.5);
  vertex(-sizePix * 0.6, -sizePix * 0.5);
  endShape(CLOSE);

  popMatrix();
}

void drawLidar() {
  fill(6, 182, 212);
  noStroke();
  for (LidarPoint p : lidarPoints) {
    float angleRad = (p.angle_cd / 100.0) * PI / 180.0 + radians(robot.thDeg);
    float dist_m = p.distance / 1000.0; // mm -> m

    float x = robot.x + dist_m * cos(angleRad);
    float y = robot.y + dist_m * sin(angleRad);

    PVector s = worldToScreen(x, y);
    ellipse(s.x, s.y, 6, 6);
  }
}

// ================================
// LOG / UI TEXTE
// ================================
void addLog(String msg) {
  println(msg);
  logs.add(msg);
  while (logs.size() > maxLogs) {
    logs.remove(0);
  }
}

void drawUI() {
  // Stats LIDAR
  fill(56, 189, 248);
  textAlign(LEFT, TOP);
  String scanInfo = lidarPoints.size() + " pts – " + nf(scanFreq, 0, 1) + " Hz";
  text("LIDAR: " + scanInfo, 10, 10);

  // Pose robot
  fill(226, 232, 240);
  text("Robot: x=" + nf(robot.x, 0, 2) + " m, y=" + nf(robot.y, 0, 2) + " m, θ=" + nf(robot.thDeg, 0, 1) + "°", 10, 30);

  // Auto scan
  String autoTxt = autoScan ? "AutoScan: ON (touche 'a')" : "AutoScan: OFF (touche 'a')";
  fill(148, 163, 184);
  text(autoTxt, 10, 50);

  // Rappel commandes
  float yHelp = 80;
  fill(148, 163, 184);
  text("Commandes :", 10, yHelp);
  yHelp += 14;
  text("Souris : glisser le robot", 10, yHelp); yHelp += 14;
  text("Molette sur le robot : rotation ±5°", 10, yHelp); yHelp += 14;
  text("Clavier : ↑ ↓ ← → (déplacement), PageUp / PageDown (rotation)", 10, yHelp); yHelp += 14;
  text("'p' : envoyer /pose    's' : scan      'a' : auto-scan ON/OFF", 10, yHelp); yHelp += 14;
  text("'c' : export CSV       'v' : import carte vectorielle", 10, yHelp);

  text("Moteurs : I/K avant/arrière, J/L gauche/droite, U/O rotation, ESPACE arrêt", 10, yHelp + 14);

  // Zone de log en bas
  float logH = 180;
  float logY = height - logH - 10;
  fill(0, 0, 0, 180);
  noStroke();
  rectMode(CORNER);
  rect(10, logY, width - 20, logH, 8);

  fill(0, 255, 0);
  textAlign(LEFT, TOP);
  float ly = logY + 6;
  for (String s : logs) {
    text(s, 16, ly);
    ly += 14;
  }

  // Copyright
  fill(203, 213, 225);
  textAlign(LEFT, BOTTOM);
  text("© QUILLES Jonathan (2026) – version Processing", 12, height - 6);
}

// ================================
// ENVOI POSE
// ================================
void sendPoseToRobot() {
  int x = constrain(round(robot.x * 1000), -32768, 32767);
  int y = constrain(round(robot.y * 1000), -32768, 32767);
  int angle = ((round(robot.thDeg * 100) % 36000) + 36000) % 36000;
  requestCommand("/pose?x=" + x + "&y=" + y + "&z=" + angle, false);
}

void sendMotorCmd(String action, int timeMs) {
  requestCommand("/" + action + "?time=" + constrain(timeMs, 0, 2000), action.equals("stop"));
}

void manualScan() {
  if (!scanPending.compareAndSet(false, true)) return;
  scanWorker.submit(() -> {
    try {
      final byte[] buffer = httpGet("/scan", 2308);
      uiUpdates.add(() -> {
        try { decodeScan(buffer); addLog("Scan OK"); }
        catch (Exception error) { addLog("Erreur scan : " + error.getMessage()); }
        finally { scanPending.set(false); }
      });
    } catch (Exception error) {
      final String message = error.getMessage();
      uiUpdates.add(() -> { addLog("Erreur scan : " + message); scanPending.set(false); });
    }
  });
}

void decodeScan(byte[] buffer) {
  if (buffer == null || buffer.length < 8) throw new IllegalArgumentException("En-tête incomplet");
  ByteBuffer bb = ByteBuffer.wrap(buffer).order(ByteOrder.LITTLE_ENDIAN);
  short x = bb.getShort();
  short y = bb.getShort();
  int angle = bb.getShort() & 0xffff;
  int n = bb.getShort() & 0xffff;
  if (n < 1 || n > 460 || buffer.length != 8 + 5 * n || angle >= 36000)
    throw new IllegalArgumentException("Taille ou pose de scan invalide");
  ArrayList<LidarPoint> points = new ArrayList<LidarPoint>();
  for (int i = 0; i < n; i++) {
    LidarPoint point = new LidarPoint();
    point.angle_cd = bb.getShort() & 0xffff;
    point.distance = bb.getShort() & 0xffff;
    point.intensity = bb.get() & 0xff;
    if (point.angle_cd > 36000) throw new IllegalArgumentException("Angle invalide");
    points.add(point);
  }
  int now = millis();
  int dt = now - lastScanTimeMs;
  if (lastScanTimeMs != 0 && dt > 0) scanFreq = 1000.0f / dt;
  lastScanTimeMs = now;
  robot.x = x / 1000.0f;
  robot.y = y / 1000.0f;
  robot.thDeg = angle / 100.0f;
  lidarPoints = points;
}

// ================================
// EXPORT CSV
// ================================
void exportScanCSV() {
  if (lidarPoints.isEmpty()) {
    addLog("⚠ Aucun scan à exporter");
    return;
  }
  ArrayList<String> lines = new ArrayList<String>();
  lines.add(String.format(Locale.ROOT, "# Robot position: x=%.4fm, y=%.4fm, theta=%.2fdeg", robot.x, robot.y, robot.thDeg));
  lines.add("angle_deg,distance_m,intensity");
  for (LidarPoint p : lidarPoints) {
    float a_deg = p.angle_cd / 100.0f;
    float d_m = p.distance / 1000.0f;
    String line = String.format(Locale.ROOT, "%.3f,%.4f,%d", a_deg, d_m, p.intensity);
    lines.add(line);
  }
  String[] arr = lines.toArray(new String[0]);
  String filename = "lidar_scan.csv";
  saveStrings(filename, arr);
  addLog("⬇ Scan exporté en CSV (" + filename + ")");
}

// ================================
// IMPORT CARTE VECTORIELLE
// ================================
void importVectorMap(File selection) {
  if (selection == null) {
    uiUpdates.add(() -> addLog("Import annulé."));
    return;
  }
  uiUpdates.add(() -> addLog("Import carte vectorielle: " + selection.getAbsolutePath()));
  String[] fileLines = loadStrings(selection);
  if (fileLines == null) {
    uiUpdates.add(() -> addLog("Erreur lecture fichier."));
    return;
  }
  final ArrayList<Segment> imported = new ArrayList<Segment>();
  for (String line : fileLines) {
    line = line.trim();
    if (line.length() == 0 || line.startsWith("#")) continue;

    // séparateurs ; ou , comme dans le JS
    String[] parts = line.split("[,;]", -1);

    if (parts.length != 4) { uiUpdates.add(() -> addLog("Import refusé : quatre coordonnées attendues")); return; }
    try {
      float x1 = Float.parseFloat(parts[0].trim());
      float y1 = Float.parseFloat(parts[1].trim());
      float x2 = Float.parseFloat(parts[2].trim());
      float y2 = Float.parseFloat(parts[3].trim());

      if (!Float.isFinite(x1) || !Float.isFinite(y1) || !Float.isFinite(x2) || !Float.isFinite(y2)) throw new IllegalArgumentException();
      Segment s = new Segment();
      s.x1 = x1;
      s.y1 = y1;
      s.x2 = x2;
      s.y2 = y2;
      imported.add(s);
    }
    catch (Exception e) {
      uiUpdates.add(() -> addLog("Import refusé : coordonnées invalides"));
      return;
    }
  }
  if (imported.isEmpty()) { uiUpdates.add(() -> addLog("Import refusé : carte vide")); return; }
  uiUpdates.add(() -> { segments = imported; addLog("Carte importée : " + segments.size() + " segments"); });
}

// déclenché par 'v'
void selectVectorFile() {
  selectInput("Choisir un fichier de segments", "importVectorMap");
}

// ================================
// INTERACTIONS SOURIS / CLAVIER
// ================================
void mousePressed() {
  // détecter si on clique près du robot
  PVector m = new PVector(mouseX, mouseY);
  PVector rS = worldToScreen(robot.x, robot.y);
  float dx = m.x - rS.x;
  float dy = m.y - rS.y;
  float distPix = dist(0, 0, dx, dy);
  float thresholdPix = 0.25 * view.scale; // ~0.25 m

  if (distPix < thresholdPix) {
    draggingRobot = true;
  }
}

void mouseDragged() {
  if (!draggingRobot) return;
  PVector w = screenToWorld(mouseX, mouseY);
  // clamp dans la carte
  robot.x = constrain(w.x, 0, worldW);
  robot.y = constrain(w.y, 0, worldH);
}

void mouseReleased() {
  draggingRobot = false;
}

// molette = rotation si sur le robot
void mouseWheel(MouseEvent event) {
  float delta = event.getCount(); // >0 = vers toi, <0 = vers l'écran
  PVector m = new PVector(mouseX, mouseY);
  PVector rS = worldToScreen(robot.x, robot.y);
  float distPix = dist(m.x, m.y, rS.x, rS.y);
  float thresholdPix = 0.25 * view.scale;
  if (distPix < thresholdPix) {
    if (delta > 0) {
      robot.thDeg -= 5;
    } else if (delta < 0) {
      robot.thDeg += 5;
    }
  }
}

void keyPressed() {
  float step = 0.05; // 5 cm
  if (keyCode == UP) {
    robot.y = constrain(robot.y + step, 0, worldH);
  } else if (keyCode == DOWN) {
    robot.y = constrain(robot.y - step, 0, worldH);
  } else if (keyCode == LEFT) {
    robot.x = constrain(robot.x - step, 0, worldW);
  } else if (keyCode == RIGHT) {
    robot.x = constrain(robot.x + step, 0, worldW);
  }

  // PageUp / PageDown via java.awt.event.KeyEvent
  if (key == CODED) {
    if (keyCode == KeyEvent.VK_PAGE_UP) {
      robot.thDeg += 5;
    } else if (keyCode == KeyEvent.VK_PAGE_DOWN) {
      robot.thDeg -= 5;
    }
  }

  // Commandes physiques distinctes des flèches qui modifient la pose.
  if (key == ' ') sendMotorCmd("stop", 0);
  if (key == 'i' || key == 'I') sendMotorCmd("forward", 300);
  if (key == 'k' || key == 'K') sendMotorCmd("backward", 300);
  if (key == 'j' || key == 'J') sendMotorCmd("left", 300);
  if (key == 'l' || key == 'L') sendMotorCmd("right", 300);
  if (key == 'u' || key == 'U') sendMotorCmd("rotateleft", 300);
  if (key == 'o' || key == 'O') sendMotorCmd("rotateright", 300);

  // Raccourcis alpha
  if (key == 'p' || key == 'P') {
    sendPoseToRobot();
  } else if (key == 's' || key == 'S') {
    manualScan();
  } else if (key == 'a' || key == 'A') {
    autoScan = !autoScan;
    addLog("AutoScan " + (autoScan ? "ON" : "OFF"));
  } else if (key == 'c' || key == 'C') {
    exportScanCSV();
  } else if (key == 'v' || key == 'V') {
    selectVectorFile();
  }
}

// gestion resize
void surfaceResized() {
  fitView();
}
