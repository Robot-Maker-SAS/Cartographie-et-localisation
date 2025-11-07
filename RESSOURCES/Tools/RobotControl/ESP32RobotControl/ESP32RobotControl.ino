#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include "ld06.h"
#include "MecanumCar_v2.h"

// ============================================================
// WIFI AP
// ============================================================
const char* ssid = "RobotESP32";
const char* password = "12345678";
AsyncWebServer server(80);

// ROBOT POSE
int16_t posex = 0;
int16_t posey = 0;
uint16_t posez = 0;

// ============================================================
// LIDAR LD06
// ============================================================
#define RX_LIDAR 35
#define TX_LIDAR -1
#define LIDAR_BAUD 230400
LD06 lidar(Serial2);

// ============================================================
// OUTILS HTTP
// ============================================================
int getArg(AsyncWebServerRequest* req, const char* name, int def) {
  return req->hasParam(name) ? req->getParam(name)->value().toInt() : def;
}

void addCORS(AsyncWebServerResponse* resp) {
  resp->addHeader("Access-Control-Allow-Origin", "*");
  resp->addHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  resp->addHeader("Access-Control-Allow-Headers", "*");
}

// ============================================================
// MOTEURS
// ============================================================
bool moving = false;
uint32_t nextStop = 0;

mecanumCar mecanumCar(19, 21);

void doMove(void (*fn)(), int t) {
  moving = true;
  fn();
  nextStop = millis() + t;
}

void forward(int t)     { doMove([](){ mecanumCar.Advance(); }, t); }
void backward(int t)    { doMove([](){ mecanumCar.Back(); },     t); }
void left(int t)        { doMove([](){ mecanumCar.L_Move(); },   t); }
void right(int t)       { doMove([](){ mecanumCar.R_Move(); },   t); }
void rotateleft(int t)  { doMove([](){ mecanumCar.Turn_Left(); }, t/2); }
void rotateright(int t) { doMove([](){ mecanumCar.Turn_Right(); }, t/2); }

// ============================================================
// SEND SCAN
// ============================================================
void sendScanBinary(AsyncWebServerRequest* req) {

  uint16_t n = lidar.getNbPointsInScan();
  if (n == 0 || n > 460) {
    req->send(500, "text/plain", "NO_VALID_SCAN");
    return;
  }

  AsyncResponseStream* resp = req->beginResponseStream("application/octet-stream");

  // HEADER pose
  resp->write((uint8_t)(posex & 0xFF)); resp->write((uint8_t)(posex >> 8));
  resp->write((uint8_t)(posey & 0xFF)); resp->write((uint8_t)(posey >> 8));
  resp->write((uint8_t)(posez & 0xFF)); resp->write((uint8_t)(posez >> 8));
  resp->write((uint8_t)(n & 0xFF));     resp->write((uint8_t)(n >> 8));

  // POINTS
  for (uint16_t i = 0; i < n; i++) {
    const auto* pt = lidar.getPoints(i);
    uint16_t angle_cd = pt->angle * 100;

    resp->write((uint8_t)(angle_cd & 0xFF));
    resp->write((uint8_t)(angle_cd >> 8));
    resp->write((uint8_t)(pt->distance & 0xFF));
    resp->write((uint8_t)(pt->distance >> 8));
    resp->write(pt->intensity);
  }

  addCORS(resp);
  req->send(resp);

  Serial.printf("SCAN SENT (%u pts)\n", n);
}

// ============================================================
// SETUP
// ============================================================
void setup() {
  Serial.begin(115200);
  delay(200);

  // LIDAR UART
  Serial2.setRxBufferSize(1024);
  Serial2.begin(LIDAR_BAUD, SERIAL_8N1, RX_LIDAR, TX_LIDAR);
  Serial2.setTimeout(2);
  lidar.init();

  // WIFI AP
  WiFi.mode(WIFI_AP);
  WiFi.softAP(ssid, password);
  delay(200);
  Serial.print("AP IP: ");
  Serial.println(WiFi.softAPIP());

  // ROUTES
  server.on("/forward", HTTP_GET, [](AsyncWebServerRequest* r){
    forward(getArg(r,"time",300));
    auto x = r->beginResponse(200,"text/plain","OK");
    addCORS(x); r->send(x);
  });

  server.on("/backward", HTTP_GET, [](AsyncWebServerRequest* r){
    backward(getArg(r,"time",300));
    auto x = r->beginResponse(200,"text/plain","OK");
    addCORS(x); r->send(x);
  });

  server.on("/left", HTTP_GET, [](AsyncWebServerRequest* r){
    left(getArg(r,"time",300));
    auto x = r->beginResponse(200,"text/plain","OK");
    addCORS(x); r->send(x);
  });

  server.on("/right", HTTP_GET, [](AsyncWebServerRequest* r){
    right(getArg(r,"time",300));
    auto x = r->beginResponse(200,"text/plain","OK");
    addCORS(x); r->send(x);
  });

  server.on("/rotateleft", HTTP_GET, [](AsyncWebServerRequest* r){
    rotateleft(getArg(r,"time",300));
    auto x = r->beginResponse(200,"text/plain","OK");
    addCORS(x); r->send(x);
  });

  server.on("/rotateright", HTTP_GET, [](AsyncWebServerRequest* r){
    rotateright(getArg(r,"time",300));
    auto x = r->beginResponse(200,"text/plain","OK");
    addCORS(x); r->send(x);
  });

  server.on("/scan", HTTP_GET, [](AsyncWebServerRequest* r){
    sendScanBinary(r);
  });

  server.on("/pose", HTTP_GET, [](AsyncWebServerRequest* r){
    posex = getArg(r,"x",0);
    posey = getArg(r,"y",0);
    posez = getArg(r,"z",0);
    auto x = r->beginResponse(200,"text/plain","OK");
    addCORS(x); r->send(x);
  });

  server.on("/ping", HTTP_GET, [](AsyncWebServerRequest *r){
    r->send(200,"text/plain","OK");
  });

  server.begin();
}

// ============================================================
// LOOP
// ============================================================
void loop() {

  // Lire le lidar régulièrement
  lidar.readScan();

  // Laisser respirer la pile WiFi
  static uint32_t lastYield = 0;
  if (millis() - lastYield > 20) {
    lastYield = millis();
    yield();
  }

  // Arrêt auto des moteurs
  if (moving && millis() > nextStop) {
    mecanumCar.Stop();
    moving = false;
  }
}
