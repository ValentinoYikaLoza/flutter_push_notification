import 'package:dio/dio.dart';
import 'package:push_app_notification/config/constants/environment.dart';
import 'package:push_app_notification/config/constants/storage_keys.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';
import 'package:push_app_notification/features/shared/services/storage_service.dart';

// import '../constants/environment.dart';

class ApiFMC {
  final Dio _dioBase = Dio(BaseOptions(baseUrl: Environment.urlFMC));

  InterceptorsWrapper interceptor = InterceptorsWrapper();

  ApiFMC() {
    interceptor = InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final apiKey = await StorageService.get<String>(StorageKeys.apiKey);
          if (apiKey == null) {
            throw ServiceException('API key is null');
          }
          options.headers['Authorization'] = 'Bearer $apiKey';
          //print('> Api correct $apiKey');
          // print('> Request to: ${options.uri}');
          // print('> Headers: ${options.headers}');
          handler.next(options);
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
