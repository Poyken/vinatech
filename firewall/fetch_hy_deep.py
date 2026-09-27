import urllib.request
import urllib.parse
import ssl
import http.cookiejar
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

base_url = "https://10.0.0.1:4443"
user = "hainv"
password = "Vina@123"

cj = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(
    urllib.request.HTTPCookieProcessor(cj),
    urllib.request.HTTPSHandler(context=ctx)
)

login_url = f"{base_url}/logincheck"
data = urllib.parse.urlencode({'username': user, 'secretkey': password, 'ajax': '1'}).encode('utf-8')
req = urllib.request.Request(login_url, data=data, headers={'User-Agent': 'Mozilla/5.0', 'Referer': f"{base_url}/login"})

try:
    opener.open(req, timeout=10)
except Exception as e:
    print(f"Login failed: {e}")
    sys.exit(1)

csrf_token = ""
for cookie in cj:
    if "ccsrftoken" in cookie.name:
        csrf_token = cookie.value.strip('"')
        break

headers = {'User-Agent': 'Mozilla/5.0', 'X-CSRFTOKEN': csrf_token, 'Referer': f"{base_url}/ng/"}

endpoints = {
    "arp": "/api/v2/monitor/network/arp",
    "dhcp_leases": "/api/v2/monitor/system.dhcp/lease",
    "routing_ipv4": "/api/v2/monitor/router/ipv4",
    "interfaces": "/api/v2/monitor/system/interface",
    "device_query": "/api/v2/monitor/user/device/query",
    "sdwan_health": "/api/v2/monitor/virtual-wan/health-check",
    "ipsec_monitor": "/api/v2/monitor/vpn/ipsec",
    "system_resources": "/api/v2/monitor/system/resource/usage",
    "managed_switches": "/api/v2/cmdb/switch-controller/managed-switch",
    "wifi_aps": "/api/v2/cmdb/wireless-controller/wtp",
    "ntp": "/api/v2/cmdb/system/ntp",
    "dns_database": "/api/v2/cmdb/system/dns-database",
    "traffic_shaper": "/api/v2/cmdb/firewall.shaper/traffic-shaper",
    "addrgrp": "/api/v2/cmdb/firewall/addrgrp"
}

hy_deep_data = {}
for name, ep in endpoints.items():
    try:
        r = opener.open(urllib.request.Request(f"{base_url}{ep}", headers=headers), timeout=10)
        res_json = json.loads(r.read().decode('utf-8'))
        hy_deep_data[name] = res_json.get("results")
        count = len(hy_deep_data[name]) if isinstance(hy_deep_data[name], list) else "object"
        print(f"[+] Fetched {name}: {count}")
    except Exception as e:
        hy_deep_data[name] = None
        print(f"[-] Failed {name}: {e}")

with open("hy_deep_data.json", "w", encoding="utf-8") as f:
    json.dump(hy_deep_data, f, ensure_ascii=False, indent=2)

print("\nSaved deep data to hy_deep_data.json successfully!")
