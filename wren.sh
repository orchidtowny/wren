#!/bin/bash
# wren launcher

# colors
A='\033[0;35m'
J='\033[1;34m'
G='\033[0;37m'
H='\033[1;32m'
R='\033[0m'
# static
PREFIX="[wren]"
VERSION="0.0.3"
# list admin accounts that will be added to the containers
declare -a admins=("blueb" "kurbiis")
# make each name the name of the directory that is inh /home/servers/
declare -a servers=("coco" "cobalt-web" "cobalt-api")

if [[ $1 == "help" ]]; then
    echo -e "${A}$PREFIX${R} ${J}wren launcher v${VERSION}"
    echo -e "${A}$PREFIX${R} (c) 2023 ihateblueb"
    echo -e "${A}$PREFIX${R} ${J}commands:"
    echo -e "${A}$PREFIX${R}    help    ${G}             ${R}       show this help menu"
    echo -e "${A}$PREFIX${R}    list    ${G}             ${R}       show all running containers"
    echo -e "${A}$PREFIX${R}    spawn   ${G}(server name)${R}       run start script of server in new container"
    echo -e "${A}$PREFIX${R}    start   ${G}(server name)${R}       run start script of server in current container"
    echo -e "${A}$PREFIX${R}    restart ${G}(server name)${R}       run restart script of server"
    echo -e "${A}$PREFIX${R}    stop    ${G}(server name)${R}       run stop script of server"
    echo -e "${A}$PREFIX${R}    kill    ${G}(server name)${R}       kill container of server"
    echo -e "${A}$PREFIX${R}    console ${G}(server name)${R}       open to console of server"
    echo -e "${A}$PREFIX${R} ${J}available servers:"
    for server in ${servers[@]}; do
        echo -e "${A}$PREFIX${R}    $server"
    done
elif [[ $1 == "start" ]]; then
    echo -e "${A}$PREFIX${R} starting $2"
    sudo -u wren screen -S $2 -X stuff 'cd /home/servers/'$2'\r sh start.sh\r'
elif [[ $1 == "spawn" ]]; then
    echo -e "${A}$PREFIX${R} spawning $2"
    sudo -u wren screen -dmS $2 bash -c 'cd /home/servers/'$2'; sh start.sh; exec bash;'
    sudo -u wren screen -S $2 -X multiuser on
    for admin in ${admins[@]}; do
        sudo -u wren screen -S $2 -X acladd $admin
    done
elif [[ $1 == "restart" ]]; then
    echo -e "${A}$PREFIX${R} restarting $2"
    sudo -u wren screen -S $2 -X eval 'stuff "restart\015"'
elif [[ $1 == "stop" ]]; then
    echo -e "${A}$PREFIX${R} stopping $2"
    sudo -u wren screen -S $2 -X eval 'stuff "stop\015"'
elif [[ $1 == "command" ]]; then
    echo -e "${A}$PREFIX${R} running command '${@:3}' on $2"
    sudo -u wren screen -S $2 -X eval 'stuff "'"${*:3}"'\015"'
elif [[ $1 == "kill" ]]; then
    read -r -p "$(echo -e ${A}$PREFIX${R}" you're about to kill a process ("$2"). this could lead to data corruption, would you like to continue? "${H}"[y/N]"${R}) " response
    case "$response" in
    [yY][eE][sS] | [yY])
        echo -e "${A}$PREFIX${R} killed process $2 and removed it's container."
    sudo -u wren screen -S $2 -X kill
        ;;
    *)
        echo -e "${A}$PREFIX${R} cancelling, $2 was not killed."
        ;;
    esac
elif [[ $1 == "console" ]]; then
    echo -e "${A}$PREFIX${R} opening console of $2"
    echo -e "${A}$PREFIX${R} "
    echo -e "${A}$PREFIX${R} ${J}!! IMPORTANT !!"
    echo -e "${A}$PREFIX${R} do not use ${H}ctrl + c${R}."
    echo -e "${A}$PREFIX${R} to exit a container always use ${H}ctrl + a${R} & ${H}d${R}."
    echo -e "${A}$PREFIX${R} to copy to clipboard always use ${H}ctrl + shift + c${R}."
    echo -e "${A}$PREFIX${R} "
    read -r -p "$(echo -e ${A}$PREFIX${R}" "${G}"press enter to continue")"
    sudo -u wren screen -R $2
elif [[ $1 == "list" ]]; then
    echo -e "${A}$PREFIX${R} here's all the containers"
    sudo -u wren screen -ls
else
    echo -e "${A}$PREFIX${R} unknown command. see ${H}$0 help${R} for more"
fi
