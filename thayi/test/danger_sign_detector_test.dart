import 'package:flutter_test/flutter_test.dart';
import 'package:setu_thayi/safety/danger_sign_detector.dart';

void main() {
  const detector = DangerSignDetector();

  group('fires on Kannada danger signs', () {
    const cases = {
      'ನನಗೆ ರಕ್ತಸ್ರಾವ ಆಗುತ್ತಿದೆ': DangerSign.bleeding,
      'ಜೋರಾಗಿ ತಲೆನೋವು ಬರುತ್ತಿದೆ': DangerSign.severeHeadache,
      'ಕಣ್ಣು ಮಂಜಾಗಿ ಕಾಣಿಸುತ್ತಿದೆ': DangerSign.blurredVision,
      'ಮಗು ಆಡುತ್ತಿಲ್ಲ ಇವತ್ತು': DangerSign.reducedFetalMovement,
      'ರಾತ್ರಿಯಿಂದ ಜ್ವರ ಇದೆ': DangerSign.fever,
      'ಮುಖ ಊದಿಕೊಂಡಿದೆ': DangerSign.swelling,
      'ಸೆಳೆತ ಬಂತು': DangerSign.convulsions,
    };

    cases.forEach((text, expected) {
      test(text, () {
        expect(detector.detect(text)?.sign, expected);
      });
    });
  });

  group('fires on English danger signs', () {
    const cases = {
      'I have bleeding since morning': DangerSign.bleeding,
      'severe headache, not going away': DangerSign.severeHeadache,
      'my vision is blurry': DangerSign.blurredVision,
      'baby not moving since last night': DangerSign.reducedFetalMovement,
      'I have fever and chills': DangerSign.fever,
      'my hands are swollen': DangerSign.swelling,
      'she had fits': DangerSign.convulsions,
    };

    cases.forEach((text, expected) {
      test(text, () {
        expect(detector.detect(text)?.sign, expected);
      });
    });
  });

  test('punctuation and casing do not hide a sign', () {
    expect(detector.isDangerous('BLEEDING!!!'), isTrue);
    expect(detector.isDangerous('  fever...  '), isTrue);
  });

  test('ordinary questions are not blocked', () {
    const safe = [
      'ಪ್ರತಿ ದಿನ ಏನು ತಿನ್ನಬೇಕು?',
      'ಎಷ್ಟು ವಿಶ್ರಾಂತಿ ತೆಗೆದುಕೊಳ್ಳಬೇಕು?',
      'ನನ್ನ ರಕ್ತದ ಗುಂಪು ಯಾವುದು?',
      'when is my next checkup',
      'can I drink tea',
    ];
    for (final text in safe) {
      expect(detector.isDangerous(text), isFalse, reason: text);
    }
  });

  test('empty input is safe', () {
    expect(detector.detect(''), isNull);
    expect(detector.detect('   '), isNull);
  });
}
