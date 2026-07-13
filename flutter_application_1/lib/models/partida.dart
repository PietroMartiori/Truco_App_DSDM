/// Dados mutaveis de um dos dois times durante uma partida.
class Time {
  /// Nome mostrado para o time nas telas.
  String nome;
  /// Pontuacao atual do time.
  int pontos;
  /// Caminho/URL da foto escolhida; pode nao existir.
  String? fotoPath;
  Time({required this.nome, this.pontos = 0, this.fotoPath});
}

/// Registro imutavel de um acontecimento/rodada no historico da partida.
class Rodada {
  /// Texto que explica o que ocorreu na rodada (ex.: truco aceito).
  final String descricao;
  /// Placar do time A no instante do registro.
  final int pontosTimeA;
  /// Placar do time B no instante do registro.
  final int pontosTimeB;
  /// Momento em que o evento foi gravado.
  final DateTime data;

  Rodada({required this.descricao, required this.pontosTimeA, required this.pontosTimeB, required this.data});
}

/// Modelo completo que e mostrado nas telas e persistido pelo banco.
class Partida {
  // Identificador gerado pelo banco; nulo antes do primeiro salvamento.
  int? id;
  /// Primeiro time da partida.
  Time timeA;
  /// Segundo time da partida.
  Time timeB;
  /// Pontos necessarios para vencer.
  int metaPontos;
  /// Quantidade de jogadores escolhida no formulario.
  int numJogadores;
  /// Historico cronologico das rodadas/eventos.
  List<Rodada> rodadas;
  /// Data em que a partida foi criada.
  DateTime? dataInicio;
  /// Data em que a partida foi encerrada; nula enquanto em andamento.
  DateTime? dataFim;
  /// Nome do time vencedor; nulo enquanto nao houver vencedor.
  String? vencedor;

  /// Cria a partida; se nao receber rodadas, inicia uma lista vazia.
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

  /// Converte o objeto para colunas que o sqflite consegue salvar.
  Map<String, dynamic> toMap() => {
      'id': id,
      'nomeTimeA': timeA.nome,
      'nomeTimeB': timeB.nome,
      'pontosTimeA': timeA.pontos,
      'pontosTimeB': timeB.pontos,
      'fotoTimeA': timeA.fotoPath,
      'fotoTimeB': timeB.fotoPath,
      'metaPontos': metaPontos,
      'numJogadores': numJogadores,
      'dataInicio': (dataInicio ?? DateTime.now()).toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
      'vencedor': vencedor,
    };

  /// Reconstrói uma partida a partir de uma linha lida no banco.
  static Partida fromMap(Map<String, dynamic> map) {
    return Partida(
      id: map['id'],
      timeA: Time(
        nome: map['nomeTimeA'],
        pontos: map['pontosTimeA'],
        fotoPath: map['fotoTimeA'],
      ),
      timeB: Time(
        nome: map['nomeTimeB'],
        pontos: map['pontosTimeB'],
        fotoPath: map['fotoTimeB'],
      ),
      metaPontos: map['metaPontos'],
      numJogadores: map['numJogadores'],
      dataInicio: DateTime.tryParse(map['dataInicio'] ?? ''),
      dataFim: map['dataFim'] != null ? DateTime.tryParse(map['dataFim']) : null,
      vencedor: map['vencedor'],
    );
  }
}
