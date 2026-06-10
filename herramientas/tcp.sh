#!/bin/bash
# =========================================================
#          VPS-SAMA - ACELERADOR DE RED TCP BBR
# =========================================================

clear
echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
echo -e "          \e[1;36m⚙️ OPTIMIZACIÓN DE RED & TCP BBR ⚙️\e[0m"
echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
echo -e "  \e[1;32m[1]\e[1;37m > Activar Aceleración Google BBR (Recomendado)"
echo -e "  \e[1;32m[2]\e[1;37m > Optimizar Buffers de Sistema (Limpieza de Red)"
echo -e "  \e[1;32m[0]\e[1;37m > Volver Atrás"
echo -e "\e[1;33m ————————————————————————————————————————————————————\e[0m"
read -p " Seleccione una opción: " op_tcp

case $op_tcp in
1)
    clear
    echo -e " \e[1;32m[+] Activando Google BBR...\e[0m"
    # Inyectar parámetros en el núcleo del sistema de Linux
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p >/dev/null 2>&1
    echo -e "\e[1;32m[+] ¡Algoritmo BBR activado con éxito! Core optimizado.\e[0m"
    sleep 2
    ;;
2)
    clear
    echo -e " \e[1;32m[+] Optimizando límites de conexiones de red...\e[0m"
    cat <<EOF >> /etc/sysctl.conf
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_max_syn_backlog = 4096
EOF
    sysctl -p >/dev/null 2>&1
    echo -e "\e[1;32m[+] Buffers limpios y optimizados.\e[0m"
    sleep 2
    ;;
*) return 0 ;;
esac
