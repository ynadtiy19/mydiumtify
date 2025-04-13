import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http; // 导入 dart_frog

// 默认 Firebase API 密钥
const String DEFAULT_API_KEY =
    'AIzaSyDtC7Uwb5pGAsdmrH2T4Gqdk5Mga07jYPM'; // 替换为你的 Firebase API 密钥

// API 终结点
const String FIREBASE_AUTH_BASE_URL =
    'https://identitytoolkit.googleapis.com/v1/accounts';
const String FIREBASE_TOKEN_URL = 'https://securetoken.googleapis.com/v1/token';

/// 封装 SesameAI API 错误的基类
class SesameAIError implements Exception {
  final String message;
  SesameAIError(this.message);
  @override
  String toString() => 'SesameAIError: $message';
}

/// 表示身份验证失败时引发的异常（令牌无效等）
class AuthenticationError extends SesameAIError {
  AuthenticationError(String message) : super(message);
}

/// 表示 API 返回错误响应时引发的异常
class APIError extends SesameAIError {
  final int code;
  final List<Map<String, dynamic>>? errors;

  APIError(this.code, String message, {this.errors}) : super(message);

  @override
  String toString() => 'APIError $code: $message, errors: $errors';
}

/// 表示 ID 令牌无效或过期时引发的异常
class InvalidTokenError extends AuthenticationError {
  InvalidTokenError() : super('Invalid or expired ID token');
}

/// 表示网络通信失败时引发的异常
class NetworkError extends SesameAIError {
  NetworkError(String message) : super(message);
}

/// API 响应的基类
class BaseResponse {
  final Map<String, dynamic> rawResponse;

  BaseResponse(this.rawResponse);

  @override
  String toString() {
    final className = runtimeType.toString();
    final attributes = rawResponse.keys
        .where((k) => k != 'raw_response')
        .map((k) => '$k=${rawResponse[k]}')
        .join(', ');
    return '$className($attributes)';
  }
}

/// 来自注册端点的响应
class SignupResponse extends BaseResponse {
  final dynamic kind;
  final dynamic idToken;
  final dynamic refreshToken;
  final dynamic expiresIn;
  final dynamic localId;

  SignupResponse(Map<String, dynamic> responseJson)
      : kind = responseJson['kind'],
        idToken = responseJson['idToken'],
        refreshToken = responseJson['refreshToken'],
        expiresIn = responseJson['expiresIn'],
        localId = responseJson['localId'],
        super(responseJson);
}

/// 来自令牌刷新端点的响应
class RefreshTokenResponse extends BaseResponse {
  final dynamic accessToken;
  final dynamic expiresIn;
  final dynamic tokenType;
  final dynamic refreshToken;
  final dynamic idToken;
  final dynamic userId;
  final dynamic projectId;

  RefreshTokenResponse(Map<String, dynamic> responseJson)
      : accessToken = responseJson['access_token'],
        expiresIn = responseJson['expires_in'],
        tokenType = responseJson['token_type'],
        refreshToken = responseJson['refresh_token'],
        idToken = responseJson['id_token'],
        userId = responseJson['user_id'],
        projectId = responseJson['project_id'],
        super(responseJson);
}

/// 来自帐户查找端点的响应
class LookupResponse extends BaseResponse {
  final dynamic kind;
  final dynamic localId;
  final dynamic lastLoginAt;
  final dynamic createdAt;
  final dynamic lastRefreshAt;

  LookupResponse(Map<String, dynamic> responseJson)
      : kind = responseJson['kind'],
        localId = responseJson['users']?[0]?['localId'],
        lastLoginAt = responseJson['users']?[0]?['lastLoginAt'],
        createdAt = responseJson['users']?[0]?['createdAt'],
        lastRefreshAt = responseJson['users']?[0]?['lastRefreshAt'],
        super(responseJson);
}

/// 生成 x-firebase-client 标头值
String getFirebaseClientHeader() {
  final xFirebaseClient = {
    'version': 2,
    'heartbeats': [
      {
        'agent':
            'fire-core/0.11.1 fire-core-esm2017/0.11.1 fire-js/ fire-js-all-app/11.3.1 fire-auth/1.9.0 fire-auth-esm2017/1.9.0',
        'dates': [DateTime.now().toString().split(' ')[0]]
      }
    ]
  };
  final xFirebaseClientJson = json.encode(xFirebaseClient);
  final encoded = base64.encode(utf8.encode(xFirebaseClientJson));
  return encoded;
}

/// 获取标准 User-Agent 字符串
String getUserAgent() {
  return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36';
}

/// 获取 API 请求的标头
Map<String, String> getHeaders(String requestType) {
  final commonHeaders = {
    'accept': '*/*',
    'accept-language': 'en-US,en;q=0.9',
    'content-type': 'application/json',
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36',
    'x-firebase-client': getFirebaseClientHeader(),
    'x-client-data': 'COKQywE=',
    'x-client-version': 'Chrome/JsCore/11.3.1/FirebaseCore-web',
    'x-firebase-gmpid': '1:1072000975600:web:75b0bf3a9bb8d92e767835',
  };

  // 根据需要添加特定于请求的标头
  if (requestType == 'signup') {
    return commonHeaders;
  } else if (requestType == 'lookup') {
    return commonHeaders;
  } else if (requestType == 'refresh') {
    return commonHeaders;
  } else {
    return commonHeaders;
  }
}

/// 获取 API 请求的 URL 参数
Map<String, String> getParams(String requestType, {String? apiKey}) {
  // 使用提供的 API 密钥或回退到默认密钥
  final key = apiKey ?? DEFAULT_API_KEY;

  final commonParams = {
    'key': key,
  };

  // 根据需要添加特定于请求的参数
  if (requestType == 'signup') {
    return commonParams;
  } else if (requestType == 'lookup') {
    return commonParams;
  } else if (requestType == 'refresh') {
    return commonParams;
  } else {
    return commonParams;
  }
}

/// 获取特定请求类型的完整 URL
String getEndpointUrl(String requestType) {
  if (requestType == 'refresh') {
    return FIREBASE_TOKEN_URL;
  } else {
    final endpoint = requestType == 'signup' ? 'signUp' : requestType;
    return '$FIREBASE_AUTH_BASE_URL:$endpoint';
  }
}

/// SesameAI API 客户端 - SesameAI API 的非官方 Dart 客户端
///
/// 为 SesameAI 服务提供身份验证和帐户管理功能。
class SesameAI {
  final String? apiKey;

  /// 初始化 SesameAI API 客户端
  ///
  /// [apiKey]：Firebase API 密钥。如果未提供，将使用配置中的默认密钥。
  SesameAI({this.apiKey});

  /// 向 Firebase Authentication API 发出请求
  ///
  /// [requestType]：请求类型（'signup'、'lookup' 等）。
  /// [payload]：请求负载。
  /// [isFormData]：指示负载是否应作为表单数据发送。
  ///
  /// 返回：
  /// API 响应作为 JSON
  ///
  /// 抛出：
  /// NetworkError：如果发生网络错误
  /// APIError：如果 API 返回错误响应
  /// InvalidTokenError：如果令牌无效
  Future<Map<String, dynamic>> _makeAuthRequest(
      String requestType, Map<String, dynamic> payload,
      {bool isFormData = false}) async {
    final headers = getHeaders(requestType);
    final params = getParams(requestType, apiKey: apiKey);
    final url = getEndpointUrl(requestType);

    try {
      final uri = Uri.parse(url).replace(queryParameters: params);
      final http.Response response;
      if (isFormData) {
        response = await http.post(
          uri,
          headers: headers,
          body: payload, //  payload 已经是 Map<String,String>
        );
      } else {
        response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(payload),
        );
      }

      // 检查 HTTP 错误
      if (response.statusCode != 200) {
        //改为检查 200
        throw NetworkError(
            'HTTP error: ${response.statusCode}, body: ${response.body}'); // 抛出 NetworkError
      }
      // 解析响应
      final responseJson = jsonDecode(response.body);

      // 检查 API 错误
      if (responseJson is Map && responseJson.containsKey('error')) {
        // 修改这里
        _handleApiError(responseJson['error'] as Map<String, dynamic>); //调用内部函数
      }
      return responseJson as Map<String, dynamic>; // 修改这里
    } catch (e) {
      if (e is NetworkError) {
        rethrow; //  NetworkError 异常
      } else {
        throw NetworkError('Failed to make request: $e');
      }
    }
  }

  /// 处理 API 错误响应
  ///
  /// [error]：来自 API 的错误信息。
  ///
  /// 抛出：
  /// InvalidTokenError：如果令牌无效
  /// APIError：对于其他 API 错误
  void _handleApiError(Map<String, dynamic> error) {
    final errorCode = error['code'] ?? 400; //  int
    final errorMessage = error['message'] ?? 'Unknown error';
    final errorDetails = error['errors']?.cast<Map<String, dynamic>>() ??
        []; // List<Map<String,dynamic>>

    // 处理特定错误类型
    if (errorMessage == 'INVALID_ID_TOKEN' ||
        errorMessage == 'INVALID_REFRESH_TOKEN') {
      throw InvalidTokenError();
    }

    // 通用 API 错误
    throw APIError(errorCode as int, errorMessage as String,
        errors:
            errorDetails as List<Map<String, dynamic>>?); // 传递  errorDetails
  }

  /// 创建一个匿名帐户
  ///
  /// 返回：
  /// 包含身份验证令牌的 SignupResponse 对象
  ///
  /// 抛出：
  /// NetworkError：如果发生网络错误
  /// APIError：如果 API 返回错误响应
  Future<SignupResponse> createAnonymousAccount() async {
    final payload = {
      'returnSecureToken': true,
    };
    final responseJson = await _makeAuthRequest('signup', payload);
    return SignupResponse(responseJson);
  }

  /// 使用刷新令牌刷新 ID 令牌
  ///
  /// [refreshToken]：Firebase 刷新令牌
  ///
  /// 返回：
  /// 包含新令牌的 RefreshTokenResponse 对象
  ///
  /// 抛出：
  /// NetworkError：如果发生网络错误
  /// APIError：如果 API 返回错误响应
  /// InvalidTokenError：如果刷新令牌无效
  Future<RefreshTokenResponse> refreshAuthenticationToken(
      String refreshToken) async {
    final payload = {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken
    };

    final responseJson =
        await _makeAuthRequest('refresh', payload, isFormData: true);
    return RefreshTokenResponse(responseJson);
  }

  /// 使用 ID 令牌获取帐户信息
  ///
  /// [idToken]：Firebase ID 令牌
  ///
  /// 返回：
  /// 包含帐户信息的 LookupResponse 对象
  ///
  /// 抛出：
  /// NetworkError：如果发生网络错误
  /// APIError：如果 API 返回错误响应
  /// InvalidTokenError：如果 ID 令牌无效
  Future<LookupResponse> getAccountInfo(String idToken) async {
    final payload = {
      'idToken': idToken,
    };

    final responseJson = await _makeAuthRequest('lookup', payload);
    return LookupResponse(responseJson);
  }
}

// Dart Frog handler function
Future<Response> onRequest(RequestContext context) async {
  //请求路径 https://mydiumtify.globeapp.dev/sesameai
  if (context.request.method == HttpMethod.post) {
    try {
      // // 创建 SesameAI 客户端实例
      // final apiClient = SesameAI();
      // // 创建匿名帐户并获取 SignupResponse
      // final signupResponse = await apiClient.createAnonymousAccount();
      // // 从 SignupResponse 中提取 ID 令牌
      // final idToken = signupResponse.idToken;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDtC7Uwb5pGAsdmrH2T4Gqdk5Mga07jYPM'),
      );

      request.fields.addAll({
        'returnSecureToken': 'true',
      });

      final response = await request.send();
      dynamic idToken = 'this is test id token';

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString(); // 转成字符串
        final data = jsonDecode(responseBody); // 转成Map
        idToken = data['idToken']; // 提取idToken
      } else {
        idToken = await response.stream.bytesToString();
      }
      return Response.json(
        body: {'id_token': idToken},
      );
    } catch (e) {
      // 捕获并打印任何异常
      print('Error: $e');
      return Response.json(body: {'错误': '获取idToken时发生错误'}, statusCode: 500);
    }
  } else if (context.request.method == HttpMethod.get) {
    return Response.json(
      body: {'message': 'Welcome to the API', 'status': 'success'},
    );
  }

  return Response.json(
    body: {'message': 'Invalid request', 'status': 'error'},
    statusCode: 400,
  );
}
