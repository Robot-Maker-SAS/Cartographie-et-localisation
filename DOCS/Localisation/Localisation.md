# Localisation d'un robot mobile

## Objectif du cours

Ce document présente les principes de la **localisation** en robotique mobile

L’objectif est de comprendre comment un robot peut construire, mettre à jour et exploiter une représentation numérique de son environnement grâce aux différents capteurs à sa disposition.

Les étudiants pourront :

- Comprendre le rôle et les objectifs de la localisation en robotique mobile et le principe générale.
- Découvrir les notions de localisations relative et de localisation absolues, 
- Comprendre les différents méthode de localisation en fonction de capteurs et des modèles de cartographie utilisés. 

---

## 1. Introduction

**Définition :**  
La **localisation** est le processus qui consiste à **estimer la pose du robot**, c'est à dire **sa position et son orientation dans son environnement** à partir des informations issues de ses capteurs.  
Autrement dit, il s’agit de répondre à la question :

> *« D'après ce que j'observe, où suis-je et comment suis-je orienté ? »*

Cette localisation peut se faire par rapport à une **carte connue*** ou par rapport à une **position précédente***.
La localisation est **étroitement liée à la cartographie** :

> *« Sans carte, comment indiquer où nous sommes ? »*
> 
> *« Sans savoir où nous sommes comment construire la carte de ce qui nous entoure?»*

---

**Expression de la pose du robot :**

En **2D**, la pose X du robot est généralement définie par :
X = [x, y, θ]

$$
\mathbf{X_{2D}} =
\begin{bmatrix}
x \\
y \\
θ \\
\end{bmatrix}
$$

où :

- **x, y** sont les coordonnées du robot dans le plan 2D,
- **θ** (theta) est l’**angle d’orientation**, c’est-à-dire la rotation du robot autour de l’axe vertical (Z).

En **3D**, la pose doit prendre en compte la position dans l’espace ainsi que les trois angles de rotation indépendants.  
On note généralement :

X = [x, y , z, φ, θ, ψ]

$$
\mathbf{X_{3D}} =
\begin{bmatrix}
x \\
y \\
z \\
φ \\
θ \\
ψ
\end{bmatrix}
$$

où :

- (x, y, z) représentent la **position** du robot dans l’espace 3D,
- (φ, θ, ψ) représentent les **angles d’Euler** :
  - φ (phi) → **roulis (roll)** : rotation autour de l’axe X,
  - θ (theta) → **tangage (pitch)** : rotation autour de l’axe Y,
  - ψ (psi) → **lacet (yaw)** : rotation autour de l’axe Z.

**⚠️On note que la notation en 2D et en 3D n'utilise pas par défaut la même lettre pour représenté le lacet !**

---

## **2. Types de localisation**

Selon la source de référence utilisée, on distingue deux grandes approches pour la localisation selon la manière dont la position est estimée : la **localisation absolue** et la **localisation relative**.

---

### **a. Localisation absolue**

La localisation absolue fournit la position du robot **dans un repère fixe**, généralement associé à la **carte de l’environnement** ou à un **système global de coordonnées** (ex. GPS, balises, repères visuels connus).

#### **Principe**

- Le robot détermine directement sa position par rapport à un ensemble de **références fixes connues**.

- Chaque estimation est **indépendante** des déplacements précédents.

- Elle repose sur la **mesure d’une position globale**, et non sur l’intégration d’un mouvement.

- L’objectif est de retrouver la **pose absolue** du robot dans le repère global de la carte.

- Cette approche nécessite un **modèle de référence** (points, marqueurs, signaux radio, carte 2D/3D) connu **a priori**.

#### **Avantages**

- Aucune accumulation d’erreurs : pas de **dérive** au cours du temps.

- Permet une **relocalisation instantanée** après perte de position.

- Souvent plus robuste sur le long terme.

#### **Inconvénients**

- Nécessite des **infrastructures externes** (balises, satellites, marqueurs) ou une carte connue.

- **Inutilisable ou imprécise** dans certains environnements (ex. GPS indoor).

- La fréquence et la précision peuvent être limitées.

-> Voir 3. Exemples d’applications et type des capteurs pour localisation absolue

---

### **b. Localisation relative**

La **localisation relative** consiste à estimer la **position du robot par rapport à une position précédente**,  à partir des **déplacements mesurés** par ses capteurs.  
C’est le principe de la **navigation incrémentale** (ou *dead reckoning*).
Contrairement à la localisation absolue, elle **n’utilise pas de repères fixes externes** : la position est déduite à partir des **mouvements effectués** ou des **changements perçus** entre deux instants successifs.

Elle est souvent exprimée sous forme d’un **vecteur de déplacement**

$$
\mathbf{ΔX_{2D}} =
\begin{bmatrix}
Δx \\
Δy \\
Δ\theta \\
\end{bmatrix}

\mathbf{ΔX_{3D}} =
\begin{bmatrix}
Δx \\
Δy \\
Δz \\
Δφ \\
Δθ \\
Δψ \\
\end{bmatrix}
$$

et intégrée dans le temps pour estimer la pose courante.

---

#### **Principe général**

- On part d’une position initiale connue.

- Le robot estime **son mouvement local** à partir des informations de ses capteurs.

- Chaque nouvelle position est obtenue par **intégration incrémentale** du déplacement estimé : on intègre les mesures de déplacement (linéaire et angulaire) pour estimer la nouvelle position.
  
  Xt​=Xt−1​+Δx

- Les erreurs se **cumulent dans le temps** → on parle de **dérive progressive**.

- Ces approches sont donc précises **à court terme**, mais nécessitent souvent une **recalibration absolue** périodique (via un repère ou une carte).

#### **Avantages**

- Fonctionne **sans infrastructure externe**.

- **Réactive et continue** : donne une estimation fluide à haute fréquence.

- Suffisante pour de petits déplacements ou des corrections rapides.

#### **Inconvénients**

- **Accumulation d’erreurs** au fil du temps (dérive).

- Sensible au **glissement**, au **bruit des capteurs**, et aux **mouvements brusques**.

- Nécessite souvent une **recalibration** périodique via une localisation absolue.

-> Voir 4. Exemples d’applications et type des capteurs pour localisation relative

---

### **c. Combinaison des deux approches**

En pratique, un robot combine les deux types de localisation pour tirer parti de leurs avantages :

- la **relative** pour le suivi local en temps réel,

- la **globale** pour se corriger périodiquement (fusion de données, SLAM, GPS + IMU, etc.).

| Type         | Source                           | Avantage principal                  | Limite principale         |
| ------------ | -------------------------------- | ----------------------------------- | ------------------------- |
| **Absolue**  | GPS, balises, vision par repères | Corrige la dérive, position globale | Dépend de l’environnement |
| **Relative** | Odométrie, IMU, Lidar, vision    | Haute fréquence, autonomie          | Dérive cumulative         |

Cette **fusion de données** est au cœur des systèmes modernes de localisation

> la localisation relative fournit la continuité,  
> la localisation absolue apporte la correction globale.

-> Voir 5. Fusion des données de localisation

---

## 3. Exemples d’applications et type des capteurs pour localisation absolue

### a) Localisation par GPS

**Principe :**

- Le robot mesure le **temps de propagation des signaux** entre plusieurs satellites et son récepteur.

- Par **trilatération**, il estime sa position (latitude, longitude, altitude) dans un repère géodésique global (WGS84).

- En ajoutant un gyroscope ou une boussole, on obtient aussi une orientation absolue approximative.

**Caractéristiques :**

- **Précision :**
  
  - GPS standard : ±3 à 10 m.
  
  - GPS différentiel (DGPS/RTK) : ±1 à 2 cm.

- **Fréquence de mise à jour** : 1 à 20 Hz selon les modules.

- **Latence** : faible, mais dépendante de la visibilité satellite.

**Avantages :**

- Couverture mondiale.

- Aucun besoin d’infrastructure locale.

- Donne une position absolue directe.

**Limites :**

- Inefficace **en intérieur** ou sous abri.

- Dépend des conditions atmosphériques et de la géométrie satellite.

- Ne donne **aucune information sur l’environnement local**.

**Applications :**

- Véhicules autonomes, drones, robots agricoles, cartographie extérieure.

---

### **b) Localisation par balises radio (UWB / Wi-Fi / RFID)**

**Principe :**

- Des **balises fixes** sont disposées à des positions connues.

- Le robot mesure la **distance ou le temps de vol** d’un signal radio (Ultra Wide Band, Wi-Fi RTT, RFID, Bluetooth BLE).

- Par **triangulation** ou **trilatération**, il détermine sa position dans le repère des balises.

**Caractéristiques :**

- Précision :
  
  - UWB : ±10 cm en intérieur.
  
  - Wi-Fi RTT : 0,5 à 1 m.
  
  - RFID passif : détection plutôt que mesure de distance.

- Portée : 5 à 50 m selon la technologie.

**Avantages :**

- Fonctionne **en intérieur** sans visibilité directe.

- Peu sensible aux conditions lumineuses.

- Infrastructure simple à déployer (balises fixes).

**Limites :**

- **Installation nécessaire** de balises dans l’environnement.

- Sensible aux **réflexions radio** (multipath).

- Peut nécessiter une **calibration** précise des balises.

**Applications :**

- Robots d’usine, AGV en entrepôt, navigation dans les bâtiments, logistique.

---

### c) **Localisation optique externe (Vicon, OptiTrack, Qualisys)**

**Principe :**

- Des **caméras externes calibrées** détectent des **marqueurs réfléchissants** ou **actifs** sur le robot.

- Le système calcule la position 3D du robot par **triangulation optique**.

- Les coordonnées obtenues sont exprimées dans un repère global fixé par le système.

**Caractéristiques :**

- Précision : de **±0.5 mm à ±2 mm**.

- Fréquence : jusqu’à 200–500 Hz.

- Nécessite plusieurs caméras autour de la zone de travail.

**Avantages :**

- Extrêmement précis.

- Temps réel, très stable.

- Permet la **capture complète de trajectoire 3D**.

**Limites :**

- Nécessite une **infrastructure coûteuse et calibrée**.

- Limité à une **zone de travail délimitée**.

- Fonctionne uniquement **en visibilité directe** des marqueurs.

**Applications :**

- Recherche en robotique, biomécanique, calibration de capteurs, validation d’algorithmes de SLAM, cinéma et effet spéciaux.

---

### **d) Vision par repères connus (fiduciaux / markers)**

**Principe :**

- Une caméra embarquée détecte des **repères visuels** placés à des positions connues dans l’environnement.

- Chaque marqueur (ex. **ArUco**, **AprilTag**) contient un identifiant unique permettant de retrouver sa **position absolue** et son **orientation** dans la carte.

- À partir de la pose relative du marqueur dans l’image, on calcule la pose du robot par **résolution de la géométrie projective** (PnP).

**Caractéristiques :**

- Précision : quelques millimètres à quelques centimètres selon la calibration de la caméra.

- Fréquence : jusqu’à 60 Hz selon la caméra et la complexité de la scène.

- Portée : 0.2 à 5 m selon la taille des marqueurs.

**Avantages :**

- Peu coûteux.

- Pas d’infrastructure électronique.

- Facile à déployer et à calibrer.

- Peut être combiné à la vision naturelle.

**Limites :**

- Nécessite **éclairage suffisant** et **visibilité** directe.

- Sensible à la **perspective** et à la **distance**.

- Champ de vision limité à la caméra.

**Applications :**

- Laboratoires de robotique, drones indoor, petits robots pédagogiques, robots collaboratifs.

---

### e) **Lidar sur carte connue (Scan Matching / Map Matching)**

**Principe :**

- Le robot dispose d’une **carte de référence connue** (grid map ou carte vectorielle).

- À chaque mesure, il compare le **scan lidar courant** (ensemble de points 2D/3D) à la carte.

- L’algorithme cherche la transformation (x,y,θ) qui minimise l’erreur entre les points mesurés et les obstacles de la carte.

- Cette recherche peut s’effectuer par :
  
  - **ICP (Iterative Closest Point)** : itérations sur les correspondances de points les plus proches.
  
  - **NDT (Normal Distributions Transform)** : comparaison avec une carte probabiliste (distribution de voxels).
  
  - **Correlative Scan Matching** : comparaison de corrélation directe entre cartes locales et carte globale.

**Caractéristiques :**

- Précision : quelques millimètres à quelques centimètres.

- Fréquence : 5 à 50 Hz selon la puissance de calcul et la densité du lidar.

- Fonctionne sans GPS, y compris en intérieur.

**Avantages :**

- Très bonne précision.

- Ne nécessite pas de balises ni de repères visuels.

- Robuste aux conditions d’éclairage.

- Peut se coupler à d’autres capteurs pour une localisation hybride.

**Limites :**

- Nécessite une **carte de référence fiable et bien calibrée**.

- Demande une **puissance de calcul** importante.

- Peut échouer si la carte et l’environnement ont trop changé.

**Applications :**

- Véhicules autonomes, robots mobiles en entrepôt, SLAM 2D/3D, localisation sur carte préexistante.

### f) Tableau récapitulatif des solutions absolues :

| **Technologie**                                        | **Principe**                                                                                  | **Précision typique**                      | **Environnement / Portée**                                 | **Avantages**                                        | **Limites**                                                        | **Applications typiques**                              |
| ------------------------------------------------------ | --------------------------------------------------------------------------------------------- | ------------------------------------------ | ---------------------------------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------ |
| **GPS / GNSS**                                         | Mesure du temps de vol des signaux satellites → trilatération de la position (lat, lon, alt). | ±3–10 m (GPS standard)±1–2 cm (RTK / DGPS) | Extérieur, portée illimitée (visibilité satellite requise) | Couverture mondialePas d’installation locale         | Inefficace en intérieurSensibilité à la météo et aux obstacles     | Drones, véhicules autonomes, robots agricoles          |
| **Balises radio (UWB / Wi-Fi / RFID)**                 | Triangulation à partir de la distance mesurée entre balises fixes et robot.                   | UWB : ±10 cmWi-Fi RTT : 0.5–1 m            | Intérieur, 5 à 50 m                                        | Précis en intérieurPas de visibilité optique requise | Nécessite installation et calibrationSensible aux réflexions radio | Robots d’usine, AGV, navigation indoor                 |
| **Systèmes optiques (Vicon / OptiTrack)**              | Caméras externes suivent des marqueurs sur le robot → triangulation 3D.                       | ±0.5–2 mm                                  | Zone limitée, 5–10 m max                                   | Très grande précisionTemps réel                      | Coût élevéInfrastructure calibrée requise                          | Recherche robotique, capture de mouvement, calibration |
| **Vision par repères connus (ArUco / AprilTag)**       | Détection de marqueurs visuels à positions connues → résolution PnP.                          | Quelques mm à cm                           | Intérieur, 0.2–5 m                                         | Simple et peu coûteuxFacile à déployer               | Dépend lumière / visibilitéChamp de vision limité                  | Robots pédagogiques, drones indoor, robotique mobile   |
| **Lidar sur carte connue (Scan Matching / ICP / NDT)** | Alignement d’un scan lidar avec une carte connue pour estimer la pose absolue.                | mm à quelques cm                           | Intérieur / extérieur selon le lidar                       | Très précisPas de balisesIndépendant de la lumière   | Calcul intensifNécessite carte fiable                              | Robots mobiles, SLAM 2D/3D, véhicules autonomes        |

## 4. Exemples d’applications et type des capteurs pour localisation relative

### a) Odométrie (roues codeuses)

**Principe :**

- le robot est équipée de roues codeuses (roues équipées d'encodeurs) qui compte des **impulsions par tour**.

- En connaissant le **rayon des roues** et la **distance entre les roues**, on obtient des équations de cinématique  qui permettent le calcul dun delta de déplacement linéaire et en rotation du robot.

- L'intégration des déplacements nous donne la nouvelle position.

**Caractéristiques :**

- Précision : millimétrique à court terme.

- Fréquence : élevée (100–1000 Hz).

- Coût : faible.

**Avantages :**

- Simple à implémenter.

- Aucun traitement complexe.

- Idéal pour mesurer les mouvements à court terme.

**Limites :**

- **Accumulation d’erreurs** (glissement, jeu mécanique).

- Ne fonctionne que sur des surfaces adhérentes.

- Nécessite des codeurs précis et bien calibrés.

- N'est pas compatible avec tous les types de robots

**Applications :**

- Robots différentiels, AGV, robots pédagogiques, base mobile ROS. compétitions

---

### b) **IMU (Inertial Measurement Unit)**

**Principe :**

- L’IMU mesure les **accélérations linéaires** (accéléromètre) et les **vitesses angulaires** (gyroscope).

- En intégrant ces mesures dans le temps, on estime la **vitesse** puis la **position**.

- Les magnétomètres peuvent fournir une **orientation absolue** (boussole électronique).

**Caractéristiques :**

- Précision : élevée sur quelques secondes, mais dérive rapide.

- Fréquence : très haute (jusqu’à 1 kHz).

- Données continues même sans contact avec le sol.

**Avantages :**

- Fonctionne dans tous les environnements (même sans GPS ni contact au sol).

- Réagit très vite aux accélérations.

- L'intégration de premier ordre du gyromètre est très efficace pour le calcul de déplcament angulaire

- Complément idéal de l’odométrie.

**Limites :**

- **Dérive quadratique** avec le temps sur les accélération (intégration  double du bruit ). 

- Bias, nécessite un calibrage, et sensible à la température.

- Nécessite un **filtrage (Kalman, complémentaire)**.

- Sensible aux vibrations et aux chocs, aux perturbations magnétique et à la température.

**Applications :**

- Drones, robots à pattes, fusion de capteurs (IMU + Lidar / Vision), navigation inertielle, missile ballistique.

---

### c) **Odométrie visuelle (Visual Odometry / VO)**

**Principe :**

- Le robot capture des **images successives** avec une ou plusieurs caméras.

- Des **points caractéristiques (features)** sont détectés (ex. ORB, SIFT, FAST).

- En suivant leurs déplacements dans les images, on calcule le **mouvement relatif** de la caméra (translation + rotation).

- Si la calibration est connue, on peut estimer la pose 3D.

**Deux variantes principales :**

1. **Monoculaire VO** : une seule caméra → la trajectoire est connue à un facteur d’échelle près.

2. **Stéréo VO** : deux caméras → la profondeur est mesurée directement.

**Caractéristiques :**

- Précision : de l’ordre du cm à court terme.

- Fréquence : 20 à 100 Hz selon la puissance de calcul.

- Coût : modéré (caméra + traitement CPU/GPU).

**Avantages :**

- Fonctionne sans encodeur ni GPS.

- Fournit simultanément **position et orientation**.

- Compatible avec l’odométrie visuelle-inertielle (VIO) pour plus de stabilité.

**Limites :**

- Dépend fortement de la **texture** et de la **lumière**.

- Perte de suivi possible (motion blur, surfaces uniformes).

- Calcul intensif en temps réel.

**Applications :**

- Drones, véhicules autonomes, SLAM visuel (ORB-SLAM, DSO, VINS-Mono).

---

### d) Lidar – Scan Matching successif

**Principe :**

- Le robot compare **deux scans lidar successifs** pour estimer le déplacement entre les deux.

- Les nuages de points sont alignés en minimisant la différence (erreur de correspondance).

- Méthodes courantes :
  
  - **ICP (Iterative Closest Point)** : aligne les points d’un scan sur ceux du précédent.
  
  - **NDT (Normal Distributions Transform)** : utilise des distributions locales au lieu de points individuels.
  
  - **Correlative Matching** : recherche de la meilleure translation/rotation par corrélation.

- Cette estimation donne la pose relative (Δx,Δy,Δθ) du robot entre deux scans.

**Caractéristiques :**

- Précision : quelques millimètres à centimètres.

- Fréquence : 5 à 20 Hz selon le lidar.

- Fonctionne sans GPS, en intérieur ou extérieur.

**Avantages :**

- Indépendant de la lumière ou de la texture.

- Peut fonctionner sur surfaces planes ou en 3D.

- Fournit directement des données utilisables pour le **SLAM**.

**Limites :**

- Sensible à la qualité du scan et au bruit.

- Peut échouer si les scans sont trop différents (rotation rapide, occlusion).

- Nécessite puissance de calcul modérée à élevée.

**Applications :**

- Robots autonomes, SLAM 2D/3D, localisation sur carte dynamique, navigation indoor.

### e) Tableau récapitulatif des solutions relatives :

| **Technologie**                          | **Principe**                                                                                                        | **Précision typique**                                                  | **Avantages**                                             | **Limites**                                         | **Applications typiques**                                            |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- | --------------------------------------------------------- | --------------------------------------------------- | -------------------------------------------------------------------- |
| **Odométrie (roues codeuses)**           | Comptage des impulsions des roues pour estimer la translation et la rotation du robot (cinématique différentielle). | Millimétrique à court terme                                            | Simple, peu coûteux, très rapide                          | Dérive cumulative (glissement, erreurs mécaniques)  | Robots à roues, AGV, plateformes mobiles éducatives, compétition     |
| **IMU (Inertial Measurement Unit)**      | Intégration des accélérations et vitesses angulaires mesurées par accéléromètres et gyroscopes.                     | Précise à court terme (ms), dérive rapide au-delà de quelques secondes | Fonctionne sans contact, haute fréquence, réactive        | Dérive quadratique, sensible au bruit et vibrations | Drones, robots à pattes, navigation inertielle, missile ballistique. |
| **Odométrie visuelle (Visual Odometry)** | Analyse du mouvement des points caractéristiques entre images successives pour estimer la pose (mono/stéréo).       | Centimétrique à court terme                                            | Fonctionne sans encodeurs, donne orientation et mouvement | Dépend lumière / texture, calcul intensif           | Drones, véhicules autonomes, SLAM visuel                             |
| **Lidar – Scan matching successif**      | Corrélation entre deux scans lidar successifs pour estimer ((\Delta x, \Delta y, \Delta \theta)).                   | mm à cm                                                                | Robuste, indépendant de la lumière, utile pour SLAM       | Sensible aux changements de scène, calcul coûteux   | Robots mobiles, SLAM 2D/3D, navigation indoor                        |

---

## 5. **Fusion des données de localisation**

La **fusion de données** consiste à combiner les informations issues de plusieurs capteurs afin d’obtenir une **estimation plus précise, robuste et cohérente** de l’état du robot (position, vitesse, orientation, etc.).  
Aucun capteur n’est parfait : chaque source a ses propres **forces** (ex. précision, fréquence, portée) et **faiblesses** (bruit, dérive, latence).  
En les fusionnant intelligemment, on exploite les atouts de chacun tout en compensant leurs erreurs respectives.

---

 **Pourquoi fusionner ?**

- **Réduire le bruit** des mesures individuelles (moyennage statistique).

- **Limiter la dérive** des capteurs relatifs (odométrie, IMU).

- **Combler les absences de données** (ex. perte de GPS).

- **Améliorer la précision et la robustesse** de la localisation et de la cartographie.

- **Détecter et rejeter** les mesures aberrantes (filtrage).

> Exemple typique :
> L’odométrie donne un mouvement précis à court terme mais dérive dans le temps.  
> Le GPS fournit une position absolue mais bruitée et lente.  
> En les fusionnant, on obtient une trajectoire **continue, fluide et précise**.

---

### **a) Approche de fusion la plus répandue : le filtre de Kalman**

Le **filtre de Kalman (KF)** est un algorithme mathématique de **fusion statistique** qui permet d’estimer un **état caché** (comme la position réelle du robot) à partir de **mesures bruitées**.  
Il combine **prédiction** (modèle du mouvement du robot) et **correction** (mesures des capteurs) en tenant compte des incertitudes de chaque source.

#### Principe général  :

1. **Prédiction :**  
   à partir de la position et de la vitesse précédentes, on estime la nouvelle position attendue.

2. **Correction :**  
   les mesures capteurs sont comparées à la prédiction ; la différence (innovation) ajuste l’estimation.

3. **Mise à jour de la covariance :**  
   on met à jour la confiance (incertitude) accordée à chaque capteur.

Le filtre minimise ainsi l’**erreur quadratique moyenne** entre l’estimation et la réalité.

>  Exemple : un **filtre de Kalman étendu (EKF)** est souvent utilisé en robotique pour fusionner **odométrie, IMU et GPS**, car il gère les **modèles non linéaires** du mouvement.

---

#### **Variantes de Kalman**

- **EKF (Extended Kalman Filter)** : version non linéaire, linéarisation autour de l’état courant.

- **UKF (Unscented Kalman Filter)** : évite la linéarisation en utilisant un ensemble de points sigma (plus stable).

- **Information Filter (IF)** : forme duale du KF, utile dans les graphes de contraintes (SLAM).

- **Kalman 3D / Multi-senseur** : utilisé pour la fusion Lidar-IMU-Vision dans les systèmes modernes (ex. LIO-SAM, VINS-Mono).

---

### **b) Autres approches de fusion**

En dehors des filtres de Kalman et de leurs variantes, il existe d’autres méthodes de **fusion de données** adaptées à des contextes spécifiques, notamment lorsque les modèles physiques sont **non linéaires**, **non gaussiens**, ou difficiles à formaliser mathématiquement.  
Ces approches sont souvent plus souples, mais parfois plus coûteuses en calcul.

---

#### **Filtre de particules (Monte Carlo Localization – MCL)**

Le filtre de particules représente l’état du robot non pas par une seule estimation, mais par un **ensemble de particules**, chacune représentant une hypothèse possible de position et d’orientation.  
Chaque particule est **pondérée** selon la **probabilité d’observer les mesures actuelles** depuis cette position, puis un **échantillonnage aléatoire** est effectué pour garder les hypothèses les plus crédibles.

Cette approche est particulièrement robuste dans les environnements **non linéaires** ou **multi-modaux**, où plusieurs positions plausibles peuvent coexister (par exemple, plusieurs couloirs identiques).  
Elle est utilisée dans la **localisation probabiliste** et dans certains algorithmes de **SLAM (FastSLAM)**.  
En revanche, elle nécessite un **nombre élevé de particules** pour une bonne précision, ce qui la rend coûteuse en calcul pour les grands espaces.

---

#### **Filtre complémentaire**

Le filtre complémentaire repose sur une idée simple mais efficace : **combiner des capteurs ayant des comportements complémentaires en fréquence**.  
Typiquement, un **capteur rapide mais bruité** (ex. gyroscope) est fusionné avec un **capteur lent mais stable** (ex. accéléromètre).  
Le premier capture les variations instantanées, tandis que le second corrige les dérives à long terme.

Cette méthode est très utilisée pour estimer l’**orientation (pitch, roll)** sur les petits systèmes embarqués, notamment les drones ou les robots à faible puissance de calcul.  
Elle ne repose pas sur un modèle statistique formel, mais sur une **pondération empirique** adaptée à la fréquence des signaux.  
Simple et légère, elle constitue une alternative pratique au filtre de Kalman lorsque la puissance de calcul est limitée.

---

#### **Optimisation par graphe (Graph-SLAM)**

Dans les systèmes de **cartographie et localisation simultanée (SLAM)**, la fusion des données peut être formulée comme un **problème d’optimisation globale**.  
Chaque **pose du robot** (position et orientation) et chaque **observation capteur** sont représentées sous forme de **nœuds et d’arêtes** dans un **graphe de contraintes**.  
L’algorithme cherche alors la configuration de poses qui **minimise l’erreur totale** entre les mesures et les observations.

Cette approche, dite **Graph-SLAM**, est particulièrement adaptée aux environnements étendus ou aux trajectoires bouclées (loop closure), car elle permet de **corriger les dérives accumulées** en recalculant la carte entière.  
Elle est utilisée dans la plupart des implémentations modernes de SLAM (g2o, Ceres, ORB-SLAM, Cartographer), notamment pour le **post-traitement** ou la **fusion de données multi-capteurs (Lidar, IMU, caméra)**.

---

#### **Fusion neuronale (Deep Sensor Fusion)**

Les approches d’**apprentissage profond** représentent une nouvelle génération de techniques de fusion.  
Plutôt que de définir mathématiquement la relation entre les capteurs, un **réseau de neurones** apprend à **pondérer et combiner les entrées** selon le contexte observé.  
Par exemple, une architecture peut apprendre à faire confiance davantage au **lidar** dans un tunnel sombre, ou à la **caméra** dans un environnement dégagé.

Ces modèles peuvent traiter des données **complexes et non linéaires** (images, nuages de points, signaux inertiels) et s’adaptent dynamiquement aux conditions.  
Cependant, ils nécessitent de **grandes bases d’entraînement**, une **puissance de calcul élevée** et manquent souvent d’**interprétabilité** (on ne sait pas toujours pourquoi le modèle choisit telle pondération).

Ces méthodes sont aujourd’hui très utilisées dans la **perception multisensorielle des véhicules autonomes**, les **robots de service** ou les **systèmes d’intelligence embarquée**.

---

### c) Synthèse :

#### Tableau comparatif :

| **Méthode de fusion**                               | **Principe**                                                                                     | **Type / Nature du modèle**              | **Avantages principaux**                                         | **Limites**                                                       | **Applications typiques**                                     |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------ | ---------------------------------------- | ---------------------------------------------------------------- | ----------------------------------------------------------------- | ------------------------------------------------------------- |
| **Filtre de Kalman (KF)**                           | Fusion séquentielle entre prédiction et mesure, en pondérant selon les incertitudes.             | Linéaire, bruit gaussien                 | Rapide, optimal (si hypothèses respectées), facile à implémenter | Modèle linéaire uniquement, sensible aux erreurs de modèle        | Suivi d’état simple, capteurs de position ou vitesse          |
| **Filtre de Kalman étendu (EKF)**                   | Linéarisation locale du modèle non linéaire pour appliquer les équations du Kalman.              | Non linéaire (approximation locale)      | Adapté aux systèmes réels (cinématique robot), robuste           | Erreurs de linéarisation possibles, instable si fort non-linéaire | Fusion IMU + GPS + odométrie, SLAM 2D/3D                      |
| **Filtre de Kalman non linéaire (UKF – Unscented)** | Utilise des points “sigma” pour propager les incertitudes sans linéariser.                       | Non linéaire exact (unscented transform) | Précis et stable sans dérivation analytique                      | Plus coûteux en calcul                                            | Robots autonomes, navigation précise, fusion Lidar/Vision     |
| **Filtre complémentaire**                           | Combinaison pondérée de signaux selon leur fréquence (rapide/bruité vs lent/stable).             | Empirique, sans modèle                   | Simple, très léger en calcul                                     | Approximation grossière, pas de gestion d’incertitude             | Orientation (fusion gyro–accéléromètre), microcontrôleurs     |
| **Filtre de particules (Monte Carlo)**              | Représente l’état par un ensemble de particules pondérées selon la probabilité des observations. | Non linéaire, non gaussien               | S’adapte à tout type d’environnement, robuste au bruit           | Coût élevé (nombre de particules), convergence lente              | Localisation probabiliste (MCL), SLAM partiellement connu     |
| **Optimisation par graphe (Graph-SLAM)**            | Représente poses et mesures sous forme de graphe, puis minimise l’erreur globale.                | Non linéaire, optimisation globale       | Très précis, cohérence globale de la carte                       | Calcul lourd, nécessite correspondances fiables                   | SLAM 2D/3D, post-traitement, cartographie de précision        |
| **Fusion neuronale (Deep Sensor Fusion)**           | Réseaux de neurones apprenant à pondérer ou combiner plusieurs capteurs selon le contexte.       | Apprentissage profond (data-driven)      | Gère données complexes et bruit non gaussien                     | Nécessite base d’entraînement, boîte noire                        | Véhicules autonomes, fusion caméra–lidar–radar                |
| **Fusion hiérarchique / multi-niveaux**             | Combine plusieurs fusions à différents niveaux (capteurs → modules → décision).                  | Hybride                                  | Flexible, adaptable à plusieurs sources                          | Complexité de conception                                          | Systèmes robotiques intégrés, architecture ROS multi-capteurs |

### **En résumé**

- La fusion permet de **corriger les faiblesses individuelles** des capteurs.

- Les **filtres de Kalman** restent la **méthode de référence** pour la robotique embarquée : ils sont rapides et optimaux.

- Les méthodes **statistiques (Kalman, particules)** reposent sur des modèles probabilistes et garantissent un cadre rigoureux.

- D’autres approches (filtre de particules, graphes, IA) prennent le relais lorsque les **modèles sont non linéaires** ou les **environnements incertains**.

- Les méthodes **empiriques (complémentaire)** sont simples et adaptées aux systèmes embarqués légers.

- Les approches **par optimisation** assurent une cohérence globale sur de longues trajectoires.

- Les méthodes **neuronales** ouvrent la voie à une fusion contextuelle et intelligente, mais au prix d’une complexité accrue.

## 6. Conclusion

La **localisation** vise à **estimer la pose du robot dans un repère connu**, à partir des **données capteurs** et de modèles géométriques de l’environnement.  
C’est une composante essentielle de tout système autonome, qu’il soit terrestre, aérien ou sous-marin.

Elle constitue l’une des **compétences fondamentales** de la robotique mobile : sans localisation fiable, un robot ne peut ni se déplacer, ni planifier, ni interagir efficacement avec son environnement.

Nous avons vu que :

- La **localisation absolue** repose sur des **repères fixes** ou des **systèmes globaux** (GPS, balises, carte connue).

- La **localisation relative** estime le déplacement à partir des **capteurs embarqués** (odométrie, IMU, vision, lidar).

- Aucune méthode n’est parfaite : chaque capteur a ses **forces** et **limites** selon le contexte.

- La **fusion de données** — via des filtres comme le **Kalman**, l’**EKF** ou le **filtre de particules** — permet d’obtenir une estimation **plus stable et fiable** dans le temps.

- En pratique, tout système robuste s’appuie sur une **fusion multi-capteurs** (IMU, lidar, caméra, GPS, etc.).

---

La performance d’un système de localisation dépend autant de la **qualité du modèle** que de la **cohérence des données** : calibration, synchronisation et fréquence d’échantillonnage sont essentielles.  
Les algorithmes doivent gérer le **bruit**, la **dérive** et l’**incertitude**, tout en restant **temps réel**.

Les approches modernes de **fusion multisensorielle** et de **SLAM** illustrent cette évolution et la frontière entre **localisation** et **cartographie** tend à disparaître.

---

© 2025 – Jonathan Quillès – Module Cartographie et Localisation appliquée à la robotique mobile
