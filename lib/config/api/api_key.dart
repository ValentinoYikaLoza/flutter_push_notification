import 'package:dio/dio.dart';

// import '../constants/environment.dart';

class ApiKey {
  final Dio _dioBase = Dio(BaseOptions(baseUrl: 'https://3d5e-190-237-20-41.ngrok-free.app'));

  Future<Response> get(String path) async {
    return _dioBase.get(path);
  }
}
