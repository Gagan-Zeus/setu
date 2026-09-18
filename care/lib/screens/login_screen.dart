import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/care_logo.dart';
import '../widgets/care_widgets.dart';

enum _Step { email, otp }

/// Centred card. Email, then a six digit code sent to it. The session is
/// cached, so a clinic desk signs in once.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController(text: 'sridevi@phc.kar.gov.in');
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

  Future<void> _sendCode() async {
    final email = _email.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });

    final auth = ref.read(authProvider.notifier);
    try {
      await auth.sendOtp(email);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not send the code. Check the address and try again.';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _step = _Step.otp;
      _notice = auth.otpUnavailable
          ? 'No connection — signed in on this device only.'
          : null;
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _otpFocus.requestFocus());
  }

  Future<void> _verify() async {
    if (_otp.text.length != 6) {
      setState(() => _error = 'Enter all 6 digits');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .verifyOtp(email: _email.text.trim(), code: _otp.text);
      // The router swaps to the shell on session change.
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'That code is not right. Check your email and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(S.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: CareCard(
                padding: const EdgeInsets.all(S.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const CareLogo(size: 30),
                        const SizedBox(width: S.sm),
                        const Text('Setu Care', style: T.h1),
                      ],
                    ),
                    const SizedBox(height: S.sm),
                    const Text(
                      'Antenatal records from your ASHA workers, in one place.',
                      style: T.small,
                    ),
                    const SizedBox(height: S.lg),
                    if (_step == _Step.email)
                      ..._emailStep()
                    else
                      ..._otpStep(),
                    if (_notice != null) ...[
                      const SizedBox(height: S.md),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: C.amberSoft,
                          borderRadius: BorderRadius.circular(S.sm),
                        ),
                        child: Text(_notice!,
                            style: T.small.copyWith(color: C.amber)),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: S.md),
                      Text(_error!, style: T.small.copyWith(color: C.red)),
                    ],
                    const SizedBox(height: S.md),
                    Text(MockData.facility,
                        style: T.small, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _emailStep() => [
        const SectionLabel('Email'),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          style: T.body,
          onSubmitted: (_) => _sendCode(),
          decoration: const InputDecoration(hintText: 'name@phc.kar.gov.in'),
        ),
        const SizedBox(height: S.lg),
        FilledButton(
          onPressed: _busy ? null : _sendCode,
          child: Text(_busy ? 'Sending code…' : 'Send code'),
        ),
      ];

  List<Widget> _otpStep() => [
        SectionLabel('Code sent to ${_email.text.trim()}'),
        const SizedBox(height: S.sm),
        _OtpBoxes(controller: _otp, focusNode: _otpFocus),
        const SizedBox(height: S.lg),
        FilledButton(
          onPressed: _busy ? null : _verify,
          child: Text(_busy ? 'Checking…' : 'Verify'),
        ),
        const SizedBox(height: S.sm),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _busy ? null : _sendCode,
                child: const Text('Resend'),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () => setState(() {
                  _step = _Step.email;
                  _otp.clear();
                  _error = null;
                  _notice = null;
                }),
                child: const Text('Change email'),
              ),
            ),
          ],
        ),
      ];
}

/// Six boxes backed by one field.
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
              width: 44,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: C.bg,
                borderRadius: BorderRadius.circular(S.sm),
                border: Border.all(
                  color: active ? C.teal : C.divider,
                  width: active ? 2 : 1,
                ),
              ),
              child: Text(filled ? text[i] : '',
                  style: T.h1.copyWith(fontSize: 22)),
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
