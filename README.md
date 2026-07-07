# Docker SecureLink VPN

基于 Arch Linux 的 SecureLink VPN 容器化部署，提供 X11/VNC 桌面环境用于 GUI 交互。

## 快速启动

### Docker Compose（推荐）

```bash
git clone --recurse-submodules https://github.com/exyexin/docker-securelink-vpn.git
cd docker-securelink-vpn
docker compose up -d
```

使用 DockerHub 镜像（无需本地构建，需修改 `docker-compose.yml` 中的 `image` 字段）：

```yaml
image: exyexin/docker-securelink-vpn:latest
```

### 手动构建

```bash
cd securelink && makepkg
cd ../
podman build -t svpn .
bash ./run.sh <container_name>
```

> 初次启动可能需要选择 timezone，之后即可正常使用。

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

配置数据存储在 `/root/.config/securelink/`，容器重启后自动恢复登录信息。（需在服务文件中显式设置 `Environment=HOME=/root`）

## 镜像

[![DockerHub](https://img.shields.io/badge/DockerHub-exyexin%2Fdocker--securelink--vpn-blue)](https://hub.docker.com/r/exyexin/docker-securelink-vpn)

```bash
docker pull exyexin/docker-securelink-vpn:latest
```
