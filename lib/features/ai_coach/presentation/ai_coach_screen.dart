import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/ai.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';
import '../../../shared/widgets/nirmaan_badge.dart';
import '../../../shared/widgets/nirmaan_card.dart';
import '../controllers/ai_controller.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend(AiController controller, String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;

    _messageController.clear();
    await controller.sendMessage(clean);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final aiController = context.watch<AiController>();
    final messages = aiController.messages;
    final isSending = aiController.isSending;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'AI Business Coach',
        subtitle: 'Powered by Gemini AI',
        isDark: true,
        actions: [
          IconButton(
            tooltip: 'Clear Chat',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              aiController.clearChat();
            },
          ),
          IconButton(
            tooltip: 'Advisory Notice',
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showAdvisoryDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Decision Support Advisory Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.aiPurpleLight,
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppColors.aiPurple,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Decision support information · Guidance only (SRS FR-24)',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.aiPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppDimensions.space16),
              itemCount: messages.length + (isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isSending) {
                  return _buildTypingIndicator();
                }
                final msg = messages[index];
                return _buildMessageItem(context, msg);
              },
            ),
          ),

          // Suggested Prompts Horizontal Scroll
          if (!isSending)
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: aiController.suggestedPrompts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prompt = aiController.suggestedPrompts[index];
                  return ActionChip(
                    label: Text(prompt, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.surfaceWhite,
                    side: const BorderSide(color: AppColors.surfaceBorder),
                    onPressed: () => _handleSend(aiController, prompt),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),

          // Text Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceWhite,
              border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !isSending,
                      decoration: const InputDecoration(
                        hintText: 'Ask your business coach...',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (val) => _handleSend(aiController, val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                    ),
                    icon: isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                    onPressed: isSending
                        ? null
                        : () => _handleSend(
                            aiController, _messageController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, AiChatMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryNavy,
            borderRadius:
                BorderRadius.circular(16).copyWith(bottomRight: Radius.zero),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      );
    } else {
      final structured = msg.structuredResponse;
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16, right: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius:
                BorderRadius.circular(16).copyWith(bottomLeft: Radius.zero),
            border: Border.all(
              color: AppColors.aiPurple.withValues(alpha: 0.25),
            ),
            boxShadow: AppDimensions.shadowSubtle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge & Confidence
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 15, color: AppColors.aiPurple),
                      const SizedBox(width: 6),
                      Text(
                        'AI BUSINESS COACH',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.aiPurple,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  if (structured != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlueLight.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        structured.confidence,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Summary Text
              Text(
                msg.text,
                style: AppTypography.body.copyWith(height: 1.4),
              ),

              // Insights List
              if (structured != null && structured.insights.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: AppDimensions.borderSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operational Observations',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...structured.insights.map(
                        (insight) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(
                                      color: AppColors.primaryNavy,
                                      fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(
                                  insight,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Warnings
              if (structured != null && structured.warnings.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...structured.warnings.map(
                  (warn) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.alertAmber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.alertAmber.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 16, color: AppColors.alertAmber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            warn,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Recommendations Section
              if (structured != null &&
                  structured.recommendations.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Recommended Actions (User Confirmation Required)',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 8),
                ...structured.recommendations.map(
                  (rec) => _buildRecommendationCard(context, rec),
                ),
              ],

              // Disclaimer
              const SizedBox(height: 10),
              Text(
                structured?.disclaimer ??
                    'Decision-support guidance only. Not financial or business guarantees.',
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildRecommendationCard(BuildContext context, AiRecommendation rec) {
    BadgeType badgeType = BadgeType.info;
    if (rec.category == 'INVENTORY') badgeType = BadgeType.warning;
    if (rec.category == 'SALES') badgeType = BadgeType.success;

    return NirmaanCard(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  rec.title,
                  style: AppTypography.cardTitle.copyWith(fontSize: 13),
                ),
              ),
              NirmaanBadge(label: rec.category, type: badgeType),
            ],
          ),
          if (rec.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(rec.description, style: AppTypography.caption),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryNavy,
                side: const BorderSide(color: AppColors.primaryNavy),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 14),
              label: Text(rec.actionLabel, style: const TextStyle(fontSize: 11)),
              onPressed: () {
                // Safe user-directed navigation. The user explicitly reviews and acts.
                Navigator.of(context).pushNamed(rec.route);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.aiPurple,
              ),
            ),
            SizedBox(width: 10),
            Text('Synthesizing store intelligence...',
                style: AppTypography.caption),
          ],
        ),
      ),
    );
  }

  void _showAdvisoryDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.aiPurple, size: 20),
            SizedBox(width: 8),
            Text('AI Decision Support Notice'),
          ],
        ),
        content: const Text(
          'Per SRS Section 3.3 (FR-24), all AI recommendations are decision-support guidance only. The AI will never autonomously mutate inventory, orders, prices, or live business records without your explicit review and confirmation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}
