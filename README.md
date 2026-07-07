# Docker SecureLink VPN

基于 Docker 的 SecureLink VPN 容器化部署，提供 X11/VNC 桌面环境用于 GUI 交互。支持 **Arch Linux** 和 **Debian** 两种基础镜像。

## 快速启动

### Docker Compose（推荐）

```bash
git clone --recurse-submodules https://github.com/exyexin/docker-securelink-vpn.git
cd docker-securelink-vpn
docker compose up -d
```

### 手动构建

**Arch Linux 版本**（默认 `Dockerfile`）：

```bash
cd securelink && makepkg
cd ../
podman build -t svpn .
bash ./run.sh <container_name>
```

**Debian 版本**（`Dockerfile.debian`）：

```bash
# 先重新打包 .deb（替换原始 postinst）
cd securelink && bash repack.sh && cd ..

# 构建（需要代理时用 add_proxy）
add_proxy podman build --network host -f Dockerfile.debian -t svpn-debian .

podman run -d --name svpn \
    --cap-add SYS_ADMIN --cap-add NET_ADMIN \
    --device /dev/net/tun \
    -v /sys/fs/cgroup/:/sys/fs/cgroup/:ro \
    -p 5902:5900 -p 10802:10801 -p 18889:18888 \
    svpn-debian
```

> 初次启动可能需要选择 timezone（Debian 版本默认跳过交互）。

## 连接

| 端口 | 服务 |
|------|------|
| `5902` | VNC 远程桌面 |
| `10802` | SOCKS5 代理 |
| `18889` | HTTP 代理 |

VNC 连接：`localhost:5902`

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `HOME` | `/root` | SecureLink 配置存储路径 |
| `DISPLAY` | `:0.0` | X11 显示 |
| `DISPLAY_WIDTH` | `1024` | 虚拟屏幕宽度 |
| `DISPLAY_HEIGHT` | `768` | 虚拟屏幕高度 |
| `RUN_XTERM` | `yes` | 启动 XTerm |
| `RUN_FLUXBOX` | `yes` | 启动 Fluxbox 窗口管理器 |

## 服务说明

| 服务 | 说明 |
|------|------|
| `securelink.service` | VPN 后端守护进程 |
| `securelink_gui.service` | Electron GUI 客户端 |
| `xvfb.service` | X11 虚拟显示 |
| `fluxbox.service` | 窗口管理器 |
| `x11vnc.service` | VNC 服务 |
| `gost.service` | SOCKS5/HTTP 代理隧道 |

配置数据存储在 `/root/.config/securelink/`，容器重启后自动恢复（需在服务文件中显式设置 `Environment=HOME=/root`）。

## 项目结构

```
├── Dockerfile          # Arch Linux 版本
├── Dockerfile.debian   # Debian 版本
├── docker-compose.yml  # Compose 配置
├── run.sh              # Podman 启动脚本
├── services/           # 自定义 systemd 服务文件
│   ├── securelink.service      # VPN 守护进程（覆盖 vendor 版本）
│   ├── securelink_gui.service  # Electron GUI
│   ├── xvfb.service            # 虚拟显示
│   ├── fluxbox.service         # 窗口管理器
│   ├── x11vnc.service          # VNC
│   ├── xterm.service           # 终端
│   └── gost.service            # 代理隧道
└── securelink/         # 子模块 — PKGBUILD 和 .deb 打包
    ├── PKGBUILD        # Arch 打包脚本
    ├── .install        # Arch 安装钩子
    ├── repack.sh       # .deb 重新打包脚本
    ├── new-postinst    # 简化版 postinst
    └── new-postrm      # 简化版 postrm
```

## 镜像

[![DockerHub](https://img.shields.io/badge/DockerHub-exyexin%2Fdocker--securelink--vpn-blue)](https://hub.docker.com/r/exyexin/docker-securelink-vpn)

```bash
docker pull exyexin/docker-securelink-vpn:latest
```
