// Widgets e componentes visuais do Flutter.
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/historico_screen.dart';

/// Ponto de entrada: prepara o Flutter e inicia a arvore de widgets.
void main() {
  // Garante que plugins possam ser usados antes de o app ser desenhado.
  WidgetsFlutterBinding.ensureInitialized();
  // Insere o widget raiz na tela.
  runApp(const TrucoApp());
}

/// Widget raiz, responsavel pela configuracao geral do aplicativo.
class TrucoApp extends StatelessWidget {
  const TrucoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp define navegacao, tema e a tela inicial.
    return MaterialApp(
      title: 'Truco',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // O historico e a primeira tela exibida ao abrir o aplicativo.
      home: const HistoricoScreen(),
    );
  }
}
