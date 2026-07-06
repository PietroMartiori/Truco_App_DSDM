import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/historico_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TrucoApp());
}

class TrucoApp extends StatelessWidget {
  const TrucoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Truco',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HistoricoScreen(),
    );
  }
}