import 'dart:io' show SocketException;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../routes.dart';
import '../theme/tokens.dart';
import '../widgets/big_action_button.dart';
import '../widgets/language_toggle.dart';
import '../widgets/setu_card.dart';
import '../widgets/setu_logo.dart';

enum _Step { phone, otp, consent }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _otpFocus = FocusNode();

  _Step _step = _Step.phone;
  String? _error;
  bool _consentChecked = false;
  bool _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  static final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  Future<void> _submitPhone(AppLocalizations l) async {
    final email = _phone.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _error = l.emailInvalid);
      return;
    }

    setState(() {
      _error = null;
      _busy = true;
    });

    final auth = ref.read(authControllerProvider.notifier);
    try {
      // Her account exists only because an ASHA registered her. An address
      // that is not on a mother's record never gets a code.
      if (!await auth.isRegistered(email)) {
        if (!mounted) return;
        setState(() {
          _busy = false;
          _error = l.emailNotRegistered;
        });
        return;
      }
      await auth.sendOtp(email);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _messageFor(error, l, fallback: l.otpSendFailed);
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _step = _Step.otp;
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _otpFocus.requestFocus());
  }

  Future<void> _submitOtp(AppLocalizations l) async {
    if (_otp.text.length != 6) {
      setState(() => _error = l.otpInvalid);
      return;
    }

    setState(() {
      _error = null;
      _busy = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).verifyOtp(
            email: _phone.text.trim(),
            code: _otp.text,
          );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _messageFor(error, l, fallback: l.otpWrongCode);
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _step = _Step.consent;
    });
  }

  /// Never show her a raw exception. Everything becomes one plain sentence.
  String _messageFor(Object error, AppLocalizations l,
      {required String fallback}) {
    final text = error.toString().toLowerCase();
    if (error is SocketException ||
        text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('connection closed')) {
      return l.noNetwork;
    }
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      if (message.contains('expired') ||
          message.contains('invalid') ||
          message.contains('token')) {
        return l.otpWrongCode;
      }
    }
    return fallback;
  }

  Future<void> _accept(AppLocalizations l) async {
    if (!_consentChecked) {
      setState(() => _error = l.consentMustAccept);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    await ref.read(authControllerProvider.notifier).recordConsent();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);
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
                  _Step.phone => _phoneStep(l),
                  _Step.otp => _otpStep(l),
                  _Step.consent => _consentStep(l),
                },
                if (_error != null) ...[
                  const SizedBox(height: S.md),
                  Row(
                    children: [
                      const Icon(Icons.error_outline, color: C.red, size: 24),
                      const SizedBox(width: S.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          style: T.body.copyWith(color: C.red),
                        ),
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

  Widget _phoneStep(AppLocalizations l) {
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
            controller: _phone,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            autofillHints: const [AutofillHints.email],
            textCapitalization: TextCapitalization.none,
            style: T.body.copyWith(fontSize: 20),
            decoration: InputDecoration(
              labelText: l.emailLabel,
              hintText: l.emailHint,
              counterText: '',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: S.md, right: S.sm),
                child: Icon(Icons.mail_outline, size: 26, color: C.textSoft),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
            ),
            onSubmitted: (_) => _submitPhone(l),
          ),
          const SizedBox(height: S.md),
          BigActionButton(
            label: _busy ? l.emailChecking : l.sendOtp,
            icon: Icons.sms_outlined,
            onPressed: _busy ? null : () => _submitPhone(l),
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
          Text(l.otpSentTo(_phone.text.trim()), style: T.bodySoft),
          const SizedBox(height: S.lg),
          _OtpBoxes(controller: _otp, focusNode: _otpFocus),
          const SizedBox(height: S.lg),
          BigActionButton(
            label: _busy ? l.otpVerifying : l.verify,
            icon: Icons.check_circle_outline,
            onPressed: _busy ? null : () => _submitOtp(l),
          ),
          const SizedBox(height: S.sm),
          TextButton.icon(
            onPressed: () => setState(() {
              _step = _Step.phone;
              _otp.clear();
              _error = null;
            }),
            icon: const Icon(Icons.edit_outlined, size: 22),
            label: Text(l.changeNumber),
          ),
        ],
      ),
    );
  }

  Widget _consentStep(AppLocalizations l) {
    Widget block(IconData icon, String title, String body) => Padding(
          padding: const EdgeInsets.only(bottom: S.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: C.tealSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: C.teal, size: 24),
              ),
              const SizedBox(width: S.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: T.body.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: S.xs),
                    Text(body, style: T.bodySoft),
                  ],
                ),
              ),
            ],
          ),
        );

    return SetuCard(
      padding: const EdgeInsets.all(S.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.consentTitle, style: T.h2),
          const SizedBox(height: S.lg),
          block(Icons.folder_shared_outlined, l.consentWhatTitle,
              l.consentWhatBody),
          block(Icons.visibility_outlined, l.consentWhoTitle, l.consentWhoBody),
          block(Icons.lock_open_outlined, l.consentWithdrawTitle,
              l.consentWithdrawBody),
          const Divider(height: S.lg),
          Material(
            color: _consentChecked ? C.tealSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() {
                _consentChecked = !_consentChecked;
                _error = null;
              }),
              child: Container(
                constraints: const BoxConstraints(minHeight: S.tapMin),
                padding: const EdgeInsets.symmetric(
                    horizontal: S.sm, vertical: S.sm),
                child: Row(
                  children: [
                    Icon(
                      _consentChecked
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 32,
                      color: _consentChecked ? C.teal : C.textSoft,
                    ),
                    const SizedBox(width: S.sm),
                    Expanded(child: Text(l.consentAccept, style: T.body)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: S.md),
          BigActionButton(
            label: l.continueLabel,
            icon: Icons.arrow_forward,
            onPressed: _busy ? null : () => _accept(l),
          ),
        ],
      ),
    );
  }
}

/// Six boxes backed by one field - far more reliable on low-end keyboards
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
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

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
              width: 48,
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
