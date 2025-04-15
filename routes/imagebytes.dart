import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  //https://mydiumtify.globeapp.dev/imagebytes?medium_id=7b759aebbfe1

  final params = context.request.uri.queryParameters;
  final medium_id = params['medium_id'] ?? '7b759aebbfe1';

  final headers = {
    'accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    'accept-encoding': 'gzip, deflate, br, zstd',
    'accept-language': 'zh-CN,zh;q=0.9',
    'cache-control': 'no-cache',
    'cookie':
        '_ga=GA1.2.764495630.1724915282; cf_clearance=gMV.gatO9bM5YRVvv2BMLUOeQVv8Fe6cTcDw0wpijmc-1744702549-1.2.1.1-plfjI5keLXyNemPymGin0ijZJpGelig5CKPCcn7HwVN0hfTEPHQ9UmucNoPif8ixF20hkgMVOSwYbjA1HU7O3ElXMyToBSw7HfMktQZJodc7DAZammHrZxM9pb7UI3ZEsovRUEOZSQeaWFf5q6L7b5uPVzAKeZxx5dRcUJY_PN2bSkJkkb06nAHNe_Gs4cJLW0TVhZSVpYh1WeC691DLXzNoUUPL7e4dRszEP95R2ruXMAUbEjQ_xhLg4iG8_5JGVocqGln7oQZNrfNYGPf8LaVsGvqt36IUeNLJXhiQ4m3ie5Tj0.0ZF6FZ8C.9BVHI2mZomS1xa_1H4LL3SaM_K4ita_eFDcaNHULWK3cXTo9F0zseF_9.bVNrJrIIROpv',
    'pragma': 'no-cache',
    'priority': 'u=0, i',
    'sec-ch-ua':
        '"Chromium";v="136", "Microsoft Edge";v="136", "Not.A/Brand";v="99"',
    'sec-ch-ua-arch': '"x86"',
    'sec-ch-ua-bitness': '"64"',
    'sec-ch-ua-full-version': '"136.0.3240.14"',
    'sec-ch-ua-full-version-list':
        '"Chromium";v="136.0.7103.25", "Microsoft Edge";v="136.0.3240.14", "Not.A/Brand";v="99.0.0.0"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-model': '""',
    'sec-ch-ua-platform': '"Windows"',
    'sec-ch-ua-platform-version': '"19.0.0"',
    'sec-fetch-dest': 'document',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-site': 'none',
    'sec-fetch-user': '?1',
    'upgrade-insecure-requests': '1',
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36'
  };

  final response = await http.get(
    Uri.parse('https://freedium.cfd/https://medium.com/p/$medium_id'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final compressedBytes = response.bodyBytes;
    return Response.bytes(
      body: compressedBytes,
      headers: {
        'content-type': 'text/html; charset=utf-8',
        'content-encoding': 'zstd',
        'cache-control': 'no-store',
      },
    );
  } else {
    return Response.json(
      statusCode: response.statusCode,
      body: {'error': '请求失败', 'message': response.reasonPhrase},
    );
  }
}
