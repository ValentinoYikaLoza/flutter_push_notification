import 'package:dio/dio.dart';
import 'package:push_app_notification/config/constants/environment.dart';
import 'package:push_app_notification/config/constants/storage_keys.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';
import 'package:push_app_notification/features/shared/services/storage_service.dart';

class Api {
  final Dio _dioBase = Dio(BaseOptions(baseUrl: Environment.urlBASE));

  InterceptorsWrapper interceptor = InterceptorsWrapper();

  Api() {
    interceptor = InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final userToken = await StorageService.get<String>(StorageKeys.userToken);
          if (userToken == null) {
            throw ServiceException('API key is null');
          }
          options.headers['Authorization'] = 'Bearer $userToken';
          options.headers['Accept'] = 'aplication/json';
          // print('> Api correct $userToken');
          // print('> Request to: ${options.uri}');
          // print('> Headers: ${options.headers}');
          handler.next(options);
        } catch (e) {
          // print('> Error in interceptor: $e');
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

  Future<Response> delete(String path, {required Object data}) async {
    return _dioBase.delete(path, data: data);
  }
}
