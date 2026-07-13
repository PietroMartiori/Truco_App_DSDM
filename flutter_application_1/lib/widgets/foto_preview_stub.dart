import 'package:flutter/material.dart';

/// Alternativa segura para plataformas sem leitura de arquivos/imagens web.
Widget fotoPreview(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) => Icon(Icons.image, size: width ?? height ?? 24); // Mostra um icone neutro.
