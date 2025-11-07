# Consignes de TP

Maintenant à vous de jouer pour exploiter les données du lidar LD06 et vous lancer dans l'aventure de la cartographie et du mapping. Le travail à faire est individuel, mais vous pouvez discuter et échanger avec vos collègues.  
Ce module a pour objectif de vous amener à **comprendre, traiter et exploiter les données issues du lidar LD06**, afin de développer progressivement des outils de **cartographie** et de **localisation** pour un robot mobile.

Sur votre ordinateur, vous êtes libres de choisir votre environnement de développement :  
Python, C++ avec Qt, Processing (Java), tableur Excel, ou même une application Web (HTML/CSS/JS).  
Le choix dépend de vos compétences et de vos préférences. C’est à vous de choisir vos outils pour mener à bien vos objectifs.

Dans les grandes lignes, vous devrez :

- Afficher les données du lidar sous forme de **nuages de points**

- Utiliser les mesures pour construire une **carte d’occupation (grid map)**

- Transformer les nuages de points en **segments** pour produire une **carte vectorielle**

- Mettre en œuvre un algorithme de **localisation** à partir d’un scan lidar sur :
  
  - une carte d’occupation
  
  - une carte vectorielle
  
  - un scan de référence

- Atteindre l'objectif final : **cartographier la salle de classe** et être capable de **localiser le robot** dans cette carte.

---

# TP – Jour 1 : Extraction, Visualisation et Cartographie

### 1. Extraction des données lidar

- Consultez le dossier *Ressources* dédié au LD06.

- Apprenez à récupérer les données brutes du lidar.

- Chaque étudiant doit **extraire ses propres jeux de scans réels** dans la salle (coordonnées polaires). Ces données seront réutilisées pour la suite.

### 2. Visualisation des nuages de points

- Développez un outil permettant d’afficher vos scans sous forme de **points cartésiens**. L’outil doit permettre d’afficher plusieurs scans simultanément.

- Les différents scans doivent apparaître dans **des couleurs distinctes**.

- Vous devez pouvoir **modifier la pose d’origine** de chaque scan indépendamment pour les déplacer manuellement sur la carte.

### 3. Construction d’une grid map 2D

- Créez un outil qui transforme plusieurs *(scan + pose)* en **carte d’occupation**.

- Suivez les étapes décrites dans le document *« Construction d’une grid map 2D à partir d’un scan lidar »* et expliquez clairement votre démarche (choix techniques, hypothèses, difficultés, limites) à chaque étape.

### 4. Extraction de segments

- Développez un outil ou des outils capables de transformer un nuage de points en **un ensemble de segments**.

### 5. Construction d’une carte vectorielle

- Utilisez (ou intégrez) l’outil de segmentation pour construire une **carte vectorielle**.

- Expliquez, comme pour la grid map, les étapes suivies d’après le document *« Construction d’une carte vectorielle 2D à partir d’un scan Lidar »*.

- Vous êtes libres :
  
  - d’intégrer cette étape dans l’outil du point 3,
  
  - ou d’en créer un distinct.

Vous êtes encouragés à ajouter des propriétés supplémentaires à vos cartes : durée de vie des cellules, filtrages, pondérations, etc.  
**Commencez simple, complexifiez progressivement.**

---

# TP – Jour 2 : Localisation (Scan Matching)

### 1. Localisation sur grid map

Mettez en œuvre un ou plusieurs algorithmes de localisation fonctionnant sur une **carte d’occupation**.

### 2. Localisation sur carte vectorielle

Mettez en œuvre un ou plusieurs algorithmes de localisation fonctionnant sur une **carte vectorielle**.

### 3. Localisation entre scans

Implémentez un algorithme permettant de **localiser un scan par rapport à un scan de référence**.

Vous devrez ensuite comparer vos algorithmes selon :

- rapidité

- efficacité

- précision

Vous pouvez vous appuyer sur les articles scientifiques fournis dans le dossier *Papers*, et partager également vos autres sources.

---

# TP – Jour 3 : Intégration SLAM & Cartographie de la salle

- Finalisez les travaux des jours 1 et 2.

- Combinez vos outils pour obtenir un système capable de **localisation + cartographie simultanées** (début de SLAM).

- Utilisez vos outils pour produire une **carte complète de la salle de classe**.

### Bonus

Si vous réussissez, essayez de **déplacer le robot automatiquement** pour construire la carte en temps réel.

---

# Remarques complémentaires

- Vous pourrez (et devrez) tester vos outils afin de vérifier vos résultats. Pour cela, vous pouvez utiliser :
  
  - des données réelles récupérées via le lidar LD06,
  
  - des données artificielles générées avec **mapTool** (dans le dossier *Tools*).

- De nombreuses ressources sont disponibles : documentation, exemples, bibliothèques, compléments de cours... N’hésitez pas à consulter les dossiers :
  
  - `/DOCS`
  
  - `/RESSOURCES`

- Le robot utilise un **ESP32**, un microcontrôleur doté du Wi-Fi.  
  Vous pourrez donc transmettre les données **sans fil** vers votre ordinateur. L’outil *RobotControl* dans le dossier *Tools* peut vous aider à piloter le robot sans fil et à extraire les données du lidar en temps réel.

- **⚠️ Commits réguliers exigés** :  
  au moins **un commit toutes les 1h30** de TP, contenant par exemple :
  
  - ce qui a été réalisé
  
  - les choix effectués
  
  - les difficultés rencontrées
  
  - l’état d’avancement
  
  - ce qu’il reste à faire

- Votre **dernier commit** du projet devra contenir une conclusion personnelle :  
  ce que vous avez appris, ce que vous avez apprécié ou non, et ce que vous amélioreriez si vous le pouviez.

---

# Vidéo d’inspiration

[Vigirobotics SLAM Solution executed on a PIC 32 Bits Arduino-like MCU – YouTube](https://www.youtube.com/watch?v=Pq5y7eDiReU)

---

© 2025 – Jonathan Quillès  
**Module : Cartographie et Localisation appliquée à la robotique mobile**
