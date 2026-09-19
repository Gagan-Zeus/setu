import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers.dart';
import '../theme/tokens.dart';
import '../widgets/care_widgets.dart';

/// A photograph of the paper prescription written at the visit.
///
/// The prescription she is handed is a sheet of paper that gets lost between
/// the clinic and the chemist. Photographing it at the counter means she still
/// has it later, and so does whoever sees her next.
class PrescriptionCapture {
  PrescriptionCapture._();

  static const bucket = 'prescriptions';

  /// Camera by default: the paper is on the desk right now. Gallery is there
  /// for a photo already taken.
  ///
  /// There is deliberately no doctorName parameter. It had one, and the only
  /// caller filled it with MockData.doctorName — so every prescription
  /// photographed on a real handset was filed in the real database as
  /// prescribed by an invented doctor. Her name is resolved here, from the same
  /// provider every other writer uses, where no caller can substitute a
  /// constant.
  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required String motherId,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: C.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(S.radius)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(S.md, S.md, S.md, S.sm),
              child: SectionLabel('Prescription'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, size: 20),
              title: const Text('Photograph the prescription', style: T.body),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, size: 20),
              title: const Text('Choose a photo', style: T.body),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            const SizedBox(height: S.sm),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      // Large enough that handwriting stays legible, small enough to upload
      // over a clinic connection.
      maxWidth: 1800,
      imageQuality: 85,
    );
    if (picked == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final note = await _askForNote(context);
    if (!context.mounted) return;

    messenger.showSnackBar(
      const SnackBar(content: Text('Saving prescription…')),
    );

    try {
      await _upload(
        ref,
        motherId: motherId,
        file: File(picked.path),
        note: note,
      );
      ref.invalidate(prescriptionsProvider(motherId));
      messenger.showSnackBar(
        const SnackBar(content: Text('Prescription saved to her record')),
      );
    } catch (error) {
      // 42501 is Row Level Security refusing the write, and for a doctor that
      // means one thing: she has no access to this mother. Reporting it as a
      // connection problem sends her to look in the wrong place — the same
      // misdirection the assign-task sheet already corrects.
      //
      // The image goes to Storage before the row goes to the table, so when
      // she has no access it is Storage that refuses first — a
      // StorageException carrying a 403, not a PostgrestException carrying
      // 42501. Recognising only the second one leaves the misdirection exactly
      // where it was, because the insert is never reached.
      final refused = _isRefusal(error);
      messenger.showSnackBar(
        SnackBar(
          content: Text(refused
              ? 'She has not given you access yet, so it was not saved. Ask '
                  'her, or scan her Thayi Card if she is with you.'
              : 'Could not save it. Check the connection and retry.'),
        ),
      );
    }
  }

  /// True when the backend refused the write for want of access, whichever
  /// leg refused it: Storage answers 403, PostgREST answers 42501.
  static bool _isRefusal(Object error) {
    if (error is PostgrestException) {
      return error.code == '42501' ||
          error.message.contains('row-level security');
    }
    if (error is StorageException) {
      return error.statusCode == '403' ||
          error.statusCode == '42501' ||
          error.message.contains('row-level security');
    }
    return false;
  }

  static Future<String?> _askForNote(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(S.radius),
        ),
        title: const Text('Add a note', style: T.h2),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: T.body,
          decoration: const InputDecoration(
            hintText: 'What was prescribed, in a few words',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            style:
                FilledButton.styleFrom(minimumSize: const Size(110, S.tapMin)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  static Future<void> _upload(
    WidgetRef ref, {
    required String motherId,
    required File file,
    String? note,
  }) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) {
      throw StateError('No connection');
    }

    // Null when her staff row could not be read. prescribed_by is nullable and
    // the timeline simply omits the byline, which is honest; a stand-in would
    // put a name on a prescription that nobody wrote.
    final prescribedBy = await ref.read(authorNameProvider.future);

    // Filed under her id, because the storage policy reads the folder name and
    // applies the same access rule as the rest of her record.
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$motherId/rx-$stamp.jpg';

    await client.storage.from(bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

    await client.from('prescriptions').insert({
      'mother_id': motherId,
      'storage_path': path,
      'note': (note == null || note.isEmpty) ? null : note,
      'prescribed_by': prescribedBy,
    });
  }
}

/// One prescription photo in her record.
class Prescription {
  const Prescription({
    required this.id,
    required this.storagePath,
    required this.takenAt,
    this.note,
    this.prescribedBy,
  });

  final String id;
  final String storagePath;
  final DateTime takenAt;
  final String? note;
  final String? prescribedBy;
}

final prescriptionsProvider =
    FutureProvider.family<List<Prescription>, String>((ref, motherId) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return const [];
  final rows = await client
      .from('prescriptions')
      .select()
      .eq('mother_id', motherId)
      .order('taken_at', ascending: false);
  return rows
      .map((r) => Prescription(
            id: r['id'] as String,
            storagePath: r['storage_path'] as String,
            takenAt:
                DateTime.tryParse(r['taken_at'].toString()) ?? DateTime.now(),
            note: r['note'] as String?,
            prescribedBy: r['prescribed_by'] as String?,
          ))
      .toList();
});

/// The bucket is private, so images are fetched through a short-lived signed
/// URL rather than a public link that could be forwarded.
final prescriptionUrlProvider =
    FutureProvider.family<String?, String>((ref, path) async {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  try {
    return await client.storage
        .from(PrescriptionCapture.bucket)
        .createSignedUrl(path, 60 * 60);
  } catch (_) {
    return null;
  }
});
