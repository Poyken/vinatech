import json

with open('hy_exhaustive_data.json', 'r', encoding='utf-8') as f:
    hy = json.load(f)

print('=== 1. STATUS ===')
st = hy.get('status', {})
for k in ['hostname', 'version', 'serial', 'biosver', 'logindisplay']:
    print(f"  {k}: {st.get(k)}")

print('\n=== 2. VIP (Port Forwarding) ===')
for vip in hy.get('vip', []):
    print(f"  VIP '{vip.get('name')}': {vip.get('extip')} (port {vip.get('extport')}) -> {vip.get('mappedip')} (port {vip.get('mappedport')}) on iface {vip.get('extintf')}")

print('\n=== 3. POLICIES ===')
for p in hy.get('policy', []):
    src = [x['name'] for x in p.get('srcintf', [])]
    dst = [x['name'] for x in p.get('dstintf', [])]
    srcaddr = [x['name'] for x in p.get('srcaddr', [])]
    dstaddr = [x['name'] for x in p.get('dstaddr', [])]
    svc = [x['name'] for x in p.get('service', [])]
    print(f"  Rule #{p.get('policyid')} [{p.get('name')}]: {src} -> {dst} | {srcaddr} -> {dstaddr} | action={p.get('action')} nat={p.get('nat')}")

print('\n=== 4. STATIC ROUTES ===')
for r in hy.get('router_static', []):
    print(f"  Route #{r.get('seq-num')}: dst={r.get('dst')} gw={r.get('gateway')} dev={r.get('device')} dist={r.get('distance')} comment={r.get('comment')}")

print('\n=== 5. LIVE ROUTING TABLE (Summary) ===')
routes = hy.get('routing_table_live', [])
for r in routes:
    print(f"  {r.get('type'):6s} {r.get('ip_mask'):18s} -> gw: {str(r.get('gateway')):15s} iface: {r.get('interface')}")

print('\n=== 6. IPSEC VPN TUNNELS ===')
for p1 in hy.get('ipsec_p1', []):
    print(f"  Phase1: {p1.get('name')} | gw={p1.get('remote-gw')} | intf={p1.get('interface')}")
for p2 in hy.get('ipsec_p2', []):
    print(f"  Phase2: {p2.get('name')} | p1={p2.get('phase1name')} | src={p2.get('src-subnet')} | dst={p2.get('dst-subnet')}")
