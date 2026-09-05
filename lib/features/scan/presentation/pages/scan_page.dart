import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/document_provider.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  File? pickedImage;
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  bool showRawText = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    setState(() => pickedImage = File(file.path));
    await ref.read(scanProvider.notifier).scan(pickedImage!);
    final doc = ref.read(scanProvider).document;
    if (doc != null) {
      amountController.text = doc.extractedAmount?.toStringAsFixed(2) ?? '';
      dateController.text = doc.extractedDate ?? '';
    }
  }

  Color _confidenceColor(int confidence, ThemeData theme) {
    if (confidence >= 70) return Colors.green.shade700;
    if (confidence >= 40) return Colors.orange.shade700;
    return theme.colorScheme.error;
  }

  String _confidenceLabel(int confidence) {
    if (confidence >= 70) return 'Extraction fiable';
    if (confidence >= 40) return 'Vérification conseillée';
    return 'Vérification nécessaire';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanProvider);
    final theme = Theme.of(context);

    ref.listen(scanProvider, (previous, next) {
      if (next.confirmed && previous?.confirmed != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Document validé et enregistré'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final doc = state.document;

    return Scaffold(
      appBar: AppBar(title: const Text('Scanner un document')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview / source picker
            if (pickedImage == null)
              Container(
                height: 190,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.document_scanner_outlined,
                        size: 52, color: theme.colorScheme.outline),
                    const SizedBox(height: 12),
                    const Text('Photographiez une facture',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text('Les montants seront extraits automatiquement',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  ],
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(pickedImage!, height: 190, fit: BoxFit.cover),
              ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Caméra'),
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galerie'),
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),

            if (state.isLoading) ...[
              const SizedBox(height: 32),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 14),
              Center(
                child: Text('Analyse du document en cours...',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              ),
            ],

            if (doc != null && !state.isLoading) ...[
              const SizedBox(height: 22),

              // Confidence banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _confidenceColor(doc.confidence, theme).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.analytics_outlined,
                        size: 20, color: _confidenceColor(doc.confidence, theme)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_confidenceLabel(doc.confidence),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: _confidenceColor(doc.confidence, theme),
                              )),
                          Text('Confiance de l\'extraction : ${doc.confidence} %',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: theme.colorScheme.onSurfaceVariant,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text('Vérifiez et corrigez si nécessaire',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant',
                  prefixIcon: const Icon(Icons.euro_symbol),
                  suffixText: 'DT',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (amount <= 0) return;
                    ref.read(scanProvider.notifier).confirm(
                      id: doc.id,
                      amount: amount,
                      date: dateController.text.trim().isEmpty
                          ? null
                          : dateController.text.trim(),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Valider et enregistrer',
                      style: TextStyle(fontSize: 15)),
                  style: FilledButton.styleFrom(
                    shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              InkWell(
                onTap: () => setState(() => showRawText = !showRawText),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(showRawText ? Icons.expand_less : Icons.expand_more,
                          size: 20, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text('Texte brut extrait',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                    ],
                  ),
                ),
              ),
              if (showRawText)
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 240),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      doc.rawText.isEmpty ? '(aucun texte détecté)' : doc.rawText,
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}