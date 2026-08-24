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

def fetch_sql_events():
    global cached_events, last_fetch_time
    now = time.time()
    if cached_events and (now - last_fetch_time < 5):
        return cached_events

    ps_code = f'''
$connStr = "Server={SQL_SERVER};Database={SQL_DB};User Id={SQL_USER};Password={SQL_PASS};Connect Timeout=4;TrustServerCertificate=True;"
try {{
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandTimeout = 10
    $cmd.CommandText = "SELECT TOP 500 RecordID, EmployeeID, PersonName, Department, AccessDateTime, AccessDate, AccessTime, AuthenticationType, AuthenticationResult, DeviceName, DeviceSerialNo, ResourceName, ReaderName, CardNumber, Direction, CreatedAt FROM dbo.HCP_AccessRecord ORDER BY AccessDateTime DESC"
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $null = $adapter.Fill($dt)
    $conn.Close()
    
    $rows = @()
    foreach ($r in $dt.Rows) {{
        $obj = [ordered]@{{}}
        foreach ($col in $dt.Columns) {{
            $obj[$col.ColumnName] = [string]$r[$col.ColumnName]
        }}
        $rows += $obj
    }}
    $rows | ConvertTo-Json -Compress
}} catch {{
    Write-Output "[]"
}}
'''
    try:
        p = subprocess.run(["powershell", "-ExecutionPolicy", "Bypass", "-Command", ps_code], capture_output=True, text=True, timeout=8)
        out = p.stdout.strip()
        if out.startswith("[") or out.startswith("{"):
            data = json.loads(out)
            if isinstance(data, dict):
                data = [data]
            cached_events = data
            last_fetch_time = now
            return cached_events
    except Exception as e:
        print(f"[SQL Fetch Error]: {e}")
    
    return cached_events

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
            events = fetch_sql_events()
            res = {
                "status": "connected" if events else "offline",
                "server": SQL_SERVER,
                "database": SQL_DB,
                "totalEvents": len(events),
                "lastUpdated": time.strftime("%Y-%m-%d %H:%M:%S")
            }
            self.wfile.write(json.dumps(res).encode('utf-8'))
            return

        elif path == "/api/events":
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.end_headers()
            
            events = fetch_sql_events()
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

            events = fetch_sql_events()
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
                        "status": "On Time"
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

            # Determine status
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

            events = fetch_sql_events()
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
    with socketserver.TCPServer(("", PORT), FaceIdHandler) as httpd:
        print(f"===============================================================")
        print(f"  FACE ID & HIKCENTRAL PORTAL WEB SERVER RUNNING")
        print(f"  URL: http://localhost:{PORT}/")
        print(f"  Database: {SQL_DB} @ {SQL_SERVER}")
        print(f"===============================================================")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nShutting down server.")

if __name__ == "__main__":
    fetch_sql_events()
    start_server()
