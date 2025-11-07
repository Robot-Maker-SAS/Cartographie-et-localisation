# Cartographie-et-localisation

Ce module propose une **introduction aux principes de cartographie (mapping) et de localisation** avec une application pratique dans le cadre d’un robot mobile équipé d’un [**Lidar LD06**](https://www.robot-maker.com/shop/capteurs/468-lidar-ld06-468.html) et d’un **microcontrôleur [ESP32 + shield](https://www.robot-maker.com/shop/cartes-programmables/642-esp-32-shield-642.html)** pour de la cartographie et de la localisation en 2D.

L’objectif est de permettre aux étudiants de comprendre et de mettre en œuvre les bases du **SLAM (Simultaneous Localization and Mapping)** à travers des activités expérimentales mêlant capteurs, traitement de données et représentation spatiale.

---

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

```
Cartographie-et-localisation-2D/
│
├── README.md
│   → Présentation générale du module.
│
├── DOCS/
│   ├── Cartographie/
│   ├── Localisation/
│   ├── Présentation.pptx
│   ├── Glossaire.md
│   → Documents de cours, explications, présentations et articles.
│
├── RESSOURCES/
│   ├── LD06/
│   ├── MecanumCarV2/
│   ├── Tools/
│   └── Programmer un ESP32 avec l'IDE Arduino.md
│   → Guides matériels, drivers, outils d’analyse et scripts d’aide.
│
└── TP/
    ├── Consignes.md
    → C’est dans ce dossier que vous déposerez vos livrables.


```

---

## 🪪 Licence

Ce projet est diffusé sous licence **MIT**.  
Vous êtes libres de l’utiliser et de le modifier à des fins pédagogiques, sous réserve de citer la source.  
© 2025 – QUILLES Jonathan– Robot Maker SAS
