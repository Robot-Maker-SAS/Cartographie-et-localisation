// Cartographie & Lidar - Processing
// © QUILLES Jonathan (2026)
import java.awt.event.KeyEvent;
import controlP5.*;

// État global
float sceneW = 2.0;
float sceneH = 3.0;
float cellSize = 0.10;
int numRays = 100;
boolean addBorders = true;
boolean showScan = true;
boolean deleteMode = false;

ArrayList<Segment> segments = new ArrayList<Segment>();
int[][] gridOcc;
int gridNx, gridNy;

Robot robot = new Robot(0.5, 0.5, 0);

// Vue
float viewScale = 220;
float viewOx = 30;
float viewOy = 30;

// Bruit Lidar
float noiseAngle = 0;
float noiseDist = 0;

// Interaction
boolean dragging = false;
PVector dragFrom = null;
boolean draggingRobot = false;

// UI
int panelWidth = 320;
ControlP5 cp5;

void setup() {
  size(1200, 800);
  surface.setResizable(true);
  
  setupUI();
  allocGrid();
  if (addBorders) addBorderWalls();
  autoFitView();
}

void setupUI() {
  cp5 = new ControlP5(this);
  PFont font = createFont("Arial", 11);
  cp5.setFont(font);
  
  int y = 20;
  int x = 10;
  int w = 140;
  
  // Paramètres de la scène
  cp5.addTextlabel("lblScene")
     .setText("PARAMETRES SCENE")
     .setPosition(x, y)
     .setColorValue(color(255))
     .setFont(createFont("Arial", 12, true));
  y += 25;
  
  cp5.addTextfield("sceneWField")
     .setPosition(x, y)
     .setSize(w, 25)
     .setText(str(sceneW))
     .setLabel("Largeur (m)")
     .setColorBackground(color(40))
     .setColorForeground(color(60))
     .setColorActive(color(80))
     .setAutoClear(false);
  
  cp5.addTextfield("sceneHField")
     .setPosition(x + w + 10, y)
     .setSize(w, 25)
     .setText(str(sceneH))
     .setLabel("Hauteur (m)")
     .setColorBackground(color(40))
     .setColorForeground(color(60))
     .setColorActive(color(80))
     .setAutoClear(false);
  y += 55;
  
  cp5.addTextfield("cellSizeField")
     .setPosition(x, y)
     .setSize(w, 25)
     .setText(str(cellSize))
     .setLabel("Pas grille (m)")
     .setColorBackground(color(40))
     .setColorForeground(color(60))
     .setColorActive(color(80))
     .setAutoClear(false);
  
  cp5.addTextfield("numRaysField")
     .setPosition(x + w + 10, y)
     .setSize(w, 25)
     .setText(str(numRays))
     .setLabel("Points Lidar")
     .setColorBackground(color(40))
     .setColorForeground(color(60))
     .setColorActive(color(80))
     .setAutoClear(false);
  y += 55;
  
  cp5.addToggle("addBorders")
     .setPosition(x, y)
     .setSize(40, 20)
     .setValue(addBorders)
     .setCaptionLabel("Murs bords")
     .setColorBackground(color(40))
     .setColorForeground(color(100))
     .setColorActive(color(56, 189, 248));
  
  cp5.addToggle("showScan")
     .setPosition(x + 120, y)
     .setSize(40, 20)
     .setValue(showScan)
     .setCaptionLabel("Afficher scan")
     .setColorBackground(color(40))
     .setColorForeground(color(100))
     .setColorActive(color(6, 182, 212));
  y += 50;
  
  // Robot
  cp5.addTextlabel("lblRobot")
     .setText("ROBOT")
     .setPosition(x, y)
     .setColorValue(color(255))
     .setFont(createFont("Arial", 12, true));
  y += 25;
  
  cp5.addTextfield("robotXField")
     .setPosition(x, y)
     .setSize(90, 25)
     .setText(nf(robot.x, 0, 2))
     .setLabel("X (m)")
     .setColorBackground(color(40))
     .setColorForeground(color(60))
     .setColorActive(color(80))
     .setAutoClear(false);
  
  cp5.addTextfield("robotYField")
     .setPosition(x + 100, y)
     .setSize(90, 25)
     .setText(nf(robot.y, 0, 2))
     .setLabel("Y (m)")
     .setColorBackground(color(40))
     .setColorForeground(color(60))
     .setColorActive(color(80))
     .setAutoClear(false);
  
  cp5.addTextfield("robotThField")
     .setPosition(x + 200, y)
     .setSize(90, 25)
     .setText(str(int(robot.thDeg)))
     .setLabel("θ (°)")
     .setColorBackground(color(40))
     .setColorForeground(color(60))
     .setColorActive(color(80))
     .setAutoClear(false);
  y += 55;
  
  // Bruit
  cp5.addTextlabel("lblNoise")
     .setText("BRUIT LIDAR")
     .setPosition(x, y)
     .setColorValue(color(255))
     .setFont(createFont("Arial", 12, true));
  y += 25;
  
  cp5.addTextfield("noiseAngleField")
     .setPosition(x, y)
     .setSize(w, 25)
     .setText(str(noiseAngle))
     .setLabel("Angle (±°)")
     .setColorBackground(color(40))
     .setColorForeground(color(60))
     .setColorActive(color(80))
     .setAutoClear(false);
  
  cp5.addTextfield("noiseDistField")
     .setPosition(x + w + 10, y)
     .setSize(w, 25)
     .setText(str(noiseDist))
     .setLabel("Distance (±m)")
     .setColorBackground(color(40))
     .setColorForeground(color(60))
     .setColorActive(color(80))
     .setAutoClear(false);
  y += 55;
  
  // Boutons
  cp5.addTextlabel("lblActions")
     .setText("ACTIONS")
     .setPosition(x, y)
     .setColorValue(color(255))
     .setFont(createFont("Arial", 12, true));
  y += 25;
  
  cp5.addButton("btnApply")
     .setPosition(x, y)
     .setSize(290, 25)
     .setCaptionLabel("APPLIQUER PARAMETRES")
     .setColorBackground(color(56, 189, 248))
     .setColorForeground(color(100, 200, 255))
     .setColorActive(color(150, 220, 255));
  y += 35;
  
  cp5.addButton("btnClear")
     .setPosition(x, y)
     .setSize(140, 25)
     .setCaptionLabel("EFFACER LIGNES")
     .setColorBackground(color(239, 68, 68))
     .setColorForeground(color(255, 100, 100))
     .setColorActive(color(255, 150, 150));
  
  cp5.addButton("btnToggleDelete")
     .setPosition(x + 150, y)
     .setSize(140, 25)
     .setCaptionLabel("MODE SUPPRESSION")
     .setColorBackground(color(245, 158, 11))
     .setColorForeground(color(255, 180, 50))
     .setColorActive(color(255, 200, 100));
  y += 35;
  
  cp5.addButton("btnImport")
     .setPosition(x, y)
     .setSize(140, 25)
     .setCaptionLabel("IMPORTER CARTE")
     .setColorBackground(color(100, 100, 180))
     .setColorForeground(color(120, 120, 200))
     .setColorActive(color(150, 150, 220));
  
  cp5.addButton("btnExportGrid")
     .setPosition(x + 150, y)
     .setSize(140, 25)
     .setCaptionLabel("EXPORT GRID CSV")
     .setColorBackground(color(34, 197, 94))
     .setColorForeground(color(50, 220, 110))
     .setColorActive(color(100, 240, 150));
  y += 35;
  
  cp5.addButton("btnExportVector")
     .setPosition(x, y)
     .setSize(140, 25)
     .setCaptionLabel("EXPORT VECTOR TXT")
     .setColorBackground(color(34, 197, 94))
     .setColorForeground(color(50, 220, 110))
     .setColorActive(color(100, 240, 150));
  
  cp5.addButton("btnExportScan")
     .setPosition(x + 150, y)
     .setSize(140, 25)
     .setCaptionLabel("EXPORT SCAN CSV")
     .setColorBackground(color(34, 197, 94))
     .setColorForeground(color(50, 220, 110))
     .setColorActive(color(100, 240, 150));
  y += 45;
  
  // Aide
  cp5.addTextlabel("lblHelp")
     .setText("AIDE")
     .setPosition(x, y)
     .setColorValue(color(255))
     .setFont(createFont("Arial", 12, true));
  y += 20;

  cp5.addTextlabel("help1")
     .setText("• Tracer: clic-glisser sur zone vide")
     .setPosition(x, y)
     .setColorValue(color(150));
  y += 18;
  cp5.addTextlabel("help2")
     .setText("• Supprimer: clic près d'une ligne en mode suppression")
     .setPosition(x, y)
     .setColorValue(color(150));
  y += 18;
  cp5.addTextlabel("help3")
     .setText("• Robot: clic-glisser / molette ou")
     .setPosition(x, y)
     .setColorValue(color(150));
  y += 18;
  cp5.addTextlabel("help4")
     .setText("• Flèches du clavier ←↑↓→ + PageUp/PageDown")
     .setPosition(x, y)
     .setColorValue(color(150));
  y += 18;
  cp5.addTextlabel("help5")
     .setText("• Cliquez sur un champs pour le modifier")
     .setPosition(x, y)
     .setColorValue(color(150));
  y += 18;
  cp5.addTextlabel("help6")
     .setText("• Appuyez sur Entrer pour valider un champ")
     .setPosition(x, y)
     .setColorValue(color(150));
}

void draw() {
  background(15, 23, 42);
  
  // Panel de contrôle
  fill(17, 24, 39);
  noStroke();
  rect(0, 0, panelWidth, height);
  
  // Zone de dessin
  pushMatrix();
  translate(panelWidth + 10, 0);
  drawScene();
  popMatrix();
  
  // Mode indicator
  if (deleteMode) {
    fill(239, 68, 68);
    textAlign(CENTER);
    textSize(14);
    text("MODE SUPPRESSION ACTIF", width/2 + 80, 20);
  }
  
  // Copyright
  fill(150, 200);
  textAlign(RIGHT);
  textSize(10);
  text("© QUILLES Jonathan (2026)", width - 10, height - 10);
  textAlign(LEFT);
}

void drawScene() {
  // Fond blanc
  fill(255);
  noStroke();
  PVector topLeft = worldToScreen(0, sceneH);
  PVector bottomRight = worldToScreen(sceneW, 0);
  float w = bottomRight.x - topLeft.x;
  float h = bottomRight.y - topLeft.y;
  rect(topLeft.x, topLeft.y, w, h);
  
  // Grille
  stroke(209, 213, 219);
  strokeWeight(1);
  for (int i = 0; i <= gridNx; i++) {
    float x = i * cellSize;
    PVector p1 = worldToScreen(x, 0);
    PVector p2 = worldToScreen(x, sceneH);
    line(p1.x, p1.y, p2.x, p2.y);
  }
  for (int j = 0; j <= gridNy; j++) {
    float y = j * cellSize;
    PVector p1 = worldToScreen(0, y);
    PVector p2 = worldToScreen(sceneW, y);
    line(p1.x, p1.y, p2.x, p2.y);
  }
  
  // Cellules occupées
  fill(0);
  noStroke();
  for (int j = 0; j < gridNy; j++) {
    for (int i = 0; i < gridNx; i++) {
      if (gridOcc[j][i] == 1) {
        float x = i * cellSize;
        float y = j * cellSize;
        PVector p1 = worldToScreen(x, y);
        PVector p2 = worldToScreen(x + cellSize, y + cellSize);
        rect(p1.x, p1.y, p2.x - p1.x, p2.y - p1.y);
      }
    }
  }
  
  // Segments
  stroke(239, 68, 68);
  strokeWeight(3);
  for (Segment s : segments) {
    PVector p1 = worldToScreen(s.x1, s.y1);
    PVector p2 = worldToScreen(s.x2, s.y2);
    line(p1.x, p1.y, p2.x, p2.y);
  }
  
  // Scan Lidar
  if (showScan) {
    drawLidarScan();
  }
  
  // Ligne en cours
  if (dragging && dragFrom != null) {
    stroke(245, 158, 11);
    strokeWeight(2);
    PVector p1 = worldToScreen(dragFrom.x, dragFrom.y);
    PVector mouse = getCanvasMousePos();
    PVector worldMouse = screenToWorld(mouse.x, mouse.y);
    PVector p2 = worldToScreen(constrain(worldMouse.x, 0, sceneW), constrain(worldMouse.y, 0, sceneH));
    line(p1.x, p1.y, p2.x, p2.y);
  }
  
  // Robot
  drawRobot();
}

void drawLidarScan() {
  ArrayList<ScanPoint> scan = computeScan();
  PVector robotScreen = worldToScreen(robot.x, robot.y);
  
  // Rayons
  stroke(6, 182, 212, 60);
  strokeWeight(1);
  for (ScanPoint pt : scan) {
    if (pt.hasHit) {
      PVector hitScreen = worldToScreen(pt.xAbs, pt.yAbs);
      line(robotScreen.x, robotScreen.y, hitScreen.x, hitScreen.y);
    }
  }
  
  // Points
  fill(6, 182, 212);
  noStroke();
  for (ScanPoint pt : scan) {
    if (pt.hasHit) {
      PVector hitScreen = worldToScreen(pt.xAbs, pt.yAbs);
      ellipse(hitScreen.x, hitScreen.y, 5, 5);
    }
  }
}

void drawRobot() {
  PVector pos = worldToScreen(robot.x, robot.y);
  float size = 0.12 * viewScale;
  
  pushMatrix();
  translate(pos.x, pos.y);
  rotate(-radians(robot.thDeg));
  
  fill(56, 189, 248);
  stroke(14, 165, 233);
  strokeWeight(2);
  
  beginShape();
  vertex(size, 0);
  vertex(-size * 0.6, size * 0.5);
  vertex(-size * 0.6, -size * 0.5);
  endShape(CLOSE);
  
  popMatrix();
}

PVector worldToScreen(float x, float y) {
  float sx = viewOx + x * viewScale;
  float sy = height - (viewOy + y * viewScale);
  return new PVector(sx, sy);
}

PVector screenToWorld(float sx, float sy) {
  float x = (sx - viewOx) / viewScale;
  float y = (height - sy - viewOy) / viewScale;
  return new PVector(x, y);
}

PVector getCanvasMousePos() {
  return new PVector(mouseX - panelWidth - 10, mouseY);
}

void autoFitView() {
  float canvasW = width - panelWidth - 20;
  float canvasH = height - 40;
  float margin = 40;
  float availW = canvasW - 2 * margin;
  float availH = canvasH - 2 * margin;
  float scaleW = availW / sceneW;
  float scaleH = availH / sceneH;
  viewScale = min(scaleW, scaleH);
  float gridPixW = sceneW * viewScale;
  float gridPixH = sceneH * viewScale;
  viewOx = (canvasW - gridPixW) / 2;
  viewOy = (canvasH - gridPixH) / 2;
}

void allocGrid() {
  gridNx = max(1, ceil(sceneW / cellSize));
  gridNy = max(1, ceil(sceneH / cellSize));
  gridOcc = new int[gridNy][gridNx];
}

void clearGrid() {
  for (int j = 0; j < gridNy; j++) {
    for (int i = 0; i < gridNx; i++) {
      gridOcc[j][i] = 0;
    }
  }
}

void markCell(int i, int j) {
  if (i == gridNx) i--;
  if (j == gridNy) j--;
  if (i >= 0 && j >= 0 && i < gridNx && j < gridNy) {
    gridOcc[j][i] = 1;
  }
}

void rasterizeSegment(float x0, float y0, float x1, float y1) {
  x0 = constrain(x0, 0, sceneW);
  y0 = constrain(y0, 0, sceneH);
  x1 = constrain(x1, 0, sceneW);
  y1 = constrain(y1, 0, sceneH);
  
  float epsilon = 1e-9;
  int i = floor(x0 / cellSize);
  int j = floor(y0 / cellSize);
  int iEnd = floor(x1 / cellSize);
  int jEnd = floor(y1 / cellSize);
  
  markCell(i, j);
  
  float dx = x1 - x0;
  float dy = y1 - y0;
  int stepI = dx > 0 ? 1 : (dx < 0 ? -1 : 0);
  int stepJ = dy > 0 ? 1 : (dy < 0 ? -1 : 0);
  float invDx = dx != 0 ? 1 / dx : 0;
  float invDy = dy != 0 ? 1 / dy : 0;
  
  float tMaxI, tMaxJ, tDeltaI, tDeltaJ;
  
  if (stepI != 0) {
    float xb = stepI > 0 ? (i + 1) * cellSize : i * cellSize;
    tMaxI = (xb - x0) * invDx;
    tDeltaI = (cellSize * stepI) * invDx;
  } else {
    tMaxI = Float.POSITIVE_INFINITY;
    tDeltaI = Float.POSITIVE_INFINITY;
  }
  
  if (stepJ != 0) {
    float yb = stepJ > 0 ? (j + 1) * cellSize : j * cellSize;
    tMaxJ = (yb - y0) * invDy;
    tDeltaJ = (cellSize * stepJ) * invDy;
  } else {
    tMaxJ = Float.POSITIVE_INFINITY;
    tDeltaJ = Float.POSITIVE_INFINITY;
  }
  
  while (i != iEnd || j != jEnd) {
    if (tMaxI < tMaxJ - epsilon) {
      i += stepI;
      markCell(i, j);
      tMaxI += tDeltaI;
    } else if (tMaxJ < tMaxI - epsilon) {
      j += stepJ;
      markCell(i, j);
      tMaxJ += tDeltaJ;
    } else {
      int iPrev = i;
      int jPrev = j;
      i += stepI;
      j += stepJ;
      markCell(i, j);
      markCell(iPrev, j);
      markCell(i, jPrev);
      tMaxI += tDeltaI;
      tMaxJ += tDeltaJ;
    }
  }
}

void rebuildGridFromSegments() {
  clearGrid();
  for (Segment s : segments) {
    rasterizeSegment(s.x1, s.y1, s.x2, s.y2);
  }
}

void addSegment(float x1, float y1, float x2, float y2) {
  x1 = constrain(x1, 0, sceneW);
  y1 = constrain(y1, 0, sceneH);
  x2 = constrain(x2, 0, sceneW);
  y2 = constrain(y2, 0, sceneH);
  segments.add(new Segment(x1, y1, x2, y2));
  rasterizeSegment(x1, y1, x2, y2);
}

void resetSegments() {
  segments.clear();
  clearGrid();
  if (addBorders) addBorderWalls();
}

void addBorderWalls() {
  addSegment(0, 0, sceneW, 0);
  addSegment(sceneW, 0, sceneW, sceneH);
  addSegment(sceneW, sceneH, 0, sceneH);
  addSegment(0, sceneH, 0, 0);
}

int findSegmentAtPoint(float wx, float wy, float threshold) {
  for (int i = 0; i < segments.size(); i++) {
    Segment s = segments.get(i);
    float dist = distancePointToSegment(wx, wy, s.x1, s.y1, s.x2, s.y2);
    if (dist < threshold) return i;
  }
  return -1;
}

float distancePointToSegment(float px, float py, float x1, float y1, float x2, float y2) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  float lenSq = dx * dx + dy * dy;
  if (lenSq == 0) return dist(px, py, x1, y1);
  float t = constrain(((px - x1) * dx + (py - y1) * dy) / lenSq, 0, 1);
  float projX = x1 + t * dx;
  float projY = y1 + t * dy;
  return dist(px, py, projX, projY);
}

void deleteSegment(int index) {
  if (index >= 0 && index < segments.size()) {
    segments.remove(index);
    rebuildGridFromSegments();
  }
}

Hit raySegmentIntersection(float px, float py, float rdx, float rdy, float x1, float y1, float x2, float y2) {
  float sx = x2 - x1;
  float sy = y2 - y1;
  float denom = rdx * sy - rdy * sx;
  if (abs(denom) < 1e-10) return null;
  
  float dx = x1 - px;
  float dy = y1 - py;
  float t = (dx * sy - dy * sx) / denom;
  float u = (dx * rdy - dy * rdx) / denom;
  
  if (t > 1e-6 && u >= -1e-6 && u <= 1.0 + 1e-6) {
    float ix = px + t * rdx;
    float iy = py + t * rdy;
    return new Hit(t, ix, iy);
  }
  return null;
}

ArrayList<ScanPoint> computeScan() {
  ArrayList<ScanPoint> out = new ArrayList<ScanPoint>();
  float th0 = radians(robot.thDeg);
  
  for (int k = 0; k < numRays; k++) {
    float aLocal = k * TWO_PI / numRays;
    float aGlobal = th0 + aLocal;
    float rdx = cos(aGlobal);
    float rdy = sin(aGlobal);
    
    Hit best = null;
    for (Segment s : segments) {
      Hit hit = raySegmentIntersection(robot.x, robot.y, rdx, rdy, s.x1, s.y1, s.x2, s.y2);
      if (hit != null && (best == null || hit.t < best.t)) {
        best = hit;
      }
    }
    
    if (best != null) {
      float r = best.t;
      float rWithNoise = max(0.001, r + randomNoise(noiseDist));
      float aLocalWithNoise = aLocal + radians(randomNoise(noiseAngle));
      
      out.add(new ScanPoint(
        degrees(aLocal),
        rWithNoise,
        rWithNoise * cos(aLocalWithNoise),
        rWithNoise * sin(aLocalWithNoise),
        best.ix,
        best.iy,
        true
      ));
    } else {
      out.add(new ScanPoint(degrees(aLocal), 0, 0, 0, robot.x, robot.y, false));
    }
  }
  
  return out;
}

float randomNoise(float range) {
  return (random(1) - 0.5) * 2 * range;
}

void exportGridCSV() {
  String[] lines = new String[gridNy + 1];
  lines[0] = "# Grid map " + gridNx + "x" + gridNy + ", cell=" + cellSize + " m ; 1=occupied,0=free";
  for (int j = gridNy - 1; j >= 0; j--) {
    String row = "";
    for (int i = 0; i < gridNx; i++) {
      row += gridOcc[j][i];
      if (i < gridNx - 1) row += ",";
    }
    lines[gridNy - j] = row;
  }
  String filename = sketchPath("grid_map.csv");
  saveStrings(filename, lines);
  println("✓ Grid map exporté : " + filename);
}

void exportVectorTXT() {
  String[] lines = new String[segments.size() + 1];
  lines[0] = "# Vector map segments: x1,y1,x2,y2 (meters)";
  for (int i = 0; i < segments.size(); i++) {
    Segment s = segments.get(i);
    lines[i + 1] = nf(s.x1, 0, 4) + "," + nf(s.y1, 0, 4) + "," + nf(s.x2, 0, 4) + "," + nf(s.y2, 0, 4);
  }
  String filename = sketchPath("vector_map.txt");
  saveStrings(filename, lines);
  println("✓ Carte vectorielle exportée : " + filename);
}

void exportScanCSV() {
  ArrayList<ScanPoint> scan = computeScan();
  String[] lines = new String[scan.size() + 2];
  lines[0] = "# Robot position: x=" + nf(robot.x, 0, 4) + "m, y=" + nf(robot.y, 0, 4) + "m, theta=" + nf(robot.thDeg, 0, 2) + "deg";
  lines[1] = "angle_deg,r_m,x_rel_m,y_rel_m";
  for (int i = 0; i < scan.size(); i++) {
    ScanPoint pt = scan.get(i);
    lines[i + 2] = nf(pt.angleDeg, 0, 3) + "," + nf(pt.rM, 0, 4) + "," + nf(pt.xRel, 0, 4) + "," + nf(pt.yRel, 0, 4);
  }
  String filename = sketchPath("scan_lidar.csv");
  saveStrings(filename, lines);
  println("✓ Scan Lidar exporté : " + filename);
}

void importVectorMap() {
  selectInput("Sélectionner carte vectorielle (.txt)", "fileSelected");
}

void fileSelected(File selection) {
  if (selection == null) return;
  String[] lines = loadStrings(selection.getAbsolutePath());
  segments.clear();
  for (String line : lines) {
    line = trim(line);
    if (line.length() == 0 || line.startsWith("#")) continue;
    String[] parts = split(line, ',');
    if (parts.length == 4) {
      float x1 = float(trim(parts[0]));
      float y1 = float(trim(parts[1]));
      float x2 = float(trim(parts[2]));
      float y2 = float(trim(parts[3]));
      segments.add(new Segment(x1, y1, x2, y2));
    }
  }
  rebuildGridFromSegments();
  println("✓ Carte importée : " + segments.size() + " segments");
}

void mousePressed() {
  if (mouseX < panelWidth) return;
  
  PVector mouse = getCanvasMousePos();
  PVector world = screenToWorld(mouse.x, mouse.y);
  
  if (world.x < 0 || world.x > sceneW || world.y < 0 || world.y > sceneH) return;
  
  float dx = world.x - robot.x;
  float dy = world.y - robot.y;
  if (dist(0, 0, dx, dy) < 0.2) {
    draggingRobot = true;
    return;
  }
  
  if (deleteMode) {
    int segIndex = findSegmentAtPoint(world.x, world.y, 0.05);
    if (segIndex != -1) {
      deleteSegment(segIndex);
    }
    return;
  }
  
  dragging = true;
  dragFrom = new PVector(constrain(world.x, 0, sceneW), constrain(world.y, 0, sceneH));
}

void mouseDragged() {
  if (mouseX < panelWidth) return;
  
  if (draggingRobot) {
    PVector mouse = getCanvasMousePos();
    PVector world = screenToWorld(mouse.x, mouse.y);
    robot.x = constrain(world.x, 0, sceneW);
    robot.y = constrain(world.y, 0, sceneH);
    updateRobotFields();
  }
}

void mouseReleased() {
  if (dragging && dragFrom != null) {
    PVector mouse = getCanvasMousePos();
    PVector world = screenToWorld(mouse.x, mouse.y);
    addSegment(dragFrom.x, dragFrom.y, constrain(world.x, 0, sceneW), constrain(world.y, 0, sceneH));
    dragging = false;
    dragFrom = null;
  }
  draggingRobot = false;
}

void mouseWheel(MouseEvent event) {
  if (mouseX < panelWidth) return;
  
  PVector mouse = getCanvasMousePos();
  PVector world = screenToWorld(mouse.x, mouse.y);
  
  float dx = world.x - robot.x;
  float dy = world.y - robot.y;
  if (dist(0, 0, dx, dy) < 0.2) {
    robot.thDeg = constrain(robot.thDeg + (event.getCount() > 0 ? -5 : 5), -180, 180);
    updateRobotFields();
  }
}

void keyPressed() {
  float step = 0.05;
  float rot = 5;
  
  if (keyCode == RIGHT) {
    robot.x += step;
  } else if (keyCode == LEFT) {
    robot.x -= step;
  } else if (keyCode == UP) {
    robot.y += step;
  } else if (keyCode == DOWN) {
    robot.y -= step;
  } else if (keyCode ==  KeyEvent.VK_PAGE_DOWN) {
    robot.thDeg = constrain(robot.thDeg + rot, -180, 180);
  } else if (keyCode ==  KeyEvent.VK_PAGE_UP) {
    robot.thDeg = constrain(robot.thDeg - rot, -180, 180);
  }
  
  robot.x = constrain(robot.x, 0, sceneW);
  robot.y = constrain(robot.y, 0, sceneH);
  updateRobotFields();
}

void updateRobotFields() {
  Textfield tfX = (Textfield)cp5.getController("robotXField");
  Textfield tfY = (Textfield)cp5.getController("robotYField");
  Textfield tfTh = (Textfield)cp5.getController("robotThField");
  
  // Ne mettre à jour que si le champ n'est pas en cours d'édition
  if (!tfX.isFocus()) tfX.setText(nf(robot.x, 0, 2));
  if (!tfY.isFocus()) tfY.setText(nf(robot.y, 0, 2));
  if (!tfTh.isFocus()) tfTh.setText(str(int(robot.thDeg)));
}

// Callbacks ControlP5 pour textfields
void sceneWField(String value) {
  try {
    sceneW = max(0.5, float(value));
  } catch(Exception e) {}
}

void sceneHField(String value) {
  try {
    sceneH = max(0.5, float(value));
  } catch(Exception e) {}
}

void cellSizeField(String value) {
  try {
    cellSize = max(0.02, float(value));
  } catch(Exception e) {}
}

void numRaysField(String value) {
  try {
    numRays = max(16, int(float(value)));
  } catch(Exception e) {}
}

void robotXField(String value) {
  try {
    robot.x = constrain(float(value), 0, sceneW);
  } catch(Exception e) {}
}

void robotYField(String value) {
  try {
    robot.y = constrain(float(value), 0, sceneH);
  } catch(Exception e) {}
}

void robotThField(String value) {
  try {
    robot.thDeg = constrain(float(value), -180, 180);
  } catch(Exception e) {}
}

void noiseAngleField(String value) {
  try {
    noiseAngle = max(0, float(value));
  } catch(Exception e) {}
}

void noiseDistField(String value) {
  try {
    noiseDist = max(0, float(value));
  } catch(Exception e) {}
}

// Callbacks pour toggles
void addBorders(boolean value) {
  addBorders = value;
}

void showScan(boolean value) {
  showScan = value;
}

// Callbacks pour boutons
void btnApply() {
  allocGrid();
  rebuildGridFromSegments();
  autoFitView();
  println("✓ Paramètres appliqués");
}

void btnClear() {
  resetSegments();
  println("✓ Lignes effacées");
}

void btnToggleDelete() {
  deleteMode = !deleteMode;
  if (deleteMode) {
    cp5.getController("btnToggleDelete").setColorBackground(color(127, 29, 29));
    cp5.getController("btnToggleDelete").setCaptionLabel("✓ MODE SUPPRESSION");
    println("✓ Mode suppression activé");
  } else {
    cp5.getController("btnToggleDelete").setColorBackground(color(245, 158, 11));
    cp5.getController("btnToggleDelete").setCaptionLabel("MODE SUPPRESSION");
    println("✓ Mode suppression désactivé");
  }
}

void btnImport() {
  importVectorMap();
}

void btnExportGrid() {
  exportGridCSV();
}

void btnExportVector() {
  exportVectorTXT();
}

void btnExportScan() {
  exportScanCSV();
}

// Classes
class Segment {
  float x1, y1, x2, y2;
  Segment(float x1, float y1, float x2, float y2) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
  }
}

class Robot {
  float x, y, thDeg;
  Robot(float x, float y, float thDeg) {
    this.x = x;
    this.y = y;
    this.thDeg = thDeg;
  }
}

class Hit {
  float t, ix, iy;
  Hit(float t, float ix, float iy) {
    this.t = t;
    this.ix = ix;
    this.iy = iy;
  }
}

class ScanPoint {
  float angleDeg, rM, xRel, yRel, xAbs, yAbs;
  boolean hasHit;
  ScanPoint(float angleDeg, float rM, float xRel, float yRel, float xAbs, float yAbs, boolean hasHit) {
    this.angleDeg = angleDeg;
    this.rM = rM;
    this.xRel = xRel;
    this.yRel = yRel;
    this.xAbs = xAbs;
    this.yAbs = yAbs;
    this.hasHit = hasHit;
  }
}
