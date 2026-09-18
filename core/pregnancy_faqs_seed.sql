-- Grounding content for the assistant.
--
-- She never sees this as a list. It is retrieved silently on each question and
-- handed to the model as the only material it may answer from, so replies stay
-- inside guidance a clinician has signed off rather than whatever the model
-- happens to believe.
--
-- Sourced from WHO ANC recommendations and the MoHFW / NHM India maternal and
-- child health materials. reviewed_by is deliberately null: a clinician at the
-- PHC must read and sign each row before this is used with real patients.

insert into public.pregnancy_faqs
  (category, stage, question, answer, question_kn, answer_kn,
   source_name, urgency, is_published)
values
-- ------------------------------------------------------------------ food
('food','pregnancy',
 'What should I eat during pregnancy?',
 'Eat a little more than usual, and eat a mix: rice or ragi, dal, seasonal vegetables, greens, milk or curd, and fruit. Add groundnuts, eggs or fish if you eat them. Take your iron and folic acid tablets as your ASHA gives them. Drink water through the day.',
 'ಗರ್ಭಿಣಿಯಾಗಿದ್ದಾಗ ಏನು ತಿನ್ನಬೇಕು?',
 'ಎಂದಿಗಿಂತ ಸ್ವಲ್ಪ ಹೆಚ್ಚು ತಿನ್ನಿ, ಮತ್ತು ಬೇರೆ ಬೇರೆ ಆಹಾರ ತಿನ್ನಿ: ಅಕ್ಕಿ ಅಥವಾ ರಾಗಿ, ಬೇಳೆ, ಕಾಲಕ್ಕೆ ತಕ್ಕ ತರಕಾರಿ, ಸೊಪ್ಪು, ಹಾಲು ಅಥವಾ ಮೊಸರು, ಹಣ್ಣು. ಕಡಲೆಕಾಯಿ, ಮೊಟ್ಟೆ, ಮೀನು ತಿನ್ನುವವರಾದರೆ ಅವನ್ನೂ ಸೇರಿಸಿ. ಆಶಾ ಕಾರ್ಯಕರ್ತೆ ಕೊಡುವ ಕಬ್ಬಿಣ ಮತ್ತು ಫೋಲಿಕ್ ಆಮ್ಲದ ಮಾತ್ರೆಗಳನ್ನು ತಪ್ಪದೆ ತೆಗೆದುಕೊಳ್ಳಿ. ದಿನವಿಡೀ ನೀರು ಕುಡಿಯಿರಿ.',
 'WHO ANC guideline; MoHFW India','normal',true),

('food','pregnancy',
 'Can I drink tea or coffee?',
 'A little is alright, but keep it to about one or two cups a day. Too much tea or coffee makes it harder for your body to absorb iron. Try not to drink tea just before or just after a meal, or right after your iron tablet.',
 'ನಾನು ಚಹಾ ಅಥವಾ ಕಾಫಿ ಕುಡಿಯಬಹುದೇ?',
 'ಸ್ವಲ್ಪ ಪರವಾಗಿಲ್ಲ, ಆದರೆ ದಿನಕ್ಕೆ ಒಂದು ಅಥವಾ ಎರಡು ಕಪ್‌ಗೆ ಸೀಮಿತಗೊಳಿಸಿ. ಹೆಚ್ಚು ಚಹಾ ಕಾಫಿ ಕುಡಿದರೆ ದೇಹಕ್ಕೆ ಕಬ್ಬಿಣಾಂಶ ಸೇರುವುದು ಕಷ್ಟವಾಗುತ್ತದೆ. ಊಟಕ್ಕೆ ಮೊದಲು ಅಥವಾ ಆದ ಕೂಡಲೇ, ಮತ್ತು ಕಬ್ಬಿಣದ ಮಾತ್ರೆ ತೆಗೆದುಕೊಂಡ ಕೂಡಲೇ ಚಹಾ ಕುಡಿಯಬೇಡಿ.',
 'WHO ANC guideline','normal',true),

('food','pregnancy',
 'I feel sick and vomit in the morning. What can I do?',
 'This is very common in the early months and usually settles by about the fourth month. Eat small amounts often instead of large meals, keep something dry like a biscuit or puffed rice to eat before getting up, and sip water or lemon water through the day. Avoid smells that trouble you. If you cannot keep any food or water down at all, or you are losing weight, tell your ASHA worker.',
 'ಬೆಳಗ್ಗೆ ವಾಕರಿಕೆ ಮತ್ತು ವಾಂತಿ ಆಗುತ್ತದೆ. ಏನು ಮಾಡಲಿ?',
 'ಮೊದಲ ತಿಂಗಳುಗಳಲ್ಲಿ ಇದು ತುಂಬಾ ಸಾಮಾನ್ಯ, ಸಾಮಾನ್ಯವಾಗಿ ನಾಲ್ಕನೇ ತಿಂಗಳ ಹೊತ್ತಿಗೆ ಕಡಿಮೆಯಾಗುತ್ತದೆ. ಒಮ್ಮೆಗೇ ಹೆಚ್ಚು ತಿನ್ನುವ ಬದಲು ಸ್ವಲ್ಪ ಸ್ವಲ್ಪವಾಗಿ ಪದೇ ಪದೇ ತಿನ್ನಿ, ಏಳುವ ಮೊದಲು ಬಿಸ್ಕತ್ತು ಅಥವಾ ಮಂಡಕ್ಕಿ ತಿನ್ನಿ, ದಿನವಿಡೀ ನೀರು ಅಥವಾ ನಿಂಬೆ ನೀರು ಸ್ವಲ್ಪ ಸ್ವಲ್ಪ ಕುಡಿಯಿರಿ. ತೊಂದರೆ ಕೊಡುವ ವಾಸನೆಯಿಂದ ದೂರವಿರಿ. ಆಹಾರ ನೀರು ಏನೂ ಒಳಗೆ ಉಳಿಯದಿದ್ದರೆ ಅಥವಾ ತೂಕ ಕಡಿಮೆಯಾಗುತ್ತಿದ್ದರೆ ಆಶಾ ಕಾರ್ಯಕರ್ತೆಗೆ ತಿಳಿಸಿ.',
 'WHO ANC guideline','normal',true),

('food','pregnancy',
 'Why do I have to take the iron tablet?',
 'Many women become low on blood during pregnancy, which leaves you tired and breathless and makes delivery riskier. The iron and folic acid tablet prevents that and helps the baby grow. Take it as your ASHA worker tells you, with water, and not together with tea or milk. It can make your stool dark, which is normal and harmless.',
 'ಕಬ್ಬಿಣದ ಮಾತ್ರೆ ಏಕೆ ತೆಗೆದುಕೊಳ್ಳಬೇಕು?',
 'ಗರ್ಭಾವಸ್ಥೆಯಲ್ಲಿ ಅನೇಕ ಮಹಿಳೆಯರಿಗೆ ರಕ್ತ ಕಡಿಮೆಯಾಗುತ್ತದೆ, ಇದರಿಂದ ಸುಸ್ತು ಮತ್ತು ಉಸಿರಾಟದ ತೊಂದರೆ ಆಗುತ್ತದೆ ಮತ್ತು ಹೆರಿಗೆ ಅಪಾಯಕಾರಿಯಾಗುತ್ತದೆ. ಕಬ್ಬಿಣ ಮತ್ತು ಫೋಲಿಕ್ ಆಮ್ಲದ ಮಾತ್ರೆ ಇದನ್ನು ತಡೆಯುತ್ತದೆ ಮತ್ತು ಮಗುವಿನ ಬೆಳವಣಿಗೆಗೆ ಸಹಾಯ ಮಾಡುತ್ತದೆ. ಆಶಾ ಕಾರ್ಯಕರ್ತೆ ಹೇಳಿದಂತೆ ನೀರಿನೊಂದಿಗೆ ತೆಗೆದುಕೊಳ್ಳಿ, ಚಹಾ ಅಥವಾ ಹಾಲಿನೊಂದಿಗೆ ಬೇಡ. ಮಲ ಕಪ್ಪಾಗಬಹುದು, ಅದು ಸಾಮಾನ್ಯ, ಭಯಪಡಬೇಕಿಲ್ಲ.',
 'MoHFW India anaemia programme','normal',true),

-- --------------------------------------------------------- first trimester
('first_trimester','pregnancy',
 'How many check-ups do I need and when?',
 'You need at least four check-ups, and eight contacts are better. The first should be as early as possible in the first three months, then around the sixth month, the eighth month, and the ninth month. Your ASHA worker will tell you the date each time. Go even if you feel completely well, because the tests find problems before you can feel them.',
 'ಎಷ್ಟು ತಪಾಸಣೆ ಬೇಕು ಮತ್ತು ಯಾವಾಗ?',
 'ಕನಿಷ್ಠ ನಾಲ್ಕು ತಪಾಸಣೆ ಬೇಕು, ಎಂಟು ಆದರೆ ಇನ್ನೂ ಒಳ್ಳೆಯದು. ಮೊದಲನೆಯದು ಮೊದಲ ಮೂರು ತಿಂಗಳಲ್ಲಿ ಆದಷ್ಟು ಬೇಗ, ನಂತರ ಸುಮಾರು ಆರನೇ ತಿಂಗಳು, ಎಂಟನೇ ತಿಂಗಳು ಮತ್ತು ಒಂಬತ್ತನೇ ತಿಂಗಳಲ್ಲಿ. ಪ್ರತಿ ಬಾರಿ ದಿನಾಂಕವನ್ನು ಆಶಾ ಕಾರ್ಯಕರ್ತೆ ತಿಳಿಸುತ್ತಾರೆ. ಚೆನ್ನಾಗಿದ್ದೇನೆ ಅನಿಸಿದರೂ ಹೋಗಿ, ಏಕೆಂದರೆ ತೊಂದರೆ ನಿಮಗೆ ಗೊತ್ತಾಗುವ ಮೊದಲೇ ಪರೀಕ್ಷೆಯಲ್ಲಿ ಸಿಗುತ್ತದೆ.',
 'WHO ANC guideline; MoHFW India','normal',true),

('first_trimester','pregnancy',
 'Is it safe to keep working and doing housework?',
 'Yes, most women carry on with their usual work. Avoid lifting heavy loads, standing for very long stretches, and working in the midday heat. Sit down and rest when you feel tired, and keep water with you. If your work involves pesticides, chemicals or heavy lifting, tell your ASHA worker.',
 'ಕೆಲಸ ಮತ್ತು ಮನೆಕೆಲಸ ಮಾಡುವುದು ಸುರಕ್ಷಿತವೇ?',
 'ಹೌದು, ಹೆಚ್ಚಿನ ಮಹಿಳೆಯರು ಎಂದಿನ ಕೆಲಸ ಮುಂದುವರಿಸುತ್ತಾರೆ. ಭಾರ ಎತ್ತುವುದು, ಬಹಳ ಹೊತ್ತು ನಿಂತಿರುವುದು ಮತ್ತು ಮಧ್ಯಾಹ್ನದ ಬಿಸಿಲಿನಲ್ಲಿ ಕೆಲಸ ಮಾಡುವುದನ್ನು ತಪ್ಪಿಸಿ. ಸುಸ್ತಾದಾಗ ಕುಳಿತು ವಿಶ್ರಾಂತಿ ತೆಗೆದುಕೊಳ್ಳಿ, ನೀರು ಜೊತೆಯಲ್ಲಿಡಿ. ಕೀಟನಾಶಕ, ರಾಸಾಯನಿಕ ಅಥವಾ ಭಾರ ಎತ್ತುವ ಕೆಲಸವಾದರೆ ಆಶಾ ಕಾರ್ಯಕರ್ತೆಗೆ ತಿಳಿಸಿ.',
 'WHO ANC guideline','normal',true),

('first_trimester','pregnancy',
 'Can I travel by bus to my mother''s house?',
 'Short journeys are usually fine, and the middle months are the most comfortable time to travel. On a long journey, get up and move your legs every couple of hours and drink water. Late in pregnancy it is better to stay near the hospital where you plan to deliver. If you have been told your pregnancy is high risk, ask your ASHA worker before making a long trip.',
 'ಬಸ್ಸಿನಲ್ಲಿ ತವರುಮನೆಗೆ ಪ್ರಯಾಣ ಮಾಡಬಹುದೇ?',
 'ಸಣ್ಣ ಪ್ರಯಾಣ ಸಾಮಾನ್ಯವಾಗಿ ಪರವಾಗಿಲ್ಲ, ಮಧ್ಯದ ತಿಂಗಳುಗಳು ಪ್ರಯಾಣಕ್ಕೆ ಹೆಚ್ಚು ಆರಾಮದಾಯಕ. ದೂರದ ಪ್ರಯಾಣದಲ್ಲಿ ಪ್ರತಿ ಎರಡು ಗಂಟೆಗೊಮ್ಮೆ ಎದ್ದು ಕಾಲು ಆಡಿಸಿ ಮತ್ತು ನೀರು ಕುಡಿಯಿರಿ. ಕೊನೆಯ ತಿಂಗಳುಗಳಲ್ಲಿ ಹೆರಿಗೆ ಮಾಡಿಸಿಕೊಳ್ಳುವ ಆಸ್ಪತ್ರೆಯ ಹತ್ತಿರವೇ ಇರುವುದು ಒಳ್ಳೆಯದು. ನಿಮ್ಮ ಗರ್ಭಾವಸ್ಥೆ ಅಪಾಯದ ಮಟ್ಟದಲ್ಲಿದೆ ಎಂದು ಹೇಳಿದ್ದರೆ, ದೂರ ಪ್ರಯಾಣಕ್ಕೆ ಮೊದಲು ಆಶಾ ಕಾರ್ಯಕರ್ತೆಯನ್ನು ಕೇಳಿ.',
 'WHO ANC guideline','normal',true),

-- -------------------------------------------------------- second trimester
('second_trimester','pregnancy',
 'When will I feel the baby move?',
 'Most women first feel movement between the fourth and fifth month, and later than that in a first pregnancy. Once movements have settled into a pattern, you should feel them every day. If the baby moves less than usual, or you notice no movement for several hours, do not wait at home — go to the health centre the same day.',
 'ಮಗುವಿನ ಚಲನೆ ಯಾವಾಗ ಅನಿಸುತ್ತದೆ?',
 'ಹೆಚ್ಚಿನ ಮಹಿಳೆಯರಿಗೆ ನಾಲ್ಕರಿಂದ ಐದನೇ ತಿಂಗಳ ನಡುವೆ ಮೊದಲ ಬಾರಿ ಚಲನೆ ಅನಿಸುತ್ತದೆ, ಮೊದಲ ಗರ್ಭಾವಸ್ಥೆಯಲ್ಲಿ ಸ್ವಲ್ಪ ತಡವಾಗಿ. ಚಲನೆ ಒಂದು ಕ್ರಮಕ್ಕೆ ಬಂದ ಮೇಲೆ ಪ್ರತಿದಿನ ಅನಿಸಬೇಕು. ಮಗು ಎಂದಿಗಿಂತ ಕಡಿಮೆ ಆಡಿದರೆ, ಅಥವಾ ಹಲವು ಗಂಟೆ ಚಲನೆಯೇ ಇಲ್ಲದಿದ್ದರೆ ಮನೆಯಲ್ಲಿ ಕಾಯಬೇಡಿ — ಅದೇ ದಿನ ಆರೋಗ್ಯ ಕೇಂದ್ರಕ್ಕೆ ಹೋಗಿ.',
 'WHO ANC guideline','contact_clinician',true),

('second_trimester','pregnancy',
 'My legs and feet are swelling. Is that normal?',
 'Mild swelling of the feet and ankles at the end of the day is common, especially in the later months. Put your feet up when you sit, lie on your left side, and avoid standing for long. But swelling that comes on suddenly, or swelling of the face and hands, along with headache or blurred vision, can be a sign of a dangerous rise in blood pressure. Go to the health centre straight away.',
 'ಕಾಲು ಮತ್ತು ಪಾದ ಊದಿಕೊಳ್ಳುತ್ತಿದೆ, ಇದು ಸಾಮಾನ್ಯವೇ?',
 'ದಿನದ ಕೊನೆಯಲ್ಲಿ ಪಾದ ಮತ್ತು ಗಂಟುಗಳ ಸ್ವಲ್ಪ ಊತ ಸಾಮಾನ್ಯ, ಮುಖ್ಯವಾಗಿ ಕೊನೆಯ ತಿಂಗಳುಗಳಲ್ಲಿ. ಕುಳಿತಾಗ ಕಾಲನ್ನು ಮೇಲಕ್ಕೆ ಇಡಿ, ಎಡ ಮಗ್ಗುಲಿಗೆ ಮಲಗಿ, ಬಹಳ ಹೊತ್ತು ನಿಲ್ಲಬೇಡಿ. ಆದರೆ ಇದ್ದಕ್ಕಿದ್ದಂತೆ ಬರುವ ಊತ, ಅಥವಾ ಮುಖ ಮತ್ತು ಕೈ ಊದಿಕೊಳ್ಳುವುದು, ಜೊತೆಗೆ ತಲೆನೋವು ಅಥವಾ ಮಸುಕಾದ ದೃಷ್ಟಿ ಇದ್ದರೆ — ಇದು ರಕ್ತದೊತ್ತಡ ಅಪಾಯಕಾರಿಯಾಗಿ ಏರಿದ ಸೂಚನೆ ಇರಬಹುದು. ತಕ್ಷಣ ಆರೋಗ್ಯ ಕೇಂದ್ರಕ್ಕೆ ಹೋಗಿ.',
 'WHO ANC guideline','contact_clinician',true),

('second_trimester','pregnancy',
 'Is walking or light exercise safe?',
 'Yes. Walking twenty to thirty minutes a day is good for you: it helps with sleep, constipation, swelling and blood sugar. Walk at a pace where you can still talk. Stop and rest if you feel dizzy, breathless or have any pain, and avoid anything where you might fall.',
 'ನಡಿಗೆ ಅಥವಾ ಹಗುರ ವ್ಯಾಯಾಮ ಸುರಕ್ಷಿತವೇ?',
 'ಹೌದು. ದಿನಕ್ಕೆ ಇಪ್ಪತ್ತರಿಂದ ಮೂವತ್ತು ನಿಮಿಷ ನಡೆಯುವುದು ಒಳ್ಳೆಯದು: ನಿದ್ದೆ, ಮಲಬದ್ಧತೆ, ಊತ ಮತ್ತು ಸಕ್ಕರೆ ಅಂಶಕ್ಕೆ ಸಹಾಯವಾಗುತ್ತದೆ. ಮಾತನಾಡಲು ಸಾಧ್ಯವಾಗುವ ವೇಗದಲ್ಲಿ ನಡೆಯಿರಿ. ತಲೆ ಸುತ್ತು, ಉಸಿರಾಟದ ತೊಂದರೆ ಅಥವಾ ನೋವು ಬಂದರೆ ನಿಲ್ಲಿಸಿ ವಿಶ್ರಾಂತಿ ಪಡೆಯಿರಿ, ಬೀಳುವ ಸಾಧ್ಯತೆ ಇರುವ ಯಾವುದನ್ನೂ ಮಾಡಬೇಡಿ.',
 'WHO ANC guideline','normal',true),

-- --------------------------------------------------------- third trimester
('third_trimester','pregnancy',
 'How should I sleep in the last months?',
 'Sleep on your side, and the left side is best, because lying flat on your back presses on a large blood vessel and can make you feel faint. Put a pillow between your knees and one under your belly. If you wake up on your back, just turn to your side; no harm is done.',
 'ಕೊನೆಯ ತಿಂಗಳುಗಳಲ್ಲಿ ಹೇಗೆ ಮಲಗಬೇಕು?',
 'ಮಗ್ಗುಲಿಗೆ ಮಲಗಿ, ಎಡ ಮಗ್ಗುಲು ಅತ್ಯುತ್ತಮ. ಬೆನ್ನ ಮೇಲೆ ನೇರವಾಗಿ ಮಲಗಿದರೆ ದೊಡ್ಡ ರಕ್ತನಾಳದ ಮೇಲೆ ಒತ್ತಡ ಬಿದ್ದು ತಲೆ ಸುತ್ತಬಹುದು. ಮೊಣಕಾಲುಗಳ ನಡುವೆ ಒಂದು ದಿಂಬು, ಹೊಟ್ಟೆಯ ಕೆಳಗೆ ಒಂದು ದಿಂಬು ಇಟ್ಟುಕೊಳ್ಳಿ. ಎಚ್ಚರವಾದಾಗ ಬೆನ್ನ ಮೇಲೆ ಇದ್ದರೆ ಮಗ್ಗುಲಿಗೆ ತಿರುಗಿ, ಏನೂ ತೊಂದರೆ ಆಗಿರುವುದಿಲ್ಲ.',
 'WHO ANC guideline','normal',true),

('third_trimester','pregnancy',
 'What should I keep ready for the delivery?',
 'Keep your Thayi card and hospital papers, clean clothes for you and the baby, a towel, sanitary pads, soap, and your money or Janani Suraksha Yojana papers in one bag. Decide now which hospital you will go to and how you will get there at night, and keep the ambulance number 108 and your ASHA worker''s number where anyone at home can find them.',
 'ಹೆರಿಗೆಗೆ ಏನೆಲ್ಲ ಸಿದ್ಧವಿಟ್ಟುಕೊಳ್ಳಬೇಕು?',
 'ತಾಯಿ ಕಾರ್ಡ್ ಮತ್ತು ಆಸ್ಪತ್ರೆಯ ಕಾಗದಗಳು, ನಿಮಗೂ ಮಗುವಿಗೂ ಶುಚಿಯಾದ ಬಟ್ಟೆ, ಟವೆಲ್, ಸ್ಯಾನಿಟರಿ ಪ್ಯಾಡ್, ಸೋಪು, ಹಣ ಅಥವಾ ಜನನಿ ಸುರಕ್ಷಾ ಯೋಜನೆಯ ಕಾಗದ — ಇವೆಲ್ಲವನ್ನೂ ಒಂದೇ ಚೀಲದಲ್ಲಿ ಇಟ್ಟುಕೊಳ್ಳಿ. ಯಾವ ಆಸ್ಪತ್ರೆಗೆ ಹೋಗಬೇಕು, ರಾತ್ರಿ ಹೇಗೆ ಹೋಗಬೇಕು ಎಂದು ಈಗಲೇ ನಿರ್ಧರಿಸಿ. ಆಂಬ್ಯುಲೆನ್ಸ್ ಸಂಖ್ಯೆ 108 ಮತ್ತು ಆಶಾ ಕಾರ್ಯಕರ್ತೆಯ ನಂಬರನ್ನು ಮನೆಯಲ್ಲಿ ಎಲ್ಲರಿಗೂ ಸಿಗುವಂತೆ ಇಡಿ.',
 'MoHFW India birth preparedness','normal',true),

-- ---------------------------------------------------------------- labour
('labour','pregnancy',
 'How will I know labour has started?',
 'Labour usually starts with pains that come in a regular rhythm, grow stronger, and last longer, along with a low backache and a tightening of the belly. You may see a plug of mucus, sometimes streaked with blood. Go to the hospital when the pains are regular, or straight away if your water breaks, if you bleed, or if the baby stops moving.',
 'ಹೆರಿಗೆ ನೋವು ಶುರುವಾಗಿದೆ ಎಂದು ಹೇಗೆ ತಿಳಿಯುವುದು?',
 'ಸಾಮಾನ್ಯವಾಗಿ ಒಂದು ಕ್ರಮದಲ್ಲಿ ಬರುವ, ಹೆಚ್ಚು ಜೋರಾಗುತ್ತಾ ಹೋಗುವ, ಹೆಚ್ಚು ಹೊತ್ತು ಇರುವ ನೋವಿನಿಂದ ಹೆರಿಗೆ ಶುರುವಾಗುತ್ತದೆ, ಜೊತೆಗೆ ಸೊಂಟ ನೋವು ಮತ್ತು ಹೊಟ್ಟೆ ಬಿಗಿಯಾಗುವುದು. ಲೋಳೆ ಹೋಗಬಹುದು, ಅದರಲ್ಲಿ ಸ್ವಲ್ಪ ರಕ್ತವೂ ಇರಬಹುದು. ನೋವು ಕ್ರಮವಾಗಿ ಬರತೊಡಗಿದಾಗ ಆಸ್ಪತ್ರೆಗೆ ಹೋಗಿ. ನೀರು ಹೋದರೆ, ರಕ್ತಸ್ರಾವ ಆದರೆ ಅಥವಾ ಮಗು ಆಡುವುದು ನಿಂತರೆ ತಕ್ಷಣ ಹೋಗಿ.',
 'WHO labour care guide','contact_clinician',true),

('labour','pregnancy',
 'Why should I deliver in a hospital and not at home?',
 'Most deliveries go well, but the two things that kill mothers — heavy bleeding and fits from high blood pressure — happen without warning and need treatment within minutes. A hospital has that treatment, blood, and someone trained to use it. Government delivery is free, and Janani Suraksha Yojana pays you and covers your transport.',
 'ಮನೆಯಲ್ಲಿ ಅಲ್ಲದೆ ಆಸ್ಪತ್ರೆಯಲ್ಲೇ ಏಕೆ ಹೆರಿಗೆ ಮಾಡಿಸಿಕೊಳ್ಳಬೇಕು?',
 'ಹೆಚ್ಚಿನ ಹೆರಿಗೆಗಳು ಸರಿಯಾಗಿ ಆಗುತ್ತವೆ. ಆದರೆ ತಾಯಂದಿರ ಪ್ರಾಣ ತೆಗೆಯುವ ಎರಡು ವಿಷಯಗಳು — ಅತಿಯಾದ ರಕ್ತಸ್ರಾವ ಮತ್ತು ರಕ್ತದೊತ್ತಡದಿಂದ ಬರುವ ಫಿಟ್ಸ್ — ಯಾವ ಸೂಚನೆಯೂ ಇಲ್ಲದೆ ಬರುತ್ತವೆ ಮತ್ತು ಕೆಲವೇ ನಿಮಿಷಗಳಲ್ಲಿ ಚಿಕಿತ್ಸೆ ಬೇಕಾಗುತ್ತದೆ. ಆಸ್ಪತ್ರೆಯಲ್ಲಿ ಆ ಚಿಕಿತ್ಸೆ, ರಕ್ತ ಮತ್ತು ತರಬೇತಿ ಪಡೆದವರು ಇರುತ್ತಾರೆ. ಸರ್ಕಾರಿ ಆಸ್ಪತ್ರೆಯಲ್ಲಿ ಹೆರಿಗೆ ಉಚಿತ, ಜನನಿ ಸುರಕ್ಷಾ ಯೋಜನೆಯಲ್ಲಿ ಹಣ ಮತ್ತು ಪ್ರಯಾಣದ ವೆಚ್ಚವೂ ಸಿಗುತ್ತದೆ.',
 'MoHFW India JSY; WHO','normal',true),

-- ------------------------------------------------------- postpartum mother
('postpartum_mother','postpartum',
 'How long does bleeding after delivery last?',
 'Some bleeding is normal for up to about six weeks. It is heaviest and red in the first few days, then becomes brown and finally pale, and it gradually reduces. But if you soak more than one pad in an hour, if you pass large clots, or if the bleeding gets heavier again after it had settled, that is an emergency — go to the hospital at once.',
 'ಹೆರಿಗೆಯ ನಂತರ ರಕ್ತಸ್ರಾವ ಎಷ್ಟು ದಿನ ಇರುತ್ತದೆ?',
 'ಸುಮಾರು ಆರು ವಾರಗಳವರೆಗೆ ಸ್ವಲ್ಪ ರಕ್ತಸ್ರಾವ ಸಾಮಾನ್ಯ. ಮೊದಲ ಕೆಲವು ದಿನ ಹೆಚ್ಚು ಮತ್ತು ಕೆಂಪಾಗಿರುತ್ತದೆ, ನಂತರ ಕಂದು ಬಣ್ಣಕ್ಕೆ, ಕೊನೆಗೆ ತಿಳಿ ಬಣ್ಣಕ್ಕೆ ತಿರುಗಿ ಕಡಿಮೆಯಾಗುತ್ತದೆ. ಆದರೆ ಒಂದು ಗಂಟೆಯಲ್ಲಿ ಒಂದಕ್ಕಿಂತ ಹೆಚ್ಚು ಪ್ಯಾಡ್ ತೊಯ್ದರೆ, ದೊಡ್ಡ ಹೆಪ್ಪುಗಳು ಹೋದರೆ, ಅಥವಾ ಕಡಿಮೆಯಾಗಿದ್ದ ರಕ್ತಸ್ರಾವ ಮತ್ತೆ ಹೆಚ್ಚಾದರೆ — ಇದು ತುರ್ತು ಪರಿಸ್ಥಿತಿ, ತಕ್ಷಣ ಆಸ್ಪತ್ರೆಗೆ ಹೋಗಿ.',
 'WHO postnatal care guideline','contact_clinician',true),

('postpartum_mother','postpartum',
 'What should I eat after delivery, especially if I am feeding the baby?',
 'Eat more than you did in pregnancy, not less, and eat normally — there is no food you must avoid while breastfeeding. Have rice or ragi, dal, greens, vegetables, milk or curd, fruit, and eggs or fish if you eat them. Drink water each time you feed. Keep taking the iron tablets for three months after delivery.',
 'ಹೆರಿಗೆಯ ನಂತರ, ಹಾಲುಣಿಸುವಾಗ ಏನು ತಿನ್ನಬೇಕು?',
 'ಗರ್ಭಾವಸ್ಥೆಯಲ್ಲಿ ತಿಂದಿದ್ದಕ್ಕಿಂತ ಹೆಚ್ಚು ತಿನ್ನಿ, ಕಡಿಮೆ ಅಲ್ಲ. ಎಂದಿನ ಆಹಾರವನ್ನೇ ತಿನ್ನಿ — ಹಾಲುಣಿಸುವಾಗ ಬಿಡಲೇಬೇಕಾದ ಆಹಾರ ಯಾವುದೂ ಇಲ್ಲ. ಅಕ್ಕಿ ಅಥವಾ ರಾಗಿ, ಬೇಳೆ, ಸೊಪ್ಪು, ತರಕಾರಿ, ಹಾಲು ಅಥವಾ ಮೊಸರು, ಹಣ್ಣು, ತಿನ್ನುವವರಾದರೆ ಮೊಟ್ಟೆ ಮೀನು ಸೇರಿಸಿ. ಪ್ರತಿ ಬಾರಿ ಹಾಲುಣಿಸಿದಾಗ ನೀರು ಕುಡಿಯಿರಿ. ಹೆರಿಗೆಯ ನಂತರ ಮೂರು ತಿಂಗಳು ಕಬ್ಬಿಣದ ಮಾತ್ರೆ ಮುಂದುವರಿಸಿ.',
 'WHO postnatal care guideline; MoHFW India','normal',true),

-- ---------------------------------------------------------------- newborn
('newborn','newborn',
 'How often should I feed the baby?',
 'Feed only your own milk for the first six months — no water, no honey, no cow''s milk, not even in hot weather. Start within the first hour after birth, and give the thick yellow first milk, which protects the baby from infection. Feed whenever the baby wants, at least eight to twelve times in a day and night. Six or more wet nappies a day means the baby is getting enough.',
 'ಮಗುವಿಗೆ ಎಷ್ಟು ಬಾರಿ ಹಾಲುಣಿಸಬೇಕು?',
 'ಮೊದಲ ಆರು ತಿಂಗಳು ನಿಮ್ಮ ಎದೆಹಾಲನ್ನು ಮಾತ್ರ ಕೊಡಿ — ನೀರು ಬೇಡ, ಜೇನುತುಪ್ಪ ಬೇಡ, ಹಸುವಿನ ಹಾಲು ಬೇಡ, ಸೆಕೆ ಇದ್ದರೂ ಬೇಡ. ಹುಟ್ಟಿದ ಒಂದು ಗಂಟೆಯೊಳಗೆ ಶುರು ಮಾಡಿ, ಮೊದಲ ಬರುವ ಗಟ್ಟಿಯಾದ ಹಳದಿ ಹಾಲನ್ನು ತಪ್ಪದೆ ಕೊಡಿ, ಅದು ಮಗುವನ್ನು ಸೋಂಕಿನಿಂದ ಕಾಪಾಡುತ್ತದೆ. ಮಗು ಬಯಸಿದಾಗಲೆಲ್ಲ ಉಣಿಸಿ, ಹಗಲು ರಾತ್ರಿ ಸೇರಿ ಕನಿಷ್ಠ ಎಂಟರಿಂದ ಹನ್ನೆರಡು ಬಾರಿ. ದಿನಕ್ಕೆ ಆರು ಅಥವಾ ಹೆಚ್ಚು ಬಾರಿ ಮಗು ಉಚ್ಚೆ ಮಾಡಿದರೆ ಹಾಲು ಸಾಕಾಗುತ್ತಿದೆ ಎಂದರ್ಥ.',
 'WHO infant feeding guideline; MoHFW India','normal',true),

('newborn','newborn',
 'Which vaccinations does my baby need?',
 'At birth the baby gets BCG, the first hepatitis B dose and oral polio drops. Then there are doses at six, ten and fourteen weeks, at nine months, and later. All of them are free at the government health centre and at the village immunisation day. Your ASHA worker will tell you each date and it will show in this app — keep the card safe and do not miss a dose.',
 'ನನ್ನ ಮಗುವಿಗೆ ಯಾವ ಲಸಿಕೆಗಳು ಬೇಕು?',
 'ಹುಟ್ಟಿದಾಗ ಬಿಸಿಜಿ, ಹೆಪಟೈಟಿಸ್ ಬಿ ಮೊದಲ ಡೋಸ್ ಮತ್ತು ಪೋಲಿಯೊ ಹನಿ ಕೊಡುತ್ತಾರೆ. ನಂತರ ಆರು, ಹತ್ತು ಮತ್ತು ಹದಿನಾಲ್ಕು ವಾರಗಳಲ್ಲಿ, ಒಂಬತ್ತನೇ ತಿಂಗಳಲ್ಲಿ ಮತ್ತು ಆಮೇಲೆ ಇನ್ನಷ್ಟು ಇವೆ. ಎಲ್ಲವೂ ಸರ್ಕಾರಿ ಆರೋಗ್ಯ ಕೇಂದ್ರದಲ್ಲಿ ಮತ್ತು ಗ್ರಾಮದ ಲಸಿಕೆ ದಿನದಂದು ಉಚಿತ. ಪ್ರತಿ ದಿನಾಂಕವನ್ನು ಆಶಾ ಕಾರ್ಯಕರ್ತೆ ತಿಳಿಸುತ್ತಾರೆ ಮತ್ತು ಈ ಆ್ಯಪ್‌ನಲ್ಲೂ ಕಾಣಿಸುತ್ತದೆ — ಕಾರ್ಡ್ ಜೋಪಾನವಾಗಿಡಿ, ಯಾವ ಡೋಸ್ ಕೂಡ ತಪ್ಪಿಸಬೇಡಿ.',
 'MoHFW India universal immunisation programme','normal',true),

('newborn','newborn',
 'How do I keep my newborn warm and safe?',
 'Keep the baby skin to skin against your chest and cover you both together; that is warmer than any blanket alone. Delay the first bath for at least a day. Keep the cord stump clean and dry and put nothing on it. Everyone should wash their hands before touching the baby. If the baby feels cold or hot, will not feed, breathes fast, is very sleepy or turns yellow in the first days, go to the health centre.',
 'ಹಸುಗೂಸನ್ನು ಬೆಚ್ಚಗೆ ಮತ್ತು ಸುರಕ್ಷಿತವಾಗಿ ಹೇಗೆ ನೋಡಿಕೊಳ್ಳುವುದು?',
 'ಮಗುವನ್ನು ನಿಮ್ಮ ಎದೆಗೆ ಚರ್ಮದಿಂದ ಚರ್ಮಕ್ಕೆ ತಾಗುವಂತೆ ಇಟ್ಟುಕೊಂಡು ಇಬ್ಬರನ್ನೂ ಒಟ್ಟಿಗೆ ಹೊದಿಸಿ; ಯಾವ ಕಂಬಳಿಗಿಂತಲೂ ಇದು ಬೆಚ್ಚಗಿರುತ್ತದೆ. ಮೊದಲ ಸ್ನಾನವನ್ನು ಕನಿಷ್ಠ ಒಂದು ದಿನ ಮುಂದೂಡಿ. ಹೊಕ್ಕುಳ ಬಳ್ಳಿಯನ್ನು ಶುಚಿಯಾಗಿ ಒಣಗಿಸಿ ಇಡಿ, ಅದಕ್ಕೆ ಏನನ್ನೂ ಹಚ್ಚಬೇಡಿ. ಮಗುವನ್ನು ಮುಟ್ಟುವ ಮೊದಲು ಎಲ್ಲರೂ ಕೈ ತೊಳೆಯಬೇಕು. ಮಗು ತಣ್ಣಗಾದರೆ ಅಥವಾ ಬಿಸಿಯಾದರೆ, ಹಾಲು ಕುಡಿಯದಿದ್ದರೆ, ವೇಗವಾಗಿ ಉಸಿರಾಡಿದರೆ, ತುಂಬಾ ನಿದ್ದೆ ಮಾಡಿದರೆ ಅಥವಾ ಮೊದಲ ದಿನಗಳಲ್ಲಿ ಹಳದಿಯಾದರೆ ಆರೋಗ್ಯ ಕೇಂದ್ರಕ್ಕೆ ಹೋಗಿ.',
 'WHO postnatal care guideline','contact_clinician',true),

-- ----------------------------------------------------------- mental health
('mental_health','postpartum',
 'I feel low and cry a lot after delivery. Is something wrong with me?',
 'Nothing is wrong with you, and you are not a bad mother. Feeling tearful and low in the first two weeks is very common and usually passes. But if the sadness lasts longer than two weeks, or you cannot sleep even when the baby sleeps, or you feel no interest in the baby, that is an illness that has a treatment — tell your ASHA worker or the doctor. If you ever have thoughts of harming yourself or the baby, tell someone today.',
 'ಹೆರಿಗೆಯ ನಂತರ ಬೇಸರವಾಗುತ್ತದೆ, ಆಗಾಗ ಅಳು ಬರುತ್ತದೆ. ನನಗೆ ಏನಾದರೂ ತೊಂದರೆಯೇ?',
 'ನಿಮಗೆ ಏನೂ ತಪ್ಪಿಲ್ಲ, ನೀವು ಕೆಟ್ಟ ತಾಯಿ ಅಲ್ಲ. ಮೊದಲ ಎರಡು ವಾರಗಳಲ್ಲಿ ಅಳು ಮತ್ತು ಬೇಸರ ಬರುವುದು ತುಂಬಾ ಸಾಮಾನ್ಯ, ಸಾಮಾನ್ಯವಾಗಿ ತಾನಾಗಿ ಸರಿಹೋಗುತ್ತದೆ. ಆದರೆ ಬೇಸರ ಎರಡು ವಾರಕ್ಕಿಂತ ಹೆಚ್ಚು ಇದ್ದರೆ, ಮಗು ಮಲಗಿದಾಗಲೂ ನಿದ್ದೆ ಬರದಿದ್ದರೆ, ಅಥವಾ ಮಗುವಿನ ಮೇಲೆ ಆಸಕ್ತಿಯೇ ಇಲ್ಲದಿದ್ದರೆ — ಅದು ಚಿಕಿತ್ಸೆ ಇರುವ ಕಾಯಿಲೆ. ಆಶಾ ಕಾರ್ಯಕರ್ತೆಗೆ ಅಥವಾ ವೈದ್ಯರಿಗೆ ತಿಳಿಸಿ. ನಿಮಗೆ ಅಥವಾ ಮಗುವಿಗೆ ಹಾನಿ ಮಾಡುವ ಆಲೋಚನೆ ಬಂದರೆ ಇಂದೇ ಯಾರಿಗಾದರೂ ಹೇಳಿ.',
 'WHO maternal mental health guidance','contact_clinician',true);
