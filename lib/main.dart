import 'package:app/nutrition_page.dart';
import 'package:flutter/material.dart';
import 'chatbot_page.dart';
import 'signup.dart';
import 'login.dart';
import 'home.dart';
import 'data_input.dart';
import 'result_page.dart';
// ✅ harus sesuai nama file


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/signup', // Mulai dari SignUp
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HealthHomePage(),
        '/dataInput': (context) => const DataInputPage(),
        '/nutrition': (context) => const NutritionPage(),
        '/chatbot': (context) => const ChatbotPage(),
        '/result': (context) => const ResultPage()
      },
    );
  }
}
