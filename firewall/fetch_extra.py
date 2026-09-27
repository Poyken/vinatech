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
    { "name": "Bắc Ninh (BN)", "code": "BN", "base_url": "https://42.112.60.211", "user": "admin", "pass": "Vinatechvina2025" },
    { "name": "Hưng Yên (HY)", "code": "HY", "base_url": "https://10.0.0.1:4443", "user": "hainv", "pass": "Vina@123" },
    { "name": "Bắc Giang 1 (BG1)", "code": "BG1", "base_url": "https://14.241.37.102", "user": "admin", "pass": "Vinatech!@#bg2023" },
    { "name": "Bắc Giang 2 (BG2)", "code": "BG2", "base_url": "https://14.252.33.178", "user": "admin", "pass": "Vinatechvina2025" }
]

def fetch_extra(fw):
    print(f"[*] Thu thập dữ liệu chuyên sâu cho {fw['name']}...")
    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(
        urllib.request.HTTPCookieProcessor(cj),
        urllib.request.HTTPSHandler(context=ctx)
    )

    login_url = f"{fw['base_url']}/logincheck"
    data = urllib.parse.urlencode({'username': fw['user'], 'secretkey': fw['pass'], 'ajax': '1'}).encode('utf-8')
    req = urllib.request.Request(login_url, data=data, headers={'User-Agent': 'Mozilla/5.0', 'Referer': f"{fw['base_url']}/login"})
    try:
        opener.open(req, timeout=10)
    except Exception as e:
        print(f"[-] Login failed {fw['name']}: {e}")
        return {}

    csrf_token = ""
    for cookie in cj:
        if "ccsrftoken" in cookie.name:
            csrf_token = cookie.value.strip('"')
            break

    headers = {'User-Agent': 'Mozilla/5.0', 'X-CSRFTOKEN': csrf_token, 'Referer': f"{fw['base_url']}/ng/"}

    endpoints = {
        "vip": "/api/v2/cmdb/firewall/vip",
        "sdwan": "/api/v2/cmdb/system/sdwan",
        "ssl_settings": "/api/v2/cmdb/vpn.ssl/settings",
        "local_users": "/api/v2/cmdb/user/local",
        "user_groups": "/api/v2/cmdb/user/group",
        "av_profile": "/api/v2/cmdb/antivirus/profile",
        "webfilter_profile": "/api/v2/cmdb/webfilter/profile",
        "app_profile": "/api/v2/cmdb/application/list",
        "ips_sensor": "/api/v2/cmdb/ips/sensor"
    }

    res = {}
    for k, ep in endpoints.items():
        try:
            r = opener.open(urllib.request.Request(f"{fw['base_url']}{ep}", headers=headers), timeout=10)
            res[k] = json.loads(r.read().decode('utf-8')).get("results")
        except Exception as e:
            res[k] = None
    return res

extra_data = {}
for fw in firewalls:
    extra_data[fw["code"]] = fetch_extra(fw)

with open("firewalls_extra.json", "w", encoding="utf-8") as f:
    json.dump(extra_data, f, ensure_ascii=False, indent=2)

print("[+] Đã hoàn thành thu thập dữ liệu chuyên sâu!")
