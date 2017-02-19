#!/bin/bash

if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
if [ $(tty) = "/dev/tty1" ]; then
	#panel-lib # only needed if you own my HTPC Case ;)
	while true; do
		startx	/home/pi/jivelite/bin/jivelite
	done
fi
