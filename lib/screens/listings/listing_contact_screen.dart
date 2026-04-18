import 'package:flutter/material.dart';

import '../../models/listing.dart';
import '../../models/listing_contact.dart';
import '../../services/listing_storage_service.dart';
import '../../services/project_service.dart';
import '../../theme/doutang_theme.dart';

/// Écran d'édition des coordonnées du contact d'une annonce.
///
/// Reçoit un [Listing] via [settings.arguments].
class ListingContactScreen extends StatefulWidget {
  final Listing listing;

  const ListingContactScreen({super.key, required this.listing});

  @override
  State<ListingContactScreen> createState() => _ListingContactScreenState();
}

class _ListingContactScreenState extends State<ListingContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _isAgency;
  late final TextEditingController _agencyNameController;
  late final TextEditingController _contactNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.listing.contact;
    _isAgency = c?.isAgency ?? false;
    _agencyNameController = TextEditingController(text: c?.agencyName ?? '');
    _contactNameController = TextEditingController(text: c?.contactName ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
  }

  @override
  void dispose() {
    _agencyNameController.dispose();
    _contactNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final contact = ListingContact(
      isAgency: _isAgency,
      agencyName: _isAgency && _agencyNameController.text.trim().isNotEmpty
          ? _agencyNameController.text.trim()
          : null,
      contactName: _contactNameController.text.trim().isEmpty
          ? null
          : _contactNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
    );

    final updated = widget.listing.copyWith(contact: contact);
    final projectId = await ProjectService.getActiveId() ?? '';
    await ListingStorageService.update(updated, projectId: projectId);

    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context, updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: DSpacing.sm),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enregistrer'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(DSpacing.md),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type de contact',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: DSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Particulier'),
                            icon: Icon(Icons.person_outline),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('Agence'),
                            icon: Icon(Icons.business_outlined),
                          ),
                        ],
                        selected: {_isAgency},
                        onSelectionChanged: (s) =>
                            setState(() => _isAgency = s.first),
                      ),
                    ),
                    if (_isAgency) ...[
                      const SizedBox(height: DSpacing.md),
                      TextFormField(
                        controller: _agencyNameController,
                        decoration: const InputDecoration(
                          labelText: "Nom de l'agence",
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ],
                    const SizedBox(height: DSpacing.md),
                    TextFormField(
                      controller: _contactNameController,
                      decoration: InputDecoration(
                        labelText: _isAgency
                            ? "Nom du négociateur"
                            : "Nom du propriétaire",
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DSpacing.md),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: DSpacing.md),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v != null && v.isNotEmpty && !v.contains('@')) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
