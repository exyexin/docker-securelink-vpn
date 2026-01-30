FROM archlinux:latest

#COPY securelink-3.8.13_66-1-x86_64.pkg.tar.zst /root/
COPY services /root/services
COPY securelink /root/securelink

RUN pacman-key --init && pacman-key --populate archlinux && \
	pacman -Syu git fluxbox x11vnc xterm xorg-server-xvfb iproute apparmor lsb-release procps-ng unzip gzip iptables wget curl gost supervisor noto-fonts-cjk ttf-cascadia-mono-nerd \
	at-spi2-core libcups gtk3 base-devel\
	libnotify libxtst nss dmidecode \
	--needed --noconfirm 

#RUN	pacman -U /root/securelink-3.8.13_66-1-x86_64.pkg.tar.zst --noconfirm && \
RUN cd securelink && makepkg -s --noconfirm && \
	pacman -U ./securelink-3.8.13_66-1-x86_64.pkg.tar.zst --noconfirm && \
	pacman -Rs base-devel git --noconfirm && \
	rm -rf /var/cache/pacman/ /root/securelink\

COPY app/conf.d/service /root/service
RUN cp /root/services/* /etc/systemd/system/ 
RUN	systemctl enable gost.service xterm.service securelink_gui.service
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

#COPY app /app
CMD ["/lib/systemd/systemd"]
