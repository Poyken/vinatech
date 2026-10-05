import json

with open('hy_exhaustive_data.json', 'r', encoding='utf-8') as f:
    hy = json.load(f)

print('=== FORTIGATE 100F INTERFACES (CMDB & MONITOR) ===')
cmdb_ifaces = {x['name']: x for x in hy.get('interfaces_cmdb', [])}
mon_ifaces = hy.get('interfaces_monitor', {})

for name, cmdb in cmdb_ifaces.items():
    ip = cmdb.get('ip')
    mode = cmdb.get('mode')
    vdom = cmdb.get('vdom')
    status = cmdb.get('status')
    typ = cmdb.get('type')
    alias = cmdb.get('alias', '')
    
    mon = mon_ifaces.get(name, {})
    link = mon.get('link')
    speed = mon.get('speed')
    rx_bytes = mon.get('rx_bytes', 0)
    tx_bytes = mon.get('tx_bytes', 0)
    
    # only print active/configured interfaces or physical ports with link up
    if ip != '0.0.0.0 0.0.0.0' or link is True or alias or typ in ['vlan', 'tunnel', 'aggregate']:
        print(f"  Interface '{name}' (Alias: '{alias}', Type: {typ}):")
        print(f"    IP/Mask: {ip} | Mode: {mode} | Link: {link} | Speed: {speed}")
        print(f"    Traffic: RX={rx_bytes / (1024*1024):.2f} MB, TX={tx_bytes / (1024*1024):.2f} MB")
