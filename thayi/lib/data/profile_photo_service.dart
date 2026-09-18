import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PhotoSource { camera, gallery }

/// Her profile photo.
///
/// The file is kept on the phone, in the app's own documents directory. That
/// is deliberate: it works with no signal, it costs her no data, and a
/// photograph of a pregnant woman is not something to upload anywhere by
/// default. [uploadPending] is the hook for syncing it to Supabase Storage
/// once she has a real session and has been asked.
class ProfilePhotoService {
  ProfilePhotoService(this._prefs);

  static const _pathKey = 'profile_photo_path';
  static const _fileName = 'profile_photo.jpg';

  final SharedPreferences _prefs;
  final ImagePicker _picker = ImagePicker();

  /// The saved photo, or null if she has not added one.
  File? currentPhoto() {
    final path = _prefs.getString(_pathKey);
    if (path == null) return null;
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  /// Opens the camera or the system photo picker, then copies the result into
  /// the app's own directory so it survives the picker's temp files being
  /// cleaned up. Returns null if she backed out.
  Future<File?> pick(PhotoSource source) async {
    final picked = await _picker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      // A profile photo never needs to be bigger than this, and a low-end
      // phone should not be moving 8 megapixel files around.
      maxWidth: 900,
      maxHeight: 900,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final target = File('${dir.path}/$_fileName');

    // Write via a temp file so a failure part-way through cannot leave her
    // with a half-written photo and no original.
    final temp = File('${dir.path}/$_fileName.tmp');
    await temp.writeAsBytes(await picked.readAsBytes(), flush: true);
    if (await target.exists()) await target.delete();
    await temp.rename(target.path);

    await _prefs.setString(_pathKey, target.path);
    return target;
  }

  Future<void> remove() async {
    final path = _prefs.getString(_pathKey);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    await _prefs.remove(_pathKey);
  }

  /// True when there is a local photo that has not been copied to the
  /// backend yet. Nothing uploads until she is signed in and has agreed.
  bool get uploadPending => currentPhoto() != null;
}
