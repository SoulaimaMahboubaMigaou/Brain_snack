import 'package:brainsnack/database/database_helper.dart';
import 'package:brainsnack/models/app_user.dart';

class AuthService {
  AuthService({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<AppUser?> restoreSession() async {
    return _currentUser;
  }

  Future<AppUser> register({
    required String username,
    required String password,
  }) async {
    final cleanedUsername = username.trim();
    final existing = await _databaseHelper.getUserByUsername(cleanedUsername);
    if (existing != null) {
      throw Exception('That username is already taken.');
    }

    final user = AppUser(
      username: cleanedUsername,
      password: password,
      createdAt: DateTime.now(),
    );
    final id = await _databaseHelper.insertUser(user);
    _currentUser = user.copyWith(id: id);
    return _currentUser!;
  }

  Future<AppUser> login({
    required String username,
    required String password,
  }) async {
    final user = await _databaseHelper.getUserByUsername(username.trim());
    if (user == null || user.password != password) {
      throw Exception('Invalid username or password.');
    }
    _currentUser = user;
    return user;
  }

  Future<void> logout() async {
    _currentUser = null;
  }
}
