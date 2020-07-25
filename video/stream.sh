#!/bin/sh
#justin.tv streaming command functionality

#streaming() {
#   INRES="1440x900"                                            # input resolution
   INRES="800x600"                                            # input resolution
#   OUTRES="1440x900"                                           # Output resolution
   OUTRES="800x600"                                           # Output resolution
   FPS="35"                                                    # target FPS
   QUAL="medium"                                               # one of the many FFMPEG preset on (k)ubuntu found in /usr/share/ffmpeg
                                                               # If you have low bandwidth, put the qual preset on 'fast' (upload bandwidth)
                                                              # If you have medium bandwitch put it on normal to medium
   STREAM_KEY="live_12345678_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234"   # This is your streamkey generated by jtv/twitch found at: http://www.justin.tv/broadcast/adv_other

#   ffmpeg -f x11grab -s "$INRES" -r "$FPS" -i :0.0+0,0 -itsoffset 00:00:01 -f alsa -ac 2 -i pulse  -vcodec libx264 -vpre "$QUAL" -s "$OUTRES" -acodec libmp3lame -ab 96k -threads 6 -qscale 5 -b 1024kb -f flv "rtmp://live.justin.tv/app/$STREAM_KEY" 
#   ffmpeg -f x11grab -s "$INRES" -r "$FPS" -i :0.0+0,0 -itsoffset 00:00:01 -f alsa -ac 2 -i hw:0,0  -vcodec libx264 -s "$OUTRES" -acodec libmp3lame -ar 44100 -threads 6 -qscale 5 -b 256k -f flv "rtmp://live.twitch.tv/app/$STREAM_KEY" 
   ffmpeg -f x11grab -s "$INRES" -r "$FPS" -i :0.0+0,0 -itsoffset 00:00:01 -f alsa -ac 2 -i pulse -vcodec libx264 -s "$OUTRES" -acodec libmp3lame -ar 44100 -threads 6 -qscale 5 -b 256k -f flv "rtmp://live.twitch.tv/app/$STREAM_KEY" 
#}



# -f x11grab = force format.  This causes ffmpeg to force the format to grab the x11 display

# -s "$INRES" = Sets the frame size of the grab to the input resolution.  This is Width X Height. The "$INRES" is a variable that you set previously.

# -r "$FPS" = this sets the framerate to your target fps. (it's okay if it doesn't hit this rate, but I wouldn't set it much higher than 35)

# -i :0.0+0,0 = -i usually refers to the input filename.  Since we're grabbing the display, the :0.0+0,0 tells it the coordinates of the screen to grab and how much area of the screen to grab.  Incidentally :0.0+0,0 tells it to grab the entire screen.

# -itsoffset 00:00:01 = This sets an input time offset in seconds "hh:mm:ss" only applies to input files that come after it.  (this isn't neccesary, only attempts to correct for lag between audio and video.

# -f alsa = Forcing the alsa format

# -ac 2 = sets the adio channels to 2 (stereo).  Defaults to 1 (mono).

# -i pulse = sets ffmpeg to capture audio from pulse

# -vcodec libx264 = forces ffmpeg to use the cideo codec of libx264

# -vpre "$QUAL" = forces ffmpeg to use the "$QUAL" (quality variable) presets.

# -s "$OUTRES" = sets the output size to the "$OUTRES" variable.  I have played with this and found that for best quality it should probably match $INRES

# -acodec libmp3lame = forces ffmpeg to compress the audio into an mp3 stream

# -ab 96k = sets the audio bitrate to 96k - this doesn't have to be high on the stream and will help scale back the bandwidth usage.

# -threads 6 = Thread count.  Typically this should only be as high as the number of processing cores you have available.

# -qscale 5 = This has to do with the compression of the overall thread (quantization)  Leave it at 5.

# -f flv = forces the output format to flv (the flash video format that jtv/twitch can recognize)

# -b 1024kb = this is the bitrate of the output stream.  YOU WILL NEED TO CHANGE THIS TO WORK WITH YOUR BANDWIDTH/ISP SETTINGS.

# "rtmp://live.justin.tv/app/$STREAM_KEY" = this is the output file, in our case it outputs it via the RTMP protocol to justin.tv using your streamkey.