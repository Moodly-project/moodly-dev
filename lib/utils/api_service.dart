import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_config.dart';
import '../models/mood_entry.dart';

class ApiService {
  static const String _apiConfigKey = 'api_config';
  static ApiConfig? _cachedConfig;

  // Salvar configurações da API
  static Future<bool> saveApiConfig(ApiConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(config.toJson());
      
      final result = await prefs.setString(_apiConfigKey, jsonString);
      if (result) {
        _cachedConfig = config;
      }
      
      return result;
    } catch (e) {
      print('Erro ao salvar configurações da API: $e');
      return false;
    }
  }

  // Carregar configurações da API
  static Future<ApiConfig?> loadApiConfig() async {
    if (_cachedConfig != null) {
      return _cachedConfig;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_apiConfigKey);
      
      if (jsonString == null) {
        return null;
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      _cachedConfig = ApiConfig.fromJson(json);
      
      return _cachedConfig;
    } catch (e) {
      print('Erro ao carregar configurações da API: $e');
      return null;
    }
  }

  // Verificar se as configurações da API estão disponíveis
  static Future<bool> hasApiConfigured() async {
    final config = await loadApiConfig();
    return config != null && config.apiKey.isNotEmpty;
  }

  // Limpar configurações da API
  static Future<bool> clearApiConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.remove(_apiConfigKey);
      
      if (result) {
        _cachedConfig = null;
      }
      
      return result;
    } catch (e) {
      print('Erro ao limpar configurações da API: $e');
      return false;
    }
  }

  // Analisar entradas de humor (implementação futura)
  static Future<String?> analyzeMoodEntries(List<MoodEntry> entries) async {
    final config = await loadApiConfig();
    
    if (config == null || !config.analyzePatterns) {
      return null;
    }
    
    // Aqui seria a implementação real da chamada à API de IA
    // Por enquanto, retornamos uma análise simulada
    return 'Análise simulada: Seus registros mostram uma tendência de melhora no humor nos últimos dias. Momentos de tristeza ocorrem principalmente pela manhã.';
  }

  // Obter sugestões com base no humor (implementação futura)
  static Future<List<String>> getSuggestions(String currentMood) async {
    final config = await loadApiConfig();
    
    if (config == null || !config.provideSuggestions) {
      return [];
    }
    
    // Simulação de sugestões baseadas no humor atual
    switch (currentMood) {
      case 'Muito Feliz':
      case 'Feliz':
        return [
          'Continue com as atividades que te deixam feliz',
          'Compartilhe sua alegria com as pessoas próximas',
          'Aproveite para iniciar aquele projeto que você sempre quis'
        ];
      case 'Neutro':
        return [
          'Que tal uma caminhada ao ar livre?',
          'Pratique alguns minutos de meditação',
          'Entre em contato com um amigo querido'
        ];
      case 'Triste':
      case 'Muito Triste':
        return [
          'Respeite seu momento e permita-se sentir',
          'Tente uma atividade física leve, como caminhada',
          'Ouça músicas que elevem seu humor',
          'Considere conversar com alguém de confiança sobre como está se sentindo'
        ];
      default:
        return ['Tente registrar regularmente seus estados emocionais para receber sugestões mais personalizadas'];
    }
  }
} 