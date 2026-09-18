import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../routes.dart';
import '../../theme/tokens.dart';
import '../../widgets/big_action_button.dart';
import '../../widgets/setu_card.dart';

/// One question per screen. Her name is the only thing asked before an
/// account exists, and it is only used to greet her.
class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({super.key});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  late final TextEditingController _name =
      TextEditingController(text: ref.read(onboardingProvider).name ?? '');
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _next(AppLocalizations l) async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l.nameRequired);
      return;
    }
    await ref.read(onboardingProvider.notifier).setName(_name.text);
    if (!mounted) return;
    Navigator.pushNamed(context, Routes.onboardingLocation);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(S.screen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l.nameTitle, style: T.h1),
                      const SizedBox(height: S.sm),
                      Text(l.nameWhy, style: T.bodySoft),
                      const SizedBox(height: S.lg),
                      SetuCard(
                        padding: const EdgeInsets.all(S.lg),
                        child: TextField(
                          controller: _name,
                          autofocus: true,
                          textCapitalization: TextCapitalization.words,
                          style: T.body.copyWith(fontSize: 22),
                          onSubmitted: (_) => _next(l),
                          decoration: InputDecoration(
                            labelText: l.nameLabel,
                            hintText: l.nameHint,
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: S.md),
                        Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: C.red, size: 24),
                            const SizedBox(width: S.sm),
                            Expanded(
                              child: Text(_error!,
                                  style: T.body.copyWith(color: C.red)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(S.screen),
                child: BigActionButton(
                  label: l.continueLabel,
                  icon: Icons.arrow_forward,
                  onPressed: () => _next(l),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
