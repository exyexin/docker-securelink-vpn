
```bash
cd securelink && makepkg
cd ../
podman build -t svpn .
bash ./run.sh <container name>
```

初次启动需要在tty中输入一次回车或者选择zoneinfo，以完成初始设置后方可正常启动vpn service
