# RobotControl pour Processing 4

Ouvrir `RobotControl.pde` en mode Java. Adapter `ROBOT_IP`, puis lancer le sketch après connexion au réseau du robot. Voir aussi le [guide de démarrage](../../../Utiliser%20les%20outils%20du%20module.md).

- Flèches, PageUp/PageDown, glisser et molette : modifier la pose affichée.
- P : transmettre la pose ; S : lire un scan ; A : activer ou désactiver les scans automatiques (5 Hz maximum).
- I/K : avance/recul ; J/L : translation gauche/droite ; U/O : rotation. Durée demandée : 300 ms, divisée par deux pour les rotations côté robot.
- Espace : demander `/stop`. Le canal d'arrêt est distinct de l'acquisition et des commandes ordinaires. Il reste soumis au réseau et ne remplace pas une coupure matérielle.
- C : exporter `lidar_scan.csv` dans le dossier du sketch, avec point décimal indépendant de la langue du poste.
- V : importer une carte de segments `x1,y1,x2,y2` en mètres. Les commentaires `#` et lignes vides sont ignorés. Un fichier vide, une coordonnée non finie ou une ligne incorrecte annule tout l'import et conserve la carte précédente.

Les échanges HTTP s'exécutent en arrière-plan. Une seule requête de scan et une seule commande ordinaire peuvent être en cours ; une nouvelle demande ordinaire pendant une commande est ignorée. Les scans sont validés intégralement avant mise à jour de l'affichage. Les mises à jour reçues sont appliquées dans la boucle de dessin.

## Validation

Prétraitement Processing 4.4.10 et compilation Java réussis. Tests automatisés ciblés : décodage de pose signée, distance et intensité ; rejet des scans tronqués et des comptes invalides ; préservation de la carte après import incorrect ou vide ; point décimal avec une locale française.

Avant un TP, tester sur le robot : acquisition manuelle et automatique, déconnexion Wi-Fi sans gel de l'interface, mouvement court et arrêt par Espace. Vérifier aussi l'import et l'export depuis l'interface. Ces essais matériels et visuels restent à effectuer.

---

© 2026 – Jonathan Quillès – Module Cartographie et Localisation appliquée à la robotique mobile
