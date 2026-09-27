import urllib.request
import json
import socket

neighbors = [
    {"ip": "192.168.184.1", "mac": "e4:4e:2d:4b:8d:51", "role": "Core Switch Layer 3 Gateway"},
    {"ip": "192.168.184.10", "mac": "NVR-01 in FortiGate VIP", "role": "Camera NVR 01"},
    {"ip": "192.168.184.11", "mac": "NVR-02 in FortiGate VIP", "role": "Camera NVR 02"},
    {"ip": "192.168.184.34", "mac": "30:56:0f:23:6f:40", "role": "Neighbor Host 34"},
    {"ip": "192.168.184.36", "mac": "bc:0f:f3:c0-f9:e3", "role": "Neighbor Host 36"},
    {"ip": "192.168.184.40", "mac": "30:d0:42:10:88:2f", "role": "Neighbor Host 40"},
    {"ip": "192.168.184.42", "mac": "2c:58:b9:0c:72:c9", "role": "Neighbor Host 42"},
    {"ip": "192.168.184.45", "mac": "e8:cf:83:9e:71:d7", "role": "Neighbor Host 45"}
]

# Common ports to check
ports = [80, 443, 8000, 8080, 3389, 445, 135, 22, 23, 9100]

def check_ports(ip):
    open_ports = []
    for p in ports:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(0.3)
        res = s.connect_ex((ip, p))
        if res == 0:
            open_ports.append(p)
        s.close()
    return open_ports

results = []
for n in neighbors:
    open_p = check_ports(n["ip"])
    hostname = ""
    try:
        hostname = socket.gethostbyaddr(n["ip"])[0]
    except Exception:
        hostname = "N/A"
    n["open_ports"] = open_p
    n["hostname"] = hostname
    results.append(n)
    print(f"IP {n['ip']:15} | Ports: {str(open_p):15} | Host: {hostname} | Role: {n['role']}")

with open("neighbors_audit.json", "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)
