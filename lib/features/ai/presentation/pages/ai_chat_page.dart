import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final questionController = TextEditingController();
  final scrollController = ScrollController();

  final suggestions = [
    'Quels produits risquent une rupture ?',
    'Quels clients me doivent de l\'argent ?',
    'Fais-moi un résumé de mon activité',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(aiProvider.notifier).loadHistory());
  }

  void _send(String question) {
    if (question.trim().isEmpty) return;
    ref.read(aiProvider.notifier).ask(question.trim());
    questionController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiProvider);

    ref.listen(aiProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
      if (next.messages.length > (previous?.messages.length ?? 0)) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('AI Copilot')),
      body: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty && !state.isLoading
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.smart_toy_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Posez une question sur votre activité',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    ...suggestions.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton(
                        onPressed: () => _send(s),
                        child: Text(s, textAlign: TextAlign.center),
                      ),
                    )),
                  ],
                ),
              ),
            )
                : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final m = state.messages[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8, left: 40),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(m.question),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16, right: 40),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: MarkdownBody(data: m.answer),
                    ),
                  ],
                );
              },
            ),
          ),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Analyse en cours...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: suggestions
                  .map((s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  onPressed: state.isLoading ? null : () => _send(s),
                ),
              ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: questionController,
                    decoration: const InputDecoration(
                      hintText: 'Posez votre question...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: state.isLoading ? null : () => _send(questionController.text),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}