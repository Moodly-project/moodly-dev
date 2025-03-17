import 'package:flutter/material.dart';

class AppTheme {
  // Novas cores para o projeto
  static const Color primaryColor = Color(0xFF3E8974); // Verde escuro
  static const Color secondaryColor = Color(0xFF93B5AB); // Verde médio
  static const Color accentColor = Color(0xFFAAD2B0); // Verde claro
  static const Color backgroundColor = Color(0xFFD9D9D9); // Cinza claro
  
  // Cores de estado emocional
  static const Color calmColor = Color(0xFF93B5AB); // Verde médio
  static const Color happyColor = Color(0xFFAAD2B0); // Verde claro
  static const Color sadColor = Color(0xFFD9D9D9); // Cinza claro
  static const Color anxiousColor = Color(0xFF3E8974); // Verde escuro
  static const Color angryColor = Color(0xFF3E8974); // Verde escuro
  
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