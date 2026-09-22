# -*- coding: utf-8 -*-
"""
==============================================================================
zalo_window_reader.py — VINATECH MES ZALO PC DIRECT WINDOW READER (100% AUTO)
==============================================================================
Mục đích:
  - Tự động đọc tin nhắn trực tiếp từ cửa sổ Zalo PC (không cần bấm Copy).
  - Tự động nhận diện cửa sổ Chat Nhóm Xưởng (Pop-out Window hoặc Cửa sổ Zalo chính).
  - Khi có tin nhắn mới:
      + Tiền lệ lặp lại: Tự động sửa DB -> Tự động gõ & gửi phản hồi vào Zalo.
      + Lỗi mới: Kích hoạt quy tắc quá trình -> Bật Modal Phê Duyệt cho anh Đức.
  - Yêu cầu: Zalo khởi chạy với cờ --force-renderer-accessibility.
==============================================================================
"""

import os
import sys
import re
import time
import datetime
import threading
import subprocess
from pathlib import Path

# Đảm bảo UTF-8
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

BASE_DIR = Path(__file__).resolve().parent.parent
TOOLS_DIR = BASE_DIR / "tools"
sys.path.insert(0, str(TOOLS_DIR))

try:
    import uiautomation as auto
except ImportError:
    auto = None

try:
    from mes_zalo_autopilot import classify_request, execute_precedent, PrecedentVerdict, extract_lots
except ImportError:
    pass

class ZaloWindowReader:
    def __init__(self, target_window_keyword="", on_message_callback=None):
        self.target_keyword = target_window_keyword.lower()
        self.on_message_callback = on_message_callback
        self.seen_messages = set()
        self.running = False
        self.current_window = None

    def find_zalo_windows(self):
        """Tìm tất cả các cửa sổ Zalo đang mở (cả cửa sổ chính và cửa sổ nhóm đã tách riêng)"""
        if not auto:
            return []

        import ctypes
        user32 = ctypes.windll.user32
        h_def = user32.OpenDesktopW('Default', 0, False, 0x01FF)
        if h_def:
            user32.SetThreadDesktop(h_def)

        zalo_wins = []
        try:
            root = auto.GetRootControl()
            for win in root.GetChildren():
                c_name = win.ClassName
                w_name = win.Name
                # Cửa sổ Electron của Zalo có class Chrome_WidgetWin_1 hoặc tên chứa Zalo
                if c_name == "Chrome_WidgetWin_1" or "zalo" in w_name.lower():
                    # Lọc bớt các cửa sổ phụ vô hình
                    if win.NativeWindowHandle and user32.IsWindowVisible(win.NativeWindowHandle):
                        zalo_wins.append(win)
        except Exception as e:
            print(f"[ZALO READER] Lỗi quét cửa sổ: {e}")

        return zalo_wins

    def select_target_window(self):
        """Chọn cửa sổ phù hợp nhất (ưu tiên cửa sổ chat nhóm đã tách hoặc cửa sổ Zalo chính)"""
        wins = self.find_zalo_windows()
        if not wins:
            return None

        # Nếu có từ khóa chỉ định
        if self.target_keyword:
            for w in wins:
                if self.target_keyword in w.Name.lower():
                    return w

        # Ưu tiên cửa sổ tách riêng (tên không chỉ là chữ 'Zalo' đơn thuần)
        for w in wins:
            if w.Name.strip() and w.Name.strip().lower() != "zalo" and "antigravity" not in w.Name.lower():
                return w

        # Fallback về cửa sổ Zalo bất kỳ
        for w in wins:
            if "antigravity" not in w.Name.lower() and "chrome" not in w.Name.lower():
                return w

        return wins[0] if wins else None

    def read_latest_messages_from_window(self, win):
        """Đọc danh sách các tin nhắn văn bản hiện có trong cửa sổ Zalo"""
        if not win or not auto:
            return []

        messages = []
        try:
            # Quét các phần tử dạng Text hoặc ListItem bên trong cửa sổ
            for ctrl, depth in auto.WalkControl(win, maxDepth=12):
                c_type = ctrl.ControlTypeName
                name = ctrl.Name.strip() if ctrl.Name else ""
                
                # Bắt các đoạn văn bản có ý nghĩa (bỏ qua icon, thời gian lẻ, nút bấm)
                if name and len(name) > 3:
                    # Kiểm tra xem có dấu hiệu mã Lot hoặc từ khóa MES không
                    lots = extract_lots(name) if 'extract_lots' in globals() else []
                    mes_keywords = ["b782", "b530", "b552", "rollback", "chuyển ngày", "chuyen ngay", "kẹt", "ket", "fifo", "lot", "lỗi", "loi"]
                    if len(lots) > 0 or any(k in name.lower() for k in mes_keywords):
                        messages.append(name)
        except Exception:
            pass

        return messages

    def send_reply_to_zalo(self, win, text):
        """Tự động dán và gửi câu trả lời vào ô chat của cửa sổ Zalo"""
        if not win or not auto:
            return False

        try:
            # Tìm ô soạn tin nhắn (EditControl hoặc DocumentControl trong Zalo)
            edit_box = None
            for ctrl, depth in auto.WalkControl(win, maxDepth=8):
                if ctrl.ControlTypeName in ["EditControl", "DocumentControl"]:
                    edit_box = ctrl
                    break

            if edit_box:
                edit_box.Click()
                time.sleep(0.1)
                # Dán text qua clipboard để hỗ trợ tiếng Việt có dấu đầy đủ
                auto.SetClipboardText(text)
                auto.SendKeys('{Ctrl}v')
                time.sleep(0.2)
                auto.SendKeys('{Enter}')
                return True
            else:
                # Nếu không tìm thấy EditControl cụ thể, click vào góc dưới cửa sổ
                rect = win.BoundingRectangle
                if rect:
                    auto.Click(rect.left + int(rect.width() * 0.5), rect.bottom - 40)
                    time.sleep(0.1)
                    auto.SetClipboardText(text)
                    auto.SendKeys('{Ctrl}v')
                    time.sleep(0.2)
                    auto.SendKeys('{Enter}')
                    return True
        except Exception as e:
            print(f"[ZALO READER] Lỗi gửi tin nhắn Zalo: {e}")

        return False

    def start_listening(self, interval=1.0):
        """Vòng lặp lắng nghe liên tục tin nhắn mới từ Zalo"""
        self.running = True
        print(f"\n{'='*70}")
        print("  VINATECH MES — ZALO DIRECT WINDOW READER (100% AUTO)")
        print(f"{'='*70}")
        print("-> Trạng thái: Đang theo dõi trực tiếp cửa sổ Zalo PC.")
        print("-> Khi công nhân nhắn tin vào nhóm Zalo:")
        print("   + Hệ thống TỰ ĐỘNG ĐỌC MÀN HÌNH (Không cần bấm Copy).")
        print("   + Tiền lệ quen thuộc: Tự sửa & tự gửi trả lời vào nhóm.")
        print("   + Lỗi mới: Bật Modal Phê Duyệt cho anh Đức.")
        print("-> Nhấn Ctrl+C để dừng.\n")

        # Nạp các tin nhắn cũ lúc ban đầu vào seen_messages để không xử lý lại lịch sử
        initial_win = self.select_target_window()
        if initial_win:
            print(f"-> Đã kết nối cửa sổ Zalo: '{initial_win.Name}'")
            initial_msgs = self.read_latest_messages_from_window(initial_win)
            for m in initial_msgs:
                self.seen_messages.add(m)
            print(f"-> Đã bỏ qua {len(self.seen_messages)} tin nhắn lịch sử cũ.")
        else:
            print("(!) Chưa phát hiện cửa sổ Zalo đang mở. Đang chờ Zalo khởi động...")

        while self.running:
            try:
                win = self.select_target_window()
                if win:
                    self.current_window = win
                    messages = self.read_latest_messages_from_window(win)
                    for msg in messages:
                        if msg not in self.seen_messages:
                            self.seen_messages.add(msg)
                            print(f"\n[PHÁT HIỆN TIN NHẮN MỚI TỪ ZALO]: \"{msg[:100]}\"")
                            
                            # Xử lý tin nhắn
                            if self.on_message_callback:
                                self.on_message_callback(msg, win)
                            else:
                                self.default_handle_message(msg, win)

                time.sleep(interval)
            except KeyboardInterrupt:
                print("\n[STOP] Đã dừng theo dõi cửa sổ Zalo.")
                self.running = False
                break
            except Exception as e:
                time.sleep(interval)

    def default_handle_message(self, text, win):
        """Xử lý mặc định cho tin nhắn đọc được"""
        classification = classify_request(text)
        verdict = classification['verdict']

        if verdict == PrecedentVerdict.IGNORE:
            return

        print(f" - Phân loại: {verdict} ({classification['reason']})")

        if verdict == PrecedentVerdict.AUTO_EXECUTE:
            print(f"⚡ [AUTO-PILOT] Tự động thực thi tiền lệ...")
            resp = execute_precedent(classification)
            print("✅ Đã deploy thành công! Đang tự động gửi phản hồi vào Zalo...")
            # Tự động gửi lại câu trả lời vào Zalo
            self.send_reply_to_zalo(win, resp)
            print("-> [XONG] Đã gửi xác nhận vào nhóm Zalo!")
        else:
            print("🚨 YÊU CẦU MỚI: Cần anh Đức phê duyệt.")
            # Bắn thông báo
            show_windows_toast("Yêu cầu Zalo mới", f"Cần duyệt: {text[:80]}")

def main():
    reader = ZaloWindowReader()
    reader.start_listening()

if __name__ == "__main__":
    main()
