import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(
    headers: {
      'Content-Type': 'text/html',
    },
    body: ''' <!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的 App</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-white text-gray-900" style="background-image: url('https://uuunu.standard.us-east-1.oortstorage.com/Aesthetic%20phone%20background%20_%20phone%20wallpaper%20nude%20colours.jpg?signature=be0fa9891a9c0c40b2d774b18702dcbc9eced61758d7091c02a36c642a45d3142c6b7a9a24aacf967644c8a8f9e47aecd7e20d7e91879c134c389bcac4ad23aa9c9629ce5bc70e363b85aa74664c48af676688e4fba38ed344218562dba14b07&provider=1'); background-size: contain; background-position: center; background-repeat: no-repeat;">
    <header class="text-center p-10">
        <h1 class="text-4xl font-bold">云雨之洲 App</h1>
        <p class="mt-2 text-lg text-gray-600">一款专为你打造的ai聊天绘画应用</p>
    </header>

    <section class="max-w-4xl mx-auto p-6">
    <h2 class="text-2xl font-semibold text-center mb-4">核心功能</h2>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="p-4 border rounded-lg shadow-md">💬 AI 多轮聊天</div>
        <div class="p-4 border rounded-lg shadow-md">🎨 AI 绘画</div>
        <div class="p-4 border rounded-lg shadow-md">📌 Pinterest 图像搜索下载</div>
        <div class="p-4 border rounded-lg shadow-md">📰 Medium 文章获取</div>
    </div>
    <!-- Download Section with buttons -->
    <div class="mt-8 text-center">
        <div class="flex justify-center gap-6">
            <!-- GitHub Download Button -->
            <a href="https://github.com/ynadtiy19/Special-myfirstApp/releases/tag/ynadity19-yunyuzhizhou" class="bg-blue-500 text-white px-6 py-3 rounded-lg shadow-md hover:bg-blue-600 transition duration-300">GitHub 下载</a>
            <!-- APK Download Button -->
            <a href="https://uuunu.standard.us-east-1.oortstorage.com/app-release.apk?signature=be0fa9891a9c0c40b2d774b18702dcbc9eced61758d7091c02a36c642a45d3142c6b7a9a24aacf967644c8a8f9e47aecd7e20d7e91879c134c389bcac4ad23aa9c9629ce5bc70e363b85aa74664c48afcc7569f4101731ec91e116fb5fd0893c&provider=1" class="bg-green-500 text-white px-6 py-3 rounded-lg shadow-md hover:bg-green-600 transition duration-300">直接下载 APK</a>
        </div>
    </div>
</section>


    <section class="max-w-4xl mx-auto p-6 mt-10">
        <h2 class="text-2xl font-semibold text-center mb-4">AI 绘画框</h2>
        <div id="chat-box" class="border p-4 rounded-lg min-h-96 overflow-visible bg-gray-100"></div>
        <form id="text2image-form" class="mt-4 flex">
            <input type="text" id="prompt" class="flex-grow p-2 border rounded-l-lg" placeholder="输入你的promote...">
            <button type="submit" class="bg-blue-500 text-white px-6 py-2 rounded-r-lg shadow-md hover:bg-blue-600 transition">发送</button>
        </form>
        <p id="loading" class="text-center mt-2 hidden">加载中...</p>
    </section>

    <section class="max-w-4xl mx-auto p-6 mt-10">
        <h2 class="text-2xl font-semibold text-center mb-4">应用截图</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <img src="https://uuunu.standard.us-east-1.oortstorage.com/Screenshot_2025-02-19-12-14-51-725_com.example.hung.jpg?signature=be0fa9891a9c0c40b2d774b18702dcbc9eced61758d7091c02a36c642a45d3142c6b7a9a24aacf967644c8a8f9e47aecd7e20d7e91879c134c389bcac4ad23aa9c9629ce5bc70e363b85aa74664c48af728a40e5ca6d6cf013ffd21a83dd67ea&provider=1" class="rounded-lg shadow-md">
            <img src="https://uuunu.standard.us-east-1.oortstorage.com/Screenshot_2025-02-19-12-14-18-083_com.example.hung.jpg?signature=be0fa9891a9c0c40b2d774b18702dcbc9eced61758d7091c02a36c642a45d3142c6b7a9a24aacf967644c8a8f9e47aecd7e20d7e91879c134c389bcac4ad23aa9c9629ce5bc70e363b85aa74664c48af728a40e5ca6d6cf013ffd21a83dd67ea&provider=1" class="rounded-lg shadow-md">
            <img src="https://uuunu.standard.us-east-1.oortstorage.com/Screenshot_2025-02-19-12-13-44-407_com.example.hung.jpg?signature=be0fa9891a9c0c40b2d774b18702dcbc9eced61758d7091c02a36c642a45d3142c6b7a9a24aacf967644c8a8f9e47aecd7e20d7e91879c134c389bcac4ad23aa9c9629ce5bc70e363b85aa74664c48af728a40e5ca6d6cf013ffd21a83dd67ea&provider=1" class="rounded-lg shadow-md">
            <img src="https://uuunu.standard.us-east-1.oortstorage.com/Screenshot_2025-02-19-12-14-51-725_com.example.hung.jpg?signature=be0fa9891a9c0c40b2d774b18702dcbc9eced61758d7091c02a36c642a45d3142c6b7a9a24aacf967644c8a8f9e47aecd7e20d7e91879c134c389bcac4ad23aa9c9629ce5bc70e363b85aa74664c48af728a40e5ca6d6cf013ffd21a83dd67ea&provider=1" class="rounded-lg shadow-md">
            <img src="https://uuunu.standard.us-east-1.oortstorage.com/Screenshot_2025-02-19-12-14-21-482_com.example.hung.jpg?signature=be0fa9891a9c0c40b2d774b18702dcbc9eced61758d7091c02a36c642a45d3142c6b7a9a24aacf967644c8a8f9e47aecd7e20d7e91879c134c389bcac4ad23aa9c9629ce5bc70e363b85aa74664c48af728a40e5ca6d6cf013ffd21a83dd67ea&provider=1" class="rounded-lg shadow-md">
            <img src="https://uuunu.standard.us-east-1.oortstorage.com/Screenshot_2025-02-19-12-13-34-441_com.example.hung.jpg?signature=be0fa9891a9c0c40b2d774b18702dcbc9eced61758d7091c02a36c642a45d3142c6b7a9a24aacf967644c8a8f9e47aecd7e20d7e91879c134c389bcac4ad23aa9c9629ce5bc70e363b85aa74664c48af728a40e5ca6d6cf013ffd21a83dd67ea&provider=1" class="rounded-lg shadow-md">
        </div>
    </section>

    <script>
        document.getElementById('text2image-form').addEventListener('submit', async function(event) {
            event.preventDefault();
            const prompt = document.getElementById('prompt').value;
            const chatBox = document.getElementById('chat-box');
            const loading = document.getElementById('loading');

            chatBox.innerHTML += `<p class='p-2 bg-gray-200 rounded-lg mt-2'>用户: \${prompt}</p>`;
            loading.style.display = 'block';

            const apiUrl = 'https://api-key.fusionbrain.ai/';
            const apiKey = '904C36AB36B1AA98EFEC077B19F28EE9'; // Previous API Key
            const secretKey = '57CCFC112FB57BD364D3874D9CADCF32'; // Previous Secret Key

            try {
                // Get model ID
                let response = await fetch(apiUrl + 'key/api/v1/models', {
                    method: 'GET',
                    headers: {
                        'X-Key': 'Key ' + apiKey,
                        'X-Secret': 'Secret ' + secretKey
                    }
                });
                let data = await response.json();
                const modelId = data[0]['id'];

                // Generate image
                const params = {
                    type: 'GENERATE',
                    numImages: 1,
                    width: 1024,
                    height: 1024,
                    generateParams: {
                        query: prompt
                    }
                };
                const formData = new FormData();
                formData.append('model_id', modelId);
                formData.append('params', new Blob([JSON.stringify(params)], { type: 'application/json' }));

                response = await fetch(apiUrl + 'key/api/v1/text2image/run', {
                    method: 'POST',
                    headers: {
                        'X-Key': 'Key ' + apiKey,
                        'X-Secret': 'Secret ' + secretKey
                    },
                    body: formData
                });
                data = await response.json();
                const uuid = data['uuid'];

                // Check generation status
                let attempts = 10;
                const delay = 10000;
                let images = null;

                while (attempts > 0) {
                    response = await fetch(apiUrl + 'key/api/v1/text2image/status/' + uuid, {
                        method: 'GET',
                        headers: {
                            'X-Key': 'Key ' + apiKey,
                            'X-Secret': 'Secret ' + secretKey
                        }
                    });
                    data = await response.json();

                    if (data['status'] === 'DONE') {
                        images = data['images'];
                        break;
                    }

                    attempts -= 1;
                    await new Promise(resolve => setTimeout(resolve, delay));
                }

                // Display images
                loading.style.display = 'none';
                if (images) {
                    images.forEach(imageBase64 => {
                        chatBox.innerHTML += `<img src='data:image/png;base64,\${imageBase64}' class='rounded-lg shadow-md mt-2' alt="\${prompt}">`;
                    });
                } else {
                    chatBox.innerHTML += `<p class='p-2 bg-red-200 rounded-lg mt-2'>生成失败，请重试</p>`;
                }
            } catch (error) {
                loading.style.display = 'none';
                chatBox.innerHTML += `<p class='p-2 bg-red-200 rounded-lg mt-2'>发生错误，请重试</p>`;
                console.error("Image generation error:", error); // Log the error for debugging
            }
        });
    </script>
</body>
</html>
''',
  );
}
