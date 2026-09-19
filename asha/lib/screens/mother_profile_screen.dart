import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/home_location.dart';
import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../data/email_verification.dart';
import '../data/supabase_sync_service.dart';
import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/asha_scaffold.dart';
import '../widgets/empty_state.dart';
import '../widgets/line_chart.dart';
import '../widgets/risk_chip.dart';
import '../widgets/setu_card.dart';
import 'new_visit_screen.dart';

class MotherProfileScreen extends ConsumerWidget {
  const MotherProfileScreen({super.key, required this.motherId});

  final String motherId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final mother = ref.watch(motherProvider(motherId)).valueOrNull;

    if (mother == null) {
      return AshaScaffold(
        title: l.loading,
        body: const SkeletonList(),
      );
    }

    return DefaultTabController(
      length: 4,
      child: AshaScaffold(
        title: mother.name,
        showBanner: false,
        bottom: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(height: S.tapMin, text: l.profileTabTimeline),
            Tab(height: S.tapMin, text: l.profileTabVitals),
            Tab(height: S.tapMin, text: l.profileTabSchemes),
            Tab(height: S.tapMin, text: l.profileTabQr),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'new-visit',
          backgroundColor: C.teal,
          foregroundColor: C.onDark,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => NewVisitScreen(mother: mother),
            ),
          ),
          icon: const Icon(Icons.add, size: 28),
          label: Text(l.newVisit,
              style: T.button.copyWith(color: C.onDark, fontSize: 17)),
        ),
        body: Column(
          children: [
            _Header(mother: mother),
            Expanded(
              child: TabBarView(
                children: [
                  _Timeline(motherId: motherId),
                  _Vitals(motherId: motherId),
                  _Schemes(mother: mother),
                  _QrCard(mother: mother),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.mother});

  final Mother mother;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final weeks = gestationWeeks(mother.lmp);
    final days = gestationDays(mother.lmp);
    final (level, label) = switch (mother.riskLevel) {
      'red' => (RiskLevel.danger, l.riskRed),
      'amber' => (RiskLevel.caution, l.riskAmber),
      _ => (RiskLevel.normal, l.riskGreen),
    };

    return Container(
      width: double.infinity,
      color: C.bg,
      padding: const EdgeInsets.fromLTRB(S.screen, S.sm, S.screen, S.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${mother.name} · ${mother.age}',
                  style: T.h2,
                ),
              ),
              RiskChip(label: label, level: level),
            ],
          ),
          const SizedBox(height: S.sm),
          _HomeRow(mother: mother),
          const SizedBox(height: S.sm),
          _EmailRow(mother: mother),
          const SizedBox(height: S.sm),
          Wrap(
            spacing: S.md,
            runSpacing: S.xs,
            children: [
              _Fact(label: l.gaLabel(weeks, days)),
              _Fact(
                label:
                    '${l.eddLabel} ${DateFormat('d MMM', l.localeName).format(eddOf(mother.lmp))}',
              ),
              if (mother.bloodGroup != null)
                _Fact(label: '${l.bloodGroupLabel} ${mother.bloodGroup}'),
              _Fact(label: mother.village),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) =>
      Text(label, style: T.label.copyWith(fontSize: 15));
}

/// The heart of the product: one feed mixing visits, alerts and referrals,
/// each showing who recorded it. This is the thing that does not exist today.
class _Timeline extends ConsumerWidget {
  const _Timeline({required this.motherId});

  final String motherId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final visits = ref.watch(visitsProvider(motherId)).valueOrNull;
    final alerts = ref.watch(alertsProvider(motherId)).valueOrNull ?? const [];

    if (visits == null) return const SkeletonList();
    if (visits.isEmpty && alerts.isEmpty) {
      return EmptyState(
        icon: Icons.timeline_outlined,
        message: l.timelineEmpty,
      );
    }

    final entries = <_Entry>[
      for (final v in visits) _Entry(date: v.visitDate, visit: v),
      for (final a in alerts) _Entry(date: a.createdAt, alert: a),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return ListView.separated(
      padding: const EdgeInsets.all(S.screen),
      itemCount: entries.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: S.md),
      itemBuilder: (context, i) => i == entries.length
          ? kFabClearance
          : _TimelineTile(entry: entries[i]),
    );
  }
}

class _Entry {
  _Entry({required this.date, this.visit, this.alert});
  final DateTime date;
  final AncVisit? visit;
  final Alert? alert;
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.entry});

  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isKn = l.localeName.startsWith('kn');
    final date = DateFormat('d MMM yyyy', l.localeName).format(entry.date);

    if (entry.alert != null) {
      final a = entry.alert!;
      final red = a.severity == 'red';
      return SetuCard(
        color: red ? C.redSoft : C.amberSoft,
        padding: const EdgeInsets.all(S.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 24, color: red ? C.red : C.amber),
                const SizedBox(width: S.sm),
                Expanded(
                  child: Text(
                    '${l.entryAlert} · ${a.ruleId}',
                    style: T.label.copyWith(color: red ? C.red : C.amber),
                  ),
                ),
                Text(date, style: T.label.copyWith(fontSize: 14)),
              ],
            ),
            const SizedBox(height: S.sm),
            Text(isKn ? a.messageKn : a.messageEn, style: T.body),
          ],
        ),
      );
    }

    final v = entry.visit!;
    final signs = decodeIds(v.dangerSigns);

    return SetuCard(
      padding: const EdgeInsets.all(S.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_information_outlined,
                  size: 24, color: C.teal),
              const SizedBox(width: S.sm),
              Expanded(
                child: Text(
                  v.correctsId == null
                      ? '${l.entryVisit} · ${l.visitNumberLabel(v.visitNo)}'
                      : l.correctionOf(v.visitNo),
                  style: T.label.copyWith(color: C.teal),
                ),
              ),
              Text(date, style: T.label.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(height: S.sm),
          Wrap(
            spacing: S.lg,
            runSpacing: S.sm,
            children: [
              if (v.bpSys != null && v.bpDia != null)
                _Metric(label: l.vitalsBp, value: '${v.bpSys}/${v.bpDia}'),
              if (v.weightKg != null)
                _Metric(
                  label: l.vitalsWeight,
                  value: '${v.weightKg!.toStringAsFixed(1)} kg',
                ),
              if (v.hb != null)
                _Metric(
                  label: l.vitalsHb,
                  value: v.hb!.toStringAsFixed(1),
                ),
            ],
          ),
          if (signs.isNotEmpty) ...[
            const SizedBox(height: S.sm),
            Wrap(
              spacing: S.sm,
              runSpacing: S.xs,
              children: [
                for (final s in signs)
                  RiskChip(label: s, level: RiskLevel.danger),
              ],
            ),
          ],
          if (v.notes != null && v.notes!.isNotEmpty) ...[
            const SizedBox(height: S.sm),
            Text(v.notes!, style: T.bodySoft),
          ],
          const SizedBox(height: S.sm),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18, color: C.textSoft),
              const SizedBox(width: S.xs),
              Text(l.recordedBy(v.recordedBy),
                  style: T.label.copyWith(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: T.label.copyWith(fontSize: 13)),
        Text(value, style: T.h2),
      ],
    );
  }
}

class _Vitals extends ConsumerWidget {
  const _Vitals({required this.motherId});

  final String motherId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final visits = ref.watch(visitsProvider(motherId)).valueOrNull;
    if (visits == null) return const SkeletonList();

    final ordered = [...visits]
      ..sort((a, b) => a.visitDate.compareTo(b.visitDate));
    final labels = [
      for (final v in ordered)
        DateFormat('d MMM', l.localeName).format(v.visitDate)
    ];

    Widget chartCard(String title, List<ChartSeries> series) => Padding(
          padding: const EdgeInsets.only(bottom: S.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title),
              SetuCard(
                padding: const EdgeInsets.all(S.md),
                child: series.first.values.isEmpty
                    ? Text(l.chartNoData, style: T.bodySoft)
                    : SimpleLineChart(series: series, xLabels: labels),
              ),
            ],
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(S.screen),
      children: [
        chartCard(l.vitalsBp, [
          ChartSeries(
            values: [
              for (final v in ordered)
                if (v.bpSys != null) v.bpSys!.toDouble()
            ],
            color: C.terra,
            label: l.bpSys,
          ),
          ChartSeries(
            values: [
              for (final v in ordered)
                if (v.bpDia != null) v.bpDia!.toDouble()
            ],
            color: C.teal,
            label: l.bpDia,
          ),
        ]),
        chartCard(l.vitalsWeight, [
          ChartSeries(
            values: [
              for (final v in ordered)
                if (v.weightKg != null) v.weightKg!
            ],
            color: C.teal,
            label: l.vitalsWeight,
          ),
        ]),
        chartCard(l.vitalsHb, [
          ChartSeries(
            values: [
              for (final v in ordered)
                if (v.hb != null) v.hb!
            ],
            color: C.green,
            label: l.vitalsHb,
          ),
        ]),
        kFabClearance,
      ],
    );
  }
}

class _Schemes extends StatelessWidget {
  const _Schemes({required this.mother});

  final Mother mother;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // The same rules the Thayi app uses, over her profile fields.
    final entries = <(String, bool)>[
      (l.schemeThayiBhagya, mother.isBpl),
      (l.schemePmmvy, mother.para == 0),
      (l.schemeJsy, mother.isBpl),
      (l.schemePrasootiAraike, mother.isBpl && mother.gravida <= 2),
      (l.schemeMadilu, mother.isBpl),
      (l.schemeJssk, true),
    ];

    return ListView(
      padding: const EdgeInsets.all(S.screen),
      children: [
        for (final (name, eligible) in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: S.md),
            child: SetuCard(
              padding: const EdgeInsets.all(S.md),
              child: Row(
                children: [
                  Expanded(child: Text(name, style: T.h2)),
                  RiskChip(
                    label: eligible ? l.yes : l.no,
                    level: eligible ? RiskLevel.normal : RiskLevel.neutral,
                    icon: eligible ? Icons.check : Icons.remove,
                  ),
                ],
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(S.md),
          decoration: BoxDecoration(
            color: C.amberSoft,
            borderRadius: BorderRadius.circular(S.radius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 22, color: C.amber),
              const SizedBox(width: S.sm),
              Expanded(
                child: Text(l.schemesNote,
                    style: T.bodySoft.copyWith(fontSize: 16)),
              ),
            ],
          ),
        ),
        kFabClearance,
      ],
    );
  }
}

/// Her code is not here, and this says so rather than faking one.
///
/// This tab used to render a QR built from `mother.id.hashCode`. That was never
/// a token — nothing in the database would ever match it — so scanning it at a
/// facility was always going to be refused, and the ASHA would have had no way
/// to know why. A control that looks like it works and cannot is worse than no
/// control, because it fails in front of the person it was meant to help.
///
/// It could not be made to work either. Her code is now a short-lived token
/// minted for whoever holds her session, and a phone in someone else's hand
/// producing it would be her consent manufactured without her — the same reason
/// an administrator cannot mint one. Her holding out her own phone IS the
/// permission.
///
/// So this became the useful thing instead: where her code actually lives, and
/// what to do about it if she cannot get to it — which, in a house with one
/// shared handset, is the question an ASHA is actually going to be asked.
class _QrCard extends StatelessWidget {
  const _QrCard({required this.mother});

  final Mother mother;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final email = mother.email;

    return ListView(
      padding: const EdgeInsets.all(S.screen),
      children: [
        SetuCard(
          padding: const EdgeInsets.all(S.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 34, color: C.teal),
                  const SizedBox(width: S.sm),
                  Expanded(child: Text(l.qrOnHerPhone, style: T.h2)),
                ],
              ),
              const SizedBox(height: S.md),
              Text(l.qrWhyNotHere, style: T.bodySoft),
              const SizedBox(height: S.lg),
              if (email != null && email.trim().isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(S.md),
                  decoration: BoxDecoration(
                    color: C.tealSoft,
                    borderRadius: BorderRadius.circular(S.radius),
                  ),
                  child: Text(l.qrHelpSignIn(email), style: T.body),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(S.md),
                  decoration: BoxDecoration(
                    color: C.amberSoft,
                    borderRadius: BorderRadius.circular(S.radius),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 24, color: C.amber),
                      const SizedBox(width: S.sm),
                      Expanded(child: Text(l.qrNoEmail, style: T.body)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        kFabClearance,
      ],
    );
  }
}

/// Her house: navigate to it once pinned, or pin it on this visit.
///
/// Street View sits behind the directions button on purpose — coverage in
/// rural villages is close to nonexistent, so it is a nice-to-have, never the
/// way to find a house.
class _HomeRow extends ConsumerStatefulWidget {
  const _HomeRow({required this.mother});

  final Mother mother;

  @override
  ConsumerState<_HomeRow> createState() => _HomeRowState();
}

class _HomeRowState extends ConsumerState<_HomeRow> {
  bool _busy = false;

  Future<void> _pin() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    final at = await HomeLocation.capture();
    if (!mounted) return;
    setState(() => _busy = false);

    if (at == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.homeLocationFailed, style: T.body)),
      );
      return;
    }
    await ref.read(visitRepositoryProvider).setHomeLocation(
          motherId: widget.mother.id,
          lat: at.lat,
          lng: at.lng,
        );
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: C.green,
        content:
            Text(l.homeLocationSaved, style: T.body.copyWith(color: C.onDark)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final m = widget.mother;
    final lat = m.homeLat;
    final lng = m.homeLng;

    if (lat == null || lng == null) {
      return OutlinedButton.icon(
        onPressed: _busy ? null : _pin,
        icon: const Icon(Icons.my_location, size: 18),
        label: Text(_busy ? l.homeLocationBusy : l.homeLocationCapture),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(42),
          textStyle: T.button.copyWith(fontSize: 15),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () async {
              final ok = await HomeLocation.navigateTo(lat, lng, label: m.name);
              if (!context.mounted || ok) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(l.homeLocationOpenFailed, style: T.body)),
              );
            },
            icon: const Icon(Icons.directions, size: 18),
            label: Text(l.homeLocationDirections),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(42),
              textStyle: T.button.copyWith(fontSize: 15),
            ),
          ),
        ),
        const SizedBox(width: S.sm),
        IconButton(
          tooltip: l.homeLocationStreetView,
          onPressed: () async {
            final ok = await HomeLocation.streetView(lat, lng);
            if (!context.mounted || ok) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(l.homeLocationNoStreetView, style: T.body)),
            );
          },
          icon: const Icon(Icons.streetview, size: 20),
          style: IconButton.styleFrom(
            side: const BorderSide(color: C.divider),
            minimumSize: const Size(42, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(S.sm),
            ),
          ),
        ),
        const SizedBox(width: S.sm),
        IconButton(
          tooltip: l.homeLocationCapture,
          onPressed: _busy ? null : _pin,
          icon: const Icon(Icons.my_location, size: 20),
          style: IconButton.styleFrom(
            side: const BorderSide(color: C.divider),
            minimumSize: const Size(42, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(S.sm),
            ),
          ),
        ),
      ],
    );
  }
}

/// Her email, and whether it has been proved to reach her.
///
/// An address typed at a doorstep and never tested is the quietest way for a
/// mother to lose access to her own record: nothing fails until she tries to
/// sign in, weeks later, with the worker long gone. Verifying sends her the
/// login code she will actually use and asks her to read it back.
///
/// Only offered when there is signal. Registration is offline-first and stays
/// that way; an unverified address is carried honestly instead of blocking the
/// visit.
class _EmailRow extends ConsumerStatefulWidget {
  const _EmailRow({required this.mother});

  final Mother mother;

  @override
  ConsumerState<_EmailRow> createState() => _EmailRowState();
}

class _EmailRowState extends ConsumerState<_EmailRow> {
  bool _busy = false;

  Future<void> _verify() async {
    final l = AppLocalizations.of(context);
    final email = widget.mother.email;
    if (email == null || email.isEmpty) return;

    final client = ref.read(supabaseClientProvider);
    if (client == null) return;

    setState(() => _busy = true);
    final verifier = EmailVerification(client);
    try {
      // Her record has to be on the server before the auth account is made:
      // auth_user_id is what RLS resolves her through, and an account created
      // against a row that is not there yet links to nothing. She would then
      // sign in successfully to an empty app, which is the worst of the
      // failures because it looks like it worked.
      await ref.read(syncWorkerProvider).drain();
      final serverId = SupabaseSyncService.uuidFor(widget.mother.id);
      final row = await client
          .from('mothers')
          .select('id')
          .eq('id', serverId)
          .maybeSingle();
      if (!mounted) return;
      if (row == null) {
        _say(l.emailVerifiedPending);
        return;
      }

      final sent = await verifier.sendCode(email);
      if (!mounted) return;
      if (sent != VerifyOutcome.sent) {
        _say(l.emailVerifyOffline);
        return;
      }

      final code = await _askForCode(email);
      if (code == null || !mounted) return;

      final result = await verifier.confirm(
        email: email,
        code: code,
        motherServerId: serverId,
      );
      if (!mounted) return;
      _say(switch (result) {
        VerifyOutcome.verified => l.emailVerifiedOk,
        VerifyOutcome.notSyncedYet => l.emailVerifiedPending,
        VerifyOutcome.wrongCode => l.emailVerifyWrongCode,
        _ => l.emailVerifyOffline,
      });
      // Both outcomes mean she received the code; the only difference is
      // whether her row has reached the server yet. Either way the local
      // record is now verified and the queued update will carry it up.
      if (result == VerifyOutcome.verified ||
          result == VerifyOutcome.notSyncedYet) {
        await ref
            .read(visitRepositoryProvider)
            .markEmailVerified(widget.mother.id);
        ref.invalidate(motherProvider(widget.mother.id));
      }
    } finally {
      await verifier.dispose();
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askForCode(String email) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final l = AppLocalizations.of(dialogContext);
        return AlertDialog(
          backgroundColor: C.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(S.radius),
          ),
          title: Text(l.emailVerifyTitle, style: T.h2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.emailVerifyBody(email), style: T.body),
              const SizedBox(height: S.md),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: T.h2,
                decoration: const InputDecoration(counterText: ''),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              style: FilledButton.styleFrom(
                minimumSize: const Size(120, S.tapMin),
              ),
              child: Text(l.emailVerifyConfirm),
            ),
          ],
        );
      },
    );
  }

  void _say(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: T.body)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final email = widget.mother.email;
    if (email == null || email.isEmpty) return const SizedBox.shrink();

    final verified = widget.mother.emailVerified;
    final online = ref.watch(connectivityProvider).valueOrNull ?? false;

    return Row(
      children: [
        Icon(
          verified ? Icons.mark_email_read_outlined : Icons.mail_outline,
          size: 20,
          color: verified ? C.green : C.textSoft,
        ),
        const SizedBox(width: S.xs),
        Expanded(
          child: Text(
            email,
            style: T.label.copyWith(color: C.textSoft),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (verified)
          Text(l.emailVerifiedChip,
              style:
                  T.label.copyWith(color: C.green, fontWeight: FontWeight.w600))
        else if (_busy)
          const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2))
        else if (online)
          TextButton(
            onPressed: _verify,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, S.tapMin),
              foregroundColor: C.teal,
            ),
            child: Text(l.emailVerifyAction),
          )
        else
          // No signal: say so plainly rather than showing a button that fails.
          Text(l.emailNotVerifiedOffline,
              style: T.label.copyWith(color: C.amber)),
      ],
    );
  }
}
