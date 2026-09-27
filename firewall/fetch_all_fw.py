import urllib.request
import urllib.parse
import ssl
import http.cookiejar
import json
import traceback
import sys

sys.stdout.reconfigure(encoding='utf-8')

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

firewalls = [
    {
        "name": "Bắc Ninh (BN)",
        "base_url": "https://42.112.60.211",
        "user": "admin",
        "pass": "Vinatechvina2025"
    },
    {
        "name": "Hưng Yên (HY)",
        "base_url": "https://10.0.0.1:4443",
        "user": "hainv",
        "pass": "Vina@123"
    },
    {
        "name": "Bắc Giang 1 (BG1)",
        "base_url": "https://14.241.37.102",
        "user": "admin",
        "pass": "Vinatech!@#bg2023"
    },
    {
        "name": "Bắc Giang 2 (BG2)",
        "base_url": "https://14.252.33.178",
        "user": "admin",
        "pass": "Vinatechvina2025"
    }
]

def audit_firewall(fw):
    print(f"\n==================== {fw['name']} ====================")
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
        res_body = resp.read().decode('utf-8', errors='ignore')
        print(f"Login Response: {res_body.strip()[:100]}")
    except Exception as e:
        print(f"Login failed: {e}")
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

    info = {"name": fw["name"], "url": fw["base_url"]}

    # Status
    try:
        r = opener.open(urllib.request.Request(f"{fw['base_url']}/api/v2/monitor/system/status", headers=headers), timeout=10)
        info["status"] = json.loads(r.read().decode('utf-8')).get("results", {})
    except Exception as e:
        info["status"] = {"error": str(e)}

    # Global
    try:
        r = opener.open(urllib.request.Request(f"{fw['base_url']}/api/v2/cmdb/system/global", headers=headers), timeout=10)
        info["global"] = json.loads(r.read().decode('utf-8')).get("results", {})
    except Exception as e:
        info["global"] = {"error": str(e)}

    # Interfaces
    try:
        r = opener.open(urllib.request.Request(f"{fw['base_url']}/api/v2/cmdb/system/interface", headers=headers), timeout=10)
        info["interfaces"] = json.loads(r.read().decode('utf-8')).get("results", [])
    except Exception as e:
        info["interfaces"] = []

    # Policies
    try:
        r = opener.open(urllib.request.Request(f"{fw['base_url']}/api/v2/cmdb/firewall/policy", headers=headers), timeout=10)
        info["policies"] = json.loads(r.read().decode('utf-8')).get("results", [])
    except Exception as e:
        info["policies"] = []

    # IPsec Tunnels
    try:
        r = opener.open(urllib.request.Request(f"{fw['base_url']}/api/v2/monitor/vpn/ipsec", headers=headers), timeout=10)
        info["ipsec"] = json.loads(r.read().decode('utf-8')).get("results", [])
    except Exception as e:
        info["ipsec"] = []

    print(f"Model: {info.get('status', {}).get('model', 'Unknown')} ({info.get('status', {}).get('model_number', '')})")
    print(f"Hostname: {info.get('global', {}).get('hostname', info.get('status', {}).get('hostname', 'Unknown'))}")
    print(f"Interfaces count: {len(info.get('interfaces', []))}")
    print(f"Policies count: {len(info.get('policies', []))}")
    print(f"IPsec Tunnels count: {len(info.get('ipsec', []))}")

    return info

all_data = {}
for fw in firewalls:
    try:
        res = audit_firewall(fw)
        if res:
            all_data[fw["name"]] = res
    except Exception as e:
        print(f"Error auditing {fw['name']}: {e}")

with open("firewalls_audit.json", "w", encoding="utf-8") as f:
    json.dump(all_data, f, ensure_ascii=False, indent=2)

print("\nAudit finished and saved to firewalls_audit.json")
