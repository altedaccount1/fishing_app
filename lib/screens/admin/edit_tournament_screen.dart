// screens/admin/edit_tournament_screen.dart
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../services/data_service.dart';
import '../../utils/date_formatter.dart';

class EditTournamentScreen extends StatefulWidget {
  final Tournament tournament;

  const EditTournamentScreen({super.key, required this.tournament});

  @override
  State<EditTournamentScreen> createState() => _EditTournamentScreenState();
}

class _EditTournamentScreenState extends State<EditTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _hostClubController;
  late DateTime _selectedDate;
  late String _selectedStatus;
  bool _isLoading = false;

  final List<String> _statusOptions = ['upcoming', 'live', 'completed'];
  final List<String> _asacClubs = [
    'American Angler',
    'Anglesea Surf Anglers',
    'Atlantic City Salt Water Anglers',
    'Barrington Rod & Reel',
    'Creek Keepers Surf Fishing Team',
    'Delaware Valley Surf Anglers',
    'Fishin Fuzz',
    'Frann\'s Fans in the Sand',
    'Long Beach Island Fishing Club',
    'Merchantville Fishing Club',
    'New Jersey Beach Buggy Assoc.',
    'Ocean City Fishing Club',
    'Pennsauken Fishing Club',
    'Seaside Heights Fishing Club',
    'Surf n\'Land Sportsmen\'s Club',
    'Surf City Sea Anglers',
    'Team Top Notch',
    'Women\'s Surf Fishing Club of NJ',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tournament.name);
    _locationController =
        TextEditingController(text: widget.tournament.location);
    _hostClubController =
        TextEditingController(text: widget.tournament.hostClub);
    _selectedDate = widget.tournament.date;
    _selectedStatus = widget.tournament.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _hostClubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tournament'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTournament,
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
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
                        Icon(Icons.edit, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Edit Tournament',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Editing: ${widget.tournament.name}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    Text(
                      'Created: ${DateFormatter.formatLongDate(widget.tournament.date)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tournament Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tournament Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                  hintText: 'Enter tournament name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a tournament name';
                  }
                  if (value.length < 3) {
                    return 'Tournament name must be at least 3 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Enter tournament location',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tournament Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            DateFormatter.formatLongDate(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Host Club Dropdown
              DropdownButtonFormField<String>(
                value: _asacClubs.contains(_hostClubController.text)
                    ? _hostClubController.text
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Host Club',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                items: _asacClubs.map((club) {
                  return DropdownMenuItem(
                    value: club,
                    child: Text(club),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _hostClubController.text = value;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a host club';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Status Dropdown
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Tournament Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Icon(
                          status == 'live'
                              ? Icons.live_tv
                              : status == 'upcoming'
                                  ? Icons.schedule
                                  : Icons.check_circle,
                          size: 20,
                          color: status == 'live'
                              ? Colors.green
                              : status == 'upcoming'
                                  ? Colors.orange
                                  : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(status.toUpperCase()),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              // Tournament Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tournament Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Current Teams',
                      '${widget.tournament.teams.length}',
                      Icons.group,
                    ),
                    _buildInfoRow(
                      'Total Catches',
                      '${widget.tournament.catches.length}',
                      Icons.set_meal,
                    ),
                    _buildInfoRow(
                      'Tournament ID',
                      widget.tournament.id,
                      Icons.tag,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveTournament,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Saving...'),
                              ],
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Delete Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _showDeleteConfirmation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, size: 18),
                      SizedBox(width: 8),
                      Text('Delete Tournament'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Tournament Date',
      cancelText: 'Cancel',
      confirmText: 'Select',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTournament() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedTournament = widget.tournament.copyWith(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        hostClub: _hostClubController.text,
        date: _selectedDate,
        status: _selectedStatus,
      );

      final success = await DataService.updateTournament(updatedTournament);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Tournament updated successfully!'
                : 'Failed to update tournament'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving tournament: $e'),
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tournament'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Are you sure you want to delete "${widget.tournament.name}"?'),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone and will:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action is permanent and cannot be undone!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTournament();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTournament() async {
    setState(() => _isLoading = true);

    try {
      final success = await DataService.deleteTournament(widget.tournament.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Tournament "${widget.tournament.name}" deleted successfully'
                : 'Failed to delete tournament'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting tournament: $e'),
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
