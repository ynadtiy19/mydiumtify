# 使用官方 Dart 镜像
FROM dart:stable AS build

# 设置工作目录
WORKDIR /app

# 将 pubspec 文件复制到容器中并获取依赖
COPY pubspec.* ./
RUN dart pub get

# 将所有项目文件复制到容器中
COPY . .

# 构建 Dart Frog 项目
RUN dart pub global activate dart_frog_cli
RUN dart_frog build

# 使用最小 Dart 镜像来运行应用
FROM dart:stable AS runtime

# 将编译后的应用复制到最终运行容器中
COPY --from=build /app/build /app

# 设置工作目录
WORKDIR /app

# 暴露应用所使用的端口，默认 Dart Frog 在 8080 端口运行
EXPOSE 8080

# 运行应用
CMD ["dart", "bin/server.dart"]
