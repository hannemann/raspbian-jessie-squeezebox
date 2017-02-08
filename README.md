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
ATX Power supply for the PI via +5VSB and switching the PSU on already working. More to come...

### Hardware for lirc via GPIO
I have used a TSOP4838 IR Receiver. The pinout can be found in several Datasheets available around the internet.

Connect pin VCC to a +3.3V pin of the PI, pin GND to a ground pin and the data pin to an arbitrary GPIO pin.

Edit /boot/config.txt:
```
dtoverlay=lirc-rpi,gpio_in_pin=22,gpio_out_pin=27
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

### Playback from Turntable
Install Darkice-1.2 and Icecast2
```
sudo apt-get install darkice icecast2
```
Configure Darkice:
```
sudo cp /usr/share/doc/darkice/examples/darkice.cfg.gz /etc/
cd /etc/
sudo gunzip darkice.cfg.gz
sudo vi darkice.cfg
```
My Config:
```
# sample DarkIce configuration file, edit for your needs before using
# see the darkice.cfg man page for details

# this section describes general aspects of the live streaming session
[general]
duration        = 0        # duration of encoding, in seconds. 0 means forever
bufferSecs      = 5         # size of internal slip buffer, in seconds
reconnect       = yes       # reconnect to the server(s) if disconnected
realtime        = yes       # run the encoder with POSIX realtime priority
rtprio          = 3         # scheduling priority for the realtime threads

# this section describes the audio input that will be streamed
[input]
device          = hw:1,0  # OSS DSP soundcard device for the audio input
sampleRate      = 44100     # sample rate in Hz. try 11025, 22050 or 44100
bitsPerSample   = 16        # bits per sample. try 16
channel         = 2         # channels. 1 = mono, 2 = stereo

# this section describes a streaming connection to an IceCast2 server
# there may be up to 8 of these sections, named [icecast2-0] ... [icecast2-7]
# these can be mixed with [icecast-x] and [shoutcast-x] sections
[icecast2-0]
bitrateMode     = cbr       # average bit rate
format          = mp3    # format of the stream: ogg vorbis
bitrate         = 320        # bitrate of the stream sent to the server
server          = localhost
                            # host name of the server
port            = 8000      # port of the IceCast2 server, usually 8000
password        = crazysecretpasswordnevertobehacked    # source password to the IceCast2 server
mountPoint      = phono  # mount point of this stream on the IceCast2 server
name            = Phono
                            # name of the stream
description     = This is only a trial
                            # description of the stream
url             = http://[address of your pi]:8000/phono
                            # URL related to the stream
genre           = my own    # genre of the stream
public          = yes       # advertise this stream?
localDumpFile   = dump.ogg  # local dump file
```
Icecast will ask for hostname and passwords while installing. Type in localhost and your password used in darkice configuration. Always use extreme secure passwords!

/etc/asound.conf:
```
pcm.!default  {
 type hw card 0
}
ctl.!default {
 type hw card 0
}
pcm.rate_convert {
        type plug
        slave {
                pcm "hw:1,0"
                rate 48000
        }
}
```
