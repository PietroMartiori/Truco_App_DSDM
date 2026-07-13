# Truco App

Aplicativo em Flutter para registrar e acompanhar partidas de Truco entre dois times.

## O que é o projeto

O app funciona como um placar digital de Truco. Em vez de anotar os pontos no papel, os jogadores criam uma nova partida, cadastram os dois times (podendo tirar uma foto de cada um pela câmera do dispositivo) e vão registrando o placar rodada a rodada até que um time vença.

Depois que a partida termina, ela fica salva no histórico, onde é possível abrir uma linha do tempo com todos os eventos da partida (início, cada rodada e o fim de jogo), junto com os horários e a duração total da partida.

## Principais funcionalidades

- **Nova partida**: cadastro dos times, com opção de foto de cada time.
- **Placar**: tela para ir somando os pontos das rodadas em tempo real.
- **Histórico**: lista de todas as partidas já jogadas.
- **Linha do tempo**: detalhamento de uma partida específica, mostrando início, rodadas e resultado final, com o tempo total de duração calculado a partir do horário de início e fim.

## Tecnologias

- **Flutter / Dart**
- **sqflite** — banco de dados local (armazenamento das partidas)
- **image_picker** — captura de fotos pela câmera
- **timeline_tile** — construção da linha do tempo visual
- **intl** — formatação de datas e horários

## Estrutura básica

```
lib/
├── models/      # Modelos de dados (Partida, etc.)
├── screens/     # Telas do app (nova partida, placar, histórico, timeline, foto)
├── widgets/     # Componentes reutilizáveis (ex: preview de foto)
└── database/    # Camada de persistência local
```