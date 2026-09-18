import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../l10n/app_localizations.dart';
import '../l10n/content.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/empty_state.dart';
import '../widgets/setu_card.dart';
import '../widgets/setu_scaffold.dart';

class ThayiCardScreen extends ConsumerWidget {
  const ThayiCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final motherAsync = ref.watch(motherProvider);
    final qrSize = MediaQuery.of(context).size.width * 0.6;

    return SetuScaffold(
      title: l.thayiCardTitle,
      body: motherAsync.when(
        loading: () => const SkeletonList(count: 2),
        error: (_, __) => EmptyState(
          icon: Icons.cloud_off_outlined,
          message: l.errorTitle,
        ),
        data: (m) => ListView(
          padding: const EdgeInsets.all(S.screen),
          children: [
            SetuCard(
              padding:
                  const EdgeInsets.symmetric(vertical: S.lg, horizontal: S.md),
              child: Column(
                children: [
                  // Only the id and the token are encoded. Never her name,
                  // her phone number, or anything clinical.
                  QrImageView(
                    data: m.qrPayload,
                    version: QrVersions.auto,
                    size: qrSize,
                    backgroundColor: C.card,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: C.ink,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: C.ink,
                    ),
                  ),
                  const SizedBox(height: S.lg),
                  Text(
                    l.qrCaption,
                    style: T.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: S.md),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.offline_pin_outlined,
                          size: 22, color: C.green),
                      const SizedBox(width: S.xs),
                      Text(
                        l.worksOffline,
                        style: T.label.copyWith(color: C.green, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: S.md),
            SetuCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: S.md, vertical: S.sm),
              child: Column(
                children: [
                  DetailRow(label: l.fieldName, value: l.motherName(m)),
                  const Divider(height: 1),
                  DetailRow(label: l.fieldAge, value: l.ageYears(m.age)),
                  const Divider(height: 1),
                  DetailRow(label: l.fieldGuardian, value: l.guardian(m)),
                  const Divider(height: 1),
                  DetailRow(
                    label: l.fieldVillage,
                    value: '${l.village(m)}, ${l.district(m)}',
                  ),
                  const Divider(height: 1),
                  DetailRow(label: l.fieldBloodGroup, value: m.bloodGroup),
                  const Divider(height: 1),
                  DetailRow(label: l.fieldEdd, value: l.formatDate(m.edd)),
                  const Divider(height: 1),
                  DetailRow(
                    label: l.fieldCardNumber,
                    value: m.thayiCardNumber,
                  ),
                  const Divider(height: 1),
                  DetailRow(
                    label: l.fieldAsha,
                    value: l.ashaName(m.asha),
                  ),
                ],
              ),
            ),
            kFabClearance,
          ],
        ),
      ),
    );
  }
}
