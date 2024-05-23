import 'package:dio/dio.dart';
import 'package:push_app_notification/config/constants/storage_keys.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';
import 'package:push_app_notification/features/shared/services/storage_service.dart';

class ApiAuth {
  final Dio _dioBase = Dio(BaseOptions(baseUrl: 'https://9375-190-237-20-41.ngrok-free.app'));

  InterceptorsWrapper interceptor = InterceptorsWrapper();

  ApiAuth() {
    interceptor = InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final userToken = await StorageService.get<String>(StorageKeys.userToken);
          if (userToken == null) {
            throw ServiceException('API key is null');
          }
          options.headers['Authorization'] = 'Bearer $userToken';
          // print('> Request to: ${options.uri}');
          // print('> Headers: ${options.headers}');
          handler.next(options);
          print('> Api correct $userToken');
        } catch (e) {
          print('> Error in interceptor: $e');
          handler.reject(DioException(
            requestOptions: options,
            error: e,
          ));
        }
      },
    );
    _dioBase.interceptors.add(interceptor);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dioBase.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {required Object data}) async {
    return _dioBase.post(path, data: data);
  }
}
