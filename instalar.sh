#!/bin/bash
# =========================================================
#          INSTALADOR MAESTRO DE TU PANEL: VPS-SAMA
# =========================================================

# Forzar la desactivación de IPv6 para mejorar velocidad de inyección
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1

clear
echo "————————————————————————————————————————————————————"
echo "        🐲 INSTALADOR OFICIAL VPS-SAMA PREMIUM 🐲"
echo "————————————————————————————————————————————————————"
echo "[+] Preparando el entorno del sistema operativo..."

# Actualizar repositorios e instalar dependencias pesadas que usan tus módulos
apt-get update -y >/dev/null 2>&1
apt-get install python3 screen lsof stunnel4 htop curl unzip -y >/dev/null 2>&1

# Crear el árbol de directorios definitivo en el VPS
mkdir -p /etc/VPS-SAMA
mkdir -p /etc/VPS-SAMA/controlador
mkdir -p /etc/VPS-SAMA/herramientas
mkdir -p /etc/VPS-SAMA/protocolos

echo "[+] Descargando módulos y componentes desde tu GitHub..."

# URL base de tu repositorio (cambiala si usás otro nombre de repositorio público)
URL_BASE="https://raw.githubusercontent.com/edusama79/VPS-SAMA/main"

# 1. Descargar Menú Principal
curl -sSL -o /etc/VPS-SAMA/menu "${URL_BASE}/menu"
chmod +x /etc/VPS-SAMA/menu

# 2. Descargar Controladores de fondo
curl -sSL -o /etc/VPS-SAMA/controlador/monitor.sh "${URL_BASE}/controlador/monitor.sh"
chmod +x /etc/VPS-SAMA/controlador/monitor.sh

# 3. Descargar Herramientas de Red
curl -sSL -o /etc/VPS-SAMA/herramientas/ports.sh "${URL_BASE}/herramientas/ports.sh"
curl -sSL -o /etc/VPS-SAMA/herramientas/tcp.sh "${URL_BASE}/herramientas/tcp.sh"
chmod +x /etc/VPS-SAMA/herramientas/ports.sh
chmod +x /etc/VPS-SAMA/herramientas/tcp.sh

# 4. Descargar Protocolos de Conexión
curl -sSL -o /etc/VPS-SAMA/protocolos/PDirect.py "${URL_BASE}/protocolos/PDirect.py"
curl -sSL -o /etc/VPS-SAMA/protocolos/sockspy.sh "${URL_BASE}/protocolos/sockspy.sh"
curl -sSL -o /etc/VPS-SAMA/protocolos/ssl.sh "${URL_BASE}/protocolos/ssl.sh"
curl -sSL -o /etc/VPS-SAMA/protocolos/slowdns.sh "${URL_BASE}/protocolos/slowdns.sh"
chmod +x /etc/VPS-SAMA/protocolos/sockspy.sh
chmod +x /etc/VPS-SAMA/protocolos/ssl.sh
chmod +x /etc/VPS-SAMA/protocolos/slowdns.sh

# =========================================================
#  ENCENDIDO DE SERVICIOS AUTOMÁTICOS Y ENLACES (CRONTAB)
# =========================================================
echo "[+] Activando motores en segundo plano..."

# Matar cualquier monitor viejo y encender el nuevo monitor de multilogin
kill -9 $(screen -ls | grep "monitor_sama" | awk '{print $1}' | cut -d'.' -f1) >/dev/null 2>&1
screen -dmS monitor_sama bash /etc/VPS-SAMA/controlador/monitor.sh

# Crear el acceso directo para que entres escribiendo solo la palabra 'menu' en tu terminal
rm -rf /bin/menu /bin/sama
echo "bash /etc/VPS-SAMA/menu" > /bin/menu
echo "bash /etc/VPS-SAMA/menu" > /bin/sama
chmod +x /bin/menu /bin/sama

# Asegurar persistencia ante reinicios del servidor en el Crontab
sed -i '/monitor_sama/d' /etc/crontab
echo "@reboot root screen -dmS monitor_sama bash /etc/VPS-SAMA/controlador/monitor.sh" >> /etc/crontab

# Configurar el mensaje/Slogan por defecto del panel
echo "VPS-SAMA PREMIUM" > /etc/VPS-SAMA/message.txt

clear
echo "————————————————————————————————————————————————————"
echo "   ¡INSTALACIÓN INICIAL DE VPS-SAMA COMPLETADA!"
echo "————————————————————————————————————————————————————"
echo " [+] Tu script ya está listo para ser administrado."
echo " [+] Podés acceder en cualquier momento escribiendo: menu"
echo "————————————————————————————————————————————————————"
sleep 2
bash /etc/VPS-SAMA/menu
