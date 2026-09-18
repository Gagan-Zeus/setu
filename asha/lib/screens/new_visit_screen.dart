import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../db/database.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../risk/risk_engine.dart';
import '../theme/tokens.dart';
import '../widgets/asha_scaffold.dart';
import '../widgets/big_action_button.dart';
import '../widgets/setu_card.dart';
import 'risk_alert_screen.dart';

/// The most-used screen in the app. One field group per card, big numeric
/// keypads, a live risk banner pinned to the bottom, and a save that writes to
/// SQLite and returns instantly.
class NewVisitScreen extends ConsumerStatefulWidget {
  const NewVisitScreen({super.key, required this.mother, this.closesTaskId});

  final Mother mother;
  final String? closesTaskId;

  @override
  ConsumerState<NewVisitScreen> createState() => _NewVisitScreenState();
}

class _NewVisitScreenState extends ConsumerState<NewVisitScreen> {
  final _sys = TextEditingController();
  final _dia = TextEditingController();
  final _weight = TextEditingController();
  final _fundal = TextEditingController();
  final _hb = TextEditingController();
  final _fetalHr = TextEditingController();
  final _notes = TextEditingController();

  String _albumin = 'nil';
  bool _fetalMovement = true;
  bool _ifa = false;
  bool _calcium = false;
  int? _ttDose;
  final Set<String> _dangerSigns = {};
  final List<String> _photos = [];
  bool _saving = false;

  static const _dangerSignIds = [
    'bleeding',
    'headache',
    'vision',
    'swelling',
    'fever',
    'convulsions',
    'noMovement',
  ];

  @override
  void initState() {
    super.initState();
    for (final c in [_sys, _dia, _weight, _fundal, _hb, _fetalHr]) {
      c.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    for (final c in [_sys, _dia, _weight, _fundal, _hb, _fetalHr, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onChanged() => setState(() {});

  int? get _sysValue => int.tryParse(_sys.text);
  int? get _diaValue => int.tryParse(_dia.text);
  double? get _hbValue => double.tryParse(_hb.text);
  double? get _weightValue => double.tryParse(_weight.text);

  RiskProfile get _profile => RiskProfile(
        age: widget.mother.age,
        gravida: widget.mother.gravida,
        prevComplications: decodeIds(widget.mother.prevComplications),
        lmp: widget.mother.lmp,
      );

  List<RiskAlert> _currentAlerts(RiskEngine? engine) {
    if (engine == null) return const [];
    return engine.evaluateVisit(
      RiskInput(
        bpSys: _sysValue,
        bpDia: _diaValue,
        hb: _hbValue,
        weightKg: _weightValue,
        dangerSigns: _dangerSigns.toList(),
      ),
      _profile,
    );
  }

  /// Silent, best-effort, and never blocking. Rural GPS genuinely fails.
  Future<(double?, double?)> _tryLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return (null, null);
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return (null, null);
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 6),
        ),
      );
      return (pos.latitude, pos.longitude);
    } catch (_) {
      return (null, null);
    }
  }

  /// A typo in a BP reading is dangerous. Anything implausible gets a
  /// confirmation rather than being silently accepted.
  Future<bool> _confirmOutliers(AppLocalizations l) async {
    final suspicious = <String>[];
    if (_sysValue != null && !PlausibleRange.bpSys(_sysValue!)) {
      suspicious.add('${l.bpSys} ${_sysValue!}');
    }
    if (_diaValue != null && !PlausibleRange.bpDia(_diaValue!)) {
      suspicious.add('${l.bpDia} ${_diaValue!}');
    }
    if (_sysValue != null && _diaValue != null) {
      // Also implausible as a pair, even if each is individually in range.
      if (_sysValue! <= _diaValue!) {
        suspicious.add('${_sysValue!}/${_diaValue!}');
      }
    }
    if (_weightValue != null && !PlausibleRange.weight(_weightValue!)) {
      suspicious.add('${l.weightKgLabel} ${_weightValue!}');
    }
    if (_hbValue != null && !PlausibleRange.hb(_hbValue!)) {
      suspicious.add('${l.hbLabel} ${_hbValue!}');
    }
    if (suspicious.isEmpty) return true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(S.radius),
        ),
        title: Text(l.rangeConfirmTitle, style: T.h2),
        content: Text(
          l.rangeConfirmBody(suspicious.join(', ')),
          style: T.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.rangeNo),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              minimumSize: const Size(140, S.tapMin),
            ),
            child: Text(l.rangeYes),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _save(AppLocalizations l, RiskEngine? engine) async {
    if (_saving) return;
    if (!await _confirmOutliers(l)) return;
    if (!mounted) return;

    setState(() => _saving = true);

    final db = ref.read(dbProvider);
    final last = await db.lastVisit(widget.mother.id);
    final visitNo = (last?.visitNo ?? 0) + 1;
    final (lat, lng) = await _tryLocation();

    final repo = ref.read(visitRepositoryProvider);
    final visitId = await repo.saveVisit(
      motherId: widget.mother.id,
      visitNo: visitNo,
      recordedBy: ref.read(authControllerProvider).name ?? '',
      bpSys: _sysValue,
      bpDia: _diaValue,
      weightKg: _weightValue,
      fundalHeightCm: double.tryParse(_fundal.text),
      hb: _hbValue,
      urineAlbumin: _albumin,
      fetalHr: int.tryParse(_fetalHr.text),
      fetalMovement: _fetalMovement,
      dangerSigns: _dangerSigns.toList(),
      ifaTaken: _ifa,
      calciumTaken: _calcium,
      ttDoseGiven: _ttDose,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      gpsLat: lat,
      gpsLng: lng,
      photoPaths: _photos,
    );

    final alerts = _currentAlerts(engine);
    await repo.saveAlerts(widget.mother.id, visitId, alerts);
    if (widget.closesTaskId != null) {
      await repo.closeTask(widget.closesTaskId!, visitId: visitId);
    }

    if (!mounted) return;
    setState(() => _saving = false);

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: C.green,
        content: Text(
          lat == null ? l.gpsUnavailable : l.visitSaved,
          style: T.body.copyWith(color: C.onDark),
        ),
      ),
    );

    // Red rules interrupt before she can move on.
    if (alerts.any((a) => a.isRed)) {
      await RiskAlertScreen.show(
        context,
        motherId: widget.mother.id,
        motherName: widget.mother.name,
        alerts: alerts,
        visitId: visitId,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final engine = ref.watch(riskEngineProvider).valueOrNull;
    final alerts = _currentAlerts(engine);

    return AshaScaffold(
      title: widget.mother.name,
      showBanner: false,
      bottomBar: _RiskBanner(alerts: alerts),
      body: ListView(
        padding: const EdgeInsets.all(S.screen),
        children: [
          _Group(
            title: l.sectionBp,
            child: Row(
              children: [
                Expanded(
                  child: _NumberField(
                    controller: _sys,
                    label: l.bpSys,
                    maxLength: 3,
                  ),
                ),
                const SizedBox(width: S.md),
                Expanded(
                  child: _NumberField(
                    controller: _dia,
                    label: l.bpDia,
                    maxLength: 3,
                  ),
                ),
              ],
            ),
          ),
          _Group(
            title: l.sectionMeasure,
            child: Row(
              children: [
                Expanded(
                  child: _NumberField(
                    controller: _weight,
                    label: l.weightKgLabel,
                    decimal: true,
                  ),
                ),
                const SizedBox(width: S.md),
                Expanded(
                  child: _NumberField(
                    controller: _fundal,
                    label: l.fundalHeightLabel,
                    decimal: true,
                  ),
                ),
              ],
            ),
          ),
          _Group(
            title: l.sectionLab,
            child: Column(
              children: [
                _NumberField(
                  controller: _hb,
                  label: l.hbLabel,
                  decimal: true,
                ),
                const SizedBox(height: S.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l.urineAlbuminLabel, style: T.label),
                ),
                const SizedBox(height: S.sm),
                Wrap(
                  spacing: S.sm,
                  children: [
                    for (final entry in {
                      'nil': l.albuminNil,
                      'trace': l.albuminTrace,
                      'plus1': l.albuminPlus1,
                      'plus2': l.albuminPlus2,
                    }.entries)
                      ChoiceChip(
                        label: Text(entry.value, style: T.body),
                        selected: _albumin == entry.key,
                        onSelected: (_) => setState(() => _albumin = entry.key),
                        selectedColor: C.tealSoft,
                        labelStyle: T.body,
                        padding: const EdgeInsets.symmetric(
                            horizontal: S.sm, vertical: S.sm),
                      ),
                  ],
                ),
              ],
            ),
          ),
          _Group(
            title: l.sectionFetal,
            child: Column(
              children: [
                _NumberField(
                  controller: _fetalHr,
                  label: l.fetalHrLabel,
                  maxLength: 3,
                ),
                const SizedBox(height: S.sm),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _fetalMovement,
                  onChanged: (v) => setState(() {
                    _fetalMovement = v;
                    // Keep the danger sign and this switch in step, so the
                    // risk banner cannot disagree with the form.
                    if (v) {
                      _dangerSigns.remove('noMovement');
                    } else {
                      _dangerSigns.add('noMovement');
                    }
                  }),
                  activeThumbColor: C.teal,
                  title: Text(l.fetalMovementLabel, style: T.body),
                ),
              ],
            ),
          ),
          _Group(
            title: l.sectionDanger,
            child: Column(
              children: [
                for (final id in _dangerSignIds)
                  _DangerCheck(
                    label: _dangerLabel(l, id),
                    checked: _dangerSigns.contains(id),
                    onChanged: (v) => setState(() {
                      if (v) {
                        _dangerSigns.add(id);
                        if (id == 'noMovement') _fetalMovement = false;
                      } else {
                        _dangerSigns.remove(id);
                        if (id == 'noMovement') _fetalMovement = true;
                      }
                    }),
                  ),
              ],
            ),
          ),
          _Group(
            title: l.sectionTablets,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _ifa,
                  onChanged: (v) => setState(() => _ifa = v),
                  activeThumbColor: C.teal,
                  title: Text(l.ifaTakenLabel, style: T.body),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _calcium,
                  onChanged: (v) => setState(() => _calcium = v),
                  activeThumbColor: C.teal,
                  title: Text(l.calciumTakenLabel, style: T.body),
                ),
                const SizedBox(height: S.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l.ttDoseLabel, style: T.label),
                ),
                const SizedBox(height: S.sm),
                Wrap(
                  spacing: S.sm,
                  children: [
                    ChoiceChip(
                      label: Text(l.ttNone, style: T.body),
                      selected: _ttDose == null,
                      selectedColor: C.tealSoft,
                      onSelected: (_) => setState(() => _ttDose = null),
                    ),
                    for (final dose in [1, 2])
                      ChoiceChip(
                        label: Text('$dose', style: T.body),
                        selected: _ttDose == dose,
                        selectedColor: C.tealSoft,
                        onSelected: (_) => setState(() => _ttDose = dose),
                      ),
                  ],
                ),
              ],
            ),
          ),
          _Group(
            title: l.sectionNotes,
            child: Column(
              children: [
                TextField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 5,
                  style: T.body,
                  decoration: InputDecoration(hintText: l.notesHint),
                ),
                const SizedBox(height: S.md),
                BigActionButton(
                  label: _photos.isEmpty ? l.addPhoto : l.photoAdded,
                  icon: Icons.photo_camera_outlined,
                  outlined: true,
                  onPressed: _pickPhoto,
                ),
              ],
            ),
          ),
          const SizedBox(height: S.md),
          BigActionButton(
            label: l.saveVisit,
            icon: Icons.check_circle_outline,
            onPressed: _saving ? null : () => _save(l, engine),
          ),
          const SizedBox(height: S.xl),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1400,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _photos.add(picked.path));
  }

  String _dangerLabel(AppLocalizations l, String id) => switch (id) {
        'bleeding' => l.dsBleeding,
        'headache' => l.dsHeadache,
        'vision' => l.dsVision,
        'swelling' => l.dsSwelling,
        'fever' => l.dsFever,
        'convulsions' => l.dsConvulsions,
        _ => l.dsNoMovement,
      };
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: S.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title),
          SetuCard(padding: const EdgeInsets.all(S.md), child: child),
        ],
      ),
    );
  }
}

/// Big numeric keypad, 18sp+ text. She is entering this one-handed.
class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    this.decimal = false,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final bool decimal;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      textAlign: TextAlign.center,
      maxLength: maxLength,
      style: T.h1.copyWith(fontSize: 30),
      inputFormatters: [
        if (decimal)
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        contentPadding:
            const EdgeInsets.symmetric(vertical: S.md, horizontal: S.sm),
      ),
    );
  }
}

class _DangerCheck extends StatelessWidget {
  const _DangerCheck({
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: checked ? C.redSoft : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(!checked),
        child: Container(
          constraints: const BoxConstraints(minHeight: S.tapMin),
          padding: const EdgeInsets.symmetric(horizontal: S.sm),
          child: Row(
            children: [
              Icon(
                checked ? Icons.check_box : Icons.check_box_outline_blank,
                size: 32,
                color: checked ? C.red : C.textSoft,
              ),
              const SizedBox(width: S.sm),
              Expanded(
                child: Text(
                  label,
                  style: T.body.copyWith(color: checked ? C.red : C.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pinned to the bottom, updates as she types. This is what makes the risk
/// engine feel live rather than something that happens after saving.
class _RiskBanner extends StatelessWidget {
  const _RiskBanner({required this.alerts});

  final List<RiskAlert> alerts;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isKn = l.localeName.startsWith('kn');

    final worst = alerts.isEmpty ? null : alerts.first;
    final (bg, fg, icon) = switch (worst?.severity) {
      Severity.red => (C.red, C.onDark, Icons.error_outline),
      Severity.amber => (C.amberSoft, C.amber, Icons.warning_amber_rounded),
      _ => (C.greenSoft, C.green, Icons.check_circle_outline),
    };

    return Material(
      color: bg,
      child: SafeArea(
        top: false,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding:
              const EdgeInsets.symmetric(horizontal: S.screen, vertical: S.sm),
          child: Row(
            children: [
              Icon(icon, size: 28, color: fg),
              const SizedBox(width: S.sm),
              Expanded(
                child: Text(
                  worst == null
                      ? l.riskBannerNormal
                      : (isKn ? worst.messageKn : worst.messageEn),
                  style: T.body.copyWith(color: fg, fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
