import 'package:dio/dio.dart';
import 'auth_service.dart';

abstract class BaseApiService {
  static const String baseUrl = 'http://localhost:8000';
  final AuthService authService;
  late Dio dio;

  BaseApiService(this.authService) {
    dio = Dio();
    _configureDio();
  }

  void _configureDio() {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    // Interceptor para adicionar token automaticamente
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (authService.token != null) {
            options.headers['Authorization'] = 'Bearer ${authService.token}';
          }
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          handler.next(options);
        },
        onError: (error, handler) {
          print('API Error: ${error.message}');
          print('Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );
  }
}
