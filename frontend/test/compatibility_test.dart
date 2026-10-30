import 'package:flutter_test/flutter_test.dart';
import 'package:campus_pulse/main.dart';

void main() {
  group('Campus Pulse compatibility', () {
    test('calculates weighted compatibility score from subject, goal, and availability data', () {
      final score = calculateCompatibilityScore(
        subjectsA: {'DSA', 'Web Development', 'UI/UX Design'},
        subjectsB: {'DSA', 'Machine Learning', 'UI/UX Design'},
        goalsA: {'Placement Preparation', 'Project Work'},
        goalsB: {'Placement Preparation', 'Learning New Skills'},
        availabilityA: {'Mon Morning', 'Sat Afternoon'},
        availabilityB: {'Sat Afternoon', 'Sun Evening'},
      );

      expect(score, inInclusiveRange(0, 100));
      expect(score, isNotNull);
      expect(score.round(), equals(42));
    });
  });
}
