podman run -it --name $1 \
	--entrypoint /lib/systemd/systemd \
	--cap-add SYS_ADMIN \
	--cap-add NET_ADMIN \
	--device /dev/net/tun \
	-v /sys/fs/cgroup/:/sys/fs/cgroup/:ro \
	-p 5902:5900 \
	-p 10802:10801 \
	-p 18889:18888 \
	svpn
