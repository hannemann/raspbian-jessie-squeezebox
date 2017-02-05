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
        /home/pi/jivelite/bin/jivelite
fi
```
ATX Power supply for the PI via +5VSB and switching the PSU on already working. More to come...

### Hardware for lirc via GPIO
I have used a TSOP4838 IR Receiver. The pinout can be found in several Datasheets available around the internet.

Connect pin VCC to a +3.3V pin of the PI, pin GND to a ground pin and the data pin to an arbitrary GPIO pin.

Edit /boot/config.txt:
```
...PLACE CODE HERE...
```
/etc/lirc/hardware.conf
```
# /etc/lirc/hardware.conf
#
# Arguments which will be used when launching lircd
LIRCD_ARGS="--uinput"

#Don't start lircmd even if there seems to be a good config file
#START_LIRCMD=false

#Don't start irexec, even if a good config file seems to exist.
START_IREXEC=true

#Try to load appropriate kernel modules
LOAD_MODULES=true

# Run "lircd --driver=help" for a list of supported drivers.
DRIVER="default"
# usually /dev/lirc0 is the correct setting for systems using udev
DEVICE="/dev/lirc0"
MODULES="lirc_rpi"

# Default configuration files for your hardware if any
LIRCD_CONF=""
LIRCMD_CONF=""
```

### Install and configure lirc
```
sudo apt-get install lirc
irrecord -n -d /dev/lirc0 remote # follow instructions
sudo cp remote /etc/lirc/lircd.conf
```

Next steps: lirc via GPIO, the case i am using has some tactile switches that can be used for navigation, pre amp USB soun card for the turntable, cd playback via cdrom, eGalay Touchscreen driver and calibration
