// screens/judge/judge_screen.dart - UPDATED VERSION
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/team.dart';
import '../../models/individual_registration.dart';
import '../../models/fish.dart';
import '../../services/data_service.dart';
import '../../services/scoring_service.dart';
import '../../services/auth_service.dart';
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
  final _notesController = TextEditingController();

  String? _selectedTournament;
  String _participantType = 'team'; // 'team' or 'individual'
  String? _selectedParticipant;
  String? _selectedTeamMember;
  bool _isSubmitting = false;

  String get _currentJudgeClub {
    final user = AuthService.currentUser;
    return user?.club ?? 'Cape May Fishing Club';
  }

  @override
  void dispose() {
    _speciesController.dispose();
    _lengthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish Scoring'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showScoringHelp,
            tooltip: 'Scoring Help',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judge Info Card
            _buildJudgeInfoCard(),
            const SizedBox(height: 20),

            // Check if user can judge
            if (!AuthService.canScore)
              _buildAccessDeniedCard()
            else
              _buildJudgeContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildJudgeInfoCard() {
    return Container(
      width: double.infinity,
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

  Widget _buildAccessDeniedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.lock, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Judge Access Required',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'You need judge or admin permissions to score fish.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJudgeContent() {
    final judgableTournaments =
        DataService.getTournamentsByHostClub(_currentJudgeClub)
            .where((t) => t.status == 'live' || t.status == 'upcoming')
            .toList();

    if (judgableTournaments.isEmpty) {
      return _buildNoTournamentsCard();
    }

    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Tournament Selection
              DropdownButtonFormField<String>(
                value: _selectedTournament,
                decoration: const InputDecoration(
                  labelText: 'Tournament',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
                items: judgableTournaments.map((tournament) {
                  return DropdownMenuItem<String>(
                    value: tournament.id,
                    child: Text(tournament.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTournament = value;
                    _selectedParticipant = null;
                    _selectedTeamMember = null;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a tournament' : null,
              ),
              const SizedBox(height: 16),

              // Participant Type Selection
              if (_selectedTournament != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Participant Type:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'team',
                                    groupValue: _participantType,
                                    onChanged: (value) {
                                      setState(() {
                                        _participantType = value!;
                                        _selectedParticipant = null;
                                        _selectedTeamMember = null;
                                      });
                                    },
                                  ),
                                  const Text('Team'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'individual',
                                    groupValue: _participantType,
                                    onChanged: (value) {
                                      setState(() {
                                        _participantType = value!;
                                        _selectedParticipant = null;
                                        _selectedTeamMember = null;
                                      });
                                    },
                                  ),
                                  const Text('Individual'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Participant Selection
              if (_selectedTournament != null && _participantType == 'team')
                _buildTeamSelection(),

              if (_selectedTournament != null &&
                  _participantType == 'individual')
                _buildIndividualSelection(),

              // Team Member Selection (if team is selected)
              if (_participantType == 'team' && _selectedParticipant != null)
                _buildTeamMemberSelection(),

              const SizedBox(height: 16),

              // Species Selection
              DropdownButtonFormField<String>(
                value: _speciesController.text.isEmpty
                    ? null
                    : _speciesController.text,
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

              // Length Only (No Weight)
              TextFormField(
                controller: _lengthController,
                decoration: const InputDecoration(
                  labelText: 'Length (inches)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten),
                  suffixText: 'in',
                  helperText: 'Measure from tip of nose to end of tail',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _validateLength,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Points Preview (Length-based only)
              if (_canShowPointsPreview()) _buildPointsPreview(),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Judge Notes (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
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
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildRecentSubmissions(),
      ],
    );
  }

  Widget _buildTeamSelection() {
    final teams = _getTeamsForTournament(_selectedTournament!);

    return DropdownButtonFormField<String>(
      value: _selectedParticipant,
      decoration: const InputDecoration(
        labelText: 'Team',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.group),
      ),
      items: teams.map((team) {
        return DropdownMenuItem<String>(
          value: team.id,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(team.name),
              Text(
                '${team.club} • ${team.members.length} members',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedParticipant = value;
          _selectedTeamMember = null;
        });
      },
      validator: (value) => value == null ? 'Please select a team' : null,
    );
  }

  Widget _buildIndividualSelection() {
    final individuals =
        DataService.getIndividualRegistrations(_selectedTournament!)
            .where((reg) => reg.isPaid)
            .toList();

    return DropdownButtonFormField<String>(
      value: _selectedParticipant,
      decoration: const InputDecoration(
        labelText: 'Individual Participant',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      items: individuals.map((individual) {
        return DropdownMenuItem<String>(
          value: individual.id,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(individual.displayName),
              if (individual.isChild)
                Text(
                  'Parent: ${individual.parentName}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedParticipant = value;
        });
      },
      validator: (value) =>
          value == null ? 'Please select a participant' : null,
    );
  }

  Widget _buildTeamMemberSelection() {
    final team = _getTeamsForTournament(_selectedTournament!)
        .firstWhere((t) => t.id == _selectedParticipant);

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedTeamMember,
          decoration: const InputDecoration(
            labelText: 'Team Member Who Caught Fish',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          items: team.members.map((member) {
            return DropdownMenuItem<String>(
              value: member,
              child: Text(member),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedTeamMember = value;
            });
          },
          validator: (value) =>
              value == null ? 'Please select team member' : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNoTournamentsCard() {
    return Container(
      width: double.infinity,
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
            'No Active Tournaments',
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

  Widget _buildPointsPreview() {
    final length = double.tryParse(_lengthController.text);
    final species = _speciesController.text;

    if (length == null || species.isEmpty) {
      return const SizedBox();
    }

    // Calculate points based on length only (no weight)
    final points = ScoringService.calculatePoints(
      length: length,
      weight: 1.0, // Default weight since we don't weigh fish
      species: species,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calculate, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Points Preview',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$points points',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on ${length}" length',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          if (ScoringService.hasSpeciesBonus(species))
            Text(
              '${species} bonus applied!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
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
            width: double.infinity,
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
    final individual = DataService.getIndividualRegistrations(fish.tournamentId)
        .where((reg) => reg.id == fish.teamId)
        .firstOrNull;
    final tournament = DataService.getTournamentById(fish.tournamentId);

    final participantName =
        team?.name ?? individual?.displayName ?? "Unknown Participant";

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
        title: Text('${fish.species} - $participantName'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Length: ${fish.lengthDisplay} • ${fish.pointsDisplay}'),
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

  List<Team> _getTeamsForTournament(String tournamentId) {
    final tournament = DataService.getTournamentById(tournamentId);
    return tournament?.teams ?? [];
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

  bool _canShowPointsPreview() {
    return _lengthController.text.isNotEmpty &&
        _speciesController.text.isNotEmpty;
  }

  bool _canSubmit() {
    final participantSelected = _selectedParticipant != null;
    final teamMemberSelected =
        _participantType == 'individual' || _selectedTeamMember != null;

    return _selectedTournament != null &&
        participantSelected &&
        teamMemberSelected &&
        _speciesController.text.isNotEmpty &&
        _lengthController.text.isNotEmpty &&
        !_isSubmitting;
  }

  Future<void> _submitFish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final length = double.parse(_lengthController.text);
      final species = _speciesController.text;

      // Calculate points based on length only
      final points = ScoringService.calculatePoints(
        length: length,
        weight: 1.0, // Default weight
        species: species,
      );

      final newFish = Fish(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        teamId: _selectedParticipant!,
        tournamentId: _selectedTournament!,
        species: species,
        length: length,
        weight: 1.0, // Default weight since we don't weigh fish
        caughtTime: DateTime.now(),
        points: points,
        judgeId:
            'judge_${_currentJudgeClub.replaceAll(' ', '_').toLowerCase()}',
        verified: true,
        notes: _buildSubmissionNotes(),
      );

      DataService.addFishCatch(newFish);

      if (mounted) {
        final participantName = _getParticipantDisplayName();
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

  String _buildSubmissionNotes() {
    String notes = '';

    if (_participantType == 'team' && _selectedTeamMember != null) {
      notes += 'Caught by: $_selectedTeamMember';
    }

    if (_notesController.text.isNotEmpty) {
      if (notes.isNotEmpty) notes += '\n';
      notes += _notesController.text;
    }

    return notes.isNotEmpty ? notes : '';
  }

  String _getParticipantDisplayName() {
    if (_participantType == 'team') {
      final team = _getTeamsForTournament(_selectedTournament!)
          .firstWhere((t) => t.id == _selectedParticipant);
      return '${team.name} (${_selectedTeamMember})';
    } else {
      final individual =
          DataService.getIndividualRegistrations(_selectedTournament!)
              .firstWhere((reg) => reg.id == _selectedParticipant);
      return individual.displayName;
    }
  }

  void _clearForm() {
    _speciesController.clear();
    _lengthController.clear();
    _notesController.clear();
    setState(() {
      _selectedParticipant = null;
      _selectedTeamMember = null;
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
              Text('• Based on fish length only'),
              Text('• Length (inches) × 1.5 + base points'),
              Text('• Fish are NOT weighed in ASAC tournaments'),
              SizedBox(height: 16),
              Text('Species Multipliers:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Striped Bass: 1.2x multiplier'),
              Text('• Red Drum: 1.1x multiplier'),
              Text('• Tautog: 1.3x multiplier'),
              SizedBox(height: 16),
              Text('Participants:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Teams: Select team and specific member'),
              Text('• Individuals: Select registered participant'),
              Text('• Kids divisions tracked separately'),
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
