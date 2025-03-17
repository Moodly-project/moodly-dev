class ApiConfig {
  String provider;
  String apiKey;
  String? apiUrl;
  bool analyzePatterns;
  bool provideSuggestions;
  bool enableReminders;

  ApiConfig({
    required this.provider,
    required this.apiKey,
    this.apiUrl,
    this.analyzePatterns = true,
    this.provideSuggestions = true,
    this.enableReminders = false,
  });

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'apiKey': apiKey,
      'apiUrl': apiUrl,
      'analyzePatterns': analyzePatterns,
      'provideSuggestions': provideSuggestions,
      'enableReminders': enableReminders,
    };
  }

  // Criar a partir de JSON
  factory ApiConfig.fromJson(Map<String, dynamic> json) {
    return ApiConfig(
      provider: json['provider'] as String,
      apiKey: json['apiKey'] as String,
      apiUrl: json['apiUrl'] as String?,
      analyzePatterns: json['analyzePatterns'] as bool,
      provideSuggestions: json['provideSuggestions'] as bool,
      enableReminders: json['enableReminders'] as bool,
    );
  }
} 