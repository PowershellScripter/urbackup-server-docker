# /bin/bash

apt-get update
apt-get install -y curl wget
export VERSION=`curl -s https://beta.urbackup.org/Server/ | grep -Po '\b2.5.(\d+)' | tail -1`
export FILE=`curl -s "https://beta.urbackup.org/Server/${VERSION}/" | grep -Po 'urbackup-server_.*?deb' | tail -1`
export URL="https://beta.urbackup.org/Server/$VERSION/$FILE"

wget "$URL" /root/$FILE
echo "urbackup-server urbackup/backuppath string /backups" | debconf-set-selections
apt-get install -y --no-install-recommends "/root/$FILE" btrfs-tools
rm "/root/$FILE"
apt-get clean
rm -rf "/var/lib/apt/lists/*"