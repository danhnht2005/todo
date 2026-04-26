import 'package:bot_toast/bot_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/task/pages/home_page.dart';
import '../../features/task/pages/my_day_page.dart';
import '../../features/task/widgets/main_layout.dart';

/// AppRouter — Cấu hình GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    //BotToast observer
    observers: [BotToastNavigatorObserver()],

    initialLocation: '/home',
    redirect: (context, state) {
      final isAuthenticated = Supabase.instance.client.auth.currentUser != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Chưa đăng nhập → về login
      if (!isAuthenticated && !isAuthRoute) {
        return '/my-day';
      }

      // Đã đăng nhập mà vào trang auth → về home
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      return null; // Không redirect
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/my-day',
            builder: (context, state) => const MyDayPage(),
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
    ],
  );
}
