#!/bin/bash
# =========================================================
#             INSTALADOR ÚNICO OFICIAL: VPS-SAMA
# =========================================================

clear && clear
export DEBIAN_FRONTEND=noninteractive

# Colores del Panel
BRAN='\033[1;37m' && VERMELHO='\e[31m' && VERDE='\e[32m' && AMARELO='\e[33m'
AZUL='\e[34m' && MAGENTA='\e[35m' && MAG='\033[1;36m' && NEGRITO='\e[1m' && SEMCOR='\e[0m'

msg() {
  case $1 in
    -bar) echo -e "${VERMELHO}————————————————————————————————————————————————————${SEMCOR}" ;;
    -azu) echo -e "${MAG}${NEGRITO}${2}${SEMCOR}" ;;
    -verd) echo -e "${VERDE}${NEGRITO}${2}${SEMCOR}" ;;
    -ama) echo -e "${AMARELO}${NEGRITO}${2}${SEMCOR}" ;;
  esac
}

msg -bar
echo -e "          \e[1;36m⚙️ INSTALADOR PREMIUM: VPS-SAMA ⚙️\e[0m"
msg -bar
echo -ne "\033[1;97m Digite su slogan o marca personal: \033[1;32m" && read slogan
[[ -z "$slogan" ]] && slogan="VPS-SAMA Premium"

# Crear directorios del sistema
mkdir -p /etc/VPS-SAMA
mkdir -p /etc/VPS-SAMA/controlador
mkdir -p /etc/VPS-SAMA/herramientas
mkdir -p /etc/VPS-SAMA/protocolos
echo "$slogan" > /etc/VPS-SAMA/message.txt

msg -bar
echo -e "\e[1;37m[+] Instalando dependencias del sistema y Python...\e[0m"
apt-get update -y && apt-get upgrade -y
apt-get install python3 python3-pip screen unzip lsof tar curl iptables openssl dropbear squid stunnel4 net-tools htop -y

msg -bar
echo -e "\e[1;32m[+] Descargando componentes personalizados de VPS-SAMA...\e[0m"

# DESCARGA DIRECTA DE TU MENÚ DESDE TU NUEVO GITHUB
curl -sSL -o /etc/VPS-SAMA/menu "https://raw.githubusercontent.com/edusama79/VPS-SAMA/main/menu"
chmod +x /etc/VPS-SAMA/menu

# Crear accesos directos rápidos en la terminal del VPS
echo "/etc/VPS-SAMA/menu" > /usr/bin/menu && chmod +x /usr/bin/menu
echo "/etc/VPS-SAMA/menu" > /usr/bin/vps-sama && chmod +x /usr/bin/vps-sama

# =========================================================
# CONFIGURACIÓN DE LA API PARA TU APP (PUERTO 81)
# =========================================================
msg -bar
echo -e "\e[1;32m[+] Levantando API en puerto 81 para Android Studio...\e[0m"

cat << 'EOF' > /etc/VPS-SAMA/api_vps.py
import http.server, socketserver, os
PORT = 81
class LatamHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/usuarios':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            ruta = "/etc/VPS-SAMA/usuarios.db"
            datos_para_app = ""
            if os.path.exists(ruta):
                with open(ruta, "r") as f:
                    datos_para_app = f.read()
            if datos_para_app.strip():
                self.wfile.write(bytes(datos_para_app, "utf-8"))
            else:
                self.wfile.write(bytes("vacio|sin_cuentas\n", "utf-8"))
        else:
            self.send_response(404)
            self.end_headers()
with socketserver.TCPServer(("", PORT), LatamHandler) as httpd:
    httpd.serve_forever()
EOF

# Reiniciar puerto 81 de fondo
kill -9 $(lsof -t -i:81) 2>/dev/null
screen -dmS api_vps_sama python3 /etc/VPS-SAMA/api_vps.py
echo "@reboot root screen -dmS api_vps_sama python3 /etc/VPS-SAMA/api_vps.py" >> /etc/crontab

# Pantalla estética al ingresar por SSH
echo 'clear' > /root/.bashrc
echo 'echo -e "\t\033[1;36m  __   __ ___  ___   ___   _   __  __   _   "' >> /root/.bashrc
echo 'echo -e "\t\033[1;36m  \ \ / /| _ \/ __| / __| /_\ |  \/  | /_\  "' >> /root/.bashrc
echo 'echo -e "\t\033[1;32m   \ V / |  _/\__ \ \__ \/ _ \| |\/| |/ _ \ "' >> /root/.bashrc
echo 'echo -e "\t\033[1;32m    \_/  |_|  |___/ |___/_/ \_\|_|  |_/_/ \_\ "' >> /root/.bashrc
echo 'echo ""' >> /root/.bashrc
echo 'echo -e "\t\e[1;33m MARCA / RESELLER :\e[1;37m $(cat /etc/VPS-SAMA/message.txt 2>/dev/null)"' >> /root/.bashrc
echo 'echo -e "\t\e[1;32m PANEL DE CONTROL : \e[1;41m menu \e[0m \e[1;32m o \e[1;41m vps-sama \e[0m"' >> /root/.bashrc
echo 'echo -e "\t\e[1;35m API ANDROID APP  : \e[1;32m Activa en Puerto 81 \e[0m"' >> /root/.bashrc
echo ""

msg -bar
echo -e "\e[1;92m   >> ¡SISTEMA VPS-SAMA INSTALADO Y VINCULADO CON ÉXITO! <<"
msg -bar
