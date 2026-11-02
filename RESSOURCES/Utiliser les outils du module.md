# Utiliser les outils du module

## Choisir son parcours

- Sans robot : ouvrir `Tools/MapTool/MapTool.html` dans un navigateur. Dessiner les murs, déplacer le robot, puis exporter une carte ou un scan.
- Python : depuis la racine du dépôt, créer un environnement avec `python -m venv .venv`, installer avec `.venv/Scripts/python -m pip install -r RESSOURCES/Tools/MapTool/maptoolPython/requirements.txt`, puis lancer `.venv/Scripts/python RESSOURCES/Tools/MapTool/maptoolPython/maptool.py`.
- Processing : utiliser Processing 4 en mode Java et ouvrir `Tools/MapTool/maptoolProcessing/maptoolProcessing.pde`. Pour RobotControl, ouvrir `Tools/RobotControl/RobotControl/RobotControl.pde`. I/K : avant/arrière ; J/L : translation ; U/O : rotation ; Espace : arrêt. Les flèches modifient seulement la pose affichée. Les mouvements durent 300 ms (rotations 150 ms côté robot). Les échanges réseau sont exécutés en arrière-plan, avec délais et validation des scans ; acquisition automatique à 5 Hz maximum.
- Avec robot : suivre les étapes ci-dessous, puis ouvrir `Tools/RobotControl/RobotControl.html`.

Les chemins des outils ci-dessus sont relatifs à `RESSOURCES/`.

## Dépendances et versions

| Élément | Référence | Statut |
| --- | --- | --- |
| Python | 3.10 ou supérieur | Cible proposée ; syntaxe vérifiée avec l'interpréteur disponible |
| Pygame | 2.x (`>=2.0,<3.0`) | Dépendance déclarée dans requirements.txt ; interface à tester localement |
| Processing | 4.x, mode Java | Cible proposée ; compilation non effectuée |
| Arduino IDE | 2.x | Environnement proposé |
| ESP32 | Paquet `esp32 by Espressif Systems` | Version à relever sur le poste utilisé ; compilation à valider |
| LD06 | 1.0.0, archive `LD06/Librairie/LD06.zip` | Version issue de library.properties ; métadonnée architectures=avr malgré les exemples ESP32 |
| MecanumCar_v2 | Archive `MecanumCarV2/Libraries/MecanumCar_v2.zip` | Archive fournie sans manifeste de version |
| AsyncTCP et ESPAsyncWebServer | Bibliothèques du projet ESP32Async | Installer les deux depuis le même projet ; noter leurs versions avec celle du cœur ESP32 |

Aucune combinaison Arduino/ESP32 n'est certifiée par cette vérification. Pour rendre un poste reproductible, conserver dans le compte rendu les versions exactes du cœur ESP32, des deux bibliothèques réseau et le modèle de carte. Pour Python, enregistrer les versions effectivement utilisées avec `python -m pip freeze` dans l'environnement du projet.

## Mise en route du robot

1. Suivre [l'installation Arduino](Programmer%20un%20ESP32%20avec%20l'IDE%20Arduino.md) et le [câblage Mecanum](MecanumCarV2/README.md). Vérifier masse commune et alimentation. Brancher TX du Lidar sur GPIO33 et son entrée PWM sur GPIO32. La bibliothèque initialise GPIO32 à HIGH ; aucun PWM périodique n'est généré par défaut.
2. Installer les archives LD06 et MecanumCar_v2 par le menu Arduino « Ajouter la bibliothèque .ZIP ». Installer aussi AsyncTCP et ESPAsyncWebServer pour RobotControl.
3. Sélectionner « ESP32 Dev Module » pour l’ESP32-WROOM-32 du projet et le bon port USB. Compiler puis téléverser `Tools/RobotControl/ESP32RobotControl/ESP32RobotControl.ino`.
4. Ouvrir le moniteur série à 115200 bauds. Le Lidar utilise séparément 230400 bauds.
5. Connecter le PC au réseau `RobotESP32`, mot de passe de démonstration `12345678`. L'adresse est affichée sur le moniteur série, généralement `http://192.168.4.1`. Adapter `ROBOT_IP` dans le client si nécessaire.
6. Ouvrir RobotControl HTML. Tester d'abord un scan manuel, puis l'acquisition automatique. Si le navigateur bloque l'accès réseau local, autoriser cet accès pour la page dans ses paramètres de site.
7. Robot soulevé, tester un mouvement court et le bouton « ARRÊT IMMÉDIAT », puis vérifier l'arrêt automatique. Les durées sont bornées à 2000 ms côté robot ; les rotations utilisent la moitié de la durée demandée.

Un scan indisponible donne HTTP 503. Attendre le premier tour complet et vérifier la liaison série avant de relancer. Le client HTML refuse les réponses tronquées et limite chaque requête de scan à trois secondes, sans requêtes simultanées.

## Formats et conventions

Les outils utilisent une pose `(x, y, theta)` : position en mètres dans les interfaces et CSV, angle en degrés, axe X vers la droite et Y vers le haut. Les angles positifs sont antihoraires, zéro vers +X. L'affichage écran inverse l'axe Y. Le décodeur LD06 convertit le sens physique du capteur ; le montage et son éventuelle inversion doivent être vérifiés avec un obstacle de position connue.

- Scan MapTool : CSV `angle_deg,r_m,x_rel_m,y_rel_m`. Distance en mètres ; `r_m=0` indique l'absence d'impact et ne représente pas un obstacle à l'origine.
- Scan RobotControl : CSV `angle_deg,distance_m,intensity`. `distance_m` a la même unité que `r_m` ; renommer la colonne ou adapter le lecteur avant de mélanger les exports. La pose figure dans une ligne de commentaire commençant par `#`.
- Carte vectorielle : une ligne `x1,y1,x2,y2` par segment, coordonnées en mètres, commentaires `#` ignorés.
- Grille MapTool : matrice CSV, `1=occupé`, `0=libre`. Les lignes sont exportées du haut vers le bas. Ce format de scène simulée ne distingue pas les cellules inconnues d'une carte issue de mesures.

### Échange binaire RobotControl

La réponse `/scan` est en little-endian, de taille exacte `8 + 5*N` octets, avec `1 <= N <= 460`.

| Offset | Type | Valeur |
| --- | --- | --- |
| 0 | int16 | x en millimètres |
| 2 | int16 | y en millimètres |
| 4 | uint16 | orientation en centièmes de degré |
| 6 | uint16 | N, nombre de points |
| 8 + 5*i | uint16 | angle local du point en centièmes de degré |
| 10 + 5*i | uint16 | distance en millimètres |
| 12 + 5*i | uint8 | intensité |

Les positions transmises sont limitées à [-32768, 32767] mm, l'orientation est ramenée dans [0, 36000[. La pose est renseignée par l'utilisateur via `/pose` ; elle ne constitue pas une localisation calculée. Le serveur publie le dernier scan complet et ajoute la pose lors de la réponse. Le format ne contient pas d'horodatage : éviter les déplacements pendant les acquisitions destinées aux premiers TP.

## Vérification avant un TP

Comparer un export MapTool et un scan réel sur un obstacle simple, vérifier unités et orientation, puis tester les mouvements courts et l'arrêt. Archiver les versions utilisées avec les résultats. La validation matérielle et la compilation Arduino restent nécessaires sur le poste équipé.

---

© 2026 – Jonathan Quillès – Module Cartographie et Localisation appliquée à la robotique mobile
