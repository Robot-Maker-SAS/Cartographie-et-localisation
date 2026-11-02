# Cartographie (Mapping) en robotique mobile

## Objectif du cours

Ce document présente les notions fondamentales de **cartographie** en robotique mobile.  
L’objectif est de comprendre comment un robot peut construire, mettre à jour et exploiter une représentation numérique de son environnement.

Les étudiants pourront :

- Comprendre le rôle et les objectifs de la cartographie en robotique mobile et le principe générale.
- Découvrir les représentations les plus courantes : carte d’occupation, carte vectorielle, carte sémantique et les différents types de capteurs utilisés pour la cartographie.
- Comprendre comment fusionner les données pour produire une carte, ainsi que les limitations, et problèmes associés et les méthodes pour les résoudre.

---

## 1. Introduction

La **cartographie** (ou *mapping*) consiste à construire une **représentation numérique** de l’environnement à partir des mesures d’un ou plusieurs capteurs.  
Cette carte permet au robot de comprendre où il peut se déplacer, d’identifier les obstacles et de planifier des trajectoires.

Plusieurs capteurs peuvent être utilisés selon le contexte : intérieur, extérieur, aérien, terrestre et même sous-marin. 
Les robots roulants utilisent majoritairement une cartographie 2D, tandis que les drones et robots bipèdes nécessitent des modèles 3D.

### 2. Principe général

Le processus de cartographie peut être résumé ainsi :

1. **Phase initiale** : Le robot connaît (ou estime) sa position dans le repère global.
2. **Phase d'acquistion** : Le robot explore un environnement inconnu et ses capteurs (Lidar, caméras, ultrasons, radar…) mesurent des distances ou prennent des images. Il repère ainsi un **objet**, un **obstacle** ou un **point d’intérêt** via ses capteurs.
3. **Phase de calculs** : Il calcule la **position relative** de cet élément par rapport à lui-même. Les données sont transformées en coordonnées cartésiennes, dans le **repère du robot** puis dans le **repère de la carte** et met à jour la représentation.
4. Phase de mise à jour : Les points obtenus sont fusionnés pour construire et compléter une **carte cohérente**. La carte est mise à jour en continu, en ajoutant ou supprimant des éléments selon les nouvelles mesures.

Certaines cartes intègrent la **durée de vie** des obstacles ou une **probabilité de persistance**, pour prendre en compte les objets mobiles.

---

## 3. Exemples d’applications

- **Robots de service** : aspirateurs autonomes, tondeuses, robots de nettoyage.  
- **Véhicules autonomes** : voitures, navettes, AGV industriels.  
- **Robots d'inspections et robots aériens** : cartographie 3D de bâtiments, inspection d’environnements.  
- **Robots explorateurs** : quadrupèdes, sous-marins, robots spatiaux pour explorer les environnements inconnus, potentiellement hostiles. Grotte, mine, fond marins, champs de bataille

Ces systèmes partagent tous le même besoin : **comprendre leur environnement pour agir efficacement**.

---

## 4. Types de cartes en robotique

### a) Carte d’occupation (Occupancy Grid)

L’espace est divisé en **cellules** (souvent carrées en 2D ou cubique en 3D), chacune ayant une **probabilité d’être occupée**.

| Valeur | Signification |
| ------ | ------------- |
| 0      | Libre         |
| 1      | Occupée       |
| 0.5    | Inconnue      |

Chaque cellule peut aussi stocker des informations supplémentaires (dernière mise à jour, poids, persistance).

**Avantages :**

- Simple à implémenter et visualiser.
- Directement exploitable pour la navigation.

**Inconvénients :**

- Mémoire importante pour une carte fine.
- Résolution fixe.
- Peu d’information sémantique.

---

### b) Carte vectorielle (Feature-based Map)

La carte vectorielle stocke uniquement des **éléments géométriques distinctifs** (lignes (murs), intersections (coins) , objets).  
Ces éléments sont appelés *landmarks* (repères). Chaque repère est défini par ses coordonnées et ses propriétés ( Type, dimensions). Chaque élement peut également stocker des informations supplémentaire comme un niveau de confiance ou d'importance, une probabilité ou une durée de vie ... 

**Avantages :**

- Représentation compacte et précise.
- Très utile et précis pour la localisation.
- Idéal pour les environnements strucutrés

**Inconvénients :**

- Extraction de features moyennement complexe.
- Sensible au bruit et aux surfaces irrégulères, nécessite un bon pré traitement des données
- Moins adaptée aux environnements peu structurés

---

### c) Carte sémantique (Semantic Map)

La carte sémantique associe à chaque région ou objet une **étiquette descriptive** (porte, mur, meuble, personne…).  
Elle est souvent générée par des algorithmes de vision et d’IA.

**Avantages :**

- Représentation riche et interprétable.
- Permet une interaction “intelligente” avec l’environnement.

**Inconvénients :**

- Calculs lourds, nécessite des modèles entraînés.
- Moins précise géométriquement.

---

### Tableau comparatif des types de cartes

| Type de carte      | Avantages          | Inconvénients                        | Usage typique                       |
| ------------------ | ------------------ | ------------------------------------ | ----------------------------------- |
| Carte d’occupation | Simple, intuitive  | Mémoire élevée pour haute résolution | SLAM 2D, navigation au sol          |
| Carte vectorielle  | Compacte, précise  | Extraction complexe                  | SLAM basé sur repères, vision 2D/3D |
| Carte sémantique   | Riche, descriptive | Lourde en calcul                     | Robots de service, IA mobile        |

**Résumé :**  
Le choix du type de carte dépend du **niveau d’abstraction souhaité** et des **ressources de calcul disponibles et des capteurs utilisés**.

---

## 5. Capteurs utilisés pour la cartographie

Il existe plusieurs types de capteurs avec différents avantages et incovénients

| Type de capteur                   | Exemple concret                 | Portée                                                  | Type de données                     | Avantages                                                                                                             | Inconvénients / Limites                                                                                                                                                                                            |
| --------------------------------- | ------------------------------- | ------------------------------------------------------- | ----------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Capteur à ultrasons**           | HC-SR04, Ping 360               | 0,2 – 4 m                                               | Distance ponctuelle                 | Économique Peu sensible à la lumière Detecte les vitres, certains modèles peuvent être utilisés sous l'eau            | Portée très limitée Peu précis à cause entre autre du cone de détection large, moins fiale sur les surface qui absorbe les sons.                                                                                   |
| **Lidar 2D (360°)**               | LD06, RPLidar                   | 6 – 18 m                                                | Distances + angles (360°)           | Balayage complet 360° Précis (centimétrique) Données faciles à traiter (x, y) Fonctionne dans le noir                 | Uniquement dans un plan, portée limitée selon le modèle Moins fiable sur certaines surfaces comme les tissus noirs absorbant les IR, et ne détécte pas les vitres.<br/>Peut être sensible aux IR, et au brouillard |
| **Lidar 3D**                      | Livox Mid-360, Velodyne VLP-16  | 100 – 250 m                                             | Nuage de points 3D (x, y, z)        | Balayage 3D à 360° Bonne précision et portée Représentation complète de l’environnement Fonctionne dans le noir       | Coût élevé Données volumineuses, Fragile mécaniquement Moins fiable sur certaines surfaces comme les tissus noirs absorbant les IR, et ne détécte pas les vitres. Peut être sensible aux IR et au brouillard       |
| **Caméra de profondeur (RGB-D)**  | Intel RealSense D435, Kinect DK | 0,2 – 10 m                                              | Carte de profondeur + image couleur | Données 3D denses, Fournit également une image couleur, Fonctionne sur surfaces uniformes                             | Portée limitée Sensible à la lumière IR ambiante, Traitement lourd                                                                                                                                                 |
| **Caméra de stéréovision**        | Stereolabs ZED, RealSense T265  | 0,2 – 20 m                                              | Image + profondeur                  | Utilise deux caméras standard Fournit des données 3D et couleur Assez économique                                      | Sensible aux conditions d’éclairage Mauvaise estimation sur surfaces uniformes Traitement lourd                                                                                                                    |
| **Radar (FMCW / Doppler)**        | Navtech ClearWay, R2D100        | certains modèles ont une portée > 100 m (jusqu’à 300 m) | Distance + vitesse relative         | Fonctionne malgré brouillard, pluie ou poussière, Excellente portée, Détection de vitesse (effet Doppler)             | Résolution spatiale faible, Données difficiles à interpréter, Coût élevé pour modèles précis                                                                                                                       |
| **Caméra thermique (infrarouge)** | FLIR One, FLIR Lepton 3.5       | 0 – 30 m                                                | Température par pixel               | Fonctionne dans l’obscurité totale Détection des sources de chaleur Intéressant pour robots de secours / surveillance | Résolution faible, Ne mesure pas la profondeur, Sensible à la température ambiante                                                                                                                                 |
| **Caméra 360°**                   | Dyson 360° Eye                  | Variable (vision sphérique)                             | Image couleur 360°                  | Fournit une image panoramique complète, Permet la détection d’objets sur 360°, pratique pour compléter un lidar 360°  | Difficile d’extraire des données 3D, Dépend fortement des conditions d’éclairage                                                                                                                                   |

Il est possible de faire de la cartographie avec un seul type de capteur, par exemple un lidar 2D 360°, mais la fusion de plusieurs capteurs est conseillée afin de combiner les avantages et de pallier aux inconvénients.

---

## 6. Accumulation et fusion des données

La précision des données des capteurs affectent directement la précision de la carte. La **fusion de données multi-capteurs** (Lidar, ultrasons, caméra) augmente la précision et la robustesse. 
Les lidars ne voient pas les vitres, les ultrasons si... 
Les caméra de profondeur et les caméra stéréo ne voient pas à 360° mais permettent de fournir des nuages de points " plus denses" avec de la couleur ... 
Le radars peuvent "voir" à travers des obstacles... Etc ...
En les fusionnant il est possible de combiner leurs avantages.

Toutefois, les mesures doivent être **correctement alignées** entre-elles. 
Il faudra correctement repositionner les mesures effectuées dans le plan de chaque capteurs dans le plan de la carte. 

**L’accumulation de plusieurs mesures en se déplaçant** afin de changer les points de prise de mesures permet de compléter la carte. Les mesures devront là encore être correctement alignée.

**Méthodes courantes :**

- Alignement par corrélation.  
- Ajustement par ICP (Iterative Closest Point).  
- Localisation probabiliste (MCL).

Une mauvaise superposition de prises de mesure successive provoque des déformations de carte.

---

## 7. Dérive et erreur de fermeture de boucle

Afin de compléter la cartographie, le robot sera amené a se déplacer. Viendra un moment où le robot reviendra sur ses pas. C’est le phénomène de **loop closure**.
Cependant, bien souvent, au fil du déplacement du robot des petites erreurs de position s’accumulent dans les scans successifs qui ne s’alignent donc pas parfaitement.  

On dit alors que la **carte “dérive”**.

Avec ce décalage, il peut arriver que le robot croit être dans une nouvelle zone alors qu’il revient en réalité sur ses pas et qu'il revisite à nouveau un endroit déjà visité.

C’est ce qu’on appelle une **erreur de fermeture de boucle** (**loop closure error**).  

Afin de résoudre ce problème il faut pouvoir :

- Détecter une boucle et caractériser l'erreur
- Corriger la carte

### 8. Détection de boucle

Objectif : Reconnaissance d’un lieu déjà visité et cartographié.

Plusieurs méthodes possibles en fonction des capteurs
disponibles :

**Basées sur des repères** : Rapprochement de deux features identiques « proches » (ex.
détection de similarités visuelles lors de la comparaison d’images , ou détection de corrélation entre scans lidars via ICP – Iterative Closest Point).

**Basées sur la position estimée** : rapprochement des coordonnées
(odométrie, GPS, localisation etc.).  

Lorsque le robot identifie un endroit déjà visité, on parle alors de "**détection de fermeture de boucle**” **(loop closure detection**).

Une fois la boucle détectée, on peut alors **caractériser l’erreur** de la boucle
ce qui correspond à déterminer **l'écart entre la positionsupposée** à laquelle on pensait être au moment de la détection de la boucle, **et la position réelle** à laquelle on est effectivement si on réaligne nos observation actuelle par rapport à nos observations passées. 
La caractérisation de l'erreur se fait en (x, y, yaw) lorsqu'on est en cartographie 2D et en (x, y , z) (yaw pitch roll ) lorsqu'on est en cartographie 3D.

Une fois l'erreur caractérisée, il ne restera plus qu'à corriger la carte. 

### 9. Correction de la carte (Loop closure correction)

Une fois la boucle détectée, et l'erreur caractérisée il ne reste qu'à ajuster :

- La trajectoire estimée du robot.  
- Les poses successives dans la carte.  
- Les zones superposées, afin de minimiser l’erreur globale.

Le principe consiste à “déformer” la carte ou à réajuster la trajectoire  supposée du robot de manière à minimiser l’erreur globale sur l’ensemble des poses en particulier au niveau de la pose qui a permit de détecter le problème de boucle et de caractériser l'erreur, et réaligner la carte de sorte à ce que les zones que se chevauchent correspondent à nouveau.

Deux approches principales existent :

Correction géométrique directe : la carte finale est ajustée globalement pour réaligner les zones incohérentes.

Optimisation des poses : on reconstruit la carte à partir de la trajectoire corrigée du
robot, en ajustant les poses successives qui ont servi de repères lors des mises à jour de la carte. Mais cela nécessite d'avoir enregistrer les opérations successives de mise à jour de la carte et les poses estimées du robot dans la carte lors de ces mise à jour.

Le résultat ainsi obtenu est une **carte globalement cohérente**, sans discontinuités.

---

## 10. Conclusion

La cartographie constitue un pilier fondamental de la robotique mobile.  
Elle permet au robot de représenter et comprendre son environnement, condition nécessaire à toute localisation ou navigation.
Bien qu’il s’agisse d’un sujet largement étudié, il reste un domaine en constante
évolution, au cœur de nombreuses applications de notre quotidien.

Il existe différents types de représentations cartographiques et de capteurs selon
les besoins et les environnements avec chacun ayant leurs différents avantages et inconvénients.

Une cartographie fiable et cohérente repose sur :

- des capteurs adaptés et bien synchronisés afin d'acquérir les données à représenter,
- une représentation pertinente en fonction du besoin (résolution) et de nos capacité de mémoire,
- et des algorithmes capables d’intégrer, fusionner et corriger les données dans un repère commun.

Une mauvaise superposition des mesures entraîne des déformations ou incohérences
dans la carte.  

Pour corriger ces dérives, on peut détecter les boucles (loop closure) et réoptimiser la carte afin de minimiser l’erreur globale.  

Connaître précisément la position du robot dans la carte est donc indispensable pour garantir la cohérence des nouvelles mesures et éviter la dérive cumulative lors de la mise à jour continue de la carte.  

Cela conduit naturellement au problème suivant qui consiste à **localiser le robot** au sein d'une carte existante.

---

© 2026 – Jonathan Quillès – Module Cartographie et Localisation appliquée à la robotique mobile
