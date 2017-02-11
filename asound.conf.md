### Complete /etc/asound.conf
```
pcm.!default  {
 type hw card 0
}
ctl.!default {
 type hw card 0
}

# sysdefault:CARD=sndrpihifiberry

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

pcm.rate_convert {
	type plug
	slave {
		pcm "hw:1,0"
		rate 48000
	}
}
```
