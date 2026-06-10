#!/bin/bash
# =========================================================
#          VPS-SAMA - GESTOR SSL / TLS (STUNNEL4)
# =========================================================

SCPdir="/etc/VPS-SAMA"
clear
echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
echo -e "          \e[1;36m⚙️ GESTOR SSL / TLS (STUNNEL4) ⚙️\e[0m"
echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"

# Verificar si Stunnel está activo
PID=$(ps ax | grep stunnel4 | grep -v grep | awk '{print $1}')

if [ ! -z "$PID" ]; then
    echo -e " Status actual: \e[1;32m● ONLINE (Activo)\e[0m"
    echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
    echo -e "  \e[1;31m[1]\e[1;37m > Detener Servicio SSL/Stunnel"
    echo -e "  \e[1;32m[2]\e[1;37m > Reinstalar / Cambiar Puertos SSL"
    echo -e "  \e[1;32m[0]\e[1;37m > Volver al Menú"
    echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
    read -p " Seleccione una opción: " op_ssl
    
    if [ "$op_ssl" = "1" ]; then
        systemctl stop stunnel4 >/dev/null 2>&1
        echo -e "\e[1;31m[-] Servicio SSL detenido.\e[0m"
        sleep 2
        return 0
    elif [ "$op_ssl" = "2" ]; then
        systemctl stop stunnel4 >/dev/null 2>&1
    else
        return 0
    fi
fi

# Configuración o Reconfiguración
echo -e " \e[1;37m[+] Iniciando configuración de Stunnel4...\e[0m"
apt-get install stunnel4 -y >/dev/null 2>&1

read -p " Ingrese el puerto de escucha SSL (Ej: 443, 442): " port_ssl
read -p " Puerto interno a redirigir (Ej: SSH=22, Dropbear=80 o 442): " port_int

echo -e " \e[1;32m[+] Generando Certificado SSL Autofirmado Cert...\e[0m"
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /etc/stunnel/stunnel.pem -out /etc/stunnel/stunnel.pem -subj "/C=AR/ST=BA/L=LaPlata/O=SAMA/CN=vps-sama.com" >/dev/null 2>&1

cat <<EOF > /etc/stunnel/stunnel.conf
pid = /var/run/stunnel4.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[vps_sama_ssl]
accept = 0.0.0.0:$port_ssl
connect = 127.0.0.1:$port_int
EOF

sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
systemctl restart stunnel4 >/dev/null 2>&1

echo -e "\e[1;32m[+] SSL/Stunnel activo con éxito en el puerto $port_ssl -> Redirigido a puerto $port_int\e[0m"
sleep 2
