// screens/judge/judge_screen.dart
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/team.dart';
import '../../models/fish.dart';
import '../../services/data_service.dart';
import '../../services/scoring_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/status_badge.dart';

class JudgeScreen extends StatefulWidget {
  const JudgeScreen({super.key});

  @override
  State<JudgeScreen> createState() => _JudgeScreenState();
}

class _JudgeScreenState extends State<JudgeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _speciesController = TextEditingController();
  final _lengthController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedTournament;
  String? _selectedTeam;
  final String _currentJudgeClub =
      'Cape May Fishing Club'; // This would come from user auth

  @override
  void dispose() {
    _speciesController.dispose();
    _lengthController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show tournaments where this judge's club is hosting
    final judgableTournaments =
        DataService.getTournamentsByHostClub(_currentJudgeClub)
            .where((t) => t.status == 'live' || t.status == 'upcoming')
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 20),

            // Judge Info Card
            _buildJudgeInfoCard(),
            const SizedBox(height: 20),

            // Scoring Form
            if (judgableTournaments.isEmpty)
              _buildNoTournamentsCard()
            else
              _buildScoringForm(judgableTournaments),

            const SizedBox(height: 32),

            // Recent Submissions
            _buildRecentSubmissions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.gavel, size: 28, color: Colors.blue),
        const SizedBox(width: 12),
        const Text(
          'Fish Scoring',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => _showScoringHelp(),
          tooltip: 'Scoring Help',
        ),
      ],
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
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Judge/Official',
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
              'JUDGE',
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

  Widget _buildScoringForm(List<Tournament> tournaments) {
    return Column(
      children: [
        // Tournament Selection
        _buildDropdownField(
          value: _selectedTournament,
          label: 'Tournament',
          icon: Icons.event,
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
              _selectedTeam = null; // Reset team selection
            });
          },
          validator: (value) =>
              value == null ? 'Please select a tournament' : null,
        ),
        const SizedBox(height: 16),

        // Team Selection
        if (_selectedTournament != null)
          _buildDropdownField(
            value: _selectedTeam,
            label: 'Team',
            icon: Icons.group,
            items: _getCompetingTeamsForTournament(_selectedTournament!)
                .map((team) {
              return DropdownMenuItem<String>(
                value: team.id,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(team.name),
                    Text(
                      '${team.club} • ${team.membersDisplay}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTeam = value;
              });
            },
            validator: (value) => value == null ? 'Please select a team' : null,
          ),
        if (_selectedTournament != null) const SizedBox(height: 16),

        // Species Selection
        _buildDropdownField(
          value:
              _speciesController.text.isEmpty ? null : _speciesController.text,
          label: 'Fish Species',
          icon: Icons.set_meal,
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
              setState(() {}); // Trigger rebuild to show multiplier info
            }
          },
          validator: (value) =>
              value == null ? 'Please select a species' : null,
        ),
        const SizedBox(height: 16),

        // Show species bonus info
        if (_speciesController.text.isNotEmpty &&
            ScoringService.hasSpeciesBonus(_speciesController.text))
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.green.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_speciesController.text} has a ${ScoringService.getSpeciesMultiplier(_speciesController.text)}x point multiplier!',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (_speciesController.text.isNotEmpty &&
            ScoringService.hasSpeciesBonus(_speciesController.text))
          const SizedBox(height: 16),

        // Length and Weight Row
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _lengthController,
                label: 'Length (inches)',
                icon: Icons.straighten,
                suffix: 'in',
                validator: _validateLength,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(
                controller: _weightController,
                label: 'Weight (pounds)',
                icon: Icons.scale,
                suffix: 'lbs',
                validator: _validateWeight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Notes Field
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.note),
            hintText: 'Additional observations...',
          ),
          maxLines: 3,
          maxLength: 200,
        ),
        const SizedBox(height: 16),

        // Points Preview
        if (_lengthController.text.isNotEmpty &&
            _weightController.text.isNotEmpty &&
            _speciesController.text.isNotEmpty)
          _buildPointsPreview(),

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Submit Fish Score',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixText: suffix,
        prefixIcon: Icon(icon),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
      onChanged: (_) => setState(() {}), // Update points preview
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
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
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
          _buildPointRow(
            'Total Points',
            '${breakdown['totalPoints']}',
            isTotal: true,
          ),
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

  Widget _buildRecentSubmissions() {
    final recentCatches = DataService.getRecentCatches(limit: 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Submissions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        if (recentCatches.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No fish submissions yet',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...recentCatches.map((fish) => _buildSubmissionCard(fish)),
      ],
    );
  }

  Widget _buildSubmissionCard(Fish fish) {
    final team = DataService.getTeamById(fish.teamId);
    final tournament = DataService.getTournamentById(fish.tournamentId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: fish.verified ? Colors.green : Colors.orange,
          child: Icon(
            fish.verified ? Icons.verified : Icons.pending,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text('${fish.species} - ${team?.name ?? "Unknown Team"}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${fish.measurementDisplay} • ${fish.pointsDisplay}'),
            Text(
              '${tournament?.name ?? "Unknown Tournament"} • ${DateFormatter.getRelativeTime(fish.caughtTime)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing:
            VerificationBadge(verified: fish.verified, pending: !fish.verified),
      ),
    );
  }

  List<Team> _getCompetingTeamsForTournament(String tournamentId) {
    return DataService.getCompetingTeamsForTournament(
        tournamentId, _currentJudgeClub);
  }

  String? _validateLength(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the length';
    }
    final length = double.tryParse(value);
    if (length == null) {
      return 'Please enter a valid number';
    }
    if (length < AppConstants.minFishLength ||
        length > AppConstants.maxFishLength) {
      return 'Length must be between ${AppConstants.minFishLength}" and ${AppConstants.maxFishLength}"';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the weight';
    }
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number';
    }
    if (weight < AppConstants.minFishWeight ||
        weight > AppConstants.maxFishWeight) {
      return 'Weight must be between ${AppConstants.minFishWeight} and ${AppConstants.maxFishWeight} lbs';
    }
    return null;
  }

  bool _canSubmit() {
    return _selectedTournament != null &&
        _selectedTeam != null &&
        _speciesController.text.isNotEmpty &&
        _lengthController.text.isNotEmpty &&
        _weightController.text.isNotEmpty;
  }

  void _submitFish() {
    if (_formKey.currentState!.validate()) {
      final length = double.parse(_lengthController.text);
      final weight = double.parse(_weightController.text);
      final species = _speciesController.text;

      // Validate measurements
      final errors = ScoringService.validateFishMeasurements(
        length: length,
        weight: weight,
        species: species,
      );

      if (errors.isNotEmpty) {
        _showValidationErrors(errors);
        return;
      }

      final points = ScoringService.calculatePoints(
        length: length,
        weight: weight,
        species: species,
      );

      final newFish = Fish(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        teamId: _selectedTeam!,
        tournamentId: _selectedTournament!,
        species: species,
        length: length,
        weight: weight,
        caughtTime: DateTime.now(),
        points: points,
        judgeId:
            'judge_${_currentJudgeClub.replaceAll(' ', '_').toLowerCase()}',
        verified: true, // Judges verify immediately
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      DataService.addFishCatch(newFish);

      setState(() {
        _clearForm();
      });

      final team = DataService.getTeamById(_selectedTeam!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fish submitted and verified! $points points awarded to ${team?.name}.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showValidationErrors(Map<String, String?> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors.values
              .where((error) => error != null)
              .map(
                (error) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $error'),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _speciesController.clear();
    _lengthController.clear();
    _weightController.clear();
    _notesController.clear();
    _selectedTeam = null;
  }

  void _showScoringHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ASAC Scoring Rules'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Point Calculation:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• Length (inches) × ${AppConstants.lengthMultiplier}'),
              Text('• Weight (pounds) × ${AppConstants.weightMultiplier}'),
              const Text('• Total = Length Points + Weight Points'),
              const SizedBox(height: 16),
              const Text(
                'Species Multipliers:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...AppConstants.speciesMultipliers.entries
                  .where((entry) => entry.value > 1.0)
                  .map((entry) =>
                      Text('• ${entry.key}: ${entry.value}x multiplier')),
              const SizedBox(height: 16),
              const Text(
                'Measurement Guidelines:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Measure from tip of nose to end of tail'),
              const Text('• Weigh fish immediately after catch'),
              const Text('• Verify species identification'),
              const Text('• Check minimum size requirements'),
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
