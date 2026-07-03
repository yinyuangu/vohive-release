# Upgrade

指定版本升级：

```bash
curl -fsSL https://raw.githubusercontent.com/yinyuangu/vohive-release/master/install.sh | bash -s -- --version v1.5.5-10-gf9eb85d
```

```sh
wget -O - https://raw.githubusercontent.com/yinyuangu/vohive-release/master/install.sh | sh -s -- --version v1.5.5-10-gf9eb85d
```

默认重复执行安装脚本即为升级语义，脚本会备份旧二进制到 `/opt/vohive/bin/vohive.bak`。
