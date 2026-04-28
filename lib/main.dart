import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const LoopzApp());
}

class LoopzApp extends StatelessWidget {
  const LoopzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'Loopz',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF1a1a2e),
          colorScheme: const ColorScheme.dark(
            primary: Colors.pinkAccent,
            secondary: Colors.pinkAccent,
            surface: Color(0xFF1a1a2e),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        home: Consumer<AppProvider>(
          builder: (context, provider, _) {
            if (provider.initializing) {
              return const _SplashScreen();
            }
            if (provider.isLoggedIn) {
              return const HomeShell();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.pinkAccent, Colors.deepPurple.shade400],
                  ),
                ),
                child: const Icon(Icons.play_arrow_rounded, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'Loopz',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(color: Colors.pinkAccent, strokeWidth: 2),
            ],
          ),
        ),
      ),
    );
  }
}
