import 'package:material_ui/material_ui.dart';

import '../services/stockage_service.dart';
import '../widgets/tache_tile.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final StockageService _stockage = StockageService();
  final TextEditingController _controller = TextEditingController();

  List<String> _taches = []; // données en mémoire vive (RAM)

  @override
  void initState() {
    super.initState();
    _charger();
  }

  // LECTURE : récupère les données enregistrées au démarrage
  Future<void> _charger() async {
    final taches = await _stockage.chargerTaches();
    setState(() => _taches = taches);
  }

  // Ajout : on modifie la liste en mémoire, puis on sauvegarde
  void _ajouter() {
    final texte = _controller.text.trim();
    if (texte.isEmpty) return;
    setState(() => _taches.add(texte));
    _controller.clear();
    _stockage.sauvegarderTaches(_taches);
  }

  // Suppression : même principe
  void _supprimer(int index) {
    setState(() => _taches.removeAt(index));
    _stockage.sauvegarderTaches(_taches);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes tâches')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nouvelle tâche',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _ajouter(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _ajouter,
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _taches.isEmpty
                ? const Center(child: Text('Aucune tâche pour le moment'))
                : ListView.builder(
                    itemCount: _taches.length,
                    itemBuilder: (context, i) => TacheTile(
                      texte: _taches[i],
                      onSupprimer: () => _supprimer(i),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}