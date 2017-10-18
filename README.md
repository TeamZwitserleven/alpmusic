# Alp Horn Player 

## Requirements 

- Orange PI Zero 
- 8GB (or higher) uSD card
- Speaker set 
- 3.5mm audio jack connector 

## Hardware setup 

Connect the audio jack as follows to 13 pin header:

- Audio jack 1 -> PIN 2 (GND)
- Audio jack 2 -> PIN 7 (LINEOUTR)
- Audio jack 5 -> PIN 8 (LINEOUTL)

- Loconet pin 1 -> GPIO 11 
- Loconet pin 2 -> GPIO 12

## Software Setup 

- Download Armbian `Ubuntu Server Legacy` image from https://www.armbian.com/orange-pi-zero/.
- Unzip & flash to SD card
- Insert SD card in Orange PI Zero, connect ethernet & power up
- SSH into pi: `ssh root@orangepizero` (default password `1234`)
- Enter default & new root password
- Abort with Ctrl-C to prevent user account creation
- SSH into pi: `ssh root@orangepizero` (use updated password)
- `git clone https://github.com/TeamZwitserleven/alpmusic.git` 
- `cd alpmusic`
- `PIPASSWORD=yourpassword ./setup.sh`
- `reboot`
