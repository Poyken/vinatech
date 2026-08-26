import http.server
import socketserver
import json
import urllib.parse
import subprocess
import os
import sys
import threading
import time

PORT = 8090
DIR = os.path.dirname(os.path.abspath(__file__))

SQL_SERVER = "192.168.184.250,1433"
SQL_DB = "HCP_DATA"
SQL_USER = "hikcentral"
SQL_PASS = "vinatech@2026"

cached_events = []
last_fetch_time = 0
fetch_lock = threading.Lock()
db_connected = False

def do_fetch():
    global cached_events, last_fetch_time, db_connected
    script_path = os.path.join(DIR, "get_events_json.ps1")
    try:
        p = subprocess.run(
            ["powershell", "-ExecutionPolicy", "Bypass", "-File", script_path, "-Top", "500"],
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=12
        )
        out = p.stdout.strip()
        if out.startswith("[") or out.startswith("{"):
            data = json.loads(out)
            if isinstance(data, dict):
                data = [data]
            with fetch_lock:
                cached_events = data
                last_fetch_time = time.time()
                db_connected = True
            return True
    except Exception as e:
        print(f"[SQL Fetch Error]: {e}")
    
    # Fallback to local json if db offline
    if not cached_events:
        try:
            data_json_path = os.path.join(DIR, "data.json")
            if os.path.exists(data_json_path):
                with open(data_json_path, "r", encoding="utf-8") as f:
                    dj = json.load(f)
                    with fetch_lock:
                        cached_events = dj.get("recentLogs", [])
                        last_fetch_time = time.time()
        except Exception:
            pass
    return False

def background_sync_worker():
    """Continuously poll database in background every 6 seconds."""
    while True:
        do_fetch()
        time.sleep(6)

def get_events():
    with fetch_lock:
        return list(cached_events)

class ThreadingHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True

class FaceIdHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIR, **kwargs)

    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        query = urllib.parse.parse_qs(parsed.query)

        if path == "/api/status":
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.end_headers()
            events = get_events()
            res = {
                "status": "connected" if db_connected else "cached",
                "server": SQL_SERVER,
                "database": SQL_DB,
                "totalEvents": len(events),
                "lastUpdated": time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(last_fetch_time)) if last_fetch_time else "N/A"
            }
            self.wfile.write(json.dumps(res).encode('utf-8'))
            return

        elif path == "/api/events":
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.end_headers()
            
            events = get_events()
            limit = int(query.get("limit", [100])[0])
            date_filter = query.get("date", [None])[0]
            device_filter = query.get("device", [None])[0]
            dept_filter = query.get("dept", [None])[0]
            search_filter = query.get("search", [None])[0]

            filtered = events
            if date_filter:
                filtered = [e for e in filtered if e.get("AccessDate") == date_filter]
            if device_filter:
                filtered = [e for e in filtered if e.get("DeviceName") == device_filter]
            if dept_filter:
                filtered = [e for e in filtered if e.get("Department") == dept_filter]
            if search_filter:
                sf = search_filter.lower()
                filtered = [e for e in filtered if sf in e.get("PersonName", "").lower() or sf in e.get("EmployeeID", "").lower()]

            self.wfile.write(json.dumps(filtered[:limit]).encode('utf-8'))
            return

        elif path == "/api/attendance":
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.end_headers()

            events = get_events()
            date_filter = query.get("date", [time.strftime("%Y-%m-%d")])[0]
            
            day_events = [e for e in events if e.get("AccessDate") == date_filter] if date_filter else events

            emp_map = {}
            for e in day_events:
                eid = e.get("EmployeeID", "unknown")
                if eid not in emp_map:
                    emp_map[eid] = {
                        "employeeId": eid,
                        "personName": e.get("PersonName", ""),
                        "department": e.get("Department", ""),
                        "date": e.get("AccessDate", date_filter),
                        "firstCheckIn": e.get("AccessTime", ""),
                        "lastCheckOut": e.get("AccessTime", ""),
                        "checkInDevice": e.get("DeviceName", ""),
                        "checkOutDevice": e.get("DeviceName", ""),
                        "totalScans": 0,
                        "authType": e.get("AuthenticationType", ""),
                        "status": "Normal"
                    }
                item = emp_map[eid]
                item["totalScans"] += 1
                t = e.get("AccessTime", "")
                if t < item["firstCheckIn"]:
                    item["firstCheckIn"] = t
                    item["checkInDevice"] = e.get("DeviceName", "")
                if t > item["lastCheckOut"]:
                    item["lastCheckOut"] = t
                    item["checkOutDevice"] = e.get("DeviceName", "")

            # Determine status (HC Shift: 08:00 - 17:30)
            for eid, item in emp_map.items():
                if item["firstCheckIn"] > "08:15:00":
                    item["status"] = "Late Arrival"
                elif item["lastCheckOut"] < "17:00:00" and item["firstCheckIn"] != item["lastCheckOut"]:
                    item["status"] = "Early Departure"
                else:
                    item["status"] = "Normal"

            res = list(emp_map.values())
            self.wfile.write(json.dumps(res).encode('utf-8'))
            return

        elif path == "/api/stats":
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.end_headers()

            events = get_events()
            total = len(events)
            face_count = sum(1 for e in events if "face" in e.get("AuthenticationType", "").lower())
            finger_count = sum(1 for e in events if "finger" in e.get("AuthenticationType", "").lower())
            card_count = sum(1 for e in events if "card" in e.get("AuthenticationType", "").lower())
            
            devices_map = {}
            for e in events:
                dev = e.get("DeviceName", "Unknown")
                devices_map[dev] = devices_map.get(dev, 0) + 1

            res = {
                "totalEvents": total,
                "faceIdCount": face_count,
                "faceIdPercentage": round((face_count / total * 100), 1) if total > 0 else 0,
                "fingerCount": finger_count,
                "cardCount": card_count,
                "deviceBreakdown": devices_map
            }
            self.wfile.write(json.dumps(res).encode('utf-8'))
            return

        super().do_GET()

def start_server():
    # Start background polling thread
    t = threading.Thread(target=background_sync_worker, daemon=True)
    t.start()
    
    server_address = ("", PORT)
    with ThreadingHTTPServer(server_address, FaceIdHandler) as httpd:
        print(f"===============================================================")
        print(f"  FACE ID & HIKCENTRAL PORTAL WEB SERVER RUNNING (MULTI-THREADED)")
        print(f"  URL: http://localhost:{PORT}/")
        print(f"  Database: {SQL_DB} @ {SQL_SERVER}")
        print(f"===============================================================")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nShutting down server.")

if __name__ == "__main__":
    start_server()
