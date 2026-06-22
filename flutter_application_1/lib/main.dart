import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/nova_partida_screen.dart';

void main() {
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
      home: const NovaPartidaScreen(),
    );
  }
}