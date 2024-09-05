import 'package:dart_frog/dart_frog.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
//mediumhtml?id=333dc1eeda1a

  // Access the incoming request.
  final request = context.request;

  // Access the query parameters as a `Map<String, String>`.
  final params = request.uri.queryParameters;

  // Get the value for the key `name`.
  // Default to `there` if there is no query parameter.
  final id = params['id'] ?? '333dc1eeda1a';

  List<Link> parseHtml(Document document) {
    List<Link> linkList = [];

    // 提取所有<img>标签
    List<Element> imgElements = document.querySelectorAll('img');

    // 更新data-src和src属性中的URL并保存链接
    for (var img in imgElements) {
      // 更新 data-src 属性
      String? dataSrc = img.attributes['data-src'];
      if (dataSrc != null && dataSrc.isNotEmpty) {
        String newDataSrc = dataSrc.replaceFirst(
            'miro.medium.com', 'cdn-images-1.readmedium.com');
        img.attributes['data-src'] = newDataSrc;
        linkList.add(Link(dataSrc: newDataSrc));
      }

      // 更新 src 属性
      String? src = img.attributes['src'];
      if (src != null && src.isNotEmpty) {
        String newSrc =
            src.replaceFirst('miro.medium.com', 'cdn-images-1.readmedium.com');
        img.attributes['src'] = newSrc;
        // 如果需要保存 src 的链接
        linkList.add(Link(dataSrc: newSrc));
      }
    }

    return linkList;
  }

  String uuu = '''A''';
  Future<void> fetchHtmlContent() async {
    final response = await http.get(Uri.parse('https://www.freedium.cfd/$id'));

    if (response.statusCode == 200) {
      uuu = response.body;
      // 这里可以使用 htmlContent
      // print(htmlContent);
    } else {
      throw Exception('Failed to load HTML content');
    }
  }

  //运行fetchHtmlContent
  await fetchHtmlContent();
//isok🎉🎉🎉

  // 提取<body>部分的直接子元素
  Element? body = document.body;
  Element? fourthDiv;
  if (body != null) {
    List<Element> bodyChildren = body.children; // 获取<body>的所有直接子元素
    if (bodyChildren.length >= 4) {
      fourthDiv = bodyChildren[3]; // 选择第四个直接子元素
    }
  }

  if (fourthDiv != null) {
    // 定位到第四个<div>中的第一个<div>，再进入该<div>中的第一个<div>
    Element? firstDivInFourthDiv = fourthDiv.querySelector('div');
    if (firstDivInFourthDiv != null) {
      Element? secondDivInFirstDiv = firstDivInFourthDiv.querySelector('div');
      if (secondDivInFirstDiv != null) {
        // 查找并删除<p>元素
        Element? targetP = secondDivInFirstDiv.querySelector(
            'p.text-base.md\\:text-sm.text-green-500.font-bold.pb-3');
        targetP?.remove();
      }
    }
  } else {
    print('未找到第四个<div>');
  }

  if (head != null && fourthDiv != null) {
    // 组合成新的HTML
    String newHtml = '''
     <!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🎉🎉🎉Medium</title>
  ${head.outerHtml}
</head>
<body>
  ${fourthDiv.outerHtml}
</body>
</html>
''';

    // 解析HTML
    Document document = parse(newHtml);

    // 开始解析
    List<Link> linkList = parseHtml(document); //可以返回文章图像链接

    String finalhtml = document.outerHtml;

    int contentLength = finalhtml.length;

    return Response(
      statusCode: 200,
      body: finalhtml,
      headers: {
        'Content-Type': 'text/html',
        'Content-Length': contentLength.toString(),
        'Connection': 'close',
      },
    );
  } else {
    print('未能找到指定的HTML部分');
  }
  // // TODO: implement route handler
  return Response(body: 'This is a new route!');
}

class Link {
  String dataSrc;

  Link({required this.dataSrc});
}
