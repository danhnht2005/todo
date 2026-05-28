import 'package:bot_toast/bot_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/task/pages/search_page/search_page.dart';
import '../../features/task/pages/setting_page/setting_page.dart';
import '../../features/task/pages/setting_page/theme_page.dart';
import '../../features/task/pages/task_detail_page/task_detail_page.dart';
import '../../features/task/pages/custom_list_page/custom_list_page.dart';
import '../../features/task/pages/all_tasks_page/all_tasks_page.dart';
import '../../features/task/pages/planned_page/planned_page.dart';
import '../../features/task/pages/important_page/important_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/task/pages/my_day_page/my_day_page.dart';
import '../../features/task/pages/dashboard_page/dashboard_page.dart';
import '../../features/task/widgets/main_layout.dart';

/// AppRouter — Cấu hình GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    //BotToast observer
    observers: [BotToastNavigatorObserver()],

    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = Supabase.instance.client.auth.currentUser != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Chưa đăng nhập → về login
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // Đã đăng nhập mà vào trang auth → về home
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }

      return null; // Không redirect
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
          GoRoute(path: '/my-day', builder: (context, state) => const MyDayPage()),
          GoRoute(
            path: '/important',
            builder: (context, state) => const ImportantPage(),
          ),
          GoRoute(
            path: '/planned',
            builder: (context, state) => const PlannedPage(),
          ),
          GoRoute(
            path: '/all-tasks',
            builder: (context, state) => const AllTasksPage(),
          ),
          GoRoute(
            path: '/custom-list/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CustomListPage(id: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/task/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TaskDetailPage(id: id);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          return const SearchPage();
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingPage(),
        routes: [
          GoRoute(
            path: 'theme',
            builder: (context, state) => const ThemePage(),
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
