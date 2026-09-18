import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/access_requests.dart';
import '../data/models.dart';
import '../data/profile_photo_service.dart';
import '../l10n/app_localizations.dart';
import '../l10n/content.dart';
import '../providers.dart';
import '../routes.dart';
import '../theme/tokens.dart';
import '../widgets/big_action_button.dart';
import '../widgets/call_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/language_toggle.dart';
import '../widgets/setu_card.dart';
import '../widgets/setu_scaffold.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final motherAsync = ref.watch(motherProvider);

    return SetuScaffold(
      title: l.profileTitle,
      body: motherAsync.when(
        loading: () => const SkeletonList(count: 3),
        error: (_, __) => EmptyState(
          icon: Icons.cloud_off_outlined,
          message: l.errorTitle,
        ),
        data: (m) => ListView(
          padding: const EdgeInsets.all(S.screen),
          children: [
            const _PhotoCard(),
            const SizedBox(height: S.lg),
            SectionHeader(l.yourDetailsSection),
            _DetailsCard(mother: m),
            const SizedBox(height: S.md),
            _Note(icon: Icons.edit_off_outlined, text: l.detailsWrittenByAsha),
            const SizedBox(height: S.md),
            BigActionButton(
              label: l.reportMistake,
              icon: Icons.report_problem_outlined,
              outlined: true,
              background: C.terra,
              onPressed: () => Navigator.pushNamed(context, Routes.asha),
            ),
            const SizedBox(height: S.lg),
            SectionHeader(l.navAsha),
            CallButton(
              title: l.ashaName(m.asha),
              number: m.asha.phone,
              subtitle: l.subCentre(m.asha),
              onFailureMessage: l.callFailed,
            ),
            const SizedBox(height: S.lg),
            SectionHeader(l.settingsSection),
            SetuCard(
              padding: const EdgeInsets.all(S.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.languageLabel, style: T.label),
                  const SizedBox(height: S.sm),
                  const LanguageToggle(),
                  const Divider(height: S.lg),
                  // Kept here rather than at the foot of the screen: below
                  // the consent card it was effectively invisible.
                  BigActionButton(
                    label: l.logout,
                    icon: Icons.logout,
                    outlined: true,
                    onPressed: () => _signOut(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: S.lg),
            SectionHeader(l.accessSection),
            const _AccessCard(),
            const SizedBox(height: S.lg),
            SectionHeader(l.consentSection),
            const _ConsentCard(),
            kFabClearance,
          ],
        ),
      ),
    );
  }

  static Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    await ref.read(authControllerProvider.notifier).signOut();
    navigator.pushNamedAndRemoveUntil(Routes.login, (_) => false);
  }
}

// ------------------------------------------------------------------- photo

class _PhotoCard extends ConsumerWidget {
  const _PhotoCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final photo = ref.watch(profilePhotoProvider);
    final mother = ref.watch(motherProvider).valueOrNull;

    return SetuCard(
      padding: const EdgeInsets.all(S.lg),
      child: Column(
        children: [
          _Avatar(photo: photo, size: 132),
          const SizedBox(height: S.md),
          if (mother != null)
            Text(l.motherName(mother),
                style: T.h1, textAlign: TextAlign.center),
          const SizedBox(height: S.md),
          BigActionButton(
            label: photo.exists ? l.changePhoto : l.addPhoto,
            icon: photo.exists ? Icons.autorenew : Icons.add_a_photo_outlined,
            onPressed: () => _choose(context, ref),
          ),
          if (photo.exists) ...[
            const SizedBox(height: S.sm),
            TextButton.icon(
              onPressed: () async {
                await ref.read(profilePhotoProvider.notifier).remove();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.photoRemoved, style: T.body)),
                );
              },
              icon: const Icon(Icons.delete_outline, size: 24),
              label: Text(l.removePhoto),
              style: TextButton.styleFrom(foregroundColor: C.red),
            ),
          ],
          const SizedBox(height: S.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 18, color: C.textSoft),
              const SizedBox(width: S.xs),
              Flexible(
                child: Text(
                  l.photoPrivacyNote,
                  style: T.label.copyWith(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Two big options, icon and text on each. No icon-only choices.
  Future<void> _choose(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      backgroundColor: C.bg,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(S.lg)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(S.screen, 0, S.screen, S.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.photoSectionLabel, style: T.label),
              const SizedBox(height: S.md),
              BigActionButton(
                label: l.takePhoto,
                icon: Icons.photo_camera_outlined,
                onPressed: () =>
                    Navigator.of(sheetContext).pop(PhotoSource.camera),
              ),
              const SizedBox(height: S.md),
              BigActionButton(
                label: l.chooseFromGallery,
                icon: Icons.photo_library_outlined,
                outlined: true,
                onPressed: () =>
                    Navigator.of(sheetContext).pop(PhotoSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !context.mounted) return;

    try {
      await ref.read(profilePhotoProvider.notifier).pick(source);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.photoFailed, style: T.body)),
      );
    }
  }
}

/// Her photo, or a quiet placeholder. Used here and on the Home header.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.photo, this.size = 56});

  final ProfilePhoto photo;
  final double size;

  @override
  Widget build(BuildContext context) {
    final file = photo.file;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: C.tealSoft,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: file == null
          ? Icon(Icons.person, size: size * 0.56, color: C.teal)
          : Image.file(
              file,
              key: ValueKey(photo.version),
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.person, size: size * 0.56, color: C.teal),
            ),
    );
  }
}

// ----------------------------------------------------------------- details

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.mother});

  final Mother mother;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final m = mother;
    return SetuCard(
      padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: S.sm),
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
          DetailRow(label: l.fieldCardNumber, value: m.thayiCardNumber),
          const Divider(height: 1),
          // The health centre was missing everywhere except Emergency.
          DetailRow(label: l.fieldPhc, value: l.centreName(m.phc)),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------- consent

class _ConsentCard extends ConsumerWidget {
  const _ConsentCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);

    return SetuCard(
      padding: const EdgeInsets.all(S.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined,
                  size: 26, color: C.green),
              const SizedBox(width: S.sm),
              Expanded(
                child: Text(
                  auth.consentAt == null
                      ? l.consentNotRecorded
                      : l.consentGivenOn(l.formatDate(auth.consentAt!)),
                  style: T.body,
                ),
              ),
            ],
          ),
          const SizedBox(height: S.md),
          Text(l.consentWithdrawBody, style: T.bodySoft),
          const SizedBox(height: S.md),
          BigActionButton(
            label: l.withdrawConsent,
            icon: Icons.lock_open_outlined,
            outlined: true,
            background: C.red,
            onPressed: () => _withdraw(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(S.radius),
        ),
        title: Text(l.withdrawConsentTitle, style: T.h2),
        content: Text(l.withdrawConsentBody, style: T.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: C.red,
              minimumSize: const Size(140, S.tapMin),
            ),
            child: Text(l.withdrawConsentConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // Her photo is hers: withdrawing consent takes it off the phone too.
    await ref.read(profilePhotoProvider.notifier).remove();
    await ref.read(authControllerProvider.notifier).withdrawConsent();
    navigator.pushNamedAndRemoveUntil(Routes.login, (_) => false);
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(S.md),
      decoration: BoxDecoration(
        color: C.tealSoft,
        borderRadius: BorderRadius.circular(S.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: C.teal),
          const SizedBox(width: S.sm),
          Expanded(
            child: Text(text, style: T.bodySoft.copyWith(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

/// Small circular avatar for the Home header.
class ProfileAvatarButton extends ConsumerWidget {
  const ProfileAvatarButton({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final photo = ref.watch(profilePhotoProvider);

    return Semantics(
      button: true,
      label: l.navProfile,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.pushNamed(context, Routes.profile),
        child: Padding(
          padding: const EdgeInsets.all(S.xs),
          child: _Avatar(photo: photo, size: size),
        ),
      ),
    );
  }
}

/// Who may open her record. A doctor gets in only if she says yes here, or if
/// she showed her QR card at the hospital — presenting it is the consent.
class _AccessCard extends ConsumerWidget {
  const _AccessCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(myAccessGrantsProvider);
    final grants = async.valueOrNull ?? const <AccessGrant>[];
    final pending = grants.where((g) => g.isPending).toList();
    final active = grants.where((g) => g.isActive).toList();

    Future<void> decide(AccessGrant g, bool approve) async {
      final messenger = ScaffoldMessenger.of(context);
      await ref.read(accessRequestsProvider).decide(g.id, approve: approve);
      ref.invalidate(myAccessGrantsProvider);
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: approve ? C.green : C.ink,
          content: Text(
            approve
                ? l.accessApproved(g.doctorName)
                : l.accessRejected(g.doctorName),
            style: T.body.copyWith(color: C.onDark),
          ),
        ),
      );
    }

    return SetuCard(
      padding: const EdgeInsets.all(S.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.accessExplain, style: T.bodySoft),
          if (pending.isEmpty && active.isEmpty) ...[
            const SizedBox(height: S.md),
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 22, color: C.green),
                const SizedBox(width: S.sm),
                Expanded(child: Text(l.accessNone, style: T.body)),
              ],
            ),
          ],
          for (final g in pending) ...[
            const Divider(height: S.lg),
            Text(l.accessRequestFrom(g.doctorName), style: T.h2),
            if (g.reason != null && g.reason!.isNotEmpty) ...[
              const SizedBox(height: S.xs),
              Text(l.accessRequestReason(g.reason!), style: T.bodySoft),
            ],
            const SizedBox(height: S.md),
            Row(
              children: [
                Expanded(
                  child: BigActionButton(
                    label: l.accessApprove,
                    icon: Icons.check,
                    onPressed: () => decide(g, true),
                  ),
                ),
                const SizedBox(width: S.sm),
                Expanded(
                  child: BigActionButton(
                    label: l.accessReject,
                    icon: Icons.close,
                    outlined: true,
                    background: C.red,
                    onPressed: () => decide(g, false),
                  ),
                ),
              ],
            ),
          ],
          for (final g in active) ...[
            const Divider(height: S.lg),
            Row(
              children: [
                const Icon(Icons.visibility_outlined, size: 22, color: C.amber),
                const SizedBox(width: S.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g.doctorName,
                          style: T.body.copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        g.grantedByQr ? l.accessByQr : l.accessActiveTitle,
                        style: T.label.copyWith(fontSize: 14),
                      ),
                      if (g.expiresAt != null)
                        Text(l.accessActiveUntil(l.formatDate(g.expiresAt!)),
                            style: T.label.copyWith(fontSize: 14)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => decide(g, false),
                  style: TextButton.styleFrom(foregroundColor: C.red),
                  child: Text(l.accessRevoke),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
