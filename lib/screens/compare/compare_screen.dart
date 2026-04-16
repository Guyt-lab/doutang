import 'package:flutter/material.dart';
import '../../widgets/empty_state.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comparer')),
      body: const EmptyState(
        icon: Icons.compare_arrows,
        title: 'Rien à comparer',
        subtitle: 'Visite au moins 2 biens\npour les comparer ici',
      ),
    );
  }
}
