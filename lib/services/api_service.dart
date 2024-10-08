// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:adk_tools/config/adk_tools_init.dart';

import '../config/app_config.dart';
import '../utils/app_storage.dart';
import '../utils/app_utils.dart';
import 'package:dio/dio.dart';

enum Method { POST, GET, PUT, DELETE, PATCH }

class ApiService {
  Dio? _dio;

  Future<ApiService> init() async {
    logSys('Api Service Initialized - ${AppConfig.baseUrl}');
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );
    initInterceptors();
    return this;
  }

  void initInterceptors() {
    _dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (requestOptions, handler) {
          logSys(
            '[REQUEST_METHOD] : ${requestOptions.method}\n[URL] : ${requestOptions.baseUrl}\n[PATH] : ${requestOptions.path}'
            '\n[PARAMS_VALUES] : ${requestOptions.data}\n[QUERY_PARAMS_VALUES] : ${requestOptions.queryParameters}\n[HEADERS] : ${requestOptions.headers}',
          );
          return handler.next(requestOptions);
        },
        onResponse: (response, handler) {
          logSys(
            '[RESPONSE_STATUS_CODE] : ${response.statusCode}\n[RESPONSE_DATA] : ${jsonEncode(response.data)}\n',
          );
          return handler.next(response);
        },
        onError: (err, handler) {
          logSys('Error-> ${err}]');
          logSys('Error[${err.response?.statusCode}]');
          return handler.next(err);
        },
      ),
    );
  }

  static Future<Map<String, dynamic>> getHeader({
    Map<String, dynamic>? headers,
    required bool isToken,
  }) async {
    final header = <String, dynamic>{'Content-Type': 'application/json'};
    final token = await AppStorage.read(key: ADKTools.boxToken);

    // Jika headers tidak null, tambahkan semua headers yang ada ke header baru
    if (headers != null) {
      header.addAll(headers);
    }

    if (isToken) {
      header['Authorization'] = 'Bearer $token';
    }
    return header;
  }

  getGatewayKey(int unixtime, {isProd = true}) async {
    var result = '';
    if (isProd) {
      result = AppUtils.encryptHMAC(unixtime, ADKTools.apiKey);
    } else {
      result = ADKTools.apiDevKey;
    }
    return result;
  }

  Future<dynamic> request(
      {required String url,
      required Method method,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? parameters,
      FormData? formData,
      bool isToken = true,
      bool isCustomResponse = false,
      bool isProd = true}) async {
    Response response;

    final params = parameters ?? <String, dynamic>{};

    final header = await getHeader(headers: headers, isToken: isToken);

    try {
      final unixTime = DateTime.now().millisecondsSinceEpoch;
      // Tambahkan gatewayKey ke header jika diperlukan
      if (isProd) {
        final gatewayKey = await getGatewayKey(unixTime, isProd: isProd);
        header['gateway_key'] = gatewayKey;
        header['unixtime'] = unixTime.toString();
      } else {
        header['gateway_key'] = ADKTools.apiDevKey;
        header['unixtime'] = unixTime.toString();
      }

      if (_dio == null) {
        _dio = Dio(BaseOptions(
          baseUrl: AppConfig.baseUrl,
          headers: header,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ));
        initInterceptors();
      }

      if (method == Method.POST) {
        response = await _dio!.post(url, data: formData ?? parameters);
      } else if (method == Method.PUT) {
        response = await _dio!.put(url, data: formData ?? parameters);
      } else if (method == Method.DELETE) {
        response = await _dio!.delete(url, queryParameters: params);
      } else if (method == Method.PATCH) {
        response = await _dio!.patch(url);
      } else {
        response = await _dio!.get(url, queryParameters: params);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else if (response.statusCode == 500) {
        throw Exception('Server Error');
      } else {
        throw Exception("Something does wen't wrong");
      }
    } on SocketException catch (e) {
      logSys(e.toString());
      throw Exception('Not Internet Connection');
    } on FormatException catch (e) {
      logSys(e.toString());
      throw Exception('Bad response format');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        final response = e.response;
        try {
          if (response != null) {
            return response.data;
          }
        } catch (e) {
          throw Exception('Internal Error : $e');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Request timeout');
      } else if (e.error is SocketException) {
        throw Exception('No Internet Connection!');
      }
    } catch (e) {
      rethrow;
    }
  }
}
