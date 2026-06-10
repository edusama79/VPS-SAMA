#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# =========================================================
#          VPS-SAMA - PROXY PYTHON DIRECTO (WEBSOCKET)
# =========================================================

import socket, threading, sys

if len(sys.argv) < 2:
    print("Uso: python3 PDirect.py <Puerto_Escucha>")
    sys.exit(1)

LISTENING_PORT = int(sys.argv[1])
PASS = b"HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n"

def forward(src, dst):
    try:
        while True:
            data = src.recv(8192)
            if not data: break
            dst.sendall(data)
    except: pass

def client_handler(client_socket):
    try:
        request = client_socket.recv(8192)
        if b"Upgrade: websocket" in request or b"CONNECT" in request:
            client_socket.sendall(PASS)
            
            # Conectar internamente al SSH de Linux (Puerto 22)
            ssh_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            ssh_socket.connect(('127.0.0.1', 22))
            
            threading.Thread(target=forward, args=(client_socket, ssh_socket)).start()
            forward(ssh_socket, client_socket)
    except: pass
    finally: client_socket.close()

def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        server.bind(('0.0.0.0', LISTENING_PORT))
    except Exception as e:
        print(f"Error al abrir puerto {LISTENING_PORT}: {e}")
        sys.exit(1)
        
    server.listen(200)
    print(f"[*] VPS-SAMA Proxy WebSocket activo en puerto {LISTENING_PORT}")
    
    while True:
        try:
            client, addr = server.accept()
            threading.Thread(target=client_handler, args=(client,)).start()
        except KeyboardInterrupt: break
        except: pass

if __name__ == '__main__':
    main()
