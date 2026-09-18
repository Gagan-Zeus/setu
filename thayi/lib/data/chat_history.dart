/// Keeps the conversation between visits to the screen.
///
/// Without this, everything the assistant told her disappeared the moment she
/// navigated away — which is the opposite of useful for advice she is meant to
/// act on later. She should be able to come back and re-read what she was told
/// about her tablets or her next checkup.
///
/// It is stored on the phone and nowhere else. These are her questions about
/// her own body; her ASHA worker and the doctor have no need of them, and
/// putting them in the shared record would create a history she never asked
/// for. That also means it survives with no signal, which is when she is most
/// likely to be re-reading rather than asking.
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One line of the transcript as it is stored.
class StoredMessage {
  const StoredMessage({
    required this.fromMother,
    required this.text,
    this.blocked = false,
  });

  final bool fromMother;

  /// Null for a blocked turn, which is a note rather than something said.
  final String? text;

  /// A danger sign was caught and the message was never sent.
  final bool blocked;

  Map<String, dynamic> toJson() => {
        'me': fromMother,
        if (text != null) 'text': text,
        if (blocked) 'blocked': true,
      };

  static StoredMessage? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final blocked = raw['blocked'] == true;
    final text = raw['text'];
    if (!blocked && text is! String) return null;
    return StoredMessage(
      fromMother: raw['me'] == true,
      text: text is String ? text : null,
      blocked: blocked,
    );
  }
}

class ChatHistory {
  const ChatHistory(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'ask_setu_history';

  /// Old turns are dropped rather than kept forever. A year of questions is not
  /// something she scrolls, and the file lives on a phone with little room.
  static const maxMessages = 60;

  List<StoredMessage> load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .map(StoredMessage.fromJson)
          .whereType<StoredMessage>()
          .toList();
    } catch (_) {
      // A corrupt store is not worth crashing the screen over. She loses the
      // transcript, which is recoverable; a crash on open is not.
      return const [];
    }
  }

  Future<void> save(List<StoredMessage> messages) async {
    final trimmed = messages.length > maxMessages
        ? messages.sublist(messages.length - maxMessages)
        : messages;
    await _prefs.setString(
      _key,
      jsonEncode(trimmed.map((m) => m.toJson()).toList()),
    );
  }

  Future<void> clear() => _prefs.remove(_key);
}
