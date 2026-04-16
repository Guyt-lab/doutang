import 'package:flutter/material.dart';

class DesiderataScreen extends StatelessWidget {
  const DesiderataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes désidératas')),
      body: const Center(
        child: Text('Formulaire désidératas — Sprint 1 · #003'),
      ),
    );
  }
}
