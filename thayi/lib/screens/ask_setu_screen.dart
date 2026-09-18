import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../data/chat_history.dart';
import '../data/chat_service.dart';
import '../data/voice_service.dart';
import '../l10n/app_localizations.dart';
import '../l10n/content.dart';
import '../providers.dart';
import '../routes.dart';
import '../theme/tokens.dart';
import '../widgets/setu_scaffold.dart';
import 'danger_alert_screen.dart';

class _Message {
  _Message.fromMother(this.text)
      : fromMother = true,
        failure = null,
        blocked = false;
  _Message.fromSetu(this.text)
      : fromMother = false,
        failure = null,
        blocked = false;
  _Message.failed(this.failure)
      : fromMother = false,
        text = null,
        blocked = false;
  _Message.blocked()
      : fromMother = false,
        text = null,
        failure = null,
        blocked = true;

  final bool fromMother;

  /// What was said — her question, or the assistant's own words. The assistant
  /// writes each answer for the question she actually asked, so there is no id
  /// to look up here.
  final String? text;

  /// Set when no answer could be given, so the transcript can explain why and
  /// offer her ASHA worker.
  final ChatFailure? failure;

  /// A note in the transcript saying the message was held back on purpose.
  final bool blocked;
}

class AskSetuScreen extends ConsumerStatefulWidget {
  const AskSetuScreen({super.key});

  @override
  ConsumerState<AskSetuScreen> createState() => _AskSetuScreenState();
}

class _AskSetuScreenState extends ConsumerState<AskSetuScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _speech = SpeechToText();
  final _recorder = SpeechRecorder();

  final List<_Message> _messages = [];
  bool _thinking = false;
  bool _listening = false;
  bool _speechReady = false;

  /// Capturing her voice for Scribe.
  bool _recording = false;

  /// Waiting on the transcription to come back.
  bool _transcribing = false;

  @override
  void initState() {
    super.initState();
    // Read straight back, before the first frame, so she never sees an empty
    // screen flash into a conversation she already had.
    final stored = ref.read(chatHistoryProvider).load();
    _messages.addAll(stored.map((m) => m.blocked
        ? _Message.blocked()
        : m.fromMother
            ? _Message.fromMother(m.text!)
            : _Message.fromSetu(m.text!)));
    if (_messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
  }

  /// Written after every turn rather than on dispose: she may close the app
  /// from this screen, and a transcript that only survives a clean exit is not
  /// a transcript.
  void _persist() {
    ref.read(chatHistoryProvider).save([
      for (final m in _messages)
        if (m.failure == null)
          StoredMessage(
            fromMother: m.fromMother,
            text: m.text,
            blocked: m.blocked,
          ),
    ]);
  }

  Future<void> _clearHistory() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(S.radius)),
        title: Text(l.chatClearTitle, style: T.h2),
        content: Text(l.chatClearBody, style: T.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              minimumSize: const Size(120, S.tapMin),
              backgroundColor: C.red,
            ),
            child: Text(l.chatClearConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(chatHistoryProvider).clear();
    if (mounted) setState(_messages.clear);
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _recorder.dispose();
    super.dispose();
  }

  /// The conversation so far, so a follow-up like "and after delivery?" is
  /// understood. Blocked and failed turns are left out — they are notes to
  /// her, not part of what was discussed.
  List<ChatTurn> get _history => [
        for (final m in _messages)
          if (m.text != null) ChatTurn(fromMother: m.fromMother, text: m.text!),
      ];

  Future<void> _send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _thinking) return;

    // ---- The safety gate. This runs on every message, before anything
    // ---- is handed to the chat service. It is a keyword matcher, not a
    // ---- model call, and it is the reason the message may never be sent.
    final match = ref.read(dangerSignDetectorProvider).detect(text);
    if (match != null) {
      setState(() {
        _messages
          ..add(_Message.fromMother(text))
          ..add(_Message.blocked());
        _input.clear();
      });
      _persist();
      _scrollToEnd();
      await DangerAlertScreen.show(context, match);
      return;
    }

    final history = _history;
    setState(() {
      _messages.add(_Message.fromMother(text));
      _input.clear();
      _thinking = true;
    });
    _scrollToEnd();

    final reply =
        await ref.read(chatServiceProvider).ask(text, history: history);
    if (!mounted) return;
    setState(() {
      _messages.add(reply.canAnswer
          ? _Message.fromSetu(reply.text!)
          : _Message.failed(reply.failure!));
      _thinking = false;
    });
    _persist();
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// Records her question and sends the audio to Scribe.
  ///
  /// Preferred over the device recogniser because Android's own Kannada support
  /// is unreliable and missing entirely on many of the cheap handsets these
  /// women use, whereas Scribe transcribes Kannada at under 5% word error.
  /// [_toggleMic] is kept as the fallback for when the network is not there.
  Future<void> _toggleScribe() async {
    final l = AppLocalizations.of(context);
    final voice = ref.read(voiceServiceProvider);
    if (voice == null) return _toggleMic();

    if (_recording) {
      setState(() => _recording = false);
      final file = await _recorder.stop();
      if (file == null || !mounted) return;

      setState(() => _transcribing = true);
      try {
        final lang = ref.read(localeControllerProvider).languageCode;
        final text = await voice.transcribe(file, lang: lang);
        if (text != null && mounted) {
          _input.value = TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        }
      } on VoiceException catch (e) {
        if (!mounted) return;
        _toast(switch (e.failure) {
          VoiceFailure.nothingHeard => l.voiceNothingHeard,
          VoiceFailure.noPermission => l.micDenied,
          // No connection: fall back to whatever the phone itself can do.
          VoiceFailure.offline => l.micUnavailable,
        });
        if (e.failure == VoiceFailure.offline && mounted) await _toggleMic();
      } finally {
        // The upload is the only copy that matters; the file is temporary.
        unawaited(file.delete().catchError((_) => file));
        if (mounted) setState(() => _transcribing = false);
      }
      return;
    }

    if (!await _ensureMicPermission()) return;
    try {
      await _recorder.start(await getTemporaryDirectory());
      if (mounted) setState(() => _recording = true);
    } on VoiceException {
      if (mounted) _toast(l.micDenied);
    }
  }

  /// Explains before asking. The system dialog on its own means nothing to
  /// someone who has never been asked for a microphone before.
  Future<bool> _ensureMicPermission() async {
    final l = AppLocalizations.of(context);
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    if (!mounted) return false;

    final agreed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(S.radius),
        ),
        title: Text(l.micPermissionTitle, style: T.h2),
        content: Text(l.micPermissionBody, style: T.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style:
                FilledButton.styleFrom(minimumSize: const Size(120, S.tapMin)),
            child: Text(l.micAllow),
          ),
        ],
      ),
    );
    if (agreed != true) return false;
    final result = await Permission.microphone.request();
    if (!result.isGranted && mounted) _toast(l.micDenied);
    return result.isGranted;
  }

  Future<void> _toggleMic() async {
    final l = AppLocalizations.of(context);

    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    // Explain before asking. The system dialog on its own means nothing to
    // someone who has never been asked for a microphone before.
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      if (!mounted) return;
      final agreed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: C.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(S.radius),
          ),
          title: Text(l.micPermissionTitle, style: T.h2),
          content: Text(l.micPermissionBody, style: T.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                minimumSize: const Size(120, S.tapMin),
              ),
              child: Text(l.micAllow),
            ),
          ],
        ),
      );
      if (agreed != true) return;
      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        _toast(l.micDenied);
        return;
      }
    }

    if (!_speechReady) {
      _speechReady = await _speech.initialize(
        onStatus: (s) {
          if (s == 'done' || s == 'notListening') {
            if (mounted) setState(() => _listening = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _listening = false);
        },
      );
    }
    if (!_speechReady) {
      _toast(l.micUnavailable);
      return;
    }

    final localeId = ref.read(localeControllerProvider).languageCode == 'kn'
        ? 'kn_IN'
        : 'en_IN';

    setState(() => _listening = true);
    await _speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        partialResults: true,
      ),
      onResult: (result) {
        _input.value = TextEditingValue(
          text: result.recognizedWords,
          selection:
              TextSelection.collapsed(offset: result.recognizedWords.length),
        );
        if (result.finalResult && mounted) {
          setState(() => _listening = false);
        }
      },
    );
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: T.body)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mother = ref.watch(motherProvider).valueOrNull;

    return SetuScaffold(
      title: l.askSetuTitle,
      actions: [
        if (_messages.isNotEmpty)
          IconButton(
            onPressed: _clearHistory,
            icon: const Icon(Icons.delete_outline, size: 26),
            tooltip: l.chatClearTitle,
          ),
      ],
      bottomBar: _Composer(
        input: _input,
        listening: _listening || _recording,
        transcribing: _transcribing,
        showOpeners: _messages.isEmpty,
        onSend: () => _send(_input.text),
        onMic: _toggleScribe,
        // Tapping an opener sends that sentence to the assistant exactly as if
        // she had typed it, and she can keep talking from the answer.
        onSuggestion: (q) => _send(l.suggestedQuestion(q.id)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding:
                  const EdgeInsets.fromLTRB(S.screen, S.md, S.screen, S.md),
              children: [
                _Disclaimer(text: l.chatDisclaimer),
                const SizedBox(height: S.md),
                _Bubble.setu(text: l.chatWelcome),
                for (final m in _messages) ...[
                  const SizedBox(height: S.md),
                  if (m.blocked)
                    _BlockedNote()
                  else if (m.fromMother)
                    _Bubble.mother(text: m.text!)
                  else if (m.failure != null) ...[
                    // Every dead end offers her a person instead.
                    _Bubble.setu(text: l.chatFailure(m.failure!)),
                    const SizedBox(height: S.sm),
                    _ContactAshaButton(
                      onDone: () => _toast(
                        l.messageSentToAsha(
                          mother == null ? '' : l.ashaName(mother.asha),
                        ),
                      ),
                    ),
                  ] else ...[
                    _Bubble.setu(text: m.text!),
                    // Tap to hear it. Not automatic: she may be sitting with
                    // family, and an answer about her pregnancy read aloud is
                    // hers to choose.
                    _ListenButton(text: m.text!),
                  ],
                ],
                if (_thinking) ...[
                  const SizedBox(height: S.md),
                  _Bubble.setu(text: l.chatThinking, muted: true),
                ],
                // Clears the floating emergency button.
                const SizedBox(height: 96),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble.mother({required this.text})
      : fromMother = true,
        muted = false;
  const _Bubble.setu({required this.text, this.muted = false})
      : fromMother = false;

  final String text;
  final bool fromMother;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromMother ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.md),
        decoration: BoxDecoration(
          color: fromMother ? C.terraSoft : C.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(S.radius),
            topRight: const Radius.circular(S.radius),
            bottomLeft: Radius.circular(fromMother ? S.radius : S.xs),
            bottomRight: Radius.circular(fromMother ? S.xs : S.radius),
          ),
          boxShadow: kCardShadow,
        ),
        child: Text(
          text,
          style: muted ? T.bodySoft : T.body,
        ),
      ),
    );
  }
}

class _BlockedNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(S.md),
      decoration: BoxDecoration(
        color: C.redSoft,
        borderRadius: BorderRadius.circular(S.radius),
        border: Border.all(color: C.red, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: C.red, size: 26),
          const SizedBox(width: S.sm),
          Expanded(
            child: Text(
              l.dangerInterruptNote,
              style: T.body.copyWith(color: C.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactAshaButton extends StatelessWidget {
  const _ContactAshaButton({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: () {
          onDone();
          Navigator.pushNamed(context, Routes.asha);
        },
        icon: const Icon(Icons.person_outline, size: 24),
        label: Text(l.contactAshaFromChat),
        style: OutlinedButton.styleFrom(
          foregroundColor: C.terra,
          side: const BorderSide(color: C.terra, width: 1.5),
          minimumSize: const Size(0, S.tapMin),
          padding: const EdgeInsets.symmetric(horizontal: S.md),
          textStyle: T.button.copyWith(fontSize: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.input,
    required this.listening,
    required this.transcribing,
    required this.showOpeners,
    required this.onSend,
    required this.onMic,
    required this.onSuggestion,
  });

  final TextEditingController input;
  final bool listening;
  final bool transcribing;

  /// Openers belong on an empty screen. Once she is talking they are 108px of
  /// permanent furniture between her and the conversation — and with the
  /// keyboard up they left the message list no height at all.
  final bool showOpeners;
  final VoidCallback onSend;
  final VoidCallback onMic;
  final void Function(SuggestedQuestion) onSuggestion;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: C.bg,
        border: Border(top: BorderSide(color: C.divider)),
      ),
      // Scaffold insets its *body* for the keyboard but leaves
      // bottomNavigationBar where it is, so without this the keyboard covers
      // the very box she is typing into. SafeArea contributes nothing here
      // while the keyboard is up — MediaQuery.padding.bottom is zero then —
      // so the two do not double up.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Column(
          // Without this the composer eats the entire screen. Scaffold hands
          // bottomNavigationBar loose height constraints, and a Column defaults
          // to MainAxisSize.max, so it expanded to the full 600px and left the
          // message list exactly zero — the conversation was never on screen.
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tappable questions matter more than the text field for someone
            // who cannot type — but only until she has started talking.
            if (showOpeners)
              SizedBox(
                height: 108,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.fromLTRB(S.screen, S.sm, S.screen, 0),
                  children: [
                    for (final topic in ChatTopic.values)
                      Padding(
                        padding: const EdgeInsets.only(right: S.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.chatTopic(topic), style: T.label),
                            const SizedBox(height: S.xs),
                            Row(
                              children: [
                                for (final q in kSuggestedQuestions
                                    .where((q) => q.topic == topic))
                                  Padding(
                                    padding: const EdgeInsets.only(right: S.sm),
                                    child: _Chip(
                                      label: l.suggestedQuestion(q.id),
                                      onTap: () => onSuggestion(q),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(S.screen, S.sm, S.screen, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      minLines: 1,
                      maxLines: 4,
                      style: T.body,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      decoration: InputDecoration(
                        hintText: transcribing
                            ? l.chatThinking
                            : listening
                                ? l.voiceRecording
                                : l.chatHint,
                      ),
                    ),
                  ),
                  const SizedBox(width: S.sm),
                  _RoundButton(
                    icon: listening ? Icons.stop : Icons.mic_none,
                    label: l.chatSpeak,
                    color: listening ? C.red : C.tealSoft,
                    iconColor: listening ? C.onDark : C.teal,
                    onTap: transcribing ? () {} : onMic,
                  ),
                  const SizedBox(width: S.sm),
                  _RoundButton(
                    icon: Icons.send,
                    label: l.chatSend,
                    color: C.teal,
                    iconColor: C.onDark,
                    onTap: onSend,
                  ),
                ],
              ),
            ),
            const SizedBox(height: S.sm),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: C.tealSoft,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, maxWidth: 260),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: S.md),
          child: Text(
            label,
            style: T.body.copyWith(fontSize: 17, color: C.teal),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(
            width: S.tapMin,
            height: S.tapMin,
            child: Icon(icon, color: iconColor, size: 28),
          ),
        ),
      ),
    );
  }
}

/// Reads one answer aloud.
///
/// Deliberately a per-message control rather than a global setting: she may be
/// sitting with family, and an answer about her own pregnancy read out loud is
/// hers to ask for.
class _ListenButton extends ConsumerStatefulWidget {
  const _ListenButton({required this.text});

  final String text;

  @override
  ConsumerState<_ListenButton> createState() => _ListenButtonState();
}

class _ListenButtonState extends ConsumerState<_ListenButton> {
  bool _busy = false;
  bool _playing = false;

  Future<void> _toggle() async {
    final voice = ref.read(voiceServiceProvider);
    if (voice == null) return;
    final l = AppLocalizations.of(context);

    if (_playing) {
      await voice.stopSpeaking();
      if (mounted) setState(() => _playing = false);
      return;
    }

    setState(() => _busy = true);
    try {
      final lang = ref.read(localeControllerProvider).languageCode;
      await voice.speak(widget.text, lang: lang);
      if (mounted) setState(() => _playing = true);
    } on VoiceException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.voiceUnavailable, style: T.body)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // No control at all when there is nothing to play through, rather than a
    // button that cannot work.
    if (ref.watch(voiceServiceProvider) == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: S.xs, left: S.xs),
        child: TextButton.icon(
          onPressed: _busy ? null : _toggle,
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _playing
                      ? Icons.stop_circle_outlined
                      : Icons.volume_up_outlined,
                  size: 22),
          label: Text(_playing ? l.voiceStop : l.voiceListen),
          style: TextButton.styleFrom(
            foregroundColor: C.teal,
            minimumSize: const Size(0, S.tapMin),
            padding: const EdgeInsets.symmetric(horizontal: S.sm),
            textStyle: T.button.copyWith(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

/// Said once, at the top of the conversation.
///
/// It used to sit inside the composer, which meant it was pinned above the
/// keyboard for the whole conversation and cost height the message list needed.
/// She reads it when she arrives; repeating it under every reply does not make
/// it any truer.
class _Disclaimer extends StatelessWidget {
  const _Disclaimer({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.info_outline, size: 15, color: C.textSoft),
        const SizedBox(width: S.xs),
        Flexible(
          child: Text(
            text,
            style: T.label.copyWith(fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
