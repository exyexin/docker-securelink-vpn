podman run -it --name $1 \
	--stop-timeout 20 \
	--cap-add SYS_ADMIN \
	--cap-add NET_ADMIN \
	--device /dev/net/tun \
	-p 5902:5900 \
	-p 10802:10801 \
	-p 18889:18888 \
	svpn
