#!/bin/ksh
#
# $Header$

Battery() {
	ADAPTER=$(apm -a)
	if [ $ADAPTER = 0 ] ; then
		echo -n "%{F#FF0000}%{B#000000}AC: %{F-}%{B-}"
	elif [ $ADAPTER = 1 ] ; then
		echo -n "%{F#00FF00}%{B#000000}AC: %{F-}%{B-}"
	else
		echo -n "%{F#0000FF}%{B#000000}AC: %{F-}%{B-}"
	fi
	BATTERY=$(apm -l)
	if [ $BATTERY -gt 66 ] ; then
		echo -n "%{F#00FF00}%{B#000000}$BATTERY%% %{F-}%{B-}"
	elif [ $BATTERY -gt 33 ] ; then
		echo -n "%{F#FFFF00}%{B#000000}$BATTERY%% %{F-}%{B-}"
	else
		echo -n "%{F#FF0000}%{B#000000}$BATTERY%% %{F-}%{B-}"
	fi
	BATTERY=$(apm -m)
	[[ "$BATTERY" != "unknown" ]] && echo -n " ($BATTERY m) "
}

Clock() {
	DATETIME=$(date "+%a %d.%m.%Y %H:%M")
	echo -n "%{F#00FFFF}%{B#000000}$DATETIME%{F-}%{B-}"
}

Cpu() {
	set -A cpu_names $(iostat -C | sed -n '2,2p')
	set -A cpu_values $(iostat -C | sed -n '3,3p')
	CPULOAD=$((100-${cpu_values[5]}))
	CPUTEMP=$(sysctl hw.sensors.cpu0.temp0 | awk -F "=" '{ gsub("deg", "°", $2); print $2 }')
	CPUSPEED=$(apm | sed '1,2d;s/.*(//;s/)//')
	if [ $CPULOAD -ge 90 ] ; then
		echo -n "%{F#FF0000}%{B#000000}"
	elif [ $CPULOAD -ge 80 ] ; then
		echo -n "%{F#FFFF00}%{B#000000}"
	else
		echo -n "%{F#00FF00}%{B#000000}"
	fi
	echo -n "CPU: $CPULOAD%% %{F-}%{B-}$CPUTEMP $CPUSPEED "
}

Ifload() {
	set -A if_load $(ifstat -n -i trunk0 -b 0.1 1 | sed '1,2d')
	echo -n "In: %{F#BBBB00}${if_load[0]}%{F-} kb/s Out: %{F#0000BB}${if_load[1]}%{F-} kb/s "
}

Load() {
	SYSLOAD=$(systat -b | awk 'NR==3 { print $4"  "$5"  "$6 }')
	echo -n "Load: $SYSLOAD "
}

Display() {
	LIGHT=$(xbacklight -get | awk -F'.' '{ print $1 }')
	LIGHTDEC=$((255*$LIGHT/100))
	LIGHTHEX=$(printf "00%x00" $LIGHTDEC)
	echo -n "Display: %{F#$LIGHTHEX}%{B#000000}$LIGHT%% %{F-}%{B-}"
}

Volume() {
	MUTE=$(sndioctl output.mute | awk -F '=' '{ print $2 }')
	LSPK=$(sndioctl output.level | awk -F '=' '{ print $2 * 100 / 255 }')
	RSPK=$(sndioctl output.level | awk -F '=' '{ print $2 * 100 / 255 }')
	if [ "$MUTE" = "on" ] ; then
		echo -n "%{F#FF0000}%{B#000000}"
	else
		echo -n "%{F#00FF00}%{B#000000}"
	fi
	echo -n "Vol:%{F-}%{B-} $LSPK%% $RSPK%% "
}

Wlan() {
	WLANSTAT=$(ifconfig urtwn0 | awk '/status:/ { print $2 }')
	WLANID=$(ifconfig urtwn0  | awk '/(nwid|join)/ { print $3 }')
	WLANSIG=$(ifconfig urtwn0 | awk 'match($0, /[0-9]*%/) { print substr($0, RSTART, RLENGTH) }')
	echo -n "WLAN: "
	if [ "$WLANSTAT" = "active" ] ; then
		echo -n "%{F#00FF00}%{B#000000}"
	else
		echo -n "%{F#FF0000}%{B#000000}"
	fi
	echo -n "$WLANID $WLANSIG %{F-}%{B-}"
}

while true ; do
	echo "%{l}$(hostname -s) | $(Load)| $(Battery)| $(Cpu)%{r}$(Ifload)| $(Wlan)| $(Display)| $(Volume)| $(Clock)"
	sleep 1
done
