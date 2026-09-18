import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/tokens.dart';

/// Opens the dialler with the number filled in. ACTION_DIAL, so the app never
/// needs the CALL_PHONE permission and she always confirms the call herself.
Future<void> dial(BuildContext context, String number,
    {required String failureMessage}) async {
  final uri = Uri(scheme: 'tel', path: number);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(failureMessage, style: T.body)),
    );
  }
}

/// Terracotta button with a phone icon, a name and a number.
class CallButton extends StatelessWidget {
  const CallButton({
    super.key,
    required this.title,
    required this.number,
    this.subtitle,
    this.background = C.terra,
    this.onFailureMessage = '',
  });

  final String title;
  final String number;
  final String? subtitle;
  final Color background;
  final String onFailureMessage;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => dial(context, number, failureMessage: onFailureMessage),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: C.onDark.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.call, color: C.onDark, size: 26),
              ),
              const SizedBox(width: S.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: T.button.copyWith(color: C.onDark),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: T.label.copyWith(
                          color: C.onDark.withValues(alpha: 0.85),
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: C.onDark, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
