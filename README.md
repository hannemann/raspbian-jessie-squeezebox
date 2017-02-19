# raspbian-jessie-squeezebox

### Hardware
* Raspi 3
* Behringer ufo202 (comes with integrated phono preamp and works ootb with raspbian jessie)
* Hifiberry DAC+
* Superpower HTPC Case with integrated 7" Touchscreen and a front Panel with 5 tactile switches, a power switch and a IR receiver (the panel does not work in any way and has to be modified)
For the DAC to work add following line to /boot/config.txt
```
dtoverlay=hifiberry-dacplus
```
I soldered pin headers to the dac. Most GPIO pins can then be used for... general purpose. We use them to read the buttons from the front panel and the ir-receiver. Also the display and PSU can be turned on and off. To make this work i made a pcb from perfboard with some resistors and transistors. Not too hard to build. To connect the PSU i salvaged the atx connector from an outaged motherboard and glued it on the pcb.

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
        startx /home/pi/jivelite/bin/jivelite
fi
```
### Install and Configure Alsa Equalizer Plugin
```
sudo apt-get install libasound2-plugin-equal
```
Equal related configuration in /etc/asound.conf:
```
ctl.equal {
	type equal;
	controls "/home/pi/.alsaequal.bin"
}
 
pcm.plugequal {
	type equal;
	slave.pcm "sysdefault:CARD=sndrpihifiberry";
	controls "/home/pi/.alsaequal.bin"
}
 
pcm.equal {
	type plug;
	slave.pcm plugequal;
}
```
Configure squeezelite to use equal plugin as output in /etc/default/squeezelite
```
SL_SOUNDCARD="equal"
```
To adjust sound to your likings type
```
sudo alsamixer -D equal
```
## Hardware
ATX Power supply for the PI via +5VSB and switching the PSU on already working. More to come...

### Hardware for lirc via GPIO
I have used a TSOP4838 IR Receiver. The pinout can be found in several Datasheets available around the internet.

Connect pin VCC to a +3.3V pin of the PI, pin GND to a ground pin and the data pin to an arbitrary GPIO pin.

Edit /boot/config.txt:
```
dtoverlay=lirc-rpi,gpio_in_pin=22,gpio_out_pin=27
```

### Install and configure lirc
```
sudo apt-get install lirc
```
[hardware.conf](https://github.com/hannemann/raspbian-jessie-squeezebox/blob/master/etc/lirc/hardware.conf)
```
irrecord -n -d /dev/lirc0 remote # follow instructions
sudo cp remote /etc/lirc/lircd.conf
```

Next steps: lirc via GPIO, the case i am using has some tactile switches that can be used for navigation, pre amp USB soun card for the turntable, cd playback via cdrom, eGalay Touchscreen driver and calibration

### Playback from Turntable and AUX Device e.g. Tape
To have lossless streams we use liquidsoap to encode the data from the soundcards to flac piping it to icecast2

#### Install Liquidsoap and Icecast2
```
sudo apt-get install liquidsoap liquidsoap-plugins-all icecast2
```
#### Configure Liquidsoap and Icecast
Create *.liq files for every source you want to stream
* [aux.liq](https://github.com/hannemann/raspbian-jessie-squeezebox/blob/master/etc/liquidsoap/aux.liq)
* [phono.liq](https://github.com/hannemann/raspbian-jessie-squeezebox/blob/master/etc/liquidsoap/phono.liq)

Icecast will ask for hostname and passwords while installing. Type in localhost and your password used in darkice configuration. Always use extreme secure passwords!


