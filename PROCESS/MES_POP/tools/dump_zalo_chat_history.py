# -*- coding: utf-8 -*-
"""
==============================================================================
dump_zalo_chat_history.py — TỰ ĐỘNG TRÍCH XUẤT LỊCH SỬ CHAT TỪ CỬA SỔ ZALO
==============================================================================
Mục đích:
  - Tự động quét và trích xuất toàn bộ lịch sử tin nhắn đang hiển thị trong
    nhóm chat Zalo (không cần anh Đức copy thủ công).
  - Tự động lưu vào AI_AGENT_CONFIG/zalo_chat_samples.json để AI học hỏi:
      + Thuật ngữ tiếng lóng công nhân thường dùng
      + Các ca lỗi thực tế và cách xử lý
==============================================================================
"""

import os
import sys
import json
import time
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
OUTPUT_FILE = CONFIG_DIR / "zalo_chat_samples.json"

try:
    import uiautomation as auto
except ImportError:
    print("[ERROR] uiautomation chưa được cài đặt.")
    sys.exit(1)

def dump_chat_from_zalo():
    import ctypes
    user32 = ctypes.windll.user32
    h_def = user32.OpenDesktopW('Default', 0, False, 0x01FF)
    if h_def:
        user32.SetThreadDesktop(h_def)

    print("\n[ZALO DUMPER] Đang tìm kiếm cửa sổ Zalo trên màn hình...")
    root = auto.GetRootControl()
    target_win = None

    # Tìm cửa sổ Zalo (ưu tiên cửa sổ chat nhóm riêng hoặc Zalo chính)
    for win in root.GetChildren():
        c_name = win.ClassName
        w_name = win.Name
        if (c_name == "Chrome_WidgetWin_1" or "zalo" in w_name.lower()) and "antigravity" not in w_name.lower():
            if win.NativeWindowHandle and user32.IsWindowVisible(win.NativeWindowHandle):
                target_win = win
                # Nếu là cửa sổ chat riêng (tên không chỉ là chữ Zalo)
                if w_name.strip().lower() != "zalo":
                    break

    if not target_win:
        print("❌ Không tìm thấy cửa sổ Zalo nào đang mở và hiển thị trên màn hình.")
        print("💡 Hãy mở Zalo (hoặc cửa sổ chat nhóm Zalo) lên trước khi chạy lệnh này.")
        return

    print(f"✅ Đã tìm thấy cửa sổ: '{target_win.Name}' (Handle: {target_win.NativeWindowHandle})")
    print("⏳ Đang quét toàn bộ các khối tin nhắn văn bản trong cuộc hội thoại...")

    extracted_messages = []
    seen = set()

    for ctrl, depth in auto.WalkControl(target_win, maxDepth=16):
        name = ctrl.Name.strip() if ctrl.Name else ""
        if name and len(name) > 3 and name not in seen:
            # Lọc bỏ các text hệ thống giao diện
            ignore_texts = ["Zalo", "Tìm kiếm", "Tin nhắn", "Danh bạ", "Thông báo", "Cài đặt", "Gửi", "Đính kèm", "Soạn tin nhắn"]
            if not any(ign == name for ign in ignore_texts):
                seen.add(name)
                extracted_messages.append({
                    "text": name,
                    "control_type": ctrl.ControlTypeName,
                    "depth": depth
                })

    print(f"\n📊 Kết quả: Đã trích xuất được {len(extracted_messages)} dòng hội thoại!")

    if extracted_messages:
        result_data = {
            "source_window": target_win.Name,
            "dumped_at": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "total_messages": len(extracted_messages),
            "messages": extracted_messages
        }
        OUTPUT_FILE.write_text(json.dumps(result_data, indent=2, ensure_ascii=False), encoding="utf-8")
        print(f"💾 Đã lưu dữ liệu chat mẫu vào: {OUTPUT_FILE}")
        print("\n--- 10 TIN NHẮN ĐẦU TIÊN TRÍCH XUẤT ĐƯỢC ---")
        for i, m in enumerate(extracted_messages[:10], 1):
            print(f" {i}. {m['text'][:100]}")
    else:
        print("⚠️ Không lấy được text. Nếu cửa sổ chưa mở cờ trợ năng, vui lòng mở Zalo qua shortcut 'Zalo (MES Auto-Pilot)'.")

if __name__ == "__main__":
    dump_chat_from_zalo()
