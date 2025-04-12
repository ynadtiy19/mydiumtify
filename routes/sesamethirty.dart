import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http; // 导入 dart_frog

Future<Response> onRequest(RequestContext context) async {
  //请求路径 https://mydiumtify.globeapp.dev/sesamethirty
  if (context.request.method == HttpMethod.post) {
    final headers = {'Content-Type': 'application/json'};
    final request = http.Request(
        'POST',
        Uri.parse(
            'https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=AIzaSyDtC7Uwb5pGAsdmrH2T4Gqdk5Mga07jYPM'))
      ..body = jsonEncode({
        'requestUri': 'http://localhost',
        'returnSecureToken': true,
        'postBody':
            '&id_token=eyJhbGciOiJSUzI1NiIsImtpZCI6IjgyMWYzYmM2NmYwNzUxZjc4NDA2MDY3OTliMWFkZjllOWZiNjBkZmIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiYXpwIjoiMTA3MjAwMDk3NTYwMC1paWdybjZ2NmY3dWo4Mmpxb3M4NGRqaWkyazVwNmZoOC5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsImF1ZCI6IjEwNzIwMDA5NzU2MDAtaWlncm42djZmN3VqODJqcW9zODRkamlpMms1cDZmaDguYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTY4Mzk3ODY4MjU1OTYwODI1MTYiLCJlbWFpbCI6ImZsdXRlb2NlYW51dXlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJwZWVXRHVERHhwaHY2OFRJdnRMblNRIiwiaWF0IjoxNzQzMjQwNzc2LCJleHAiOjE3NDMyNDQzNzZ9.mvNLfJQ73HfzgpahN8V3OrRf_Bn7X5xnpgHL0YLzXb1b7d4q4OxqyUAjZgmB-LYzkkhKzgsxHz5RkG9cNBoHcux90q69hhHca8V4eBmckK-TcTddnSmFR_2YtBgueznCvKrD9KSYo3lfKpomX-pFpF5g7NUJy_GGM3fE2mmKzO7ry4mA8BVww37ZykhVlkiHbKqc8Ey5ODf0kr6bW89zpnFngFVLHdkIwkMC4KAgY_zXk2jwmbaWGRtOUS1or0-Ewv6j28GZ9YO-nUJVNpFMm8XzOzZcR31EFzfqdIBvM9TP3Nmz4SdSB3eAy1wKl7nEsssz_dHQLVfyxA_Ef8ClIA&access_token=ya29.a0AeXRPp5DNV-2J9Tuj_Wn1rQTJHTKhmW5atklpVBsVRQXt4mnnwAFp6q3RftCRhFc2J7qayHLsL_MKD1-cmzMtXEEwtePS6DbcDZdaM2dkBZPr4uHN0gp4y9lM14Rg7OB4lkHg-eIsF9TV2Ko2fS8-57WL49EDRAPzM_f6qtNaCgYKAU4SARISFQHGX2Mi4ErH6Wym8iHLO4R6_ivsAg0175&providerId=google.com'
      });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // 解析响应数据
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      // 提取idToken
      final idToken = responseData['idToken'];
      return Response.json(body: {'id_token': idToken});
    } else {
      return Response.json(
        body: {'error': 'Failed to create an anonymous account'},
      );
    }
  } else if (context.request.method == HttpMethod.get) {
    return Response.json(
      body: {'message': 'Welcome to the API', 'status': 'success'},
    );
  }

  return Response.json(
    body: {'message': 'Invalid request', 'status': 'error'},
  );
}
