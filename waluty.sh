#!/bin/bash

# Skrypt umożliwiający pobieranie kursów walut
# oraz mozliwość przeliczania kwot
# skrypt zrobiony w bashu
# potrzebny jest JQ (JsonQuery) do obróbki zapytań jsonowych z NBP
# oraz standardowo CURL

#   DEFINICJA KOLORÓW
CYAN='\033[0;36m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

answer=""

query(){ # przeliczenie na polskie złotówki
    
    #if [ $(echo $answer | cut -c1-3 ) -eq 404 ] 
    #then
    #   echo "404 - źle sformuowane zapytanie lub dane jeszcze nie upublicznione."
    #   return 404
    #fi
    # $answer=$(awk '{print $1}' <<< "$answer")
    answer=$(curl -s --url "http://api.nbp.pl/api/exchangerates/rates/a/$1/" | jq '.rates | .[] | .mid')
}

przelicz(){
    # $1 waluta obca pierwsza
    # $2 waluta obca druga
    answer=$($1*$2)
}

przelicz_obce_waluty(){
    # $1 Mocniejsza waluta w stosunku do PLN
    # $2 Słabsza waluta w stosunku do PLN
    answer=$(($1 + $2 / 2))
}

[ $# -eq 0 ] && {
    echo -e "\n$0 <ilość> <skrót_waluty> <-- wyświetli przelicznik na złotówki (np. $0 10 USD, wyświetli 10 USD to x PLN)\n\n$0 <ilość> <z_jakiej_waluty> <na_jaką_walutę> <-- wyświetli przelicznik na inne waluty (np. $0 10 USD EUR, wyświetli 10 USD to x EUR)";
    exit 1;
}

[ $# -eq 2 ] && {
    waluta=$2
    ilosc=$1
    query $waluta
    # echo $answer
    # answer=$((ilosc*answer))
    answer=$(awk "BEGIN { printf(\"%.2f\", $ilosc * $answer) }")
    echo -e "${GREEN}$ilosc ${CYAN}$waluta${NC} to w przeliczeniu ${GREEN}$answer${CYAN} PLN${NC}"
    exit 0
}

