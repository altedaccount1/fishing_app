// screens/registration/registration_success_screen.dart
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/individual_registration.dart';
import '../../utils/date_formatter.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  final Tournament tournament;
  final IndividualRegistration registration;

  const RegistrationSuccessScreen({
    super.key,
    required this.tournament,
    required this.registration,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Submitted'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 20),
            Text(
              'Registration Submitted!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tournament: ${tournament.name}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Location: ${tournament.location}'),
                  Text(
                      'Date: ${DateFormatter.formatLongDate(tournament.date)}'),
                  const SizedBox(height: 12),
                  Text('Participant: ${registration.displayName}'),
                  Text('Registration ID: ${registration.id}'),
                  if (registration.isChild) ...[
                    Text('Parent/Guardian: ${registration.parentName}'),
                    Text('Contact: ${registration.parentPhone}'),
                  ] else if (registration.phoneNumber != null) ...[
                    Text('Contact: ${registration.phoneNumber}'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.pending, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Pending Payment Confirmation',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your registration is pending until tournament officials confirm your payment. '
                    'You will be notified once approved and can then start submitting fish catches.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // What's Next section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'What\'s Next?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                      '1. Tournament officials will verify your payment'),
                  const Text('2. You\'ll receive confirmation when approved'),
                  const Text('3. Start fishing and submit your catches'),
                  const Text('4. Check leaderboards for live updates'),
                ],
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
