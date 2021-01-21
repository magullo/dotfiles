#!/usr/bin/env bash

# lemonbar awkwardness
# call lemonbar(autostart etc) =  /usr/local/bin/citrus.sh | lemonbar -g 1366x24+0+0 -pb -f "Terminus-Bold-14"

WIFIDOWN() {
        WIFIDOWN=$(ip a | awk 'BEGIN {print "Down:"};NR==14 { print $6" "$7 }' | fmt -20)

        echo -n "$WIFIDOWN"
}

WIFIUP() {
 WIFIUP=$(ip a | awk 'BEGIN {print "Up:"};NR==16 { print $6" "$7 }' | fmt -20)

 echo -n "$WIFIUP"
}

UNAME() {
 UNAME=$(uname -a | awk '{ print $1" "$3" "$8 }')

 echo -n "$UNAME"

}

MEM() {
 MEM=$(free -h --kilo | awk 'NR==2 { print $1" " $3 " / " $2}')

 echo -n "$MEM"

}

CPU() {
 CPU=$(top -bn1 -p0 | awk 'NR==3 { print $1" "$4 }' | tr -d ["(s)"])

 echo -n "$CPU"

}

ROOT() {
 ROOT=$(df -h | awk 'NR==4 { print $6"root: "$3" / "$2}')

 echo -n "$ROOT"

}

HOME() {
 HOME=$(df -h | awk 'NR==7 { print $6": "$3" / "$2}')

 echo -n "$HOME"

}
while true; do
        echo -e "%{c}%{F#cecece}%{B#E6414141} $(UNAME) | $(WIFIDOWN) | $(WIFIUP) | $(CPU) | $(MEM) | $(ROOT) | $(HOME) %{F-}%{B-}"
        sleep 1
done

