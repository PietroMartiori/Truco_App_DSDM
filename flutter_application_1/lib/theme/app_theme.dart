import 'package:flutter/material.dart';

/// Paleta centralizada: evita repetir codigos de cor nas telas.
class AppColors {
  // Cores das superficies escuras.
  static const background = Color(0xFF0F0F0F); // Fundo geral das telas.
  static const surface = Color(0xFF1A1A1A); // Fundo de cartoes e campos.
  static const surfaceElevated = Color(0xFF242424); // Superficie com destaque.
  static const border = Color(0xFF2E2E2E); // Bordas discretas.

  // Cores de acao, aviso e erro.
  static const neonGreen = Color(0xFF39FF6A); // Acao principal/sucesso.
  static const neonGreenDim = Color(0xFF1A4D2E); // Fundo verde suave.
  static const amber = Color(0xFFFFB830); // Destaque do truco.
  static const redAlert = Color(0xFFFF4444); // Erro, recusa ou exclusao.

  // Variacoes usadas para textos conforme sua importancia.
  static const textPrimary = Color(0xFFEEEEEE); // Texto mais importante.
  static const textSecondary = Color(0xFF888888); // Texto de apoio.
  static const textMuted = Color(0xFF444444); // Dica/icone pouco destacado.
}

/// Configuracao visual compartilhada por todo o MaterialApp.
class AppTheme {
  // Tema escuro aplicado em main.dart.
  static final dark = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.neonGreen,
      ),
      // Tipografia padrao para titulos, corpo e rotulos.
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 56,
          fontWeight: FontWeight.w800,
          letterSpacing: -2,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        labelSmall: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
      // Aparencia padrao de todos os TextField.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.neonGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      // Aparencia padrao dos botoes principais.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonGreen,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
}
