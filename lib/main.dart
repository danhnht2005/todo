import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bot_toast/bot_toast.dart';
import 'config/themes/app_theme.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'config/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data for Vietnamese date formatting
  await initializeDateFormatting('vi');

  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

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

        // Providers (State Management)
        ChangeNotifierProvider(
          create: (context) =>
              AuthProvider(authService: context.read<AuthService>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Antigravity To-Do List',
        debugShowCheckedModeBanner: false,

        // BotToast
        builder: BotToastInit(),

        // Routing
        routerConfig: AppRouter.router,

        // Theme
        theme: AppTheme.lightTheme,

        // Dark Theme
        darkTheme: AppTheme.darkTheme,
      ),
    );
  }
}
