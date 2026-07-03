# VoHive Release

VoHive 的 Linux 安装与发布仓库，提供一键安装脚本、卸载脚本、systemd/OpenWrt 服务配置，以及不同 CPU 架构的预编译二进制文件。

## 第一步：macOS 上修改模块 VID/PID（可选）

如果你使用的是大疆 4G 模块、EG25-G 或 Baiwang QDC507 这类模块，可能会以大疆私有 VID/PID 枚举，例如 `2ca3:4006`。在安装 VoHive 前，可以先在 macOS 上把模块改成常见的 Quectel VID/PID，例如 `2c7c:0125`，方便后续在 Linux/OpenWrt/VoHive 环境中识别和管理。

该步骤参考 [hey1874/eg25g-toolset](https://github.com/hey1874/eg25g-toolset) 的 macOS 免 Linux 修改方式，核心原理是通过 `libusb + pyusb` 直接向模块 USB bulk endpoint 发送 AT 命令。

### 1. 安装工具

```bash
brew install libusb
git clone https://github.com/hey1874/eg25g-toolset.git
cd eg25g-toolset
python3 -m venv .venv
source .venv/bin/activate
pip install pyusb flask
```

### 2. 确认 macOS 已识别模块

```bash
system_profiler SPUSBDataType | egrep -i "2ca3|2c7c|quectel|eg25|ec25|dji|baiwang"
```

如果已经是 `0x2c7c / 0x0125`，通常可以跳过修改 VID/PID。

### 3. 测试 AT 命令

```bash
python3 eg25g.py info
python3 eg25g.py at "AT"
```

正常情况下会看到 `OK`。

### 4. 修改为 Quectel VID/PID 并重启模块

```bash
python3 eg25g.py at 'AT+QCFG="usbcfg",0x2C7C,0x0125,1,1,1,1,1,0,0'
python3 eg25g.py at 'AT+CFUN=1,1'
```

执行后模块会重新枚举，USB 会短暂断开。等待 20-60 秒后重新检查：

```bash
system_profiler SPUSBDataType | egrep -i "2c7c|quectel|eg25|ec25"
```

如果需要切到 Linux/VoHive 更常用的 QMI 模式，可以继续执行：

```bash
python3 eg25g.py mode qmi
```

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
