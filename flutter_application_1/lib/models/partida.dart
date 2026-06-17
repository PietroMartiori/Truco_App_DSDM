import 'time.dart';
import 'rodada.dart';

class Partida {
  Time timeA;
  Time timeB;
  int metaPontos;
  List<Rodada> rodadas;

  Partida({
    required this.timeA,
    required this.timeB,
    required this.metaPontos,
    List<Rodada>? rodadas,
  }) : rodadas = rodadas ?? [];
}