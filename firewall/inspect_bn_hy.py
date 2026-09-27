import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open("full_firewall_details.json", "r", encoding="utf-8") as f:
    db = json.load(f)

for code in ["BN", "HY"]:
    fw = db[code]
    print(f"\n{'='*30} {code} - {fw['info']['name']} {'='*30}")
    status = fw.get("status", {})
    glob = fw.get("global", {})
    dns = fw.get("dns", {})
    routes = fw.get("static_routes", [])
    policies = fw.get("policies", [])
    interfaces = fw.get("interfaces", [])
    dhcp = fw.get("dhcp_servers", [])
    p1 = fw.get("ipsec_phase1", [])
    admins = fw.get("admins", [])
    
    print(f"Model: {status.get('model')} | OS Version: {status.get('version')} (Build {status.get('build')})")
    print(f"Hostname: {glob.get('hostname')}")
    
    print("\n[INTERFACES CHI TIẾT]:")
    for itf in interfaces:
        ip = itf.get("ip", "0.0.0.0 0.0.0.0")
        name = itf.get("name", "")
        role = itf.get("role", "")
        alias = itf.get("alias", "")
        vlanid = itf.get("vlanid", "")
        if ip != "0.0.0.0 0.0.0.0" or alias or role in ["wan", "lan", "dmz"] or vlanid:
            print(f"  * {name:15} | Role: {role:5} | IP: {ip:18} | Alias: {alias} | VLAN: {vlanid}")
            
    print("\n[DHCP SERVERS]:")
    if isinstance(dhcp, list):
        for d in dhcp:
            ditf = d.get("interface", "")
            dstart = d.get("ip-range", [{}])[0].get("start-ip", "") if d.get("ip-range") else ""
            dend = d.get("ip-range", [{}])[0].get("end-ip", "") if d.get("ip-range") else ""
            dgw = d.get("default-gateway", "")
            print(f"  * Interface: {ditf:15} | Range: {dstart} -> {dend} | Gateway: {dgw}")

    print("\n[BẢNG ĐỊNH TUYẾN STATIC ROUTES]:")
    if isinstance(routes, list):
        for r in routes:
            dst = r.get("dst", "0.0.0.0 0.0.0.0")
            gw = r.get("gateway", "")
            device = r.get("device", "")
            comment = r.get("comment", "")
            print(f"  * Đích: {dst:20} | Qua Gateway: {gw:15} | Cổng ra: {device:15} | Note: {comment}")

    print("\n[IPSEC VPN PHASES]:")
    if isinstance(p1, list):
        for tunnel in p1:
            tname = tunnel.get("name", "")
            rgw = tunnel.get("remote-gw", "")
            itf = tunnel.get("interface", "")
            print(f"  * Phase1: {tname:20} | Remote GW: {rgw:15} | Cổng nối: {itf:10}")

    print(f"\n[DANH SÁCH TOÀN BỘ POLICIES ({len(policies)} rules)]:")
    if isinstance(policies, list):
        for pol in policies:
            pid = pol.get("policyid")
            pname = pol.get("name", "")
            srcintf = [x.get("name") for x in pol.get("srcintf", [])]
            dstintf = [x.get("name") for x in pol.get("dstintf", [])]
            action = pol.get("action", "")
            nat = pol.get("nat", "")
            print(f"  Rule #{pid:2} [{pname:25}]: {','.join(srcintf):15} -> {','.join(dstintf):15} | Act: {action:6} | NAT: {nat:3}")

    print("\n[TÀI KHOẢN ADMIN]:")
    if isinstance(admins, list):
        for a in admins:
            print(f"  * Admin: {a.get('name')} | Profile: {a.get('accprofile')}")
