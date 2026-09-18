import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'sync_banner.dart';

/// Every signed-in screen. The sync banner sits above everything, because
/// knowing whether her work has left the phone matters on every screen.
class AshaScaffold extends StatelessWidget {
  const AshaScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottom,
    this.bottomBar,
    this.showBanner = true,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;
  final Widget? bottomBar;
  final bool showBanner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              actions: actions,
              bottom: bottom,
            ),
      body: SafeArea(
        top: title == null,
        child: Column(
          children: [
            if (showBanner) const SyncBanner(),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: bottomBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

const kFabClearance = SizedBox(height: 96);
