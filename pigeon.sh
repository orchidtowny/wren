#!/bin/bash
# pigeon launcher
PREFIX="[Pigeon]"
VERSION="1.0-ALPHA"

# Colours
E="\033[31m"
W="\033[33m"
R="\033[0m"
S="\033[32m"
B="\033[1m"
J='\033[1;34m'
G="\033[1;37m"


# directory for servers
pigeon_USER="Pigeon"
SERVER_DIR=$(getent passwd "$pigeon_USER" | cut -d: -f6)
declare -a servers=("magnolia")

if [[ $1 == "help" ]]; then
    echo -e "${W}$PREFIX${R} ${J}Pigeon launcher v${VERSION}${R}"
    echo -e "${W}$PREFIX${R} (c) 2026 kurbiis"
    echo -e "${W}$PREFIX${R} ${J}commands:${R}"
    echo -e "${W}$PREFIX${R}    help    ${G}             ${R}       Show this help menu"
    echo -e "${W}$PREFIX${R}    setup   ${G}             ${R}       Setup pigeon"
    echo -e "${W}$PREFIX${R}    list    ${G}             ${R}       Show all running containers"
    echo -e "${W}$PREFIX${R}    spawn   ${G}(server name)${R}       Run start script of server in new container"
    echo -e "${W}$PREFIX${R}    start   ${G}(server name)${R}       Run start script of server in current container"
    echo -e "${W}$PREFIX${R}    restart ${G}(server name)${R}       Run restart script of server"
    echo -e "${W}$PREFIX${R}    stop    ${G}(server name)${R}       Run stop script of server"
    echo -e "${W}$PREFIX${R}    kill    ${G}(server name)${R}       Kill container of server"
    echo -e "${W}$PREFIX${R}    console ${G}(server name)${R}       Open to console of server"
    echo -e "${W}$PREFIX${R} ${J}available servers:${R}"
    for server in ${servers[@]}; do
        echo -e "${W}$PREFIX${R}    $server"
    done
elif [[ $1 == "spawn" ]]; then
    echo -e "${W}$PREFIX${R} Spawning $2..."
    sudo -u "$pigeon_USER" tmux -S /tmp/tmux_$2 new-session -d -s "$2" -c "$SERVER_DIR/$2" "sh start.sh"
    sudo chgrp admin /tmp/tmux_$2
    sudo chmod 770 /tmp/tmux_$2

elif [[ $1 == "start" ]]; then
    echo -e "${W}$PREFIX${R} Starting $2..."
    sudo -u "$pigeon_USER" tmux -S /tmp/tmux_$2 send-keys -t "$2" "cd $SERVER_DIR/$2" C-m
    sudo -u "$pigeon_USER" tmux -S /tmp/tmux_$2 send-keys -t "$2" "sh start.sh" C-m

elif [[ $1 == "stop" ]]; then
    echo -e "${W}$PREFIX${R} Stopping $2..."
    sudo -u "$pigeon_USER" tmux -S /tmp/tmux_$2 send-keys -t "$2" "stop" C-m

elif [[ $1 == "restart" ]]; then
    echo -e "${W}$PREFIX${R} Restarting $2..."
    sudo -u "$pigeon_USER" tmux -S /tmp/tmux_$2 send-keys -t "$2" "restart" C-m

elif [[ $1 == "kill" ]]; then
    read -r -p "$(echo -e "${W}${PREFIX}${R} you're about to ${E}${B}kill${R} a process ($2). ${E}${B}this could lead to data corruption${R}, would you like to continue? [y/N] ")" ans

    if [[ "${ans,,}" == "y" ]]; then
        echo -e "${W}${PREFIX}${R} Killing $2..."
        sudo -u "$pigeon_USER" tmux -S /tmp/tmux_$2 kill-session -t "$2"
    elif [[ "${ans,,}" == "n" ]]; then
        echo -e "${W}${PREFIX}${R} Did not kill $2..."
    else 
        echo -e "${W}${PREFIX}${R} Something went wrong. Did not kill $2."
    fi

elif [[ $1 == "list" ]]; then
    echo -e "${W}$PREFIX${R} Here's all the containers."
    sudo -u "$pigeon_USER" tmux -S /tmp/tmux_$2 list-sessions

elif [[ $1 == "console" ]]; then
    echo -e "${W}$PREFIX${R} opening console of $2"
    echo -e "${W}$PREFIX${R} "
    echo -e "${E}$PREFIX${R} ${E}!! IMPORTWNT !!"
    echo -e "${W}$PREFIX${R} do not use ${H}ctrl + c${R}."
    echo -e "${W}$PREFIX${R} to exit a container always use ${H}ctrl + b${R} then ${H}d${R}."
    echo -e "${W}$PREFIX${R} to copy to clipboard always use ${H}ctrl + shift + c${R}."
    echo -e "${W}$PREFIX${R} "
    read -r -p "$(echo -e ${W}$PREFIX${R}" "${G}"press enter to continue")"

    sudo -u "$pigeon_USER" tmux -S /tmp/tmux_$2 attach -t "$2"

else
    echo -e "${W}$PREFIX${R} Unknown command. See ${S}$0 help${R} for more"
fi