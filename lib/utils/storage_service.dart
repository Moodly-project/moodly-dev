import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';

class StorageService {
  static const String _entriesKey = 'mood_entries';

  // Salvar entradas do diário
  static Future<bool> saveMoodEntries(List<MoodEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = entries.map((entry) => entry.toJson()).toList();
      final entriesString = jsonEncode(entriesJson);
      return await prefs.setString(_entriesKey, entriesString);
    } catch (e) {
      print('Erro ao salvar entradas: $e');
      return false;
    }
  }

  // Carregar entradas do diário
  static Future<List<MoodEntry>> loadMoodEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesString = prefs.getString(_entriesKey);
      
      if (entriesString == null || entriesString.isEmpty) {
        return [];
      }
      
      final entriesJson = jsonDecode(entriesString) as List;
      return entriesJson
          .map((json) => MoodEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao carregar entradas: $e');
      return [];
    }
  }

  // Salvar preferência de "Lembrar-me"
  static Future<bool> saveRememberMe(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool('remember_me', value);
    } catch (e) {
      print('Erro ao salvar preferência: $e');
      return false;
    }
  }

  // Carregar preferência de "Lembrar-me"
  static Future<bool> getRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('remember_me') ?? false;
    } catch (e) {
      print('Erro ao carregar preferência: $e');
      return false;
    }
  }

  // Salvar credenciais do usuário (apenas para demonstração)
  static Future<bool> saveUserCredentials(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      return true;
    } catch (e) {
      print('Erro ao salvar credenciais: $e');
      return false;
    }
  }

  // Carregar email do usuário
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_email');
    } catch (e) {
      print('Erro ao carregar email: $e');
      return null;
    }
  }
} 