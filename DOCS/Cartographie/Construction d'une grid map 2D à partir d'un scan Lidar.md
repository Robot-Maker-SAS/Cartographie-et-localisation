# Construction d'une **grid map** 2D à partir d'un **scan LIDAR**

## 1. Définir la grille couvrant la zone à explorer

- Il faut choisir la **taille de la carte** (en mètres) et la **résolution** (taille d’une cellule), ce qui détermine le nombre de cellules représentant la zone réelle à explorer.
  
  Exemple : une carte de 2 m × 3 m avec une résolution de 0,1 m correspond à une matrice de 20 × 30 cellules.

- Définir les **propriétés des cellules** qui permettront de stocker l’état d’occupation du sol et la façon dont elles seront enregistrées.  
  Cela peut être :
  
  - **binaire** : 0 = libre, 1 = occupé,
  
  - **probabiliste** : une valeur entre 0 (libre certain) et 255 (occupé certain),
  
  - une **structure plus complexe**, contenant par exemple un *timestamp* (date de dernière observation), un compteur de confiance (ex. nombre de points lidar d’impact), ou une propriété d’importance (ex. murs connus au départ), d’intérêt ou de caractérisation (ex. coins de murs).

- Vous pouvez alors déclarer une structure en mémoire représentant votre carte.

- Au démarrage, il faut également choisir un **état initial de la carte** :
  
  - tout libre (vision optimiste),
  
  - tout occupé (vision pessimiste),
  
  - ou tout inconnu (valeur neutre, par exemple 127 pour une carte probabiliste).

- Exemple :
  
  `bool gridMap[20][30] = {0}; // Le type de carte le plus simple : case occupée ou non ; par défaut tout est libre.`

---

## 2. Convertir les points LIDAR en coordonnées de la grille

- Le LIDAR renvoie des points (x, y) dans le repère du robot en **coordonnées polaires** :  
  Ppolaire​(r,θ),  
  que l’on convertit en **coordonnées cartésiennes** :  
  Pcarteˊsien​(x,y)=(rcosθ,rsinθ).

- Il faut convertir ces coordonnées locales du LIDAR en **coordonnées globales**, à l’aide de la **position et de l’orientation** du robot :
  
  Pglobal​=R(θr​)Plocal​+T(xr​,yr​)
  
  On obtient ainsi un **nuage de points 2D global**, qu’il faut ensuite **positionner dans la grille**.

- Pour cela, il faut convertir ces coordonnées en **indices** (i, j) de la grille :
  
  i=resolutionx​,j=resolutiony​

- Avant de mettre à jour la grille, il est souvent nécessaire de **filtrer et prétraiter les données** pour supprimer les **points aberrants** (trop lointains, intensité trop faible, incohérents).  
  Les points lidar sont parfois accompagnés d’une valeur de qualité, utile pour du prétraitement.  
  Les points ayant une trop faible qualité ne sont pas fiables et doivent être **supprimés du lot**.  
  Ce prétraitement limite l’apparition de **faux positifs**.

---

## 3. **Mettre à jour les cellules traversées par le faisceau**

- Toutes les cellules traversées **avant** le point d’impact sont **libres**, puisque le faisceau n’a rencontré aucun obstacle.

- Pour les repérer, on trace un **segment** entre la position du robot et le point d’impact, et on identifie toutes les cellules traversées par ce segment (à l’exception de la cellule d’impact).  
  Cela peut se faire :
  
  - avec un **algorithme de tracé de ligne** (ex. **Bresenham**),
  
  - ou en **échantillonnant** régulièrement le segment (diviser le segment en N points équidistants et identifier la cellule correspondante pour chacun).

- Les cellules ainsi identifiées peuvent alors être mises à jour, soit par **marquage direct** comme libres (0), soit par **décrément de la probabilité d’occupation**.

---

## 4. **Marquer la cellule d’impact comme occupée**

- La cellule où le faisceau s’arrête (= point de mesure LIDAR) correspond à un obstacle : elle doit donc être marquée comme **occupée**.  
  Chaque point indique la présence probable d’un obstacle fixe (mur, meuble, etc.) ou mobile (personne, porte en mouvement, autre robot…).

- Le marquage de la cellule peut se faire :
  
  - par **affectation directe** (binaire, tout ou rien),
  
  - par **augmentation de la probabilité d’occupation**,
  
  - ou par **mise à jour d’un timestamp** indiquant la dernière détection,
  
  - ou encore via un **compteur de confiance**.

---

## 5. **Mise à jour continue et nettoyage de la carte**

- Pour chaque nouveau scan, le LIDAR est **aligné** avec la carte existante (scan matching), et on répète les étapes 2, 3 et 4 afin de mettre à jour la carte au fil du temps.

- Des opérations d’identification de **cellules d’intérêt** (cellules isolées mais très probables, segments, coins — intersection de lignes) peuvent être réalisées afin :
  
  - d’ajouter du sens à la carte,
  
  - de la rendre plus visuelle,
  
  - et de faciliter le scan matching.

- Des opérations de **nettoyage** ou de **filtrage** peuvent être appliquées régulièrement.  
  Par exemple :
  
  - **Décroissance temporelle** : on réduit la probabilité d’occupation des cellules non observées depuis longtemps. On parcourt toutes les cellules et on diminue progressivement leur probabilité, jusqu’à marquer comme libres celles dont la probabilité devient trop faible.
  
  - **Effacement des obstacles obsolètes** : une cellule occupée qui n’a pas été détectée depuis longtemps peut repasser à l’état libre.
  
  - **Lissage spatial** : on filtre les artefacts isolés pour réduire le bruit. On remplace alors la valeur d’une cellule par une **valeur moyenne ou majoritaire** de ses voisines dans un certain rayon.

---

## Remarques

- La **grid map** est une **représentation discrète** de l’environnement.

- Le choix de la définition de la grille repose sur un **compromis** entre :
  
  - **précision**,
  
  - **mémoire**,
  
  - **robustesse**.

- Il peut être utile d’ajouter des **propriétés aux cellules** pour faciliter le nettoyage et ajuster l’affichage (ex. couleur liée à la probabilité), mais cela **augmente la mémoire utilisée**.

- Le choix de la résolution, du modèle de mise à jour et du filtrage dépend du **type de robot**, de la **vitesse de déplacement**, de la **qualité du LIDAR**, et de la **précision souhaitée**.

- En pratique, les cartes sont souvent stockées sous forme de **matrices de `uint8_t`** pour représenter les probabilités sans consommer trop de mémoire — en particulier pour des intégrations sur microcontrôleurs.

---

© 2025 – Jonathan Quillès – Module *Cartographie et Localisation appliquée à la robotique mobile*
