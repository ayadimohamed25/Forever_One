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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanProvider);

    ref.listen(scanProvider, (previous, next) {
      if (next.confirmed && previous?.confirmed != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document confirmed and saved')),
        );
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Document')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (pickedImage != null) Image.file(pickedImage!, height: 150, fit: BoxFit.cover),
            const SizedBox(height: 16),
            if (state.isLoading) const Center(child: CircularProgressIndicator()),
            if (state.document != null) ...[
              Text('Confidence: ${state.document!.confidence}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: state.document!.confidence >= 70
                        ? Colors.green
                        : state.document!.confidence >= 40
                        ? Colors.orange
                        : Colors.red,
                  )),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount (correct if needed)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date (correct if needed)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount <= 0) return;
                  ref.read(scanProvider.notifier).confirm(
                    id: state.document!.id,
                    amount: amount,
                    date: dateController.text.trim().isEmpty ? null : dateController.text.trim(),
                  );
                },
                child: const Text('Confirm & Save'),
              ),
              const SizedBox(height: 16),
              const Text('Raw extracted text:', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(state.document!.rawText, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}