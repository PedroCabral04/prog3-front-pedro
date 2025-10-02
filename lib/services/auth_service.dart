import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/models.dart';

class AuthService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:8000'; // Ajuste para seu IP
  String? _token;
  User? _currentUser;
  late Dio _dio;

  AuthService() {
    _dio = Dio();
    _configureDio();
  }

  void _configureDio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);

    // Configurações específicas para web
    if (kIsWeb) {
      _dio.options.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      });

      // Remove headers que podem causar preflight
      _dio.options.headers.remove('Access-Control-Allow-Origin');
      _dio.options.headers.remove('Access-Control-Allow-Methods');
      _dio.options.headers.remove('Access-Control-Allow-Headers');
    }

    // Interceptor para logs e debugging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Enviando requisição para: ${options.uri}');
          print('Headers: ${options.headers}');
          print('Data: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('Resposta recebida: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('Erro na requisição: ${error.message}');
          print('Tipo do erro: ${error.type}');
          if (error.response != null) {
            print('Status Code: ${error.response!.statusCode}');
            print('Response data: ${error.response!.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  bool get isAuthenticated => _token != null;
  User? get currentUser => _currentUser;
  String? get token => _token;

  Future<bool> login(String email, String password) async {
    try {
      // Primeira tentativa: POST com form-urlencoded
      final response = await _dio.post(
        '/auth/login',
        data: {
          'grant_type': 'password',
          'username': email,
          'password': password,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {'Accept': 'application/json'},
          // Força a não usar preflight request
          method: 'POST',
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _token = data['access_token'];

        // Buscar dados do usuário atual
        await _fetchCurrentUser();

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erro no login: $e');
      if (e is DioException) {
        print('Dio Error: ${e.message}');
        print('Response: ${e.response?.data}');

        // Se for erro de CORS, tentar abordagem alternativa
        if (e.type == DioExceptionType.connectionError ||
            e.message?.contains('CORS') == true) {
          return await _tryAlternativeLogin(email, password);
        }
      }
      return false;
    }
  }

  Future<bool> _tryAlternativeLogin(String email, String password) async {
    try {
      print('Tentando login alternativo...');

      // Criar uma nova instância do Dio com configurações simples
      final simpleDio = Dio();
      simpleDio.options.baseUrl = baseUrl;
      simpleDio.options.connectTimeout = const Duration(seconds: 30);
      simpleDio.options.receiveTimeout = const Duration(seconds: 30);

      // Tentar com headers mínimos
      final response = await simpleDio.post(
        '/auth/login',
        data: 'grant_type=password&username=$email&password=$password',
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _token = data['access_token'];
        await _fetchCurrentUser();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erro no login alternativo: $e');
      return false;
    }
  }

  Future<void> _fetchCurrentUser() async {
    if (_token == null) return;

    try {
      // Tentar buscar usuário usando a API de usuários
      // Para isso, vamos precisar do ID do usuário ou buscar pelo token
      // Por enquanto, vamos simular com o primeiro usuário admin para teste
      await _tryFetchUserFromAPI();
    } catch (e) {
      print('Erro ao buscar usuário atual: $e');
    }
  }

  Future<void> _tryFetchUserFromAPI() async {
    try {
      // Para buscar usuário atual, usaremos uma instância externa do ApiService
      // Por enquanto, deixaremos como null até implementar endpoint /me
      _currentUser = null;
    } catch (e) {
      print('Erro ao buscar usuário da API: $e');
      _currentUser = null;
    }
  }

  // Método para definir o usuário atual externamente
  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _token = null;
    _currentUser = null;
    notifyListeners();
  }

  Map<String, String> get authHeaders {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }
}
