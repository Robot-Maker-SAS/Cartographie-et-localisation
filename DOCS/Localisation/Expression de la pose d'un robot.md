# 

# Expression de la pose d'un robot 2D et 3D

## 1. Introduction

En robotique mobile, la **pose** d’un robot correspond à sa **position** et à son **orientation** dans un repère donné.  
Selon que l’on travaille en deux ou trois dimensions, la manière de décrire cette pose varie.

---

## 2. La pose en 2D

### a) Définition

Dans un espace **2D**, la pose X du robot est généralement définie par :  
X = [x, y, θ]

$$
\mathbf{X_{2D}} =
\begin{bmatrix}
x \\
y \\
\theta \\
\end{bmatrix}
$$

où :

- **x, y** sont les coordonnées du robot dans le plan 2D,

- **θ** (theta) est l’**angle d’orientation**, c’est-à-dire la rotation du robot autour de l’axe vertical (Z).

### b) Interprétation géométrique

Le robot se déplace dans un plan horizontal (généralement le sol) et ne peut tourner que dans ce plan.  
Les coordonnées **x** et **y** représentent la position du robot dans ce plan, généralement exprimées en mètres, tandis que l’angle θ, exprimé en radians (unité SI) ou en degrés (°), indique **la direction dans laquelle le robot fait face**, par rapport à l’axe des x.  
On parle également de **lacet** (*yaw* en anglais).  
Le lacet positif correspond à une rotation antihoraire vue de dessus.

Exemples :

- θ=0° → robot orienté vers l’axe X positif (la droite)

- θ=90° → robot orienté vers le haut (axe Y positif)

- θ=180° → robot orienté vers la gauche (axe X négatif)

Ces coordonnées sont très utilisées pour les robots roulants se déplaçant uniquement dans un plan 2D.

---

## 3. La pose en 3D

### a) Définition

En **3D**, la pose doit prendre en compte la position dans l’espace ainsi que les trois angles de rotation indépendants.  
On note généralement :

X = [x, y, z, φ, θ, ψ]

$$
\mathbf{X_{3D}} =
\begin{bmatrix}
x \\
y \\
z \\
\phi \\
\theta \\
\psi
\end{bmatrix}
$$

où :

- x,y,z représentent la **position** du robot dans l’espace 3D,

- φ,θ,ψ représentent les **angles d’Euler** :
  
  - φ (phi) → **roulis (roll)** : rotation autour de l’axe X
  
  - θ (theta) → **tangage (pitch)** : rotation autour de l’axe Y
  
  - ψ (psi) → **lacet (yaw)** : rotation autour de l’axe Z

**⚠️ On note que la notation en 2D et en 3D n'utilise pas par défaut la même lettre pour représenter le lacet !**

### b) Interprétation physique

Avec ces 6 coordonnées, on peut représenter complètement la pose d’un objet en 3D. 
Les trois coordonnées **x, y, z** décrivent la position dans l’espace, tandis que les trois angles d’Euler décrivent entièrement l’**orientation** :

- **Roulis (φ)** → rotation autour de l’axe **X**, correspond à l’**inclinaison latérale** du robot (ou d’un aéronef) vers la gauche ou la droite.  
  Plage typique : φ ∈ [−180°, +180°]  
  Un roulis positif correspond à une inclinaison vers la droite.

- **Tangage (θ)** → rotation autour de l’axe **Y**, correspond à l’**inclinaison avant/arrière**.  
  Plage typique : θ ∈ [−90°, +90°]  
  Un tangage positif fait pencher l’objet vers l’avant (nez vers le bas pour un aéronef).

- **Lacet (ψ)** → rotation autour de l’axe **Z**, correspond à la **direction horizontale** ou à la **rotation sur soi-même**.  
  Plage typique : ψ ∈ [−180°, +180°]  
  Un lacet positif correspond à une rotation antihoraire vue de dessus.

Ces coordonnées sont très utilisées pour les drones, les sous-marins, les bras robotiques ou tout véhicule autonome naviguant dans un environnement 3D.

---

## 4. Différences de notation entre 2D et 3D

Le changement de lettre entre θ en 2D et ψ en 3D vient des conventions historiques utilisées pour décrire les rotations autour des trois axes.

En 2D, il n’existe qu’une seule rotation possible : le lacet (yaw) autour de l’axe Z.  
En géométrie plane, on utilise traditionnellement **θ** pour représenter un angle.  
C’est donc cette notation qui a été adoptée pour la pose 2D.

En 3D, les conventions issues de la mécanique et de l’aéronautique utilisent les **trois angles d’Euler** : φ, θ, ψ.  
Dans ce système :

- **ψ** décrit le lacet (rotation autour de Z),

- **θ** décrit le tangage (rotation autour de Y).

Ainsi :

- **θ en 2D correspond à ψ en 3D** → le lacet, rotation autour de Z,

- **θ en 3D correspond au tangage**, rotation autour de Y.

Pour tenter d’harmoniser les notations, certains utilisent en 2D :

X = [x, y, ψ]

$$
\mathbf{X_{2D}} =
\begin{bmatrix}
x \\
y \\
\psi \\
\end{bmatrix}
$$

---

### **Synthèse**

| Dimension      | Axes de rotation | Notation standard | Description                             |
| -------------- | ---------------- | ----------------- | --------------------------------------- |
| **2D (x,y)**   | 1 (autour de Z)  | θ (parfois ψ)     | Orientation dans le plan, lacet (yaw)   |
| **3D (x,y,z)** | 3 (X, Y, Z)      | φ, θ, ψ           | Angles d’Euler : roulis, tangage, lacet |

---

© 2025 – Jonathan Quillès – Module Cartographie et Localisation appliquée à la robotique mobile







# Expression de la pose d'un robot 2D et 3D

## 1. Introduction

En robotique mobile, la **pose** d’un robot correspond à définir sa **position** et à son **orientation** dans un repère donné.  
Selon que l’on travaille en deux ou trois dimensions, la manière de décrire cette pose varie.

---

## 2. La pose en 2D

### a) Définition

Dans un espace **2D**, la pose X du robot est généralement définie par :
X = [x, y, θ]

$$
\mathbf{X_{2D}} =
\begin{bmatrix}
x \\
y \\
\theta \\
\end{bmatrix}
$$

où :  

- **x, y**  sont les coordonnées du robot dans le plan 2D,  
- **θ** (theta) est l’**angle d’orientation**, c’est-à-dire la rotation du robot autour de l’axe vertical (Z).

### b) Interprétation géométrique

Le robot se déplace dans un plan horizontal (gènéralement le sol), et ne peut tourner que dans ce plan. Les coordonnées x et y reprèsentent la position du robot dans ce plan, généralement exprimé en mètres, tandis que l’angle \( θ \) exprimés en Radians (Rad Unitié SI ) ou en Degrés (°) indique **la direction dans laquelle le robot fait face**, par rapport à l’axe des x. On parle également de lacet (ou yaw en anglais). 
Le lacet positif correspond à une rotation dans le sens anti-horaire en vue de dessus.

Exemple :  

- \( θ = 0° \) → robot orienté vers l’axe X positif ( la droite).  
- \( θ = 90° \) → robot orienté vers le haut (axe Y positif).  
- \( θ = 180° \) → robot orienté vers la gauche ( axe X négatif).

Ces coordonnées sont très utilisées pour les robots roulants se déplaçant uniquement dans un plan 2D.

--- 

## 3. La pose en 3D

### a) Définition

En **3D**, la pose doit prendre en compte la position dans l’espace ainsi que les trois angles de rotation indépendants.  
On note généralement :

X = [x, y , z, φ, θ, ψ]

$$
\mathbf{X_{3D}} =
\begin{bmatrix}
x \\
y \\
z \\
\phi \\
\theta \\
\psi
\end{bmatrix}
$$

où :  

- \(x, y, z\) représentent la **position** du robot dans l’espace 3D,  
- \(φ, θ, ψ\) représentent les **angles d’Euler** :
  - φ (phi\) → **roulis (roll)** : rotation autour de l’axe X,  
  - θ (theta\) → **tangage (pitch)** : rotation autour de l’axe Y,  
  - ψ (psi\) → **lacet (yaw)** : rotation autour de l’axe Z.

**⚠️On note que la notation en 2D et en 3D n'utilise pas par défaut la même lettre pour représenté le lacet !**

### b) Interprétation physique

Avec ces 6 coordonnées on peut complètement représenter la position de notre objet en 3D. les 3 coordonnées x, y, et z représentant la position dans l'espace tandis que les trois angles d'Euler décrivent entièrement l’**orientation d’un objet dans l’espace 3D** :

- **Roulis (φ)** → rotation autour de l’axe **X**, correspond à l’**inclinaison latérale** du robot (ou d’un aéronef) vers la gauche ou la droite. 
  Plage typique :  ϕ∈[−180°,+180°]
  
  Un roulis positif correspond à une inclinaison vers la droite.

- **Tangage (θ)** → rotation autour de l’axe **Y**, correspond à l’**inclinaison avant/arrière**.
  
  Plage typique : θ∈[−90°,+90°]
  Un tangage positif fait pencher le robot vers l’avant (nez vers le bas pour un drone ou un avion).

- **Lacet (ψ)** → rotation autour de l’axe **Z**, correspond à la **direction horizontale** ou à la **rotation sur soi-même** (orientation dans le plan 2D).
  
  Plage typique : ψ∈[−180°,+180°]
  
  Un lacet positif correspond à une rotation dans le sens anti-horaire vue du dessus.

Ces coordonnées sont très utilisées pour les drones volants et sous marins, les bras robotiques ou tout véhicules autonomes naviguant dans un environnement 3D.

---

## 4. Différences de notation entre 2D et 3D

Le changement de lettre entre θ en 2D et ψ en 3D vient des conventions historiques adoptées pour décrire les rotations selon les trois axes.

**En 2D**, il n’existe qu’une seule rotation possible, le lacet (yaw) autour de l’axe Z.  
Or en mathématique, ****en géométrie plane on utilise θ**** pour représenter la rotation autour de l'axe Z . C'est pour cette raison qu'on utilise généralement par défaut la lettre θ (thêta) pour exprimer cet angle unique dans la position 2D.

 **En mécanique 3D et en aéronautique on utilise les trois angles d’Euler (φ, θ, ψ)** afin de décrire les trois rotations indépendantes permettant de décrire l'orientation 3D d'un corps. On a alors adopté cette convention pour la position 3D.

Ainsi, l'usage de ces deux conventions distinctes fait que l’angle **θ en 2D  correspond à ψ en 3D et représentent le lacet : la rotation autour de l’axe Z**, tandis que **θ en 3D représente le tangage : la rotation autour de l'axe Y**.

Pour cette raison on observe parfois la tentative d'hamonisation avec la notation 2D suivante :  X = [x, y, ψ]

$$
\mathbf{X_{2D}} =
\begin{bmatrix}
x \\
y \\
\psi \\
\end{bmatrix}
$$

**Synthèse**:

| Dimension      | Axes de rotation      | Notation standard des angles | Description                                               |
| -------------- | --------------------- | ---------------------------- | --------------------------------------------------------- |
| **2D (x, y)**  | 1 (autour de Z)       | θ  (parfois ψ)               | Orientation dans le plan, "lacet" (yaw)                   |
| **3D (x,y,z)** | 3 (autour de X, Y, Z) | φ, θ, ψ                      | Angles d'Euler, roulis, tangage, lacet (roll, pitch, yaw) |

---

© 2025 – Jonathan Quillès – Module Cartographie et Localisation appliquée à la robotique mobile
