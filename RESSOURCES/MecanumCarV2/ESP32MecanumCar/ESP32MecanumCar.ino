#include "MecanumCar_v2.h"

// ============================================================
// Exemple de pilotage du Mecanum Car V2 en code non bloquant
// ============================================================

// Exemple : moteurs pilotés en I2C sur les pins 19 et 21
mecanumCar mecanumCar(19, 21);

bool moving = false;
uint32_t nextStop = 0;

// Fonction générique pour lancer un mouvement pendant t millisecondes
void doMove(void (*fn)(), int t) {
  moving = true;
  fn();
  nextStop = millis() + t;
}

// Fonctions de mouvement simplifiées
void forward(int t)     { doMove([](){ mecanumCar.Advance(); }, t); }
void backward(int t)    { doMove([](){ mecanumCar.Back(); },     t); }
void left(int t)        { doMove([](){ mecanumCar.L_Move(); },   t); }
void right(int t)       { doMove([](){ mecanumCar.R_Move(); },   t); }
void rotateLeft(int t)  { doMove([](){ mecanumCar.Turn_Left(); },  t); }
void rotateRight(int t) { doMove([](){ mecanumCar.Turn_Right(); }, t); }

void setup() {
  Serial.begin(115200);
  delay(200);

  Serial.println("Démarrage du robot Mecanum...");
}

// Indice du mouvement en cours
int step = 0;
uint32_t nextAction = 0;

void loop() {

  // Gestion de l'arrêt auto des moteurs
  if (moving && millis() > nextStop) {
    mecanumCar.Stop();
    moving = false;
    Serial.println("Moteurs arrêtés.");
  }

  // ------------------------------------------------------------
  // Séquence automatique sur 6 secondes (6 actions de 1s)
  // ------------------------------------------------------------
  if (millis() < 5000 && millis() > nextAction && !moving) {

    switch (step) {
      case 0:
        Serial.println("▶ Avance 0.5s");
        forward(500);
        break;
      case 1:
        Serial.println("▶ Recule 0.5s");
        backward(500);
        break;
      case 2:
        Serial.println("▶ Déplacement droite 0.5s");
        right(500);
        break;
      case 3:
        Serial.println("▶ Déplacement gauche 0.5s");
        left(500);
        break;
      case 4:
        Serial.println("▶ Rotation droite 0.5s");
        rotateRight(500);
        break;
      case 5:
        Serial.println("▶ Rotation gauche 0.5s");
        rotateLeft(500);
        break;
    }

    // Prépare la prochaine étape
    nextAction = millis() + 800; // Pause de 300 ms entre les actions
    step++;
  }

  // Après 5 secondes : rien d’automatique, le robot reste immobile
}
