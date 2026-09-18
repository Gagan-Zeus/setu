import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../l10n/content.dart';
import '../providers.dart';
import '../safety/danger_sign_detector.dart';
import '../theme/tokens.dart';
import '../widgets/call_button.dart';

/// The full-screen interrupt. It is pushed by the client the moment
/// [DangerSignDetector] matches - before anything is sent anywhere.
///
/// It reads itself aloud as it opens. This is the one screen where a woman who
/// cannot read would otherwise get nothing at all from it, and the instruction
/// on it is to go to the health centre now.
class DangerAlertScreen extends ConsumerStatefulWidget {
  const DangerAlertScreen({super.key, required this.match});

  final DangerMatch match;

  static Future<void> show(BuildContext context, DangerMatch match) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => DangerAlertScreen(match: match),
      ),
    );
  }

  @override
  ConsumerState<DangerAlertScreen> createState() => _DangerAlertScreenState();
}

class _DangerAlertScreenState extends ConsumerState<DangerAlertScreen> {
  bool _spoken = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_spoken) return;
    _spoken = true;
    // After the first frame, so the warning is on screen before it is heard.
    WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
  }

  Future<void> _speak() async {
    final voice = ref.read(voiceServiceProvider);
    if (voice == null || !mounted) return;
    final l = AppLocalizations.of(context);
    final lang = ref.read(localeControllerProvider).languageCode;
    try {
      await voice.speak(
        '${l.dangerSignTitle(widget.match.sign)}. '
        '${l.dangerSignDo(widget.match.sign)}',
        lang: lang,
      );
    } catch (_) {
      // Silence here is acceptable: the warning is already on screen in full,
      // and there is nothing useful to tell her about a speech failure while
      // she is being told to go to hospital.
    }
  }

  @override
  void dispose() {
    ref.read(voiceServiceProvider)?.stopSpeaking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mother = ref.watch(motherProvider).valueOrNull;
    final match = widget.match;

    return PopScope(
      // She has to make a choice here, not swipe it away by accident.
      canPop: false,
      child: Scaffold(
        backgroundColor: C.red,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(S.screen),
            children: [
              const SizedBox(height: S.md),
              const Icon(Icons.warning_amber_rounded,
                  size: 72, color: C.onDark),
              const SizedBox(height: S.md),
              Text(
                l.dangerInterruptTitle,
                style: T.display.copyWith(color: C.onDark, fontSize: 34),
              ),
              const SizedBox(height: S.md),
              Text(
                l.dangerInterruptBody,
                style: T.body.copyWith(color: C.onDark, fontSize: 20),
              ),
              const SizedBox(height: S.lg),
              Container(
                padding: const EdgeInsets.all(S.md),
                decoration: BoxDecoration(
                  color: C.onDark.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(S.radius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.dangerSignTitle(match.sign),
                      style: T.h2.copyWith(color: C.onDark),
                    ),
                    const SizedBox(height: S.sm),
                    Text(
                      l.dangerSignDo(match.sign),
                      style: T.body.copyWith(color: C.onDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: S.lg),
              CallButton(
                title: l.callAmbulance,
                number: '108',
                subtitle: '108',
                background: C.ink,
                onFailureMessage: l.callFailed,
              ),
              const SizedBox(height: S.md),
              if (mother != null) ...[
                CallButton(
                  title: l.callAsha,
                  number: mother.asha.phone,
                  subtitle: l.ashaName(mother.asha),
                  background: C.terra,
                  onFailureMessage: l.callFailed,
                ),
                const SizedBox(height: S.md),
                CallButton(
                  title: l.callPhc,
                  number: mother.phc.phone,
                  subtitle: l.centreName(mother.phc),
                  background: C.terra,
                  onFailureMessage: l.callFailed,
                ),
                const SizedBox(height: S.md),
              ],
              Text(
                l.dangerInterruptNote,
                style: T.bodySoft.copyWith(
                  color: C.onDark.withValues(alpha: 0.85),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: S.lg),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: C.onDark,
                  minimumSize: const Size.fromHeight(S.tapMin),
                  side: BorderSide(color: C.onDark.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(l.dangerInterruptDismiss),
              ),
              const SizedBox(height: S.lg),
            ],
          ),
        ),
      ),
    );
  }
}
