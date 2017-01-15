# raspbin-jessie-squeezebox

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

### Compile Triode Jivelite
```
git clone https://github.com/ralph-irving/triode-jivelite.git
cd triode-jivelite
sudo make PREFIX=/usr/local
```
These commands create a binary in the bin subfolder that can be executed from a terminal on the display you want to use it. Starting the binary via ssh does not work.
Jivelite runs without an X server.

### Autologin via systemd
```sudo vi /etc/systemd/system/getty@tty1.service.d/override.conf```
```
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin pi --noclear %I $TERM
```
~/.bash_profile
```
#!/bin/bash

[[ $(tty) = "/dev/tty1" ]] && /home/pi/triode-jivelite/bin/jivelite
```
