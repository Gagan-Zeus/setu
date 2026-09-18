import 'package:flutter_test/flutter_test.dart';
import 'package:setu_thayi/data/chat_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setu_thayi/data/chat_service.dart';

void main() {
  const service = MockChatService(
    delay: Duration.zero,
    reply: 'Walking a little every day is good for you.',
  );

  group('medicines are refused in the client', () {
    // This must not depend on the server, the model, or a connection. A woman
    // asking how much of something to take never gets a number from software.
    const questions = [
      'how many paracetamol tablets can I take',
      'what dose of iron should I take',
      'can I take ibuprofen for back pain',
      'is this syrup safe',
      'doctor gave an injection, should I take another',
      'ಈ ಮಾತ್ರೆ ತೆಗೆದುಕೊಳ್ಳಬಹುದೇ',
      'ಯಾವ ಔಷಧಿ ಒಳ್ಳೆಯದು',
      'ಎಷ್ಟು ಗುಳಿಗೆ ತೆಗೆದುಕೊಳ್ಳಬೇಕು',
    ];

    for (final q in questions) {
      test(q, () async {
        final reply = await service.ask(q);
        expect(reply.canAnswer, isFalse);
        expect(reply.failure, ChatFailure.medicine);
      });
    }
  });

  test('ordinary questions still get through', () async {
    for (final q in [
      'what should I eat',
      'can I keep working',
      'ಚಹಾ ಕುಡಿಯಬಹುದೇ',
    ]) {
      final reply = await service.ask(q);
      expect(reply.canAnswer, isTrue, reason: q);
      expect(reply.text, isNotEmpty);
    }
  });

  test('with nothing to answer from, it says so instead of guessing', () async {
    const offline = MockChatService(delay: Duration.zero);
    final reply = await offline.ask('what should I eat');
    expect(reply.canAnswer, isFalse);
    expect(reply.failure, ChatFailure.offline);
  });

  _historyTests();

  test('history serialises to the roles the assistant expects', () {
    const turns = [
      ChatTurn(fromMother: true, text: 'what should I eat'),
      ChatTurn(fromMother: false, text: 'Eat a little more than usual.'),
    ];
    expect(turns.map((t) => t.toJson()['role']).toList(), ['user', 'model']);
  });
}

/// The transcript survives leaving the screen — everything the assistant told
/// her used to vanish the moment she navigated away.
void _historyTests() {
  group('saved transcript', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('round-trips a conversation', () async {
      final history = ChatHistory(await SharedPreferences.getInstance());
      await history.save(const [
        StoredMessage(fromMother: true, text: 'can I eat papaya'),
        StoredMessage(fromMother: false, text: 'Ripe papaya is fine.'),
        StoredMessage(fromMother: false, text: null, blocked: true),
      ]);

      final loaded = ChatHistory(await SharedPreferences.getInstance()).load();
      expect(loaded, hasLength(3));
      expect(loaded[0].fromMother, isTrue);
      expect(loaded[1].text, 'Ripe papaya is fine.');
      // A blocked turn is a note, not something that was said.
      expect(loaded[2].blocked, isTrue);
      expect(loaded[2].text, isNull);
    });

    test('keeps only the most recent turns', () async {
      final history = ChatHistory(await SharedPreferences.getInstance());
      await history.save([
        for (var i = 0; i < ChatHistory.maxMessages + 20; i++)
          StoredMessage(fromMother: i.isEven, text: 'message $i'),
      ]);
      final loaded = history.load();
      expect(loaded, hasLength(ChatHistory.maxMessages));
      // The oldest were dropped, not the newest.
      expect(loaded.last.text, 'message ${ChatHistory.maxMessages + 19}');
    });

    test('a corrupt store loses the transcript, not the screen', () async {
      SharedPreferences.setMockInitialValues({'ask_setu_history': 'not json'});
      final history = ChatHistory(await SharedPreferences.getInstance());
      expect(history.load(), isEmpty);
    });

    test('clearing removes it', () async {
      final history = ChatHistory(await SharedPreferences.getInstance());
      await history
          .save(const [StoredMessage(fromMother: true, text: 'hello')]);
      await history.clear();
      expect(history.load(), isEmpty);
    });
  });
}
