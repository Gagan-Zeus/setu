import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../theme/tokens.dart';

/// ಕನ್ನಡ / English. Prominent, and it works before login.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = ref.watch(localeControllerProvider);
    final controller = ref.read(localeControllerProvider.notifier);

    Widget option(String label, String code) {
      final selected = locale.languageCode == code;
      return Expanded(
        child: Material(
          color: selected ? C.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => controller.set(Locale(code)),
            child: Container(
              height: compact ? 48 : S.tapMin,
              alignment: Alignment.center,
              child: Text(
                label,
                style: T.button.copyWith(
                  color: selected ? C.onDark : C.textSoft,
                  fontSize: compact ? 17 : 19,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(S.xs),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.divider),
      ),
      child: Row(
        children: [
          option(l.langKannada, 'kn'),
          option(l.langEnglish, 'en'),
        ],
      ),
    );
  }
}
