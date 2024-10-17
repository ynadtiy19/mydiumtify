import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(
//     body: ''' <!DOCTYPE html>
// <html lang="en">
// <head>
//     <meta charset="UTF-8">
//     <meta name="viewport" content="width=device-width, initial-scale=1.0">
//     <title>Text to Image Generator</title>
//     <style>
//         body {
//             font-family: Arial, sans-serif;
//             margin: 0;
//             padding: 20px;
//             background-color: #f0f0f0;
//         }
//         #form-container {
//             margin-bottom: 20px;
//         }
//         #output {
//             display: flex;
//             flex-wrap: wrap;
//         }
//         .image-container {
//             margin: 10px;
//         }
//         img {
//             max-width: 100%;
//             height: auto;
//         }
//         #loading {
//             display: none;
//             font-size: 1.2em;
//             color: #555;
//         }
//     </style>
//     <script custom-element="storyly-web" src="https://web-story.storyly.io/sdk/3.2.*/storyly-web.js"></script>
// </head>
// <body>
//     <div id="form-container">
//         <form id="text2image-form">
//             <label for="prompt">Prompt:</label>
//             <input type="text" id="prompt" name="prompt" required>
//             <button type="submit">Generate Image</button>
//         </form>
//         <div id="loading">Generating image, please wait...</div>
//     </div>
//     <div id="output"></div>
//     <storyly-web></storyly-web>
//     <script>
//         const storylyWeb = document.querySelector('storyly-web');
//         storylyWeb.init({
//             token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NfaWQiOjEyMTM2LCJhcHBfaWQiOjE4NzU4LCJpbnNfaWQiOjIxMDgzfQ.Z1-47m5pTa3NiLNKpVcGJUw1N9ANOfxOS_QsKKIK1AA",
//         });
//     </script>
// <script>
//     document.getElementById('text2image-form').addEventListener('submit', async function(event) {
//         event.preventDefault();
//         const prompt = document.getElementById('prompt').value;
//         const apiUrl = 'https://api-key.fusionbrain.ai/';
//         const apiKey = '5209DB7AB7032D62FEFA1EF169EFDB95';
//         const secretKey = 'C430B7F2637DB46FE01B411F350E9E9E';
//         const loading = document.getElementById('loading');
//         const output = document.getElementById('output');
//
//         loading.style.display = 'block';
//         output.innerHTML = '';
//
//         try {
//             // Get model ID
//             let response = await fetch(apiUrl + 'key/api/v1/models', {
//                 method: 'GET',
//                 headers: {
//                     'X-Key': 'Key ' + apiKey,
//                     'X-Secret': 'Secret ' + secretKey
//                 }
//             });
//             let data = await response.json();
//             const modelId = data[0]['id'];
//
//             // Generate image
//             const params = {
//                 type: 'GENERATE',
//                 numImages: 1,
//                 width: 1024,
//                 height: 1024,
//                 generateParams: {
//                     query: prompt
//                 }
//             };
//             const formData = new FormData();
//             formData.append('model_id', modelId);
//             formData.append('params', new Blob([JSON.stringify(params)], { type: 'application/json' }));
//
//             response = await fetch(apiUrl + 'key/api/v1/text2image/run', {
//                 method: 'POST',
//                 headers: {
//                     'X-Key': 'Key ' + apiKey,
//                     'X-Secret': 'Secret ' + secretKey
//                 },
//                 body: formData
//             });
//             data = await response.json();
//             const uuid = data['uuid'];
//
//             // Check generation status
//             let attempts = 10;
//             const delay = 10000;
//             let images = null;
//
//             while (attempts > 0) {
//                 response = await fetch(apiUrl + 'key/api/v1/text2image/status/' + uuid, {
//                     method: 'GET',
//                     headers: {
//                         'X-Key': 'Key ' + apiKey,
//                         'X-Secret': 'Secret ' + secretKey
//                     }
//                 });
//                 data = await response.json();
//
//                 if (data['status'] === 'DONE') {
//                     images = data['images'];
//                     break;
//                 }
//
//                 attempts -= 1;
//                 await new Promise(resolve => setTimeout(resolve, delay));
//             }
//
//             // Display images
//             loading.style.display = 'none';
//             if (images) {
//                 images.forEach(imageBase64 => {
//                     const imgContainer = document.createElement('div');
//                     imgContainer.classList.add('image-container');
//                     const img = document.createElement('img');
//                     img.src = 'data:image/png;base64,' + imageBase64;
//                     imgContainer.appendChild(img);
//                     output.appendChild(imgContainer);
//                 });
//             } else {
//                 output.textContent = 'Failed to generate images.';
//                 console.error('Failed to generate images.');
//             }
//         } catch (error) {
//             loading.style.display = 'none';
//             output.textContent = 'An error occurred. Please try again.';
//             console.error('Error:', error);
//         }
//     });
// </script>
// </body>
// </html>
// ''',
    body: '''<!DOCTYPE html>
<html lang="zh-CN">
<head>  
    <meta charset="UTF-8">    
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    
    <title>视频数据分析</title>    
    <script src="https://cdn.jsdelivr.net/npm/echarts/dist/echarts.min.js"></script>  
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            margin: 0;
            padding: 20px;
        }
        #urlInput {
            width: 300px;
            padding: 10px;
            margin-bottom: 20px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        #fetchButton {
            padding: 10px 15px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        #fetchButton:hover {
            background-color: #45a049;
        }
        #message {
            margin-bottom: 20px;
            font-size: 16px;
        }
        .chart {
            width: 100%;
            height: 400px;
            margin-bottom: 40px;
        }
        #dropArea {
            width: 300px;
            height: 100px;
            border: 2px dashed #ccc;
            border-radius: 5px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
            color: #aaa;
            cursor: pointer;
        }
        #dropArea.hover {
            border-color: #4CAF50;
            color: #4CAF50;
        }
    </style>
</head>
<body>
    <h1>视频数据分析</h1>
    <div id="message">请输入视频数据的 URL 或拖放 JSON 文件:</div>
    <input type="text" id="urlInput" placeholder="请输入 URL">
    <button id="fetchButton">确认</button>
    <div id="dropArea">拖放 JSON 文件到这里</div>
    <div id="viewsChart" class="chart"></div>
    <div id="viewsBarChart" class="chart"></div>
    <div id="influenceChart" class="chart"></div>
    <div id="interactionChart" class="chart"></div>
    <script src="https://utfs.io/f/e9rePmZszdcgPRqO4CcC62eZIKRnvgMF5HEbsQi7hSUXD1BW"></script>
</body> 
</html>

''',
    headers: {'Content-Type': 'text/html'},
  );
}
