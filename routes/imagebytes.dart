import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:zstandard/zstandard.dart';

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
        '_ga=GA1.2.764495630.1724915282; cf_clearance=g1223ymzHR81hHBf07fAh4N8t36hmISoRQUhLUao01c-1744699077-1.2.1.1-bVTSzNGhczGLdoyKFGr5xjNEgiGUxkiJTB3ip4ZQiDydRfDlrPnxlJaHRndUuFMUX28Ud3LBLVqoQIpFKecBvXqoJ4jLElZS4ooP0wNlLUPYOQ6Pi3zZTTVs1WM6WwRRGW_7WorZnM_FEhSV7ZI.aEZxdLbcD.2oMDwpcWOKxODb_EAXmAhx0MSfb7Ny80svEp4VTN2C4OB2_NBy2WepOFDz7A2Qbw0sCAwTB0QqK7oUv1LYSvQ_62yAqnTPf6x.rE8vNK5f_ggfdmmrcuurrrQYRQJS0Lj.K1hG2aNdoFF.V.ZF1VLah3Lk3CGNyUfjteoegC_zwZbPu6ZAMbdtWhmZAoZ0WYNVtPWAcTexdTh7VkkLGrFfyt_LJf1oFaZN',
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

    final zstd = Zstandard();
    Uint8List? decompressedBytes;
    try {
      decompressedBytes = await zstd.decompress(compressedBytes);
    } catch (e) {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Zstd 解压失败', 'detail': e.toString()},
      );
    }

    final decodedString = utf8.decode(decompressedBytes! as List<int>);
    return Response(
      headers: {'content-type': 'text/html; charset=utf-8'},
      body: decodedString,
    );
  } else {
    return Response.json(
      statusCode: response.statusCode,
      body: {'error': '请求失败', 'message': response.reasonPhrase},
    );
  }
}
