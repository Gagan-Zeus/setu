import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Icon plus one line. No screen is ever allowed to be blank.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(S.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: C.tealSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: C.teal),
            ),
            const SizedBox(height: S.md),
            Text(message, style: T.bodySoft, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: S.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Soft grey blocks shown while the repository is answering. Never a spinner
/// on a white screen - that reads as broken on a projector.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(S.radius),
        boxShadow: kCardShadow,
      ),
      padding: const EdgeInsets.all(S.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(width: 120, height: 14),
          const SizedBox(height: S.md),
          _bar(width: 200, height: 22),
          const Spacer(),
          _bar(width: double.infinity, height: 10),
        ],
      ),
    );
  }

  Widget _bar({required double width, required double height}) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: C.bg,
          borderRadius: BorderRadius.circular(6),
        ),
      );
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(S.screen),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: S.md),
      itemBuilder: (_, i) => SkeletonCard(height: i.isEven ? 130 : 100),
    );
  }
}
