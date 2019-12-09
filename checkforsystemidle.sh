#!/bin/bash

#### checkforsystemidle.sh:
# check idle time of x-activity for a user using xprintidle
# check number of logged in users (including ssh sessions) and their idle time using last and w
# check if there are locked files accessed via smb
# if all are above/below their threshold -> execute a command

#### config:
# the user has to be idle longer than this according to X, in milliseconds
XIDLE_USERNAME="wrstl"
XIDLE_LIMIT_MS=1200000 # 1200000 = 20 minutes
# less than that many counts of "still logged in" are allowed to be in the output of last
# There are usually 3 just from having x running, plus 1 for a default shell window
# (Check the output of last -pnow right after booting)
LOGGEDIN_LIMIT=5 # 5 = 4 or less
# all user sessions have to be idle longer than this according to w, in seconds
W_IDLE_LIMIT_S=1200 # 1200 = 20 minutes
# do this if the system is found to be idle:
COMMAND_TO_EXECUTE="/sbin/poweroff"


#### idle checking:

# get the x idle time according to the xscreensaver extension:
XIDLE_TIME_MS=$(/sbin/runuser -l $XIDLE_USERNAME -c "DISPLAY=:0 /usr/bin/xprintidle")

echo "X_IDLE= " ${XIDLE_TIME_MS} "ms"

if [ $XIDLE_TIME_MS -gt $XIDLE_LIMIT_MS ] ;
then

# get a string that reflects if there are any files locked via SMB
SMBLOCKS_FLAG=$(/usr/bin/smbstatus -L | /bin/grep "Locked files:")

    echo "SMBLOCKS= " ${SMBLOCKS_FLAG} "?"

    if [[ -z "${SMBLOCKS_FLAG}" ]] ;
    then

# get the number of user sessions still logged in according to last
LOGGEDIN_COUNT=$(/usr/bin/last -pnow | /bin/grep -c "still logged in")

        echo "LOGGEDIN_COUNT =" ${LOGGEDIN_COUNT} "users"

        if [ $LOGGEDIN_COUNT -lt $LOGGEDIN_LIMIT ] ;
        then

# get the minimum of the idle times of sessions according to w
# (the complex awk is needed to transform the time output of w into seconds)
W_IDLE_MINIMUM=$(/usr/bin/w --no-header --short |\
/usr/bin/awk 'BEGIN {min=999999999}{\
if ($4 == "days") { val=$3*86400 }\
else if ($4 == "s") { split($3,s,"."); val=s[1]+0 }\
else if ($4 == "m") { split($3,m,":"); val=(m[1]*60+m[2])*60 }\
else { split($3,m,":"); val=m[1]*60+m[2] }\
if (val < min) min=val }\
END {print min}')

            echo "W_IDLE =" ${W_IDLE_MINIMUM} "s (lowest)"

            if [ $W_IDLE_MINIMUM -gt $W_IDLE_LIMIT_S ] ;
            then

                eval $COMMAND_TO_EXECUTE

            fi
        fi
    fi
fi



