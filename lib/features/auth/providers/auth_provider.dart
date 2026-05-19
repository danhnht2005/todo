import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({required AuthService authService})
    : _authService = authService {
    checkAuth();
  }

  bool _isLoading = false; //Kiểm tra đang tải hay không
  String? _errorMessage; //Lưu thông báo lỗi
  bool _isAuthenticated = false; //Kiểm tra đã đăng nhập hay chưa
  String? _userId; //Lưu id của user
  String? _displayName; //Lưu tên hiển thị của user
  String? _email; //Lưu email của user

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get displayName => _displayName;
  String? get email => _email;

  //Hàm set trạng thái đang tải và thông báo thay đổi cho các widget lắng nghe
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  //Kiểm tra trạng thái đăng nhập của user
  Future<void> checkAuth() async {
    final user = _authService.currentUser;
    if (user != null) {
      _isAuthenticated = true;
      _userId = user.id;
      _displayName = _authService.displayName;
      _email = _authService.email;
    } else {
      _isAuthenticated = false;
      _userId = null;
      _displayName = null;
      _email = null;
    }
    notifyListeners();
  }

  //Đăng nhập
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        _isAuthenticated = true;
        _userId = user.id;
        _displayName = user.userMetadata?['full_name'] ?? user.email ?? '';
        _email = user.email ?? '';
        _setLoading(false);
        return true;
      } else {
        _errorMessage = 'Đăng nhập thất bại';
        _isAuthenticated = false;
        _setLoading(false);
        return false;
      }
    } on AuthException catch (e) {
      _errorMessage = _mapAuthError(e.message);
      _isAuthenticated = false;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi: ${e.toString()}';
      _isAuthenticated = false;
      _setLoading(false);
      return false;
    }
  }

  //Đăng ký
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      final user = response.user;
      if (user != null) {
        _isAuthenticated = true;
        _userId = user.id;
        _displayName = fullName;
        _email = email;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = 'Đăng ký thất bại';
        _isAuthenticated = false;
        _setLoading(false);
        return false;
      }
    } on AuthException catch (e) {
      _errorMessage = _mapAuthError(e.message);
      _isAuthenticated = false;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi: ${e.toString()}';
      _isAuthenticated = false;
      _setLoading(false);
      return false;
    }
  }

  //Đăng xuất
  Future<void> logout() async {
    await _authService.signOut();
    _isAuthenticated = false;
    _userId = null;
    _displayName = null;
    _email = null;
    notifyListeners();
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Sai email hoặc mật khẩu';
    }
    if (message.contains('User already registered') || message.contains('already exists')) {
      return 'Email đã được đăng ký';
    }
    if (message.contains('Password should be')) {
      return 'Mật khẩu tối thiểu 6 ký tự';
    }
    if (message.contains('invalid email')) {
      return 'Email không hợp lệ';
    }
    return message;
  }
}
