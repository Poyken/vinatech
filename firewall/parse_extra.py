import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open("firewalls_extra.json", "r", encoding="utf-8") as f:
    extra = json.load(f)

for code, data in extra.items():
    print(f"\n{'='*30} EXTRA: {code} {'='*30}")
    
    # VIPs (Port Forwarding)
    vips = data.get("vip", [])
    print(f"[VIRTUAL IPs / PORT FORWARDING] ({len(vips) if isinstance(vips, list) else 0}):")
    if isinstance(vips, list):
        for v in vips:
            vname = v.get("name")
            extip = v.get("extip")
            mappedip = v.get("mappedip", [{}])[0].get("q_origin_key") if v.get("mappedip") else ""
            extport = v.get("extport")
            mappedport = v.get("mappedport")
            portforward = v.get("portforward")
            print(f"  * VIP: {vname:25} | Public IP: {extip}:{extport} -> Internal IP: {mappedip}:{mappedport} (PortForward: {portforward})")

    # Local users
    users = data.get("local_users", [])
    print(f"\n[LOCAL USERS] ({len(users) if isinstance(users, list) else 0}):")
    if isinstance(users, list):
        for u in users:
            uname = u.get("name")
            u_type = u.get("type")
            status = u.get("status")
            print(f"  * User: {uname:20} | Type: {u_type} | Status: {status}")

    # SD-WAN
    sdwan = data.get("sdwan", {})
    if isinstance(sdwan, dict):
        members = sdwan.get("members", [])
        print(f"\n[SD-WAN MEMBERS] ({len(members)}):")
        for m in members:
            itf = m.get("interface")
            gw = m.get("gateway")
            cost = m.get("cost")
            priority = m.get("priority")
            print(f"  * Interface: {itf:15} | Gateway: {gw} | Cost: {cost} | Priority: {priority}")

    # SSL VPN Settings
    ssl_set = data.get("ssl_settings", {})
    if isinstance(ssl_set, dict):
        ssl_port = ssl_set.get("port")
        ssl_status = ssl_set.get("status")
        tun_ip = ssl_set.get("tunnel-ip-pools", [])
        print(f"\n[SSL-VPN SETTINGS]: Status={ssl_status} | Port={ssl_port} | Pool={[x.get('name') for x in tun_ip]}")
