# **Scan matching : Méthode de localisation en 2D avec Lidar**

## 1. Introduction

Le **scan matching** (ou **alignement de scans**) est une méthode de **localisation** consistant à **ajuster la position et l’orientation** du robot de manière à ce que les **mesures LIDAR actuelles** s’alignent au mieux avec un **élément de référence** : carte ou scan précédent.

L’objectif est de déterminer la **transformation rigide** (x, y, θ) qui superpose au mieux deux ensembles : le **scan mesuré** et la **référence**.

---

## 2. Principe général

Considérons :

- un **scan courant**, ensemble de points mesurés par le LIDAR ;

- une **carte ou un nuage de référence** ;

- une **estimation initiale** de la pose du robot associée au scan : (x₀, y₀, θ₀).

Le scan matching vise à trouver la transformation rigide T (translation + rotation) qui **minimise une fonction de distance** entre le scan et la référence.

Formellement :

$$
T^* = \arg\min_T \sum_i d\bigl(T \cdot p_i, \mathcal{M}\bigr)
$$

où :

- pi​ sont les points du scan ;

- M est le Monde de référence (grid map, carte vectorielle ou nuage de point de référence)

- d désigne une mesure de distance (point-vers-carte, point-vers-point, etc.).

---

## 3. Étapes principales

Quel que soit le type de carte, le scan matching suit généralement les étapes suivantes :

###### 1. Transformation

Appliquer la transformation candidate (x, y, θ) au scan courant afin d’exprimer l’ensemble des points dans le repère « monde ».

### 2. Corrélation / correspondances

Associer chaque point du scan transformé à un élément pertinent de la référence, par exemple :

- projection dans une **grid map**,

- recherche du **plus proche voisin**,

- recherche de **primitives géométriques**,

- extraction et appariement de **features**.

Cette étape est souvent précédée d’un prétraitement des données : filtrage des outliers, réduction de bruit, sous-échantillonnage, etc.

### 3. Évaluation du score

Mesurer la qualité de l’alignement proposé (distance, similarité, corrélation, probabilité).  
Le score doit permettre une **comparaison objective** entre plusieurs transformations afin d’identifier la meilleure.

### 4. Optimisation et convergence

Rechercher la transformation qui **maximise le score** (ou minimise l’erreur), généralement autour de la pose initiale, éventuellement avec des méthodes stochastiques.  
On répète le processus jusqu’à atteindre la **convergence** (variation du score ou de la pose inférieure à un seuil) ou jusqu’à atteindre un **nombre maximal d’itérations**.

---

## 4. Scan Matching sur **Grid Map**

L’objectif est de rechercher la transformation (x, y, θ) qui **maximise la corrélation** entre les points du scan LIDAR et les **cellules occupées** de la carte.

### Corrélation

Projection des points du scan transformés dans la **carte d’occupation**.

### Score

Selon la carte, son remplissage et sa résolution, le score peut être basé sur :

- le nombre de points tombant dans des cellules occupées ;

- la somme des probabilités d’occupation ;

- la distance aux cellules occupées les plus proches.

- 

### Avantages

- Simple à mettre en œuvre ;

- Utilisable directement avec une carte d’occupation.

### Inconvénients

- Dépend fortement de la **résolution de la grille** ;

- Coûteux pour les grandes cartes ;

- Risque de **minima locaux** si l’estimation initiale est insuffisante.

---

## 5. Scan Matching sur **Carte Vectorielle**

Il s’agit de trouver la transformation minimisant la **distance entre les points du scan et les primitives géométriques** (segments, arcs, points caractéristiques) de la carte vectorielle.

### Corrélation

Pour chaque point du scan : recherche de la **feature la plus proche** dans la carte vectorielle.

### Score

$$
E(x, y, θ) = \sum_i w_i \, d(p_i', \text{feature la plus proche})^2
$$

Coût global d’alignement, calculé comme la somme des distances pondérées entre chaque point transformé du scan et la feature la plus proche dans la carte vectorielle.

### Avantages

- Très précis dans les environnements structurés ;

- Indépendant d’une résolution de grille ;

- Adapté aux cartes légères et segmentées.

### Inconvénients

- Nécessite une **détection fiable** des primitives ;

- Sensible aux mauvaises correspondances ;

- Optimisation plus complexe que sur une grille.

---

## 6. Scan Matching sur **Nuage de Points**

Le but est d’aligner au mieux deux nuages de points : le scan courant et le nuage de référence.

La référence peut être convertie en :

- **carte d’occupation**,

- **carte vectorielle**,

- ou utilisée telle quelle (point-à-point).

### Corrélation

Correspondances point-à-point via le **plus proche voisin**.

### Score

$$
E(x, y, θ) = \sum_i w_i \, \| T(x, y, θ) \cdot p_i - q_i \|^2
$$

Coût total du scan matching, obtenu en sommant les distances pondérées entre chaque point du scan transformé et son point correspondant dans la référence.

### Avantages

- Fonctionne sans carte explicite ;

- Flexible et adapté à de nombreux environnements ;

- Très précis avec des scans denses et une bonne initialisation ;

- Indépendant de la résolution de grille.

### Inconvénients

- Forte dépendance à l’estimation initiale ;

- Recherche de correspondances coûteuse ;

- Drift en pur scan-to-scan ;

- Ambiguïtés dans les environnements pauvres en géométrie.

---

## 7. Feature-to-Feature Matching

Au lieu d’utiliser tous les points du scan, on extrait des **features** :

- coins,

- segments,

- lignes dominantes,

- points caractéristiques.

Après extraction dans le scan et la référence, on réalise l’appariement.

### Corrélation

Association selon :

- proximité géométrique ;

- orientation, longueur, formes similaires.

### Score

$$
E(x, y, θ) = \sum_i w_i \, \| T(x, y, θ) \cdot f_{scan,i} - f_{ref,i} \|^2

$$

Coût d’alignement entre les features extraites du scan et celles de la référence, obtenu en sommant les distances pondérées entre chaque feature transformée et sa correspondante.

### Avantages

- Très rapide (peu de données) ;

- Parfaitement adapté aux cartes vectorielles ;

- Robuste dans les environnements structurés ;

- Calcul géométrique direct possible (pas toujours besoin d’itérations).

### Inconvénients

- Extraction de features difficile selon les environnements ;

- Nécessite aussi des features dans la référence ;

- Moins efficace dans les environnements naturels et non structurés ;

- Ambiguïtés dans les géométries répétitives.

---

# 8. Méthodes d’optimisation et convergence

Le scan matching repose sur une **optimisation non linéaire** cherchant la pose (x, y, θ) minimisant un coût géométrique.

Facteurs clés pour la convergence :

- estimation initiale pas trop  mauvaise ;

- filtrage des scans (downsampling, retrait des outliers) ;

- eviter les correspondances ambiguës pouvant entrainer les convergences vers des minimum locaux.

---

## 8.1 Méthode “Brute Force”

### Fonctionnement

1. Définir une fenêtre autour de (x₀, y₀, θ₀).

2. Discrétiser (ex : 1 cm, 0,5°).

3. Tester le score de chaque pose.

4. Choisir la meilleure.

### Avantages

- Code très simple ;

- Robuste même en cas de mauvaise initialisation.

### Inconvénients

- Coût computationnel élevé ;

- Précision limitée par la résolution d’échantillonnage.

---

## 8.2 Méthode **Multi-Résolution**

### Fonctionnement

1. Downsampling des scans ou cartes.

2. Recherche brute ou gradient à basse résolution.

3. Raffinement progressif à haute résolution.

### Avantages

- Très efficace ;

- Réduit les itérations ;

- Grande robustesse.

---

## 8.3 Méthodes basées sur le **gradient**

Inclut :

- Descente de gradient,

- Gauss–Newton,

- Levenberg–Marquardt.

### Principe

1. Calcul ou approximation du gradient.

2. Mise à jour de (x, y, θ).

3. Répétition jusqu’à convergence.

### Avantages

- Convergence rapide ;

- Très utilisé en ICP.

### Inconvénients

- Risque de minimum local ;

- Nécessité d’une bonne initialisation.

---

## 8.4 Méthodes probabilistes

### Principe

Les méthodes probabilistes modélisent la pose du robot comme une variable aléatoire et explorent un ensemble d’hypothèses de pose plutôt qu’une seule solution déterministe. Chaque hypothèse est évaluée à partir d’un score (ou d’une vraisemblance) lié à la qualité de l’alignement scan–référence, puis les poses les plus probables sont privilégiées, tout en conservant une part d’aléatoire pour éviter les minima locaux.

Exemples

- Recuit simulé ;

- Filtre de particules ;

- RANSAC géométrique.

### Avantages

- Robustes au bruit et aux ambiguïtés ;

- Moins sensibles aux minima locaux.

### Inconvénients

- Coût plus élevé ;

- Paramétrage complexe.

---

## 8.5 Moments géométriques et vecteurs résultants

### Principe

Utiliser directement les **moments géométriques** des correspondances pour estimer la transformation.

### Fonctionnement

1. Chercher les correspondances (nearest neighbor ou features).

2. Calculer :
   
   - un **vecteur résultant** des déplacements point → voisin ;
   
   - les **moments moyens** (barycentre, inertie).

3. En déduire une **approximation** directe de la transformation.

4. Optionnellement : utiliser comme initialisation.

### Avantages

- Très rapide ;

- Donne une excellente initialisation.

### Inconvénients

- Moins précis ;

- Sensible aux outliers.

---

## 9. Remarques finales

- Le scan matching est un outil fondamental de la localisation 2D.

- La performance dépend fortement :
  
  - de la géométrie de l’environnement,
  
  - de la qualité des scans (densité, bruit),
  
  - des correspondances trouvées.

- Le choix de la méthode dépend du compromis **précision / robustesse / coût**.

- Le prétraitement est crucial : downsampling, outliers, features.

- Plusieurs méthodes peuvent être **fusionnées** car une méthode performe rarement dans toutes les conditions.

- Souvent combiné à des méthodes probabilistes (EKF, MCL).

---

© 2025 – Jonathan Quillès – Module *Cartographie et Localisation appliquée à la robotique mobile
