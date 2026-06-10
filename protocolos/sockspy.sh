#!/bin/bash
# =========================================================
#          VPS-SAMA - GESTOR SOCKS PYTHON / WEBSOCKET
# =========================================================

SCPdir="/etc/VPS-SAMA"
PID_FILE="/var/run/vps_sama_socks.pid"

clear
echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
echo -e "          \e[1;36m⚙️ CONTROL SOCKS PYTHON / WEBSOCKET ⚙️\e[0m"
echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"

# Verificar si el proxy ya está corriendo de fondo
PID=$(ps ax | grep "PDirect.py" | grep -v grep | awk '{print $1}')

if [ ! -z "$PID" ]; then
    echo -e " Status actual: \e[1;32m● ONLINE (Activo)\e[0m"
    echo -e " PIDs de ejecusion: $PID"
    echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
    echo -e "  \e[1;31m[1]\e[1;37m > Detener e Interrumpir Servidores SOCKS"
    echo -e "  \e[1;32m[0]\e[1;37m > Volver al Menú"
    echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
    read -p " Seleccione una opción: " op_sk
    if [ "$op_sk" = "1" ]; then
        kill -9 $PID >/dev/null 2>&1
        echo -e "\e[1;31m[-] Servidores WebSocket detenidos.\e[0m"
        sleep 2
    fi
else
    echo -e " Status actual: \e[1;31m○ OFFLINE (Apagado)\e[0m"
    echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
    echo -e "  \e[1;32m[1]\e[1;37m > Iniciar Proxy WebSocket (Puerto 80)"
    echo -e "  \e[1;32m[2]\e[1;37m > Iniciar Proxy WebSocket (Puerto 8080)"
    echo -e "  \e[1;32m[3]\e[1;37m > Personalizar otro Puerto"
    echo -e "  \e[1;32m[0]\e[1;37m > Volver al Menú"
    echo -e "\e[1;33m —───────────────────────────────────────────────────\e[0m"
    read -p " Seleccione una opción: " op_sk
    
    case $op_sk in
    1)
        screen -dmS sama_socks80 python3 /etc/VPS-SAMA/protocolos/PDirect.py 80
        echo -e "\e[1;32m[+] Iniciado con éxito en el puerto 80.\e[0m"
        sleep 2
        ;;
    2)
        screen -dmS sama_socks8080 python3 /etc/VPS-SAMA/protocolos/PDirect.py 8080
        echo -e "\e[1;32m[+] Iniciado con éxito en el puerto 8080.\e[0m"
        sleep 2
        ;;
    3)
        read -p " Ingrese el puerto de su preferencia: " p_cust
        screen -dmS sama_socks_$p_cust python3 /etc/VPS-SAMA/protocolos/PDirect.py $p_cust
        echo -e "\e[1;32m[+] Iniciado con éxito en el puerto $p_cust.\e[0m"
        sleep 2
        ;;
    *) return 0 ;;
    esac
fi
