#!/bin/bash
CYAN='\033[0;36m' 
NC='\033[0m'

##
# $city poz. 1
# $country poz. 2
##

if [ $# -eq 2 ]
    then
        city=$1
        country=$2
        echo -e "Witaj w skrypcie pogodwym zaraz wyświetlę Ci pogodę w ${CYAN}${city^^}${NC} w państwie ${CYAN}${country^^}${NC}\n" 
        country=$(echo $2 | sed -e 's/ /%20/g')
        city=$(echo $1 | sed -e 's/ /%20/g')
        curl --url "wttr.in/$city,$country?0?F&lang=pl" -w "\n"
    elif [ $# -eq 1 ]
        then
        echo "Err: Podano tylko jeden argument. Wymagany brak argumentów lub dwa"
        exit 1
    else
        echo -e "Witaj w skrypcie pogodwym zaraz wyświetlę Ci pogodę." 
        curl --url "wttr.in/?0?F&lang=pl" -w "\n"
        exit 0
    fi

exit 0