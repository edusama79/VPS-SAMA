#!/bin/bash
# =========================================================
#          VPS-SAMA - INSTALADOR Y GESTOR SLOWDNS
# =========================================================

SCPdir="/etc/VPS-SAMA"
clear
echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
echo -e "          \e[1;36m⚙️ INSTALADOR Y GESTOR SLOWDNS ⚙️\e[0m"
echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"

if [ -f "/etc/VPS-SAMA/protocolos/dns-server" ]; then
    echo -e " Status actual: \e[1;32m● INSTALADO\e[0m"
    echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
    echo -e "  \e[1;31m[1]\e[1;37m > Desinstalar / Detener SlowDNS"
    echo -e "  \e[1;32m[2]\e[1;37m > Ver Llaves (Keys) Activas"
    echo -e "  \e[1;32m[0]\e[1;37m > Volver al Menú"
    echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
    read -p " Seleccione una opción: " op_dns
    
    if [ "$op_dns" = "1" ]; then
        pkill -f dns-server >/dev/null 2>&1
        rm -rf /etc/VPS-SAMA/protocolos/dns-server
        echo -e "\e[1;31m[-] SlowDNS removido.\e[0m"
        sleep 2
        return 0
    elif [ "$op_dns" = "2" ]; then
        clear
        echo -e "\e[1;36m=== LLAVES DE TU SLOWDNS ===\e[0m"
        cat /etc/VPS-SAMA/protocolos/server.pub 2>/dev/null || echo "No encontradas."
        read -p "Presione Enter para continuar..."
        return 0
    else
        return 0
    fi
fi

echo -e " \e[1;37m[+] Descargando binario estable de dns-server...\e[0m"
# Descargamos el binario de tu repositorio de librerías viejo para que mantengas la misma arquitectura operativa
curl -sSL -o /etc/VPS-SAMA/protocolos/dns-server "https://raw.githubusercontent.com/edusama79/VPS-MX_Oficial/master/LINKS-LIBRERIAS/dns-server"
chmod +x /etc/VPS-SAMA/protocolos/dns-server

read -p " Ingrese su dominio NS (Nameserver, ej: ns.vps-sama.site): " ns_domain
[[ -z "$ns_domain" ]] && echo "Dominio inválido" && return 0

echo -e " \e[1;32m[+] Generando par de llaves criptográficas (públicas/privadas)...\e[0m"
cd /etc/VPS-SAMA/protocolos/
./dns-server -gen-key >/dev/null 2>&1

# Levantar de fondo vinculando el puerto local 22 (SSH) o el de Dropbear
screen -dmS sama_dns ./dns-server -udp :53 -privkey server.key $ns_domain 127.0.0.1:22
echo "@reboot root cd /etc/VPS-SAMA/protocolos/ && screen -dmS sama_dns ./dns-server -udp :53 -privkey server.key $ns_domain 127.0.0.1:22" >> /etc/crontab

echo -e "\e[1;32m[+] SlowDNS levantado con éxito en el puerto UDP 53.\e[0m"
echo -e "\e[1;33m[!] Tu Clave Pública (Public Key) para poner en la App es:\e[1;37m"
cat /etc/VPS-SAMA/protocolos/server.pub
echo -e "\e[1;33m————————————————————————————————————————————————————\e[0m"
read -p " Copie la llave y presione Enter..."
