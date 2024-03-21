import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

enum HttpMethod {
  getM,
  postM,
  deleteM,
  patchM,
}

class ApiResponse {
  final int statusCode;
  final Map<String, dynamic> body;
  final Uint8List bodyBytes;

  ApiResponse({
    required this.statusCode,
    required this.body,
    required this.bodyBytes,
  });
}

class Api {
  // static const String kApiUrl = "http://172.16.165.51:3000/api";
  static const String kApiUrl = "http://192.168.1.82:3000/api";

  static final Map<String, String> kApiHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  static Future<http.Response?> _getRequestCore(
    String url,
    Map<String, String> headers,
  ) async {
    http.Response? response;

    try {
      response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
    } on http.ClientException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return response;
  }

  static Future<http.Response?> _postRequestCore(
    String url,
    Map<String, dynamic> params,
    Map<String, String> headers,
  ) async {
    http.Response? response;

    try {
      response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(params),
      );
    } on http.ClientException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return response;
  }

  static Future<http.Response?> _deleteRequestCore(
    String url,
    Map<String, String> headers,
  ) async {
    http.Response? response;

    try {
      response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
    } on http.ClientException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return response;
  }

  static Future<http.Response?> _patchRequestCore(
    String url,
    Map<String, dynamic> params,
    Map<String, String> headers,
  ) async {
    http.Response? response;

    try {
      response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(params),
      );
    } on http.ClientException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return response;
  }

  static Future<ApiResponse?> _request(
      HttpMethod method, String url, Map<String, dynamic> params,
      {bool shouldDecodeBody = true}) async {
    var headers = kApiHeaders;
    http.Response? response;

    switch (method) {
      case HttpMethod.patchM:
        response = await _patchRequestCore(url, params, headers);
        break;
      case HttpMethod.deleteM:
        response = await _deleteRequestCore(url, headers);
        break;
      case HttpMethod.postM:
        response = await _postRequestCore(url, params, headers);
        break;
      case HttpMethod.getM:
        response = await _getRequestCore(url, headers);
        break;
    }

    if (response == null) return null;

    var body = <String, dynamic>{};
    if (shouldDecodeBody && response.body.isNotEmpty) {
      body = jsonDecode(response.body);
    }

    return ApiResponse(
      statusCode: response.statusCode,
      body: body,
      bodyBytes: response.bodyBytes,
    );
  }

  // static Future<ApiResponse?> _multipartRequest(
  //     String url, String field, String filePath) async {
  //   var headers = kApiHeaders;
  //   http.StreamedResponse? response;

  //   try {
  //     // create multipart request for POST
  //     var request = http.MultipartRequest("POST", Uri.parse(url));
  //     request.headers.addAll(headers);
  //     // create multipart using filepath
  //     final file = await http.MultipartFile.fromPath(field, filePath);
  //     // add the file to request
  //     request.files.add(file);
  //     response = await request.send();
  //   } on http.ClientException catch (e) {
  //     print(e);
  //   } catch (e) {
  //     print(e);
  //   }

  //   if (response == null) return null;

  //   final res = await http.Response.fromStream(response);

  //   return ApiResponse(
  //     statusCode: res.statusCode,
  //     body: jsonDecode(res.body),
  //     bodyBytes: res.bodyBytes,
  //   );
  // }

  static Future<ApiResponse?> getCubeScanners() async {
    print("requesting scanners");
    return _request(
      HttpMethod.getM,
      '$kApiUrl/cube-scanner',
      {},
      shouldDecodeBody: true,
    );
  }
}
