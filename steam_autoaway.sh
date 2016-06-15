#!/bin/sh
# Author: Rocik
# Requirements: xprintidle & steam
# Description: Changes steam status to away after x minutes of idle and restores it.
#              Status won't be changed while using VLC.
# Changed: 10 February 2015

minutes=5

changeStatusTo() {
	steam steam://friends/status/$1 > /dev/null 2>&1
}

idleTime=$(($minutes*60*1000))
sleepTime=$idleTime
triggered=false
isIdle=false

while true; do
	idle=$(xprintidle)
	if $isIdle; then
		if [ $idle -lt $idleTime ]; then
			changeStatusTo "online"
			isIdle=false
			sleepTime=$idleTime
		fi
	else
		if ps cax | grep steam$ > /dev/null; then
			if [ $idle -ge $idleTime ]; then
				if ! $triggered; then
					QBUS_output=$(qdbus org.mpris.MediaPlayer2.vlc /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player PlaybackStatus) > /dev/null 2>&1
					if [ "$QBUS_output" != "Playing" ]; then
						changeStatusTo "away"
						triggered=true
						isIdle=true
						sleepTime=1
						continue
					fi
				fi
			else
				triggered=false
				sleepTime=$((idleTime-idle+100))
			fi
		fi
	fi
	sleep $(((sleepTime+999)/1000))
done

exit 0
