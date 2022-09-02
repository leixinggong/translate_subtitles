import 'dart:io';
import 'package:dio/dio.dart';

class NetworkManage {
  static final Dio _dioInstance = Dio(BaseOptions(
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json
  ));

  Future post(path, {required Map<String, dynamic> parmas}) async {
    dynamic data;
    try{
      Response response = await _dioInstance.post(path,data: parmas);
      if (response.statusCode == HttpStatus.ok) {
        data = response.data;
      }
    } catch (e) {
      rethrow;
    }
    return data;
  }
}