#!/bin/bash
# =========================================================
#          INSTALADOR MASTER INTERACTIVO - VPS-SAMA
# =========================================================

# Desactivar IPv6 para evitar demoras en la inyección SSH
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1

clear
echo "————————————————————————————————————————————————————"
echo "        🐲 INSTALADOR MASTER VPS-SAMA PREMIUM 🐲"
echo "————————————————————————————————————————————————————"
echo "[+] Actualizando librerías del núcleo Linux..."

# Instalar dependencias esenciales del sistema operativo
apt-get update -y >/dev/null 2>&1
apt-get install python3 screen lsof stunnel4 htop curl unzip -y >/dev/null 2>&1

# Crear estructura limpia de directorios
mkdir -p /etc/VPS-SAMA
mkdir -p /etc/VPS-SAMA/controlador
mkdir -p /etc/VPS-SAMA/herramientas
mkdir -p /etc/VPS-SAMA/protocolos
touch /etc/VPS-SAMA/usuarios.db

# =========================================================
#  1. INSTALACIÓN REAL DEL MOTOR V2RAY / XRAY CORE
# =========================================================
echo "[+] Instalando Protocolos Pesados (Xray Core / V2Ray)..."
bash <(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh) --exec --version latest >/dev/null 2>&1

# Generar una configuración base para Xray escuchando túnles de entrada
mkdir -p /usr/local/etc/xray
cat <<EOF > /usr/local/etc/xray/config.json
{
    "inbounds": [{
        "port": 4433,
        "protocol": "vless",
        "settings": {
            "clients": [],
            "decryption": "none"
        },
        "streamSettings": {
            "network": "ws",
            "wsSettings": {
                "path": "/vps-sama"
            }
        }
    }],
    "outbounds": [{
        "protocol": "freedom"
    }]
}
EOF
systemctl restart xray >/dev/null 2>&1

# =========================================================
#  2. CREACIÓN DEL SENSOR / API EN EL PUERTO 81 PARA TU APP
# =========================================================
echo "[+] Levantando API de Monitoreo de Usuarios en Puerto 81..."

cat << 'EOF' > /etc/VPS-SAMA/controlador/api_puerto81.py
import http.server
import socketserver
import os

PORT = 81
DB_PATH = "/etc/VPS-SAMA/usuarios.db"

class SamaAPIHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Responder con código 200 (Éxito)
        self.send_response(200)
        self.send_header("Content-type", "text/plain; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*") # Permite conectar Android Studio sin bloqueos
        self.end_headers()
        
        # Leer la base de datos interna y enviarla limpia a tu app
        if os.path.exists(DB_PATH):
            with open(DB_PATH, "r") as f:
                data = f.read()
            self.wfile.write(data.encode("utf-8"))
        else:
            self.wfile.write(b"BASE_DE_DATOS_VACIA")

# Apagar cualquier API corriendo previamente en el puerto 81
os.system("fuser -k 81/tcp >/dev/null 2>&1")

with socketserver.TCPServer(("0.0.0.0", PORT), SamaAPIHandler) as httpd:
    httpd.serve_forever()
EOF

# Levantar la API en segundo plano usando screen para persistencia
screen -dmS sama_api81 python3 /etc/VPS-SAMA/controlador/api_puerto81.py

# =========================================================
#  3. DESCARGA DEL ÁRBOL DE CARPETAS DESDE TU GITHUB
# =========================================================
echo "[+] Sincronizando módulos desde tu repositorio GitHub..."
URL_BASE="https://raw.githubusercontent.com/edusama79/VPS-SAMA/main"

curl -sSL -o /etc/VPS-SAMA/menu "${URL_BASE}/menu"
chmod +x /etc/VPS-SAMA/menu

curl -sSL -o /etc/VPS-SAMA/controlador/monitor.sh "${URL_BASE}/controlador/monitor.sh"
chmod +x /etc/VPS-SAMA/controlador/monitor.sh

curl -sSL -o /etc/VPS-SAMA/herramientas/ports.sh "${URL_BASE}/herramientas/ports.sh"
curl -sSL -o /etc/VPS-SAMA/herramientas/tcp.sh "${URL_BASE}/herramientas/tcp.sh"
chmod +x /etc/VPS-SAMA/herramientas/ports.sh
chmod +x /etc/VPS-SAMA/herramientas/tcp.sh

curl -sSL -o /etc/VPS-SAMA/protocolos/PDirect.py "${URL_BASE}/protocolos/PDirect.py"
curl -sSL -o /etc/VPS-SAMA/protocolos/sockspy.sh "${URL_BASE}/protocolos/sockspy.sh"
curl -sSL -o /etc/VPS-SAMA/protocolos/ssl.sh "${URL_BASE}/protocolos/ssl.sh"
curl -sSL -o /etc/VPS-SAMA/protocolos/slowdns.sh "${URL_BASE}/protocolos/slowdns.sh"
chmod +x /etc/VPS-SAMA/protocolos/sockspy.sh
chmod +x /etc/VPS-SAMA/protocolos/ssl.sh
chmod +x /etc/VPS-SAMA/protocolos/slowdns.sh

# =========================================================
#  4. PERSISTENCIA ANTE REINICIOS (CRONTAB)
# =========================================================
echo "[+] Configurando arranques automáticos de fondo..."

# Encender monitor de multilogin
kill -9 $(screen -ls | grep "monitor_sama" | awk '{print $1}' | cut -d'.' -f1) >/dev/null 2>&1
screen -dmS monitor_sama bash /etc/VPS-SAMA/controlador/monitor.sh

# Crear accesos directos globales en Linux
rm -rf /bin/menu /bin/sama
echo "bash /etc/VPS-SAMA/menu" > /bin/menu
echo "bash /etc/VPS-SAMA/menu" > /bin/sama
chmod +x /bin/menu /bin/sama

# Registrar en el Crontab para que si el VPS se reinicia, la API y el Monitor arranquen solos
sed -i '/sama_api81/d' /etc/crontab
sed -i '/monitor_sama/d' /etc/crontab
echo "@reboot root screen -dmS sama_api81 python3 /etc/VPS-SAMA/controlador/api_puerto81.py" >> /etc/crontab
echo "@reboot root screen -dmS monitor_sama bash /etc/VPS-SAMA/controlador/monitor.sh" >> /etc/crontab

clear
echo "————————————————————————————————————————————————————"
echo "        ¡SISTEMA COMPLETAMENTE INSTALADO!"
echo "————————————————————————————————————————————————————"
echo " [+] Puerto 81 WEB API activo para tu app Android."
echo " [+] V2Ray/Xray Core instalado con éxito."
echo " [+] Acceso al panel interactivo escribiendo: menu"
echo "————————————————————————————————————————————————————"
sleep 2
bash /etc/VPS-SAMA/menu
