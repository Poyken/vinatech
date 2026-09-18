"""
==============================================================================
mes_telegram_bot.py — VINATECH MES TELEGRAM ASSISTANT BOT
==============================================================================
Mục đích:
  - Nhận lệnh từ điện thoại qua Telegram (VD: /trace LOT123, /health, /screen B530)
  - Điều phối chạy công cụ MES (mes.ps1, find_kb.ps1) an toàn
  - Bắn kết quả định dạng Markdown về lại điện thoại
  - Sử dụng 100% thư viện chuẩn Python (urllib, json, subprocess) - KHÔNG CẦN PIP INSTALL!
  - Bảo mật Whitelist: Chỉ phản hồi đúng Chat ID của Admin.
==============================================================================
"""

import os
import sys
import json
import time
import urllib.request
import urllib.parse
import subprocess
from pathlib import Path

# Đảm bảo in UTF-8 không bị lỗi charmap trên Windows Console
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

# Thư mục gốc dự án
BASE_DIR = Path(__file__).resolve().parent.parent
CONFIG_FILE = Path(__file__).resolve().parent / "telegram_config.json"

DEFAULT_CONFIG = {
    "bot_token": "YOUR_TELEGRAM_BOT_TOKEN_HERE",
    "allowed_chat_ids": ["YOUR_TELEGRAM_CHAT_ID_HERE"],
    "poll_interval_seconds": 2
}

def load_config():
    if not CONFIG_FILE.exists():
        with open(CONFIG_FILE, "w", encoding="utf-8") as f:
            json.dump(DEFAULT_CONFIG, f, indent=4, ensure_ascii=False)
        return DEFAULT_CONFIG
    try:
        with open(CONFIG_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        print(f"[ERROR] Khong doc duoc file config: {e}")
        return DEFAULT_CONFIG

def send_telegram_message(token, chat_id, text):
    """Gửi tin nhắn về Telegram, tự động chia nhỏ nếu vượt quá giới hạn 4096 ký tự"""
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    
    # Giới hạn Telegram là 4096 ký tự
    max_len = 4000
    chunks = [text[i:i + max_len] for i in range(0, len(text), max_len)]
    
    for chunk in chunks:
        payload = {
            "chat_id": chat_id,
            "text": chunk,
            "parse_mode": "Markdown"
        }
        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(
            url,
            data=data,
            headers={"Content-Type": "application/json"}
        )
        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                resp.read()
        except urllib.error.HTTPError as he:
            # Nếu Markdown lỗi ký tự đặc biệt, gửi dạng text thường
            payload.pop("parse_mode", None)
            data = json.dumps(payload).encode("utf-8")
            req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
            try:
                with urllib.request.urlopen(req, timeout=15) as resp:
                    resp.read()
            except Exception as e:
                print(f"[ERROR] Gui tin nhan that bai: {e}")
        except Exception as e:
            print(f"[ERROR] Loi mang khi gui Telegram: {e}")

def run_powershell_cmd(command_args):
    """Chạy an toàn mes.ps1 hoặc powershell script và lấy output UTF-8"""
    ps_cmd = ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"] + command_args
    try:
        proc = subprocess.run(
            ps_cmd,
            cwd=str(BASE_DIR),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=120
        )
        return proc.stdout.strip()
    except subprocess.TimeoutExpired:
        return "⚠️ Lỗi: Lệnh thực thi quá thời gian (Timeout 120s)."
    except Exception as e:
        return f"⚠️ Lỗi thực thi lệnh: {e}"

def handle_command(text):
    """Phân tích lệnh và gọi mes.ps1 tương ứng"""
    text = text.strip()
    parts = text.split()
    cmd = parts[0].lower() if parts else ""
    arg = " ".join(parts[1:]) if len(parts) > 1 else ""

    if cmd in ["/start", "/help"]:
        return (
            "🤖 *VINATECH MES ASSISTANT BOT*\n"
            "━━━━━━━━━━━━━━━━━━━━━━\n"
            "Danh sách lệnh hỗ trợ:\n\n"
            "🔍 *Truy vết & Nghiệp vụ:*\n"
            "• `/trace <LotID>` : Golden Query 360° quét Lot, Routing, Kho, Thùng\n"
            "• `/screen <ScreenID>` : Tra cứu SP, bảng của màn hình MES (B530, B540...)\n"
            "• `/find <Từ khóa>` : Tra cứu tài liệu 78+ file KB nội bộ\n\n"
            "🏥 *Kiểm tra hệ thống:*\n"
            "• `/health` : Morning Health Check quét Lot HOLD, WIP 24h, Box dở dang\n"
            "• `/check [DB]` : Kiểm tra kết nối 15 Database (SmartFactoryV2, ERP...)\n\n"
            "💡 *Ví dụ:* `/trace VN-2026-LOT001` hoặc `/screen B530`"
        )
    
    elif cmd == "/trace":
        if not arg:
            return "⚠️ Vui lòng nhập mã Lot/Barcode.\nVí dụ: `/trace VN-2026-LOT001`"
        # Chạy .\mes.ps1 trace <Lot>
        res = run_powershell_cmd([f".\\mes.ps1 trace '{arg}'"])
        return f"📋 *KẾT QUẢ TRUY VẾT 360° CHO `{arg}`:*\n```\n{res}\n```"

    elif cmd == "/screen":
        if not arg:
            return "⚠️ Vui lòng nhập Screen ID.\nVí dụ: `/screen B530`"
        res = run_powershell_cmd([f".\\mes.ps1 screen '{arg}'"])
        return f"🖥️ *THÔNG TIN MÀN HÌNH `{arg}`:*\n```\n{res}\n```"

    elif cmd == "/find":
        if not arg:
            return "⚠️ Vui lòng nhập từ khóa tra cứu.\nVí dụ: `/find HOLD`"
        res = run_powershell_cmd([f".\\mes.ps1 find '{arg}'"])
        return f"📚 *KẾT QUẢ TRA CỨU KB `{arg}`:*\n```\n{res}\n```"

    elif cmd == "/health":
        res = run_powershell_cmd([".\\mes.ps1 health"])
        return f"🏥 *BÁO CÁO HEALTH CHECK:*\n```\n{res}\n```"

    elif cmd == "/check":
        target = f"-Target '{arg}'" if arg else ""
        res = run_powershell_cmd([f".\\mes.ps1 check {target}"])
        return f"🔌 *KIỂM TRA KẾT NỐI DB:*\n```\n{res}\n```"

    else:
        # Nếu gửi text bình thường, tìm kiếm nhanh trong KB
        res = run_powershell_cmd([f".\\mes.ps1 find '{text}'"])
        return (
            f"❓ Bạn gửi: *{text}*\n"
            "━━━━━━━━━━━━━━━━━━━━━━\n"
            "🔍 *Gợi ý tra cứu tài liệu nhanh:*\n"
            f"```\n{res}\n```\n"
            "_(Dùng `/help` để xem danh sách các lệnh chuyên biệt)_"
        )

def main():
    print("=================================================================")
    print("      VINATECH MES TELEGRAM BOT ASSISTANT (Starting...)          ")
    print("=================================================================")
    
    config = load_config()
    token = config.get("bot_token", "").strip()
    allowed_chat_ids = [str(x).strip() for x in config.get("allowed_chat_ids", [])]

    if not token or token == "YOUR_TELEGRAM_BOT_TOKEN_HERE":
        print(f"[CHÚ Ý] Bạn chưa điền bot_token vào file: {CONFIG_FILE}")
        print("Vui lòng mở file trên và dán Token từ @BotFather vào.")
        return

    print(f"[OK] Đang chạy với Token: {token[:6]}...{token[-4:]}")
    print(f"[OK] Danh sách Chat ID được phép: {allowed_chat_ids}")
    print("[OK] Đang chờ tin nhắn từ Telegram (Nhấn Ctrl+C để dừng)...\n")

    offset = None
    poll_interval = config.get("poll_interval_seconds", 2)

    while True:
        try:
            url = f"https://api.telegram.org/bot{token}/getUpdates?timeout=30"
            if offset:
                url += f"&offset={offset}"
            
            req = urllib.request.Request(url)
            with urllib.request.urlopen(req, timeout=40) as resp:
                data = json.loads(resp.read().decode("utf-8"))

            if data.get("ok"):
                for update in data.get("result", []):
                    offset = update["update_id"] + 1
                    msg = update.get("message")
                    if not msg:
                        continue

                    chat_id = str(msg.get("chat", {}).get("id"))
                    sender_name = msg.get("from", {}).get("first_name", "User")
                    text = msg.get("text", "")

                    # Kiểm tra Whitelist
                    if allowed_chat_ids and allowed_chat_ids != ["YOUR_TELEGRAM_CHAT_ID_HERE"]:
                        if chat_id not in allowed_chat_ids:
                            print(f"[CẢNH BÁO] Từ chối tin nhắn từ Chat ID lạ: {chat_id} ({sender_name}): {text}")
                            continue

                    print(f"[{time.strftime('%H:%M:%S')}] Nhận từ {sender_name} ({chat_id}): {text}")
                    
                    # Báo đang xử lý nếu lệnh tốn thời gian
                    if text.startswith(("/trace", "/health", "/screen", "/find")):
                        send_telegram_message(token, chat_id, "⏳ _Đang xử lý yêu cầu, vui lòng chờ trong giây lát..._")

                    response = handle_command(text)
                    send_telegram_message(token, chat_id, response)
                    print(f"[{time.strftime('%H:%M:%S')}] -> Đã phản hồi xong.")

            time.sleep(poll_interval)

        except KeyboardInterrupt:
            print("\n[STOP] Đã dừng Bot.")
            break
        except urllib.error.URLError as ue:
            print(f"[MẠNG] Không kết nối được Telegram API (sẽ thử lại sau 5s): {ue}")
            time.sleep(5)
        except Exception as e:
            print(f"[LỖI] Ngoại lệ vòng lặp bot: {e}")
            time.sleep(3)

if __name__ == "__main__":
    main()
