import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../routes.dart';
import '../theme/tokens.dart';
import '../widgets/setu_logo.dart';

/// Set on first sign-in, asked for on every open afterwards. The phone is
/// shared and it holds other women's medical records.
class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

enum _Stage { create, confirm, verify }

class _PinScreenState extends ConsumerState<PinScreen> {
  String _entry = '';
  String _first = '';
  String? _error;
  late _Stage _stage;

  @override
  void initState() {
    super.initState();
    _stage =
        ref.read(authControllerProvider).hasPin ? _Stage.verify : _Stage.create;
  }

  void _press(String digit) {
    if (_entry.length >= 4) return;
    setState(() {
      _entry += digit;
      _error = null;
    });
    if (_entry.length == 4) {
      // Let the fourth dot paint before moving on.
      WidgetsBinding.instance.addPostFrameCallback((_) => _complete());
    }
  }

  void _backspace() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _complete() async {
    final l = AppLocalizations.of(context);
    final auth = ref.read(authControllerProvider.notifier);

    switch (_stage) {
      case _Stage.create:
        setState(() {
          _first = _entry;
          _entry = '';
          _stage = _Stage.confirm;
        });
      case _Stage.confirm:
        if (_entry != _first) {
          setState(() {
            _entry = '';
            _first = '';
            _stage = _Stage.create;
            _error = l.pinMismatch;
          });
          return;
        }
        await auth.setPin(_entry);
        if (!mounted) return;
        Navigator.of(context)
            .pushNamedAndRemoveUntil(Routes.home, (_) => false);
      case _Stage.verify:
        if (!auth.checkPin(_entry)) {
          setState(() {
            _entry = '';
            _error = l.pinWrong;
          });
          return;
        }
        auth.unlock();
        if (!mounted) return;
        Navigator.of(context)
            .pushNamedAndRemoveUntil(Routes.home, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final title = switch (_stage) {
      _Stage.create => l.setPinTitle,
      _Stage.confirm => l.confirmPinTitle,
      _Stage.verify => l.enterPinTitle,
    };
    final body = switch (_stage) {
      _Stage.create => l.setPinBody,
      _Stage.confirm => l.setPinBody,
      _Stage.verify => l.enterPinBody,
    };

    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(S.screen),
          child: Column(
            children: [
              const SizedBox(height: S.lg),
              const SetuLogo(size: 64),
              const SizedBox(height: S.lg),
              Text(title, style: T.h1, textAlign: TextAlign.center),
              const SizedBox(height: S.sm),
              Text(body, style: T.bodySoft, textAlign: TextAlign.center),
              const SizedBox(height: S.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _entry.length;
                  return Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.symmetric(horizontal: S.sm),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? C.teal : C.card,
                      border: Border.all(
                        color: filled ? C.teal : C.divider,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: S.md),
              SizedBox(
                height: 28,
                child: _error == null
                    ? null
                    : Text(
                        _error!,
                        style: T.body.copyWith(color: C.red, fontSize: 16),
                      ),
              ),
              const Spacer(),
              _Keypad(onDigit: _press, onBackspace: _backspace),
              const SizedBox(height: S.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// Deliberately big. She may be entering this one-handed in a doorway.
class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onBackspace});

  final void Function(String) onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget key(String label, {VoidCallback? onTap, IconData? icon}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(S.sm),
          child: Material(
            color: icon == null ? C.card : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap ?? () => onDigit(label),
              child: Container(
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: icon == null ? Border.all(color: C.divider) : null,
                ),
                child: icon == null
                    ? Text(label, style: T.h1.copyWith(fontSize: 30))
                    : Icon(icon, size: 30, color: C.textSoft),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(children: [key('1'), key('2'), key('3')]),
        Row(children: [key('4'), key('5'), key('6')]),
        Row(children: [key('7'), key('8'), key('9')]),
        Row(children: [
          const Expanded(child: SizedBox()),
          key('0'),
          key('', icon: Icons.backspace_outlined, onTap: onBackspace),
        ]),
      ],
    );
  }
}
