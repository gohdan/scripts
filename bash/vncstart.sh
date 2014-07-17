#!/bin/sh
#x11vnc -rfbauth ~/.vnc/passwd -display :0 -auth /home/gohdan/.Xauthority -ncache 10 &
#x11vnc -display :0  -auth /var/gdm/:0.Xauth
#x11vnc -rfbauth ~/.vnc/passwd -display :0 -auth /home/gohdan/.Xauthority -ncache 10 &
/usr/bin/x11vnc -rfbauth ~/.vnc/passwd -display :0 -auth /home/gohdan/.Xauthority -nonc &

