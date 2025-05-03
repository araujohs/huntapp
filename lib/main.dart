import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HuntApp());
}

class HuntApp extends StatelessWidget {
  const HuntApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HuntApp',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
