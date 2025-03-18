import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/mood_entry.dart';
import 'auth_service.dart';

class MoodEntryService {
  // Obter cabeçalhos de autenticação
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Criar nova entrada de humor
  static Future<Map<String, dynamic>> createMoodEntry(MoodEntry entry) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.moodEntries),
        headers: headers,
        body: jsonEncode({
          'date': entry.date.toIso8601String(),
          'mood': entry.mood,
          'moodScore': entry.moodScore,
          'note': entry.note,
          'activities': entry.activities,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'entry': MoodEntry.fromJson(data['entry'])
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao criar registro de humor'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao conectar com o servidor: $e'
      };
    }
  }

  // Obter todas as entradas de humor
  static Future<Map<String, dynamic>> getMoodEntries({
    int? limit,
    int? offset,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      // Construir URL com parâmetros de consulta
      var uri = Uri.parse(ApiConfig.baseUrl + ApiConfig.moodEntries);
      
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      
      uri = uri.replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final entriesList = (data['entries'] as List)
            .map((json) => MoodEntry.fromJson(json as Map<String, dynamic>))
            .toList();
            
        return {
          'success': true,
          'entries': entriesList,
          'count': data['count']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao obter registros de humor'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao conectar com o servidor: $e'
      };
    }
  }

  // Obter entrada de humor por ID
  static Future<Map<String, dynamic>> getMoodEntryById(int id) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.moodEntries}/$id'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'entry': MoodEntry.fromJson(data['entry'])
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao obter registro de humor'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao conectar com o servidor: $e'
      };
    }
  }

  // Atualizar entrada de humor
  static Future<Map<String, dynamic>> updateMoodEntry(int id, MoodEntry entry) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.moodEntries}/$id'),
        headers: headers,
        body: jsonEncode({
          'date': entry.date.toIso8601String(),
          'mood': entry.mood,
          'moodScore': entry.moodScore,
          'note': entry.note,
          'activities': entry.activities,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'entry': MoodEntry.fromJson(data['entry'])
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao atualizar registro de humor'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao conectar com o servidor: $e'
      };
    }
  }

  // Excluir entrada de humor
  static Future<Map<String, dynamic>> deleteMoodEntry(int id) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.moodEntries}/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao excluir registro de humor'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao conectar com o servidor: $e'
      };
    }
  }

  // Obter estatísticas de humor
  static Future<Map<String, dynamic>> getMoodStats(String period) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.moodStats}?period=$period'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'stats': data['stats']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao obter estatísticas de humor'
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