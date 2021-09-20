ARG IMAGE_ARCH=debian:bullseye

FROM ${IMAGE_ARCH}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
        && apt-get install -y curl wget\
        && VERSION=`curl -s https://beta.urbackup.org/Server/ | grep -Po '\b2.5.(\d+)' | tail -1` \
        && FILE=`curl -s "https://beta.urbackup.org/Server/${VERSION}/" | grep -Po 'urbackup-server_.*?deb' | tail -1` \ 
        && URL="https://beta.urbackup.org/Server/$VERSION/$FILE" \
        && curl -s "$URL" -o "/root/$FILE"\
        && echo "urbackup-server urbackup/backuppath string /backups" | debconf-set-selections \
        && apt-get install -y --no-install-recommends /root/$FILE btrfs-progs \
        && rm /root/$FILE \
        && apt-get clean \
        && rm -rf "/var/lib/apt/lists/*"
        

ARG QEMU_ARCH

COPY entrypoint.sh qemu-$QEMU_ARCH-static* /usr/bin/

RUN mkdir /web-backup && cp -R /usr/share/urbackup/* /web-backup

RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 55413
EXPOSE 55414
EXPOSE 55415
EXPOSE 35623/udp

VOLUME [ "/var/urbackup", "/var/log", "/backups" ]
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["run"]
