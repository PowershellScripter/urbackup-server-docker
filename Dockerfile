# Base image can be specified by --build-arg IMAGE_ARCH= ; defaults to debian:stretch
ARG IMAGE_ARCH=debian:bullseye
FROM ${IMAGE_ARCH}

ENV DEBIAN_FRONTEND=noninteractive

#ARG VERSION=2.5.22
RUN apt-get update \
        && apt-get install -y curl wget\
        && VERSION=`curl -s https://beta.urbackup.org/Server/ | grep -Po '\b2.5.(\d+)' | tail -1` \
        && FILE=`curl -s "https://beta.urbackup.org/Server/${VERSION}/" | grep -Po 'urbackup-server_.*?deb' | tail -1` \ 
        && URL="https://beta.urbackup.org/Server/$VERSION/$FILE" \
        && curl -SLO "$URL" "/root/$FILE"\
        && echo "urbackup-server urbackup/backuppath string /backups" | debconf-set-selections \
        && apt-get install -y --no-install-recommends /root/$FILE btrfs-tools \
        && rm /root/$FILE \
        && apt-get clean \
        && rm -rf "/var/lib/apt/lists/*"
        

ARG QEMU_ARCH


## Copy the entrypoint-script and the emulator needed for autobuild function of DockerHub
COPY entrypoint.sh qemu-$QEMU_ARCH-static* /usr/bin/
#ADD ${cat ./URL} /root/${cat ./FILE}

## Install UrBackup-server
#RUN echo "urbackup-server urbackup/backuppath string /backups" | debconf-set-selections \
#        && apt-get install -y --no-install-recommends /root/$(cat ./FILE) btrfs-tools \
#        && rm /root/$(cat ./FILE) \
#        && apt-get clean \
#        && rm -rf /var/lib/apt/lists/*

## Backing up www-folder
RUN mkdir /web-backup && cp -R /usr/share/urbackup/* /web-backup
## Making entrypoint-script executable
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 55413
EXPOSE 55414
EXPOSE 55415
EXPOSE 35623/udp

## /usr/share/urbackup will not be exported to a volume by default, but it still can be bind mounted
VOLUME [ "/var/urbackup", "/var/log", "/backups" ]
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["run"]
