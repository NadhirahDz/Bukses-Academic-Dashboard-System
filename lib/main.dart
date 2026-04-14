import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school/dashboard_page.dart';
import 'package:school/home_page.dart';
import 'package:school/splashscreen.dart';
import 'package:school/upload_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Prestasi Pelajar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/': (context) => const LoginPage(),
        '/splash': (context) => const SplashScreen(),
        // Admin goes to HomeMenuPage (has Kemaskini Data)
        '/admin': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return HomeMenuPage(
            name: args['name'] ?? 'Pentadbir',
            role: 'admin',
            password: args['password'] ?? '',
          );
        },
        // Teachers go DIRECTLY to dashboard
        '/teacher4': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return DashboardPage(
            name: args['name'] ?? 'Cikgu',
            role: 'teacher_form4',
          );
        },
        '/teacher5': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return DashboardPage(
            name: args['name'] ?? 'Cikgu',
            role: 'teacher_form5',
          );
        },
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return HomeMenuPage(
            name: args['name'] ?? 'User',
            role: args['role'] ?? 'teacher_form4',
          );
        },
        '/dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return DashboardPage(
            name: args['name'] ?? '',
            role: args['role'] ?? 'admin',
          );
        },
        '/update': (context) => const UploadPage(),
      },
    );
  }
}
