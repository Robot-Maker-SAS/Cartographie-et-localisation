# Programmer un ESP32 avec l'IDE Arduino

Ce tutoriel présente les étapes essentielles pour configurer l'environnement Arduino IDE et programmer une carte de type ESP32. Il s'adresse aux débutants souhaitant se familiariser avec cet écosystème.

---

## 1. Prérequis

Avant de commencer, assurez-vous de disposer des éléments suivants :

- Une carte ESP32 (ex. DevKitC, WROOM, WROVER…)

- Un câble USB de bonne qualité

- L'IDE Arduino installé (version récente recommandée)

- Une connexion Internet pour installer les dépendances

---

## 2. Installation des cartes ESP32 dans l'IDE Arduino

1. Ouvrez l'IDE Arduino.

2. Rendez-vous dans **Fichier > Préférences**.

3. Dans le champ *URL de gestionnaire de cartes supplémentaires*, ajoutez :
   
   `https://espressif.github.io/arduino-esp32/package_esp32_index.json`

4. Cliquez sur **OK**.

5. Allez dans **Outils > Type de carte > Gestionnaire de cartes**.

6. Recherchez « ESP32 », puis installez le paquet officiel *esp32 by Espressif Systems*.

---

## 3. Configuration de la carte ESP32

1. Accédez à **Outils > Type de carte** et sélectionnez votre modèle d’ESP32 (ex. *ESP32 Dev Module* dans notre cas).

2. Après avoir branché votre ESP32, choisissez le bon port dans **Outils > Port**.  
   (En cas de doute, si plusieurs ports COM sont visibles : sortez du menu Outils, débranchez l’ESP32, puis retournez dans **Outils > Port** pour vérifier lequel a disparu lors du débranchement.)

---

## 4. Premier programme : débogage et messages série

Voici un exemple minimaliste pour vérifier que votre carte fonctionne correctement.  
Vous pouvez utiliser le port série pour afficher des informations de débogage :

`void setup() {   Serial.begin(115200);   Serial.println("Démarrage ESP32"); }  void loop() {   Serial.println("Boucle en cours...");  delay(1000); }`

Pour téléverser le programme :

- Cliquez sur **Téléverser** dans l'IDE Arduino.

- Sur certaines cartes, vous devrez maintenir le bouton « BOOT » au début de l’upload.

Ensuite, ouvrez le **Moniteur série** via **Outils > Moniteur série** (ou utilisez le raccourci **CTRL + MAJ + M**).

Pour le reste, dans les grandes lignes, l’ESP32 se programme comme une carte Arduino. Vous pouvez suivre les cours de base de programmation Arduino.

---

## 5. Aller plus loin

L'ESP32 propose de nombreuses fonctionnalités :

- Wi-Fi (station, access point, web server…)

- Bluetooth et BLE

- Capteurs intégrés (Hall, touchpads)

- Support MQTT, HTTP, WebSocket…

Documentation utile :

- Arduino-ESP32 : [GitHub - espressif/arduino-esp32: Arduino core for the ESP32](https://github.com/espressif/arduino-esp32)

- Espressif API Reference : [https://docs.espressif.com](https://docs.espressif.com)

---

## 6. Conclusion

Vous êtes maintenant prêt à programmer et expérimenter avec les cartes ESP32 dans l'IDE Arduino. Commencez par des projets simples, puis explorez les capacités avancées du module selon vos besoins.
