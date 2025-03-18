import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';

  // Login de usuário
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Salvar token e dados do usuário
        await _saveToken(data['token']);
        await _saveUserData(data['user']);
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Erro ao fazer login'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro ao conectar com o servidor: $e'};
    }
  }

  // Registro de usuário
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Salvar token e dados do usuário
        await _saveToken(data['token']);
        await _saveUserData(data['user']);
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Erro ao registrar usuário'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro ao conectar com o servidor: $e'};
    }
  }

  // Obter perfil do usuário
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      
      if (token == null) {
        return {'success': false, 'message': 'Usuário não autenticado'};
      }

      final response = await http.get(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.profile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Atualizar dados do usuário
        await _saveUserData(data['user']);
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Erro ao obter perfil'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erro ao conectar com o servidor: $e'};
    }
  }

  // Sair (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Verificar se o usuário está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;
    
    try {
      // Verificar se o token está expirado
      final isTokenExpired = JwtDecoder.isExpired(token);
      return !isTokenExpired;
    } catch (e) {
      return false;
    }
  }

  // Salvar token JWT
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Obter token JWT
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Salvar dados do usuário
  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  // Obter dados do usuário
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userKey);
    
    if (userDataString == null) return null;
    
    return jsonDecode(userDataString) as Map<String, dynamic>;
  }

  // Salvar preferência de "Lembrar-me"
  static Future<bool> saveRememberMe(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_rememberMeKey, value);
    } catch (e) {
      print('Erro ao salvar preferência: $e');
      return false;
    }
  }

  // Carregar preferência de "Lembrar-me"
  static Future<bool> getRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      print('Erro ao carregar preferência: $e');
      return false;
    }
  }
} 