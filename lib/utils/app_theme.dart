import 'package:flutter/material.dart';

class AppTheme {
  // Cores principais relacionadas à saúde mental
  static const Color primaryColor = Color(0xFF6A7FDB); // Azul acalmante
  static const Color secondaryColor = Color(0xFF9D88D9); // Lavanda relaxante
  static const Color accentColor = Color(0xFF5BC0BE); // Verde-água tranquilo
  static const Color backgroundColor = Color(0xFFF5F5F5); // Branco suave
  
  // Cores de estado emocional
  static const Color calmColor = Color(0xFF90CAFF); // Azul claro
  static const Color happyColor = Color(0xFFFFD166); // Amarelo
  static const Color sadColor = Color(0xFF9399A1); // Cinza azulado
  static const Color anxiousColor = Color(0xFFFF9F80); // Laranja suave
  static const Color angryColor = Color(0xFFFF6B6B); // Vermelho suave
  
  // Textos
  static const Color textPrimary = Color(0xFF2D3142); // Quase preto
  static const Color textSecondary = Color(0xFF6E7889); // Cinza
  
  // Estilos de texto
  static TextStyle headingStyle = const TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static TextStyle subheadingStyle = const TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static TextStyle bodyStyle = const TextStyle(
    fontSize: 16.0,
    color: textPrimary,
  );

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
} 