# -*- coding: utf-8 -*-
"""
==============================================================================
mes_zalo_gui.py — VINATECH MES ZALO AUTO-PILOT CONTROL CENTER (GUI v2.0)
==============================================================================
Bảng điều khiển trực quan (Native Desktop GUI) cho Kỹ sư Nguyễn Văn Đức (EA Team)
- Tự động đọc tin nhắn trực tiếp từ cửa sổ Zalo PC (không cần bấm Copy)
- Chuyển đổi linh hoạt giữa 2 chế độ:
    + 🟢 Chế độ Tự Động (Auto-Pilot): Tiền lệ lặp lại tự xử lý | Lỗi mới xin duyệt
    + 🟠 Chế độ Thủ Công (Manual Supervised): Mọi yêu cầu đều chờ anh Đức bấm duyệt
- Khi gặp Lỗi Mới (Novel / Unknown Error):
    + Tự động kích hoạt Quy Tắc Quá Trình (L1 Cache -> 360° Trace -> 4 Dòng Vàng)
    + Soạn sẵn giải pháp và mã SQL Hotfix (Author: vanduc)
    + Bật Modal Phê Duyệt trực quan cho anh Đức xem, sửa SQL và bấm duyệt 1 chạm.
- Tự động dán và gửi câu trả lời lại vào khung chat Zalo sau khi hoàn tất.
==============================================================================
"""

import os
import sys
import re
import json
import time
import datetime
import threading
import subprocess
from pathlib import Path
import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext

BASE_DIR = Path(__file__).resolve().parent.parent
TOOLS_DIR = BASE_DIR / "tools"
CONFIG_DIR = BASE_DIR / "AI_AGENT_CONFIG"
HOTFIX_DIR = BASE_DIR / "sql" / "hotfixes"
SETTINGS_FILE = CONFIG_DIR / "zalo_gui_settings.json"
LOG_FILE = BASE_DIR / "zalo_gui.log"

# Đảm bảo stdout / stderr hoạt động bình thường trên cả python và pythonw
if sys.stdout is None:
    try:
        sys.stdout = open(LOG_FILE, "a", encoding="utf-8", buffering=1)
    except Exception:
        pass
if sys.stderr is None:
    try:
        sys.stderr = open(LOG_FILE, "a", encoding="utf-8", buffering=1)
    except Exception:
        pass

if sys.platform == "win32":
    try:
        if hasattr(sys.stdout, "reconfigure"):
            sys.stdout.reconfigure(encoding="utf-8")
        if hasattr(sys.stderr, "reconfigure"):
            sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

sys.path.insert(0, str(TOOLS_DIR))
try:
    from mes_zalo_autopilot import (
        classify_request, execute_precedent, PrecedentVerdict, 
        extract_lots, show_windows_toast
    )
except ImportError:
    pass

try:
    from mes_diagnose import diagnose
except ImportError:
    diagnose = None

try:
    from zalo_window_reader import ZaloWindowReader
except ImportError:
    ZaloWindowReader = None

class ZaloControlCenterApp:
    def __init__(self, root):
        self.root = root
        self.root.title("VINATECH MES — Zalo Auto-Pilot Control Center (IT EA Team)")
        self.root.geometry("1020x740")
        self.root.minsize(880, 620)
        self.root.configure(bg="#1a1c23")

        self.setup_styles()

        # Biến trạng thái
        self.mode_var = tk.StringVar(value="AUTO")  # "AUTO" hoặc "MANUAL"
        self.is_monitoring = tk.BooleanVar(value=True)
        self.auto_copy_var = tk.BooleanVar(value=True)
        self.auto_reply_zalo_var = tk.BooleanVar(value=True)
        self.last_clipboard_text = ""
        self.monitor_thread = None
        self.stop_event = threading.Event()
        self.window_reader = ZaloWindowReader() if ZaloWindowReader else None
        self.active_zalo_win = None

        self.load_settings()
        self.build_ui()
        self.start_monitoring_thread()
        self.root.after(500, self.check_and_launch_zalo_on_startup)
        self.root.protocol("WM_DELETE_WINDOW", self.on_close)

    def setup_styles(self):
        style = ttk.Style()
        style.theme_use("clam")

        self.c_bg = "#1a1c23"
        self.c_card = "#222530"
        self.c_accent = "#00d2d3"
        self.c_text = "#f1f2f6"
        self.c_text_muted = "#a4b0be"

        style.configure("TFrame", background=self.c_bg)
        style.configure("Card.TFrame", background=self.c_card, relief="flat")
        style.configure("TLabel", background=self.c_bg, foreground=self.c_text, font=("Segoe UI", 10))
        style.configure("Header.TLabel", background=self.c_card, foreground=self.c_accent, font=("Segoe UI", 13, "bold"))
        style.configure("SubHeader.TLabel", background=self.c_card, foreground=self.c_text_muted, font=("Segoe UI", 9))
        style.configure("CardTitle.TLabel", background=self.c_card, foreground="#ffffff", font=("Segoe UI", 11, "bold"))
        style.configure("TRadiobutton", background=self.c_card, foreground=self.c_text, font=("Segoe UI", 10, "bold"))
        style.configure("TCheckbutton", background=self.c_card, foreground=self.c_text, font=("Segoe UI", 9))

    def load_settings(self):
        if SETTINGS_FILE.exists():
            try:
                data = json.loads(SETTINGS_FILE.read_text(encoding="utf-8"))
                self.mode_var.set(data.get("mode", "AUTO"))
                self.auto_copy_var.set(data.get("auto_copy", True))
                self.auto_reply_zalo_var.set(data.get("auto_reply_zalo", True))
            except Exception:
                pass

    def save_settings(self):
        data = {
            "mode": self.mode_var.get(),
            "auto_copy": self.auto_copy_var.get(),
            "auto_reply_zalo": self.auto_reply_zalo_var.get(),
            "last_updated": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        try:
            SETTINGS_FILE.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
        except Exception:
            pass

    def build_ui(self):
        # 1. HEADER BAR
        header_frame = ttk.Frame(self.root, style="Card.TFrame", padding=(15, 12))
        header_frame.pack(fill="x", padx=12, pady=(12, 6))

        title_box = ttk.Frame(header_frame, style="Card.TFrame")
        title_box.pack(side="left")
        ttk.Label(title_box, text="⚡ VINATECH MES — ZALO AUTO-PILOT CONTROL CENTER", style="Header.TLabel").pack(anchor="w")
        ttk.Label(title_box, text="Kỹ sư IT Phụ trách: Nguyễn Văn Đức (EA Team) | Author / ChangeUserID: vanduc", style="SubHeader.TLabel").pack(anchor="w")

        right_box = ttk.Frame(header_frame, style="Card.TFrame")
        right_box.pack(side="right")

        btn_launch_zalo = tk.Button(
            right_box,
            text="🚀 Mở Zalo Trợ Năng",
            font=("Segoe UI", 9, "bold"),
            bg="#2e86de",
            fg="#ffffff",
            activebackground="#54a0ff",
            relief="flat",
            padx=10,
            pady=4,
            command=self.launch_accessible_zalo
        )
        btn_launch_zalo.pack(side="left", padx=5)

        self.lbl_status = tk.Label(right_box, text="● ĐANG THEO DÕI (LIVE)", font=("Segoe UI", 10, "bold"), fg="#1dd1a1", bg=self.c_card, padx=10, pady=4, relief="ridge")
        self.lbl_status.pack(side="left", padx=5)

        # 2. CONTROL PANEL
        control_frame = ttk.Frame(self.root, style="Card.TFrame", padding=(15, 12))
        control_frame.pack(fill="x", padx=12, pady=6)

        ttk.Label(control_frame, text="1. CHỌN CHẾ ĐỘ PHÊ DUYỆT & VẬN HÀNH:", style="CardTitle.TLabel").pack(anchor="w", pady=(0, 6))

        mode_box = ttk.Frame(control_frame, style="Card.TFrame")
        mode_box.pack(fill="x", pady=4)

        rb_co_pilot = ttk.Radiobutton(
            mode_box,
            text="🔵 Chế Độ Duyệt Qua Antigravity (An Toàn Tuyệt Đối): Thu thập tin vào hàng đợi -> Chờ mở Antigravity cùng anh Đức duyệt",
            variable=self.mode_var,
            value="ANTIGRAVITY",
            command=self.on_mode_changed
        )
        rb_co_pilot.pack(anchor="w", pady=3)

        rb_manual = ttk.Radiobutton(
            mode_box,
            text="🟠 Chế Độ Thủ Công (Modal GUI): Bật cửa sổ Popup Tkinter để anh Đức duyệt trực tiếp trên màn hình",
            variable=self.mode_var,
            value="MANUAL",
            command=self.on_mode_changed
        )
        rb_manual.pack(anchor="w", pady=3)

        rb_auto = ttk.Radiobutton(
            mode_box,
            text="🟢 Chế Độ Tự Động (Auto-Pilot): Tiền lệ quen thuộc tự sửa DB 100% | Lỗi mới xin duyệt",
            variable=self.mode_var,
            value="AUTO",
            command=self.on_mode_changed
        )
        rb_auto.pack(anchor="w", pady=3)

        # Cài đặt phụ trợ
        opt_box = ttk.Frame(control_frame, style="Card.TFrame")
        opt_box.pack(fill="x", pady=(8, 2))

        ttk.Checkbutton(
            opt_box,
            text="Tự động đọc tin nhắn trực tiếp từ cửa sổ Zalo PC (Không cần bấm Copy)",
            variable=tk.BooleanVar(value=True),
            state="disabled"
        ).pack(side="left", padx=(0, 15))

        ttk.Checkbutton(
            opt_box,
            text="Tự động gửi câu trả lời vào nhóm Zalo khi xử lý xong",
            variable=self.auto_reply_zalo_var,
            command=self.save_settings
        ).pack(side="left", padx=(0, 15))

        self.btn_toggle_monitor = tk.Button(
            opt_box,
            text="⏸ Tạm Dừng",
            font=("Segoe UI", 9, "bold"),
            bg="#34495e",
            fg="#ffffff",
            relief="flat",
            padx=10,
            pady=2,
            command=self.toggle_monitoring
        )
        self.btn_toggle_monitor.pack(side="right")

        # 3. DIRECT TEST INPUT
        test_frame = ttk.Frame(self.root, style="Card.TFrame", padding=(15, 10))
        test_frame.pack(fill="x", padx=12, pady=6)

        ttk.Label(test_frame, text="2. NHẬP / DÁN THỬ TIN NHẮN TỪ ZALO:", style="CardTitle.TLabel").pack(anchor="w", pady=(0, 4))

        input_box = ttk.Frame(test_frame, style="Card.TFrame")
        input_box.pack(fill="x")

        self.txt_input = tk.Entry(input_box, font=("Segoe UI", 11), bg="#2c303e", fg="#ffffff", insertbackground="#00d2d3", relief="flat")
        self.txt_input.pack(side="left", fill="x", expand=True, ipady=6, padx=(0, 8))
        self.txt_input.insert(0, "Anh Đức ơi chuyển ngày b782 giúp em lot VV26090123 sang 2026-09-23")
        self.txt_input.bind("<Return>", lambda e: self.process_manual_input())

        btn_process = tk.Button(
            input_box,
            text="⚡ Xử Lý Ngay",
            font=("Segoe UI", 10, "bold"),
            bg=self.c_accent,
            fg="#1a1c23",
            activebackground="#48dbfb",
            relief="flat",
            padx=16,
            pady=4,
            command=self.process_manual_input
        )
        btn_process.pack(side="right")

        # 4. LIVE LOG
        log_frame = ttk.Frame(self.root, style="Card.TFrame", padding=(15, 10))
        log_frame.pack(fill="both", expand=True, padx=12, pady=(6, 12))

        log_header = ttk.Frame(log_frame, style="Card.TFrame")
        log_header.pack(fill="x", pady=(0, 6))
        ttk.Label(log_header, text="3. NHẬT KÝ THEO DÕI & TỰ ĐỘNG XỬ LÝ (LIVE AUDIT FEED):", style="CardTitle.TLabel").pack(side="left")

        btn_clear = tk.Button(
            log_header,
            text="Xóa Log",
            font=("Segoe UI", 8),
            bg="#2c303e",
            fg="#a4b0be",
            relief="flat",
            padx=8,
            command=self.clear_log
        )
        btn_clear.pack(side="right")

        self.txt_log = scrolledtext.ScrolledText(
            log_frame,
            font=("Consolas", 10),
            bg="#14151b",
            fg="#ecf0f1",
            insertbackground="#00d2d3",
            relief="flat",
            padx=10,
            pady=8
        )
        self.txt_log.pack(fill="both", expand=True)

        self.log("🚀 Hệ thống Zalo Auto-Pilot Control Center (v2.0 Direct Window Reader) đã khởi động.")
        self.log(f"📋 Chế độ hiện tại: {'🟢 TỰ ĐỘNG (Auto-Pilot)' if self.mode_var.get() == 'AUTO' else '🟠 THỦ CÔNG PHÊ DUYỆT'}")
        self.log("💡 Hệ thống đang quét tự động cửa sổ Zalo PC và Clipboard cùng lúc.\n")

    def log(self, text):
        now = datetime.datetime.now().strftime("%H:%M:%S")
        self.txt_log.insert(tk.END, f"[{now}] {text}\n")
        self.txt_log.see(tk.END)

    def clear_log(self):
        self.txt_log.delete("1.0", tk.END)

    def launch_accessible_zalo(self):
        """Khởi động Zalo kèm cờ trợ năng"""
        zalo_exe = Path(os.path.expandvars(r"%LOCALAPPDATA%\Programs\Zalo\Zalo.exe"))
        if zalo_exe.exists():
            subprocess.Popen([str(zalo_exe), "--force-renderer-accessibility"], cwd=str(zalo_exe.parent))
            self.log("🚀 Đã mở Zalo PC với cờ trợ năng (--force-renderer-accessibility)!")
        else:
            bat_file = BASE_DIR / "start_zalo_accessible.bat"
            if bat_file.exists():
                subprocess.Popen(["cmd.exe", "/c", str(bat_file)])
                self.log("🚀 Đã gửi lệnh khởi động Zalo PC với cờ --force-renderer-accessibility!")
            else:
                self.log("❌ Không tìm thấy Zalo.exe tại đường dẫn mặc định.")

    def check_and_launch_zalo_on_startup(self):
        """Tự động kiểm tra và khởi động Zalo trợ năng nếu chưa mở"""
        try:
            cmd = 'tasklist /fi "imagename eq Zalo.exe" 2>nul'
            out = subprocess.check_output(cmd, shell=True, text=True, errors="ignore")
            if "Zalo.exe" not in out:
                self.log("ℹ️ Chưa phát hiện Zalo PC đang chạy. Đang tự động khởi động Zalo Trợ Năng...")
                self.launch_accessible_zalo()
            else:
                self.log("✅ Zalo PC đang hoạt động.")
        except Exception:
            pass

    def on_mode_changed(self):
        mode = self.mode_var.get()
        self.save_settings()
        if mode == "AUTO":
            self.log("🔄 ĐÃ CHUYỂN SANG: 🟢 CHẾ ĐỘ TỰ ĐỘNG (Auto-Pilot)")
            self.log("   -> Tiền lệ lặp lại: Tự động sửa & tự gửi trả lời Zalo.")
            self.log("   -> Lỗi mới: Bật Modal xin anh Đức phê duyệt.")
        else:
            self.log("🔄 ĐÃ CHUYỂN SANG: 🟠 CHẾ ĐỘ BÁN TỰ ĐỘNG (Thủ Công Phê Duyệt)")
            self.log("   -> MỌI yêu cầu đều dừng lại để anh Đức bấm [Phê Duyệt].")

    def toggle_monitoring(self):
        if self.is_monitoring.get():
            self.is_monitoring.set(False)
            self.lbl_status.config(text="● TẠM DỪNG (PAUSED)", fg="#ff6b6b")
            self.btn_toggle_monitor.config(text="▶ Tiếp Tục", bg="#10ac84")
            self.log("⏸ Đã tạm dừng tính năng theo dõi tin nhắn Zalo.")
        else:
            self.is_monitoring.set(True)
            self.lbl_status.config(text="● ĐANG THEO DÕI (LIVE)", fg="#1dd1a1")
            self.btn_toggle_monitor.config(text="⏸ Tạm Dừng", bg="#34495e")
            self.log("▶ Đã kích hoạt lại tính năng theo dõi tin nhắn Zalo.")

    # ------------------------------------------------------------------
    # PIPELINE XỬ LÝ TIN NHẮN
    # ------------------------------------------------------------------
    def process_incoming_message(self, raw_text, source="ZALO_WINDOW", win=None):
        raw_text = raw_text.strip()
        if not raw_text:
            return

        self.log(f"📥 Tiếp nhận yêu cầu ({source}): \"{raw_text[:80]}...\"")
        if win:
            self.active_zalo_win = win
            self.log(f"   (Cửa sổ nguồn: '{win.Name}')")
        
        classification = classify_request(raw_text)
        verdict = classification['verdict']
        action = classification['action_type']
        lots = classification['lots']
        lots_str = ", ".join(lots) if lots else "N/A"

        self.log(f"🔎 Phân loại: {verdict} | Action: {action} | Lots: [{lots_str}]")

        # Lưu tin nhắn vào hàng đợi để Antigravity có thể đọc và duyệt bất cứ lúc nào
        try:
            inbox_dir = BASE_DIR / "AI_AGENT_CONFIG" / "zalo_inbox"
            inbox_dir.mkdir(parents=True, exist_ok=True)
            queue_file = inbox_dir / "incoming_queue.jsonl"
            queue_entry = {
                "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "source": source,
                "source_window": win.Name if win else "",
                "raw_message": raw_text,
                "classification": {
                    "verdict": str(verdict),
                    "action_type": action,
                    "lots": lots,
                    "reason": classification.get("reason", "")
                },
                "status": "WAITING_REVIEW"
            }
            with open(queue_file, "a", encoding="utf-8") as qf:
                qf.write(json.dumps(queue_entry, ensure_ascii=False) + "\n")
        except Exception as e:
            self.log(f"Lỗi ghi hàng đợi inbox: {e}")

        current_mode = self.mode_var.get()

        if verdict == PrecedentVerdict.IGNORE:
            return

        # 1. TIỀN LỆ LẶP LẠI & CHẾ ĐỘ AUTO -> XỬ LÝ NGAY 100%
        if verdict == PrecedentVerdict.AUTO_EXECUTE and current_mode == "AUTO":
            self.log(f"⚡ [AUTO-PILOT] Thực thi tự động tiền lệ '{action}' (Không cần xin duyệt)...")
            response = execute_precedent(classification)
            self.log("✅ Đã xử lý & deploy thành công!")
            self.finish_response(response, win=win)

        # 2. LỖI MỚI HOẶC CHẾ ĐỘ THỦ CÔNG -> QUY TẮC QUÁ TRÌNH & MODAL DUYỆT
        else:
            reason = classification['reason']
            if verdict == PrecedentVerdict.ESCALATE_TO_DUC:
                self.log(f"🚨 PHÁT HIỆN YÊU CẦU MỚI: {reason}")
            else:
                self.log(f"🟠 CHẾ ĐỘ THỦ CÔNG: Yêu cầu '{action}' cần anh Đức xác nhận trước khi sửa DB.")

            proposal = self.run_process_rules_diagnosis(raw_text, classification)
            self.root.after(0, lambda: self.show_approval_modal(raw_text, classification, proposal, win=win))

    def run_process_rules_diagnosis(self, raw_text, classification):
        self.log("🔬 Đang thực hiện Quy Tắc Quá Trình (L1 Cache -> 360° Trace -> 4 Dòng Vàng)...")
        diag_data = None
        if diagnose:
            try:
                diag_data = diagnose(raw_text, check_live_db=True)
            except Exception as e:
                self.log(f"Lỗi khi chạy chẩn đoán: {e}")

        lots = classification['lots']
        lots_in = ", ".join([f"'{l}'" for l in lots]) if lots else "''"
        action = classification['action_type']

        if action == "MOVEDATE":
            today = datetime.datetime.now().strftime("%Y-%m-%d")
            proposed_sql = f"""USE SmartFactoryV2;
GO
BEGIN TRAN;
-- Cập nhật JobDate và ProdDateTime vượt mốc 10:00 AM (Author: vanduc)
UPDATE H
SET 
    H.ProdDateTime = DATEADD(HOUR, 10, H.ProdDateTime),
    H.JobDate = '{today}',
    H.ChangeDateTime = GETDATE(),
    H.ChangeUserID = 'vanduc'
FROM SmartFactoryV2.dbo.STB_ProdRouteHist H
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S ON H.ControlNo = S.ControlNo
WHERE S.Barcode IN ({lots_in});

COMMIT TRAN;"""
        elif action == "ROLLBACK":
            proposed_sql = f"""USE SmartFactoryV2;
GO
BEGIN TRAN;
-- Rollback hủy lượt chốt gần nhất (Author: vanduc)
DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteWorkerHist
WHERE ProdRouteHistNo IN (
    SELECT MAX(ProdRouteHistNo) FROM SmartFactoryV2.dbo.STB_ProdRouteHist H WITH(NOLOCK)
    INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S WITH(NOLOCK) ON H.ControlNo = S.ControlNo
    WHERE S.Barcode IN ({lots_in})
);

DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteHist
WHERE ProdRouteHistNo IN (
    SELECT MAX(ProdRouteHistNo) FROM SmartFactoryV2.dbo.STB_ProdRouteHist H WITH(NOLOCK)
    INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S WITH(NOLOCK) ON H.ControlNo = S.ControlNo
    WHERE S.Barcode IN ({lots_in})
);
COMMIT TRAN;"""
        elif action == "FIX_POP_CLONE":
            proposed_sql = f"""USE SmartFactoryV2;
GO
BEGIN TRAN;
-- Xóa dòng tự sinh dở dang CompleteRoute IS NULL để mở chốt POP Kiosk Aging (Author: vanduc)
DELETE W
FROM SmartFactoryV2.dbo.STB_ProdRouteWorkerHist W
INNER JOIN SmartFactoryV2.dbo.STB_ProdRouteHist H ON W.ProdRouteHistNo = H.ProdRouteHistNo
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S ON H.ControlNo = S.ControlNo
WHERE S.Barcode IN ({lots_in}) AND H.CompleteRoute IS NULL;

DELETE H
FROM SmartFactoryV2.dbo.STB_ProdRouteHist H
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S ON H.ControlNo = S.ControlNo
WHERE S.Barcode IN ({lots_in}) AND H.CompleteRoute IS NULL;
COMMIT TRAN;"""
        elif diag_data and diag_data.get("sql_hotfix") and not diag_data["sql_hotfix"].startswith("Khong can") and not diag_data["sql_hotfix"].startswith("--"):
            proposed_sql = diag_data["sql_hotfix"]
        else:
            proposed_sql = f"""USE SmartFactoryV2;
GO
-- SQL Hotfix Đề Xuất (Bọc BEGIN TRAN...COMMIT | Author: vanduc)
BEGIN TRAN;

-- TODO: Kiểm tra và chỉnh sửa điều kiện trước khi Deploy
-- SELECT * FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode IN ({lots_in});

COMMIT TRAN;"""

        return {"diag": diag_data, "proposed_sql": proposed_sql}

    def show_approval_modal(self, raw_text, classification, proposal, win=None):
        try:
            import winsound
            winsound.MessageBeep(winsound.MB_ICONEXCLAMATION)
        except Exception:
            pass

        modal = tk.Toplevel(self.root)
        modal.title("🚨 PHÊ DUYỆT YÊU CẦU MES — KỸ SƯ NGUYỄN VĂN ĐỨC")
        modal.geometry("920x720")
        modal.minsize(800, 600)
        modal.configure(bg="#1a1c23")
        modal.attributes("-topmost", True)

        h_frame = ttk.Frame(modal, style="Card.TFrame", padding=12)
        h_frame.pack(fill="x", padx=10, pady=(10, 5))
        
        is_novel = classification['verdict'] == PrecedentVerdict.ESCALATE_TO_DUC
        badge_text = "🚨 PHÁT HIỆN YÊU CẦU MỚI CHƯA CÓ TIỀN LỆ" if is_novel else "🟠 YÊU CẦU ĐANG CHỜ PHÊ DUYỆT THỦ CÔNG"
        badge_color = "#ff6b6b" if is_novel else "#ff9f43"

        lbl_badge = tk.Label(h_frame, text=badge_text, font=("Segoe UI", 12, "bold"), fg="#ffffff", bg=badge_color, padx=10, pady=4)
        lbl_badge.pack(anchor="w", pady=(0, 4))
        
        ttk.Label(h_frame, text=f"Tin nhắn gốc: \"{raw_text}\"", style="SubHeader.TLabel").pack(anchor="w")
        ttk.Label(h_frame, text=f"Mã Lots: {', '.join(classification['lots']) if classification['lots'] else 'Không có'}", style="SubHeader.TLabel").pack(anchor="w")

        body_frame = ttk.Frame(modal, style="Card.TFrame", padding=10)
        body_frame.pack(fill="both", expand=True, padx=10, pady=5)

        ttk.Label(body_frame, text="📊 KẾT QUẢ CHẨN ĐOÁN (4 DÒNG VÀNG):", style="CardTitle.TLabel").pack(anchor="w", pady=(0, 4))
        txt_diag = scrolledtext.ScrolledText(body_frame, height=9, font=("Segoe UI", 9), bg="#14151b", fg="#ecf0f1", relief="flat")
        txt_diag.pack(fill="x", pady=(0, 10))

        diag = proposal.get("diag")
        if diag:
            diag_text = (
                f"🎯 1. NGUYÊN NHÂN GỐC RỄ:\n   {diag.get('root_cause', 'N/A')}\n\n"
                f"📍 2. HIỆN TRẠNG THỰC TẾ:\n   {diag.get('data_state', 'N/A')}\n\n"
                f"🛠️ 3. CÁCH OP TỰ XỬ LÝ (WORKAROUND):\n   {diag.get('op_workaround', 'N/A')}"
            )
        else:
            diag_text = "Không có thông tin chẩn đoán lỗi đặc thù."
        txt_diag.insert(tk.END, diag_text)
        txt_diag.config(state="disabled")

        ttk.Label(body_frame, text="⚡ SCRIPT SQL HOTFIX ĐỀ XUẤT (Có thể chỉnh sửa trực tiếp trước khi Deploy):", style="CardTitle.TLabel").pack(anchor="w", pady=(0, 4))
        txt_sql = scrolledtext.ScrolledText(body_frame, font=("Consolas", 10), bg="#0f1117", fg="#54a0ff", insertbackground="#00d2d3", relief="flat")
        txt_sql.pack(fill="both", expand=True, pady=(0, 10))
        txt_sql.insert(tk.END, proposal["proposed_sql"])

        btn_bar = ttk.Frame(modal, style="Card.TFrame", padding=8)
        btn_bar.pack(fill="x", padx=10, pady=(0, 10))

        def on_approve_deploy():
            edited_sql = txt_sql.get("1.0", tk.END).strip()
            modal.destroy()
            self.execute_approved_hotfix(raw_text, classification, edited_sql, win=win)

        def on_send_workaround_only():
            modal.destroy()
            self.log("💬 Anh Đức chọn: Chỉ gửi hướng dẫn OP (Không can thiệp CSDL).")
            response = (
                f"💡 [HƯỚNG DẪN TỪ KỸ SƯ NGUYỄN VĂN ĐỨC - IT MES]\n"
                f"📋 Yêu cầu: \"{raw_text[:80]}\"\n"
                f"🛠️ Cách xử lý: Vui lòng thực hiện theo hướng dẫn:\n"
                f"{diag.get('op_workaround', 'Thao tác lại quy trình chuẩn.') if diag else 'Kiểm tra trên màn hình MES.'}"
            )
            self.finish_response(response, win=win)

        def on_reject():
            modal.destroy()
            self.log("❌ Anh Đức đã TỪ CHỐI yêu cầu này.")
            response = (
                f"⚠️ [IT MES THÔNG BÁO]\n"
                f"Yêu cầu: \"{raw_text[:80]}\" đã được Kỹ sư Nguyễn Văn Đức thẩm định.\n"
                f"Trạng thái: Từ chối thực hiện do không an toàn cho CSDL Production."
            )
            self.finish_response(response, win=win)

        tk.Button(btn_bar, text="✅ DUYỆT & DEPLOY NGAY", font=("Segoe UI", 10, "bold"), bg="#10ac84", fg="#ffffff", relief="flat", padx=18, pady=8, command=on_approve_deploy).pack(side="left", padx=5)
        tk.Button(btn_bar, text="💬 Chỉ Gửi Hướng Dẫn OP", font=("Segoe UI", 10), bg="#2e86de", fg="#ffffff", relief="flat", padx=14, pady=8, command=on_send_workaround_only).pack(side="left", padx=5)
        tk.Button(btn_bar, text="❌ Từ Chối / Hủy", font=("Segoe UI", 10), bg="#ee5253", fg="#ffffff", relief="flat", padx=14, pady=8, command=on_reject).pack(side="right", padx=5)

    def execute_approved_hotfix(self, raw_text, classification, sql_code, win=None):
        self.log("🚀 ĐANG DEPLOY HOTFIX ĐÃ ĐƯỢC PHÊ DUYỆT...")
        HOTFIX_DIR.mkdir(parents=True, exist_ok=True)
        now_tag = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        sql_filename = f"hotfix_{now_tag}_ZALO_MANUAL_APPROVED.sql"
        sql_path = HOTFIX_DIR / sql_filename

        sql_path.write_text(sql_code, encoding="utf-8")
        self.log(f"💾 Đã lưu file: {sql_filename}")

        deploy_script = TOOLS_DIR / "deploy_tool.ps1"
        cmd = f'powershell -ExecutionPolicy Bypass -File "{deploy_script}" -SqlPath "{sql_path}"'
        proc = subprocess.run(cmd, shell=True, capture_output=True, text=True, encoding="utf-8", errors="replace")

        lots_str = ", ".join(classification['lots']) if classification['lots'] else "Lot chỉ định"
        if proc.returncode == 0:
            self.log("✅ DEPLOY THÀNH CÔNG! Đã tự động tạo Pre-flight Snapshot backup.")
            response = (
                f"✅ [IT MES - ĐÃ XỬ LÝ & DEPLOY THÀNH CÔNG]\n"
                f"⏰ Thời gian: {datetime.datetime.now().strftime('%H:%M:%S %d/%m/%Y')}\n"
                f"📋 Phê duyệt bởi: Kỹ sư Nguyễn Văn Đức (vanduc)\n"
                f"📦 Danh sách Lot: {lots_str}\n"
                f"🛡️ Trạng thái: Dữ liệu đã được cập nhật an toàn trên CSDL.\n"
                f"👉 Công nhân tại xưởng có thể tiếp tục thao tác bình thường."
            )
        else:
            self.log(f"❌ Deploy thất bại: {proc.stderr[:200]}")
            response = f"❌ [LỖI KHI DEPLOY HOTFIX]: {proc.stderr[:200]}"

        self.finish_response(response, win=win)

    def finish_response(self, response_text, win=None):
        """Hoàn tất: Tự động gửi lại vào Zalo và nạp Clipboard"""
        # 1. Tự động gửi lại vào khung chat Zalo nếu có cửa sổ và bật tùy chọn
        target_win = win or self.active_zalo_win
        if target_win and self.auto_reply_zalo_var.get() and self.window_reader:
            try:
                self.log(f"📤 Đang tự động gửi câu trả lời vào nhóm Zalo ('{target_win.Name}')...")
                sent = self.window_reader.send_reply_to_zalo(target_win, response_text)
                if sent:
                    self.log("✅ ĐÃ TỰ ĐỘNG GỬI THÀNH CÔNG VÀO KHUNG CHAT ZALO!")
            except Exception as e:
                self.log(f"Lỗi khi tự gửi Zalo: {e}")

        # 2. Nạp vào Clipboard
        if self.auto_copy_var.get():
            try:
                self.last_clipboard_text = response_text.strip()
                self.root.clipboard_clear()
                self.root.clipboard_append(response_text)
                self.log("📋 Đã nạp câu trả lời vào Clipboard làm backup.")
            except Exception:
                pass

        try:
            import winsound
            winsound.MessageBeep(winsound.MB_ICONASTERISK)
        except Exception:
            pass

    def process_manual_input(self):
        text = self.txt_input.get().strip()
        if text:
            self.process_incoming_message(text, source="MANUAL_INPUT")

    # ------------------------------------------------------------------
    # LUỒNG GIÁM SÁT KÉP (DIRECT WINDOW READER + CLIPBOARD BACKUP)
    # ------------------------------------------------------------------
    def start_monitoring_thread(self):
        self.stop_event.clear()
        self.monitor_thread = threading.Thread(target=self._dual_monitor_loop, daemon=True)
        self.monitor_thread.start()

    def _dual_monitor_loop(self):
        import ctypes
        user32 = ctypes.windll.user32
        kernel32 = ctypes.windll.kernel32

        try:
            ctypes.windll.ole32.CoInitialize(None)
        except Exception:
            pass

        try:
            h_def = user32.OpenDesktopW('Default', 0, False, 0x01FF)
            if h_def:
                user32.SetThreadDesktop(h_def)
        except Exception:
            pass

        def get_clip_text():
            try:
                import uiautomation as _auto
                return _auto.GetClipboardText() or ""
            except Exception:
                try:
                    return self.root.clipboard_get() or ""
                except Exception:
                    return ""

        seen_window_messages = set()

        # Nạp lịch sử cũ ban đầu để không xử lý lại
        if self.window_reader:
            try:
                init_win = self.window_reader.select_target_window()
                if init_win:
                    msgs = self.window_reader.read_latest_messages_from_window(init_win)
                    for m in msgs:
                        seen_window_messages.add(m)
            except Exception:
                pass

        while not self.stop_event.is_set():
            try:
                if self.is_monitoring.get():
                    # 1. Quét trực tiếp TẤT CẢ các cửa sổ Zalo PC đang mở (Đa nhóm / Cửa sổ riêng)
                    if self.window_reader:
                        target_wins = self.window_reader.get_all_target_windows()
                        for win in target_wins:
                            self.active_zalo_win = win
                            new_msgs = self.window_reader.read_latest_messages_from_window(win)
                            for msg in new_msgs:
                                if msg not in seen_window_messages:
                                    seen_window_messages.add(msg)
                                    self.root.after(0, lambda m=msg, w=win: self.process_incoming_message(m, source=f"ZALO ({w.Name})", win=w))

                    # 2. Giám sát Clipboard làm kênh phụ trợ
                    current_clip = get_clip_text().strip()
                    if current_clip and current_clip != self.last_clipboard_text:
                        self.last_clipboard_text = current_clip

                        # Bỏ qua các tin nhắn do chính AI sinh ra để triệt tiêu vòng lặp vô tận
                        ai_signatures = ["🔍 [KẾT QUẢ", "✅ [IT MES", "💡 [HƯỚNG DẪN", "⚠️ [IT MES", "VINATECH MES & POP", "SQL HOTFIX"]
                        if any(sig in current_clip for sig in ai_signatures):
                            continue

                        lots = extract_lots(current_clip)
                        keywords = ["b782", "b530", "b552", "rollback", "chuyển ngày", "chuyen ngay", "kẹt", "ket", "fifo", "màn hình", "lot"]
                        if len(lots) > 0 or any(k in current_clip.lower() for k in keywords):
                            if current_clip not in seen_window_messages:
                                seen_window_messages.add(current_clip)
                                self.root.after(0, lambda t=current_clip: self.process_incoming_message(t, source="CLIPBOARD"))

                time.sleep(2.0)
            except Exception:
                time.sleep(2.0)

    def on_close(self):
        self.save_settings()
        self.stop_event.set()
        self.root.destroy()

def main():
    import traceback
    def on_tk_exception(exc_type, exc_value, exc_traceback):
        try:
            with open(LOG_FILE, "a", encoding="utf-8") as f:
                f.write(f"\n[TK_EXCEPTION {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}]:\n")
                traceback.print_exception(exc_type, exc_value, exc_traceback, file=f)
        except Exception:
            pass

    try:
        root = tk.Tk()
        root.report_callback_exception = on_tk_exception
        app = ZaloControlCenterApp(root)
        root.mainloop()
    except Exception as e:
        try:
            with open(LOG_FILE, "a", encoding="utf-8") as f:
                f.write(f"\n[FATAL_ERROR {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}]:\n")
                traceback.print_exc(file=f)
        except Exception:
            pass

if __name__ == "__main__":
    main()
