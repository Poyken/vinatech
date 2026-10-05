import json

with open('hy_exhaustive_data.json', 'r', encoding='utf-8') as f:
    hy = json.load(f)

print('=== 1. ADDRESS OBJECTS ===')
addrs = {}
for a in hy.get('address', []):
    name = a.get('name')
    subnet = a.get('subnet')
    addrs[name] = subnet
    print(f"  {name:30s} -> {subnet}")

print('\n=== 2. ADDRESS GROUPS DETAILED ===')
for g in hy.get('addrgrp', []):
    gname = g.get('name')
    print(f"  Group '{gname}':")
    for m in g.get('member', []):
        mname = m.get('name')
        print(f"    * {mname:30s} : {addrs.get(mname, 'N/A')}")

print('\n=== 3. DHCP SERVERS ===')
for dhcp in hy.get('dhcp_server_config', []):
    print(f"  ID #{dhcp.get('id')} on iface '{dhcp.get('interface')}':")
    print(f"    Subnet: {dhcp.get('netmask')} Gateway: {dhcp.get('default-gateway')}")
    ip_ranges = dhcp.get('ip-range', [])
    for ipr in ip_ranges:
        print(f"    Range: {ipr.get('start-ip')} - {ipr.get('end-ip')}")

print('\n=== 4. SNMP & NTP & DNS ===')
dns = hy.get('dns', {})
print(f"  Primary DNS: {dns.get('primary')} | Secondary DNS: {dns.get('secondary')}")
ntp = hy.get('ntp', {})
print(f"  NTP Type: {ntp.get('type')} | Sync Interval: {ntp.get('syncinterval')}")
snmp = hy.get('snmp_sysinfo', {})
print(f"  SNMP Status: {snmp.get('status')} | Description: {snmp.get('description')} | Location: {snmp.get('location')}")
