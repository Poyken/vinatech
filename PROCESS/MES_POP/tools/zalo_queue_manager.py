# -*- coding: utf-8 -*-
"""
zalo_queue_manager.py — Quản lý hàng đợi tin nhắn Zalo chờ Antigravity kiểm duyệt
Hỗ trợ:
- Lấy danh sách tin nhắn mới chưa xử lý
- Đánh dấu đã xử lý xong (PROCESSED / REJECTED)
- Dọn dẹp hàng đợi định kỳ
"""

import os
import sys
import json
import datetime
from pathlib import Path

# Đảm bảo UTF-8
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

BASE_DIR = Path(__file__).resolve().parent.parent
CONFIG_DIR = BASE_DIR / "AI_AGENT_CONFIG"
INBOX_DIR = CONFIG_DIR / "zalo_inbox"
QUEUE_FILE = INBOX_DIR / "incoming_queue.jsonl"

def ensure_queue():
    INBOX_DIR.mkdir(parents=True, exist_ok=True)
    if not QUEUE_FILE.exists():
        QUEUE_FILE.touch()

def get_pending_requests():
    """Lấy danh sách các yêu cầu đang chờ Antigravity duyệt"""
    ensure_queue()
    pending = []
    lines = [l.strip() for l in QUEUE_FILE.read_text(encoding="utf-8").splitlines() if l.strip()]
    for idx, line in enumerate(lines):
        try:
            item = json.loads(line)
            if item.get("status") in ["WAITING_REVIEW", "PENDING_ANTIGRAVITY"]:
                item["_line_index"] = idx
                pending.append(item)
        except Exception:
            pass
    return pending

def mark_request_processed(timestamp_or_idx, status="PROCESSED", resolution=""):
    """Đánh dấu một yêu cầu đã được Antigravity và anh Đức duyệt xong"""
    ensure_queue()
    lines = [l.strip() for l in QUEUE_FILE.read_text(encoding="utf-8").splitlines() if l.strip()]
    updated_lines = []
    found = False

    for idx, line in enumerate(lines):
        try:
            item = json.loads(line)
            match = False
            if isinstance(timestamp_or_idx, int) and idx == timestamp_or_idx:
                match = True
            elif item.get("timestamp") == timestamp_or_idx or item.get("id") == timestamp_or_idx:
                match = True

            if match:
                item["status"] = status
                item["processed_at"] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                item["resolution"] = resolution
                found = True
            updated_lines.append(json.dumps(item, ensure_ascii=False))
        except Exception:
            updated_lines.append(line)

    QUEUE_FILE.write_text("\n".join(updated_lines) + "\n", encoding="utf-8")
    return found

def add_request_to_queue(raw_text, source="ZALO", source_window="", lots=None, classification=None):
    """Thêm một tin nhắn mới vào hàng đợi"""
    ensure_queue()
    now_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    req_id = f"REQ_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}_{os.getpid()}"
    entry = {
        "id": req_id,
        "timestamp": now_str,
        "source": source,
        "source_window": source_window,
        "raw_message": raw_text,
        "lots": lots or [],
        "classification": classification or {},
        "status": "WAITING_REVIEW"
    }
    with open(QUEUE_FILE, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")
    return entry

def display_pending():
    """In danh sách yêu cầu đang chờ ra màn hình console"""
    pending = get_pending_requests()
    print("=" * 70)
    print(f"  HÀNG ĐỢI TIN NHẮN ZALO CHỜ ANTIGRAVITY DUYỆT (Chờ duyệt: {len(pending)})")
    print("=" * 70)
    if not pending:
        print("  ✅ Tuyệt vời! Hiện không có yêu cầu nào đang chờ duyệt.")
        print("  💡 Khi công nhân nhắn tin vào 2 nhóm POP, tin nhắn sẽ tự xuất hiện ở đây.")
        print("=" * 70)
        return

    for i, item in enumerate(pending, 1):
        lots_str = ", ".join(item.get("lots", [])) if item.get("lots") else "Chưa bóc tách được Lot"
        action = item.get("classification", {}).get("action_type", "CHƯA_XÁC_ĐỊNH")
        print(f"[{i}] Thời gian: {item['timestamp']} | Nguồn: {item.get('source_window') or item.get('source')}")
        print(f"    Mã Lots  : {lots_str}")
        print(f"    Phân loại: {action}")
        print(f"    Nội dung : \"{item['raw_message'][:100]}\"")
        print("-" * 70)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--display":
        display_pending()
    elif len(sys.argv) > 2 and sys.argv[1] == "--mark":
        mark_request_processed(sys.argv[2])
        print(f"-> Đã đánh dấu yêu cầu {sys.argv[2]} là PROCESSED.")
    else:
        display_pending()
