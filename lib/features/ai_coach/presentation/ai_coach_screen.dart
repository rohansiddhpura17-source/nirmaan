import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nirmaan_app_bar.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Hello Rohan! I am your Nirmaan AI Business Coach. I have analyzed your store records for this month.\n\nYour net margin is currently 29.2%, and revenue is trending +14% compared to last week. How can I help optimize your business today?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  final List<String> _suggestedPrompts = [
    'Which items should I reorder today?',
    'How can I increase my profit margins?',
    'Who are my customers at risk of churn?',
    'What was my top selling product this week?',
  ];

  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _messageController.clear();

    await Future<void>.delayed(const Duration(milliseconds: 900));

    String aiReply;
    final lower = text.toLowerCase();
    if (lower.contains('reorder') || lower.contains('stock')) {
      aiReply =
          'Based on your recent 7-day velocity, you have 2 critical items:\n• **Fortune Sunflower Oil 1L** (2 left, sells ~4/day)\n• **Royal Basmati Rice 5kg** (4 left, sells ~3/day)\n\nI recommend placing a purchase order for 24 units of Oil and 15 bags of Rice before Thursday evening.';
    } else if (lower.contains('margin') || lower.contains('profit')) {
      aiReply =
          'Your highest margin category is **Spices & Masalas (38% margin)**, while Grains are at 18% margin. Bundling slow-moving spices with staple grains can increase your average cart value by ₹120 without adding overhead.';
    } else if (lower.contains('churn') || lower.contains('customer')) {
      aiReply =
          '12 customers haven\'t purchased in over 21 days. They previously averaged ₹1,200/month. A targeted WhatsApp reminder with a 5% loyalty coupon could recover ~40% of them.';
    } else {
      aiReply =
          'I have noted that for your store context. Tracking daily order volume and keeping stock levels above minimum thresholds will safeguard your 29% margin.';
    }

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: aiReply,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: NirmaanAppBar(
        title: 'AI Business Coach',
        subtitle: 'Powered by Gemini AI',
        isDark: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('AI Advisory Notice'),
                  content: const Text(
                    'Per SRS Section 3.3 (FR-24), all AI recommendations are decision-support guidance only. The AI will never autonomously execute financial or inventory transactions without explicit owner confirmation.',
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Understood')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // AI Decision Support Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.aiPurpleLight,
            child: Row(
              children: [
                const Icon(Icons.auto_awesome,
                    size: 14, color: AppColors.aiPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Decision support information · Guidance only (SRS FR-24)',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.aiPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.space16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Suggested Prompts
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _suggestedPrompts[index];
                return ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.surfaceWhite,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                  onPressed: () => _sendMessage(prompt),
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
                      decoration: const InputDecoration(
                        hintText: 'Ask your business coach...',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy),
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(_messageController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
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
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, right: 48),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius:
                BorderRadius.circular(16).copyWith(bottomLeft: Radius.zero),
            border:
                Border.all(color: AppColors.aiPurple.withValues(alpha: 0.2)),
            boxShadow: AppDimensions.shadowSubtle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome,
                      size: 14, color: AppColors.aiPurple),
                  const SizedBox(width: 6),
                  Text(
                    'AI ADVISOR',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.aiPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                msg.text,
                style: AppTypography.body,
              ),
            ],
          ),
        ),
      );
    }
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
                  strokeWidth: 2, color: AppColors.aiPurple),
            ),
            SizedBox(width: 10),
            Text('Analyzing store data...', style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}
