/// The safety mechanism of this app.
///
/// This is a hard-coded keyword matcher, NOT a model call. It runs on every
/// message before it is handed to the chat service, and it fires
/// deterministically. Nothing about the assistant's behaviour is trusted to
/// catch a danger sign.
///
/// It is deliberately biased towards firing: a false alarm costs her a phone
/// call, a missed sign costs much more.
library;

enum DangerSign {
  bleeding,
  severeHeadache,
  blurredVision,
  reducedFetalMovement,
  fever,
  swelling,
  convulsions,
}

class DangerMatch {
  const DangerMatch({required this.sign, required this.matchedTerm});
  final DangerSign sign;
  final String matchedTerm;
}

class DangerSignDetector {
  const DangerSignDetector();

  /// Kannada and English terms for each sign. Kannada is written the way a
  /// woman actually types or speaks it, including common transliterations.
  static const Map<DangerSign, List<String>> terms = {
    DangerSign.bleeding: [
      // Kannada
      'ರಕ್ತಸ್ರಾವ',
      'ರಕ್ತ ಸ್ರಾವ',
      'ರಕ್ತ ಹೋಗು',
      'ರಕ್ತ ಬರು',
      'ರಕ್ತ ಬಿಳ',
      'ಬ್ಲೀಡಿಂಗ್',
      'ಸ್ರಾವ',
      // English / transliterated
      'bleeding',
      'blood loss',
      'losing blood',
      'spotting',
      'raktasrava',
      'rakta hogu',
    ],
    DangerSign.severeHeadache: [
      'ತಲೆನೋವು',
      'ತಲೆ ನೋವು',
      'ತಲೆ ಸಿಡಿ',
      'ಜೋರು ತಲೆ',
      'headache',
      'head ache',
      'head pain',
      'talenovu',
      'tale novu',
    ],
    DangerSign.blurredVision: [
      'ಕಣ್ಣು ಮಂಜು',
      'ಮಂಜು ಕಾಣ',
      'ಮಂಜಾಗಿ',
      'ಮಂಜಾಗು',
      'ಕಣ್ಣು ಮಸುಕು',
      'ಮಸುಕು',
      'ಕಣ್ಣು ಕಾಣಿಸ',
      'blurred',
      'blurry',
      'blur vision',
      'cannot see',
      "can't see",
      'seeing spots',
      'kannu manju',
    ],
    DangerSign.reducedFetalMovement: [
      'ಮಗು ಆಡುತ್ತಿಲ್ಲ',
      'ಮಗು ಅಲುಗಾಡು',
      'ಮಗು ಆಡ್ತಿಲ್ಲ',
      'ಚಲನೆ ಇಲ್ಲ',
      'ಚಲನೆ ಕಡಿಮೆ',
      'ಮಗುವಿನ ಚಲನೆ',
      'ಒದೆಯುತ್ತಿಲ್ಲ',
      'ಒದೆತ ಇಲ್ಲ',
      'baby not moving',
      'no movement',
      'less movement',
      'reduced movement',
      'not kicking',
      'no kicks',
      'magu aaduttilla',
    ],
    DangerSign.fever: [
      'ಜ್ವರ',
      'ಮೈ ಬಿಸಿ',
      'ಚಳಿ ಜ್ವರ',
      'fever',
      'temperature high',
      'jwara',
      'jvara',
    ],
    DangerSign.swelling: [
      'ಊತ',
      'ಊದಿ',
      'ಬಾವು',
      'ಮುಖ ಊದ',
      'ಕೈ ಊದ',
      'ಕಾಲು ಊದ',
      'swelling',
      'swollen',
      'puffy face',
      'oota',
      'oothu',
    ],
    DangerSign.convulsions: [
      'ಸೆಳೆತ',
      'ಫಿಟ್ಸ್',
      'ಫಿಟ್',
      'ಮೂರ್ಛೆ',
      'ಪ್ರಜ್ಞೆ ತಪ್ಪ',
      'ಎಚ್ಚರ ತಪ್ಪ',
      'ನಡುಗು',
      'convulsion',
      'seizure',
      'fits',
      'unconscious',
      'fainted',
      'blackout',
      'selata',
    ],
  };

  /// Returns the first matching sign, or null. Order of [DangerSign] values
  /// decides priority when a message mentions more than one.
  DangerMatch? detect(String input) {
    final text = _normalise(input);
    if (text.isEmpty) return null;

    for (final sign in DangerSign.values) {
      for (final term in terms[sign]!) {
        if (text.contains(_normalise(term))) {
          return DangerMatch(sign: sign, matchedTerm: term);
        }
      }
    }
    return null;
  }

  bool isDangerous(String input) => detect(input) != null;

  /// Lowercase, collapse whitespace, drop punctuation that people type
  /// between words. Kannada codepoints are left untouched.
  static String _normalise(String input) {
    final lowered = input.toLowerCase();
    final cleaned = lowered.replaceAll(RegExp(r'[.,!?;:"‘’“”()\[\]/\\-]'), ' ');
    return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
