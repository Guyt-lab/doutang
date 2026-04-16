import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/listing.dart';
import '../../services/listing_parser_service.dart';
import '../../services/listing_storage_service.dart';
import '../../services/profile_storage_service.dart';
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
  bool _isSaving = false;
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

  // ── Parsing URL ───────────────────────────────────────────────────────────

  Future<void> _parseUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _isParsing = true);

    final parsed = await ListingParserService.parseUrl(url);

    if (!mounted) return;
    setState(() {
      _isParsing = false;
      _showManual = true;
      if (parsed.title != null) _titleController.text = parsed.title!;
      if (parsed.price != null) {
        _priceController.text = parsed.price!.toInt().toString();
      }
      if (parsed.surface != null) {
        _surfaceController.text = parsed.surface!.toInt().toString();
      }
      if (parsed.address != null) _addressController.text = parsed.address!;
    });

    if (!parsed.hasAnyData && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Impossible d\'extraire les infos — complète manuellement',
          ),
          backgroundColor: DoutangTheme.textSecondary,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  // ── Sauvegarde ────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Charge le prénom du profil local, fallback 'Moi'
    final profile = await ProfileStorageService.load();
    final owner = profile?.owner ?? 'Moi';

    final listing = Listing(
      url: _urlController.text.trim().isEmpty
          ? null
          : _urlController.text.trim(),
      title: _titleController.text.trim(),
      price: _priceController.text.isEmpty
          ? null
          : double.tryParse(_priceController.text),
      surface: _surfaceController.text.isEmpty
          ? null
          : double.tryParse(_surfaceController.text),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      addedBy: owner,
    );

    await ListingStorageService.add(listing);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
              // ── Import URL ──
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(DSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import depuis Jinka',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
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
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
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
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(
                            _isParsing ? 'Extraction...' : 'Extraire les infos',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: DSpacing.md),

              // ── Bouton saisie manuelle ──
              if (!_showManual)
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _showManual = true),
                    child: const Text('Saisie manuelle sans URL'),
                  ),
                ),

              // ── Formulaire manuel ──
              if (_showManual) ...[
                Text(
                  'Informations du bien',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: DSpacing.md),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Titre *'),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: DSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Prix (€/mois ou €)',
                          suffixText: '€',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: DSpacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _surfaceController,
                        decoration: const InputDecoration(
                          labelText: 'Surface',
                          suffixText: 'm²',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DSpacing.md),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse / Quartier',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: DSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _save(),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Ajouter l\'annonce'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
