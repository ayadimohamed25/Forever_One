import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown/markdown.dart' as md;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../providers/ai_provider.dart';

/// Status tags the model used to echo, e.g. [ALERTE RUPTURE] or
/// [OUT OF STOCK]. Uppercase only, and never followed by "(", so markdown
/// links like [text](url) are left alone.
class _StatusTagSyntax extends md.InlineSyntax {
  _StatusTagSyntax()
      : super(r"\[([A-ZÀ-ÖØ-Þ][A-ZÀ-ÖØ-Þ0-9 _'\-]{1,40})\](?!\()");

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('statustag', match[1]!));
    return true;
  }
}

/// Draws a status tag as a danger pill instead of raw bracketed text.
class _StatusTagBuilder extends MarkdownElementBuilder {
  final String Function(String raw) labelFor;

  _StatusTagBuilder(this.labelFor);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: AppBadge(
        label: labelFor(element.textContent),
        tone: BadgeTone.danger,
      ),
    );
  }
}

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
    // The assistant answers in the language currently selected in the app.
    final locale = Localizations.localeOf(context).languageCode;
    ref.read(aiProvider.notifier).ask(question.trim(), locale: locale);
    questionController.clear();
    FocusScope.of(context).unfocus();
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _tagLabel(String raw, AppLocalizations l10n) {
    final t = raw.toUpperCase();
    if (t.contains('RUPTURE') || t.contains('OUT OF STOCK')) {
      return l10n.rupture;
    }
    return raw;
  }

  MarkdownStyleSheet _markdownStyle(BuildContext context) {
    final base = AppTheme.font(size: 15, height: 1.5);
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: base,
      listBullet: base,
      strong: AppTheme.font(size: 15, weight: FontWeight.w700, height: 1.5),
      em: base.copyWith(fontStyle: FontStyle.italic),
      h1: AppTheme.font(size: 18, weight: FontWeight.w700),
      h2: AppTheme.font(size: 17, weight: FontWeight.w700),
      h3: AppTheme.font(size: 16, weight: FontWeight.w600),
      tableHead: AppTheme.font(size: 13, weight: FontWeight.w600),
      tableBody: AppTheme.font(size: 13),
      code: AppTheme.font(size: 13).copyWith(backgroundColor: AppColors.fill),
      blockSpacing: 10,
      listIndent: 22,
    );
  }

  Widget _userBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(6),
          ),
        ),
        child: Text(
          text,
          style: AppTheme.font(size: 15, height: 1.4, color: Colors.white),
        ),
      ),
    );
  }

  Widget _assistantBubble(AiMessageEntity m, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(
            color: AppColors.accentSoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome_outlined,
              size: 16, color: AppColors.accent),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: AppColors.cardShadow,
                ),
                child: MarkdownBody(
                  data: m.answer,
                  styleSheet: _markdownStyle(context),
                  extensionSet: md.ExtensionSet.gitHubFlavored,
                  inlineSyntaxes: [_StatusTagSyntax()],
                  builders: {
                    'statustag':
                    _StatusTagBuilder((raw) => _tagLabel(raw, l10n)),
                  },
                ),
              ),
              if (m.createdAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    formatDateTime(m.createdAt!),
                    style: AppTheme.font(size: 12, color: AppColors.textMuted),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _suggestionChip(String text, bool disabled) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: AppColors.surface,
        shape: const StadiumBorder(side: BorderSide(color: AppColors.track)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: disabled ? null : () => _send(text),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_outlined,
                    size: 14, color: AppColors.accent),
                const SizedBox(width: 6),
                Text(text,
                    style: AppTheme.font(size: 13, weight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(List<String> suggestions, AppLocalizations l10n) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.auto_awesome_outlined,
                  size: 30, color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.askYourBusiness,
              textAlign: TextAlign.center,
              style: AppTheme.font(size: 20, weight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.askQuestionSubtitle,
              textAlign: TextAlign.center,
              style: AppTheme.label,
            ),
            const SizedBox(height: 28),
            for (final s in suggestions)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _send(s),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.accentSoft,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(Icons.auto_awesome_outlined,
                                size: 17, color: AppColors.accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              s,
                              maxLines: 2,
                              style: AppTheme.font(
                                  size: 14, weight: FontWeight.w500),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              size: 20, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiProvider);
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
            content: Text(next.error!),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      if (next.messages.length > (previous?.messages.length ?? 0)) {
        _scrollToEnd();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.canvas,
      drawer: const AppDrawer(currentRoute: '/ai'),
      appBar: AppPageHeader(
        title: l10n.aiCopilot,
        subtitle: l10n.aiAssistant,
        icon: Icons.auto_awesome_outlined,
        color: AppColors.accent,
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty && !state.isLoading
                ? _emptyState(suggestions, l10n)
                : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final m = state.messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _userBubble(m.question),
                      _assistantBubble(m, l10n),
                    ],
                  ),
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
                        strokeWidth: 2, color: AppColors.accent),
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.analyzingData, style: AppTheme.label),
                ],
              ),
            ),

          if (state.messages.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                children: [
                  for (final s in suggestions)
                    _suggestionChip(s, state.isLoading),
                ],
              ),
            ),

          Container(
            color: AppColors.canvas,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: TextField(
                        controller: questionController,
                        textInputAction: TextInputAction.send,
                        minLines: 1,
                        maxLines: 4,
                        onSubmitted: _send,
                        style: AppTheme.font(size: 15),
                        decoration: InputDecoration(
                          hintText: l10n.askYourQuestion,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          hintStyle: AppTheme.font(
                              size: 15, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: state.isLoading ? AppColors.track : AppColors.black,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: state.isLoading
                          ? null
                          : () => _send(questionController.text),
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Icon(Icons.arrow_upward,
                            size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}