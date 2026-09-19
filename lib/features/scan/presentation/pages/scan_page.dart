import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../providers/document_provider.dart';
import '../../../../shared/widgets/app_page_header.dart';

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

  @override
  void dispose() {
    amountController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    setState(() => pickedImage = File(file.path));
    await ref.read(scanProvider.notifier).scan(pickedImage!);
    final doc = ref.read(scanProvider).document;
    if (doc != null) {
      amountController.text = doc.extractedAmount?.toStringAsFixed(3) ?? '';
      dateController.text = doc.extractedDate ?? '';
    }
  }

  Color _confidenceColor(int confidence) {
    if (confidence >= 70) return AppColors.success;
    if (confidence >= 40) return AppColors.warning;
    return AppColors.danger;
  }

  String _confidenceLabel(int confidence, AppLocalizations l10n) {
    if (confidence >= 70) return l10n.extractionReliable;
    if (confidence >= 40) return l10n.verificationAdvised;
    return l10n.verificationRequired;
  }

  Widget _sourceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: AppColors.tintGradient(color),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 7),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(scanProvider, (previous, next) {
      if (next.confirmed && previous?.confirmed != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 19),
                const SizedBox(width: 10),
                Text(l10n.documentValidated),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.error!), backgroundColor: AppColors.danger),
        );
      }
    });

    final doc = state.document;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      drawer: const AppDrawer(currentRoute: '/scan'),
      appBar: AppPageHeader(
        title: l10n.scanDocument,
        icon: Icons.document_scanner_rounded,
        color: AppColors.info,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pickedImage == null)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      gradient: AppColors.tintGradient(AppColors.primary),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.document_scanner_outlined,
                        size: 34, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.photographInvoice,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(l10n.amountsExtractedAutomatically,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(pickedImage!, height: 200, fit: BoxFit.cover),
            ),

          const SizedBox(height: 14),

          Row(
            children: [
              _sourceButton(
                icon: Icons.camera_alt_outlined,
                label: l10n.camera,
                color: AppColors.primary,
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 12),
              _sourceButton(
                icon: Icons.photo_library_outlined,
                label: l10n.gallery,
                color: AppColors.stock,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),

          if (state.isLoading) ...[
            const SizedBox(height: 36),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 14),
            Center(
              child: Text(l10n.analyzingDocument,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            ),
          ],

          if (doc != null && !state.isLoading) ...[
            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppColors.tintGradient(_confidenceColor(doc.confidence)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _confidenceColor(doc.confidence)
                        .withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _confidenceColor(doc.confidence),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.analytics_outlined,
                        size: 17, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_confidenceLabel(doc.confidence, l10n),
                            style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: _confidenceColor(doc.confidence))),
                        const SizedBox(height: 1),
                        Text(l10n.extractionConfidence(doc.confidence),
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            Text(l10n.checkAndCorrect,
                style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.amount,
                      prefixIcon: const Icon(Icons.payments_outlined),
                      suffixText: 'DT',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: l10n.date,
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              height: 52,
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
                label: Text(l10n.validateAndSave,
                    style: const TextStyle(fontSize: 15)),
              ),
            ),

            const SizedBox(height: 18),
            InkWell(
              onTap: () => setState(() => showRawText = !showRawText),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(showRawText ? Icons.expand_less : Icons.expand_more,
                        size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(l10n.rawExtractedText,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            if (showRawText)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 240),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    doc.rawText.isEmpty ? l10n.noTextDetected : doc.rawText,
                    style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: AppColors.textSecondary),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}