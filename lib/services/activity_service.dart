import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class ActivityService {
  // Obter cabeçalhos de autenticação
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obter todas as atividades
  static Future<Map<String, dynamic>> getAllActivities() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.activities),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'activities': data['activities']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao obter atividades'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao conectar com o servidor: $e'
      };
    }
  }

  // Obter atividades mais comuns do usuário
  static Future<Map<String, dynamic>> getMostCommonActivities({int limit = 10}) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userActivities}?limit=$limit'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'activities': data['activities']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao obter atividades mais comuns'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao conectar com o servidor: $e'
      };
    }
  }

  // Criar nova atividade
  static Future<Map<String, dynamic>> createActivity(String name) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.activities),
        headers: headers,
        body: jsonEncode({'name': name}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'activity': data['activity']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao criar atividade'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao conectar com o servidor: $e'
      };
    }
  }
} 