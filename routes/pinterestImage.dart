import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

Future<Response> onRequest(RequestContext context) async {
  //https://mydiumtify.globeapp.dev/pinterestImage?isImage=true&url=https://i.pinimg.com/originals/7d/41/80/7d41806124b7cfe34a4b850c7bf435df.jpg
  final queryParams = context.request.uri.queryParameters;
  final url = queryParams['url'] ??
      'https://nodle-community-nfts.myfilebase.com/ipfs/QmaC2W92D1iAhoUMyY94zn5fNR6zDZDdKeDtWTtTjpMNqc';
  final isImage = queryParams['isImage']?.toLowerCase() == 'true'; // 转换为布尔值

  try {
    // 请求选定的图片链接
    final imageResponse = await http.get(Uri.parse(url));
    if (imageResponse.statusCode == 200) {
      // 判断响应头中的 'content-type' 是否为图片类型
      final contentType = imageResponse.headers['content-type'];
      if (contentType != null && contentType.startsWith('image/')) {
        // 返回图片的二进制数据
        return Response.bytes(
          body: imageResponse.bodyBytes,
          headers: {
            'Content-Type': contentType,
          },
        );
      } else if (contentType != null && contentType.startsWith('video/')) {
        // 如果是视频类型，返回HTML5播放器页面
        String htmlContent = '''
        <!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<title>Plyr - A simple, customizable HTML5 Video, Audio, YouTube and Vimeo player</title>
	<meta name="description" property="og:description" content="A simple HTML5 media player with custom controls and WebVTT captions." />
	<meta name="author" content="Sam Potts" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	<link rel="icon" href="https://cdn.plyr.io/static/icons/favicon.ico" />
	<link rel="icon" type="image/png" href="https://cdn.plyr.io/static/icons/32x32.png" sizes="32x32" />
	<link rel="icon" type="image/png" href="https://cdn.plyr.io/static/icons/16x16.png" sizes="16x16" />
	<link rel="apple-touch-icon" sizes="180x180" href="https://cdn.plyr.io/static/icons/180x180.png" />
	<meta property="og:title" content="Plyr - A simple, customizable HTML5 Video, Audio, YouTube and Vimeo player" />
	<meta property="og:site_name" content="Plyr" />
	<meta property="og:url" content="https://plyr.io" />
	<meta property="og:image" content="https://cdn.plyr.io/static/icons/1200x630.png" />
	<meta name="twitter:card" content="summary" />
	<meta name="twitter:site" content="@sam_potts" />
	<meta name="twitter:creator" content="@sam_potts" />
	<meta name="twitter:card" content="summary_large_image" />
	<link rel="stylesheet" href="https://cdn.plyr.io/3.7.8/demo.css" />
	<link rel="preload" as="font" crossorigin type="font/woff2" href="https://cdn.plyr.io/static/fonts/gordita-medium.woff2" />
	<link rel="preload" as="font" crossorigin type="font/woff2" href="https://cdn.plyr.io/static/fonts/gordita-bold.woff2" />
	<script async src="https://www.googletagmanager.com/gtag/js?id=UA-132699580-1"></script>
	<script>
		window.dataLayer = window.dataLayer || [];
		function gtag() {
		  dataLayer.push(arguments);
		}
		gtag('js', new Date());
		gtag('config', 'UA-132699580-1');
	</script>
</head>
<body>
	<div class="grid">
		<main>
			<div id="container">
				<video controls crossorigin playsinline data-poster="" id="player">
					<source src=$url type="video/mp4" size="576" />
					<source src=$url type="video/mp4" size="720" />
					<source src=$url type="video/mp4" size="1080" />
					<track kind="captions" label="English" srclang="en" src="https://cdn.plyr.io/static/demo/View_From_A_Blue_Moon_Trailer-HD.en.vtt" default />
					<track kind="captions" label="Français" srclang="fr" src="https://cdn.plyr.io/static/demo/View_From_A_Blue_Moon_Trailer-HD.fr.vtt" />
					<a href=$url download>Download</a>
				</video>
			</div>
	
		</main>
	</div>
	
	<script src="https://cdn.plyr.io/3.7.8/demo.js" crossorigin="anonymous"></script>
</body>
</html>
        
        ''';
        return Response(
          body: htmlContent,
          headers: {'Content-Type': 'text/html'},
        );
      } else {
        // 如果是其他类型的内容，返回Base64编码的内容
        final base64 = base64Encode(imageResponse.bodyBytes);
        return Response(body: base64);
      }
    } else {
      return Response.json(
        statusCode: imageResponse.statusCode,
        body: 'Error fetching image: ${imageResponse.reasonPhrase}',
      );
    }
  } catch (e) {
    return Response(body: 'Failed to fetch image: $e');
  }
}
