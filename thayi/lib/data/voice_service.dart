/// Her voice in, and a voice back out.
///
/// This is an accessibility feature before it is a convenience one. A woman who
/// cannot read gets nothing from the assistant's answer or from the danger-sign
/// screen telling her to go to the health centre now — and typing Kannada on a
/// phone keyboard is slow even for someone who reads it well.
///
/// Both directions run through Supabase Edge Functions, never against
/// ElevenLabs directly: the API key is billed per character and anything shipped
/// inside an APK can be pulled straight back out of it.
///
/// Kannada is why the models are not interchangeable. ElevenLabs only supports
/// it on `eleven_v3` — Multilingual v2 and Flash v2.5 do not include it at all —
/// and Scribe transcribes it at under 5% word error, which is better than the
/// recogniser built into most of the handsets these women actually own.
library;

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// What went wrong, in terms the UI can turn into a sentence she can act on.
enum VoiceFailure {
  /// No session, no connection, or the function could not be reached.
  offline,

  /// The recording ran but there was nothing intelligible in it.
  nothingHeard,

  /// She has not granted the microphone.
  noPermission,
}

class VoiceException implements Exception {
  const VoiceException(this.failure);
  final VoiceFailure failure;
}

abstract class VoiceService {
  /// Speaks [text] aloud and returns when playback finishes.
  Future<void> speak(String text, {String lang = 'kn'});

  /// Stops any playback in progress.
  Future<void> stopSpeaking();

  /// True while audio is playing, so the UI can show a stop control.
  Stream<bool> get speaking;

  /// Transcribes a recorded file. Returns null if nothing was heard.
  Future<String?> transcribe(File audio, {String lang = 'kn'});

  void dispose();
}

class SupabaseVoiceService implements VoiceService {
  SupabaseVoiceService(this._client);

  final SupabaseClient _client;
  final AudioPlayer _player = AudioPlayer();

  @override
  Stream<bool> get speaking => _player.onPlayerStateChanged
      .map((s) => s == PlayerState.playing)
      .distinct();

  @override
  Future<void> speak(String text, {String lang = 'kn'}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (_client.auth.currentSession == null) {
      throw const VoiceException(VoiceFailure.offline);
    }

    late final Uint8List audio;
    try {
      final response = await _client.functions.invoke(
        'speak',
        // The function replies as application/octet-stream, which is the only
        // content type this client hands back as raw bytes rather than trying
        // to decode as text — an mp3 does not survive that.
        body: {'text': trimmed, 'lang': lang},
      );
      final data = response.data;
      if (data is! List<int> || data.length < 512) {
        throw const VoiceException(VoiceFailure.offline);
      }
      audio = Uint8List.fromList(data);
    } on VoiceException {
      rethrow;
    } catch (error) {
      debugPrint('speak failed: $error');
      throw const VoiceException(VoiceFailure.offline);
    }

    await _player.stop();
    await _player.play(BytesSource(audio, mimeType: 'audio/mpeg'));
  }

  @override
  Future<void> stopSpeaking() => _player.stop();

  @override
  Future<String?> transcribe(File audio, {String lang = 'kn'}) async {
    if (_client.auth.currentSession == null) {
      throw const VoiceException(VoiceFailure.offline);
    }

    final bytes = await audio.readAsBytes();
    // Below about a kilobyte there is no speech in there — she tapped the mic
    // and released it immediately.
    if (bytes.length < 1024) {
      throw const VoiceException(VoiceFailure.nothingHeard);
    }

    try {
      final response = await _client.functions.invoke(
        'transcribe',
        files: [
          MultipartFile.fromBytes('file', bytes, filename: 'speech.m4a'),
        ],
        body: {'lang': lang},
      );

      final data = response.data;
      if (data is Map && data['text'] is String) {
        final text = (data['text'] as String).trim();
        if (text.isNotEmpty) return text;
      }
      throw const VoiceException(VoiceFailure.nothingHeard);
    } on VoiceException {
      rethrow;
    } catch (error) {
      debugPrint('transcribe failed: $error');
      throw const VoiceException(VoiceFailure.offline);
    }
  }

  @override
  void dispose() => _player.dispose();
}

/// Records a short spoken question to a temporary file.
///
/// Kept separate from [VoiceService] because recording is a device concern and
/// transcription is a network one — and because the device recogniser fallback
/// needs the same start/stop shape.
class SpeechRecorder {
  SpeechRecorder();

  final AudioRecorder _recorder = AudioRecorder();
  String? _path;

  Future<bool> get hasPermission => _recorder.hasPermission();

  Future<void> start(Directory tempDir) async {
    if (!await _recorder.hasPermission()) {
      throw const VoiceException(VoiceFailure.noPermission);
    }
    // AAC in an m4a container: small enough to upload over a village
    // connection, and Scribe accepts it directly.
    _path = '${tempDir.path}/ask-${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 64000,
        sampleRate: 22050,
        numChannels: 1,
      ),
      path: _path!,
    );
  }

  /// Returns the recorded file, or null if nothing was captured.
  Future<File?> stop() async {
    final path = await _recorder.stop();
    final target = path ?? _path;
    if (target == null) return null;
    final file = File(target);
    return await file.exists() ? file : null;
  }

  Future<bool> get isRecording => _recorder.isRecording();

  Future<void> cancel() async {
    await _recorder.cancel();
    _path = null;
  }

  void dispose() => _recorder.dispose();
}
