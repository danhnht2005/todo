import 'package:bot_toast/bot_toast.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';

/// AppRouter — Cấu hình GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    //BotToast observer
    observers: [BotToastNavigatorObserver()],

    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
    ],
  );
}
