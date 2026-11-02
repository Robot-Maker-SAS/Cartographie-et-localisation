# Acquisition des données issues du Lidar LD06

## 1. Présentation générale

Le **LD06** est un **lidar 2D à balayage 360°**, compact et économique, adapté aux applications pédagogiques et aux petits robots mobiles.  
Il permet de mesurer les distances autour du robot sur un plan horizontal et de produire une **représentation circulaire de l’environnement**.

Ce type de capteur repose sur le principe de la **télémétrie laser** : une diode émet un faisceau lumineux, le capteur mesure le temps nécessaire pour que le signal réfléchi revienne, ce qui permet de calculer la distance entre le lidar et l’objet détecté.

---

## 2. Principe d’un lidar 2D 360°

Un lidar 2D à balayage complet mesure des distances dans un plan en effectuant une **rotation continue du capteur**.  
Ainsi, il collecte un ensemble de points correspondant aux obstacles situés autour de lui sur une coupe horizontale.

Les données sont généralement exprimées dans un **repère polaire** centré sur le capteur, chaque point étant défini par sa distance `r` et son angle `θ` :

Ppolaire​=(r,θ)

où :

- `r` = distance mesurée entre le lidar et l’objet,

- `θ` = angle de mesure par rapport à une référence (souvent l’axe avant du capteur) exprimé dans le sens anti horaire.

Pour l’exploitation ou la visualisation, on convertit ces coordonnées polaires en **coordonnées cartésiennes** dans le repère du lidar :

x=r⋅cos(θ)

y=r⋅sin(θ)​

 Pcartésien​=(x,y)

où :

- `x` = distance sur l'axe X dans le repère du lidar,

- `y` = distance sur l'axe Y dans le repère du lidar.

Pour l’exploitation ou la visualisation, on convertit ces coordonnées polaires en

Ces coordonnées permettent de représenter graphiquement un **nuage de points** décrivant les objets environnants.

---

## 3. Caractéristiques techniques du Lidar LD06

En lisant la documentation technique du lidar on peut en extraire les caractéristiques suivantes :

| **Paramètre**              | **Valeur typique**                                 |
| -------------------------- | -------------------------------------------------- |
| Portée maximale            | ≈ 12 m                                             |
| Résolution angulaire       | 0,5° à 1°                                          |
| Fréquence de rotation      | 10 à 15 Hz                                         |
| Taux de mesure             | ≈ 4500 points/s                                    |
| Interface de communication | UART (230400 bauds)                                |
| Alimentation               | 5 V                                                |
| Données par trame          | 12 points (distance + intensité)                   |
| Sens de rotation du lidar  | ⚠️Sens Horaire (**inverse du sens mathématique!**) |

 **Importance du sens de rotation du lidar :  dans le sens horaire (CW – ClockWise)** lorsqu’on **regarde le capteur du dessus** (du côté du capot transparent où l’on voit le faisceau tourner) le faisceau tourne **dans le sens des aiguilles d’une montre**.

L’angle fournit par le lidat augmente également **dans le sens horaire**, c’est-à-dire **dans le sens de rotation du laser**. Ce qui est l'inverse de la représentation polaire : 

Lorsque qu'on va convertir les coordonnées polaires en coordonnées cartésiennes 

il faudra absolument tenir compte de ce**sens de rotation horaire**, qui est **inverse du repère trigonométrique standard** (où les angles croissent dans le sens antihoraire).

Pour corriger cela dans le repère mathématique classique, on pourra simplement inverser le signe de l’angle :

θmath​=−θLD06​
On pourra aussi écrire
θmath = 360° − θLD06​

si on veut garder θmath entre 0 et 360°.

Cela garantira que le nuage de points s’affichera avec le bon sens (droite/gauche respectés) lorsqu'on applique les transformation trigonométrique standard.

---

## 4. Structure d’une trame de données

En lisant le protocole de communication du lidar on peut en déduire les informations suivantes :

**Le capteur LD06 envoie en continu des trames binaires** (paquets de données) contenant les mesures issues du balayage laser.  
Chaque trame regroupe **12 points successifs** correspondant à un petit segment de rotation du capteur.

La structure d’une trame est fixe et normalisée :

`[Header][Version & Taille][Vitesse][Angle début][12 × (Distance, Intensité)][Angle fin][Temps][Checksum]`

### Détail du contenu :

| Champ                          | Taille (octets) | Description                                                                                                                                                                                                 |
| ------------------------------ | --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Header**                     | 1               | Octet de synchronisation valant `0x54`. Il marque le début d’une nouvelle trame.                                                                                                                            |
| **Version & Taille**           | 1               | Vaut `0x2C` pour le format LD06 utilisé : version et nombre de mesures (12 points). La trame complète fait 47 octets.                                                       |
| **Speed**                      | 2               | Vitesse de rotation du moteur du Lidar, en degrés par seconde. Permet d’estimer la fréquence de balayage.                                                                                       |
| **Angle début**                | 2               | Angle du premier point du paquet, exprimé en centièmes de degré (0–35999 → 0–359,99°).                                                                                                                      |
| **12 × (Distance, Intensité)** | 36              | Ensemble de 12 mesures successives :<br>• **Distance** (2 octets, uint16) : distance mesurée en millimètres (0 à 12 000).<br>• **Intensité** (1 octet, uint8) : niveau de réflexion du signal reçu (0–255). |
| **Angle fin**                  | 2               | Angle du dernier point du paquet, exprimé en centièmes de degré. Sert à calculer le pas angulaire entre les points.                                                                                         |
| **Temps**                      | 2               | Horodatage relatif (timestamp) interne au Lidar, utilisé pour la synchronisation temporelle entre trames.                                                                                                   |
| **Checksum**                   | 1               | Somme de contrôle (CRC8) calculée sur tous les octets précédents pour vérifier l’intégrité de la trame.                                                                                                     |

---

### Remarques importantes

- **La trame LD06 utilisée par la bibliothèque fournie contient exactement 47 octets**, CRC8 inclus, sans octet de fin supplémentaire.

- Les **angles** sont exprimés en centièmes de degrés, ce qui permet une précision d’environ 0,01°.

- Les **distances** sont exprimées en millimètres ; leur fiabilité dépend de la réflectivité de la surface et de l’angle d’incidence.

- Le **checksum** suit un calcul de type **CRC8** avec la table de correspondance spécifique au LD06.

- La bibliothèque fournie attend le couple `0x54 0x2C`. Un autre protocole nécessite un décodeur adapté ; ne pas accepter un format inconnu sans validation.

---

### Exemple de trame brute (en hexadécimal)

`54 2C 60 09 5A 15  D0 07 25 D0 07 2B D1 07 2F D2 07 30 D1 07 2F D1 07 2E D0 07 2B D0 07 28 D0 07 25 D1 07 60 15 3E 00 9A`

Dans cet exemple :

- `0x54` → Header

- `0x2C` → Version & Taille

- `0x0960` → Vitesse (environ 2400 deg/s)

- `0x155A` → Angle de début = 5466 → 54,66°

- `12 × (distance, intensité)` → 12 mesures consécutives

- `0x1560` → Angle de fin = 5472 → 54,72°

- `0x003E` → Timestamp

- `0x9A` → Checksum CRC8

---

## 5. Reconstruction des angles de mesure d'une trame

Une trame du LD06 ne fournit pas directement les 12 angles individuels des points mesurés.  
Seuls les **angles de début et de fin** sont transmis, et les angles intermédiaires doivent être **interpolés**.

On calcule d’abord la plage angulaire des 12 mesures : 

θTotal =(Angle fin−Angle début+360) % 360

Le terme `( + 360 ) % 360` permet de corriger les cas où l’angle de fin est inférieur à l’angle de début (passage de 359° à 0°).

On obtient ainsi toujour  θTotal compris entre 0 et 360° . 

​On peut ensuite calculer l’écart angulaire moyen entre deux points :

Δθ=  θTotal / 12    =   ( (Angle fin−Angle début+360) % 360​ ) / 12

Ensuite, pour chaque point n (avec n∈[0,11]), on calcule son angle interpolé :

θn​= 360 - (Angle deˊbut+(n+0.5)⋅Δθ) % 360 
⚠️ Le signele "360 -"" est présent car l'angle du LD06 est donné en sens horaire et que les coordonnées polaires doivent être exprimées en sens anti horaire !  

On obtient ainsi les 12 couples (rn​,θn​) qui représentent les points détectés pendant cette portion de rotation du lidar  

Pn​=(rn​,θn​)

---

## 6. Accumulation des trame pour reconstruction d'un scan et Conversion des données

Une fois qu'on est capable d'extraire les angles et distances d'une trame, on peut convertir les coordonnées polaires en coordonnées cartésiennes pour affichage ou traitement :

xn​=rn​⋅cos(θn​)

yn​=rn​⋅sin(θn​)​

De plus on peut accumuler plusieurs trames consécutives afin de compléter un scan 360°. 
⚠️ Il faut détecter le passage de 360° à 0° afin de repérer "un nouveau scan"
et ce passage peut se faire en plein milieu d'un trame.

Un fois le scan complet récupéré on obtient notre " nuage de points " en coordonnées cartésienne qui représente l'ensemble des obstacles "vu" par notre lidar. 

En connaissant la pose du robot ( position et angle) vous pourrez alors positionner ces points dans la carte du robot. 

Ces points peuvent ensuite être :

- visualisés sous forme de **nuage de points**,

- accumulés dans une **carte d’occupation**,

- transformé en feature pour être stocké dans une carte vectorielle;

- utilisés pour des algorithmes de **détection d’obstacles** ou de **localisation** (scan matching).

---

## 7. Intégration avec un microcontrôleur (ESP32)

Le LD06 communique via un port **UART** à 230400 bauds.  
Une simple liaison série (TX/RX) permet de récupérer les trames binaires sur un microcontrôleur, tel qu’un **ESP32**.
Dans ce projet, le Lidar LD06 est relié à un ESP32-WROOM-32 configuré comme « ESP32 Dev Module » : TX du Lidar vers GPIO33 (RX de Serial2), entrée PWM du Lidar vers GPIO32 et masse commune.

Le microcontrôleur peut :

- **Décoder les trames** reçues en analysant le header et le checksum,

- **Reconstituer les 12 points** de chaque trame,

- **Accumuler les points pour reformer un scan 360°**

- **Transmettre les coordonnées** (r, θ) ou (x, y) à un ordinateur via une connexion série, Wi-Fi ou Bluetooth.

Fort heureusement pour vous une âme charitable a réalisé une librairie https://github.com/Robot-Maker-SAS/LD06  permettant le décodage de trames du LD06, ainsi que l'accumulation des points et la conversion en coordonnées cartésienne et la conversion dans la carte du robot... 
Il vous suffit de l'installer et de lancer le code d'exemple ESP32_LD06_Test.ino fourni. 
Vous êtes néanmoins fortement invité à lire le code de la librairie afin de retrouver comment ont été réalisé les différents points évoqué précédément. 

Le code d'exemple envoie des données sur le moniteur série avec un baudrate de 115200. Par défaut les données sont au format " teleplot" et vous pourrez donc facilement les lire dans le moniteur série, mais aussi les afficher sur https://teleplot.fr .

---


### Conventions et câblage de référence

Le champ vitesse est en degrés par seconde : `0x0960 = 2400 °/s`, soit environ `6,67 tours/s`. Seuls les champs angles utilisent des centièmes de degré. Ces unités correspondent à `LD06/src/ld06.h` dans l'archive fournie.

La formule d'interpolation ci-dessus décrit la convention de la bibliothèque fournie (pas divisé par 12 et décalage d'un demi-pas). Elle ne doit pas être confondue avec une interpolation passant exactement par les deux angles extrêmes. Pour comparer des décodeurs, conserver la même convention et vérifier sur un scan de référence.

Les exemples configurent l'entrée PWM du Lidar sur GPIO32, initialisée à l'état haut par la bibliothèque ; la génération d'un PWM périodique reste optionnelle. GPIO34 est une entrée uniquement sur l'ESP32 classique. Voir le [guide matériel Mecanum](../MecanumCarV2/README.md) pour le connecteur TX/PWM sur GPIO33/GPIO32.

---

© 2026 – Jonathan Quillès – Module Cartographie et Localisation appliquée à la robotique mobile
