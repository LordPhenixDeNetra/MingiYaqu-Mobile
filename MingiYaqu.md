# 📘 Cahier des charges – Application **MingiYaqu**

## 1. Présentation générale

**Nom de l’application** : MingiYaqu
**Description** : Application mobile multiplateforme (Android & iOS) développée en **Flutter**.
Elle permet de suivre les dates de péremption des produits alimentaires, d’envoyer des alertes avant leur expiration, et de réduire le gaspillage.
**Langues supportées** : Français et Anglais (sélection automatique via langue du système + option manuelle).

---

## 2. Objectifs

* Aider les utilisateurs à **gérer efficacement leurs produits alimentaires** (frigo, placard, congélateur).
* Réduire le **gaspillage alimentaire** en envoyant des alertes personnalisées avant expiration.
* Fournir une **interface simple, intuitive et moderne**, utilisable par tous.
* Offrir un système **multilingue** (FR/EN).

---

## 3. Fonctionnalités principales

### 3.1 Gestion des produits

* Ajout manuel d’un produit (nom, catégorie, date d’achat, date de péremption, quantité, photo).
* Scan de code-barres pour pré-remplir certains champs (nom du produit, infos disponibles).
* Modification et suppression des produits.
* Organisation des produits par **catégories** (frigo, placard, congélateur, autre).

### 3.2 Notifications et rappels

* Alertes **paramétrables** (ex. : 1 jour, 2 jours, 1 semaine avant la date d’expiration).
* Notifications locales (fonctionnent hors connexion).
* Annulation automatique des alertes si le produit est supprimé ou consommé.

### 3.3 Interface utilisateur

* Tableau de bord avec :

  * Produits proches de l’expiration (affichage en priorité).
  * Produits déjà périmés.
  * Produits encore valides.
* Possibilité de trier et filtrer (par date, catégorie, nom, validité).
* Affichage avec codes couleur :

  * **Vert** = valide,
  * **Orange** = bientôt périmé,
  * **Rouge** = périmé.

### 3.4 Multilingue et Multi thème 

* Application disponible en **français** et **anglais**, **Thème sombre** et **Thème clair ** 
* Détection automatique de la langue du smartphone.
* Option dans les paramètres pour changer de langue manuellement.

### 3.5 Sauvegarde et synchronisation (optionnel, version future)

* Synchronisation via **Firebase** pour sauvegarder les données.
* Connexion avec Google/Apple ID pour restaurer les produits sur un nouvel appareil.

---

## 4. Contraintes techniques

* **Technologie** : Flutter (Dart).
* **Base de données locale** : Hive ou SQLite (mode hors connexion).
* **Notifications locales** : `flutter_local_notifications` ou `awesome_notifications`.
* **Scan code-barres** : `mobile_scanner` ou `barcode_scan2`.
* **Multilingue** : `flutter_localizations` + `intl`.

---

## 5. Design & ergonomie

* Interface simple, adaptée à un usage quotidien.
* Palette de couleurs fraîches (vert, blanc, orange, rouge pour l’état des produits).
* Icônes claires pour catégories (frigo, placard, congélateur).
* Compatible **mode sombre**.

---

## 6. Sécurité & confidentialité

* Toutes les données sont **stockées en local** par défaut.
* Aucune donnée sensible partagée sans consentement.
* Option de synchronisation cloud (dans une version ultérieure).

---

## 7. Livrables attendus

1. Application mobile Flutter (Android & iOS).
2. Documentation technique (installation, déploiement, maintenance).
3. Interface multilingue (FR/EN).
4. Cahier de tests (tests unitaires + tests utilisateurs).

---

## 8. Évolutions possibles (versions futures)

* Partage de produits ou listes entre plusieurs utilisateurs (famille, colocataires).
* Reconnaissance automatique des produits via API de code-barres (OpenFoodFacts).
* Suggestions de recettes basées sur les produits proches de l’expiration.
* Widget ou notifications interactives.
