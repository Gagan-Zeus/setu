/// The assistant behind "Ask Setu".
///
/// She types or speaks a question in her own words and gets an answer written
/// for her — this is a conversation, not a menu of prepared answers. The model
/// runs on the server (a Supabase Edge Function), never in this app, because
/// the API key would otherwise be sitting inside the APK.
///
/// Two rules are enforced here in the client rather than trusted to the model:
/// danger signs (see [DangerSignDetector], which runs before anything reaches
/// this file) and medicines. Both must hold even if the assistant is offline,
/// misbehaving, or replaced.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

/// One line of the conversation, kept so follow-ups like "and after delivery?"
/// make sense to the assistant.
class ChatTurn {
  const ChatTurn({required this.fromMother, required this.text});

  final bool fromMother;
  final String text;

  Map<String, String> toJson() => {
        'role': fromMother ? 'user' : 'model',
        'text': text,
      };
}

/// Why an answer could not be given. Each maps to a sentence she can act on,
/// and every one of them offers her ASHA worker instead.
enum ChatFailure {
  /// Asked about a medicine or a dose. Refused in the client, always.
  medicine,

  /// No connection, or the assistant could not be reached.
  offline,

  /// The assistant answered nothing usable. Silence beats an unreviewed guess.
  noAnswer,
}

class ChatReply {
  const ChatReply.answer(String this.text) : failure = null;
  const ChatReply.failed(ChatFailure this.failure) : text = null;

  final String? text;
  final ChatFailure? failure;

  bool get canAnswer => text != null;
}

abstract class ChatService {
  Future<ChatReply> ask(String question, {List<ChatTurn> history = const []});
}

/// Anything about medicines or doses is refused before it leaves the phone.
///
/// A woman asking "how many paracetamol can I take" must not receive a number
/// from software, and the refusal cannot depend on a server being reachable or
/// a model following instructions.
class MedicineGuard {
  const MedicineGuard();

  static const terms = [
    'ಮಾತ್ರೆ',
    'ಔಷಧ',
    'ಔಷಧಿ',
    'ಡೋಸ್',
    'ಇಂಜೆಕ್ಷನ್',
    'ಗುಳಿಗೆ',
    'ಎಷ್ಟು ತೆಗೆದುಕೊ',
    'medicine',
    'tablet',
    'tablets',
    'dose',
    'dosage',
    'syrup',
    'injection',
    'antibiotic',
    'painkiller',
    'paracetamol',
    'ibuprofen',
    'aspirin',
    'matre',
    'aushadha',
  ];

  bool isAboutMedicine(String question) {
    final text = question.toLowerCase();
    return terms.any(text.contains);
  }
}

/// Talks to the `ask-setu` Edge Function.
///
/// The function holds the model key, pulls approved answers out of
/// `pregnancy_faqs`, and tells the model to answer only from those. All this
/// app sends is her question and the last few turns.
class GeminiChatService implements ChatService {
  const GeminiChatService(this._client, {this.guard = const MedicineGuard()});

  final SupabaseClient _client;
  final MedicineGuard guard;

  static const _function = 'ask-setu';

  @override
  Future<ChatReply> ask(
    String question, {
    List<ChatTurn> history = const [],
  }) async {
    if (guard.isAboutMedicine(question)) {
      return const ChatReply.failed(ChatFailure.medicine);
    }

    // No session means no assistant: the function refuses anonymous callers,
    // and there is nothing useful to show her offline.
    if (_client.auth.currentSession == null) {
      return const ChatReply.failed(ChatFailure.offline);
    }

    try {
      final response = await _client.functions.invoke(
        _function,
        body: {
          'question': question,
          // The last few turns only. More context is not worth the tokens or
          // the wait on a village connection.
          'history': history
              .sublist(history.length > 6 ? history.length - 6 : 0)
              .map((t) => t.toJson())
              .toList(),
        },
      );

      final data = response.data;
      if (data is Map && data['reply'] is String) {
        final reply = (data['reply'] as String).trim();
        if (reply.isNotEmpty) return ChatReply.answer(reply);
      }
      return const ChatReply.failed(ChatFailure.noAnswer);
    } on FunctionException {
      return const ChatReply.failed(ChatFailure.offline);
    } catch (_) {
      return const ChatReply.failed(ChatFailure.offline);
    }
  }
}

/// Used when Supabase is switched off, and in tests. It does not pretend to
/// answer — it says it cannot, which is the honest failure.
class MockChatService implements ChatService {
  const MockChatService({
    this.delay = const Duration(milliseconds: 600),
    this.reply,
    this.guard = const MedicineGuard(),
  });

  final Duration delay;

  /// Set in tests to make the assistant answer with a known string.
  final String? reply;
  final MedicineGuard guard;

  @override
  Future<ChatReply> ask(
    String question, {
    List<ChatTurn> history = const [],
  }) async {
    await Future.delayed(delay);
    if (guard.isAboutMedicine(question)) {
      return const ChatReply.failed(ChatFailure.medicine);
    }
    final text = reply;
    return text == null
        ? const ChatReply.failed(ChatFailure.offline)
        : ChatReply.answer(text);
  }
}

/// Openers shown above the keyboard.
///
/// These are not a FAQ list — tapping one sends that sentence to the assistant
/// exactly as if she had typed it, and she can carry on from the answer. They
/// exist because a blank text box is intimidating for someone who is not used
/// to typing, and because they show what kind of thing she may ask.
enum ChatTopic { food, rest, afterDelivery }

class SuggestedQuestion {
  const SuggestedQuestion({required this.topic, required this.id});

  final ChatTopic topic;

  /// Matches the `qFood1`-style key in the ARB files.
  final String id;
}

const kSuggestedQuestions = <SuggestedQuestion>[
  SuggestedQuestion(topic: ChatTopic.food, id: 'qFood1'),
  SuggestedQuestion(topic: ChatTopic.food, id: 'qFood2'),
  SuggestedQuestion(topic: ChatTopic.food, id: 'qFood3'),
  SuggestedQuestion(topic: ChatTopic.rest, id: 'qRest1'),
  SuggestedQuestion(topic: ChatTopic.rest, id: 'qRest2'),
  SuggestedQuestion(topic: ChatTopic.rest, id: 'qRest3'),
  SuggestedQuestion(topic: ChatTopic.afterDelivery, id: 'qAfter1'),
  SuggestedQuestion(topic: ChatTopic.afterDelivery, id: 'qAfter2'),
  SuggestedQuestion(topic: ChatTopic.afterDelivery, id: 'qAfter3'),
];
