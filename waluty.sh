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
    local verify=$(curl --silent --head --url "http://api.nbp.pl/api/exchangerates/rates/a/$1/" | awk '/^HTTP/{print $2}')
    if [ "$verify" == "404" ] 
    then
       echo "Zwrotka: $verify"
       exit 1
    else
    answer=$(curl -s --url "http://api.nbp.pl/api/exchangerates/rates/a/$1/" | jq '.rates | .[] | .mid')
    fi
}

[ $# -eq 0 ] && {
    echo -e "\n$0 <ilość> <skrót_waluty> <-- wyświetli przelicznik na złotówki (np. $0 10 USD, wyświetli 10 USD to x PLN)\n\n$0 <ilość> <z_jakiej_waluty> <na_jaką_walutę> <-- wyświetli przelicznik na inne waluty (np. $0 10 USD EUR, wyświetli 10 USD to x EUR)";
    exit 1;
}

[ $# -eq 1 ] && {
    waluta=$1
    query $waluta
    echo -e "${GREEN}1 ${CYAN}$waluta${NC} to w przeliczeniu ${GREEN}$answer${CYAN} PLN${NC}"
    exit 0
}

[ $# -eq 2 ] && {
    waluta=$2
    ilosc=$1
    query $waluta
    answer=$(awk "BEGIN { printf(\"%.2f\", $ilosc * $answer) }")
    echo -e "${GREEN}$ilosc ${CYAN}$waluta${NC} to w przeliczeniu ${GREEN}$answer${CYAN} PLN${NC}"
    exit 0
}

[ $# -eq 3 ] && {
    ilosc=$1
    waluta_z=$2 # pobranie waluty z której będziemy przeliczać
    waluta_na=$3 # pobranie waluty na którą będziemy przeliczać
    tablica=("" "") # przechowujemy tutaj wartości skonwertowane na złotówki z dwóch zapytań, API NBP nie pozwala konwertować bezpośrednio walut obcych.
    query $waluta_z # zapytanie o walute
    tablica[0]=$answer # zapisanie odpowiedzi do tablicy
    query $waluta_na # zapytanie o drugą walute
    tablica[1]=$answer # zapisanie odpowiedzi do tablicy
    answer=$(awk "BEGIN { printf(\"%.2f\", (${tablica[0]} / ${tablica[1]}) * $ilosc) }")
    echo -e "${GREEN}$ilosc ${CYAN}$waluta_z${NC} to w przeliczeniu ${GREEN}$answer${CYAN} $waluta_na${NC}"
    exit 0
}