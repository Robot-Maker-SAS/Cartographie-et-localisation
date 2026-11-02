# Construction d'une carte vectorielle 2D à partir d'un scan lidar

## 1. Définir les caractéristiques de la zone à explorer

- Il faut commencer par définir **ce que l’on souhaite représenter** en fonction du **type d’environnement**.
  
  Dans la majorité des cas, en **environnement intérieur structuré (indoor)**, on cherchera à représenter les **murs, portes, meubles ou obstacles fixes** sous forme de **segments**.  
  Exemple : un mur sera défini par deux points extrémités (x₁, y₁) et (x₂, y₂).  
  Il est néanmoins possible de compléter cette représentation par des points caractéristiques (ex. coins), des cercles ou arcs de cercle (troncs d’arbres, poteaux, bornes, bidons, etc.), ou toute autre **forme libre** (courbes, contours) selon le niveau de détail souhaité.

- Pour chaque *feature* ou entité géométrique détectée, il faut définir un **modèle mathématique** permettant de la représenter et de la stocker :
  
  | Type d’entité        | Représentation typique | Description                                           |
  | -------------------- | ---------------------- | ----------------------------------------------------- |
  | Segment              | (x₁, y₁, x₂, y₂)       | Deux points d’extrémité E₁(x₁, y₁) et E₂(x₂, y₂)      |
  | Cercle               | (x_c, y_c, r)          | Centre C(x_c, y_c) et rayon r                         |
  | Arc de cercle        | (x_c, y_c, r, θ₁, θ₂)  | Centre C(x_c, y_c), rayon r, angle de début et de fin |
  | Point orienté / coin | (x, y, θ)              | Coordonnées (x, y) et orientation θ                   |
  
  La carte est alors représentée par une **liste de primitives géométriques**, appelées **features**.
  
  Pour chaque *feature*, on peut également ajouter des propriétés complémentaires comme un *timestamp* (date de dernière observation) ou un compteur de confiance.

- La carte vectorielle est ainsi représentée par une **liste de toutes les features**.  
  Elle peut être stockée en mémoire sous la forme d’un **vecteur de features** (ou d’une liste chaînée) et enregistrée dans un simple fichier texte pour l’affichage.  
  Exemple :
  
  ```
  # Carte vectorielle (segments)
  0.10,0.50,1.80,0.55
  1.80,0.55,1.85,2.80
  ...
  ```
  
  Par défaut, cette carte est vide, sauf si vous souhaitez l’initialiser avec des éléments connus (ex. murs d’une pièce).

---

## 2. Acquisition du nuage de points et prétraitement

- Le lidar renvoie des points (x, y) dans le repère du robot, initialement en **coordonnées polaires** :  Ppolaire​(r,θ)  que l’on convertit en **coordonnées cartésiennes** :  Pcartésien​(x,y)=(rcosθ,rsinθ).

- Il faut ensuite convertir les coordonnées locales du lidar en **coordonnées globales**, à l’aide de la **position et de l’orientation** du robot : Pglobal​=R(θr​)Plocal​+T(xr​,yr​)
  
  On obtient ainsi un **nuage de points 2D global**, qu’il faut ensuite **structurer** pour en extraire les formes utiles.

- Avant d’extraire les primitives géométriques, il est souvent nécessaire de **filtrer et prétraiter les données** afin de supprimer les **points aberrants** (trop lointains, intensité trop faible, incohérents).  
  Les points lidar sont parfois accompagnés d'une valeur de qualité, qui peut être utile pour du prétraitement.  
  Les points ayant une trop faible qualité ne sont pas fiables et sont supprimés du lot.  Ce prétraitement améliore fortement la robustesse de la détection des formes.

---

## 3. Extraction de primitives géométriques

L’extraction de **primitives géométriques** est une étape cruciale et souvent délicate dans la construction d’une **carte vectorielle**.  
L’objectif est de transformer le **nuage de points bruts** obtenu par le lidar en un ensemble de **formes géométriques simples et exploitables**.

On cherche à retrouver les *features* suivantes :

- **Segments** (murs, cloisons, bords de tables, etc.)

- **Cercles / arcs** (poteaux, obstacles cylindriques)

- **Points d’intérêt** (coins, intersections)

L’extraction se déroule en deux grandes étapes :

---

### 1) Segmentation (clusterisation)

L’objectif est de regrouper les points appartenant à un même objet.

- Les points **proches** (distance < seuil, typiquement quelques centimètres) sont regroupés dans un cluster.

- Une **discontinuité de distance** entre deux points successifs indique un **changement de cluster**.

- On peut aussi utiliser :
  
  - un critère **angulaire**,
  
  - un critère d’**intensité**,
  
  - un critère de **continuité**.

Chaque cluster correspond à un ensemble de points issus d’un même objet.

---

### 2) Reconnaissance géométrique

Une fois les clusters identifiés, on ajuste une **forme géométrique** sur les points :

- **Régression linéaire** (segment)

- **RANSAC** (robuste aux outliers)

- **Ajustement de cercle / arc**

- **Simplification polygonale**  
  (ex. Douglas–Peucker, `cv::approxPolyDP`)

---

## 4. Ajout et mise à jour des features dans la carte

Avant d’ajouter une nouvelle feature, il faut vérifier si des éléments similaires existent déjà dans la carte :

Comparaison basée sur :

- distance spatiale (écart entre points clés),

- similarité géométrique (orientation, longueur, rayon…).

Deux cas :

1. **Nouvelle feature** → ajout direct

2. **Feature similaire existante** →
   
   - *Remplacement* (plus fiable)
   
   - *Conservation* (ancienne plus stable)
   
   - *Fusion* (cas le plus courant)

La **fusion** permet notamment :

- d’unifier deux segments alignés,

- de fusionner deux cercles proches,

- de lisser deux points caractéristiques (moyenne pondérée).

---

## 5. Gestion des absences de détection des features

Certains obstacles peuvent disparaître ou changer (porte ouverte, meuble déplacé).

### Détection d’absence

On trace un segment entre la **position du robot** et le **point du scan**, puis on teste l’intersection avec les features existantes :

- intersection segment–segment

- intersection segment–cercle

- distance point–segment

Si une feature est **traversée**, elle est probablement absente.

### Ajustement

Selon le cas :

- **réduire** la taille d’un segment,

- **scinder** un segment en deux,

- **supprimer** la feature ou diminuer sa confiance.

---

## 6. Mise à jour continue et nettoyage

À chaque scan :

1. Alignement lidar ↔ carte vectorielle (scan matching)

2. Extraction de features

3. Mise à jour / fusion

4. Nettoyage des features obsolètes

Exemples de nettoyage :

- fusion des features redondantes,

- correction des collisions géométriques,

- suppression des features trop anciennes ou trop petites.

---

## Remarques

- Une carte vectorielle représente uniquement des **formes détectées** (pas de grille).

- Très **compacte**, très **précise**, mais plus **complexe** à maintenir qu’une carte d’occupation.

- Le choix des features dépend fortement de l’environnement.

- La qualité de la carte dépend du **lidar**, de la **stabilité du robot** et de la **robustesse des algorithmes**.

---

© 2026 – Jonathan Quillès – Module Cartographie et Localisation appliquée à la robotique mobile
