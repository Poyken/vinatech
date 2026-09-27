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

firewalls = [
    {
        "name": "Bắc Ninh (BN)",
        "code": "BN",
        "base_url": "https://42.112.60.211",
        "user": "admin",
        "pass": "Vinatechvina2025"
    },
    {
        "name": "Hưng Yên (HY)",
        "code": "HY",
        "base_url": "https://10.0.0.1:4443",
        "user": "hainv",
        "pass": "Vina@123"
    },
    {
        "name": "Bắc Giang 1 (BG1)",
        "code": "BG1",
        "base_url": "https://14.241.37.102",
        "user": "admin",
        "pass": "Vinatech!@#bg2023"
    },
    {
        "name": "Bắc Giang 2 (BG2)",
        "code": "BG2",
        "base_url": "https://14.252.33.178",
        "user": "admin",
        "pass": "Vinatechvina2025"
    }
]

def get_detailed_config(fw):
    print(f"[*] Đang thu thập cấu hình chi tiết cho {fw['name']}...")
    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(
        urllib.request.HTTPCookieProcessor(cj),
        urllib.request.HTTPSHandler(context=ctx)
    )

    login_url = f"{fw['base_url']}/logincheck"
    data = urllib.parse.urlencode({
        'username': fw['user'],
        'secretkey': fw['pass'],
        'ajax': '1'
    }).encode('utf-8')

    req = urllib.request.Request(login_url, data=data, headers={
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        'Referer': f"{fw['base_url']}/login"
    })

    try:
        resp = opener.open(req, timeout=10)
    except Exception as e:
        print(f"[-] Đăng nhập thất bại {fw['name']}: {e}")
        return None

    csrf_token = ""
    for cookie in cj:
        if "ccsrftoken" in cookie.name:
            csrf_token = cookie.value.strip('"')
            break

    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        'X-CSRFTOKEN': csrf_token,
        'Referer': f"{fw['base_url']}/ng/"
    }

    endpoints = {
        "status": "/api/v2/monitor/system/status",
        "global": "/api/v2/cmdb/system/global",
        "dns": "/api/v2/cmdb/system/dns",
        "interfaces": "/api/v2/cmdb/system/interface",
        "dhcp_servers": "/api/v2/cmdb/system.dhcp/server",
        "static_routes": "/api/v2/cmdb/router/static",
        "policies": "/api/v2/cmdb/firewall/policy",
        "addresses": "/api/v2/cmdb/firewall/address",
        "addr_groups": "/api/v2/cmdb/firewall/addrgrp",
        "ipsec_monitor": "/api/v2/monitor/vpn/ipsec",
        "ipsec_phase1": "/api/v2/cmdb/vpn.ipsec/phase1-interface",
        "ipsec_phase2": "/api/v2/cmdb/vpn.ipsec/phase2-interface",
        "admins": "/api/v2/cmdb/system/admin"
    }

    result = {"info": fw}
    for key, ep in endpoints.items():
        try:
            r = opener.open(urllib.request.Request(f"{fw['base_url']}{ep}", headers=headers), timeout=10)
            res_json = json.loads(r.read().decode('utf-8'))
            result[key] = res_json.get("results")
        except Exception as e:
            result[key] = f"Error: {e}"

    print(f"[+] Hoàn tất {fw['name']}")
    return result

full_db = {}
for fw in firewalls:
    res = get_detailed_config(fw)
    if res:
        full_db[fw["code"]] = res

with open("full_firewall_details.json", "w", encoding="utf-8") as f:
    json.dump(full_db, f, ensure_ascii=False, indent=2)

print("\nĐã lưu toàn bộ cấu hình chi tiết vào full_firewall_details.json!")
