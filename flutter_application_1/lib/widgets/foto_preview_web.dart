import 'package:flutter/material.dart';

/// Exibe no navegador a URL temporária retornada pelo image_picker.
Widget fotoPreview(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) => Image.network(path, width: width, height: height, fit: fit);
