// Export condicional: cada plataforma usa sua propria forma de exibir imagem.
export 'foto_preview_stub.dart'
    if (dart.library.io) 'foto_preview_io.dart'
    if (dart.library.html) 'foto_preview_web.dart';
