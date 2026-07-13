import 'dart:io';

import 'package:flutter/material.dart';

/// Exibe, no celular/desktop, a imagem localizada no caminho do arquivo.
Widget fotoPreview(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) => Image.file(File(path), width: width, height: height, fit: fit);
