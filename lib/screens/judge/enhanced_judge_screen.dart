// screens/judge/enhanced_judge_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/tournament.dart';
import '../../models/team.dart';
import '../../models/individual_registration.dart';
import '../../models/fish.dart';
import '../../services/data_service.dart';
import '../../services/scoring_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_badge.dart';

class EnhancedJudgeScreen extends StatefulWidget {
  const EnhancedJudgeScreen({super.key});

  @override
  State<EnhancedJudgeScreen> createState() => _EnhancedJudgeScreenState();
}

class _EnhancedJudgeScreenState extends State<EnhancedJudgeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _speciesController = TextEditingController();
  final _lengthController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  final _participantSearchController = TextEditingController();

  String? _selectedTournament;
  dynamic _selectedParticipant; // Can be Team or IndividualRegistration
  File? _fishPhoto;
  Position? _currentLocation;
  bool _isSubmitting = false;
  bool _isGettingLocation = false;

  final ImagePicker _picker = ImagePicker();
  final String _currentJudgeClub = 'Cape May Fishing Club'; // From auth

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _speciesController.dispose();
    _lengthController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    _participantSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final judgableTournaments =
        DataService.getTournamentsByHostClub(_currentJudgeClub)
            .where((t) => t.status == 'live' || t.status == 'upcoming')
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish Submission'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showScoringHelp(),
            tooltip: 'Scoring Help',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judge Info Card
              _buildJudgeInfoCard(),
              const SizedBox(height: 20),

              // Location Status
              _buildLocationCard(),
              const SizedBox(height: 20),

              if (judgableTournaments.isEmpty)
                _buildNoTournamentsCard()
              else
                _buildSubmissionForm(judgableTournaments),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJudgeInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: const Icon(Icons.gavel, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tournament Judge',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  'Judging for: $_currentJudgeClub',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'ACTIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _currentLocation != null
            ? Colors.green.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _currentLocation != null
              ? Colors.green.shade200
              : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _currentLocation != null ? Icons.location_on : Icons.location_off,
            color: _currentLocation != null ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentLocation != null
                      ? 'Location Acquired'
                      : 'Getting Location...',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _currentLocation != null
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
                if (_currentLocation != null)
                  Text(
                    'Lat: ${_currentLocation!.latitude.toStringAsFixed(4)}, '
                    'Lng: ${_currentLocation!.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  )
                else
                  const Text(
                    'Location required for fish submission',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          if (_isGettingLocation)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Location',
            ),
        ],
      ),
    );
  }

  Widget _buildNoTournamentsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, color: Colors.orange, size: 48),
          const SizedBox(height: 12),
          const Text(
            'No Active Tournaments to Judge',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Your club ($_currentJudgeClub) is not currently hosting any active tournaments.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionForm(List<Tournament> tournaments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tournament Selection
        DropdownButtonFormField<String>(
          value: _selectedTournament,
          decoration: const InputDecoration(
            labelText: 'Tournament',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.event),
          ),
          items: tournaments.map((tournament) {
            return DropdownMenuItem<String>(
              value: tournament.id,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tournament.name),
                  Text(
                    '${tournament.location} • ${tournament.status.toUpperCase()}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedTournament = value;
              _selectedParticipant = null;
            });
          },
          validator: (value) =>
              value == null ? 'Please select a tournament' : null,
        ),
        const SizedBox(height: 16),

        // Participant Search and Selection
        if (_selectedTournament != null) ...[
          _buildParticipantSearch(),
          const SizedBox(height: 16),
        ],

        // Fish Photo
        _buildPhotoSection(),
        const SizedBox(height: 16),

        // Species Selection
        DropdownButtonFormField<String>(
          value:
              _speciesController.text.isEmpty ? null : _speciesController.text,
          decoration: const InputDecoration(
            labelText: 'Fish Species',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.set_meal),
          ),
          items: AppConstants.commonSpecies.map((species) {
            return DropdownMenuItem<String>(
              value: species,
              child: Row(
                children: [
                  Expanded(child: Text(species)),
                  if (ScoringService.hasSpeciesBonus(species))
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${ScoringService.getSpeciesMultiplier(species)}x',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              _speciesController.text = value;
              setState(() {});
            }
          },
          validator: (value) =>
              value == null ? 'Please select a species' : null,
        ),
        const SizedBox(height: 16),

        // Measurements
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _lengthController,
                decoration: const InputDecoration(
                  labelText: 'Length (inches)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten),
                  suffixText: 'in',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _validateLength,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (pounds)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                  suffixText: 'lbs',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _validateWeight,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Points Preview
        if (_canShowPointsPreview()) _buildPointsPreview(),

        // Notes
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Judge Notes (optional)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.note),
            hintText: 'Additional observations...',
          ),
          maxLines: 3,
          maxLength: 200,
        ),
        const SizedBox(height: 24),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canSubmit() ? _submitFish : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: _isSubmitting
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
                      Text('Submitting...'),
                    ],
                  )
                : const Text(
                    'Submit Fish Score',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _participantSearchController,
          decoration: InputDecoration(
            labelText: 'Search Participant',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _participantSearchController.clear();
                setState(() => _selectedParticipant = null);
              },
            ),
          ),
          onChanged: _searchParticipants,
        ),
        if (_selectedParticipant != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getParticipantName(_selectedParticipant),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _getParticipantType(_selectedParticipant),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, color: Colors.green.shade600),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fish Photo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _fishPhoto != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _fishPhoto!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () => setState(() => _fishPhoto = null),
                        icon: const Icon(Icons.close, color: Colors.red),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: _takeFishPhoto,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to take fish photo',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPointsPreview() {
    final length = double.tryParse(_lengthController.text);
    final weight = double.tryParse(_weightController.text);
    final species = _speciesController.text;

    if (length == null || weight == null || species.isEmpty)
      return const SizedBox();

    final breakdown = ScoringService.getPointsBreakdown(
      length: length,
      weight: weight,
      species: species,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              const Icon(Icons.calculate, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Points Calculation',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPointRow('Length points', '${breakdown['lengthPoints']}'),
          _buildPointRow('Weight points', '${breakdown['weightPoints']}'),
          if (breakdown['hasBonus'])
            _buildPointRow('Species bonus', '+${breakdown['bonusPoints']}',
                isBonus: true),
          const Divider(),
          _buildPointRow('Total Points', '${breakdown['totalPoints']}',
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPointRow(String label, String value,
      {bool isBonus = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isBonus ? Colors.green.shade700 : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 18 : 14,
              color: isBonus
                  ? Colors.green.shade700
                  : (isTotal ? Colors.blue : null),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() => _currentLocation = position);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _takeFishPhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (photo != null) {
        setState(() => _fishPhoto = File(photo.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _searchParticipants(String query) {
    if (query.length < 2 || _selectedTournament == null) return;

    // Search teams and individual registrations
    final tournament = DataService.getTournamentById(_selectedTournament!);
    final individuals =
        DataService.getIndividualRegistrations(_selectedTournament!);

    // Combine and search
    final allParticipants = <dynamic>[
      ...tournament?.teams ?? [],
      ...individuals.where((reg) => reg.isPaid),
    ];

    final matches = allParticipants.where((participant) {
      final name = _getParticipantName(participant).toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    if (matches.isNotEmpty) {
      setState(() => _selectedParticipant = matches.first);
    }
  }

  String _getParticipantName(dynamic participant) {
    if (participant is Team) {
      return participant.name;
    } else if (participant is IndividualRegistration) {
      return participant.displayName;
    }
    return 'Unknown';
  }

  String _getParticipantType(dynamic participant) {
    if (participant is Team) {
      return 'Team • ${participant.club}';
    } else if (participant is IndividualRegistration) {
      return participant.isChild ? 'Individual (Child)' : 'Individual (Adult)';
    }
    return 'Unknown';
  }

  String? _validateLength(String? value) {
    if (value == null || value.isEmpty) return 'Please enter length';
    final length = double.tryParse(value);
    if (length == null) return 'Please enter a valid number';
    if (length < AppConstants.minFishLength ||
        length > AppConstants.maxFishLength) {
      return 'Length must be between ${AppConstants.minFishLength}" and ${AppConstants.maxFishLength}"';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) return 'Please enter weight';
    final weight = double.tryParse(value);
    if (weight == null) return 'Please enter a valid number';
    if (weight < AppConstants.minFishWeight ||
        weight > AppConstants.maxFishWeight) {
      return 'Weight must be between ${AppConstants.minFishWeight} and ${AppConstants.maxFishWeight} lbs';
    }
    return null;
  }

  bool _canShowPointsPreview() {
    return _lengthController.text.isNotEmpty &&
        _weightController.text.isNotEmpty &&
        _speciesController.text.isNotEmpty;
  }

  bool _canSubmit() {
    return _selectedTournament != null &&
        _selectedParticipant != null &&
        _speciesController.text.isNotEmpty &&
        _lengthController.text.isNotEmpty &&
        _weightController.text.isNotEmpty &&
        _fishPhoto != null &&
        _currentLocation != null &&
        !_isSubmitting;
  }

  Future<void> _submitFish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final length = double.parse(_lengthController.text);
      final weight = double.parse(_weightController.text);
      final species = _speciesController.text;

      final points = ScoringService.calculatePoints(
        length: length,
        weight: weight,
        species: species,
      );

      final participantId = _selectedParticipant is Team
          ? (_selectedParticipant as Team).id
          : (_selectedParticipant as IndividualRegistration).id;

      final newFish = Fish(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        teamId: participantId,
        tournamentId: _selectedTournament!,
        species: species,
        length: length,
        weight: weight,
        caughtTime: DateTime.now(),
        points: points,
        judgeId:
            'judge_${_currentJudgeClub.replaceAll(' ', '_').toLowerCase()}',
        verified: true, // Judges verify immediately
        photoUrl: _fishPhoto!.path, // In real app, upload to cloud storage
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      DataService.addFishCatch(newFish);

      if (mounted) {
        final participantName = _getParticipantName(_selectedParticipant);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '$species submitted for $participantName! $points points awarded.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting fish: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _clearForm() {
    _speciesController.clear();
    _lengthController.clear();
    _weightController.clear();
    _notesController.clear();
    _participantSearchController.clear();
    setState(() {
      _selectedParticipant = null;
      _fishPhoto = null;
    });
  }

  void _showScoringHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ASAC Scoring Rules'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Point Calculation:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Length (inches) × 1.5'),
              Text('• Weight (pounds) × 3.0'),
              Text('• Total = Length Points + Weight Points'),
              SizedBox(height: 16),
              Text('Species Multipliers:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Striped Bass: 1.2x multiplier'),
              Text('• Red Drum: 1.1x multiplier'),
              Text('• Tautog: 1.3x multiplier'),
              SizedBox(height: 16),
              Text('Measurement Guidelines:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Measure from tip of nose to end of tail'),
              Text('• Weigh fish immediately after measurement'),
              Text('• Photo must show full fish clearly'),
              Text('• Location and timestamp are automatically recorded'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
