# VoHive Release

VoHive 的 Linux 安装与发布仓库，提供一键安装脚本、卸载脚本、systemd/OpenWrt 服务配置，以及不同 CPU 架构的预编译二进制文件。

## 支持架构

安装脚本会自动识别当前系统架构，并获取对应二进制文件：

| 系统架构 | 二进制文件 |
| --- | --- |
| x86_64 / amd64 | `vohive_v1.5.5-10-gf9eb85d_linux_amd64` |
| aarch64 / arm64 | `vohive_v1.5.5-10-gf9eb85d_linux_arm64` |
| armv7 / armv7l | `vohive_v1.5.5-10-gf9eb85d_linux_armv7` |

## 一键安装

使用 `curl`：

```bash
curl -fsSL https://raw.githubusercontent.com/yinyuangu/vohive-release/master/install.sh | bash
```

使用 `wget`：

```sh
wget -O - https://raw.githubusercontent.com/yinyuangu/vohive-release/master/install.sh | sh
```

脚本默认会：

- 安装二进制到 `/opt/vohive/bin/vohive`
- 生成配置文件 `/opt/vohive/config/config.yaml`
- 创建数据目录 `/opt/vohive/data`
- 创建日志目录 `/opt/vohive/logs`
- 自动注册并启动 `vohive.service`
- 在 OpenWrt 环境下自动注册 `/etc/init.d/vohive`

默认 Web 账号密码：

```text
admin / admin
```

默认访问地址：

```text
http://127.0.0.1:7575
```

## 安装指定版本

```bash
curl -fsSL https://raw.githubusercontent.com/yinyuangu/vohive-release/master/install.sh | bash -s -- --version v1.5.5-10-gf9eb85d
```

```sh
wget -O - https://raw.githubusercontent.com/yinyuangu/vohive-release/master/install.sh | sh -s -- --version v1.5.5-10-gf9eb85d
```

## 本地安装

如果已经克隆本仓库，可以直接执行：

```bash
sudo ./install.sh
```

脚本会优先使用同目录下的本地二进制文件，不会重复远程下载。

也可以通过环境变量指定二进制目录：

```bash
sudo VOHIVE_BINARY_DIR=/path/to/binaries ./install.sh
```

## Docker 部署

本仓库内置 `Dockerfile` 和 `docker-compose.yml`，会直接使用仓库中的 Linux 二进制构建镜像，不依赖外部 `iniwex/vohive:latest` 镜像。

构建本机架构镜像：

```bash
docker build -t yinyuangu/vohive:latest .
```

启动 Docker Compose：

```bash
mkdir -p config data logs
docker compose up -d --build
```

Compose 默认配置：

- 镜像名：`yinyuangu/vohive:latest`
- 容器名：`vohive`
- 网络模式：`host`
- 运行权限：`privileged`
- 配置目录：`./config:/app/config`
- 数据目录：`./data:/app/data`
- 日志目录：`./logs:/app/logs`
- 设备透传：`/dev:/dev`

首次启动时，如果 `config/config.yaml` 不存在，容器入口脚本会自动生成默认配置。

多架构构建示例：

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t yinyuangu/vohive:latest .
```

更多说明见 [Docker 部署](docs/docker.md)。

## 服务管理

systemd：

```bash
sudo systemctl status vohive
sudo systemctl restart vohive
sudo journalctl -u vohive -f
```

OpenWrt：

```sh
/etc/init.d/vohive status
/etc/init.d/vohive restart
logread -f
```

## 升级

重复执行安装脚本即可升级。升级前脚本会将旧二进制备份到：

```text
/opt/vohive/bin/vohive.bak
```

## 回滚

如果升级后需要恢复旧版本：

```bash
sudo cp /opt/vohive/bin/vohive.bak /opt/vohive/bin/vohive
sudo systemctl restart vohive
```

OpenWrt：

```sh
cp /opt/vohive/bin/vohive.bak /opt/vohive/bin/vohive
/etc/init.d/vohive restart
```

## 卸载

保留数据和配置：

```bash
curl -fsSL https://raw.githubusercontent.com/yinyuangu/vohive-release/master/uninstall.sh | bash
```

删除程序、配置、数据和日志：

```bash
curl -fsSL https://raw.githubusercontent.com/yinyuangu/vohive-release/master/uninstall.sh | bash -s -- --purge
```

## 常用参数

| 参数 | 说明 |
| --- | --- |
| `--version <版本>` | 安装指定版本 |
| `--channel stable` | 安装稳定版本 |
| `--channel latest` | 安装最新版本 |
| `--no-systemd` | 只安装二进制和配置，不注册系统服务 |
| `--dry-run` | 预览安装动作，不实际写入系统 |
| `--force` | 覆盖已有默认配置 |

## 相关文档

- [快速开始](docs/quickstart.md)
- [Docker 部署](docs/docker.md)
- [升级说明](docs/upgrade.md)
- [回滚说明](docs/rollback.md)
