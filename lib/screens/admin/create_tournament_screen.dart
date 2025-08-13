// screens/admin/create_tournament_screen.dart
import 'package:flutter/material.dart';
import '../../services/data_service.dart';
import '../../utils/date_formatter.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _hostClubController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  String _selectedStatus = 'upcoming';
  bool _isLoading = false;

  final List<String> _statusOptions = ['upcoming', 'live'];
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
        title: const Text('Create Tournament'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _createTournament,
            tooltip: 'Create Tournament',
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
                        Icon(Icons.add_circle, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Create New Tournament',
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
                      'Set up a new ASAC fishing tournament',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade600,
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
                  hintText: 'Enter tournament name (e.g., Spring Classic 2024)',
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
                  hintText:
                      'Enter tournament location (e.g., Cape Henlopen State Park)',
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
                value: _hostClubController.text.isEmpty
                    ? null
                    : _hostClubController.text,
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
                  labelText: 'Initial Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Icon(
                          status == 'live' ? Icons.live_tv : Icons.schedule,
                          size: 20,
                          color:
                              status == 'live' ? Colors.green : Colors.orange,
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

              // Tournament Guidelines
              Container(
                padding: const EdgeInsets.all(16),
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
                        Text(
                          'Tournament Setup Guidelines',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                        '• Tournament dates should be at least 1 week in advance'),
                    const Text(
                        '• Host club will manage judging and verification'),
                    const Text(
                        '• Teams can register after tournament creation'),
                    const Text('• Tournament can be edited until it goes live'),
                    const Text(
                        '• Set to "Live" status to begin accepting fish submissions'),
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
                      onPressed: _isLoading ? null : _createTournament,
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
                                Text('Creating...'),
                              ],
                            )
                          : const Text(
                              'Create Tournament',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
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

  Future<void> _createTournament() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate date is not in the past
    if (_selectedDate
        .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tournament date cannot be in the past'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tournamentId = await DataService.createTournament(
        name: _nameController.text.trim(),
        date: _selectedDate,
        location: _locationController.text.trim(),
        hostClub: _hostClubController.text,
        status: _selectedStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Tournament "${_nameController.text}" created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating tournament: $e'),
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
