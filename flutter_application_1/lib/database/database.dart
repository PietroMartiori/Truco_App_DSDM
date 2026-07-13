// Escolhe automaticamente o banco nativo ou a implementacao web na compilacao.
export 'database_io.dart' if (dart.library.html) 'database_web.dart';
