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
  bool _initialized = false;

  /// Non-null en mode édition.
  Listing? _editingListing;

  bool get _isEditMode => _editingListing != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Listing) {
      setState(() {
        _editingListing = arg;
        _urlController.text = arg.url ?? '';
        _titleController.text = arg.title;
        if (arg.price != null) {
          _priceController.text = arg.price!.toInt().toString();
        }
        if (arg.surface != null) {
          _surfaceController.text = arg.surface!.toInt().toString();
        }
        _addressController.text = arg.address ?? '';
        _showManual = true;
      });
    }
  }

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

    final url = _urlController.text.trim().isEmpty
        ? null
        : _urlController.text.trim();

    // Détection de doublons (mode ajout uniquement, et seulement si URL fournie)
    if (!_isEditMode && url != null) {
      final existing = await ListingStorageService.load();
      Listing? dupe;
      for (final l in existing) {
        if (l.url == url) {
          dupe = l;
          break;
        }
      }
      if (dupe != null && mounted) {
        final choice = await showDialog<_DupeChoice>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cette annonce existe déjà'),
            content: Text(dupe!.title),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, _DupeChoice.viewExisting),
                child: const Text('Voir l\'existante'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, _DupeChoice.addAnyway),
                child: const Text('Ajouter quand même'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, _DupeChoice.cancel),
                child: const Text('Annuler'),
              ),
            ],
          ),
        );
        if (!mounted) return;
        if (choice == null || choice == _DupeChoice.cancel) return;
        if (choice == _DupeChoice.viewExisting) {
          Navigator.pop(context);
          return;
        }
        // _DupeChoice.addAnyway → continue
      }
    }

    setState(() => _isSaving = true);

    final profile = await ProfileStorageService.load();
    final owner = _editingListing?.addedBy ?? profile?.owner ?? 'Moi';

    final listing = Listing(
      id: _editingListing?.id,
      url: url,
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
      addedAt: _editingListing?.addedAt,
      status: _editingListing?.status,
      notes: _editingListing?.notes,
      rooms: _editingListing?.rooms,
      facts: _editingListing?.facts,
    );

    if (_isEditMode) {
      await ListingStorageService.update(listing);
    } else {
      await ListingStorageService.add(listing);
    }

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
        title: Text(_isEditMode ? 'Modifier l\'annonce' : 'Ajouter une annonce'),
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
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEditMode
                            ? 'Modifier'
                            : 'Ajouter l\'annonce'),
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

enum _DupeChoice { viewExisting, addAnyway, cancel }
