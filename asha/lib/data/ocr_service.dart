/// Reading a paper Thayi Card with the camera.
///
/// A Gemini Vision implementation drops in behind this interface later. The
/// contract that matters: OCR output is never saved silently. The caller must
/// show every extracted field back to the ASHA for confirmation.
library;

class OcrResult {
  const OcrResult({
    this.name,
    this.age,
    this.husbandName,
    this.phone,
    this.village,
    this.subCentre,
    this.abhaId,
    this.lmp,
    this.gravida,
    this.para,
    this.bloodGroup,
    this.heightCm,
    this.confidence = 0.0,
  });

  final String? name;
  final int? age;
  final String? husbandName;
  final String? phone;
  final String? village;
  final String? subCentre;
  final String? abhaId;
  final DateTime? lmp;
  final int? gravida;
  final int? para;
  final String? bloodGroup;
  final double? heightCm;

  /// 0..1. Shown to her so a poor scan is obvious before she confirms.
  final double confidence;
}

abstract class OcrService {
  Future<OcrResult> readThayiCard(String imagePath);
}

class MockOcrService implements OcrService {
  const MockOcrService({this.delay = const Duration(seconds: 2)});

  final Duration delay;

  @override
  Future<OcrResult> readThayiCard(String imagePath) async {
    await Future.delayed(delay);
    final today = DateTime.now();
    return OcrResult(
      name: 'ಸುಮಾ',
      age: 23,
      husbandName: 'ರಮೇಶ',
      phone: '9845067890',
      village: 'ಹೊಸಳ್ಳಿ',
      subCentre: 'ಹೊಸಳ್ಳಿ ಉಪ ಕೇಂದ್ರ',
      abhaId: '12-3456-7890-1234',
      lmp: DateTime(today.year, today.month, today.day)
          .subtract(const Duration(days: 154)),
      gravida: 2,
      para: 1,
      bloodGroup: 'O+',
      heightCm: 152,
      confidence: 0.86,
    );
  }
}
