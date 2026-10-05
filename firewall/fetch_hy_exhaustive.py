import urllib.request
import urllib.parse
import ssl
import http.cookiejar
import json
import time
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

endpoints = [
    ("status", "/api/v2/monitor/system/status"),
    ("vip", "/api/v2/cmdb/firewall/vip"),
    ("policy", "/api/v2/cmdb/firewall/policy"),
    ("address", "/api/v2/cmdb/firewall/address"),
    ("addrgrp", "/api/v2/cmdb/firewall/addrgrp"),
    ("dhcp_server_config", "/api/v2/cmdb/system.dhcp/server"),
    ("dhcp_status", "/api/v2/monitor/system/dhcp"),
    ("ipsec_p1", "/api/v2/cmdb/vpn.ipsec/phase1-interface"),
    ("ipsec_p2", "/api/v2/cmdb/vpn.ipsec/phase2-interface"),
    ("ipsec_monitor", "/api/v2/monitor/vpn/ipsec"),
    ("router_static", "/api/v2/cmdb/router/static"),
    ("routing_table_live", "/api/v2/monitor/router/ipv4"),
    ("arp_table", "/api/v2/monitor/network/arp"),
    ("interfaces_cmdb", "/api/v2/cmdb/system/interface"),
    ("interfaces_monitor", "/api/v2/monitor/system/interface"),
    ("system_resources", "/api/v2/monitor/system/resource/usage"),
    ("sdwan_health", "/api/v2/monitor/virtual-wan/health-check"),
    ("device_query", "/api/v2/monitor/user/device/query"),
    ("admin_users", "/api/v2/cmdb/system/admin"),
    ("snmp_sysinfo", "/api/v2/cmdb/system.snmp/sysinfo"),
    ("ntp", "/api/v2/cmdb/system/ntp"),
    ("dns", "/api/v2/cmdb/system/dns"),
    ("traffic_shaper", "/api/v2/cmdb/firewall.shaper/traffic-shaper")
]

exhaustive_data = {}
for name, ep in endpoints:
    try:
        r = opener.open(urllib.request.Request(f"{base_url}{ep}", headers=headers), timeout=10)
        res_json = json.loads(r.read().decode('utf-8'))
        results = res_json.get("results")
        exhaustive_data[name] = results
        count = len(results) if isinstance(results, (list, dict)) else "scalar"
        print(f"[OK] {name:22s}: {count}")
    except Exception as e:
        exhaustive_data[name] = {"error": str(e)}
        print(f"[ERR] {name:22s}: {e}")
    time.sleep(0.3)

with open("hy_exhaustive_data.json", "w", encoding="utf-8") as f:
    json.dump(exhaustive_data, f, ensure_ascii=False, indent=2)

print("\nSuccessfully saved all deep data to hy_exhaustive_data.json!")
