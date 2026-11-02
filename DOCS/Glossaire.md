# Glossaire Cartographie et Localisation

Ce glossaire regroupe les définitions essentielles utilisées dans le module **Cartographie et Localisation**.  
Chaque terme est défini de manière concise et contextualisée pour la robotique mobile.

---

## Liste des termes

- [Capteur](#capteur)
- [Carte d’occupation / Grille d'occupation (Grid Map / Occupancy Grid)](#carte-d%E2%80%99occupation-/-grille-d'occupation-(grid-map-/-occupancy-grid))
- [Carte sémantique (Semantic Map)](#carte-s%C3%A9mantique-(semantic-map))
- [Carte vectorielle / Feature-based (Landmark Map)](#carte-vectorielle-/-feature-based-(landmark-map))
- [Cartographie (Mapping)](#cartographie-(mapping))
- [Correction de boucle (Loop Solving)](#correction-de-boucle-(loop-solving))
- [Détection de boucle (Loop Closure Detection)](#d%C3%A9tection-de-boucle-(loop-closure-detection))
- [Erreur de dérive (Drift Error)](#erreur-de-d%C3%A9rive-(drift-error))
- [ESP32](#esp32)
- [Filtre de Kalman étendu (EKF)](#filtre-de-kalman-%C3%A9tendu-(ekf))
- [Fusion de données (Sensor Fusion)](#fusion-de-donn%C3%A9es-(sensor-fusion))
- [Lidar (360)](#lidar-(360))
- [Liste des termes](#liste-des-termes)
- [Localisation (Localization)](#localisation-(localization))
- [Nuage de points (Point Cloud)](#nuage-de-points-(point-cloud))
- [Odométrie](#odom%C3%A9trie)
- [Repère / Landmark](#rep%C3%A8re-/-landmark)
- [SLAM (Simultaneous Localization and Mapping)](#slam-(simultaneous-localization-and-mapping))
- [Système de coordonnées](#syst%C3%A8me-de-coordonn%C3%A9es)
- [Transmission Wi-Fi (UDP / TCP)](#transmission-wi-fi-(udp-/-tcp))

---

## Capteur

**Définition courte :**  
Dispositif permettant de mesurer une grandeur physique et de la convertir en donnée numérique.

**Explication :**  
En robotique mobile, un capteur fournit des informations sur l’environnement ou l’état du robot.  
Exemples : Lidar (distance), IMU (orientation), encodeur (vitesse), caméra (vision).  
Les données capteurs sont fusionnées pour la cartographie et la localisation.

---

## Carte d’occupation / Grille d’occupation (Grid Map / Occupancy Grid)

**Définition courte :**  
Représentation de l’environnement sous forme de grille où chaque cellule indique si elle est **libre**, **occupée** ou **inconnue**.

**Explication :**  
Une carte d’occupation divise l’espace en cellules régulières (souvent carrées en 2D).  
Chaque cellule contient une probabilité d’occupation (0 libre, 1 obstacle).  
C’est la représentation la plus répandue pour le SLAM 2D.

---

## Carte sémantique (Semantic Map)

**Définition courte :**  
Carte enrichie contenant des informations sur la nature des objets (murs, portes, personnes, etc.).

**Explication :**  
Contrairement aux cartes purement géométriques, une carte sémantique associe des **étiquettes sémantiques** aux zones détectées.  
Elle permet une compréhension de l’environnement utile pour les robots de service ou la navigation autonome.

---

## Carte vectorielle / Feature-based (Landmark Map)

**Définition courte :**  
Carte constituée d’un ensemble de repères géométriques (landmarks) extraits de l’environnement.

**Explication :**  
Une carte vectorielle ne stocke que des éléments distinctifs : coins, murs, objets, points caractéristiques.  
Ces cartes sont compactes, précises et adaptées aux SLAM basés sur caméras ou lidars haute résolution.  
Elles sont couramment utilisées dans **EKF-SLAM** ou **Graph-SLAM**.

---

## Cartographie (Mapping)

**Définition courte :**  
Processus consistant à construire une représentation de l’environnement à partir des capteurs.

**Explication :  
**La cartographie consiste à créer un modèle 2D ou 3D de l’environnement à partir de mesures (Lidar, caméra, sonar).  
La carte sert ensuite à la navigation, la planification ou l’évitement d’obstacles.

---

## Correction de boucle (Loop Solving)

**Définition courte :**  
Ajustement global de la carte et de la trajectoire après la détection d’une boucle.

**Explication :**  
Après détection d’une boucle, le système **réoptimise la trajectoire complète** pour réduire l’erreur accumulée.  
Méthodes courantes : **Graph-SLAM**, **Pose Graph Optimization**.

---

## Détection de boucle (Loop Closure Detection)

**Définition courte :**  
Reconnaissance d’un lieu déjà visité pour réduire l’erreur de dérive.

**Explication :**  
Elle permet d’identifier qu’un environnement observé correspond à un lieu déjà cartographié.  
Cela déclenche ensuite une phase de **correction de boucle** (*loop solving*).  
Élément central du SLAM moderne.

---

## Erreur de dérive (Drift Error)

**Définition courte :**  
Erreur accumulée au fil du temps dans la position estimée du robot.

**Explication :**  
Les erreurs successives (bruit, glissement, imprécision) s’accumulent et créent une **dérive**.  
La détection et la correction de boucle servent à compenser cette dérive.

---

## ESP32

**Définition courte :**  
Microcontrôleur Wi-Fi/Bluetooth abordable utilisé pour la communication et le traitement embarqué.

**Explication :**  
L’ESP32 peut acquérir les données du Lidar LD06 et les transmettre sans fil vers un PC.  
Dans ce module, il joue le rôle de **passerelle** entre le robot et l’ordinateur.

---

## Filtre de Kalman étendu (EKF)

**Définition courte :**  
Méthode probabiliste de fusion de données et d’estimation d’état non linéaire.

**Explication :**  
L’EKF fusionne des mesures bruitées (IMU, Lidar…) pour estimer l’état du robot.  
Très utilisé dans les premiers SLAM, notamment **EKF-SLAM**.

---

## Fusion de données (Sensor Fusion)

**Définition courte :**  
Combinaison de mesures issues de capteurs différents pour améliorer la précision.

**Explication :**  
Elle vise à réduire les incertitudes en croisant plusieurs sources d’information.  
Outils : filtres de Kalman, filtres de particules, approches bayésiennes.

---

## Lidar 360°

**Définition courte :**  
Capteur de télémétrie laser mesurant des distances sur 360°.

**Explication :**  
Le LD06 effectue une rotation continue et produit des mesures angle/distance/intensité à haute fréquence.  
Indispensable pour la cartographie et la localisation 2D.

---

## Localisation (Localization)

**Définition courte :**  
Estimation de la position et de l’orientation du robot dans un environnement.

**Explication :**  
Elle repose sur la comparaison entre les mesures actuelles du Lidar et la carte existante.  
Indispensable pour tout robot autonome.

---

## Nuage de points (Point Cloud)

**Définition courte :**  
Ensemble de points représentant les surfaces détectées.

**Explication :**  
Un nuage de points regroupe les mesures (x, y) ou (x, y, z).  
Il sert de base à la cartographie ou à l’extraction de features.

---

## Odométrie

**Définition courte :**  
Estimation du déplacement du robot à partir de ses capteurs de mouvement.

**Explication :**  
L’odométrie utilise les encodeurs ou l’IMU, mais accumule des erreurs.  
Dans ce module, le robot **n’utilise pas d’odométrie** : la localisation repose sur le seul Lidar.

---

## Repère / Landmark

**Définition courte :**  
Point caractéristique utilisé comme référence pour la localisation.

**Explication :**  
Les landmarks servent à reconnaître des lieux et stabiliser la localisation.  
Très utilisés dans les approches **Feature-based SLAM**.

---

## SLAM (Simultaneous Localization and Mapping)

**Définition courte :**  
Méthode permettant de se localiser tout en construisant la carte.

**Explication :**  
Le SLAM combine simultanément :

1. **Mapping** : construire la carte

2. **Localization** : estimer la pose du robot

---

## Système de coordonnées

**Définition courte :**  
Référence spatiale utilisée pour décrire positions et orientations.

**Explication :**  
En robotique, on utilise :

- le **repère robot**

- le **repère monde**

Les transformations (rotation, translation) permettent d’exprimer correctement les mesures dans la carte.

---

## Transmission Wi-Fi (UDP / TCP)

**Définition courte :**  
Méthodes de communication réseau entre le robot et le PC.

**Explication :**

- **UDP** : rapide, pour les flux continus (scans Lidar),

- **TCP** : fiable, pour le contrôle ou les commandes.

---

## Remarques

Ce glossaire accompagne les documents *cartographie.md*, *localisation.md* et les TP du module.  
Il constitue une base de référence et peut être enrichi selon vos besoins.

---


## Version XML pour import

[Glossaire.xml](Glossaire.xml) contient les mêmes 19 concepts sous une forme abrégée pour l'import dans un glossaire Moodle. Les définitions XML sont des synthèses : le présent document reste la référence détaillée. Lors d'une mise à jour, vérifier les deux versions. Le fichier est syntaxiquement valide ; tester l'import sur l'instance Moodle cible avant diffusion et vérifier les accents et le rendu HTML des définitions.

---

© 2026 – Jonathan Quillès – Module Cartographie et Localisation appliquée à la robotique mobile
