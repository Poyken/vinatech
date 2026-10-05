import json

with open('full_firewall_details.json', 'r', encoding='utf-8') as f:
    fws = json.load(f)

for code, data in fws.items():
    print(f"\n==========================================")
    print(f"SITE: {code}")
    print(f"==========================================")
    
    # Status
    status = data.get('status', {})
    print(f"  Hostname: {status.get('hostname')} | Serial: {status.get('serial')} | Version: {status.get('version')}")
    
    # WAN & Interfaces
    print("  Interfaces:")
    for iface in data.get('interfaces', []):
        ip = iface.get('ip')
        name = iface.get('name')
        typ = iface.get('type')
        alias = iface.get('alias', '')
        if ip and ip != '0.0.0.0 0.0.0.0' or alias:
            print(f"    - {name:15s} (Alias: '{alias}', Type: {typ}): {ip}")
            
    # IPsec Tunnels
    print("  IPsec Phase 1 Tunnels:")
    for p1 in data.get('ipsec_phase1', []):
        print(f"    - {p1.get('name'):20s} -> Remote GW: {p1.get('remote-gw')} | Interface: {p1.get('interface')}")
        
    # Static Routes
    print("  Static Routes:")
    for r in data.get('static_routes', []):
        dst = r.get('dst')
        gw = r.get('gateway')
        dev = r.get('device')
        if dst != '0.0.0.0 0.0.0.0':
            print(f"    - Dst: {dst:30s} via {gw:15s} dev: {dev}")
            
    # Policies summary
    pols = data.get('policies', [])
    print(f"  Total Firewall Policies: {len(pols)}")
    for p in pols[:8]: # top 8
        srcintf = [x['name'] for x in p.get('srcintf', [])]
        dstintf = [x['name'] for x in p.get('dstintf', [])]
        srcaddr = [x['name'] for x in p.get('srcaddr', [])]
        dstaddr = [x['name'] for x in p.get('dstaddr', [])]
        print(f"    * Rule #{p.get('policyid')} [{p.get('name')}]: {srcintf} -> {dstintf} ({srcaddr} -> {dstaddr})")
