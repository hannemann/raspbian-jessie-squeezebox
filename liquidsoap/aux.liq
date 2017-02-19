#!/usr/bin/liquidsoap

# set the path and permissions for the logfile
set("log.file.path","/var/log/liquidsoap/aux.log")
set("log.file.perms",755)
set("log.unix_timestamps",true)

#input from soundcard
aux = input.alsa(bufferize=true,fallible=false,device="hw:CARD=aux")

#stream it to local icecast, default port and password
output.icecast(
        %ogg(
                %flac(
                        samplerate = 44100,
                        channels = 2,
                        compression = 5,
                        bits_per_sample = 16
                )
        ),
        format = "audio/ogg",
        description = "Tape FLAC",
        url = "http://127.0.0.1:8221",
        genre = "Misc",
        mount = "/tape",
        name = "Misc",
        host = "hifipi.hannemann.lan", port=8000, password="************",
        aux
)
