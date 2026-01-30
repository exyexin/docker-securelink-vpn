FROM archlinux:latest

COPY securelink-3.8.13_66-1-x86_64.pkg.tar.zst /root/
COPY services /root/services

RUN mv /etc/pacman.d/mirrorlist{,.bak} && echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist && \
	pacman-key --init && pacman-key --populate archlinux && \
	pacman -Syu fluxbox x11vnc xterm xorg-server-xvfb iproute lsb-release procps-ng iptables wget curl gost supervisor wqy-microhei ttf-cascadia-code \
	at-spi2-core libcups gtk3 \
	libnotify libxtst nss dmidecode \
	--needed --noconfirm && \
	pacman -U /root/securelink-3.8.13_66-1-x86_64.pkg.tar.zst --noconfirm && \
	rm -rf /var/cache/pacman/ \

COPY app/conf.d/service /root/service
RUN cp /root/services/* /etc/systemd/system/ 
RUN	systemctl enable gost.service xterm.service securelink_gui.service x11vnc.service
# Fetch Securelink vpn
#RUN wget https://download-sdwan.wangsu.com/public/securelink/pkg/formal/COMMON/ubuntuX64/SecureLink-ubuntu-x64-3.8.13-66.deb



# Setup demo environment variables
ENV HOME=/root \
    USER=root \ 
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1024 \
    DISPLAY_HEIGHT=768 \
    RUN_XTERM=yes \
    RUN_FLUXBOX=yes

#COPY svpn/data/opt /opt
#COPY svpn/control/*inst /root/

# Download and verify UniVPN
WORKDIR /root

#EXPOSE 5900
#EXPOSE 8080
#EXPOSE 2222
#EXPOSE 10801
#EXPOSE 18888

CMD ["/lib/systemd/systemd"]
