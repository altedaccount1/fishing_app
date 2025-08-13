// models/individual_registration.dart
class IndividualRegistration {
  final String id;
  final String tournamentId;
  final String name;
  final String? phoneNumber;
  final int? age; // null for adults
  final DateTime registrationTime;
  final bool isPaid;
  final String? parentName; // for kids
  final String? parentPhone; // for kids
  final List<Fish> catches;
  int totalPoints;

  IndividualRegistration({
    required this.id,
    required this.tournamentId,
    required this.name,
    this.phoneNumber,
    this.age,
    required this.registrationTime,
    this.isPaid = false,
    this.parentName,
    this.parentPhone,
    this.catches = const [],
    this.totalPoints = 0,
  });

  bool get isChild => age != null && age! < 18;
  bool get needsParentInfo =>
      isChild && (parentName == null || parentPhone == null);

  String get displayName => isChild ? '$name (Age $age)' : name;
  String get contactInfo =>
      isChild ? parentPhone ?? 'No contact' : phoneNumber ?? 'No contact';

  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'name': name,
      'phoneNumber': phoneNumber,
      'age': age,
      'registrationTime': registrationTime.toIso8601String(),
      'isPaid': isPaid,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'catches': catches.map((c) => c.toJson()).toList(),
      'totalPoints': totalPoints,
    };
  }

  factory IndividualRegistration.fromJson(Map<String, dynamic> json) {
    return IndividualRegistration(
      id: json['id'],
      tournamentId: json['tournamentId'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      age: json['age'],
      registrationTime: DateTime.parse(json['registrationTime']),
      isPaid: json['isPaid'] ?? false,
      parentName: json['parentName'],
      parentPhone: json['parentPhone'],
      catches:
          (json['catches'] as List?)?.map((c) => Fish.fromJson(c)).toList() ??
              [],
      totalPoints: json['totalPoints'] ?? 0,
    );
  }

  IndividualRegistration copyWith({
    String? id,
    String? tournamentId,
    String? name,
    String? phoneNumber,
    int? age,
    DateTime? registrationTime,
    bool? isPaid,
    String? parentName,
    String? parentPhone,
    List<Fish>? catches,
    int? totalPoints,
  }) {
    return IndividualRegistration(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      registrationTime: registrationTime ?? this.registrationTime,
      isPaid: isPaid ?? this.isPaid,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      catches: catches ?? this.catches,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}

// models/tournament_code.dart
class TournamentCode {
  final String tournamentId;
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;
  final int maxRegistrations;
  final int currentRegistrations;

  TournamentCode({
    required this.tournamentId,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    this.isActive = true,
    this.maxRegistrations = 100,
    this.currentRegistrations = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isFull => currentRegistrations >= maxRegistrations;
  bool get isValid => isActive && !isExpired && !isFull;

  Map<String, dynamic> toJson() {
    return {
      'tournamentId': tournamentId,
      'code': code,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isActive': isActive,
      'maxRegistrations': maxRegistrations,
      'currentRegistrations': currentRegistrations,
    };
  }

  factory TournamentCode.fromJson(Map<String, dynamic> json) {
    return TournamentCode(
      tournamentId: json['tournamentId'],
      code: json['code'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      isActive: json['isActive'] ?? true,
      maxRegistrations: json['maxRegistrations'] ?? 100,
      currentRegistrations: json['currentRegistrations'] ?? 0,
    );
  }
}

// screens/registration/join_tournament_screen.dart
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

// screens/registration/registration_success_screen.dart
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
                  Text('Participant: ${registration.displayName}'),
                  Text('Registration ID: ${registration.id}'),
                  if (registration.isChild)
                    Text('Parent/Guardian: ${registration.parentName}'),
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
