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
if [ -z "${MPG123}" ]; then
    apt-get update
    apt-get -y install mpg123
    MPG123=$(which mpg123)
fi

adduser --gecos $PIUSER --disabled-login $PIUSER --uid 1000
chown -R 1000:1000 /home/$PIUSER 
echo "$PIUSER:$PIPASSWORD" | chpasswd 
usermod -a -G sudo,adm,audio,input,video,plugdev $PIUSER

mkdir -p /music 
cp -Rf music/*.mp3 /music/
chown -R 1000:1000 /music 

cat > "/etc/systemd/system/music-player.service" <<EOF
[Unit]
Description=Play music 

[Service]
User=${PIUSER}
ExecStart=/bin/sh -c "mpg123 -Z /music/*.mp3"

[Install]
WantedBy=multi-user.target
EOF

cat > "/home/$PIUSER/.asoundrc" <<EOF
pcm.!default {
 type asym
 capture.pcm "mic"
 playback.pcm "speaker"
}
pcm.mic {
 type plug
 slave {
 pcm "hw:0,0"
 }
}
pcm.speaker {
 type plug
 slave {
 pcm "hw:0,0"
 }
}
EOF

chown -R 1000:1000 /home/$PIUSER 

systemctl daemon-reload
systemctl enable music-player.service
systemctl restart music-player.service
