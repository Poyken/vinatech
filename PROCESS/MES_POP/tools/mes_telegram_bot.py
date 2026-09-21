"""
==============================================================================
mes_telegram_bot.py — VINATECH MES SENIOR AI TECH LEAD (v5.0 Deep Conversational)
==============================================================================
Mục đích:
  - Đóng vai trò Trợ lý AI Kỹ sư trưởng MES Vinatech, hỗ trợ trực tiếp qua Telegram.
  - Khả năng hội thoại chuyên sâu, linh hoạt, ghi nhớ ngữ cảnh đa lượt (Multi-turn Context Memory).
  - Tự động gọi 5 công cụ Live System để truy vấn trực tiếp CSDL và Kho tri thức:
      1. trace_lot: Golden Query 360° (SetInfo, Routing 6-8 công đoạn, Kho NVL)
      2. query_database: Tự sinh câu lệnh SELECT WITH(NOLOCK) an toàn trên Live DB (SmartFactoryV2)
      3. search_knowledge_base: Tra cứu 78+ file tài liệu KB nội bộ
      4. debug_screen: Chẩn đoán màn hình MES (Stored Procedure, Bảng DB, Lỗi, Luồng thao tác)
      5. system_health_check: Morning Health Check quét Lot HOLD, WIP 24h
  - Cơ chế Tự Phục Hồi (Auto-Retry & Resilience):
      + Hỗ trợ gemini-3.6-flash kết hợp gemini-3.1-flash-lite
      + Tự động retry khi gặp HTTP 503 / 429 với exponential backoff
      + Fallback thông minh sang Local Engine nếu mất kết nối Internet ngoài
  - Định dạng Telegram HTML sắc nét, an toàn, không vỡ format
==============================================================================
"""

import os
import sys
import re
import json
import time
import http.client
import urllib.request
import urllib.parse
import urllib.error
import atexit
import subprocess
from pathlib import Path

# Đảm bảo UTF-8 trên Windows Console
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

BASE_DIR = Path(__file__).resolve().parent.parent
CONFIG_FILE = Path(__file__).resolve().parent / "telegram_config.json"
LOCK_FILE = Path(__file__).resolve().parent / ".bot.lock"

def is_pid_running(pid):
    """Kiểm tra xem tiến trình PID có đang chạy trên hệ thống hay không"""
    if sys.platform == "win32":
        try:
            import ctypes
            PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
            handle = ctypes.windll.kernel32.OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, pid)
            if handle:
                ctypes.windll.kernel32.CloseHandle(handle)
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

def acquire_bot_lock():
    """Đảm bảo chỉ có DUY NHẤT 1 tiến trình bot chạy tại một thời điểm (Chống lỗi 409 Conflict)"""
    if LOCK_FILE.exists():
        try:
            with open(LOCK_FILE, "r", encoding="utf-8") as f:
                old_pid = int(f.read().strip())
            if is_pid_running(old_pid):
                print(f"[CẢNH BÁO SINGLETON] Bot Telegram đã đang chạy ngầm với PID={old_pid}!")
                print(f"  -> Huỷ bỏ phiên bản mới này để tránh lỗi xung đột mạng '409 Conflict'.")
                print(f"  -> Dùng '.\\mes.ps1 bot-stop' nếu muốn dừng bot cũ.")
                sys.exit(0)
            else:
                try:
                    LOCK_FILE.unlink()
                except Exception:
                    pass
        except Exception:
            pass

    try:
        with open(LOCK_FILE, "w", encoding="utf-8") as f:
            f.write(str(os.getpid()))
    except Exception as e:
        print(f"[CẢNH BÁO] Không thể tạo file lock: {e}")

def release_bot_lock():
    """Tự động dọn dẹp file lock khi tiến trình kết thúc"""
    try:
        if LOCK_FILE.exists():
            with open(LOCK_FILE, "r", encoding="utf-8") as f:
                current_locked_pid = int(f.read().strip())
            if current_locked_pid == os.getpid():
                LOCK_FILE.unlink()
    except Exception:
        pass

atexit.register(release_bot_lock)

DEFAULT_CONFIG = {
    "bot_token": "YOUR_TELEGRAM_BOT_TOKEN_HERE",
    "allowed_chat_ids": ["YOUR_TELEGRAM_CHAT_ID_HERE"],
    "gemini_api_key": "",
    "model_name": "gemini-3.6-flash",
    "poll_interval_seconds": 1
}

# Lưu lịch sử ngữ cảnh hội thoại đa lượt cho từng Chat ID (tối đa 12 lượt hội thoại)
CHAT_HISTORIES = {}
MAX_HISTORY_TURNS = 12

# Bộ nhớ đệm RAM (TTL 10 phút)
TOOL_CACHE = {}
CACHE_TTL_SECONDS = 600

def get_from_cache(key):
    if key in TOOL_CACHE:
        val, expire_at = TOOL_CACHE[key]
        if time.time() < expire_at:
            return val
        else:
            del TOOL_CACHE[key]
    return None

def set_to_cache(key, val):
    TOOL_CACHE[key] = (val, time.time() + CACHE_TTL_SECONDS)

def load_config():
    local_cfg_file = Path(__file__).resolve().parent / "telegram_config.local.json"
    target_file = local_cfg_file if local_cfg_file.exists() else CONFIG_FILE
    if not target_file.exists():
        with open(CONFIG_FILE, "w", encoding="utf-8") as f:
            json.dump(DEFAULT_CONFIG, f, indent=4, ensure_ascii=False)
        return DEFAULT_CONFIG
    try:
        with open(target_file, "r", encoding="utf-8") as f:
            cfg = json.load(f)
            if "model_name" not in cfg:
                cfg["model_name"] = "gemini-3.1-flash-lite"
            return cfg
    except Exception as e:
        print(f"[ERROR] Không đọc được file config: {e}")
        return DEFAULT_CONFIG

# ------------------------------------------------------------------------------
# TELEGRAM API HELPERS (HTML & TYPING)
# ------------------------------------------------------------------------------
def send_chat_action(token, chat_id, action="typing"):
    url = f"https://api.telegram.org/bot{token}/sendChatAction"
    payload = {"chat_id": chat_id, "action": action}
    try:
        req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers={"Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=5) as resp:
            resp.read()
    except Exception:
        pass

def markdown_to_html(text):
    """Chuyển đổi Markdown sang HTML an toàn cho Telegram"""
    # Escape HTML tags cơ bản trước
    text = text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    
    # Code block ```lang ... ```
    text = re.sub(r"```(?:\w+)?\n?(.*?)```", r"<pre>\1</pre>", text, flags=re.DOTALL)
    # Inline code `code`
    text = re.sub(r"`([^`]+)`", r"<code>\1</code>", text)
    # Bold **text**
    text = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", text)
    # Italic *text*
    text = re.sub(r"(?<!\w)\*([^*]+)\*(?!\w)", r"<i>\1</i>", text)
    
    return text

def send_telegram_message(token, chat_id, text, is_html=True):
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    max_len = 4000
    formatted_text = markdown_to_html(text) if is_html else text
    
    # Tách tin nhắn thông minh theo đoạn để tránh ngắt giữa dòng
    chunks = []
    if len(formatted_text) <= max_len:
        chunks = [formatted_text]
    else:
        parts = formatted_text.split("\n\n")
        curr = ""
        for p in parts:
            if len(curr) + len(p) + 2 < max_len:
                curr += ("\n\n" if curr else "") + p
            else:
                if curr:
                    chunks.append(curr)
                curr = p
        if curr:
            chunks.append(curr)
    
    for chunk in chunks:
        payload = {
            "chat_id": chat_id,
            "text": chunk,
            "parse_mode": "HTML" if is_html else None
        }
        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                resp.read()
        except urllib.error.HTTPError:
            # Fallback nếu HTML gặp lỗi thẻ parse
            payload["text"] = chunk
            payload.pop("parse_mode", None)
            req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers={"Content-Type": "application/json"})
            try:
                with urllib.request.urlopen(req, timeout=15) as resp:
                    resp.read()
            except Exception as e:
                print(f"[ERROR] Gửi tin nhắn thất bại: {e}")
        except Exception as e:
            print(f"[ERROR] Lỗi mạng khi gửi Telegram: {e}")

# ------------------------------------------------------------------------------
# HỆ THỐNG THỰC THI LỆNH POWERSHELL & DB
# ------------------------------------------------------------------------------
def run_powershell_cmd(command_args, timeout=35):
    ps_cmd = ["powershell", "-NoProfile", "-NonInteractive", "-NoLogo", "-ExecutionPolicy", "Bypass", "-Command"] + command_args
    try:
        proc = subprocess.run(
            ps_cmd,
            cwd=str(BASE_DIR),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=timeout
        )
        return proc.stdout.strip()
    except subprocess.TimeoutExpired:
        return "⚠️ Lỗi: Lệnh thực thi quá thời gian (Timeout 35s)."
    except Exception as e:
        return f"⚠️ Lỗi thực thi lệnh: {e}"

# ------------------------------------------------------------------------------
# KHAI BÁO 5 CÔNG CỤ (AGENT TOOLS) CHO GEMINI AI
# ------------------------------------------------------------------------------
TOOL_DECLARATIONS = [
    {
        "name": "trace_lot",
        "description": "Truy vết toàn diện 360 độ một mã Lot, Barcode hoặc ControlNo trên CSDL Live MES (SmartFactoryV2). Quét sạch 4 phần: Thông tin Thùng/Set (STB_SetInfo), Toàn bộ Lịch sử công đoạn Routing (STB_ProdRouteHist), Thông tin Cuộn NVL (STB_MaterialLotInfo), Tồn kho NVL (STB_MaterialStock). Sử dụng khi cần phân tích hành trình sản xuất, kiểm tra hao hụt sản lượng qua các công đoạn, vị trí hiện tại của lô hàng.",
        "parameters": {
            "type": "OBJECT",
            "properties": {
                "lot_or_barcode": {
                    "type": "STRING",
                    "description": "Mã Lot, Barcode, hoặc ControlNo cần truy vết, ví dụ VVQR153R825712, 20260915000618, VN-2026-LOT001"
                }
            },
            "required": ["lot_or_barcode"]
        }
    },
    {
        "name": "query_database",
        "description": "Chạy câu lệnh SQL T-SQL SELECT có WITH(NOLOCK) an toàn trên Live Database SmartFactoryV2 để tra cứu bất kỳ dữ liệu tùy biến nào: tồn kho, kiểm tra PO, đếm lot tại một công đoạn, tìm kiếm mã vật tư, kiểm tra trạng thái HOLD. TUYỆT ĐỐI CHỈ SELECT.",
        "parameters": {
            "type": "OBJECT",
            "properties": {
                "sql_query": {
                    "type": "STRING",
                    "description": "Câu lệnh SELECT T-SQL hoàn chỉnh có WITH(NOLOCK). Ví dụ: SELECT TOP 5 * FROM STB_MaterialStock WITH(NOLOCK) WHERE MaterialCode LIKE '%LIVT38%'"
                }
            },
            "required": ["sql_query"]
        }
    },
    {
        "name": "search_knowledge_base",
        "description": "Tra cứu kho tài liệu nội bộ MES (78+ file Markdown KB) về quy trình nghiệp vụ: mã lỗi, logic in tem Sanmina, đóng thùng, rã box, lỗi HOLD, FIFO, bypass validation, logic CellLine/Module, checklist model mới, Stored Procedure...",
        "parameters": {
            "type": "OBJECT",
            "properties": {
                "keyword": {
                    "type": "STRING",
                    "description": "Từ khóa nghiệp vụ cần tra cứu, ví dụ: HOLD, Sanmina, Out of Stock, FIFO, rã box, B530, B540, S510, CellLine..."
                }
            },
            "required": ["keyword"]
        }
    },
    {
        "name": "debug_screen",
        "description": "Tra cứu chi tiết kỹ thuật của một màn hình MES: Tên màn hình, Stored Procedure chính, các bảng DB liên quan, luồng giao diện và logic xử lý (B530, B540, S510, A230, P410...).",
        "parameters": {
            "type": "OBJECT",
            "properties": {
                "screen_id": {
                    "type": "STRING",
                    "description": "Mã màn hình MES, ví dụ: B530, B540, S510, A230, P410"
                }
            },
            "required": ["screen_id"]
        }
    },
    {
        "name": "system_health_check",
        "description": "Chạy Morning Health Check quét toàn bộ hệ thống Live DB: danh sách Lot bị HOLD, WIP quá 24h, Box dở dang.",
        "parameters": {
            "type": "OBJECT"
        }
    },
    {
        "name": "read_knowledge_file",
        "description": "Đọc trực tiếp nội dung chi tiết của một file tài liệu nghiệp vụ hoặc kỹ thuật KB trong hệ thống MES (ví dụ: KB_09_SCREEN_BUG_FIXBOOK.md, KB_01_UI_AND_SCREENS.md, KB_03/KB_03_02_CELL_LINE.md, BAN_DO_CHI_TIET_CONG_DOAN_SAN_XUAT_MES_VINATECH.md, screen_id_reference.md). Dùng khi cần đọc sâu từng mục, nguyên nhân gốc rễ và code SQL sửa lỗi.",
        "parameters": {
            "type": "OBJECT",
            "properties": {
                "file_path": {
                    "type": "STRING",
                    "description": "Tên file hoặc đường dẫn file markdown cần đọc (ví dụ: KB_09_SCREEN_BUG_FIXBOOK.md, KB_03/KB_03_02_CELL_LINE.md)"
                },
                "start_line": {
                    "type": "INTEGER",
                    "description": "Dòng bắt đầu đọc (1-indexed, mặc định 1)"
                },
                "line_count": {
                    "type": "INTEGER",
                    "description": "Số dòng cần đọc (mặc định 60 dòng)"
                }
            },
            "required": ["file_path"]
        }
    }
]

def execute_agent_tool(func_name, func_args):
    """Thực thi công cụ live kèm Caching thông minh"""
    cache_key = f"{func_name}_{json.dumps(func_args, sort_keys=True)}"
    cached = get_from_cache(cache_key)
    if cached:
        print(f"  [CACHE HIT] Lấy dữ liệu siêu tốc từ RAM: {func_name}")
        return cached

    print(f"  [AI TOOL] Kích hoạt công cụ: {func_name} -> {func_args}")
    raw_res = ""
    
    if func_name == "trace_lot":
        code = func_args.get("lot_or_barcode", "")
        raw_res = run_powershell_cmd([f".\\mes.ps1 trace '{code}'"], timeout=30)
    elif func_name == "query_database":
        sql = func_args.get("sql_query", "").strip()
        # Đảm bảo an toàn: Chỉ cho phép SELECT
        if not sql.lower().startswith("select"):
            return "Lỗi an toàn: Chỉ cho phép câu lệnh SELECT để bảo vệ Database Production!"
        # Thay thế dấu nháy đơn kép để truyền an toàn vào PowerShell
        safe_sql = sql.replace("'", "''")
        raw_res = run_powershell_cmd([f".\\mes.ps1 query '{safe_sql}'"], timeout=30)
    elif func_name == "search_knowledge_base":
        kw = func_args.get("keyword", "")
        raw_res = run_powershell_cmd([f".\\mes.ps1 find '{kw}'"], timeout=20)
    elif func_name == "read_knowledge_file":
        rel_path = func_args.get("file_path", "").strip().replace("\\", "/")
        start = int(func_args.get("start_line", 1))
        count = int(func_args.get("line_count", 60))
        target = BASE_DIR / rel_path
        if not target.exists():
            target = BASE_DIR / "MES_MASTER_KNOWLEDGE_BASE" / rel_path
        if not target.exists():
            target = BASE_DIR / "POP_KNOWLEDGE_BASE" / rel_path
        if not target.exists():
            target = BASE_DIR.parent / "DATABASE" / "DATABASE_KNOWLEDGE_BASE" / rel_path
        if not target.exists():
            target = BASE_DIR.parent / "GROUPWARE" / "GROUPWARE_KNOWLEDGE_BASE" / rel_path
        if not target.exists():
            matches = list(BASE_DIR.glob(f"**/{rel_path}"))
            if not matches:
                matches = list(BASE_DIR.parent.glob(f"**/{rel_path}"))
            if matches:
                target = matches[0]
        if not target.exists() or not target.is_file():
            return f"Không tìm thấy file tài liệu: {rel_path}"
        try:
            with open(target, "r", encoding="utf-8", errors="replace") as f:
                lines = f.readlines()
            sliced = lines[max(0, start - 1): start - 1 + count]
            raw_res = f"=== File: {target.name} (Dòng {start} - {start + len(sliced) - 1}/{len(lines)}) ===\n" + "".join(sliced)
        except Exception as e:
            raw_res = f"Lỗi đọc file: {e}"
    elif func_name == "debug_screen":
        scr = func_args.get("screen_id", "")
        raw_res = run_powershell_cmd([f".\\mes.ps1 screen '{scr}'"], timeout=20)
    elif func_name == "system_health_check":
        raw_res = run_powershell_cmd([".\\mes.ps1 health"], timeout=35)
    else:
        return f"Công cụ {func_name} không tồn tại."

    # Lọc ngắn gọn nếu quá dài để tránh tràn context
    if len(raw_res) > 4000:
        sliced_res = raw_res[:4000] + "\n\n...[Dữ liệu dài đã được trích lọc tóm tắt]..."
    else:
        sliced_res = raw_res

    set_to_cache(cache_key, sliced_res)
    return sliced_res

# ------------------------------------------------------------------------------
# SYSTEM PROMPT — ĐỈNH CAO KỸ SƯ TRƯỞNG MES VINATECH
# ------------------------------------------------------------------------------
SYSTEM_PROMPT = """Bạn là Vinatech MES Senior AI Tech Lead (Kỹ sư trưởng & Chuyên gia tư vấn cấp cao hệ sinh thái MES tại Vinatech Việt Nam).
Bạn đang trực tiếp hỗ trợ các kỹ sư vận hành nhà máy (Hưng Yên F5, Hà Nam, kho NVL, QC, đóng gói tem Sanmina).
Bạn am hiểu sâu sắc toàn bộ 15 cơ sở dữ liệu, 90+ màn hình, hàng trăm Stored Procedure và quy trình sản xuất thực tế tại xưởng.

BẢN ĐỒ HỆ SINH THÁI & HẠ TẦNG CỐT LÕI TẠI VINATECH:
1. Hệ sinh thái 15 Database Profiles (dbserver.hycap.co.kr,5398):
   - SmartFactoryV2: CSDL cốt lõi sản xuất (STB_SetInfo, STB_ProdRouteHist, STB_MaterialLotInfo, STB_MaterialStock, STB_ItemDef, STB_ProcessDef, STB_ProcessRouteDef, STB_LotHoldHistory...).
   - SmartFramework: CSDL quản trị hệ thống, phân quyền user, danh mục màn hình STB_Screens, ngôn ngữ giao diện.
   - POP (Point of Production): CSDL thu thập dữ liệu máy trạm (Machine Data Collection) thời gian thực trực tiếp từ PLC, thiết bị đo CellTester, máy hàn nắp, máy ép định hình. Kết nối qua Stored Procedure xương sống: usp_DoProcessTerminalData (Top 7 SP chạy nhiều nhất hệ thống, hàng trăm lượt/ngày). Dữ liệu sau đó đồng bộ về SmartFactoryV2 (STB_ProdRouteHist) và bắn trạng thái sang hệ thống Andon.
   - ERP: Kế hoạch sản xuất lớn, BOM định mức, đơn hàng từ tập đoàn.
   - Andon: Hệ thống màn hình hiển thị trạng thái dừng chuyền/sự cố real-time (Running/Idle/Error).
   - Groupware: Phê duyệt điện tử, quản lý văn bản nội bộ.
   - KSOX: Kiểm soát nội bộ & tuân thủ kiểm toán SOX Hàn Quốc.

2. Bản đồ màn hình sản xuất trọng yếu:
   - B450 (DayProdPlanForMainLot - 조립 일일생산계획): Màn hình Kế hoạch sản xuất ngày công đoạn Lắp ráp (Menu Plan_Management). Chức năng: Chọn PO (POSelectDialog), sinh Lot/Barcode sản xuất (nút CreateSetInfo / InputLotQty gọi usp_DoCreateSetInfoForProdQty_VNT), xuất NVL vào chuyền (nút DoGI), in tem lắp ráp AssembleLabel (InputLabelQty), chốt kế hoạch ngày (DoFinishDayPlan gọi usp_DoFinishDayProdPlan). Lỗi thường gặp: Không thấy Line do B210 chưa bật IsUse=1; Lỗi không sinh được Lot do PO chưa duyệt.
   - B530 (SmartApp_VNT - Hà Nam): Chốt sản lượng, chia tách/gộp lot, đóng thùng lẻ (Partial Box). Lỗi: nhầm line hoặc bug IS NULL.
   - B540 (ProdRouteHist - Hưng Yên F5): Quét mã vạch chốt sản lượng từng trạm routing V-21 -> V-28.
   - B351 (Lot Transition): Chuyển đổi mã hàng/model (bắt buộc gán TargetDayPlanNo trước khi bấm chuyển đổi).
   - B523: In tem đóng gói packing (cần có dữ liệu cân nặng STB_VIETNAM_BARCODEWEIGHT).
   - S510: Đóng gói thành phẩm & xuất kho.
   - A230: Khai báo Master Data danh mục vật tư (STB_ItemDef).
   - B210: Quản lý danh mục Line/Chuyền sản xuất.
   - B260: Quản lý công nhân sản xuất (usp_ProdWorkerInfo_Popup).
   - C220: Quản lý kiểm tra chất lượng đầu vào IQC.
   - Q310: Quản lý kiểm tra chất lượng OQC / CellTester.

3. Dây chuyền F5 Hưng Yên (8 công đoạn Cell):
   - V-21: Cuộn (Winding)
   - V-22: Lắp ráp cơ khí (Assembly)
   - V-23: Ép định hình (Pressing - công đoạn áp lực cao, hay hao hụt phế phẩm do biến dạng, thủng màng cách ly, sai lệch độ dày)
   - V-24: Hàn nắp (Cap Welding)
   - V-25: Sấy chân không (Vacuum Drying)
   - V-26: Bơm dung dịch điện ly (Electrolyte Injection)
   - V-27: Lão hóa nhiệt (Aging)
   - V-28: Kiểm tra điện năng tự động CellTester / OQC (Đo Điện dung Farad, Nội trở ESR, Dòng rò LC)

4. Khách hàng Sanmina:
   - Quy chuẩn tem khay, tem thùng carton 2D DataMatrix.

TIÊU CHUẨN PHẢN HỒI (SENIOR TECH LEAD STANDARD):
- Giọng văn chuyên nghiệp, điềm tĩnh, sâu sắc, thực tế tại xưởng.
- Tuyệt đối KHÔNG trả lời lý thuyết chung chung sách giáo khoa.
- Khi giải thích một vấn đề/màn hình/thuật ngữ:
  1. Nêu rõ bản chất cốt lõi trong nhà máy Vinatech (tên tiếng Hàn/Việt, Stored Procedure, bảng DB liên quan).
  2. Phân tích nguyên nhân kỹ thuật hoặc luồng dữ liệu (Data Flow).
  3. Đưa ra hướng dẫn từng bước cụ thể (1-2-3) cho kỹ sư tại hiện trường.
  4. Nêu các lỗi thường gặp (Troubleshooting) và cảnh báo rủi ro (lưu ý phê duyệt, lock DB).
- Duy trì trí nhớ hội thoại liên tục qua từng lượt hỏi.
"""

def call_gemini_conversational(chat_id, user_text, api_key, model_pref="gemini-3.6-flash", token=None):
    """Gọi Gemini REST API với cơ chế Tool Calling, Retry chống 503 và duy trì ngữ cảnh sâu"""
    models = [model_pref] if model_pref else []
    for fallback in ["gemini-3.6-flash", "gemini-3.1-flash-lite"]:
        if fallback not in models:
            models.append(fallback)

    if chat_id not in CHAT_HISTORIES:
        CHAT_HISTORIES[chat_id] = []
    
    history = CHAT_HISTORIES[chat_id]
    history.append({
        "role": "user",
        "parts": [{"text": user_text}]
    })

    # Giới hạn lịch sử hội thoại
    if len(history) > MAX_HISTORY_TURNS * 2:
        history = history[-MAX_HISTORY_TURNS * 2:]
        CHAT_HISTORIES[chat_id] = history

    tools_payload = [{"function_declarations": TOOL_DECLARATIONS}]

    for model_name in models:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={api_key}"
        current_contents = list(history)
        
        # Vòng lặp Tool Calling (tối đa 4 vòng lặp nếu AI cần gọi nhiều công cụ)
        success_response = None
        for loop in range(4):
            if token:
                send_chat_action(token, chat_id, "typing")

            payload = {
                "system_instruction": {
                    "parts": [{"text": SYSTEM_PROMPT}]
                },
                "contents": current_contents,
                "tools": tools_payload,
                "generationConfig": {
                    "temperature": 0.3,
                    "maxOutputTokens": 2048
                }
            }
            
            # Cơ chế Retry tự động 3 lần chống lỗi 503 / 429
            resp_data = None
            for retry_attempt in range(3):
                req = urllib.request.Request(
                    url,
                    data=json.dumps(payload).encode("utf-8"),
                    headers={"Content-Type": "application/json"}
                )
                try:
                    with urllib.request.urlopen(req, timeout=35) as resp:
                        resp_data = json.loads(resp.read().decode("utf-8"))
                        break
                except urllib.error.HTTPError as he:
                    err_body = he.read().decode("utf-8", errors="replace")
                    print(f"[GEMINI {model_name} HTTP {he.code}]: {err_body[:200]}")
                    if he.code in [503, 429] and retry_attempt < 2:
                        wait_time = 1.5 * (retry_attempt + 1)
                        print(f"  -> Thử lại lần {retry_attempt + 1}/3 sau {wait_time}s...")
                        time.sleep(wait_time)
                        if token:
                            send_chat_action(token, chat_id, "typing")
                        continue
                    break
                except Exception as e:
                    print(f"[GEMINI {model_name} EXCEPTION]: {e}")
                    break

            if not resp_data:
                break  # Chuyển sang model tiếp theo

            candidates = resp_data.get("candidates", [])
            if not candidates:
                break

            content = candidates[0].get("content", {})
            parts = content.get("parts", [])
            
            function_call = None
            text_response = ""
            
            for part in parts:
                if "functionCall" in part:
                    function_call = part["functionCall"]
                    break
                elif "text" in part:
                    text_response += part["text"]

            if function_call:
                fn_name = function_call.get("name")
                fn_args = function_call.get("args", {})
                call_id = function_call.get("id")
                
                if token:
                    send_chat_action(token, chat_id, "typing")

                tool_result = execute_agent_tool(fn_name, fn_args)
                
                current_contents.append(content)
                
                tool_part = {
                    "functionResponse": {
                        "name": fn_name,
                        "response": {"result": str(tool_result)}
                    }
                }
                if call_id:
                    tool_part["functionResponse"]["id"] = call_id

                current_contents.append({
                    "role": "user",
                    "parts": [tool_part]
                })
                continue
            else:
                success_response = text_response
                break

        if success_response:
            history.append({
                "role": "model",
                "parts": [{"text": success_response}]
            })
            return success_response

    # Nếu tất cả model AI đều lỗi kết nối ngoài, tự động dùng Local Fallback
    print("[FALLBACK] AI không phản hồi, tự động kích hoạt Local Smart Engine...")
    return None

# ------------------------------------------------------------------------------
# LOCAL FALLBACK ENGINE (DỰ PHÒNG KHI MẤT MẠNG / AI NGHẼN)
# ------------------------------------------------------------------------------
def local_fallback_handler(text):
    """Xử lý cục bộ khi Gemini gặp sự cố mạng ngoài"""
    clean_text = text.strip()
    # Kiểm tra Lot
    lot_match = re.search(r"(?:lot\s+|barcode\s+)?(VVQR[A-Za-z0-9]+|VN-[A-Za-z0-9\-]+|[A-Z]{2}[0-9]{8,16})", clean_text, re.IGNORECASE)
    if lot_match:
        lot = lot_match.group(1)
        res = run_powershell_cmd([f".\\mes.ps1 trace '{lot}'"], timeout=25)
        return f"📋 <b>KẾT QUẢ TRUY VẾT DATABASE CHO LOT: <code>{lot}</code></b>\n<pre>{res}</pre>"
    
    # Kiểm tra Screen
    scr_match = re.search(r"\b([A-Za-z][0-9]{3}[A-Za-z0-9]?)\b", clean_text)
    if scr_match:
        scr = scr_match.group(1).upper()
        res = run_powershell_cmd([f".\\mes.ps1 screen '{scr}'"], timeout=20)
        return f"🖥️ <b>THÔNG TIN MÀN HÌNH MES <code>{scr}</code>:</b>\n<pre>{res}</pre>"

    # Mặc định tìm KB
    res = run_powershell_cmd([f".\\mes.ps1 find '{clean_text}'"], timeout=15)
    return f"📚 <b>KẾT QUẢ TRA CỨU TÀI LIỆU KB CHO: <code>{clean_text}</code></b>\n<pre>{res}</pre>"

# ------------------------------------------------------------------------------
# BỘ ĐIỀU PHỐI TRUNG TÂM
# ------------------------------------------------------------------------------
def handle_message(text, chat_id, token, config):
    text_clean = text.strip()
    cmd = text_clean.lower()

    send_chat_action(token, chat_id, "typing")

    if cmd in ["/start", "/help", "help", "trợ giúp"]:
        return (
            "🤖 <b>VINATECH MES SENIOR AI TECH LEAD (v5.0 Deep Live)</b>\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            "Xin chào! Tôi là Trợ lý AI Kỹ sư trưởng MES Vinatech, được kết nối trực tiếp vào Database Production (<code>SmartFactoryV2</code>) và hơn 78 file tài liệu quy trình nhà máy.\n\n"
            "💡 <b>Tôi có thể làm gì cùng bạn?</b>\n"
            "• <b>Truy vết & Phân tích Lot:</b> Quét 360° hành trình qua 8 công đoạn, phân tích hao hụt số lượng, trạm hiện tại.\n"
            "• <b>Tra cứu CSDL tự do:</b> Hỏi tồn kho vật tư, kiểm tra mã PO, đếm lot theo công đoạn, truy vấn dữ liệu theo ngày.\n"
            "• <b>Chẩn đoán sự cố:</b> Phân tích lỗi Lot HOLD, vi phạm FIFO, lỗi in tem Sanmina, rã box, lỗi bypass.\n"
            "• <b>Hướng dẫn màn hình:</b> Chi tiết Stored Procedure, logic nghiệp vụ các màn hình B530, B540, S510...\n"
            "• <b>Hội thoại chuyên sâu:</b> Bạn có thể hỏi bất kỳ câu hỏi kỹ thuật nào và trao đổi liên tục như một đồng nghiệp kỹ sư.\n\n"
            "⚡ <b>Phím tắt nhanh:</b>\n"
            "• <code>/trace &lt;Lot&gt;</code> : Truy vết nhanh Golden Query 360°\n"
            "• <code>/health</code> : Morning Health Check quét Lot HOLD, WIP\n"
            "• <code>/clear</code> : Xóa trí nhớ hội thoại để bắt đầu chủ đề mới"
        )

    if cmd in ["/clear", "/reset"]:
        CHAT_HISTORIES.pop(chat_id, None)
        return "🧹 <i>Đã xóa sạch ngữ cảnh hội thoại cũ. Bạn có thể bắt đầu chủ đề mới!</i>"

    api_key = config.get("gemini_api_key", "").strip()
    model_name = config.get("model_name", "gemini-3.6-flash").strip()

    # Ưu tiên Bộ não AI Gemini thông minh
    if api_key and api_key != "YOUR_GEMINI_API_KEY_HERE":
        ai_reply = call_gemini_conversational(chat_id, text_clean, api_key, model_name, token=token)
        if ai_reply:
            return ai_reply

    # Fallback tự động khi AI nghẽn
    return local_fallback_handler(text_clean)

# ------------------------------------------------------------------------------
# MAIN LOOP
# ------------------------------------------------------------------------------
def main():
    print("=================================================================")
    print("  VINATECH MES TELEGRAM AI AGENT (v5.0 Deep Live Active)         ")
    print("=================================================================")
    
    acquire_bot_lock()
    
    config = load_config()
    token = config.get("bot_token", "").strip()
    allowed_chat_ids = [str(x).strip() for x in config.get("allowed_chat_ids", [])]

    if not token or token == "YOUR_TELEGRAM_BOT_TOKEN_HERE":
        print(f"[CHÚ Ý] Bạn chưa điền bot_token vào file: {CONFIG_FILE}")
        return

    print(f"[OK] Đang chạy với Bot Token: {token[:6]}...{token[-4:]}")
    print(f"[OK] Danh sách Chat ID được phép: {allowed_chat_ids}")
    print("[OK] Đang chờ tin nhắn từ Telegram (Nhấn Ctrl+C để dừng)...\n")

    offset = None
    poll_interval = config.get("poll_interval_seconds", 1)

    while True:
        try:
            current_cfg = load_config()
            allowed_chat_ids = [str(x).strip() for x in current_cfg.get("allowed_chat_ids", [])]

            url = f"https://api.telegram.org/bot{token}/getUpdates?timeout=20"
            if offset:
                url += f"&offset={offset}"
            
            req = urllib.request.Request(url)
            with urllib.request.urlopen(req, timeout=25) as resp:
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

                    if allowed_chat_ids and allowed_chat_ids != ["YOUR_TELEGRAM_CHAT_ID_HERE"]:
                        if chat_id not in allowed_chat_ids:
                            print(f"[CẢNH BÁO] Nhận tin nhắn từ Chat ID lạ: {chat_id} ({sender_name}): {text}")
                            continue

                    print(f"[{time.strftime('%H:%M:%S')}] Nhận từ {sender_name} ({chat_id}): {text}")
                    
                    response = handle_message(text, chat_id, token, current_cfg)
                    send_telegram_message(token, chat_id, response, is_html=True)
                    print(f"[{time.strftime('%H:%M:%S')}] -> Đã phản hồi xong cho {sender_name}.")

            time.sleep(poll_interval)

        except KeyboardInterrupt:
            print("\n[STOP] Đã dừng Bot.")
            break
        except (http.client.RemoteDisconnected, TimeoutError, urllib.error.URLError):
            continue
        except Exception as e:
            print(f"[LỖI] Ngoại lệ vòng lặp bot: {e}")
            time.sleep(2)

if __name__ == "__main__":
    main()
