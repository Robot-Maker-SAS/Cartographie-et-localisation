# Robot Mecanum Car V2 équipé d’un Lidar LD06

Ce TP utilise un **Mecanum Car V2** de **Keyestudio**, modifié pour être équipé d’un capteur [Lidar LD06](https://www.robot-maker.com/shop/capteurs/468-lidar-ld06-468.html).  
L’**Arduino Uno clone** d’origine a été remplacé par un [ESP32 + shield](https://www.robot-maker.com/shop/cartes-programmables/642-esp-32-shield-642.html) afin de permettre une communication Wi-Fi et un traitement plus rapide des données capteurs.

---

## Composition du kit

| Élément               | Description                               | Remarques                              |
| --------------------- | ----------------------------------------- | -------------------------------------- |
| **Châssis**           | Keyestudio Mecanum Car V2                 | Moteurs DC à roues Mecanum             |
| **Contrôleur**        | ESP32 + Shield                            | Remplace l’Arduino Uno                 |
| **Capteur principal** | Lidar LD06                                | Acquisition des distances 360°         |
| **Support Lidar**     | Plaque imprimée en 3D                     | Fichiers `.stl` et `.step` disponibles |
| **Fixation**          | 4 vis M4x6, 4 entretoises M4, 4 écrous M4 | Pour le montage du Lidar               |

---

## Documentation

- Documentation officielle Keyestudio :  [Mecanum Car V2 Wiki](https://docs.keyestudio.com/projects/KS0560/en/latest/docs/1.%20Product%20Introduction/1.%20Product%20Introduction.html)

- Les ressources du produit original sont dans les dossiers Libraries qui contient les librairies arduino nécessaire dont en particulier la librairie MecanumCar_V2.zip) et dans le dossier compressé Exemples.zip  qui contient les exemples de code originaux pour arduino uno qui peuvent servir d'inspiration afin d'en faire des version compatible ESP32.

---

## Montage du Lidar

Une **plaque d’adaptation 3D** a été conçue pour fixer le Lidar sur le robot.  
Les fichiers se trouvent dans le dossier : /CAD

Formats disponibles :

- `.stl` → impression 3D  
- `.step` → modification CAO (Fusion 360, SolidWorks, etc.)

Matériel nécessaire :

- 4 entretoises **M4**  
- 4 écrous **M4**  
- 4 vis **M4 x 6 mm**

---

## Connexions électroniques

**ESP32 ↔ Carte Mecanum Car (I2C)**

| Signal | Broche ESP32 | Fonction    |
| ------ | ------------ | ----------- |
| SCL    | D21          | Horloge I2C |
| SDA    | D19          | Données I2C |

> Ces connexions permettent de **piloter les moteurs** via le bus I2C.

**Lidar LD06 ↔ ESP32 (UART / PWM)**

| Signal     | Broche ESP32 | Description                                     |
| ---------- | ------------ | ----------------------------------------------- |
| TX (Lidar) | D35          | Transmission des données distance               |
| PWM        | D34          | Signal de synchronisation / vitesse de rotation |

---

## Extensions possibles disponibles

D'autres éléments supplémentaires peuvent être connectés suivant votre besoin.
Le Robot Mecanum Car V2 est équipé de 

- Plusieurs Leds RGB, 

- D'un récepteur IR, 

- De 3 capteurs de suivi de lignes

- D'un capteur ultrason HC-SR04 monté sur un servomoteur. 

---

© 2025 – Jonathan Quillès – Module Cartographie et Localisation appliquée à la robotique mobile
