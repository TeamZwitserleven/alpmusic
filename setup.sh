#!/bin/sh 

if [ "$(id -u)" -ne "0" ]; then
        echo "This script requires root."
        exit 1
fi

PIUSER=${PIUSER:=pi}
if [ -z "${PIPASSWORD}" ]; then 
    echo Set PIPASSWORD 
    exit 1
fi

MPG123=$(which mpg123)
if [ -z "${MSG123}" ]; then
    apt-get -y install mpg123
    MPG123=$(which mpg123)
fi

adduser --gecos $PIUSER --disabled-login $PIUSER --uid 1000
chown -R 1000:1000 /home/$PIUSER 
echo "$PIUSER:$PIPASSWORD" | chpasswd 
usermod -a -G sudo,adm,input,video,plugdev $DEBUSER

mkdir -p /music 
cp -Rf music/*.mp3 /music/
chown -R 1000:1000 /music 

cat > "/etc/systemd/system/music-player.service" <<EOF
[Unit]
Description=Play music 

[Service]
ExecStart=/usr/bin/mpg123 -Z /music/*

[Install]
WantedBy=multi-user.target
EOF

systemctl enable music-player.service
systemctl restart music-player.service
