// screens/registration/join_tournament_screen.dart
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/individual_registration.dart';
import '../../services/data_service.dart';
import '../../utils/date_formatter.dart';
import 'registration_success_screen.dart';

class JoinTournamentScreen extends StatefulWidget {
  const JoinTournamentScreen({super.key});

  @override
  State<JoinTournamentScreen> createState() => _JoinTournamentScreenState();
}

class _JoinTournamentScreenState extends State<JoinTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();

  bool _isLoading = false;
  Tournament? _foundTournament;
  bool _isChild = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Tournament'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tournament Registration',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Enter the tournament code provided by the host after paying your registration fee.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tournament Code
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Tournament Code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number),
                  hintText: 'e.g., ASAC24',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the tournament code';
                  }
                  if (value.length < 4) {
                    return 'Tournament code must be at least 4 characters';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.length >= 4) {
                    _verifyTournamentCode(value);
                  }
                },
              ),

              if (_foundTournament != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tournament Found!',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                            Text(
                              _foundTournament!.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text('Location: ${_foundTournament!.location}'),
                            Text(
                                'Date: ${DateFormatter.formatLongDate(_foundTournament!.date)}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Participant Information
              const Text(
                'Participant Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Age (optional - determines if child)
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age (optional - required for under 18)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                  hintText: 'Leave blank if 18+',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final age = int.tryParse(value);
                  setState(() {
                    _isChild = age != null && age < 18;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Phone Number (adult) or Parent Info (child)
              if (!_isChild) ...[
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ] else ...[
                const Text(
                  'Parent/Guardian Information (Required for under 18)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _parentNameController,
                  decoration: const InputDecoration(
                    labelText: 'Parent/Guardian Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: _isChild
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Parent/Guardian name required for minors';
                          }
                          return null;
                        }
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _parentPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Parent/Guardian Phone',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: _isChild
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Parent/Guardian phone required for minors';
                          }
                          return null;
                        }
                      : null,
                ),
              ],

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _foundTournament != null && !_isLoading
                      ? _submitRegistration
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Submitting Registration...'),
                          ],
                        )
                      : const Text(
                          'Submit Registration',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Important Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Important',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• You must pay your registration fee BEFORE submitting this form\n'
                      '• Your registration will be marked as "pending payment" until confirmed by tournament officials\n'
                      '• Keep your phone handy for fish scoring notifications',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyTournamentCode(String code) async {
    try {
      final tournament = await DataService.getTournamentByCode(code);
      setState(() {
        _foundTournament = tournament;
      });
    } catch (e) {
      setState(() {
        _foundTournament = null;
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final registration = IndividualRegistration(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tournamentId: _foundTournament!.id,
        name: _nameController.text.trim(),
        phoneNumber: _isChild ? null : _phoneController.text.trim(),
        age: _ageController.text.isNotEmpty
            ? int.parse(_ageController.text)
            : null,
        registrationTime: DateTime.now(),
        parentName: _isChild ? _parentNameController.text.trim() : null,
        parentPhone: _isChild ? _parentPhoneController.text.trim() : null,
      );

      await DataService.submitIndividualRegistration(registration);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => RegistrationSuccessScreen(
              tournament: _foundTournament!,
              registration: registration,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
