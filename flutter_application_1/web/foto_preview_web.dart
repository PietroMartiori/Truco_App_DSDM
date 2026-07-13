import 'package:flutter/material.dart';

Widget fotoPreview(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) => Image.network(path, width: width, height: height, fit: fit);
