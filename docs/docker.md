# Docker 部署

本仓库已经内置 Docker 构建文件，会从仓库中的 Linux 二进制生成镜像，不依赖 `iniwex/vohive:latest` 这个外部镜像。

## 构建镜像

```bash
docker build -t yinyuangu/vohive:latest .
```

指定版本：

```bash
docker build \
  --build-arg VOHIVE_VERSION=v1.5.5-10-gf9eb85d \
  -t yinyuangu/vohive:v1.5.5-10-gf9eb85d .
```

多架构构建：

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t yinyuangu/vohive:latest .
```

## Docker Compose

```bash
mkdir -p config data logs
docker compose up -d --build
```

Compose 示例默认会：

- 使用 `host` 网络，直接暴露 `7575` 端口
- 以 `privileged` 模式运行
- 挂载 `/dev`，方便容器访问 4G/5G 模组设备
- 挂载 `config`、`data`、`logs` 三个目录

首次启动时，如果 `config/config.yaml` 不存在，入口脚本会自动生成默认配置。

默认 Web 账号密码：

```text
admin / admin
```

访问地址：

```text
http://宿主机IP:7575
```

## 注意事项

- Docker 模式需要宿主机本身已经能识别 4G/5G 模组。
- 如果宿主机运行了 `ModemManager`，不要让它和 VoHive 同时管理拨号、APN 或数据连接。
- `privileged`、`/dev` 透传和 `host` 网络是为了让程序直接访问模组设备，部署在不可信环境时要谨慎。

