import '../models/user_model.dart';
import 'api_client.dart';
import 'api_config.dart';

class AuthResult {
  final UserModel? user;
  final String? error;
  final bool pending;
  AuthResult({this.user, this.error, this.pending = false});
}

class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  final _api = ApiClient();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  /// Restore session from saved token (call once on app start)
  Future<void> restoreSession() async {
    await _api.loadToken();
    if (_api.token == null) return;
    try {
      final res = await _api.get(ApiConfig.authMe);
      _currentUser = UserModel.fromJson(res['user'] as Map<String, dynamic>);
    } on ApiException {
      await _api.clearToken();
      _currentUser = null;
    }
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      final res = await _api.post(ApiConfig.authLogin, {
        'email': email,
        'password': password,
      });
      await _api.setToken(res['token'] as String);
      _currentUser = UserModel.fromJson(res['user'] as Map<String, dynamic>);
      return AuthResult(user: _currentUser);
    } on ApiException catch (e) {
      return AuthResult(error: e.message);
    } catch (e) {
      return AuthResult(error: 'Network error: $e');
    }
  }

  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final res = await _api.post(ApiConfig.authRegister, {
        'username': username,
        'email': email,
        'password': password,
        'role': UserModel.roleToApi(role),
      });
      if (res['pending'] == true) {
        return AuthResult(pending: true);
      }
      await _api.setToken(res['token'] as String);
      _currentUser = UserModel.fromJson(res['user'] as Map<String, dynamic>);
      return AuthResult(user: _currentUser);
    } on ApiException catch (e) {
      return AuthResult(error: e.message);
    } catch (e) {
      return AuthResult(error: 'Network error: $e');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _api.clearToken();
  }

  /// Refresh current user (e.g. after liking a video)
  Future<void> refreshCurrentUser() async {
    if (_api.token == null) return;
    try {
      final res = await _api.get(ApiConfig.authMe);
      _currentUser = UserModel.fromJson(res['user'] as Map<String, dynamic>);
    } catch (_) {}
  }

  /// Fetch a public user profile by id (no email returned).
  Future<UserModel?> getUserById(String id) async {
    try {
      final res = await _api.get(ApiConfig.authUserById(id));
      return UserModel.fromJson(res['user'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
