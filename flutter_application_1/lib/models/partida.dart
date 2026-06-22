class Time {
  String nome;
  int pontos;

  Time({required this.nome, this.pontos = 0});
}

class Rodada {
  final String descricao;
  final int pontosTimeA;
  final int pontosTimeB;
  final DateTime data;

  Rodada({
    required this.descricao,
    required this.pontosTimeA,
    required this.pontosTimeB,
    required this.data,
  });
}

class Partida {
  int? id;
  Time timeA;
  Time timeB;
  int metaPontos;
  int numJogadores;
  List<Rodada> rodadas;
  DateTime? dataInicio;
  DateTime? dataFim;
  String? vencedor;

  Partida({
    this.id,
    required this.timeA,
    required this.timeB,
    required this.metaPontos,
    required this.numJogadores,
    List<Rodada>? rodadas,
    this.dataInicio,
    this.dataFim,
    this.vencedor,
  }) : rodadas = rodadas ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomeTimeA': timeA.nome,
      'nomeTimeB': timeB.nome,
      'pontosTimeA': timeA.pontos,
      'pontosTimeB': timeB.pontos,
      'metaPontos': metaPontos,
      'numJogadores': numJogadores,
      'dataInicio': (dataInicio ?? DateTime.now()).toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'vencedor': vencedor,
    };
  }

  static Partida fromMap(Map<String, dynamic> map) {
    return Partida(
      id: map['id'],
      timeA: Time(nome: map['nomeTimeA'], pontos: map['pontosTimeA']),
      timeB: Time(nome: map['nomeTimeB'], pontos: map['pontosTimeB']),
      metaPontos: map['metaPontos'],
      numJogadores: map['numJogadores'],
      dataInicio: DateTime.tryParse(map['dataInicio'] ?? ''),
      dataFim: map['dataFim'] != null ? DateTime.tryParse(map['dataFim']) : null,
      vencedor: map['vencedor'],
    );
  }
}