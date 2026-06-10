#!/bin/bash
# =========================================================
#          VPS-SAMA - ADMINISTRADOR DE PUERTOS ACTIVER
# =========================================================

clear
echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
echo -e "          \e[1;36m⚙️ PUERTOS EN USO Y ESCUCHA (LISTEN) ⚙️\e[0m"
echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
printf " \e[1;33m%-15s %-15s %-10s\e[0m\n" "SERVICIO" "DIRECCIÓN/PUERTO" "PID"
echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"

# Obtener todos los puertos TCP que están en estado LISTEN actualmente
puertos_raw=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" | grep "LISTEN")

while read -r linea; do
    if [ ! -z "$linea" ]; then
        servicio=$(echo "$linea" | awk '{print $1}')
        pid_proc=$(echo "$linea" | awk '{print $2}')
        puerto_addr=$(echo "$linea" | awk '{print $9}' | awk -F ":" '{print $2}')
        
        if [[ ! -z "$puerto_addr" ]]; then
            printf " %-15s %-15s %-10s\n" "$servicio" "Puerto: $puerto_addr" "$pid_proc"
        fi
    fi
done <<< "$puertos_raw"

echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
echo -e "  \e[1;31m[1]\e[1;37m > Matar / Liberar un Puerto Colgado"
echo -e "  \e[1;32m[0]\e[1;37m > Volver al Menú Principal"
echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
read -p " Seleccione una opción: " op_pt

if [ "$op_pt" = "1" ]; then
    read -p " Ingrese el número de puerto que desea liberar de raíz: " p_kill
    pid_to_kill=$(lsof -t -i:$p_kill)
    if [ ! -z "$pid_to_kill" ]; then
        kill -9 $pid_to_kill >/dev/null 2>&1
        echo -e "\e[1;32m[+] Puerto $p_kill liberado (Procesos terminados).\e[0m"
    else
        echo -e "\e[1;31m[-] No se encontraron procesos activos en el puerto $p_kill.\e[0m"
    fi
    sleep 2
fi
