import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../providers/ai_provider.dart';
import '../../../../shared/widgets/app_page_header.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final questionController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(aiProvider.notifier).loadHistory());
  }

  @override
  void dispose() {
    questionController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _send(String question) {
    if (question.trim().isEmpty) return;
    final locale = Localizations.localeOf(context).languageCode;
    ref.read(aiProvider.notifier).ask(question.trim(), locale: locale);
    questionController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final suggestions = [
      l10n.suggestStockRupture,
      l10n.suggestCustomerDebts,
      l10n.suggestActivitySummary,
    ];

    ref.listen(aiProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.error!), backgroundColor: AppColors.danger),
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
      backgroundColor: AppColors.surfaceAlt,
      drawer: const AppDrawer(currentRoute: '/ai'),
      appBar: AppPageHeader(
        title: l10n.aiCopilot,
        subtitle: l10n.aiAssistant,
        icon: Icons.smart_toy_rounded,
        color: AppColors.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty && !state.isLoading
                ? Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        shape: BoxShape.circle,
                        boxShadow:
                        AppColors.softShadow(AppColors.primary),
                      ),
                      child: const Icon(Icons.smart_toy_outlined,
                          size: 42, color: Colors.white),
                    ),
                    const SizedBox(height: 22),
                    Text(l10n.askYourBusiness,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(l10n.askQuestionSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 28),
                    ...suggestions.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border:
                          Border.all(color: AppColors.border),
                          boxShadow: AppColors.cardShadow,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _send(s),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  const Icon(Icons.auto_awesome,
                                      size: 16,
                                      color: AppColors.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(s,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight:
                                            FontWeight.w500,
                                            color: AppColors
                                                .textPrimary)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            )
                : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final m = state.messages[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth:
                          MediaQuery.of(context).size.width * 0.78,
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 11),
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(5),
                          ),
                          boxShadow:
                          AppColors.softShadow(AppColors.primary),
                        ),
                        child: Text(m.question,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                height: 1.35)),
                      ),
                    ),
                    // Answer
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          margin: const EdgeInsets.only(top: 2, right: 9),
                          decoration: BoxDecoration(
                            gradient: AppColors.tintGradient(
                                AppColors.primary),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.smart_toy,
                              size: 15, color: AppColors.primary),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(18),
                                bottomLeft: Radius.circular(18),
                                bottomRight: Radius.circular(18),
                              ),
                              border: Border.all(color: AppColors.border),
                              boxShadow: AppColors.cardShadow,
                            ),
                            child: MarkdownBody(
                              data: m.answer,
                              styleSheet:
                              MarkdownStyleSheet.fromTheme(theme)
                                  .copyWith(
                                p: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1.5,
                                    color: AppColors.textPrimary),
                                listBullet: const TextStyle(
                                    fontSize: 13.5,
                                    height: 1.5,
                                    color: AppColors.textPrimary),
                                strong: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: AppColors.textPrimary),
                                code: const TextStyle(
                                    fontSize: 12,
                                    backgroundColor:
                                    AppColors.surfaceAlt),
                                h1: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800),
                                h2: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800),
                                h3: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          if (state.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.analyzingData,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.textSecondary)),
                ],
              ),
            ),

          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: suggestions
                  .map((s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  avatar: const Icon(Icons.auto_awesome,
                      size: 14, color: AppColors.primary),
                  label:
                  Text(s, style: const TextStyle(fontSize: 11.5)),
                  onPressed: state.isLoading ? null : () => _send(s),
                ),
              ))
                  .toList(),
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: questionController,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: l10n.askYourQuestion,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    gradient: state.isLoading ? null : AppColors.brandGradient,
                    color: state.isLoading ? AppColors.border : null,
                    shape: BoxShape.circle,
                    boxShadow: state.isLoading
                        ? null
                        : AppColors.softShadow(AppColors.primary),
                  ),
                  child: IconButton(
                    onPressed: state.isLoading
                        ? null
                        : () => _send(questionController.text),
                    icon: const Icon(Icons.arrow_upward,
                        color: Colors.white, size: 20),
                    padding: const EdgeInsets.all(13),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}