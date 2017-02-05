# raspbian-jessie-squeezebox

### Jivelite
dependencies installed:
* git
* libsdl1.2-dev
* libsdl-ttf2.0-dev
* libsdl-image1.2-dev
* libsdl-gfx1.2-dev
* libexpat1-dev

dependencies compiled:
* luajit
```
git clone http://luajit.org/git/luajit-2.0.git
cd luajit-2.0
make
sudo make install
cd ..
```

### Compile Jivelite
```
git clone https://code.google.com/p/jivelite/
cd jivelite
sudo make
```
These commands create a binary in the bin subfolder that can be executed from a terminal on the display you want to use it. Starting the binary via ssh does not work.
Jivelite runs without an X server.

### Autologin via systemd
```sudo vi /etc/systemd/system/getty@tty1.service.d/override.conf```
```
[Service]
Type=simple
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I $TERM
```
``` vi ~/.bash_profile```
```
#!/bin/bash

if [ $(tty) = "/dev/tty1" ]; then
        /usr/bin/gpio mode 0 out
        /usr/bin/gpio write 0 1
        /home/pi/triode-jivelite/bin/jivelite
fi
```
ATX Power supply for the PI via +5VSB and switching the PSU on already working. More to come...

Next steps: lirc via GPIO, the case i am using has some tactile switches that can be used for navigation, pre amp USB soun card for the turntable, cd playback via cdrom, eGalay Touchscreen driver and calibration
