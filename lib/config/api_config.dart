class ApiConfig {
  // Substitua pelo endereço do seu servidor
  static const String baseUrl = 'http://192.168.1.100:3000/api';
  
  // Endpoints da API
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';
  static const String updateProfile = '/auth/profile';
  static const String updatePassword = '/auth/password';
  
  static const String moodEntries = '/mood-entries';
  static const String moodStats = '/mood-entries/stats';
  
  static const String activities = '/activities';
  static const String userActivities = '/activities/user/common';
} 