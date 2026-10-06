import 'package:flutter/foundation.dart';
import '../../../models/ai.dart';
import '../../../repositories/ai_repository.dart';

class AiController extends ChangeNotifier {
  final AiRepository _aiRepository;

  final List<AiChatMessage> _messages = [];
  bool _isSending = false;
  bool _isLoadingBrief = false;
  String? _errorMessage;
  String? _briefErrorMessage;
  AiDailyBrief? _dailyBrief;

  final List<String> _suggestedPrompts = [
    'How is my business doing today?',
    'What inventory should I review?',
    'Which products need attention?',
    'Explain my business health score',
    'Who are customers at risk of churn?',
  ];

  AiController({required AiRepository aiRepository})
      : _aiRepository = aiRepository {
    _initDefaultGreeting();
  }

  List<AiChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  bool get isLoadingBrief => _isLoadingBrief;
  String? get errorMessage => _errorMessage;
  String? get briefErrorMessage => _briefErrorMessage;
  AiDailyBrief? get dailyBrief => _dailyBrief;
  List<String> get suggestedPrompts => List.unmodifiable(_suggestedPrompts);

  void _initDefaultGreeting() {
    _messages.clear();
    _messages.add(
      AiChatMessage(
        id: 'msg_welcome',
        text:
            'Hello! I am your Nirmaan AI Business Coach, connected to your live store records. Ask me about your sales, margins, low-stock items, or health score, and I will provide data-grounded guidance.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Sends a user question to the AI Business Coach.
  Future<void> sendMessage(String text) async {
    final clean = text.trim();
    if (clean.isEmpty || _isSending) return;

    _errorMessage = null;
    final userMsg = AiChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: clean,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _isSending = true;
    notifyListeners();

    try {
      // Build lightweight conversation history from recent messages
      final history = <Map<String, String>>[];
      for (final msg in _messages.take(_messages.length - 1)) {
        history.add({
          'role': msg.isUser ? 'user' : 'model',
          'content': msg.text,
        });
      }

      final response = await _aiRepository.askCoach(clean, history: history);

      _messages.add(
        AiChatMessage(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          text: response.summary,
          isUser: false,
          timestamp: response.timestamp,
          structuredResponse: response,
        ),
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _messages.add(
        AiChatMessage(
          id: 'ai_err_${DateTime.now().millisecondsSinceEpoch}',
          text:
              'I encountered an error retrieving store intelligence: $_errorMessage. Please check your network connection and try again.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Fetches Today's Business AI Brief from live backend operational data.
  Future<void> loadDailyBrief({bool forceRefresh = false}) async {
    if (_dailyBrief != null && !forceRefresh && !_isLoadingBrief) return;

    _isLoadingBrief = true;
    _briefErrorMessage = null;
    notifyListeners();

    try {
      _dailyBrief = await _aiRepository.getDailyBrief();
    } catch (e) {
      _briefErrorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingBrief = false;
      notifyListeners();
    }
  }

  /// Clears chat history back to initial state.
  void clearChat() {
    _initDefaultGreeting();
    _errorMessage = null;
    notifyListeners();
  }
}
