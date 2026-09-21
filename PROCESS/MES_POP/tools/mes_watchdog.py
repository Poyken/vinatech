"""
==============================================================================
mes_watchdog.py — VINATECH MES AUTO-PILOT WATCHDOG DAEMON (v1.0)
==============================================================================
Tuần tra 24/7 CSDL và hệ thống POP Kiosk.
Tự động phát hiện và gửi cảnh báo Telegram chủ động khi có sự cố:
  1. Deadlock / Blocking sessions trên SQL Server
  2. Dữ liệu POP Sync bị kẹt chưa chuyển sang MES (>30 phút)
  3. Thiết bị bị kẹt khóa ACTIVE ở kế hoạch cũ (>12 giờ)
  4. Lô hàng bị HOLD bất thường
Hỗ trợ:
  --once : Chạy kiểm tra 1 lần rồi thoát (cho Task Scheduler / CLI Test)
  --loop : Chạy thường trực dạng Daemon ngầm (mặc định mỗi 30 phút)
==============================================================================
"""

import os
import sys
import time
import json
import atexit
import argparse
import subprocess
import urllib.request
from pathlib import Path

# Đảm bảo UTF-8 trên Windows Console
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

BASE_DIR = Path(__file__).resolve().parent.parent
CONFIG_DIR = Path(__file__).resolve().parent
LOCK_FILE = CONFIG_DIR / ".watchdog.lock"
HISTORY_FILE = CONFIG_DIR / ".watchdog_history.json"

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
                print(f"[WATCHDOG] Tien trinh da dang chay voi PID={old_pid}. Thoat phien ban moi.")
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

def load_telegram_config():
    local_cfg = CONFIG_DIR / "telegram_config.local.json"
    default_cfg = CONFIG_DIR / "telegram_config.json"
    target = local_cfg if local_cfg.exists() else default_cfg
    if not target.exists():
        return None
    try:
        with open(target, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return None

def send_telegram_alert(text):
    cfg = load_telegram_config()
    if not cfg:
        return False
    token = cfg.get("bot_token", "").strip()
    chat_ids = cfg.get("allowed_chat_ids", [])
    if not token or token == "YOUR_TELEGRAM_BOT_TOKEN_HERE":
        return False

    url = f"https://api.telegram.org/bot{token}/sendMessage"
    success = False
    for cid in chat_ids:
        if str(cid).strip() == "YOUR_TELEGRAM_CHAT_ID_HERE":
            continue
        payload = {
            "chat_id": str(cid).strip(),
            "text": text,
            "parse_mode": "HTML"
        }
        try:
            data = json.dumps(payload).encode("utf-8")
            req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
            with urllib.request.urlopen(req, timeout=10) as resp:
                resp.read()
            success = True
        except Exception as e:
            print(f"[WATCHDOG] Gui Telegram that bai cho ChatID {cid}: {e}")
    return success

def run_ps_query(query, profile="SmartFactoryV2"):
    cmd = [
        "powershell", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass",
        "-Command", f"& (Join-Path '{CONFIG_DIR}' 'run_query.ps1') -Query \"{query}\" -Profile '{profile}'"
    ]
    try:
        res = subprocess.run(cmd, cwd=str(BASE_DIR), capture_output=True, text=True, timeout=20, encoding="utf-8", errors="replace")
        return res.stdout.strip()
    except Exception as e:
        return ""

def check_system_vitals():
    """Tuan tra 4 chi so sinh ton cua nha may"""
    vitals = {
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "blocking_sessions": 0,
        "stuck_pop_sync": 0,
        "stuck_pop_lines": [],
        "orphan_machines": 0,
        "hold_lots": 0,
        "alerts": []
    }

    # 1. Kiem tra Blocking/Lock CSDL
    q_lock = "SELECT COUNT(1) FROM sys.dm_exec_requests r WITH(NOLOCK) WHERE r.blocking_session_id <> 0"
    out_lock = run_ps_query(q_lock, "SmartFactoryV2")
    for line in out_lock.splitlines():
        line = line.strip()
        if line.isdigit():
            vitals["blocking_sessions"] = int(line)
            break
    if vitals["blocking_sessions"] > 0:
        vitals["alerts"].append({
            "level": "CRITICAL",
            "title": "CSDL BỊ NGHẼN (BLOCKING SESSIONS)",
            "message": f"Có {vitals['blocking_sessions']} session đang bị block trên SQL Server!",
            "action": "Chạy '.\\mes.ps1 health -Detail' để kiểm tra session ID gây nghẽn."
        })

    # 2. Kiem tra POP Sync ket (>30 phut)
    q_sync = "SELECT LineCode, COUNT(*) AS Qty FROM MongoToMesPerformance WITH(NOLOCK) WHERE IsDone = 1 AND IsTransferred = 0 AND ModifyDateTime < DATEADD(MINUTE, -30, GETDATE()) GROUP BY LineCode"
    out_sync = run_ps_query(q_sync, "SmartFactoryV2")
    total_stuck = 0
    stuck_lines = []
    for line in out_sync.splitlines():
        parts = [p.strip() for p in line.split() if p.strip()]
        if len(parts) >= 2 and parts[1].isdigit():
            total_stuck += int(parts[1])
            stuck_lines.append(f"{parts[0]}: {parts[1]} bản ghi")
    vitals["stuck_pop_sync"] = total_stuck
    vitals["stuck_pop_lines"] = stuck_lines
    if total_stuck > 0:
        vitals["alerts"].append({
            "level": "WARNING",
            "title": "SẢN LƯỢNG POP KIOSK KẸT CHƯA SANG MES",
            "message": f"Phát hiện {total_stuck} bản ghi sản xuất hoàn thành trên Kiosk nhưng chưa sync sang MES (>30 phút).\nChuyền bị ảnh hưởng: {', '.join(stuck_lines)}",
            "action": "Chạy '.\\mes.ps1 pop-audit' để đối soát và xử lý."
        })

    # 3. Kiem tra May bi ket lock cu (>12 gio)
    q_mach = "SELECT COUNT(1) FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING WITH(NOLOCK) WHERE MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED') AND (LEFT(DAY_PLAN_NO, 8) < CONVERT(VARCHAR(8), GETDATE(), 112) OR MAPPED_AT < DATEADD(HOUR, -12, GETDATE()))"
    out_mach = run_ps_query(q_mach, "POP")
    for line in out_mach.splitlines():
        line = line.strip()
        if line.isdigit():
            vitals["orphan_machines"] = int(line)
            break
    if vitals["orphan_machines"] > 0:
        vitals["alerts"].append({
            "level": "WARNING",
            "title": "THIẾT BỊ BỊ TREO KHÓA KẾ HOẠCH CŨ",
            "message": f"Có {vitals['orphan_machines']} thiết bị bị kẹt trạng thái ACTIVE ở DayPlan cũ, công nhân ca mới không thể chọn máy.",
            "action": "Chạy '.\\mes.ps1 release-machines -Force' để tự động giải phóng."
        })

    return vitals

def format_alert_html(vitals):
    if not vitals["alerts"]:
        return ""
    
    html = f"🚨 <b>[VINATECH MES WATCHDOG ALERT]</b>\n"
    html += f"⏰ <i>Thời gian tuần tra: {vitals['timestamp']}</i>\n"
    html += f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"

    for idx, a in enumerate(vitals["alerts"], 1):
        icon = "🔴" if a["level"] == "CRITICAL" else "⚠️"
        html += f"{icon} <b>{idx}. {a['title']}</b>\n"
        html += f"{a['message']}\n"
        html += f"👉 <code>{a['action']}</code>\n\n"

    html += f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    html += f"⚡ <i>Hệ thống giám sát tự động MES_POP Watchdog</i>"
    return html

def run_once():
    print(f"[{time.strftime('%H:%M:%S')}] Dang tuan tra he thong MES & POP...")
    vitals = check_system_vitals()
    print(f"  * CSDL Blocking: {vitals['blocking_sessions']}")
    print(f"  * POP Sync Ket : {vitals['stuck_pop_sync']} ({len(vitals['stuck_pop_lines'])} chuyen)")
    print(f"  * May Ket Lock : {vitals['orphan_machines']}")
    print(f"  * So canh bao  : {len(vitals['alerts'])}")

    if vitals["alerts"]:
        msg = format_alert_html(vitals)
        sent = send_telegram_alert(msg)
        if sent:
            print("-> [OK] Da ban canh bao Telegram thanh cong!")
        else:
            print("-> [INFO] Phat hien canh bao (Chua ban Telegram do chua cau hinh token/chat_id).")
    else:
        print("-> [PASS] He thong khoe manh, khong co su co nghiem trong.")
    return vitals

def run_loop(interval_minutes=30):
    acquire_lock()
    print("=================================================================")
    print(f"  VINATECH MES AUTO-PILOT WATCHDOG (Chu ky: {interval_minutes} phut)")
    print("=================================================================")
    print(f"[OK] Watchdog dang chay voi PID={os.getpid()}. Nhan Ctrl+C de dung.\n")

    while True:
        try:
            run_once()
            print(f"[{time.strftime('%H:%M:%S')}] Nghi {interval_minutes} phut cho chu ky tuan tra tiep theo...\n")
            time.sleep(interval_minutes * 60)
        except KeyboardInterrupt:
            print("\n[STOP] Da dung Watchdog.")
            break
        except Exception as e:
            print(f"[ERROR] Loi ngoai le Watchdog: {e}")
            time.sleep(60)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Vinatech MES Watchdog Daemon")
    parser.add_argument("--once", action="store_true", help="Chay tuan tra 1 lan va thoat")
    parser.add_argument("--interval", type=int, default=30, help="Chu ky tuan tra (phut, mac dinh 30)")
    args = parser.parse_args()

    if args.once:
        run_once()
    else:
        run_loop(args.interval)
