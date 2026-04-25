import 'package:supabase_flutter/supabase_flutter.dart';

/// AuthService — Xử lý đăng nhập, đăng ký, đăng xuất qua Supabase
class AuthService {
  final SupabaseClient _client;

  AuthService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Đăng ký tài khoản mới
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    return response;
  }

  /// Đăng nhập bằng email + password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Lấy user hiện tại (null nếu chưa đăng nhập)
  User? get currentUser => _client.auth.currentUser;

  /// Kiểm tra đã đăng nhập chưa
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Lấy tên hiển thị
  String get displayName {
    final user = currentUser;
    if (user == null) return '';
    return user.userMetadata?['full_name'] ?? user.email ?? '';
  }

  /// Lấy email
  String get email => currentUser?.email ?? '';

  /// Stream theo dõi trạng thái auth (đăng nhập/đăng xuất)
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
