import 'package:flutter/material.dart';
import '../../theme/doutang_theme.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _surfaceController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isParsing = false;
  bool _showManual = false;

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _surfaceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _parseUrl() async {
    if (_urlController.text.isEmpty) return;
    setState(() => _isParsing = true);

    // TODO: Implémenter le parsing réel
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isParsing = false;
      _showManual = true;
      // Valeurs mockées — seront remplacées par le parser
      _titleController.text = 'Appart 2P Paris 11 — extrait de Jinka';
      _priceController.text = '1350';
      _surfaceController.text = '48';
      _addressController.text = 'Paris 11ème';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une annonce'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Import URL
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(DSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Import depuis Jinka',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: DSpacing.sm),
                      Text(
                        'Copie l\'URL d\'une annonce Jinka et colle-la ici',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: DSpacing.md),
                      TextFormField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          hintText: 'https://jinka.fr/annonce/...',
                          prefixIcon: Icon(Icons.link),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: DSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isParsing ? null : _parseUrl,
                          icon: _isParsing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(
                              _isParsing ? 'Extraction...' : 'Extraire les infos'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: DSpacing.md),

              // Bouton saisie manuelle
              if (!_showManual)
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _showManual = true),
                    child: const Text('Saisie manuelle sans URL'),
                  ),
                ),

              // Formulaire manuel (visible après parsing ou manuel)
              if (_showManual) ...[
                Text('Informations du bien',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: DSpacing.md),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Titre *'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: DSpacing.md),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                          labelText: 'Prix (€/mois ou €)',
                          suffixText: '€'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: DSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _surfaceController,
                      decoration: const InputDecoration(
                          labelText: 'Surface', suffixText: 'm²'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ]),
                const SizedBox(height: DSpacing.md),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse / Quartier',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: DSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Ajouter l\'annonce'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: Sauvegarder via le state management
    Navigator.pop(context);
  }
}
