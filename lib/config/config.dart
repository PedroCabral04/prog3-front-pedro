import 'package:flutter/foundation.dart';

class Config {
  // URLs da API
  static const String productionApiUrl = 'https://programacaiii-api.onrender.com';
  static const String developmentApiUrl = 'http://localhost:8000';
  
  // URL atual baseada no modo de compilação
  static String get apiUrl {
    // Em modo web release, sempre usa produção
    if (kIsWeb && kReleaseMode) {
      return productionApiUrl;
    }
    
    // Se não for release mode, usa desenvolvimento
    if (!kReleaseMode) {
      return developmentApiUrl;
    }
    
    // Fallback para produção em outros casos
    return productionApiUrl;
  }
  
  // Também pode verificar se está rodando na web
  static bool get isWeb => kIsWeb;
  
  // Versão do app
  static const String appVersion = '1.0.0';
  
  // Timeout das requisições
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
