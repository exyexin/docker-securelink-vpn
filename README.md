# Docker SecureLink VPN

基于容器的 SecureLink VPN 部署，提供 X11/VNC 桌面环境用于 GUI 交互。支持 **Arch Linux** 和 **Debian** 两种基础镜像。

## 构建方案

进程管理有两套方案，日常用 **supervisor**，systemd 保留作兼容：

| 方案 | Dockerfile | 进程管理 | 配置 |
|------|-----------|---------|------|
| **supervisor**（推荐） | `Dockerfile`（Arch）<br>`Dockerfile.debian`（Debian） | `tini -s -- supervisord` | `config/supervisord.conf` |
| **systemd**（兼容） | `Dockerfile.debian.systemd` | `/lib/systemd/systemd` | `services/*.service` |

> systemd 方案需要额外挂载 `/sys/fs/cgroup/`，且 `securelink.service` 用 `Type=simple` 但客户端 `-d` 会 fork 退出，服务状态显示会不准确。新部署建议用 supervisor。

## 快速启动

### Docker Compose（推荐）

```bash
git clone --recurse-submodules https://github.com/exyexin/docker-securelink-vpn.git
cd docker-securelink-vpn
podman compose up -d
```

### 手动构建

构建前都需要先生成 SecureLink 安装包（`.deb` 不在版本控制中，见 `securelink/.gitignore`）。

**Debian + supervisor**：

```bash
cd securelink && bash repack.sh && cd ..
podman build -f Dockerfile.debian -t svpn-debian .
```

**Arch + supervisor**：

```bash
cd securelink && makepkg && cp securelink-3.8.13_66-1-x86_64.pkg.tar.zst ..
cd .. && podman build -t svpn .
```

**Debian + systemd**（兼容方案）：

```bash
cd securelink && bash repack.sh && cd ..
podman build -f Dockerfile.debian.systemd -t svpn-debian-systemd .
```

## 运行

`--cap-add` 和 `--device` 三项缺一不可，否则 **VPN 隧道无法建立**（症状可能是 curl 超时之类的迷惑现象）：

```bash
podman run -d --name svpn \
    --cap-add SYS_ADMIN --cap-add NET_ADMIN \
    --device /dev/net/tun \
    -v svpn_config:/root/.config \
    -v svpn_data:/opt/SecureLink/resources/app.asar.unpacked/assets/app-ext/securelink_linux64/config \
    -p 5902:5900 -p 10802:10801 -p 18889:18888 \
    svpn-debian
```

两个 volume 用于持久化 SecureLink 登录态，避免每次重建都要重新登录。

> systemd 方案额外需要 `-v /sys/fs/cgroup/:/sys/fs/cgroup/:ro`。

## 连接

| 端口 | 服务 |
|------|------|
| `5902` | VNC 远程桌面 |
| `10802` | SOCKS5 代理 |
| `18889` | HTTP 代理 |

VNC 连接：`localhost:5902`，登录后在 GUI 里连 VPN。

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `HOME` | `/root` | SecureLink 配置存储路径 |
| `USER` | `root` | 部分组件依赖此变量，缺失会导致启动异常 |
| `DISPLAY` | `:99.0`（supervisor）<br>`:0.0`（systemd） | X11 显示，**必须与 Xvfb 的 display 一致** |
| `DISPLAY_WIDTH` | `1024` | 虚拟屏幕宽度 |
| `DISPLAY_HEIGHT` | `768` | 虚拟屏幕高度 |
| `RUN_XTERM` | `yes` | 启动 XTerm |
| `RUN_FLUXBOX` | `yes` | 启动 Fluxbox 窗口管理器 |

## 服务说明

**supervisor 方案**（`config/supervisord.conf`）按 priority 分四批启动：

| 优先级 | 程序 | 说明 |
|--------|------|------|
| 10 | `xvfb` `gost` `securelink` | 并行启动，无依赖 |
| 20 | `fluxbox` | 依赖 xvfb |
| 30 | `x11vnc` `xterm` | 依赖 fluxbox |
| 40 | `securelink_gui` | 依赖 fluxbox + securelink |

其中 `securelink` 的 `startsecs=0` 是必须的：`SecureLink_Client -d` 会 fork 到后台后立即 `exit 0`，若设成正数，supervisor 会判定启动失败并反复重试，最终 FATAL 且留下多个孤儿进程。

**systemd 方案**的服务文件在 `services/`，对应 `securelink.service` / `securelink_gui.service` / `xvfb.service` / `fluxbox.service` / `x11vnc.service` / `xterm.service` / `gost.service`。

配置数据存储在 `/root/.config/securelink/`，通过 volume 持久化。

## 镜像

| 镜像 | 说明 |
|------|------|
| `akumaexs/svpn-debian` | Debian 基底 |
| `akumaexs/svpn` | Arch 基底 |

```bash
podman pull akumaexs/svpn-debian:latest
```

tag 命名：`<SecureLink版本>-<进程管理方案>`，如 `3.8.13-66-supervisor` / `3.8.13-66-systemd`，`latest` 指向 supervisor 版。

## 项目结构

```
├── Dockerfile                    # Arch + supervisor
├── Dockerfile.debian             # Debian + supervisor
├── Dockerfile.debian.systemd     # Debian + systemd（兼容方案）
├── docker-compose.yml            # Compose 配置
├── run.sh                        # Podman 启动脚本
├── config/
│   └── supervisord.conf          # supervisor 方案的服务定义
├── services/                     # systemd 方案的服务文件
│   ├── securelink.service        # VPN 守护进程（覆盖 vendor 版本）
│   ├── securelink_gui.service    # Electron GUI
│   ├── xvfb.service              # 虚拟显示
│   ├── fluxbox.service           # 窗口管理器
│   ├── x11vnc.service            # VNC
│   ├── xterm.service             # 终端
│   └── gost.service              # 代理隧道
└── securelink/                   # 子模块 — PKGBUILD 和 .deb 打包
    ├── PKGBUILD                  # Arch 打包脚本
    ├── .install                  # Arch 安装钩子
    ├── repack.sh                 # .deb 重新打包脚本
    ├── new-postinst              # 简化版 postinst
    └── new-postrm                # 简化版 postrm
```
