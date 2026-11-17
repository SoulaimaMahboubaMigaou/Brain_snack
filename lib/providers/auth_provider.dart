import 'package:brainsnack/auth/auth_service.dart';
import 'package:brainsnack/models/app_user.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  AppUser? currentUser;
  bool isLoading = false;
  String? errorMessage;

  bool get isAuthenticated => currentUser != null;

  Future<void> restoreSession() async {
    currentUser = await _authService.restoreSession();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      currentUser = await _authService.login(
        username: username,
        password: password,
      );
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      currentUser = await _authService.register(
        username: username,
        password: password,
      );
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    currentUser = null;
    errorMessage = null;
    notifyListeners();
  }
}
