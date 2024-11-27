import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  // https://mydiumtify.globeapp.dev/pinterestKeywords?query=..&sortBy=volume
  final queryParams = context.request.uri.queryParameters;
  final searchTerm = queryParams['query'] ?? 'beautiful nature image';
  final sortBy = queryParams['sortBy'] ?? 'volume';

  final url = Uri.parse(
      'https://europe-west3-pingenerator-43a15.cloudfunctions.net/api/pinterestAPI/findSuggestedKeywordsAndVolumes');
  final body = jsonEncode({
    'access_token':
        'pina_AEAZ25IWAA5LMAQAGAAGWDIYQS2G3EYBACGSPNSSNHKY7X6HXMRO7TV74ZQW2V3B4Q6ZLWPKD5WOCY2RMHGSNYGXUPLKRCIA',
    'searchTerm': searchTerm,
    'sortBy': sortBy
  });
  //volume,relevance,competition,trend
  // 请求头
  final headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6ImUwM2E2ODg3YWU3ZjNkMTAyNzNjNjRiMDU3ZTY1MzE1MWUyOTBiNzIiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoia2UgamkiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jSTBTRXVyTDBNSXY3UTNPcHdmY1c0QWo1X2k5MURZajV1Vk4tSlRGRHVoanB4c1FnPXM5Ni1jIiwiaXNzIjoiaHR0cHM6Ly9zZWN1cmV0b2tlbi5nb29nbGUuY29tL3BpbmdlbmVyYXRvci00M2ExNSIsImF1ZCI6InBpbmdlbmVyYXRvci00M2ExNSIsImF1dGhfdGltZSI6MTcyNzA4MTAxNCwidXNlcl9pZCI6IlVleGFsUjB3TlFRbzVabzZYWnNnN1VwVmVoejIiLCJzdWIiOiJVZXhhbFIwd05RUW81Wm82WFpzZzdVcFZlaHoyIiwiaWF0IjoxNzI3MDgxMDE0LCJleHAiOjE3MjcwODQ2MTQsImVtYWlsIjoiZmx1dGVvY2VhbnV1eUBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJnb29nbGUuY29tIjpbIjExNjgzOTc4NjgyNTU5NjA4MjUxNiJdLCJlbWFpbCI6WyJmbHV0ZW9jZWFudXV5QGdtYWlsLmNvbSJdfSwic2lnbl9pbl9wcm92aWRlciI6Imdvb2dsZS5jb20ifX0.Z6g9i_3aQCNaq6lZvswUQw6588tsi3uI6a5s7KIGxXK5SfSvY63j4XB07p5weJnEQOhu4TP4tMWtPSyQQhMVb9mbvviS3I7Kb--16ZMkQHvbTnYfPrjpjLIEWvc9qcAunNwxKnQRIVKxIYw8QT6Zchtk_WQpKyRyUyM7ynEqquZ3BwQty6tHAqh4i-DwQV1yLn3BtIPnegjZFZXeS5t7KrocT7yEUlnyP1qis4lk1E11vblJpiVsyGGm41bQ6ExJn52uzi0j4QYUMug3mTxubpzRPoLKLoqxI8b6kMBxGNgOCQODYhkK5UriURuDwObf66T5LkU1sMFjWIPhkFGtnA',
    'Accept': 'application/json',
    'Accept-Encoding': 'gzip, deflate, br, zstd',
    'Accept-Language': 'zh-CN,zh;q=0.9',
    'Origin': 'https://pingenerator.com',
    'Referer': 'https://pingenerator.com/',
    'Sec-Fetch-Dest': 'empty',
    'Sec-Fetch-Mode': 'cors',
    'Sec-Fetch-Site': 'cross-site',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 Edg/129.0.0.0'
  };

  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return Response.json(body: jsonResponse);
    } else {
      return Response.json(
        statusCode: response.statusCode,
        body: '请求失败: ${response.reasonPhrase}',
      );
    }
  } catch (e) {
    return Response.json(
      body: {
        'success': false,
        'data': null,
        'error_message': e.toString(),
      },
      statusCode: 500,
    );
  }
}
