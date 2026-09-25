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
import base64
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
USER_STATES = {}

# Bộ nhớ đệm RAM (TTL 10 phút)
TOOL_CACHE = {}
CACHE_TTL_SECONDS = 600

# Config cache (reload mỗi 60s thay vì mỗi vòng polling)
_config_cache = None
_config_last_load = 0
CONFIG_RELOAD_INTERVAL = 60

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

def download_telegram_photo(token, file_id):
    """Tải ảnh từ Telegram API về dạng bytes để gửi sang Gemini Vision"""
    try:
        url = f"https://api.telegram.org/bot{token}/getFile?file_id={file_id}"
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode("utf-8"))
        file_path = data.get("result", {}).get("file_path")
        if not file_path:
            return None
        file_url = f"https://api.telegram.org/file/bot{token}/{file_path}"
        req_file = urllib.request.Request(file_url)
        with urllib.request.urlopen(req_file, timeout=20) as resp_file:
            return resp_file.read()
    except Exception as e:
        print(f"[ERROR] Không tải được ảnh Telegram: {e}")
        return None

MAIN_KEYBOARD = {
    "keyboard": [
        ["🔍 Truy Vết POP 360°", "⛓️ Huyết Mạch PO/Lot"],
        ["🎯 Chẩn Đoán Sự Cố", "🏥 Sức Khỏe MES"],
        ["🏭 Kiểm Toán POP", "🔓 Giải Phóng Máy"],
        ["🔒 Khóa & Deadlock", "💰 Đơn Giá B598"]
    ],
    "resize_keyboard": True,
    "is_persistent": True
}

def send_telegram_message(token, chat_id, text, is_html=True, reply_markup=None):
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    max_len = 4000
    formatted_text = markdown_to_html(text) if is_html else text
    if reply_markup is None:
        reply_markup = MAIN_KEYBOARD
    
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
            "parse_mode": "HTML" if is_html else None,
            "reply_markup": reply_markup
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
        "name": "pop_trace",
        "description": "Truy vết siêu tốc 360 độ hiện trường POP Kiosk và đồng bộ MES (Single Round-Trip). Quét đồng thời cả 2 bảng MongoToMesPerformance và STB_ProdRouteHist, đối chiếu chứng từ kiểm tra PQC, chi tiết lỗi phế phẩm Defect, kiểm tra máy gán trên Line VINA_EQUIPMENT_MAPPING, và nhật ký thao tác công nhân VINA_POP_ACTION_LOG. Dùng khi Kiosk báo lỗi, kẹt công đoạn, lệch máy, hay không chốt được sản lượng.",
        "parameters": {
            "type": "OBJECT",
            "properties": {
                "lot_or_barcode": {
                    "type": "STRING",
                    "description": "Mã Lot hoặc Barcode trên tem Kiosk, ví dụ: VVQR193R072730, VVQR143R060619"
                }
            },
            "required": ["lot_or_barcode"]
        }
    },
    {
        "name": "pop_readiness",
        "description": "Kiểm toán 8 điều kiện sẵn sàng cắt WinForm và chạy 100% Web POP Kiosk cho một dây chuyền (Whitelist MAC, Factory config, Sub/Add prod mode, 10 slot NVL, master máy móc, mẫu tem nhãn, sync).",
        "parameters": {
            "type": "OBJECT",
            "properties": {
                "line_code": {
                    "type": "STRING",
                    "description": "Mã dây chuyền, ví dụ: VVC-01, VVC-11, VVHYC-09 (để trống nếu muốn quét toàn bộ)"
                }
            }
        }
    },
    {
        "name": "release_machines",
        "description": "Tự động giải phóng các máy móc bị kẹt trạng thái ACTIVE trong VINA_EQUIPMENT_MAPPING do công nhân ca trước quên bấm Hủy gán (POP-ERR-20).",
        "parameters": {
            "type": "OBJECT",
            "properties": {
                "line_code": {
                    "type": "STRING",
                    "description": "Mã dây chuyền cần giải phóng máy (để trống nếu muốn quét toàn bộ nhà máy)"
                }
            }
        }
    },
    {
        "name": "generate_hotfix",
        "description": "Sinh template SQL Hotfix chuẩn Vinatech bọc BEGIN TRAN...ROLLBACK và có pre-flight snapshot backup.",
        "parameters": {
            "type": "OBJECT",
            "properties": {
                "issue_name": {
                    "type": "STRING",
                    "description": "Tên sự cố cần xử lý"
                },
                "template_type": {
                    "type": "STRING",
                    "description": "Loại template: swap-machine (đổi máy Kiosk RULE 20), force-stock (tạo tồn kho cuộn), clone-defect (clone mã phế), pqc (sửa công đoạn PQC), thick (độ dày màng >= 100), packing-id (sinh mã PK in tem), b552 (điện cực), b782 (chuyển ngày 10am), rollback (rollback công đoạn)"
                }
            },
            "required": ["issue_name", "template_type"]
        }
    },
    {
        "name": "gw_ksys_trace",
        "description": "Truy vết chứng từ Groupware (PO, đề nghị thanh toán, kế hoạch ngày) hoặc phân hệ K-System Ace ERP.",
        "parameters": {
            "type": "OBJECT",
            "properties": {
                "system": {
                    "type": "STRING",
                    "description": "Hệ thống: 'GW' (Groupware) hoặc 'KSYS' (K-System Ace)"
                },
                "code": {
                    "type": "STRING",
                    "description": "Mã PO, mã văn bản, mã Lot hoặc mã vật tư cần tra cứu"
                }
            },
            "required": ["system", "code"]
        }
    },
    {
        "name": "lineage_trace",
        "description": "Truy vết huyết mạch dữ liệu liên hệ thống (PO -> Kế hoạch ngày -> Barcode ControlNo -> Kho NVL -> Kiosk POP -> Groupware).",
        "parameters": {
            "type": "OBJECT",
            "properties": {
                "target_code": {
                    "type": "STRING",
                    "description": "Mã PO hoặc mã Lot/Barcode cần truy vết huyết mạch"
                }
            },
            "required": ["target_code"]
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
    },
    {
        "name": "inspect_db_locks",
        "description": "Kiểm tra real-time các khóa blocking, page U-locks, và deadlocks trên 15 CSDL SmartFactoryV2/VINATECH_POP, kèm danh sách truy vấn chạy lâu >= 3 giây.",
        "parameters": {
            "type": "OBJECT",
            "properties": {
                "profile": {
                    "type": "STRING",
                    "description": "Tên profile database (mặc định SmartFactoryV2)"
                }
            }
        }
    },
    {
        "name": "inspect_b598_price",
        "description": "Tra cứu nhanh đơn giá USD và công thức chia cân nặng hardcode bên trong Stored Procedure usp_vn_showproductionerror cho màn hình báo phế B598.",
        "parameters": {
            "type": "OBJECT",
            "properties": {
                "material_code": {
                    "type": "STRING",
                    "description": "Mã vật tư NVL cần soi đơn giá (ví dụ GCMDPT-601, GCSN00-004)"
                }
            }
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
    elif func_name == "pop_trace":
        code = func_args.get("lot_or_barcode", "")
        raw_res = run_powershell_cmd([f".\\mes.ps1 pop-trace '{code}'"], timeout=30)
    elif func_name == "pop_readiness":
        line = func_args.get("line_code", "").strip()
        if line:
            raw_res = run_powershell_cmd([f".\\mes.ps1 pop-readiness -Line '{line}'"], timeout=30)
        else:
            raw_res = run_powershell_cmd([".\\mes.ps1 pop-readiness"], timeout=35)
    elif func_name == "release_machines":
        line = func_args.get("line_code", "").strip()
        if line:
            raw_res = run_powershell_cmd([f".\\mes.ps1 release-machines -Target '{line}' -Force"], timeout=30)
        else:
            raw_res = run_powershell_cmd([".\\mes.ps1 release-machines"], timeout=30)
    elif func_name == "generate_hotfix":
        name = func_args.get("issue_name", "HOTFIX")
        tpl = func_args.get("template_type", "")
        raw_res = run_powershell_cmd([f".\\mes.ps1 new-fix '{name}' -Template '{tpl}'"], timeout=25)
    elif func_name == "gw_ksys_trace":
        sys_type = func_args.get("system", "GW").upper()
        code = func_args.get("code", "")
        if sys_type == "KSYS":
            raw_res = run_powershell_cmd([f".\\ksys.ps1 trace '{code}'"], timeout=30)
        else:
            raw_res = run_powershell_cmd([f".\\gw.ps1 trace '{code}'"], timeout=30)
    elif func_name == "lineage_trace":
        code = func_args.get("target_code", "")
        raw_res = run_powershell_cmd([f".\\mes.ps1 lineage '{code}'"], timeout=30)
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
    elif func_name == "inspect_db_locks":
        prof = func_args.get("profile", "").strip()
        cmd_str = f".\\mes.ps1 locks -Profile '{prof}'" if prof else ".\\mes.ps1 locks"
        raw_res = run_powershell_cmd([cmd_str], timeout=25)
    elif func_name == "inspect_b598_price":
        mat = func_args.get("material_code", "").strip()
        cmd_str = f".\\mes.ps1 b598-price '{mat}'" if mat else ".\\mes.ps1 b598-price"
        raw_res = run_powershell_cmd([cmd_str], timeout=20)
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

def call_gemini_conversational(chat_id, user_text, api_key, model_pref="gemini-flash-latest", token=None, image_bytes=None):
    """Gọi Gemini REST API với Multimodal Vision, Tool Calling, Retry chống 503 và duy trì ngữ cảnh sâu"""
    models = [model_pref] if model_pref else []
    for fallback in ["gemini-flash-latest", "gemini-3.1-flash-lite", "gemini-flash-lite-latest", "gemini-3.8-flash"]:
        if fallback not in models:
            models.append(fallback)

    if chat_id not in CHAT_HISTORIES:
        CHAT_HISTORIES[chat_id] = []
    
    history = CHAT_HISTORIES[chat_id]

    user_parts = []
    if image_bytes:
        user_parts.append({
            "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64.b64encode(image_bytes).decode("utf-8")
            }
        })
    if user_text:
        user_parts.append({"text": user_text})
    elif image_bytes:
        user_parts.append({"text": "Phân tích ảnh chụp màn hình lỗi MES/POP này: Trích xuất các mã Lot, mã Line, mã máy, mã lỗi và triệu chứng hiển thị. Dùng các công cụ (như pop_trace, trace_lot, search_knowledge_base) để chẩn đoán nguyên nhân gốc và đưa ra hướng dẫn 4 Dòng Vàng (Nguyên nhân, Hiện trạng, OP tự xử lý, SQL IT)."})

    # Giới hạn lịch sử hội thoại
    if len(history) > MAX_HISTORY_TURNS * 2:
        history = history[-MAX_HISTORY_TURNS * 2:]
        CHAT_HISTORIES[chat_id] = history

    tools_payload = [{"function_declarations": TOOL_DECLARATIONS}]

    for model_name in models:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={api_key}"
        current_contents = list(history) + [{"role": "user", "parts": user_parts}]
        
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
                    "temperature": 0.2,
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
            saved_user_text = user_text if user_text else "[Ảnh chụp sự cố hiện trường OP]"
            history.append({
                "role": "user",
                "parts": [{"text": saved_user_text}]
            })
            history.append({
                "role": "model",
                "parts": [{"text": success_response}]
            })
            return success_response

    # Nếu tất cả model AI đều lỗi kết nối ngoài, tự động dùng Local Fallback
    print("[FALLBACK] AI không phản hồi, tự động kích hoạt Local Smart Engine...")
    return None

# ------------------------------------------------------------------------------
# LOCAL FALLBACK ENGINE & 1-SHOT DIAGNOSTIC (TỰ ĐỘNG CHẨN ĐOÁN LỖI)
# ------------------------------------------------------------------------------
def format_diagnostic_html(diag):
    """Định dạng kết quả chẩn đoán 4 Dòng Vàng sang Telegram HTML chuẩn"""
    import html as html_lib
    html = "⚡ <b>VINATECH MES CHẨN ĐOÁN 1-SHOT</b>\n"
    html += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    esc_rc = html_lib.escape(diag.get('root_cause', 'N/A'))
    esc_ds = html_lib.escape(diag.get('data_state', 'N/A'))
    html += f"🎯 <b>1. NGUYÊN NHÂN GỐC:</b>\n{esc_rc}\n\n"
    html += f"📍 <b>2. HIỆN TRẠNG DỮ LIỆU:</b>\n{esc_ds}\n\n"
    html += "🛠️ <b>3. HƯỚNG DẪN OP TỰ XỬ LÝ (UI):</b>\n"
    for line in diag.get("op_workaround", "").splitlines():
        html += f"• {html_lib.escape(line)}\n"
    esc_sql = html_lib.escape(diag.get('sql_hotfix', '-- N/A'))
    html += f"\n⚡ <b>4. SQL HOTFIX (IT CAN THIỆP):</b>\n<pre>{esc_sql}</pre>"
    return html

def local_fallback_handler(text):
    """Xử lý cục bộ khi Gemini gặp sự cố mạng ngoài hoặc yêu cầu chẩn đoán"""
    clean_text = text.strip()
    try:
        from mes_diagnose import diagnose
        diag = diagnose(clean_text)
        if diag.get("matched_rule") or diag.get("l1_screen") or diag.get("entities", {}).get("lots"):
            return format_diagnostic_html(diag)
    except Exception as e:
        print(f"[FALLBACK DIAGNOSE ERROR]: {e}")

    # Kiểm tra Lot trực tiếp
    lot_match = re.search(r"(?:lot\s+|barcode\s+)?(VV[A-Za-z0-9]+|VE\d{6}-\d{3}|SP\d{6}-\d{3}|PK[A-Za-z0-9]+)", clean_text, re.IGNORECASE)
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
def handle_message(text, chat_id, token, config, image_bytes=None):
    text_clean = text.strip() if text else ""
    cmd = text_clean.lower()
    api_key = config.get("gemini_api_key", "").strip()
    model_name = config.get("model_name", "gemini-flash-latest").strip()

    send_chat_action(token, chat_id, "typing")

    # 0. NẾU CÓ ẢNH ĐÍNH KÈM (MULTIMODAL AI VISION ANALYSIS)
    if image_bytes:
        if api_key:
            ai_res = call_gemini_conversational(chat_id, text_clean, api_key, model_pref=model_name, token=token, image_bytes=image_bytes)
            if ai_res:
                return ai_res
        return (
            "⚠️ <b>ĐÃ NHẬN ẢNH SỰ CỐ TỪ BẠN</b>\n\n"
            "Tuy nhiên Gemini Vision hiện chưa kết nối được (vui lòng kiểm tra lại mạng/API key). "
            "Bạn có thể paste mã Lot (VD: <code>VVQR153R060615</code>) hoặc mã lỗi dạng text để bot chẩn đoán siêu tốc ngay lập tức!"
        )

    # 1. Trợ giúp & Giới thiệu / Lời chào
    if cmd in ["/start", "/help", "help", "trợ giúp", "chào", "xin chào", "chào bạn", "hello", "hi"]:
        return (
            "🤖 <b>VINATECH MES & POP MOBILE WAR-ROOM (v5.5 Full-Power)</b>\n"
            "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
            "Xin chào anh Đức! Hệ thống giám sát, chẩn đoán và xử lý sự cố MES-POP sẵn sàng 24/7.\n\n"
            "📸 <b>NHẬN DIỆN ẢNH SỰ CỐ OP TỨC THÌ:</b>\n"
            "• Gửi thẳng ảnh chụp màn hình Kiosk POP / lỗi MES vào bot ➔ AI Vision tự đọc mã lỗi, quét Live DB và trả lời 4 Dòng Vàng!\n\n"
            "👇 <b>CÁC NÚT TÁC VỤ 1 CHẠM TRÊN BÀN PHÍM:</b>\n"
            "• <code>🔍 Truy Vết POP 360°</code> : Quét cả 2 bảng Mongo + STB_ProdRouteHist\n"
            "• <code>⛓️ Huyết Mạch PO/Lot</code> : Dòng chảy PO ➔ Kho ➔ MES ➔ POP\n"
            "• <code>🎯 Chẩn Đoán Sự Cố</code> : Chuẩn đoán 1-Shot 4 Dòng Vàng\n"
            "• <code>🏥 Sức Khỏe MES</code> : Morning Health Check quét Lot HOLD/WIP\n"
            "• <code>🏭 Kiểm Toán POP</code> : Kiểm tra 8 tiêu chí cắt WinForm\n"
            "• <code>🔓 Giải Phóng Máy</code> : Tự động Clear máy kẹt ACTIVE trên Line\n\n"
            "💡 <b>Hoặc gõ bất kỳ câu hỏi/thắc mắc nào để trao đổi như với Antigravity IDE!</b>"
        )

    if cmd in ["/clear", "/reset"]:
        CHAT_HISTORIES.pop(chat_id, None)
        USER_STATES.pop(chat_id, None)
        return "🧹 <i>Đã làm mới trạng thái hội thoại. Bạn có thể bắt đầu phiên làm việc mới!</i>"

    # 2. Xử lý các nút bấm Keyboard tương tác (Interactive Buttons)
    if "truy vết pop" in cmd or cmd == "🔍 truy vết pop 360°":
        USER_STATES[chat_id] = "WAITING_FOR_POP_TRACE"
        return "🔍 <b>BẠN MUỐN TRUY VẾT POP CHO LOT/BARCODE NÀO?</b>\n\nVui lòng paste mã Lot hoặc Barcode vào đây (Ví dụ: <code>VVQR193R072730</code>):"

    if "truy vết 360" in cmd or cmd == "🔍 truy vết 360° lot":
        USER_STATES[chat_id] = "WAITING_FOR_LOT"
        return "🔍 <b>BẠN MUỐN TRUY VẾT LOT NÀO?</b>\n\nVui lòng paste mã Lot, Barcode hoặc mã Thùng vào đây (Ví dụ: <code>VVQR153R060615</code>):"

    if "huyết mạch" in cmd or cmd == "⛓️ huyết mạch po/lot":
        USER_STATES[chat_id] = "WAITING_FOR_LINEAGE"
        return "⛓️ <b>TRUY VẾT HUYẾT MẠCH LIÊN HỆ THỐNG (PO ➔ Kho ➔ MES ➔ POP)</b>\n\nVui lòng nhập mã Lệnh SX (PO) hoặc mã Lot (Ví dụ: <code>260828000015</code> hoặc <code>VVQR153R060615</code>):"

    if "chẩn đoán" in cmd or cmd == "🎯 chẩn đoán sự cố":
        USER_STATES[chat_id] = "WAITING_FOR_DIAGNOSE"
        return "🎯 <b>CHẨN ĐOÁN SỰ CỐ NHÀ MÁY (4 DÒNG VÀNG)</b>\n\nVui lòng paste câu báo lỗi của công nhân, mã màn hình (B530, B552, C121...) hoặc gửi ảnh chụp sự cố vào đây:"

    if "sức khỏe" in cmd or cmd == "🏥 sức khỏe mes" or cmd in ["/health", "health"]:
        res = run_powershell_cmd([".\\mes.ps1 health"], timeout=30)
        return f"🏥 <b>KẾT QUẢ SỨC KHỎE HỆ THỐNG MES:</b>\n<pre>{res}</pre>"

    if "kiểm toán" in cmd or cmd == "🏭 kiểm toán pop" or cmd in ["/readiness", "readiness"]:
        res = run_powershell_cmd([".\\mes.ps1 pop-readiness"], timeout=35)
        return f"🏭 <b>KẾT QUẢ KIỂM TOÁN SẴN SÀNG POP WEB 31 CHUYỀN:</b>\n<pre>{res}</pre>"

    if "giải phóng máy" in cmd or cmd == "🔓 giải phóng máy" or cmd in ["/release", "release"]:
        res = run_powershell_cmd([".\\mes.ps1 release-machines"], timeout=30)
        return f"🔓 <b>KẾT QUẢ GIẢI PHÓNG MÁY KẸT TRÊN LINE:</b>\n<pre>{res}</pre>"

    if "khóa" in cmd or cmd == "🔒 khóa & deadlock" or cmd in ["/locks", "locks"]:
        res = run_powershell_cmd([".\\mes.ps1 locks"], timeout=25)
        return f"🔒 <b>KẾT QUẢ KIỂM TRA KHÓA & NGHẼN CSDL:</b>\n<pre>{res}</pre>"

    if "đơn giá b598" in cmd or cmd == "💰 đơn giá b598":
        USER_STATES[chat_id] = "WAITING_FOR_B598"
        return "💰 <b>TRA CỨU ĐƠN GIÁ & CÂN NẶNG BÁO PHẾ B598:</b>\n\nVui lòng nhập mã vật tư (ví dụ <code>GCMDPT-601</code> hoặc gõ <code>ALL</code> để xem toàn bộ):"

    if "báo cáo tuần" in cmd or cmd == "📊 báo cáo tuần it" or cmd in ["/report", "report"]:
        res = run_powershell_cmd([".\\mes.ps1 weekly-report"], timeout=25)
        return f"📊 <b>KẾT QUẢ XUẤT BÁO CÁO TUẦN IT (EA TEAM):</b>\n<pre>{res}</pre>\n<i>File CSV đã được cập nhật tại Desktop/thanks_and_ojt_reports.</i>"

    # 3. Xử lý trạng thái người dùng đang chờ nhập (State Machine)
    if chat_id in USER_STATES:
        st = USER_STATES.pop(chat_id)
        if st == "WAITING_FOR_POP_TRACE":
            res = run_powershell_cmd([f".\\mes.ps1 pop-trace '{text_clean}'"], timeout=30)
            return f"🏭 <b>KẾT QUẢ TRUY VẾT POP KIOSK: <code>{text_clean}</code></b>\n<pre>{res}</pre>"
        elif st == "WAITING_FOR_LOT":
            res = run_powershell_cmd([f".\\mes.ps1 trace '{text_clean}'"], timeout=30)
            return f"📋 <b>KẾT QUẢ TRUY VẾT 360° CHO: <code>{text_clean}</code></b>\n<pre>{res}</pre>"
        elif st == "WAITING_FOR_LINEAGE":
            res = run_powershell_cmd([f".\\mes.ps1 lineage '{text_clean}'"], timeout=30)
            return f"⛓️ <b>KẾT QUẢ HUYẾT MẠCH LIÊN HỆ THỐNG CHO: <code>{text_clean}</code></b>\n<pre>{res}</pre>"
        elif st == "WAITING_FOR_DIAGNOSE":
            try:
                from mes_diagnose import diagnose
                diag = diagnose(text_clean)
                return format_diagnostic_html(diag)
            except Exception as e:
                return f"❌ <b>LỖI CHẨN ĐOÁN:</b> {e}"
        elif st == "WAITING_FOR_B598":
            mat = "" if text_clean.upper() == "ALL" else text_clean
            cmd_str = f".\\mes.ps1 b598-price '{mat}'" if mat else ".\\mes.ps1 b598-price"
            res = run_powershell_cmd([cmd_str], timeout=20)
            return f"💰 <b>KẾT QUẢ SOI ĐƠN GIÁ B598 CHO <code>{text_clean}</code>:</b>\n<pre>{res}</pre>"

    # 4. Lệnh Fast-path có tiền tố (/trace, /pop, /lineage, /diagnose, /fix, /locks, /b598)
    if cmd.startswith("/trace ") or cmd.startswith("trace "):
        lot = re.sub(r"^/(trace)\s+|^trace\s+", "", text_clean, flags=re.IGNORECASE).strip()
        res = run_powershell_cmd([f".\\mes.ps1 trace '{lot}'"], timeout=25)
        return f"📋 <b>KẾT QUẢ TRUY VẾT 360° CHO: <code>{lot}</code></b>\n<pre>{res}</pre>"

    if cmd.startswith("/pop ") or cmd.startswith("pop ") or cmd.startswith("/pop-trace "):
        lot = re.sub(r"^/(pop|pop-trace)\s+|^pop\s+", "", text_clean, flags=re.IGNORECASE).strip()
        res = run_powershell_cmd([f".\\mes.ps1 pop-trace '{lot}'"], timeout=30)
        return f"🏭 <b>KẾT QUẢ TRUY VẾT POP KIOSK CHO: <code>{lot}</code></b>\n<pre>{res}</pre>"

    if cmd.startswith("/lineage ") or cmd.startswith("lineage "):
        target_val = re.sub(r"^/(lineage)\s+|^lineage\s+", "", text_clean, flags=re.IGNORECASE).strip()
        res = run_powershell_cmd([f".\\mes.ps1 lineage '{target_val}'"], timeout=25)
        return f"⛓️ <b>KẾT QUẢ HUYẾT MẠCH 3 TRỤ CỘT CHO: <code>{target_val}</code></b>\n<pre>{res}</pre>"

    if cmd.startswith("/diagnose ") or cmd.startswith("/diag "):
        q = re.sub(r"^/(diagnose|diag)\s+", "", text_clean, flags=re.IGNORECASE).strip()
        try:
            from mes_diagnose import diagnose
            diag = diagnose(q)
            return format_diagnostic_html(diag)
        except Exception as e:
            return f"❌ <b>LỖI CHẨN ĐOÁN:</b> {e}"

    if cmd.startswith("/fix ") or cmd.startswith("fix "):
        parts = text_clean.split(maxsplit=2)
        issue_name = parts[1] if len(parts) > 1 else "HOTFIX"
        tpl = parts[2] if len(parts) > 2 else ""
        res = run_powershell_cmd([f".\\mes.ps1 new-fix '{issue_name}' -Template '{tpl}'"], timeout=25)
        return f"🛠️ <b>KẾT QUẢ SINH TEMPLATE HOTFIX:</b>\n<pre>{res}</pre>"

    if cmd.startswith("/locks") or cmd.startswith("locks"):
        res = run_powershell_cmd([".\\mes.ps1 locks"], timeout=25)
        return f"🔒 <b>KẾT QUẢ KIỂM TRA KHÓA & NGHẼN CSDL:</b>\n<pre>{res}</pre>"

    if cmd.startswith("/b598") or cmd.startswith("b598"):
        mat = re.sub(r"^/(b598)\s*|^b598\s*", "", text_clean, flags=re.IGNORECASE).strip()
        cmd_str = f".\\mes.ps1 b598-price '{mat}'" if mat else ".\\mes.ps1 b598-price"
        res = run_powershell_cmd([cmd_str], timeout=20)
        return f"💰 <b>KẾT QUẢ SOI ĐƠN GIÁ B598 CHO <code>{mat if mat else 'TOÀN BỘ'}</code>:</b>\n<pre>{res}</pre>"

    # 5. FAST-PATH PATTERN RECOGNITION (< 0.1s - 1.2s, Không mất token)
    # 5.1 Nhận diện mã Lot/Barcode (VV..., VE..., SP..., PK...)
    lot_match = re.search(r"^\s*(VV[A-Za-z0-9]+|VE\d{6}-\d{3}|SP\d{6}-\d{3}|PK[A-Za-z0-9]+)\s*$", text_clean, re.IGNORECASE)
    if lot_match:
        found_lot = lot_match.group(1)
        res = run_powershell_cmd([f".\\mes.ps1 pop-trace '{found_lot}'"], timeout=25)
        return f"🏭 <b>KẾT QUẢ TRUY VẾT POP & MES CHO: <code>{found_lot}</code></b>\n<pre>{res}</pre>"

    # 5.2 Nhận diện mã PO (2608..., 1808..., 12 chữ số)
    po_match = re.search(r"^\s*(2[0-9]{11}|1[0-9]{11})\s*$", text_clean)
    if po_match:
        found_po = po_match.group(1)
        res = run_powershell_cmd([f".\\mes.ps1 lineage '{found_po}'"], timeout=25)
        return f"⛓️ <b>KẾT QUẢ HUYẾT MẠCH CHO PO: <code>{found_po}</code></b>\n<pre>{res}</pre>"

    # 5.3 Nhận diện mã màn hình MES đứng một mình (B530, C121, S510...)
    scr_match = re.search(r"^\s*([A-Za-z][0-9]{3}[A-Za-z0-9]?)\s*$", text_clean)
    if scr_match:
        scr = scr_match.group(1).upper()
        res = run_powershell_cmd([f".\\mes.ps1 screen '{scr}'"], timeout=20)
        return f"🖥️ <b>THÔNG TIN MÀN HÌNH MES <code>{scr}</code>:</b>\n<pre>{res}</pre>"

    # 5.4 Nhận diện lỗi đã biết trong 1-Shot Local Diagnostic (mes_diagnose.py)
    try:
        from mes_diagnose import diagnose
        diag = diagnose(text_clean)
        if diag.get("matched_rule"):
            return format_diagnostic_html(diag)
    except Exception:
        pass

    # 6. CONVERSATIONAL AI TECH LEAD (Gemini Flash-Latest + 11 Live Tools)
    if api_key:
        ai_resp = call_gemini_conversational(chat_id, text_clean, api_key, model_pref=model_name, token=token)
        if ai_resp:
            return ai_resp

    # 7. Fallback cuối cùng: Tra cứu tài liệu KB nội bộ
    return local_fallback_handler(text_clean)

def main():
    print("=================================================================")
    print("  VINATECH MES TELEGRAM AI AGENT (v5.5 Full-Power Live Active)   ")
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
            current_cfg = config
            now_ts = time.time()
            if now_ts - _config_last_load > CONFIG_RELOAD_INTERVAL:
                current_cfg = load_config()
                _config_cache = current_cfg
                _config_last_load = now_ts
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
                    caption = msg.get("caption", "")
                    photo = msg.get("photo")
                    image_bytes = None

                    if allowed_chat_ids and allowed_chat_ids != ["YOUR_TELEGRAM_CHAT_ID_HERE"]:
                        if chat_id not in allowed_chat_ids:
                            print(f"[CẢNH BÁO] Nhận tin nhắn từ Chat ID lạ: {chat_id} ({sender_name}): {text}")
                            continue

                    if photo:
                        largest_photo = photo[-1]
                        file_id = largest_photo.get("file_id")
                        print(f"[{time.strftime('%H:%M:%S')}] Đang tải ảnh lỗi OP từ {sender_name}...")
                        image_bytes = download_telegram_photo(token, file_id)
                        if caption and not text:
                            text = caption

                    print(f"[{time.strftime('%H:%M:%S')}] Nhận từ {sender_name} ({chat_id}): {text} (Ảnh: {'CÓ' if image_bytes else 'KHÔNG'})")
                    
                    response = handle_message(text, chat_id, token, current_cfg, image_bytes=image_bytes)
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
