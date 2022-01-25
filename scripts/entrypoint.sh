#!/bin/bash

if [ -f /lgsm_bootstrap.sh ]
then
    source /lgsm_bootstrap.sh
fi

source /lgsm_functions.sh
source /lgsm_variables.sh

if [ $# = 0 ]
then

    # Set user and group ID to server-data/server-files user
    groupmod -o -g "$PGID" server-data  > /dev/null 2>&1
    usermod -o -u "$PUID" server-data  > /dev/null 2>&1
    groupmod -o -g "$PGID" server-files  > /dev/null 2>&1
    usermod -o -u "$PUID" server-files  > /dev/null 2>&1

    # Locale, Timezone
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    ln -snf /usr/share/zoneinfo/$TimeZone /etc/localtime && echo $TimeZone > /etc/timezone
    
    # no command
    fn_check_user

    source /lgsm_install.sh
    source /lgsm_gameserver.sh
    source /lgsm_start.sh

    if [ -f /lgsm_console.sh ]
    then
        source /lgsm_console.sh
    fi

    tail -f /dev/null
else
    # execute the command passed through docker
    "$@"
fi

exit 0
