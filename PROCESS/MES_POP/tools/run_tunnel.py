import subprocess
import time
import re
import os
import sys

CLOUDFLARED = r"c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES_POP\tools\cloudflared.exe"
LOG_FILE = r"c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES_POP\tools\tunnel_url.txt"
ERR_LOG = r"c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES_POP\tools\cloudflared.log"

print("[*] Starting cloudflared in detached background process...")
log_f = open(ERR_LOG, "w", encoding="utf-8")
DETACHED_PROCESS = 0x00000008

proc = subprocess.Popen(
    [CLOUDFLARED, "tunnel", "--url", "http://127.0.0.1:5000"],
    stderr=log_f,
    stdout=log_f,
    creationflags=DETACHED_PROCESS
)

print(f"[*] Cloudflared PID: {proc.pid}. Waiting for tunnel URL...")
url = None
start = time.time()
while time.time() - start < 15:
    time.sleep(1)
    if os.path.exists(ERR_LOG):
        content = open(ERR_LOG, "r", encoding="utf-8", errors="ignore").read()
        match = re.search(r"https://[a-zA-Z0-9-]+\.trycloudflare\.com", content)
        if match:
            url = match.group(0)
            break

if url:
    print("\n" + "="*70)
    print(f"CLOUDFLARE TUNNEL URL: {url}")
    print("="*70 + "\n")
    with open(LOG_FILE, "w", encoding="utf-8") as f:
        f.write(url)
else:
    print("Could not find trycloudflare URL. Check cloudflared.log.")
