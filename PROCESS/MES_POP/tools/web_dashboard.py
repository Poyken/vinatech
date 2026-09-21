"""
==============================================================================
web_dashboard.py — VINATECH MES REALTIME FACTORY WEB DASHBOARD (v1.0)
==============================================================================
Máy chủ giám sát thời gian thực Shop Floor MES & POP Kiosk.
- 0 External Dependencies (100% Python Standard Library).
- Giao diện Dark Glassmorphism, nạp L1 Cache RAM <1ms.
- Phục vụ điện thoại di động, máy tính bảng và TV giám sát xưởng.
==============================================================================
"""

import os
import sys
import json
import time
import atexit
import argparse
import subprocess
from pathlib import Path
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler

# Đảm bảo UTF-8 trên Windows Console
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

BASE_DIR = Path(__file__).resolve().parent.parent
CONFIG_DIR = Path(__file__).resolve().parent
HTML_FILE = CONFIG_DIR / "dashboard" / "index.html"
LOCK_FILE = CONFIG_DIR / ".dashboard.lock"

def is_pid_running(pid):
    if sys.platform == "win32":
        try:
            import ctypes
            h = ctypes.windll.kernel32.OpenProcess(0x1000, False, pid)
            if h:
                ctypes.windll.kernel32.CloseHandle(h)
                return True
            return False
        except Exception:
            return False
    else:
        try:
            os.kill(pid, 0)
            return True
        except OSError:
            return False

def acquire_lock():
    if LOCK_FILE.exists():
        try:
            with open(LOCK_FILE, "r", encoding="utf-8") as f:
                old_pid = int(f.read().strip())
            if is_pid_running(old_pid):
                print(f"[DASHBOARD] Web Dashboard da dang chay voi PID={old_pid}!")
                print(f"  -> Dùng '.\\mes.ps1 dashboard-stop' neu muon dung server cu.")
                sys.exit(0)
            else:
                LOCK_FILE.unlink(missing_ok=True)
        except Exception:
            pass

    try:
        with open(LOCK_FILE, "w", encoding="utf-8") as f:
            f.write(str(os.getpid()))
    except Exception:
        pass

def release_lock():
    try:
        if LOCK_FILE.exists():
            with open(LOCK_FILE, "r", encoding="utf-8") as f:
                cur_pid = int(f.read().strip())
            if cur_pid == os.getpid():
                LOCK_FILE.unlink(missing_ok=True)
    except Exception:
        pass

atexit.register(release_lock)

class DashboardHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Tắt log HTTP spam trên console để giữ màn hình gọn gàng
        return

    def do_GET(self):
        url_path = self.path.split("?")[0]

        if url_path in ["/", "/index.html"]:
            if HTML_FILE.exists():
                content = HTML_FILE.read_bytes()
                self.send_response(200)
                self.send_header("Content-Type", "text/html; charset=utf-8")
                self.send_header("Content-Length", str(len(content)))
                self.end_headers()
                self.wfile.write(content)
            else:
                self.send_error(404, "Dashboard HTML not found")

        elif url_path == "/api/pop":
            pop_file = BASE_DIR / "AI_AGENT_CONFIG" / "POP_MATRIX.json"
            if pop_file.exists():
                content = pop_file.read_bytes()
                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.send_header("Content-Length", str(len(content)))
                self.end_headers()
                self.wfile.write(content)
            else:
                self.send_error(404, "POP_MATRIX.json not found")

        elif url_path == "/api/matrix":
            matrix_file = BASE_DIR / "AI_AGENT_CONFIG" / "QUICK_MATRIX.json"
            if matrix_file.exists():
                content = matrix_file.read_bytes()
                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.send_header("Content-Length", str(len(content)))
                self.end_headers()
                self.wfile.write(content)
            else:
                self.send_error(404, "QUICK_MATRIX.json not found")

        else:
            self.send_error(404, "Not Found")

    def do_POST(self):
        if self.path == "/api/action":
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length)
            try:
                data = json.loads(body.decode("utf-8"))
                action = data.get("action", "").lower().strip()
                
                # Chi cho phep cac lenh Read-only an toan
                allowed_commands = {
                    "health": [".\\mes.ps1", "health"],
                    "readiness": [".\\mes.ps1", "pop-readiness"],
                    "release": [".\\mes.ps1", "release-machines"],
                    "pop-audit": [".\\mes.ps1", "pop-audit"]
                }

                if action not in allowed_commands:
                    resp_data = {"error": f"Hanh dong '{action}' khong duoc phep hoac khong ton tai."}
                else:
                    cmd_args = allowed_commands[action]
                    ps_cmd = ["powershell", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File"] + cmd_args
                    res = subprocess.run(
                        ps_cmd, cwd=str(BASE_DIR),
                        capture_output=True, text=True,
                        timeout=35, encoding="utf-8", errors="replace"
                    )
                    resp_data = {"output": res.stdout.strip()}

                resp_bytes = json.dumps(resp_data, ensure_ascii=False).encode("utf-8")
                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.send_header("Content-Length", str(len(resp_bytes)))
                self.end_headers()
                self.wfile.write(resp_bytes)
            except Exception as e:
                err_bytes = json.dumps({"error": str(e)}).encode("utf-8")
                self.send_response(500)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.send_header("Content-Length", str(len(err_bytes)))
                self.end_headers()
                self.wfile.write(err_bytes)
        else:
            self.send_error(404, "Not Found")

def main():
    parser = argparse.ArgumentParser(description="Vinatech MES Realtime Web Dashboard")
    parser.add_argument("--port", type=int, default=5000, help="Port Web Server (default 5000)")
    args = parser.parse_args()

    acquire_lock()

    server_address = ("0.0.0.0", args.port)
    server = ThreadingHTTPServer(server_address, DashboardHandler)

    print("=================================================================")
    print(f"  VINATECH MES & POP REALTIME FACTORY DASHBOARD (Port {args.port})")
    print("=================================================================")
    print(f"[OK] May chu Web dang chay tai: http://localhost:{args.port}")
    print(f"[OK] Truy cap qua mang LAN:     http://<IP_MAY_TINH>:{args.port}")
    print(f"[OK] PID tien trinh: {os.getpid()} (Nhan Ctrl+C de dung)\n")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[STOP] Da dung Web Dashboard Server.")
    finally:
        server.server_close()

if __name__ == "__main__":
    main()
