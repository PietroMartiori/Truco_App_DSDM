import 'package:flutter/material.dart';
import 'models/partida.dart';
import 'models/time.dart';
import 'screens/placar_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Truco',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      home: const NovaPartidaPage(),
    );
  }
}

class NovaPartidaPage extends StatefulWidget {
  const NovaPartidaPage({super.key});

  @override
  State<NovaPartidaPage> createState() => _NovaPartidaPageState();
}

class _NovaPartidaPageState extends State<NovaPartidaPage> {
  int jogadoresSelecionado = 4;

  final TextEditingController timeAController = TextEditingController();
  final TextEditingController timeBController = TextEditingController();

  void _iniciarPartida() {
    final partida = Partida(
      timeA: Time(
        nome: timeAController.text.isEmpty ? 'Nos' : timeAController.text,
      ),
      timeB: Time(
        nome: timeBController.text.isEmpty ? 'Eles' : timeBController.text,
      ),
      metaPontos: jogadoresSelecionado == 4 ? 12 : 18,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacarScreen(partida: partida),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'nova partida',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'configure antes de começar',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              const Text(
                'JOGADORES',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _opcaoJogadores(4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _opcaoJogadores(6),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                jogadoresSelecionado == 4
                    ? 'meta: 12 pts'
                    : 'meta: 18 pts',
                style: const TextStyle(color: Colors.greenAccent),
              ),

              const SizedBox(height: 24),

              const Text(
                'TIME A',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: timeAController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Ex: Nos',
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'TIME B',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: timeBController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Ex: Eles',
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _iniciarPartida,
                  child: const Text('começar'),
                ),
              ),

              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'ao pressionar, o placar é zerado',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _opcaoJogadores(int valor) {
    final bool selecionado = jogadoresSelecionado == valor;

    return GestureDetector(
      onTap: () {
        setState(() {
          jogadoresSelecionado = valor;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          border: Border.all(
            color: selecionado ? Colors.greenAccent : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$valor',
              style: TextStyle(
                color: selecionado ? Colors.greenAccent : Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'jogadores',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}