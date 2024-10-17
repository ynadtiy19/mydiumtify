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
    </style>
</head>
<body>
    <h1>视频数据分析</h1>
    <div id="message">请输入视频数据的 URL:</div>
    <input type="text" id="urlInput" placeholder="请输入 URL">
    <button id="fetchButton">确认</button>

    <div id="viewsChart" class="chart"></div>
    <div id="influenceChart" class="chart"></div>
    <div id="interactionChart" class="chart"></div>
    
    <script>
        let videoData = []; // 存储视频数据
        const defaultUrl = 'https://api.npoint.io/0f9fe90f986b0245b107'; // 默认 URL

        // 请求数据的函数
        async function fetchVideoData(url) {
            try {
                const response = await fetch(url);
                if (!response.ok) {
                    throw new Error('网络响应不是 OK');
                }
                const data = await response.json();
                return data;
            } catch (error) {
                alert(`获取数据失败: 请重新获取url链接`);
                return null;
            }
        }

        // 渲染视频观看量柱状图
        function renderViewsChart(videoData) {
            const chartDom = document.getElementById('viewsChart');
            const myChart = echarts.init(chartDom);

            const titles = videoData.map(video => video.title);
            const views = videoData.map(video => video.stat.view);

            const option = {
                title: {
                    text: '视频播放量柱状图',
                    left: 'center'
                },
                tooltip: {
                    position: function (point) {
                        return [point[0], point[1] - 50]; // 向上偏移 50px
                    }
                },
                xAxis: {
                    type: 'category',
                    data: titles,
                    name: '视频标题'
                },
                yAxis: {
                    type: 'value',
                    name: '播放量'
                },
                series: [{
                    name: '播放量',
                    type: 'bar',
                    data: views,
                    itemStyle: {
                        color: '#5470C6',
                    },
                }]
            };

            myChart.setOption(option);
        }

        // 渲染UP主影响力排行饼图
        function renderInfluenceChart(videoData) {
            const chartDom = document.getElementById('influenceChart');
            const myChart = echarts.init(chartDom);

            const upUsers = {};
            videoData.forEach(video => {
                const user = video.owner.name;
                upUsers[user] = (upUsers[user] || 0) + video.stat.view;
            });

            const userTitles = Object.keys(upUsers);
            const userViews = Object.values(upUsers);

            const option = {
                title: {
                    text: 'UP主影响力排行饼图',
                    left: 'center'
                },
                tooltip: {
                    trigger: 'item'
                },
                series: [{
                    name: 'UP主',
                    type: 'pie',
                    radius: '50%',
                    data: userTitles.map((title, index) => ({
                        name: title,
                        value: userViews[index]
                    })),
                    emphasis: {
                        itemStyle: {
                            shadowBlur: 10,
                            shadowOffsetX: 0,
                            shadowColor: 'rgba(0, 0, 0, 0.5)'
                        }
                    }
                }]
            };

            myChart.setOption(option);
        }

        // 渲染用户互动行为折线图
        function renderInteractionChart(videoData) {
            const chartDom = document.getElementById('interactionChart');
            const myChart = echarts.init(chartDom);

            const titles = videoData.map(video => video.title);
            const likes = videoData.map(video => video.stat.like);
            const comments = videoData.map(video => video.stat.reply);
            const danmaku = videoData.map(video => video.stat.danmaku);

            const option = {
                title: {
                    text: '用户互动行为折线图',
                    left: 'center'
                },
                tooltip: {
                    position: function (point) {
                        return [point[0], point[1] - 50]; // 向上偏移 50px
                    }
                },
                legend: {
                    data: ['点赞数', '评论数', '弹幕数'],
                    bottom: '10%'
                },
                xAxis: {
                    type: 'category',
                    data: titles,
                    name: '视频标题'
                },
                yAxis: {
                    type: 'value',
                    name: '互动数量'
                },
                series: [
                    {
                        name: '点赞数',
                        type: 'line',
                        data: likes,
                        itemStyle: {
                            color: '#91CC75',
                        },
                    },
                    {
                        name: '评论数',
                        type: 'line',
                        data: comments,
                        itemStyle: {
                            color: '#FAC858',
                        },
                    },
                    {
                        name: '弹幕数',
                        type: 'line',
                        data: danmaku,
                        itemStyle: {
                            color: '#EE6666',
                        },
                    }
                ]
            };

            myChart.setOption(option);
        }

        // 主函数：获取数据并渲染图表
        async function main(url) {
            videoData = await fetchVideoData(url);
            if (videoData) {
                renderViewsChart(videoData);
                renderInfluenceChart(videoData);
                renderInteractionChart(videoData);
            }
        }

        // 点击确认按钮
        document.getElementById('fetchButton').addEventListener('click', () => {
            const url = document.getElementById('urlInput').value.trim() || defaultUrl;
            main(url);
        });

        // 默认加载数据
        main(defaultUrl);
    </script>
</body>
</html>
''',
    headers: {'Content-Type': 'text/html'},
  );
}
