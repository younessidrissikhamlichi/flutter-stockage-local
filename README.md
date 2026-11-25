# Flutter – Stockage local des données avec `shared_preferences`

Application Flutter minimaliste (liste de tâches) qui illustre **comment enregistrer des données dans la mémoire locale de l'appareil** afin qu'elles soient conservées après la fermeture de l'application.

 **Démo en ligne** : https://younessidrissikhamlichi.github.io/flutter-stockage-local/

---

## Objectifs pédagogiques

- Comprendre la différence entre **mémoire vive (RAM)** et **stockage persistant**
- Utiliser le package `shared_preferences` pour lire, écrire et supprimer des données
- Connaître les **alternatives** de stockage local dans Flutter et savoir choisir
- **Déployer** une application Flutter Web sur GitHub Pages avec GitHub Actions

---

## Fonctionnalités de l'application

- Ajouter une tâche
- Supprimer une tâche
- Les tâches sont **rechargées automatiquement** au prochain lancement

---

## Lancer le projet en local

### Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version stable)
- Un éditeur : VS Code ou Android Studio

### Installation

```bash
git clone https://github.com/younessidrissikhamlichi/flutter-stockage-local.git
cd flutter-stockage-local
flutter pub get
flutter run            # choisir un appareil (Android, iOS, Chrome...)
```

> Si vous partez de zéro :
> ```bash
> flutter create flutter_stockage_local
> cd flutter_stockage_local
> flutter pub add shared_preferences
> ```
> puis remplacez le contenu de `lib/main.dart` par celui de ce dépôt.

---

## Comprendre `shared_preferences`

`shared_preferences` est un stockage **clé-valeur** persistant. Chaque donnée est enregistrée sous une clé (un nom) et retrouvée grâce à cette clé.

### Mécanisme utilisé selon la plateforme

| Plateforme | Mécanisme natif |
|---|---|
| Android | `SharedPreferences` |
| iOS / macOS | `NSUserDefaults` |
| Web | `localStorage` du navigateur |
| Windows / Linux | fichier local |

### Types de données acceptés

`int`, `double`, `bool`, `String` et `List<String>`.

### Opérations de base

```dart
final prefs = await SharedPreferences.getInstance();

// Écrire
await prefs.setString('nom', 'Youness');
await prefs.setBool('modeSombre', true);
await prefs.setStringList('taches', ['Tâche 1', 'Tâche 2']);

// Lire (retourne null si la clé n'existe pas)
final nom = prefs.getString('nom');
final taches = prefs.getStringList('taches') ?? [];

// Supprimer
await prefs.remove('nom');

// Tout effacer
await prefs.clear();
```

### Comment l'application l'utilise

```dart
// Au démarrage : on charge les données enregistrées
@override
void initState() {
  super.initState();
  _charger();
}

Future<void> _charger() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() => _taches = prefs.getStringList('taches') ?? []);
}

// À chaque modification : on enregistre la liste
Future<void> _sauvegarder() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('taches', _taches);
}
```

Le cycle est toujours le même : **charger au démarrage → modifier en mémoire → sauvegarder**.

### Quand l'utiliser ?

- Préférences utilisateur (thème, langue)
- Petits indicateurs (onboarding déjà vu, dernier onglet ouvert)
- Petites listes de texte

### Limites

- Pas adapté aux **grandes quantités de données**
- Pas de **requêtes** (filtrage, tri, jointures)
- Données **non chiffrées** : ne jamais y stocker de mot de passe
- Sur le Web, les données sont liées au **navigateur et au domaine** (elles ne sont pas partagées entre appareils)

---

## Les autres méthodes de stockage

| Méthode | Type | Quand l'utiliser |
|---|---|---|
| **shared_preferences** | Clé-valeur simple | Préférences, petits flags |
| **Fichiers** (`path_provider` + `dart:io`) | Fichier brut (JSON, texte, images) | Export, cache, documents |
| **sqflite** | SQLite (SQL) | Données relationnelles, requêtes SQL |
| **Drift** | SQLite avec API Dart typée | Comme sqflite, avec plus de sécurité de typage |
| **Hive / Hive CE** | NoSQL clé-valeur rapide | Objets Dart, bonnes performances sans SQL |
| **Isar / ObjectBox** | NoSQL orienté objets | Grosses collections, requêtes rapides |
| **flutter_secure_storage** | Stockage chiffré (Keychain / Keystore) | Mots de passe, tokens, clés API |
| **Cloud** (Firebase, Supabase) | Base distante | Synchronisation multi-appareils, multi-utilisateurs |

### Guide de choix rapide

- Quelques valeurs simples → `shared_preferences`
- Donnée sensible → `flutter_secure_storage`
- Données structurées avec relations → `sqflite` ou `Drift`
- Objets Dart sans SQL → `Hive` ou `Isar`
- Données partagées entre utilisateurs ou appareils → solution cloud

---

## Héberger l'application sur GitHub Pages

L'application est déployée automatiquement en version **web** grâce à **GitHub Actions** à chaque `push` sur la branche `main`.

### Étape 1 – Activer GitHub Pages

1. Ouvrir le dépôt sur GitHub → **Settings** → **Pages**
2. Dans **Build and deployment** → **Source**, choisir **GitHub Actions**

### Étape 2 – Ajouter le workflow

Le fichier se trouve dans `.github/workflows/deploy.yml` :

```yaml
name: Déploiement Flutter Web sur GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Récupérer le code
        uses: actions/checkout@v4

      - name: Installer Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Installer les dépendances
        run: flutter pub get

      - name: Construire la version web
        run: flutter build web --release --base-href "/${{ github.event.repository.name }}/"

      - name: Préparer l'artefact Pages
        uses: actions/upload-pages-artifact@v3
        with:
          path: build/web

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Déployer sur GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### Étape 3 – Publier

```bash
git add .
git commit -m "Déploiement GitHub Pages"
git push origin main
```

Suivez l'avancement dans l'onglet **Actions**. Une fois terminé, l'application est disponible à l'adresse :

```
https://younessidrissikhamlichi.github.io/flutter-stockage-local/
```

### Point important : `--base-href`

GitHub Pages sert le site dans un sous-dossier (`/NOM-DU-DEPOT/`). L'option `--base-href` est donc **indispensable**, sinon la page reste blanche. Dans le workflow, elle reprend automatiquement le nom du dépôt.

### Alternative : déploiement manuel

```bash
flutter build web --release --base-href "/NOM-DU-DEPOT/"
```

Le résultat se trouve dans `build/web/`. Il peut être publié sur la branche `gh-pages` ou sur n'importe quel hébergeur statique.

---

## Structure du projet

```
flutter-stockage-local/
├── .github/
│   └── workflows/
│       └── deploy.yml      # Déploiement automatique
├── lib/
│   └── main.dart           # Application + stockage shared_preferences
├── pubspec.yaml            # Dépendances
└── README.md
```

---

## Pistes d'amélioration (exercices)

1. Ajouter une **case à cocher** pour marquer une tâche comme terminée
2. Stocker des **objets** (titre, date, statut) en les convertissant en JSON avec `jsonEncode` / `jsonDecode`
3. Ajouter un **mode sombre** mémorisé avec `setBool`
4. Remplacer `shared_preferences` par **sqflite** ou **Hive** et comparer
5. Synchroniser les tâches avec **Firebase Firestore**

---

## Ressources

- [Documentation `shared_preferences`](https://pub.dev/packages/shared_preferences)
- [Persistance des données dans Flutter](https://docs.flutter.dev/cookbook/persistence)
- [Déployer une app Flutter Web](https://docs.flutter.dev/deployment/web)
- [Documentation GitHub Pages](https://docs.github.com/pages)

---

## Licence

Projet à but pédagogique, libre d'utilisation.
Pr. Youness IDRISSI KHAMLICHI