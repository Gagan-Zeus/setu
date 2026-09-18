import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../routes.dart';
import '../theme/tokens.dart';
import '../widgets/big_action_button.dart';
import '../widgets/language_toggle.dart';
import '../widgets/setu_card.dart';
import '../widgets/setu_logo.dart';

enum _Step { email, otp }

/// Sign-in happens once. After this the PIN guards every open, and the cached
/// session is never expired by the app — she must not be asked to
/// re-authenticate in a village with no signal.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _otpFocus = FocusNode();
  static final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  _Step _step = _Step.email;
  bool _busy = false;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  Future<void> _sendCode(AppLocalizations l) async {
    final email = _email.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _error = l.emailInvalid);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });

    final auth = ref.read(authControllerProvider.notifier);
    try {
      await auth.sendOtp(email);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = l.otpSendFailed;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _step = _Step.otp;
      // Be honest about which path she is on rather than pretending a code
      // was sent when it was not.
      _notice = auth.otpUnavailable ? l.otpOfflineFallback : null;
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _otpFocus.requestFocus());
  }

  Future<void> _verify(AppLocalizations l) async {
    if (_otp.text.length != 6) {
      setState(() => _error = l.otpInvalid);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).verifyOtp(
            email: _email.text.trim(),
            code: _otp.text,
          );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = l.otpWrongCode;
      });
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.pin, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(S.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: S.sm),
                Row(
                  children: [
                    const SetuLogo(size: 56),
                    const SizedBox(width: S.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.appName, style: T.h1),
                          Text(l.appTagline, style: T.bodySoft),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: S.lg),
                Text(l.chooseLanguage, style: T.label),
                const SizedBox(height: S.sm),
                const LanguageToggle(),
                const SizedBox(height: S.lg),
                switch (_step) {
                  _Step.email => _emailStep(l),
                  _Step.otp => _otpStep(l),
                },
                if (_notice != null) ...[
                  const SizedBox(height: S.md),
                  Container(
                    padding: const EdgeInsets.all(S.md),
                    decoration: BoxDecoration(
                      color: C.amberSoft,
                      borderRadius: BorderRadius.circular(S.radius),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.cloud_off, size: 24, color: C.amber),
                        const SizedBox(width: S.sm),
                        Expanded(
                          child: Text(_notice!,
                              style: T.bodySoft.copyWith(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: S.md),
                  Row(
                    children: [
                      const Icon(Icons.error_outline, color: C.red, size: 24),
                      const SizedBox(width: S.sm),
                      Expanded(
                        child:
                            Text(_error!, style: T.body.copyWith(color: C.red)),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: S.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailStep(AppLocalizations l) {
    return SetuCard(
      padding: const EdgeInsets.all(S.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.loginTitle, style: T.h2),
          const SizedBox(height: S.xs),
          Text(l.loginSubtitle, style: T.bodySoft),
          const SizedBox(height: S.lg),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            autofillHints: const [AutofillHints.email],
            style: T.body,
            onSubmitted: (_) => _sendCode(l),
            decoration: InputDecoration(
              labelText: l.emailLabel,
              hintText: l.emailHint,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: S.md, right: S.sm),
                child: Icon(Icons.mail_outline, size: 26, color: C.textSoft),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
            ),
          ),
          const SizedBox(height: S.md),
          BigActionButton(
            label: _busy ? l.otpSending : l.signIn,
            icon: Icons.mark_email_read_outlined,
            onPressed: _busy ? null : () => _sendCode(l),
          ),
          const SizedBox(height: S.sm),
          TextButton(
            onPressed: () => _forgotPassword(context, l),
            child: Text(l.forgotPassword),
          ),
        ],
      ),
    );
  }

  Widget _otpStep(AppLocalizations l) {
    return SetuCard(
      padding: const EdgeInsets.all(S.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.otpTitle, style: T.h2),
          const SizedBox(height: S.xs),
          Text(l.otpSentTo(_email.text.trim()), style: T.bodySoft),
          const SizedBox(height: S.lg),
          _OtpBoxes(controller: _otp, focusNode: _otpFocus),
          const SizedBox(height: S.lg),
          BigActionButton(
            label: _busy ? l.otpVerifying : l.otpVerify,
            icon: Icons.check_circle_outline,
            onPressed: _busy ? null : () => _verify(l),
          ),
          const SizedBox(height: S.sm),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: _busy ? null : () => _sendCode(l),
                  icon: const Icon(Icons.refresh, size: 22),
                  label:
                      Text(l.otpResend, style: T.button.copyWith(fontSize: 16)),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    _step = _Step.email;
                    _otp.clear();
                    _error = null;
                    _notice = null;
                  }),
                  icon: const Icon(Icons.edit_outlined, size: 22),
                  label: Text(l.otpChangeEmail,
                      style: T.button.copyWith(fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _forgotPassword(BuildContext context, AppLocalizations l) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(S.radius),
        ),
        title: Text(l.forgotPasswordTitle, style: T.h2),
        content: Text(l.forgotPasswordBody, style: T.body),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style:
                FilledButton.styleFrom(minimumSize: const Size(120, S.tapMin)),
            child: Text(l.ok),
          ),
        ],
      ),
    );
  }
}

/// Six boxes backed by one field — far more reliable on low-end keyboards
/// than six separate inputs chasing focus.
class _OtpBoxes extends StatefulWidget {
  const _OtpBoxes({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
    widget.focusNode.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    widget.focusNode.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            final filled = i < text.length;
            final active = i == text.length && widget.focusNode.hasFocus;
            return Container(
              width: 46,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: C.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? C.teal : C.divider,
                  width: active ? 2 : 1,
                ),
              ),
              child: Text(
                filled ? text[i] : '',
                style: T.h1.copyWith(fontSize: 26),
              ),
            );
          }),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              keyboardType: TextInputType.number,
              maxLength: 6,
              showCursor: false,
              enableInteractiveSelection: false,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(counterText: ''),
            ),
          ),
        ),
      ],
    );
  }
}
