import subprocess
import time
import re
import os
import sys

BASE_DIR = r"c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES_POP"
TOOLS_DIR = os.path.join(BASE_DIR, "tools")
CLOUDFLARED = os.path.join(TOOLS_DIR, "cloudflared.exe")
RELAY_SCRIPT = os.path.join(TOOLS_DIR, "api_relay.py")
TUNNEL_URL_FILE = os.path.join(TOOLS_DIR, "tunnel_url.txt")
CF_LOG = os.path.join(TOOLS_DIR, "cloudflared.log")
RELAY_LOG = os.path.join(TOOLS_DIR, "relay.log")

DETACHED_PROCESS = 0x00000008

print("="*70)
print("   VINATECH MES - LAUNCHING LIVE RELAY & CLOUDFLARE TUNNEL")
print("="*70)

# 1. Start Python API Relay
print("[1/2] Launching api_relay.py on http://127.0.0.1:5000...")
relay_f = open(RELAY_LOG, "w", encoding="utf-8")
relay_proc = subprocess.Popen(
    [sys.executable, RELAY_SCRIPT],
    cwd=BASE_DIR,
    stdout=relay_f,
    stderr=relay_f,
    creationflags=DETACHED_PROCESS
)
print(f"  -> Relay running with PID: {relay_proc.pid}")

# 2. Start Cloudflare Tunnel
print("[2/2] Launching Cloudflare Tunnel...")
cf_f = open(CF_LOG, "w", encoding="utf-8")
cf_proc = subprocess.Popen(
    [CLOUDFLARED, "tunnel", "--protocol", "http2", "--url", "http://127.0.0.1:5000"],
    stdout=cf_f,
    stderr=cf_f,
    creationflags=DETACHED_PROCESS
)
print(f"  -> Cloudflared running with PID: {cf_proc.pid}")

# 3. Wait for URL
url = None
for i in range(15):
    time.sleep(1)
    if os.path.exists(CF_LOG):
        try:
            content = open(CF_LOG, "r", encoding="utf-8", errors="ignore").read()
            match = re.search(r"https://[a-zA-Z0-9-]+\.trycloudflare\.com", content)
            if match:
                url = match.group(0)
                break
        except:
            pass

if url:
    print("\n" + "="*70)
    print("SUCCESS! CLOUDFLARE TUNNEL ACTIVE:")
    print(f"URL: {url}")
    print("="*70)
    with open(TUNNEL_URL_FILE, "w", encoding="utf-8") as f:
        f.write(url)
else:
    print("Could not obtain URL yet. Please check cloudflared.log.")
