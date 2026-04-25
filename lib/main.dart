import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/themes/app_theme.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/pages/login_page.dart';

void main() async {
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
      child: MaterialApp(
        title: 'Antigravity To-Do List',
        debugShowCheckedModeBanner: false,

        home: const LoginPage(),

        // // Routing
        // routerConfig: AppRouter.router,

        // Theme
        theme: AppTheme.lightTheme,

        // Dark Theme
        darkTheme: AppTheme.darkTheme,
      ),
    );
  }
}
