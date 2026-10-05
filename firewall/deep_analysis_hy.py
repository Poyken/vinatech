import json

with open('hy_exhaustive_data.json', 'r', encoding='utf-8') as f:
    hy = json.load(f)

print('=== HY STATUS ===')
status = hy.get('status', {})
for k in ['hostname', 'version', 'serial', 'biosver', 'logindisplay', 'cpu', 'mem']:
    print(f'  {k}: {status.get(k)}')

print('\n=== HY VIP (Virtual IPs / NAT Port Forwarding) ===')
for vip in hy.get('vip', []):
    print(f"  VIP '{vip.get('name')}': extip={vip.get('extip')} -> mappedip={vip.get('mappedip')} (extport={vip.get('extport')} -> mappedport={vip.get('mappedport')}) iface={vip.get('extintf')} protocol={vip.get('protocol')}")

print('\n=== HY POLICIES ===')
for pol in hy.get('policy', []):
    srcintf = [x.get('name') for x in pol.get('srcintf', [])]
    dstintf = [x.get('name') for x in pol.get('dstintf', [])]
    srcaddr = [x.get('name') for x in pol.get('srcaddr', [])]
    dstaddr = [x.get('name') for x in pol.get('dstaddr', [])]
    service = [x.get('name') for x in pol.get('service', [])]
    print(f"  Policy #{pol.get('policyid')} [{pol.get('name')}]:")
    print(f"    Flow: {srcintf} -> {dstintf}")
    print(f"    Addr: {srcaddr} -> {dstaddr}")
    print(f"    Service: {service} | Action: {pol.get('action')} | NAT: {pol.get('nat')}")

print('\n=== HY IPSEC PHASE 1 & 2 ===')
for p1 in hy.get('ipsec_p1', []):
    print(f"  Phase1: {p1.get('name')} | remote-gw={p1.get('remote-gw')} | iface={p1.get('interface')} | proposal={p1.get('proposal')}")
for p2 in hy.get('ipsec_p2', []):
    print(f"  Phase2: {p2.get('name')} | p1={p2.get('phase1name')} | src-subnet={p2.get('src-subnet')} | dst-subnet={p2.get('dst-subnet')}")

print('\n=== HY STATIC ROUTES ===')
for r in hy.get('router_static', []):
    print(f"  Route #{r.get('seq-num')}: dst={r.get('dst')} | gw={r.get('gateway')} | dev={r.get('device')} | dist={r.get('distance')} | comment={r.get('comment')}")

print('\n=== HY LIVE ROUTING TABLE (Top 17) ===')
for r in hy.get('routing_table_live', []):
    print(f"  {r.get('type')} {r.get('ip_mask')} via {r.get('gateway')} dev {r.get('interface')} (distance={r.get('distance')}, metric={r.get('metric')})")

print('\n=== HY ADDRESS GROUPS ===')
for g in hy.get('addrgrp', []):
    members = [m.get('name') for m in g.get('member', [])]
    print(f"  Group '{g.get('name')}': {members}")

print('\n=== HY SYSTEM RESOURCES ===')
res = hy.get('system_resources', {})
print(f"  CPU usage: {res.get('cpu')}% | Memory usage: {res.get('mem')}% | Disk: {res.get('disk')}% | Sessions: {res.get('session')}")

print('\n=== HY SD-WAN HEALTH ===')
sdwan = hy.get('sdwan_health', {})
for k, v in sdwan.items():
    print(f"  Health check '{k}': {v}")

print('\n=== HY DETECTED DEVICES ===')
devices = hy.get('device_query', [])
for d in devices:
    print(f"  Device: IP={d.get('ipv4_address')} MAC={d.get('mac')} Vendor={d.get('hardware_vendor')} Type={d.get('hardware_type')} Hostname={d.get('hostname')} OS={d.get('os_name')}")
