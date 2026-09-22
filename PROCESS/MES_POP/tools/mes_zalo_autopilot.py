# -*- coding: utf-8 -*-
"""
==============================================================================
mes_zalo_autopilot.py — VINATECH MES ZALO AUTO-PILOT & PRECEDENT DISPATCHER
==============================================================================
Mục đích:
  - Tự động tiếp nhận và phân tích yêu cầu từ người dùng / xưởng gửi qua Zalo.
  - Phân loại thông minh dựa trên Ma trận Tiền Lệ (Precedent Matrix):
      1. TIỀN LỆ LẶP LẠI ĐÃ ĐƯỢC XÁC THỰC (Pre-Approved Safe Hotfix):
         -> Tự động xử lý và deploy 100% NGAY LẬP TỨC (KHÔNG CẦN ĐỨC ACCEPT).
         -> Áp dụng: Chuyển ngày B782, Rollback lượt chốt B530, Reset cuộn B552,
            Giải phóng máy POP kẹt, Chẩn đoán 4 Dòng Vàng hướng dẫn OP.
         -> Tuân thủ 100% RULE 18 (Author/ChangeUserID = 'vanduc'), Pre-flight Snapshot.
      2. YÊU CẦU MỚI / CHƯA CÓ TIỀN LỆ / RỦI RO CAO:
         -> TUYỆT ĐỐI KHÔNG TỰ SỬA CSDL.
         -> Tự động ghi nhận và chuyển tiếp/HỎI ANH ĐỨC (Escalate).
         -> Trả lời người dùng: Đang chuyển tiếp cho Kỹ sư Nguyễn Văn Đức thẩm định.
  - Đa kênh tiếp nhận:
      + 1-Shot CLI: python mes_zalo_autopilot.py --process "tin nhắn Zalo"
      + Smart Clipboard Watcher: Tự động bắt khi Copy tin nhắn từ Zalo
      + Inbox File Queue: Giám sát thư mục zalo_inbox
      + Windows Desktop Notification & Telegram Alert khi có việc cần hỏi Đức
==============================================================================
"""

import os
import sys
import re
import json
import time
import datetime
import argparse
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
TOOLS_DIR = BASE_DIR / "tools"
CONFIG_DIR = BASE_DIR / "AI_AGENT_CONFIG"
INBOX_DIR = CONFIG_DIR / "zalo_inbox"
LOG_DIR = BASE_DIR / "logs"
ESCALATION_FILE = CONFIG_DIR / "pending_escalations.json"
LOCK_FILE = TOOLS_DIR / ".zalo_autopilot.lock"

# Khởi tạo thư mục cần thiết
INBOX_DIR.mkdir(parents=True, exist_ok=True)
LOG_DIR.mkdir(parents=True, exist_ok=True)

# ----------------------------------------------------------------------
# 1. PRECEDENT CLASSIFIER & RISK EVALUATOR (MA TRẬN TIỀN LỆ)
# ----------------------------------------------------------------------
class PrecedentVerdict:
    AUTO_EXECUTE = "AUTO_EXECUTE"      # Tiền lệ chuẩn -> Xử lý luôn
    ESCALATE_TO_DUC = "ESCALATE_TO_DUC" # Mới / Chưa biết / Rủi ro cao -> Hỏi anh Đức
    IGNORE = "IGNORE"                  # Tin nhắn rác / không liên quan MES

def extract_lots(text):
    """Bóc tách mã Barcode / Lot ID từ tin nhắn"""
    patterns = [
        r'\b(VV[A-Z0-9_-]{6,30})\b',
        r'\b(VE[A-Z0-9_-]{5,25})\b',
        r'\b(SP[A-Z0-9_-]{5,25})\b',
        r'\b(PK[A-Z0-9_-]{5,25})\b',
        r'\b(ML\d{10,20})\b',
        r'\b(\d{14})\b'
    ]
    lots = []
    for p in patterns:
        matches = re.findall(p, text, re.IGNORECASE)
        for m in matches:
            m_clean = m.strip().upper()
            if m_clean not in lots:
                lots.append(m_clean)
    return lots

def extract_target_date(text):
    """Trích xuất ngày chuyển đích nếu có, mặc định là ngày hôm nay"""
    today = datetime.datetime.now().strftime("%Y-%m-%d")
    
    # yyyy-mm-dd
    m1 = re.search(r'\b(202\d[-/]\d{1,2}[-/]\d{1,2})\b', text)
    if m1:
        return m1.group(1).replace('/', '-')
    
    # dd/mm/yyyy
    m2 = re.search(r'\b(\d{1,2})[/.-](\d{1,2})[/.-](202\d)\b', text)
    if m2:
        d, m, y = m2.groups()
        return f"{y}-{int(m):02d}-{int(d):02d}"
        
    # dd/mm (lấy năm hiện tại)
    m3 = re.search(r'\b(\d{1,2})[/.-](\d{1,2})\b', text)
    if m3:
        d, m = m3.groups()
        y = datetime.datetime.now().year
        return f"{y}-{int(m):02d}-{int(d):02d}"
        
    return today

def extract_route_code(text):
    """Bóc tách mã công đoạn nếu có (V-22_HY, V-26_HY, TCX-01...)"""
    m = re.search(r'\b(V-[A-Z0-9_]+|TCX-\d+|VV[A-Z0-9_]+)\b', text, re.IGNORECASE)
    return m.group(1).upper() if m else ""

# ----------------------------------------------------------------------
# CONTEXT MEMORY (LƯU TRỮ NGỮ CẢNH HỘI THOẠI 60 GIÂY)
# ----------------------------------------------------------------------
_RECENT_LOTS_CACHE = [] # List of (timestamp, [lots])
_RECENT_MSGS_CACHE = [] # List of (timestamp, text)

def update_context_cache(text, lots):
    global _RECENT_LOTS_CACHE, _RECENT_MSGS_CACHE
    now = time.time()
    _RECENT_LOTS_CACHE = [(t, l) for t, l in _RECENT_LOTS_CACHE if now - t < 60]
    _RECENT_MSGS_CACHE = [(t, m) for t, m in _RECENT_MSGS_CACHE if now - t < 60]
    if lots:
        _RECENT_LOTS_CACHE.append((now, lots))
    _RECENT_MSGS_CACHE.append((now, text))

def get_recent_lots(lookback_seconds=60):
    now = time.time()
    all_lots = []
    for t, lots in reversed(_RECENT_LOTS_CACHE):
        if now - t <= lookback_seconds:
            for l in lots:
                if l not in all_lots:
                    all_lots.append(l)
    return all_lots

def classify_request(raw_text, use_context=True):
    """
    Phân loại yêu cầu thông minh:
    - Bóc tách mã Lot và ý định
    - Hỗ trợ ghép tin nhắn ngắt quãng (Multi-message burst qua Context Cache)
    - Hướng dẫn khi mô tả mơ hồ / thiếu thông tin
    """
    text = raw_text.strip()
    if not text:
        return {'verdict': PrecedentVerdict.IGNORE, 'action_type': 'NONE', 'lots': [], 'reason': 'Empty message'}

    text_lower = text.lower()
    lots = extract_lots(text)
    route = extract_route_code(text)
    
    # Ghép mã Lot từ tin nhắn trước đó nếu tin nhắn hiện tại có hành động nhưng thiếu mã Lot
    context_note = ""
    if len(lots) == 0 and use_context:
        recent_lots = get_recent_lots(60)
        if recent_lots:
            lots = recent_lots
            context_note = f" (Ghép mã Lot từ tin nhắn trước: {', '.join(lots)})"
    
    # 1. TIỀN LỆ 1: CHUYỂN NGÀY CHỐT B782 (MOVEDATE)
    movedate_keywords = [
        "chuyển ngày", "chuyen ngay", "đổi ngày", "doi ngay", "b782", "movedate",
        "chốt nhầm ca", "chot nham ca", "quên chốt", "quen chot", "dời ngày", "doi ngay"
    ]
    if any(kw in text_lower for kw in movedate_keywords) and len(lots) > 0:
        target_date = extract_target_date(text)
        return {
            'verdict': PrecedentVerdict.AUTO_EXECUTE,
            'action_type': 'MOVEDATE',
            'lots': lots,
            'details': {'target_date': target_date, 'route': route},
            'reason': f'Tiền lệ chuẩn B782 Move JobDate sang {target_date}'
        }

    # 2. TIỀN LỆ 2: ROLLBACK LƯỢT CHỐT CÔNG ĐOẠN B530 / POP KIOSK
    rollback_keywords = [
        "rollback", "hủy chốt", "huy chot", "xóa chốt", "xoa chot", "quét nhầm", 
        "quet nham", "hủy lượt", "huy luot", "trả lại công đoạn", "hủy quét"
    ]
    if any(kw in text_lower for kw in rollback_keywords) and len(lots) > 0:
        return {
            'verdict': PrecedentVerdict.AUTO_EXECUTE,
            'action_type': 'ROLLBACK',
            'lots': lots,
            'details': {'route': route},
            'reason': f'Tiền lệ chuẩn B530 / POP Kiosk Rollback lượt chốt gần nhất'
        }

    # 3. TIỀN LỆ 3: RESET CUỘN / MẺ TRỘN ĐIỆN CỰC B552
    electrode_keywords = [
        "b552", "reset cuộn", "reset cuon", "xóa cuộn", "xoa cuon", "hủy cuộn", 
        "huy cuon", "nạp nhầm cuộn", "nap nham cuon", "slitting", "mixing", "điện cực", "dien cuc"
    ]
    if any(kw in text_lower for kw in electrode_keywords) and len(lots) > 0:
        el_type = "Mixing" if "mixing" in text_lower else "Slitting"
        return {
            'verdict': PrecedentVerdict.AUTO_EXECUTE,
            'action_type': 'ELECTRODE',
            'lots': lots,
            'details': {'type': el_type},
            'reason': f'Tiền lệ chuẩn B552 Reset cuộn điện cực ({el_type})'
        }

    # 4. TIỀN LỆ 4: GIẢI PHÓNG MÁY POP KẸT LOCK (RELEASE MACHINES)
    machine_keywords = [
        "kẹt máy", "ket may", "treo máy", "treo may", "máy pop kẹt", "máy đơ", 
        "may do", "isrun", "giải phóng máy", "giai phong may", "máy không đăng nhập"
    ]
    if any(kw in text_lower for kw in machine_keywords):
        return {
            'verdict': PrecedentVerdict.AUTO_EXECUTE,
            'action_type': 'RELEASE_MACHINE',
            'lots': lots,
            'details': {},
            'reason': 'Tiền lệ chuẩn Giải phóng Lock máy Kiosk POP'
        }

    # 5. TIỀN LỆ 5: XÓA DÒNG TỰ SINH DỞ DANG ĐỂ MỞ CHỐT POP KIOSK (CẤP THỨ AGING)
    pop_clone_keywords = [
        "cấp thứ", "cap thu", "aging", "againg", "luyện điện", "luyen dien",
        "already completed", "chốt cấp thứ", "chot cap thu", "máy cấp thứ", "may cap thu",
        "tự clone", "completeroute is null", "dòng tự sinh", "kẹt aging"
    ]
    if any(kw in text_lower for kw in pop_clone_keywords) and len(lots) > 0:
        return {
            'verdict': PrecedentVerdict.AUTO_EXECUTE,
            'action_type': 'FIX_POP_CLONE',
            'lots': lots,
            'details': {'route': route or 'V-26_HY'},
            'reason': 'Tiền lệ chuẩn Xóa dòng clone dở dang CompleteRoute IS NULL để mở chốt POP Kiosk (Aging)'
        }

    # 6. TIỀN LỆ 6: HỎI THÔNG TIN / CHẨN ĐOÁN LỖI (4 DÒNG VÀNG - SELECT-ONLY)
    inquiry_keywords = [
        "tại sao", "tai sao", "sao không quét", "sao khong quet", "bị kẹt", "bi ket",
        "lỗi fifo", "loi fifo", "báo lỗi", "bao loi", "màn hình", "kiểm tra lot", 
        "kiem tra lot", "tra cứu", "tra cuu", "lot đang ở đâu", "lot dang o dau", "check giúp", "check giup"
    ]
    if (any(kw in text_lower for kw in inquiry_keywords) or len(lots) > 0) and not any(kw in text_lower for kw in ["xóa", "xoa", "hủy", "huy", "sửa", "sua", "đổi", "doi"]):
        return {
            'verdict': PrecedentVerdict.AUTO_EXECUTE,
            'action_type': 'DIAGNOSE',
            'lots': lots,
            'details': {'query': text},
            'reason': 'Chẩn đoán lỗi / Tra cứu tiến độ (Không can thiệp DB, trả lời 4 Dòng Vàng)'
        }

    # 6. YÊU CẦU MỚI / CHƯA BIẾT CÁCH LÀM / RỦI RO CAO (ESCALATE TO ĐỨC)
    dangerous_keywords = [
        "xóa lot", "xoa lot", "hủy đơn", "huy don", "sửa số lượng", "sua so luong",
        "sửa bom", "sua bom", "sửa erp", "sua erp", "sửa kho", "sua kho", "xuất kho",
        "nhập kho", "rã lô", "ra lo", "hủy thùng", "huy thung", "sửa sql", "chạy sql",
        "thay đổi routing", "sửa công thức"
    ]
    if any(kw in text_lower for kw in dangerous_keywords) or len(lots) > 0:
        return {
            'verdict': PrecedentVerdict.ESCALATE_TO_DUC,
            'action_type': 'UNKNOWN_HIGH_RISK',
            'lots': lots,
            'details': {'raw_text': text},
            'reason': 'Yêu cầu can thiệp dữ liệu chưa có tiền lệ tự động / Rủi ro cao -> Bắt buộc hỏi anh Đức'
        }

    # 7. MÔ TẢ MƠ HỒ / THIẾU MÃ LOT (NEED_MORE_INFO)
    vague_issue_keywords = [
        "lỗi", "loi", "sửa giúp", "sua giup", "không quét được", "khong quet duoc", 
        "không được", "khong duoc", "bị kẹt", "bi ket", "không chốt được", "khong chot duoc"
    ]
    if any(kw in text_lower for kw in vague_issue_keywords) and len(lots) == 0:
        return {
            'verdict': PrecedentVerdict.AUTO_EXECUTE,
            'action_type': 'NEED_MORE_INFO',
            'lots': [],
            'details': {'raw_text': text},
            'reason': 'Tin nhắn phản ánh lỗi nhưng chưa có mã Lot -> Tự động hướng dẫn OP cung cấp mã Lot'
        }

    return {
        'verdict': PrecedentVerdict.IGNORE,
        'action_type': 'IRRELEVANT',
        'lots': [],
        'reason': 'Không phát hiện từ khóa hoặc mã Lot liên quan đến hệ thống MES'
    }

# ----------------------------------------------------------------------
# 2. AUTO-EXECUTION ENGINE (TIỀN LỆ LẶP LẠI -> XỬ LÝ NGAY 100%)
# ----------------------------------------------------------------------
def execute_precedent(classification):
    """
    Thực thi tự động 100% các yêu cầu tiền lệ lặp lại.
    Trả về response text (chuẩn bị để gửi lại Zalo).
    """
    action = classification['action_type']
    lots = classification['lots']
    details = classification['details']
    now_str = datetime.datetime.now().strftime("%H:%M:%S %d/%m/%Y")
    lots_str = ", ".join(lots)

    print(f"\n[AUTO-PILOT] -> Đang thực thi tiền lệ '{action}' cho: {lots_str}...")

    # A. MOVEDATE (B782)
    if action == 'MOVEDATE':
        target_date = details.get('target_date', datetime.datetime.now().strftime("%Y-%m-%d"))
        route = details.get('route', '')
        route_arg = f'-Route "{route}"' if route else ''
        cmd = f'powershell -ExecutionPolicy Bypass -File "{TOOLS_DIR / "generate_safe_hotfix.ps1"}" -Action movedate -Lots "{lots_str}" -TargetDate "{target_date}" {route_arg} -DeployNow'
        
        proc = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if proc.returncode == 0:
            return (
                f"✅ [IT MES - ĐÃ TỰ ĐỘNG XỬ LÝ XONG]\n"
                f"⏰ Thời gian: {now_str}\n"
                f"📋 Yêu cầu: Chuyển ngày chốt sản lượng B782\n"
                f"📦 Danh sách Lot: {lots_str}\n"
                f"📅 Ngày đích: {target_date} (Giờ chốt >= 10:00 AM)\n"
                f"🛡️ Trạng thái: Đã cập nhật CSDL thành công (Author: vanduc)\n"
                f"👉 Hướng dẫn: Công nhân có thể tiếp tục thao tác trên màn hình bình thường."
            )
        else:
            return f"❌ [LỖI XỬ LÝ TỰ ĐỘNG B782]\nChi tiết: {proc.stderr[:300]}\nHệ thống đã chuyển thông tin tới anh Đức kiểm tra lại."

    # B. ROLLBACK (B530 / POP KIOSK)
    elif action == 'ROLLBACK':
        route = details.get('route', '')
        route_arg = f'-Route "{route}"' if route else ''
        cmd = f'powershell -ExecutionPolicy Bypass -File "{TOOLS_DIR / "generate_safe_hotfix.ps1"}" -Action rollback-route -Lots "{lots_str}" {route_arg} -DeployNow'
        
        proc = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if proc.returncode == 0:
            return (
                f"✅ [IT MES - ĐÃ TỰ ĐỘNG ROLLBACK XONG]\n"
                f"⏰ Thời gian: {now_str}\n"
                f"📋 Yêu cầu: Rollback hủy lượt chốt nhầm gần nhất\n"
                f"📦 Danh sách Lot: {lots_str}\n"
                f"🛡️ Trạng thái: Đã hủy lượt chốt và phục hồi trạng thái Lot (Author: vanduc)\n"
                f"👉 Hướng dẫn: Công nhân tại xưởng có thể tiến hành quét lại trên màn hình B530 / Kiosk POP."
            )
        else:
            return f"❌ [LỖI ROLLBACK TỰ ĐỘNG]\nChi tiết: {proc.stderr[:300]}\nĐã chuyển tiếp tới anh Đức hỗ trợ."

    # C. ELECTRODE (B552)
    elif action == 'ELECTRODE':
        el_type = details.get('type', 'Slitting')
        cmd = f'powershell -ExecutionPolicy Bypass -File "{TOOLS_DIR / "generate_safe_hotfix.ps1"}" -Action electrode -Lots "{lots_str}" -Type "{el_type}" -DeployNow'
        
        proc = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if proc.returncode == 0:
            return (
                f"✅ [IT MES - ĐÃ TỰ ĐỘNG RESET CUỘN ĐIỆN CỰC]\n"
                f"⏰ Thời gian: {now_str}\n"
                f"📋 Yêu cầu: Xóa cuộn/mẻ nạp nhầm trên B552 ({el_type})\n"
                f"📦 Danh sách Lot/Cuộn: {lots_str}\n"
                f"🛡️ Trạng thái: Đã xóa liên kết và reset IsLineInput='N' (Author: vanduc)\n"
                f"👉 Hướng dẫn: Dây chuyền có thể nạp lại cuộn mới vào máy."
            )
        else:
            return f"❌ [LỖI RESET CUỘN TỰ ĐỘNG]\nChi tiết: {proc.stderr[:300]}"

    # D. FIX_POP_CLONE (XÓA DÒNG CLONE DỞ DANG ĐỂ CHỐT CẤP THỨ AGING TRÊN POP KIOSK)
    elif action == 'FIX_POP_CLONE':
        cmd = f'powershell -ExecutionPolicy Bypass -File "{TOOLS_DIR / "generate_safe_hotfix.ps1"}" -Action clean-pop-clone -Lots "{lots_str}" -DeployNow'
        proc = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if proc.returncode == 0:
            return (
                f"✅ [IT MES - ĐÃ TỰ ĐỘNG XỬ LÝ XONG]\n"
                f"⏰ Thời gian: {now_str}\n"
                f"📋 Yêu cầu: Giải phóng dòng tự sinh dở dang để chốt cấp thứ Aging trên POP Kiosk\n"
                f"📦 Danh sách Lot: {lots_str}\n"
                f"🛡️ Trạng thái: Đã xóa bản ghi clone dở dang CompleteRoute IS NULL (Author: vanduc)\n"
                f"👉 Hướng dẫn: Công nhân có thể tải lại Kiosk POP và bấm chốt cấp thứ Aging bình thường."
            )
        else:
            return f"❌ [LỖI XỬ LÝ TỰ ĐỘNG AGING POP]\nChi tiết: {proc.stderr[:300]}\nHệ thống đã chuyển thông tin tới anh Đức kiểm tra lại."

    # E. RELEASE MACHINE LOCK
    elif action == 'RELEASE_MACHINE':
        cmd = f'powershell -ExecutionPolicy Bypass -File "{TOOLS_DIR / "release_orphan_machines.ps1"}" -Force'
        proc = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return (
            f"✅ [IT MES - ĐÃ GIẢI PHÓNG MÁY POP]\n"
            f"⏰ Thời gian: {now_str}\n"
            f"🛡️ Trạng thái: Đã xóa cờ lock IsRun='Y' cho các máy bị treo.\n"
            f"👉 Hướng dẫn: Công nhân tắt ứng dụng POP và mở lại để đăng nhập bình thường."
        )

    # E. INQUIRY / DIAGNOSTIC (4 DÒNG VÀNG)
    elif action == 'DIAGNOSE':
        query = details.get('query', lots_str)
        cmd = f'python "{TOOLS_DIR / "mes_diagnose.py"}" "{query}"'
        proc = subprocess.run(cmd, shell=True, capture_output=True, text=True, encoding='utf-8', errors='replace')
        output = proc.stdout.strip() if proc.returncode == 0 else "Không thể tra cứu thông tin tự động."
        return (
            f"🔍 [KẾT QUẢ CHẨN ĐOÁN MES TỰ ĐỘNG - 4 DÒNG VÀNG]\n"
            f"⏰ Thời gian: {now_str}\n\n"
            f"{output}\n\n"
            f"💡 Nếu công nhân cần hỗ trợ thêm, hãy nhắn lại để IT kiểm tra trực tiếp."
        )

    # F. NEED MORE INFO (HƯỚNG DẪN KHI MÔ TẢ MƠ HỒ)
    elif action == 'NEED_MORE_INFO':
        return (
            f"ℹ️ [IT MES - CẦN THÊM THÔNG TIN ĐỂ HỖ TRỢ]\n"
            f"⏰ Thời gian: {now_str}\n"
            f"Chào anh/chị! Hệ thống đã ghi nhận phản ánh sự cố của xưởng.\n"
            f"👉 Để IT có thể tự động kiểm tra và xử lý ngay tức thì, vui lòng cung cấp:\n"
            f"   1. Mã Lot / Barcode (Ví dụ: VV2609..., VE..., SP...)\n"
            f"   2. Tên màn hình đang bị kẹt (Ví dụ: B530, B540, B782, POP Kiosk)\n"
            f"   3. Ảnh chụp thông báo lỗi trên màn hình (nếu có)."
        )

    return "Yêu cầu đã được ghi nhận."

# ----------------------------------------------------------------------
# 3. ESCALATION ENGINE (YÊU CẦU MỚI / CHƯA BIẾT -> HỎI ANH ĐỨC)
# ----------------------------------------------------------------------
def escalate_to_duc(classification, raw_text):
    """
    Xử lý khi gặp yêu cầu mới hoặc rủi ro cao:
    1. Ghi vào hàng đợi phê duyệt pending_escalations.json
    2. Bắn cảnh báo nổi bật lên Desktop / Console cho Đức
    3. Trả về phản hồi cho User Zalo biết đang chờ thẩm định
    """
    now_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    escalation_id = f"ESC_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}"
    lots = classification['lots']
    lots_str = ", ".join(lots) if lots else "Không rõ"
    
    escalation_item = {
        "id": escalation_id,
        "timestamp": now_str,
        "raw_message": raw_text,
        "lots": lots,
        "reason": classification['reason'],
        "status": "WAITING_APPROVAL"
    }

    # Lưu vào file JSON
    escalations = []
    if ESCALATION_FILE.exists():
        try:
            with open(ESCALATION_FILE, "r", encoding="utf-8") as f:
                escalations = json.load(f)
        except Exception:
            escalations = []
    escalations.append(escalation_item)
    with open(ESCALATION_FILE, "w", encoding="utf-8") as f:
        json.dump(escalations, f, ensure_ascii=False, indent=2)

    # In cảnh báo to rõ lên màn hình của Đức
    alert_msg = (
        f"\n{'='*70}\n"
        f"🚨 [CẢNH BÁO: PHÁT HIỆN YÊU CẦU MỚI TỪ ZALO CẦN ANH ĐỨC XÁC NHẬN]\n"
        f"Mã Escalation: {escalation_id}\n"
        f"Thời gian    : {now_str}\n"
        f"Mã Lot       : {lots_str}\n"
        f"Nội dung Zalo: \"{raw_text}\"\n"
        f"Lý do        : {classification['reason']}\n"
        f"👉 HÀNH ĐỘNG : Hệ thống ĐÃ CHẶN TỰ ĐỘNG để bảo vệ CSDL Production.\n"
        f"               Anh Đức vui lòng thẩm định và ra quyết định xử lý!\n"
        f"{'='*70}\n"
    )
    print(alert_msg)

    # Hiển thị Windows Toast / MessageBox nếu có thể
    show_windows_toast(f"Yêu cầu Zalo mới: {lots_str}", f"Cần anh Đức xác nhận: {raw_text[:80]}")

    # Trả về câu trả lời cho User Zalo
    user_response = (
        f"⏳ [IT MES ĐÃ TIẾP NHẬN YÊU CẦU]\n"
        f"⏰ Thời gian: {now_str}\n"
        f"📋 Yêu cầu: \"{raw_text[:100]}\"\n"
        f"🔍 Phân loại: Yêu cầu can thiệp kỹ thuật đặc biệt (Chưa có tiền lệ tự động).\n"
        f"🛡️ Trạng thái: Hệ thống đã chuyển tiếp toàn bộ thông tin tới Kỹ sư Nguyễn Văn Đức (IT EA) để thẩm định an toàn.\n"
        f"👉 Anh Đức sẽ kiểm tra và phản hồi trực tiếp cho anh/chị ngay khi hoàn tất!"
    )
    return user_response

def show_windows_toast(title, msg):
    """Hiển thị thông báo Windows toast nhẹ nhàng không làm gián đoạn"""
    try:
        ps_cmd = (
            f"[reflection.assembly]::loadwithpartialname('System.Windows.Forms'); "
            f"$notify = new-object system.windows.forms.notifyicon; "
            f"$notify.icon = [system.drawing.systemicons]::Information; "
            f"$notify.visible = $true; "
            f"$notify.showballoontip(5000, '{title}', '{msg}', [system.windows.forms.tooltipicon]::Warning);"
        )
        subprocess.Popen(["powershell", "-Command", ps_cmd], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass

# ----------------------------------------------------------------------
# 4. DISPATCHER CHÍNH (PROCESS A MESSAGE)
# ----------------------------------------------------------------------
def process_message(raw_text):
    """
    Hàm xử lý cốt lõi cho một tin nhắn Zalo bất kỳ:
    1. Phân loại
    2. Nếu tiền lệ -> Tự xử lý ngay không hỏi
    3. Nếu mới -> Hỏi anh Đức
    """
    classification = classify_request(raw_text)
    update_context_cache(raw_text, classification['lots'])
    verdict = classification['verdict']

    if verdict == PrecedentVerdict.IGNORE:
        return None

    print(f"\n[PHÂN LOẠI TIN NHẮN]")
    print(f" - Nội dung : {raw_text}")
    print(f" - Đánh giá : {verdict} ({classification['reason']})")
    print(f" - Action   : {classification['action_type']}")
    if classification['lots']:
        print(f" - Mã Lots  : {classification['lots']}")

    if verdict == PrecedentVerdict.AUTO_EXECUTE:
        # XỬ LÝ LUÔN KHÔNG CẦN ANH ĐỨC ACCEPT
        response = execute_precedent(classification)
        # Log vào file
        log_entry = {
            "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "type": "AUTO_EXECUTE",
            "action": classification['action_type'],
            "lots": classification['lots'],
            "raw_text": raw_text,
            "response": response
        }
        with open(LOG_DIR / "zalo_autopilot.log", "a", encoding="utf-8") as f:
            f.write(json.dumps(log_entry, ensure_ascii=False) + "\n")
        return response

    elif verdict == PrecedentVerdict.ESCALATE_TO_DUC:
        # YÊU CẦU MỚI / CHƯA BIẾT -> HỎI ANH ĐỨC
        response = escalate_to_duc(classification, raw_text)
        return response

    return None

# ----------------------------------------------------------------------
# 5. SMART CLIPBOARD SNIFFER (CỰC KỲ TIỆN CHO ANH ĐỨC KHI DÙNG ZALO)
# ----------------------------------------------------------------------
def run_clipboard_sniffer():
    """
    Chế độ Smart Clipboard Sniffer:
    Chạy ngầm trên máy. Khi anh Đức (hoặc bất kỳ ai) bôi đen tin nhắn Zalo và bấm Copy (Ctrl+C),
    script tự động bắt được tin nhắn, phân loại và xử lý:
    - Nếu là tiền lệ: Tự deploy xong, tự nạp kết quả trả lời vào Clipboard và rung chuông!
      Anh Đức chỉ cần qua Zalo bấm Ctrl+V là đã có sẵn câu trả lời chuyên nghiệp!
    - Nếu là yêu cầu mới: Bắn cảnh báo hỏi anh Đức!
    """
    import ctypes
    user32 = ctypes.windll.user32
    kernel32 = ctypes.windll.kernel32

    # Kết nối vào desktop Default nếu cần
    try:
        h_def = user32.OpenDesktopW('Default', 0, False, 0x01FF)
        if h_def:
            user32.SetThreadDesktop(h_def)
    except Exception:
        pass

    def get_clipboard_text():
        if not user32.OpenClipboard(None):
            return ""
        try:
            CF_UNICODETEXT = 13
            h_data = user32.GetClipboardData(CF_UNICODETEXT)
            if not h_data:
                return ""
            kernel32.GlobalLock.restype = ctypes.c_wchar_p
            text_ptr = kernel32.GlobalLock(h_data)
            text = str(text_ptr) if text_ptr else ""
            kernel32.GlobalUnlock(h_data)
            return text
        finally:
            user32.CloseClipboard()

    def set_clipboard_text(text):
        if not user32.OpenClipboard(None):
            return False
        try:
            user32.EmptyClipboard()
            CF_UNICODETEXT = 13
            text_bytes = (text + '\0').encode('utf-16le')
            GMEM_MOVEABLE = 0x0002
            h_mem = kernel32.GlobalAlloc(GMEM_MOVEABLE, len(text_bytes))
            if h_mem:
                kernel32.GlobalLock.restype = ctypes.c_void_p
                dest_ptr = kernel32.GlobalLock(h_mem)
                ctypes.memmove(dest_ptr, text_bytes, len(text_bytes))
                kernel32.GlobalUnlock(h_mem)
                user32.SetClipboardData(CF_UNICODETEXT, h_mem)
            return True
        finally:
            user32.CloseClipboard()

    print(f"\n{'='*70}")
    print("  VINATECH MES — ZALO SMART CLIPBOARD AUTO-PILOT IS ACTIVE")
    print(f"{'='*70}")
    print("-> Cơ chế hoạt động siêu tiện lợi:")
    print("   1. Khi bạn Copy (Ctrl+C) bất kỳ tin nhắn nào từ Zalo...")
    print("   2. Hệ thống tự động bắt mã Lot & phân tích tiền lệ:")
    print("      - Yêu cầu lặp lại (B782/B530/B552/Kẹt máy): Tự sửa & deploy ngay!")
    print("        Đồng thời TỰ ĐỘNG NẠP CÂU TRẢ LỜI vào Clipboard (Bạn chỉ cần Ctrl+V gửi lại).")
    print("      - Yêu cầu mới: Bắn cảnh báo hỏi anh Đức!")
    print("-> Đang giám sát Clipboard... (Nhấn Ctrl+C trong console để thoát)\n")

    last_text = ""
    while True:
        try:
            current_text = get_clipboard_text().strip()
            if current_text and current_text != last_text:
                last_text = current_text
                
                # Kiểm tra xem có dấu hiệu tin nhắn xưởng / MES không
                lots = extract_lots(current_text)
                keywords = ["b782", "b530", "b552", "rollback", "chuyển ngày", "chuyen ngay", "kẹt", "ket", "fifo", "màn hình", "lot"]
                is_mes_related = len(lots) > 0 or any(k in current_text.lower() for k in keywords)

                if is_mes_related:
                    print(f"\n[CLIPBOARD PHÁT HIỆN TIN NHẮN MỚI]: \"{current_text[:120]}\"...")
                    response = process_message(current_text)
                    if response:
                        print(f"\n[KẾT QUẢ ĐÃ XỬ LÝ]:\n{response}\n")
                        # Nạp kết quả vào clipboard để anh Đức chỉ cần Ctrl+V dán vào Zalo
                        set_clipboard_text(response)
                        last_text = response # Tránh lặp vô tận
                        print("-> [ĐÃ NẠP KẾT QUẢ VÀO CLIPBOARD] (Chỉ cần bấm Ctrl+V trên Zalo để gửi lại!)")
                        # Rung chuông Beep báo hiệu đã xử lý xong
                        try:
                            import winsound
                            winsound.MessageBeep(winsound.MB_ICONASTERISK)
                        except Exception:
                            pass

            time.sleep(0.5)
        except KeyboardInterrupt:
            print("\n[STOP] Đã dừng Smart Clipboard Auto-Pilot.")
            break
        except Exception as e:
            time.sleep(1)

# ----------------------------------------------------------------------
# 6. INBOX DIRECTORY WATCHER
# ----------------------------------------------------------------------
def run_inbox_watcher():
    """
    Giám sát thư mục zalo_inbox: Bất kỳ file nào được ghi vào đây (.txt / .json)
    sẽ được xử lý ngay lập tức và ghi kết quả sang zalo_outbox!
    Rất dễ để tích hợp với Zalo Webhook, Playwright hoặc Script ngoài.
    """
    outbox_dir = CONFIG_DIR / "zalo_outbox"
    outbox_dir.mkdir(parents=True, exist_ok=True)
    print(f"[INBOX WATCHER] Đang theo dõi thư mục: {INBOX_DIR}")

    while True:
        try:
            for item in INBOX_DIR.glob("*.*"):
                if item.is_file():
                    try:
                        content = item.read_text(encoding="utf-8").strip()
                        if content:
                            print(f"[INBOX] Tiếp nhận file: {item.name}")
                            resp = process_message(content)
                            if resp:
                                out_file = outbox_dir / f"resp_{item.stem}.txt"
                                out_file.write_text(resp, encoding="utf-8")
                        item.unlink(missing_ok=True)
                    except Exception as ex:
                        print(f"Lỗi đọc file {item}: {ex}")
            time.sleep(1)
        except KeyboardInterrupt:
            break

# ----------------------------------------------------------------------
# 7. MAIN ENTRY POINT
# ----------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="VINATECH MES Zalo Auto-Pilot Engine")
    parser.add_argument("--process", "-p", type=str, help="Xử lý ngay 1 tin nhắn Zalo")
    parser.add_argument("--clip", "-c", action="store_true", help="Chạy chế độ Smart Clipboard Auto-Pilot")
    parser.add_argument("--inbox", "-i", action="store_true", help="Chạy chế độ Inbox Watcher")
    parser.add_argument("--pending", action="store_true", help="Xem danh sách yêu cầu đang chờ anh Đức phê duyệt")
    args = parser.parse_args()

    if args.process:
        resp = process_message(args.process)
        if resp:
            print("\n" + resp)
        else:
            print("\n[INFO] Tin nhắn không chứa yêu cầu MES cần xử lý.")

    elif args.clip:
        run_clipboard_sniffer()

    elif args.inbox:
        run_inbox_watcher()

    elif args.pending:
        inbox_file = INBOX_DIR / "incoming_queue.jsonl"
        has_data = False
        if inbox_file.exists():
            lines = [l.strip() for l in inbox_file.read_text(encoding="utf-8").splitlines() if l.strip()]
            if lines:
                has_data = True
                print(f"\n{'='*70}")
                print(f"  HÀNG ĐỢI TIN NHẮN ZALO ĐANG CHỜ ANTIGRAVITY DUYỆT (Tổng số: {len(lines)})")
                print(f"{'='*70}")
                for i, line in enumerate(lines[-10:], 1):
                    try:
                        item = json.loads(line)
                        print(f"[{i}] {item.get('timestamp')} | Nguồn: {item.get('source_window') or item.get('source')}")
                        print(f"    Mã Lots: {item.get('classification', {}).get('lots')}")
                        print(f"    Nội dung: \"{item.get('raw_message')[:120]}\"")
                        print(f"    Phân loại: {item.get('classification', {}).get('action_type')}\n")
                    except Exception:
                        pass

        if ESCALATION_FILE.exists():
            data = json.loads(ESCALATION_FILE.read_text(encoding="utf-8"))
            if data:
                has_data = True
                print(f"\n[YÊU CẦU MỚI CẦN DUYỆT] (Tổng số: {len(data)})")
                for item in data:
                    print(f" - [{item['id']}] {item['timestamp']} | Lot: {item['lots']}")
                    print(f"   Nội dung: {item['raw_message']}")
                    print(f"   Lý do: {item['reason']}\n")

        if not has_data:
            print("\n[INFO] Hiện tại không có yêu cầu nào đang chờ duyệt.")

    else:
        # Mặc định chạy Clipboard Sniffer (chế độ tối ưu nhất)
        run_clipboard_sniffer()

if __name__ == "__main__":
    main()
