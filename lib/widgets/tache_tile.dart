import 'package:flutter/material.dart';

/// Une ligne de la liste : le texte de la tâche et un bouton supprimer.
class TacheTile extends StatelessWidget {
  final String texte;
  final VoidCallback onSupprimer;

  const TacheTile({
    super.key,
    required this.texte,
    required this.onSupprimer,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.check_circle_outline),
      title: Text(texte),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        tooltip: 'Supprimer',
        onPressed: onSupprimer,
      ),
    );
  }
}