import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open("firewalls_audit.json", "r", encoding="utf-8") as f:
    data = json.load(f)

for name, fw in data.items():
    print("=" * 60)
    print(f"CƠ SỞ: {name}")
    print(f"URL: {fw['url']}")
    status = fw.get("status", {})
    glob = fw.get("global", {})
    print(f"Model: {status.get('model')} ({status.get('model_number')})")
    print(f"Firmware Version: {status.get('version', 'N/A')}")
    print(f"Hostname: {glob.get('hostname')}")
    
    print("\n--- CÁC INTERFACES CHÍNH (WAN/LAN/VLAN/IP) ---")
    for itf in fw.get("interfaces", []):
        ip = itf.get("ip", "0.0.0.0 0.0.0.0")
        type_ = itf.get("type", "")
        role = itf.get("role", "")
        alias = itf.get("alias", "")
        name_itf = itf.get("name", "")
        if ip != "0.0.0.0 0.0.0.0" or alias or role in ["wan", "lan"]:
            print(f"  - {name_itf:15} | Type: {type_:10} | Role: {role:5} | IP: {ip:18} | Alias/Note: {alias}")

    print("\n--- IPSEC VPN TUNNELS ---")
    for tun in fw.get("ipsec", []):
        tun_name = tun.get("name", "")
        comments = tun.get("comments", "")
        proxyid = tun.get("proxyid", [])
        remote_gw = tun.get("rgwy", "")
        status_tun = "UP" if tun.get("incoming_bytes", 0) > 0 or tun.get("outgoing_bytes", 0) > 0 else "DOWN/IDLE"
        print(f"  - Tunnel: {tun_name:20} | Remote GW: {remote_gw:15} | Status: {status_tun}")

    print("\n--- CHÍNH SÁCH BẢO MẬT (FIREWALL POLICIES) - TỔNG QUAN ---")
    policies = fw.get("policies", [])
    print(f"  Tổng số Rules: {len(policies)}")
    for pol in policies[:5]:  # Xem 5 rules đầu tiên
        pid = pol.get("policyid")
        pname = pol.get("name", "No Name")
        srcintf = [x.get("name") for x in pol.get("srcintf", [])]
        dstintf = [x.get("name") for x in pol.get("dstintf", [])]
        action = pol.get("action", "")
        service = [x.get("name") for x in pol.get("service", [])]
        print(f"  Rule #{pid} [{pname}]: {srcintf} -> {dstintf} | Action: {action} | Service: {service[:3]}")
    if len(policies) > 5:
        print(f"  ... và còn {len(policies) - 5} rules khác.")
    print("\n")
