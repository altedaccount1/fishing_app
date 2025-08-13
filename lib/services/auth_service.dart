// services/auth_service.dart
import 'dart:math';
import '../models/user.dart';

class AuthService {
  static User? _currentUser;
  static bool _isInitialized = false;
  static List<User> _users = [];

  // Data change listeners
  static final List<Function()> _listeners = [];

  // Initialize with sample users
  static void initialize() {
    if (_isInitialized) return;

    _loadSampleUsers();
    _isInitialized = true;
  }

  static void _loadSampleUsers() {
    _users = [
      User(
        id: '1',
        email: 'admin@asaconline.org',
        firstName: 'John',
        lastName: 'Smith',
        role: UserRole.admin,
        club: 'Ocean City Fishing Club',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        phoneNumber: '(555) 123-4567',
        isActive: true,
      ),
      User(
        id: '2',
        email: 'captain@oceancity.com',
        firstName: 'Drew',
        lastName: 'Furst',
        role: UserRole.teamCaptain,
        club: 'Ocean City Fishing Club',
        teamId: '1',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        phoneNumber: '(555) 234-5678',
        isActive: true,
      ),
      User(
        id: '3',
        email: 'judge@delvalley.com',
        firstName: 'Mike',
        lastName: 'Johnson',
        role: UserRole.judge,
        club: 'Delaware Valley Surf Anglers',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        phoneNumber: '(555) 345-6789',
        isActive: true,
      ),
      User(
        id: '4',
        email: 'member@asac.com',
        firstName: 'Sarah',
        lastName: 'Wilson',
        role: UserRole.user,
        club: 'Seaside Heights Fishing Club',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        phoneNumber: '(555) 456-7890',
        isActive: true,
      ),
      User(
        id: '5',
        email: 'captain2@atlanticcity.com',
        firstName: 'Tom',
        lastName: 'Brown',
        role: UserRole.teamCaptain,
        club: 'Atlantic City Salt Water Anglers',
        teamId: '3',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        phoneNumber: '(555) 567-8901',
        isActive: true,
      ),
      User(
        id: '6',
        email: 'judge2@anglesea.com',
        firstName: 'Lisa',
        lastName: 'Davis',
        role: UserRole.judge,
        club: 'Anglesea Surf Anglers',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        phoneNumber: '(555) 678-9012',
        isActive: false, // Inactive user for testing
      ),
    ];

    // Auto-login as admin for development
    _currentUser = _users.first;
    _notifyListeners();
  }

  // Listener management
  static void addListener(Function() listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  // Authentication methods
  static Future<User?> signIn(String email, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Find user by email
    final user = _users
        .where((u) => u.email.toLowerCase() == email.toLowerCase())
        .firstOrNull;

    if (user != null && user.isActive) {
      _currentUser = user;
      _notifyListeners();
      return user;
    }

    return null; // Invalid credentials or inactive user
  }

  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _notifyListeners();
  }

  static Future<User?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? club,
    String? phoneNumber,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Check if email already exists
    if (_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      throw Exception('Email already exists');
    }

    // Validate email format
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }

    // Validate password strength
    if (!_isValidPassword(password)) {
      throw Exception('Password must be at least 6 characters');
    }

    // Create new user
    final newUser = User(
      id: _generateId(),
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: role,
      club: club,
      createdAt: DateTime.now(),
      phoneNumber: phoneNumber,
      isActive: true,
    );

    _users.add(newUser);
    _currentUser = newUser;
    _notifyListeners();

    return newUser;
  }

  // Current user management
  static User? get currentUser => _currentUser;
  static bool get isSignedIn => _currentUser != null;
  static UserRole? get currentUserRole => _currentUser?.role;

  // Role checks
  static bool get isAdmin => _currentUser?.isAdmin ?? false;
  static bool get isTeamCaptain => _currentUser?.isTeamCaptain ?? false;
  static bool get isJudge => _currentUser?.isJudge ?? false;
  static bool get canManageTournaments =>
      _currentUser?.canManageTournaments ?? false;
  static bool get canManageTeams => _currentUser?.canManageTeams ?? false;
  static bool get canScore => _currentUser?.canScore ?? false;

  // User CRUD operations (Admin only)
  static List<User> getAllUsers() {
    if (!isAdmin) return [];
    return List.unmodifiable(_users);
  }

  static User? getUserById(String userId) {
    if (!isAdmin) return null;
    try {
      return _users.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  static Future<String> createUser({
    required String email,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? club,
    String? phoneNumber,
    String? teamId,
  }) async {
    if (!isAdmin) throw Exception('Unauthorized: Admin access required');

    await Future.delayed(const Duration(milliseconds: 800));

    // Check if email already exists
    if (_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      throw Exception('Email already exists');
    }

    // Validate email format
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format');
    }

    // Validate required fields
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      throw Exception('First name and last name are required');
    }

    final newUser = User(
      id: _generateId(),
      email: email.toLowerCase(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      role: role,
      club: club?.trim(),
      teamId: teamId,
      createdAt: DateTime.now(),
      phoneNumber: phoneNumber?.trim(),
      isActive: true,
    );

    _users.add(newUser);
    _notifyListeners();
    return newUser.id;
  }

  static Future<bool> updateUser(User updatedUser) async {
    if (!isAdmin && _currentUser?.id != updatedUser.id) {
      throw Exception(
          'Unauthorized: Can only update own profile or admin access required');
    }

    await Future.delayed(const Duration(milliseconds: 600));

    // Check if email already exists for other users
    if (_users.any((u) =>
        u.id != updatedUser.id &&
        u.email.toLowerCase() == updatedUser.email.toLowerCase())) {
      throw Exception('Email already exists');
    }

    // Validate email format
    if (!_isValidEmail(updatedUser.email)) {
      throw Exception('Invalid email format');
    }

    // Validate required fields
    if (updatedUser.firstName.trim().isEmpty ||
        updatedUser.lastName.trim().isEmpty) {
      throw Exception('First name and last name are required');
    }

    final index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;

      // Update current user if it's the same user
      if (_currentUser?.id == updatedUser.id) {
        _currentUser = updatedUser;
      }

      _notifyListeners();
      return true;
    }
    return false;
  }

  static Future<bool> deleteUser(String userId) async {
    if (!isAdmin) throw Exception('Unauthorized: Admin access required');

    await Future.delayed(const Duration(milliseconds: 500));

    // Cannot delete yourself
    if (_currentUser?.id == userId) {
      throw Exception('Cannot delete your own account');
    }

    // Cannot delete if user is only admin
    final user = getUserById(userId);
    if (user?.role == UserRole.admin) {
      final adminCount =
          _users.where((u) => u.role == UserRole.admin && u.isActive).length;
      if (adminCount <= 1) {
        throw Exception('Cannot delete the last active admin');
      }
    }

    final countRemoved = _users.where((u) => u.id == userId).length;
    _users.removeWhere((u) => u.id == userId);

    if (countRemoved > 0) {
      _notifyListeners();
      return true;
    }
    return false;
  }

  static Future<void> updateUserRole(String userId, UserRole newRole) async {
    if (!isAdmin) throw Exception('Unauthorized: Admin access required');

    await Future.delayed(const Duration(milliseconds: 500));

    // Cannot change own role
    if (_currentUser?.id == userId) {
      throw Exception('Cannot change your own role');
    }

    // Validate role change for last admin
    final user = getUserById(userId);
    if (user?.role == UserRole.admin && newRole != UserRole.admin) {
      final adminCount =
          _users.where((u) => u.role == UserRole.admin && u.isActive).length;
      if (adminCount <= 1) {
        throw Exception('Cannot remove admin role from the last active admin');
      }
    }

    final userIndex = _users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      _users[userIndex] = _users[userIndex].copyWith(role: newRole);
      _notifyListeners();
    }
  }

  static Future<void> toggleUserStatus(String userId) async {
    if (!isAdmin) throw Exception('Unauthorized: Admin access required');

    await Future.delayed(const Duration(milliseconds: 500));

    // Cannot deactivate yourself
    if (_currentUser?.id == userId) {
      throw Exception('Cannot deactivate your own account');
    }

    final user = getUserById(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    // Cannot deactivate last admin
    if (user.role == UserRole.admin && user.isActive) {
      final activeAdminCount =
          _users.where((u) => u.role == UserRole.admin && u.isActive).length;
      if (activeAdminCount <= 1) {
        throw Exception('Cannot deactivate the last active admin');
      }
    }

    final userIndex = _users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      _users[userIndex] = _users[userIndex].copyWith(isActive: !user.isActive);
      _notifyListeners();
    }
  }

  // Profile updates (users can update their own profile)
  static Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? club,
  }) async {
    if (_currentUser == null) throw Exception('Not signed in');

    await Future.delayed(const Duration(milliseconds: 500));

    // Validate required fields
    final newFirstName = firstName ?? _currentUser!.firstName;
    final newLastName = lastName ?? _currentUser!.lastName;

    if (newFirstName.trim().isEmpty || newLastName.trim().isEmpty) {
      throw Exception('First name and last name are required');
    }

    _currentUser = _currentUser!.copyWith(
      firstName: newFirstName.trim(),
      lastName: newLastName.trim(),
      phoneNumber: phoneNumber?.trim(),
      club: club?.trim(),
    );

    // Update in the users list
    final userIndex = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (userIndex != -1) {
      _users[userIndex] = _currentUser!;
    }

    _notifyListeners();
  }

  // Quick login methods for development
  static void loginAsAdmin() {
    _currentUser =
        _users.where((u) => u.role == UserRole.admin && u.isActive).first;
    _notifyListeners();
  }

  static void loginAsTeamCaptain() {
    _currentUser =
        _users.where((u) => u.role == UserRole.teamCaptain && u.isActive).first;
    _notifyListeners();
  }

  static void loginAsJudge() {
    _currentUser =
        _users.where((u) => u.role == UserRole.judge && u.isActive).first;
    _notifyListeners();
  }

  static void loginAsUser() {
    _currentUser =
        _users.where((u) => u.role == UserRole.user && u.isActive).first;
    _notifyListeners();
  }

  // Validation helpers
  static bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  static bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return 'user_${timestamp}_$random';
  }
}
