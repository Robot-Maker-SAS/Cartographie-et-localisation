# Cartographie-et-localisation

Ce module propose une **introduction aux principes de cartographie (mapping) et de localisation** avec une application pratique dans le cadre d’un robot mobile équipé d’un [**Lidar LD06**](https://www.robot-maker.com/shop/capteurs/468-lidar-ld06-468.html) et d’un **microcontrôleur [ESP32 + shield](https://www.robot-maker.com/shop/cartes-programmables/642-esp-32-shield-642.html)** pour de la cartographie et de la localisation en 2D.

L’objectif est de permettre aux étudiants de comprendre et de mettre en œuvre les bases du **SLAM (Simultaneous Localization and Mapping)** à travers des activités expérimentales mêlant capteurs, traitement de données et représentation spatiale.

---

## Démarrage rapide

Consultez le [guide de démarrage](RESSOURCES/Utiliser%20les%20outils%20du%20module.md) pour lancer les outils, installer les dépendances et comprendre les formats de données.

## 🎯Objectifs pédagogiques

- Comprendre les principes fondamentaux de la **cartographie** et de la **localisation robotique**.

- Manipuler un capteur [**Lidar LD06**](https://www.robot-maker.com/shop/capteurs/468-lidar-ld06-468.html) et exploiter ses données.

- Concevoir des algorithmes simples de **traitement et de visualisation** (Python ou autre langage).

- Construire une **carte d’occupation** et une **carte vectorielle** à partir de mesures réelles.

- Développer des algorithmes de **localisation 2D** (scan matching).

- S’initier à la pratique du **SLAM (Simultaneous Localization and Mapping)**.

- Mettre en œuvre la **transmission des données** entre un robot ESP32 et un PC via Wi-Fi.

---

## 🗂️ Architecture du dépôt

L’ensemble des ressources du cours est organisé par thème :

```text
Cartographie-et-localisation/
├── README.md
├── DOCS/
│   ├── Présentation du module.pptx
│   ├── Glossaire.md
│   ├── Glossaire.xml
│   ├── Cartographie/                  # Cours, présentation et construction des cartes
│   └── Localisation/                  # Cours, présentation, pose et scan matching
│       └── Papers/                    # Articles et présentations de référence
├── RESSOURCES/
│   ├── Utiliser les outils du module.md
│   ├── Programmer un ESP32 avec l'IDE Arduino.md
│   ├── LD06/                         # Guide d'acquisition et documentation du capteur
│   │   ├── ESP32_LD06_Test/           # Exemple d'acquisition sur ESP32
│   │   └── Librairie/                 # Bibliothèque LD06 en archive ZIP
│   ├── MecanumCarV2/
│   │   ├── README.md                 # Matériel et câblage
│   │   ├── ESP32MecanumCar/           # Exemple de pilotage des moteurs
│   │   ├── CAD/                      # Support Lidar aux formats STL et STP
│   │   ├── Libraries/                # Bibliothèques du kit en archives ZIP
│   │   └── Examples.zip              # Exemples d'origine du kit
│   └── Tools/
│       ├── MapTool/
│       │   ├── MapTool.html          # Simulateur dans le navigateur
│       │   ├── maptoolPython/        # Version Python et requirements.txt
│       │   └── maptoolProcessing/    # Version Processing
│       └── RobotControl/
│           ├── RobotControl.html     # Client de pilotage et d'acquisition Web
│           ├── ESP32RobotControl/    # Programme ESP32 et serveur HTTP
│           └── RobotControl/         # Client Processing et son README
└── TP/
    └── Consignes.md                   # Exercices, livrables et critères de comparaison
```

---

## 🪪 Licence

Ce module est proposé par **Robot Maker SAS**.

Ce projet est diffusé sous licence **MIT**.  
Vous êtes libres de l’utiliser et de le modifier à des fins pédagogiques, sous réserve de citer la source.

---

© 2026 – Jonathan Quillès – Module Cartographie et Localisation appliquée à la robotique mobile
