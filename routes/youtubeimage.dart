import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<String?> fetchPinterestData() async {
  var url =
      Uri.parse('https://www.pinterest.com/resource/BaseSearchResource/get/');

  // 请求头信息
  var headers = {
    'accept': 'application/json, text/javascript, */*, q=0.01',
    'accept-encoding': 'gzip, deflate, br, zstd',
    'accept-language': 'zh-CN,zh;q=0.9',
    'cache-control': 'no-cache',
    'content-type': 'application/x-www-form-urlencoded',
    'cookie':
        'csrftoken=834b002741a882bae12da6a4d39f40fa; _auth=1; ...', // 这里填写你的cookie
    'origin': 'https://www.pinterest.com',
    'pragma': 'no-cache',
    'referer': 'https://www.pinterest.com/',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'same-origin',
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 Edg/134.0.0.0',
    'x-app-version': 'd22ff69',
    'x-csrftoken': '834b002741a882bae12da6a4d39f40fa', // CSRF token 需要保持一致
    'x-pinterest-appstate': 'background',
    'x-pinterest-source-url':
        '/search/pins/?q=%E5%A4%A9%E7%A9%BA%E6%91%84%E5%BD%B1&rs=autocomplete_bubble&b_id=BJECVjLWvXOWAAAAAAAAAABZ-DXYnc0HL66Y3tuAL0ZocjEFR_qCjX9XNxVNVdHMoCgCFgOQXyvwP09CKxl_96qZOfKAskOHQRtGXk-slWiJImxL3bD9zdE&source_id=q2cFXmwi&top_pin_id=142074563238969386',
    'x-requested-with': 'XMLHttpRequest'
  };

  // 请求负载数据
  var body = {
    'source_url':
        '/search/pins/?b_id=BJECVjLWvXOWAAAAAAAAAABZ-DXYnc0HL66Y3tuAL0ZocjEFR_qCjX9XNxVNVdHMoCgCFgOQXyvwP09CKxl_96qZOfKAskOHQRtGXk-slWiJImxL3bD9zdE&q=%E5%A4%A9%E7%A9%BA%E6%91%84%E5%BD%B1&rs=autocomplete_bubble&source_id=q2cFXmwi&top_pin_id=142074563238969386',
    'data': jsonEncode({
      'options': {
        'applied_unified_filters': null,
        'appliedProductFilters': '---',
        'article':
            'BJECVjLWvXOWAAAAAAAAAABZ-DXYnc0HL66Y3tuAL0ZocjEFR_qCjX9XNxVNVdHMoCgCFgOQXyvwP09CKxl_96qZOfKAskOHQRtGXk-slWiJImxL3bD9zdE',
        'auto_correction_disabled': false,
        'corpus': null,
        'customized_rerank_type': null,
        'domains': null,
        'dynamicPageSizeExpGroup': 'enabled_300',
        'filters': null,
        'journey_depth': null,
        'page_size': '12',
        'price_max': null,
        'price_min': null,
        'query_pin_sigs': null,
        'query': '天空摄影',
        'redux_normalize_feed': true,
        'request_params': null,
        'rs': 'autocomplete_bubble',
        'scope': 'pins',
        'selected_one_bar_modules': null,
        'seoDrawerEnabled': false,
        'source_id': 'q2cFXmwi',
        'source_module_id': null,
        'source_url':
            '/search/pins/?b_id=BJECVjLWvXOWAAAAAAAAAABZ-DXYnc0HL66Y3tuAL0ZocjEFR_qCjX9XNxVNVdHMoCgCFgOQXyvwP09CKxl_96qZOfKAskOHQRtGXk-slWiJImxL3bD9zdE&q=%E5%A4%A9%E7%A9%BA%E6%91%84%E5%BD%B1&rs=autocomplete_bubble&source_id=q2cFXmwi&top_pin_id=142074563238969386',
        'top_pin_id': null,
        'top_pin_ids': null,
        'bookmarks': [
          'Y2JVSG81V2sxcmNHRlpWM1J5VFVad1ZsWllhR3RXTVVZMldUQlZOVll4U1hkT1JFWlhVak5vVkZaWE1WZGphelZaVW0xR2JHRXhjRkpXYlhSclRVVTFjMVZZWkZaaGVsWnlWRlZvVTJWV1pISlhhM1JYVm10V05sVldVbE5XVjBWNFUydDRXbFpXY0hwVWJYaExWbFphZEZKc1RsTmlTRUkyVm10YVlWVXlSWGxTYTJScVVteGFXRlpyVlRGVlJteFlaVWhPVDFKc1NubFdWekZIWVVaS1ZXSkZXbFppUmtwTVZrUkJlR050VGtsVGJGWlhZa1Z3U1ZkV1dtRmtNVTVIV2tac2FWSnVRbGhWYkZKWFpVWmFTRTFJYUZWTmEzQkhWR3hTWVZkSFNsbGhSVGxoVmpOb1YxUldXbEpsUmxaelkwVTFhR1ZyV2tkV2JYaHZZekZTYzFkcldsZFdSVnBXVm0xNFMxbFdVbGhqZWxaVFZteGFNRlJXVlRWV01ERlhWMVJDVjFKNlFYaFVhMXBTWlVaT2MxcEhSbE5TTWswMVdtdGFWMU5YU2paVmJYaFRWMGRvUmxkc1ZsZGhNV1J6VjFod2FGSkdjRmxaYTJSdVpXeHdXR042UmxkV2JYUTJXV3RWTlZZeFNuSlhWRXBYVW5wR00xbHRjM2hXYXpsWFZtMW9UazB3U2xKV1YzUldaVVV3ZUZSWWJHdFNNMUpYV1d0YVMxSldhM2RWYlRsVlRWVndTVlpYTlVOWFIwcFpVVzVLV2xaV2NETlpNVnBUVmxaV2MxRnNaRTVTYmtJMFZtcEdZV0V4WkhKTlNHaHBVMFZhVTFsc1pHOVZWbFp5V2tod2JHSkdTbmxYYTFwTFZHc3hXR1I2U2xaaVJrcEVWbFZhWVZJeFRuVlZiR2hZVTBWS2FGWkdVa0pOVmxwWFVteFdVbUY2Vm5CV2JHaERaREZaZUdGSVpGTmlWbHA1VkZaV2IxWlhTbGhsUmtaWFlURndSMXBFUmxOV01WWnpVMjE0VjJKWVozZFdWRVpUVkRGa2NrMVlUbGhpYXpWV1ZtdFdkMVV4VWxaV1ZFWnFWbXhLVmxaSGN6VldSazVJWVVaR1YxWXphR2haVkVFMVVXeENWVTFVYUU1bGJGVjZWRmR3VmsxRk1UWlhWRkpQVmtkek1WUlljRzVsYXpGRVkwVm9WbFpZWkhoYWEyUlNUVEF4VlZWdE1VNWlWVEIzVkZod1RrMHhiRlZUVkU1UVVrVlZlbFJWVWxaa01EVTJVVlJLVDFaR1JURlhhMUp1WlVac1dGUlljRTlXUm10NlZGZHdjbVZGTVhGaE0yUmFWa2RTY0ZkWWNFcGxSVFI1VmxSQ1QwMXJhM2RVVlZKV1RUQTVTRkpVVms5aGJGcHZWRlZTUTA5R1VuSldiR2h0VVZRd09XWkVUVEZPZWtreFRrUk5NazlFVlRWUFZFMDBUWHBCY1ZJeFJrMUxibmMxVGpKV2JVOUVRWGRPUkd0NVdtcEdhazVxU1RCYWJVVXpUMFJyTUU5VVRUUk9ha2swVDFkUk1scFVRWGhQVkd4cVRtcFNiRTU2UVRKT2VsRXpUMWRWTTFreVRtcE9SRWt3VFcxVk1GcFVZelJOVjBab1prVTFSbFl6ZHowPXxVSG81V1dWdE1XaFdSRnBEVjIxT2EyUjZNV1pOVkVwbVRGUkdPRTE2VlROTmFsVXdUWHBaTkU1VWF6Vk5lbWQ2VFVOd1NGVlZkM0ZtUkdONVRWUk9hVTVxU1RKTmFtTXdUbnByTWxwWFVYcE5WR1JyV1dwTmVVMUhUVFJhYWtVeVRucGplVTU2VVRWTmJVWnFXVlJhYlZwcVRtcE9lbEUwV1RKWk1WbDZWWGhPYlZKc1RtcFpNVnBIVlRSTlYwNDRWR3RXV0daQlBUMD18Tm9uZXwzNTcyNTQzNjg1OTkzODMwKkdRTCp8NDdiZmNmMWU4YjRlM2VjYTJmYWE5ZjZmM2VlZDBmYTkwMDFiOTU5OTliM2I0OWU2OWFhY2ZjMGM1ZTRmYTE2NHxORVd8'
        ]
      },
      'context': {}
    })
  };

  try {
    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print('请求成功!');
      print('响应数据: ${response.body}');
      return response.body;
    } else {
      print('请求失败: ${response.statusCode}');
      print('错误信息: ${response.body}');
      return null;
    }
  } catch (e) {
    print('请求异常: $e');
  }
}

Future<Response> onRequest(RequestContext context) async {
  //youtubeimage

  final i = await fetchPinterestData();
  return Response.json(
    body: i,
    headers: {'Content-Type': 'application/json'},
    statusCode: 200,
  );
}
