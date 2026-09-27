import urllib.request
import urllib.parse
import ssl
import http.cookiejar
import json

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

cj = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(
    urllib.request.HTTPCookieProcessor(cj),
    urllib.request.HTTPSHandler(context=ctx)
)

# 1. Login
login_url = "https://42.112.60.211/logincheck"
data = urllib.parse.urlencode({
    'username': 'admin',
    'secretkey': 'Vinatechvina2025',
    'ajax': '1'
}).encode('utf-8')

req = urllib.request.Request(login_url, data=data, headers={
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
    'Referer': 'https://42.112.60.211/login'
})

resp = opener.open(req, timeout=10)
login_res = resp.read().decode('utf-8')
print("Login result:", login_res)

# Extract ccsrftoken from cookies
csrf_token = ""
for cookie in cj:
    if "ccsrftoken" in cookie.name:
        csrf_token = cookie.value.strip('"')
        break

print("CSRF Token:", csrf_token)

# 2. Test status API
endpoints = [
    "/api/v2/monitor/system/status",
    "/api/v2/cmdb/system/global",
    "/api/v2/cmdb/system/interface",
    "/api/v2/cmdb/firewall/policy"
]

for ep in endpoints:
    try:
        api_req = urllib.request.Request(
            f"https://42.112.60.211{ep}",
            headers={
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
                'X-CSRFTOKEN': csrf_token,
                'Referer': 'https://42.112.60.211/ng/'
            }
        )
        with opener.open(api_req, timeout=10) as r:
            data = json.loads(r.read().decode('utf-8'))
            print(f"Endpoint {ep} SUCCESS: status={data.get('status')}, results count={len(data.get('results', [])) if isinstance(data.get('results'), list) else 'dict'}")
            if ep == "/api/v2/monitor/system/status":
                print("Status Info:", json.dumps(data.get('results'), indent=2))
    except Exception as e:
        print(f"Endpoint {ep} FAILED: {e}")
