// screens/admin/tournament_registration_screen.dart
class TournamentRegistrationScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentRegistrationScreen({super.key, required this.tournament});

  @override
  State<TournamentRegistrationScreen> createState() => _TournamentRegistrationScreenState();
}

class _TournamentRegistrationScreenState extends State<TournamentRegistrationScreen> {
  String _selectedFilter = 'all';
  late TournamentCode _tournamentCode;

  final List<String> _filterOptions = [
    'all',
    'pending',
    'paid',
    'kids',
  ];

  @override
  void initState() {
    super.initState();
    _loadTournamentCode();
  }

  @override
  Widget build(BuildContext context) {
    final registrations = DataService.getIndividualRegistrations(widget.tournament.id);
    final filteredRegistrations = _getFilteredRegistrations(registrations);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tournament.name} Registration'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () => _showTournamentCode(),
            tooltip: 'Show Tournament Code',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats and Code Display
          _buildRegistrationStats(registrations),

          // Filter Bar
          _buildFilterBar(),

          // Registration List
          Expanded(
            child: filteredRegistrations.isEmpty
                ? _buildEmptyState()
                : _buildRegistrationList(filteredRegistrations),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTournamentCode(),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.qr_code, color: Colors.white),
        label: const Text('Show Code', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildRegistrationStats(List<IndividualRegistration> registrations) {
    final totalRegistrations = registrations.length;
    final paidRegistrations = registrations.where((r) => r.isPaid).length;
    final pendingRegistrations = totalRegistrations - paidRegistrations;
    final kidsRegistrations = registrations.where((r) => r.isChild).length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green.shade50,
      child: Column(
        children: [
          // Tournament Code Display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.confirmation_number, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text('Tournament Code: ', style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  _tournamentCode.code,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _copyCodeToClipboard(),
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy Code',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total', totalRegistrations.toString(), Colors.blue),
              ),
              Expanded(
                child: _buildStatCard('Paid', paidRegistrations.toString(), Colors.green),
              ),
              Expanded(
                child: _buildStatCard('Pending', pendingRegistrations.toString(), Colors.orange),
              ),
              Expanded(
                child: _buildStatCard('Kids', kidsRegistrations.toString(), Colors.purple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Colors.grey),
          const SizedBox(width: 8),
          const Text('Filter: '),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions
                    .map((filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_getFilterDisplayName(filter)),
                            selected: _selectedFilter == filter,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              }
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationList(List<IndividualRegistration> registrations) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: registrations.length,
      itemBuilder: (context, index) {
        final registration = registrations[index];
        return _buildRegistrationCard(registration);
      },
    );
  }

  Widget _buildRegistrationCard(IndividualRegistration registration) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: registration.isPaid ? Colors.green : Colors.orange,
                  child: Icon(
                    registration.isPaid ? Icons.paid : Icons.pending,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        registration.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (registration.isChild)
                        Text(
                          'Parent: ${registration.parentName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: registration.isPaid 
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    registration.isPaid ? 'PAID' : 'PENDING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: registration.isPaid ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Contact Information
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  registration.contactInfo,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.formatDateTime(registration.registrationTime),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            if (registration.totalPoints > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.emoji_events, size: 16, color: Colors.blue.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${registration.totalPoints} points (${registration.catches.length} fish)',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                if (!registration.isPaid) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _markAsPaid(registration),
                      icon: const Icon(Icons.paid, size: 16),
                      label: const Text('Mark as Paid'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewRegistrationDetails(registration),
                    icon: const Icon(Icons.info, size: 16),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showRegistrationActions(registration),
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'More Actions',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No registrations yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share the tournament code with participants',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showTournamentCode(),
            icon: const Icon(Icons.qr_code),
            label: const Text('Show Tournament Code'),
          ),
        ],
      ),
    );
  }

  List<IndividualRegistration> _getFilteredRegistrations(List<IndividualRegistration> registrations) {
    switch (_selectedFilter) {
      case 'pending':
        return registrations.where((r) => !r.isPaid).toList();
      case 'paid':
        return registrations.where((r) => r.isPaid).toList();
      case 'kids':
        return registrations.where((r) => r.isChild).toList();
      default:
        return registrations;
    }
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return 'All';
      case 'pending':
        return 'Pending Payment';
      case 'paid':
        return 'Paid';
      case 'kids':
        return 'Kids';
      default:
        return filter;
    }
  }

  void _loadTournamentCode() {
    _tournamentCode = DataService.getTournamentCode(widget.tournament.id) ?? 
        DataService.generateTournamentCode(widget.tournament.id);
  }

  void _showTournamentCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tournament Registration Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Tournament Code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tournamentCode.code,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share this code with participants after they pay their registration fee. '
              'They can enter this code in the app to join the tournament.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _copyCodeToClipboard(),
            child: const Text('Copy Code'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _copyCodeToClipboard() {
    Clipboard.setData(ClipboardData(text: _tournamentCode.code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tournament code copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _markAsPaid(IndividualRegistration registration) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text(
          'Mark ${registration.displayName} as paid?\n\n'
          'This will allow them to submit fish catches.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Mark as Paid'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DataService.markRegistrationAsPaid(registration.id);
        setState(() {});
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${registration.displayName} marked as paid'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _viewRegistrationDetails(IndividualRegistration registration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(registration.displayName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Registration ID', registration.id),
              _buildDetailRow('Name', registration.name),
              if (registration.age != null)
                _buildDetailRow('Age', '${registration.age}'),
              if (registration.phoneNumber != null)
                _buildDetailRow('Phone', registration.phoneNumber!),
              if (registration.isChild) ...[
                _buildDetailRow('Parent/Guardian', registration.parentName ?? 'Not provided'),
                _buildDetailRow('Parent Phone', registration.parentPhone ?? 'Not provided'),
              ],
              _buildDetailRow('Registration Time', DateFormatter.formatFullDateTime(registration.registrationTime)),
              _buildDetailRow('Payment Status', registration.isPaid ? 'PAID' : 'PENDING'),
              _buildDetailRow('Total Points', '${registration.totalPoints}'),
              _buildDetailRow('Fish Caught', '${registration.catches.length}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!registration.isPaid)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _markAsPaid(registration);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Mark as Paid'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showRegistrationActions(IndividualRegistration registration) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('View Details'),
            onTap: () {
              Navigator.pop(context);
              _viewRegistrationDetails(registration);
            },
          ),
          if (!registration.isPaid)
            ListTile(
              leading: const Icon(Icons.paid, color: Colors.green),
              title: const Text('Mark as Paid'),
              onTap: () {
                Navigator.pop(context);
                _markAsPaid(registration);
              },
            ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Registration'),
            onTap: () {
              Navigator.pop(context);
              _editRegistration(registration);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Remove Registration'),
            onTap: () {
              Navigator.pop(context);
              _removeRegistration(registration);
            },
          ),
        ],
      ),
    );
  }

  void _editRegistration(IndividualRegistration registration) {
    // TODO: Implement edit registration dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit registration feature coming soon!')),
    );
  }

  Future<void> _removeRegistration(IndividualRegistration registration) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Registration'),
        content: Text(
          'Are you sure you want to remove ${registration.displayName}\'s registration?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DataService.removeIndividualRegistration(registration.id);
        setState(() {});
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${registration.displayName} removed from tournament'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

// Add missing import
import 'package:flutter/services.dart';