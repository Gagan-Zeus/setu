import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../routes.dart';
import '../theme/tokens.dart';

/// Red circular button, bottom-right, above everything. Implemented once here
/// and attached by [SetuScaffold], never repeated per screen.
class EmergencyFab extends StatelessWidget {
  const EmergencyFab({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: S.xs),
      child: Semantics(
        button: true,
        label: l.emergencyShort,
        child: SizedBox(
          height: 76,
          child: FloatingActionButton.extended(
            heroTag: 'setu-emergency-fab',
            backgroundColor: C.red,
            foregroundColor: C.onDark,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            onPressed: () => Navigator.of(context).pushNamed(Routes.emergency),
            icon: const Icon(Icons.emergency_share, size: 30),
            label: Text(
              l.emergencyShort,
              style: T.button.copyWith(color: C.onDark, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}

/// Every screen after login uses this. It guarantees the emergency button is
/// present and keeps page padding consistent.
class SetuScaffold extends StatelessWidget {
  const SetuScaffold({
    super.key,
    required this.body,
    this.title,
    this.showEmergencyButton = true,
    this.showBack = true,
    this.actions,
    this.backgroundColor = C.bg,
    this.bottom,
    this.bottomBar,
  });

  final Widget body;
  final String? title;
  final bool showEmergencyButton;
  final bool showBack;
  final List<Widget>? actions;
  final Color backgroundColor;
  final PreferredSizeWidget? bottom;

  /// Pinned to the bottom of the screen. The emergency button floats above
  /// it rather than on top of it, which is why the chat composer lives here.
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              automaticallyImplyLeading: showBack && canPop,
              actions: actions,
              bottom: bottom,
            ),
      body: SafeArea(top: title == null, child: body),
      bottomNavigationBar: bottomBar,
      floatingActionButton: showEmergencyButton ? const EmergencyFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// Bottom padding that keeps scrolling content clear of the emergency button.
const kFabClearance = SizedBox(height: 104);
