import urllib.request
import urllib.parse
import ssl
import http.cookiejar

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

cj = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(
    urllib.request.HTTPCookieProcessor(cj),
    urllib.request.HTTPSHandler(context=ctx)
)

url = "https://42.112.60.211/logincheck"
data = urllib.parse.urlencode({
    'username': 'admin',
    'secretkey': 'Vinatechvina2025',
    'ajax': '1'
}).encode('utf-8')

req = urllib.request.Request(url, data=data, headers={
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
    'Referer': 'https://42.112.60.211/login'
})

try:
    with opener.open(req, timeout=10) as resp:
        body = resp.read().decode('utf-8', errors='ignore')
        print("Status:", resp.status)
        print("Body:", body[:500])
        print("Cookies:")
        for cookie in cj:
            print(f"  {cookie.name} = {cookie.value[:10]}...")
except Exception as e:
    print("Error:", e)
