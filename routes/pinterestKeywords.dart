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
        'pina_AEAZ25IWAA5LMAQAGAAGWDKQN3CG3EYBACGSOSILMHANABLVGRCG2PNMAKQQGBNWJAXVRNGKPMMPA3F4Q6I4FG3LSRQK7NAA',
    'searchTerm': searchTerm,
    'sortBy': sortBy
  });
  //volume,relevance,competition,trend
  // 请求头
  final headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjkyODg2OGRjNDRlYTZhOThjODhiMzkzZDM2NDQ1MTM2NWViYjMwZDgiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoia2UgamkiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUNnOG9jSTBTRXVyTDBNSXY3UTNPcHdmY1c0QWo1X2k5MURZajV1Vk4tSlRGRHVoanB4c1FnPXM5Ni1jIiwiaXNzIjoiaHR0cHM6Ly9zZWN1cmV0b2tlbi5nb29nbGUuY29tL3BpbmdlbmVyYXRvci00M2ExNSIsImF1ZCI6InBpbmdlbmVyYXRvci00M2ExNSIsImF1dGhfdGltZSI6MTcyNzA4MTAxNCwidXNlcl9pZCI6IlVleGFsUjB3TlFRbzVabzZYWnNnN1VwVmVoejIiLCJzdWIiOiJVZXhhbFIwd05RUW81Wm82WFpzZzdVcFZlaHoyIiwiaWF0IjoxNzMyNzEyMzE0LCJleHAiOjE3MzI3MTU5MTQsImVtYWlsIjoiZmx1dGVvY2VhbnV1eUBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJnb29nbGUuY29tIjpbIjExNjgzOTc4NjgyNTU5NjA4MjUxNiJdLCJlbWFpbCI6WyJmbHV0ZW9jZWFudXV5QGdtYWlsLmNvbSJdfSwic2lnbl9pbl9wcm92aWRlciI6Imdvb2dsZS5jb20ifX0.kGEdhmnH2MHNPDvx8Pv2dP-SNlohn7uKX0tqpVSFDh6_5H0SaJENXgIP18H_t5frn6XVQtgvTv2mKGyq4wEobhBLzFEb64SW_68uZgchEF9GBiqZ16oUcpj-nSCLfs8jFT17fUljQIU42Za-GUEUJTeeTEgfHMt2s-ZtlzA0XTsDYN2_3uYLZMJWJ8yJcOPjo_6xQODVWic89YJ2ZB7kdoY4gTo6KV7w9NIUBGNUsv0ABN8yEa-dFYQ3ixzQDW7rxueJkuXXyu4YOlMy5YW1IQWieaQl2_Prl2aKhxhuJJUQu4xA_Lv3S-CaJLiTzn4V4Bew0hFSSxvIcmaiwTeeVg',
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
