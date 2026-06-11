#!/bin/bash
clear
clear

echo -e "\033[1;32m═══════════════════════════════════════════════════════════════"
echo -e "              \033[1;31m🐲 INSTALADOR VPS-SAMA v2.0 🐲\033[0m"
echo -e "\033[1;32m═══════════════════════════════════════════════════════════════\033[0m"
echo ""

[[ "$(whoami)" != "root" ]] && {
    echo -e "\033[1;31m[!] ERROR: Debes ejecutar este script como ROOT\033[0m"
    echo -e "\033[1;33m\nPaso 1: Ejecuta: sudo -i"
    echo -e "Paso 2: Repite el comando de instalación\033[0m"
    exit 1
}

SCPdir="/etc/VPS-SAMA"
echo -e "\033[1;32m[+] Verificando permisos de ROOT...\033[0m"
sleep 1

echo -e "\033[1;32m[+] Creando estructura de directorios...\033[0m"
mkdir -p ${SCPdir}/{controlador,herramientas,protocolos}
mkdir -p /usr/local/bin

echo -e "\033[1;32m[+] Instalando dependencias necesarias...\033[0m"
apt-get update >/dev/null 2>&1
apt-get install -y wget curl jq screen >/dev/null 2>&1

echo -e "\033[1;32m[+] Descargando menú principal...\033[0m"
if wget -q -O ${SCPdir}/menu https://raw.githubusercontent.com/edusama79/VPS-SAMA/main/menu 2>/dev/null; then
    chmod +x ${SCPdir}/menu
    echo -e "\033[1;32m    ✓ Menú descargado correctamente\033[0m"
else
    echo -e "\033[1;31m    ✗ Error descargando menú\033[0m"
    exit 1
fi

echo -e "\033[1;32m[+] Descargando API Android...\033[0m"
if wget -q -O ${SCPdir}/api_android.py https://raw.githubusercontent.com/edusama79/VPS-SAMA/main/api_android.py 2>/dev/null; then
    chmod +x ${SCPdir}/api_android.py
    echo -e "\033[1;32m    ✓ API descargada correctamente\033[0m"
else
    echo -e "\033[1;33m    ⚠ API no disponible (continuando sin ella)\033[0m"
fi

echo -e "\033[1;32m[+] Creando aliases de comandos...\033[0m"
echo "${SCPdir}/menu" > /usr/bin/menu && chmod +x /usr/bin/menu
echo "${SCPdir}/menu" > /usr/bin/sama && chmod +x /usr/bin/sama
echo "${SCPdir}/menu" > /usr/bin/vpssama && chmod +x /usr/bin/vpssama
echo -e "\033[1;32m    ✓ Comandos: menu, sama, vpssama\033[0m"

echo -e "\033[1;32m[+] Inicializando bases de datos...\033[0m"
[[ ! -f ${SCPdir}/usuarios.db ]] && echo "[]" > ${SCPdir}/usuarios.db
[[ ! -f ${SCPdir}/vencimientos.json ]] && echo "{}" > ${SCPdir}/vencimientos.json
echo -e "\033[1;32m    ✓ Base de datos creada\033[0m"

echo -e "\033[1;32m[+] Optimizando sistema...\033[0m"
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1
echo -e "\033[1;32m    ✓ IPv6 deshabilitado\033[0m"

echo -e "\033[1;32m[+] Obteniendo IP del VPS...\033[0m"
MEU_IP=$(curl -sS https://api.ipify.org 2>/dev/null || wget -qO- ipinfo.io/ip 2>/dev/null || echo "0.0.0.0")
echo "$MEU_IP" > ${SCPdir}/MEUIPvps
echo -e "\033[1;32m    ✓ IP: $MEU_IP\033[0m"

echo -e "\033[1;32m[+] Configurando auto-inicio (opcional)...\033[0m"
read -p "¿Deseas que el menú se inicie automáticamente al conectar? [s/n]: " autorun
if [[ "$autorun" == "s" || "$autorun" == "S" ]]; then
    cat /etc/bash.bashrc | grep -v "/etc/VPS-SAMA/menu" > /etc/bash.bashrc.tmp
    echo "/etc/VPS-SAMA/menu" >> /etc/bash.bashrc.tmp
    cp /etc/bash.bashrc /etc/bash.bashrc-backup
    mv /etc/bash.bashrc.tmp /etc/bash.bashrc
    echo -e "\033[1;32m    ✓ Auto-inicio habilitado\033[0m"
else
    echo -e "\033[1;32m    ✓ Auto-inicio deshabilitado\033[0m"
fi

echo ""
echo -e "\033[1;32m═══════════════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;32m[✓✓✓] INSTALACION COMPLETADA CON EXITO [✓✓✓]\033[0m"
echo -e "\033[1;32m═══════════════════════════════════════════════════════════════\033[0m"
echo ""
echo -e "\033[1;33m📌 COMANDOS DISPONIBLES:\033[0m"
echo -e "  \033[1;32m► sudo menu\033[0m"
echo -e "  \033[1;32m► sudo sama\033[0m"
echo -e "  \033[1;32m► sudo vpssama\033[0m"
echo ""
echo -e "\033[1;33m📍 UBICACION DE ARCHIVOS:\033[0m"
echo -e "  \033[1;32m► Menú: /etc/VPS-SAMA/menu\033[0m"
echo -e "  \033[1;32m► API: http://$MEU_IP:81/api/usuarios\033[0m"
echo -e "  \033[1;32m► BD Usuarios: /etc/VPS-SAMA/usuarios.db\033[0m"
echo ""
echo -e "\033[1;33m🚀 PARA INICIAR:\033[0m"
echo -e "  \033[1;37msudo menu\033[0m"
echo ""
