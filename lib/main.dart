import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bot_toast/bot_toast.dart';
import 'features/task/services/task_service.dart';
import 'features/task/providers/task_provider.dart';
import 'features/task_list/services/task_list_service.dart';
import 'features/task_list/providers/task_list_provider.dart';
import 'config/themes/app_theme.dart';
import 'config/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'config/routes/app_router.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data for Vietnamese date formatting
  await initializeDateFormatting('vi');

  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  // Initialize notification service (timezone + channels)
  await NotificationService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => TaskService()),

        // Providers (State Management)
        ChangeNotifierProvider(
          create: (context) =>
              AuthProvider(authService: context.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => TaskProvider(
            taskService: context.read<TaskService>(),
            notificationService: NotificationService.instance,
          ),
        ),
        Provider(create: (_) => TaskListService()),
        ChangeNotifierProvider(
          create: (context) =>
              TaskListProvider(repository: context.read<TaskListService>()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'To-Do',
            debugShowCheckedModeBanner: false,

            // BotToast
            builder: BotToastInit(),

            // Routing
            routerConfig: AppRouter.router,

            // Theme
            theme: AppTheme.lightTheme,

            // Dark Theme
            darkTheme: AppTheme.darkTheme,

            // Theme Mode
            themeMode: themeProvider.themeMode,
          );
        },
      ),
    );
  }
}
