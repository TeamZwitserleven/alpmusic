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

h3consumption -m 800 -u off

adduser --gecos $PIUSER --disabled-login $PIUSER --uid 1000
chown -R 1000:1000 /home/$PIUSER 
echo "$PIUSER:$PIPASSWORD" | chpasswd 
usermod -a -G sudo,adm,audio,input,video,plugdev $PIUSER

mkdir -p /music 
cp -Rf music/*.mp3 /music/
chown -R 1000:1000 /music 

mkdir -p /opt/alpmusic 
cp -f alpmusic /opt/alpmusic/

cat > "/etc/systemd/system/music-player.service" <<EOF
[Unit]
Description=Play music 

[Service]
ExecStartPre=/bin/sh -c "echo 11 > /sys/class/gpio/export"
ExecStartPre=/bin/sh -c "echo in > /sys/class/gpio/gpio11/direction"
ExecStartPre=/bin/sh -c "echo 12 > /sys/class/gpio/export"
ExecStartPre=/bin/sh -c "echo in > /sys/class/gpio/gpio12/direction"
ExecStart=/opt/alpmusic/alpmusic -music=/music/

[Install]
WantedBy=multi-user.target
EOF

cat > "/root/.asoundrc" <<EOF
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

