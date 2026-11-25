import 'package:shared_preferences/shared_preferences.dart';

/// Seule classe qui connaît `shared_preferences`.
/// Pour utiliser sqflite ou Hive, il suffit de réécrire ce fichier
/// avec les mêmes méthodes : l'interface (pages, widgets) ne change pas.
class StockageService {
  static const String _cleTaches = 'taches';

  /// Lit la liste enregistrée (liste vide si rien n'a encore été sauvegardé).
  Future<List<String>> chargerTaches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_cleTaches) ?? [];
  }

  /// Enregistre la liste complète dans la mémoire locale.
  Future<void> sauvegarderTaches(List<String> taches) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_cleTaches, taches);
  }
}