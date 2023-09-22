#!/bin/bash

# Pobierz listę adapterów sieciowych z przypisanymi adresami IP
network_adapters=$(ip addr show | awk '/^[0-9]+:/ {print $2}' | sed 's/://' | while read -r adapter; do
    ip_address=$(ip addr show "$adapter" | awk '/inet / {print $2}')
    if [ -n "$ip_address" ]; then
        echo "$adapter"
    fi
done)

# Znajdź najdłuższą nazwę adaptera
max_adapter_length=0
while IFS= read -r adapter; do
    adapter_length=${#adapter}
    if [ "$adapter_length" -gt "$max_adapter_length" ]; then
        max_adapter_length="$adapter_length"
    fi
done <<< "$network_adapters"

# Wyświetl nagłówki tabeli
echo "-------------------------------------------------------------"
echo "|      Adapter      |      Adres IP      |     Maska podsieci    |"
echo "-------------------------------------------------------------"

# Iteruj przez każdy adapter z przypisanym adresem IP
while IFS= read -r adapter; do
    ip_address=$(ip addr show "$adapter" | awk '/inet / {print $2}')
    subnet_mask_cidr=$(ip addr show "$adapter" | awk '/inet / {print $2}' | cut -d/ -f2)

    # Oblicz maskę podsieci w formie dziesiętnej
    subnet_mask_decimal=""
    for (( i=1; i<=4; i++ )); do
        if [ "$subnet_mask_cidr" -ge 8 ]; then
            subnet_mask_decimal+="255"
            subnet_mask_cidr=$((subnet_mask_cidr-8))
        else
            subnet_mask_decimal+=$((256 - 2**(8-subnet_mask_cidr)))
            subnet_mask_cidr=0
        fi
        if [ "$i" -lt 4 ]; then
            subnet_mask_decimal+="."
        fi
    done

    # Wyświetl dane adaptera w tabeli z uwzględnieniem wyrównania
    adapter_padding="$(printf '%*s' "$((max_adapter_length - ${#adapter}))" '')"
    printf "| %s%s | %-18s | %-21s |\n" "$adapter" "$adapter_padding" "$ip_address" "$subnet_mask_decimal"
    echo "-------------------------------------------------------------"
done <<< "$network_adapters"
