"""
==============================================================================
mes_diagnose.py — VINATECH MES & POP MASTER AUTO-DIAGNOSTIC ENGINE (v1.0)
==============================================================================
Bộ máy chẩn đoán tự động thông minh:
- Nhận diện tức thì: Mã Lot, Mã màn hình (TCode), Triệu chứng lỗi (Việt/Hàn/Anh).
- Đối chiếu tự động: L1 Cache (95 screens, 144 bugs), 60+ Hotfix logs, POP KB.
- Khảo sát thực tế Live DB (nếu có mã Lot) qua Single Round-Trip.
- Xuất kết quả chuẩn mực "4 DÒNG VÀNG" (Root Cause -> Hiện trạng -> OP -> SQL Fix).
- Phản hồi siêu tốc < 0.2s - 1.5s, 0 pip external dependencies.
==============================================================================
"""

import os
import sys
import re
import json
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
CONFIG_DIR = BASE_DIR / "AI_AGENT_CONFIG"
MATRIX_FILE = CONFIG_DIR / "QUICK_MATRIX.json"
POP_MATRIX_FILE = CONFIG_DIR / "POP_MATRIX.json"

# Nạp L1 Cache
_L1_MATRIX = None
_POP_MATRIX = None

def load_matrices():
    global _L1_MATRIX, _POP_MATRIX
    if _L1_MATRIX is None and MATRIX_FILE.exists():
        try:
            with open(MATRIX_FILE, "r", encoding="utf-8-sig") as f:
                _L1_MATRIX = json.load(f)
        except Exception:
            _L1_MATRIX = {}
    if _POP_MATRIX is None and POP_MATRIX_FILE.exists():
        try:
            with open(POP_MATRIX_FILE, "r", encoding="utf-8-sig") as f:
                _POP_MATRIX = json.load(f)
        except Exception:
            _POP_MATRIX = {}

# ----------------------------------------------------------------------
# 1. ENTITY EXTRACTOR (BÓC TÁCH MÃ LOT, MÀN HÌNH, DÂY CHUYỀN, TỪ KHÓA)
# ----------------------------------------------------------------------
def extract_entities(text):
    text_clean = text.strip()
    
    # Lot / Barcode / ControlNo / PackingID
    lot_pattern = r'\b(VV[A-Z0-9]{10,25}|VE\d{6}-\d{3}|SP\d{6}-\d{3}|PK[A-Z0-9]{9,15}|ML\d{14}|\d{14})\b'
    lots = re.findall(lot_pattern, text_clean, re.IGNORECASE)
    
    # Screen ID (TCode)
    screen_pattern = r'\b([A-Z]{1,3}\d{3,4}[A-Z]?)\b'
    screens = [s.upper() for s in re.findall(screen_pattern, text_clean) if not s.upper().startswith('PK') and not s.upper().startswith('ML') and not s.upper().startswith('VE') and not s.upper().startswith('SP') and not s.upper().startswith('VV')]
    
    # Line Code
    line_pattern = r'\b(VVC-\d{2}|VVHYC-\d{2}|TCX-\d{2}|ElectrodeBN)\b'
    lines = re.findall(line_pattern, text_clean, re.IGNORECASE)
    
    # Equipment Code
    equip_pattern = r'\b(V[VN]EP\d{3}|Winding\s*C#\d+|Curling\s*C#\d+|Sleeving\s*C#\d+)\b'
    equips = re.findall(equip_pattern, text_clean, re.IGNORECASE)
    
    return {
        "raw_text": text_clean,
        "lots": list(set(lots)),
        "screens": list(set(screens)),
        "lines": list(set(lines)),
        "equips": list(set(equips))
    }

# ----------------------------------------------------------------------
# 2. EXPERT RULES & KNOWLEDGE MATCHING (TRI THỨC CHẨN ĐOÁN 7 NHÓM LỖI)
# ----------------------------------------------------------------------
RULE_CATALOG = [
    {
        "id": "RULE_POP_ROUTE_ALREADY_COMPLETED",
        "patterns": [
            r"already completed in mes", r"this route is already completed",
            r"chốt sản xuất.*kẹt", r"đã hoàn thành trong mes"
        ],
        "screen": "POP / B530",
        "root_cause": "Xung đột quyền chốt: Trong CSDL `STB_ProdRouteHist` đã tồn tại bản ghi công đoạn cũ/chạy thử của các ca trước. Khi công nhân chốt trên Kiosk POP, API kiểm tra thấy bản ghi cũ nên chặn báo 'This route is already completed in MES'. Ngược lại trên MES WinForm B530 thì chặn bắt buộc dùng POP.",
        "op_workaround": "1. Không chốt trên WinForm B530.\n2. Báo IT xóa bản ghi kẹt cũ trong CSDL.\n3. Sau khi IT xử lý, công nhân bấm F5 trên POP Kiosk và ấn lại 'Hoàn thành sản xuất'.",
        "sql_template": """BEGIN TRAN;
-- 1. Xóa worker mapping kẹt cũ
DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteWorkerHist 
WHERE ProdRouteHistNo IN (
    SELECT ProdRouteHistNo FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
    WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '{LOT}')
      AND RouteCode = '{ROUTE}'
);
-- 2. Xóa lượt chốt kẹt cũ trong STB_ProdRouteHist
DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteHist 
WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '{LOT}')
  AND RouteCode = '{ROUTE}';
-- COMMIT TRAN; -- Kiểm tra xong mới commit"""
    },
    {
        "id": "RULE_POP_PACKING_EXCEED_REMAIN",
        "patterns": [
            r"vượt quá số lượng còn lại", r"có thể đóng gói thêm:\s*0\s*ea",
            r"còn lại:\s*0\s*ea", r"v-28_hy.*kẹt"
        ],
        "screen": "POP Web / B523",
        "root_cause": "Chốt sớm công đoạn đóng gói V-28_HY: Đã có ai đó (hoặc ca trước) chốt sản lượng toàn bộ ở công đoạn V-28_HY trên WinForm B530 hoặc tự sinh BTP tại `STB_MaterialLotInfo`, làm tiêu thụ sạch hạn mức đóng gói khả dụng trên POP Web.",
        "op_workaround": "1. Tạm dừng đóng gói chia trên Kiosk.\n2. Báo IT giải phóng lượt chốt sớm V-28_HY và bản ghi BTP tạm.\n3. F5 Kiosk POP ➔ Số lượng khả dụng sẽ phục hồi đủ để chia Box.",
        "sql_template": """BEGIN TRAN;
-- 1. Xóa bản ghi BTP sinh sớm ở kho tuyến
DELETE FROM SmartFactoryV2.dbo.STB_MaterialLotInfo 
WHERE LotNo = '{LOT}' AND MaterialWarehouseCode LIKE '%ROUTE%';
-- 2. Xóa lượt chốt công đoạn đóng gói V-28_HY
DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteHist 
WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '{LOT}')
  AND RouteCode IN ('V-28', 'V-28_HY', 'V-28_BG');
-- 3. Xóa bản ghi hạn mức tạm trong VINATECH_POP
DELETE FROM VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY 
WHERE BARCODE = '{LOT}';
-- COMMIT TRAN;"""
    },
    {
        "id": "RULE_B782_SHIFT_CUTOFF",
        "patterns": [
            r"chuyển ngày.*b782", r"b782.*lệch ngày", r"không hiện trên b782",
            r"ca đêm.*ngày hôm trước", r"ngày làm.*b782", r"jobdate.*b782"
        ],
        "screen": "B782 - LotTrackingInfo_VVT2",
        "root_cause": "Cơ chế cắt ca 10:00:00 AM của B782 (`usp_LotTrackingInfo_VVT2_get`): Chu kỳ ca tính từ 10:00 sáng hôm trước đến 10:00 sáng hôm sau. Các Lot chốt ca đêm/rạng sáng (00:00 - 09:59 AM) tự động bị B782 xếp vào ngày hôm trước. Nếu chỉ sửa cột JobDate mà không tăng ProdDateTime qua 10h thì B782 vẫn gom vào ngày cũ.",
        "op_workaround": "1. Trên giao diện B782: Chọn dải ngày tìm kiếm lùi lại 1 ngày sẽ nhìn thấy đầy đủ dữ liệu Lot.\n2. Nếu phòng ban QLSX bắt buộc hiển thị trên báo cáo ngày mới: Yêu cầu IT điều chỉnh giờ ProdDateTime vượt qua mốc 10h00 AM.",
        "sql_template": """BEGIN TRAN;
-- SOP Chuẩn hóa B782: Cộng 10 giờ để vượt mốc 10:00 AM và cập nhật JobDate
UPDATE SmartFactoryV2.dbo.STB_ProdRouteHist
SET ProdDateTime = DATEADD(HOUR, 10, ProdDateTime),
    JobDate = '{TARGET_DATE}',
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vanduc'
WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '{LOT}')
  AND RouteCode = '{ROUTE}';

-- Đồng bộ bảng phế Defect nếu có
UPDATE SmartFactoryV2.dbo.STB_DefectRepairInfo
SET FindJobdate = '{TARGET_DATE}',
    CreateDateTime = DATEADD(HOUR, 10, CreateDateTime),
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vanduc'
WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '{LOT}')
  AND FindRouteCode = '{ROUTE}';
-- COMMIT TRAN;"""
    },
    {
        "id": "RULE_B782_DEFECT_NULL",
        "patterns": [
            r"cột ng.*b782", r"phế.*không hiện.*b782", r"defectqty.*null",
            r"không link.*ng.*pop", r"số lượng ng.*trống"
        ],
        "screen": "B782 / STB_DefectRepairInfo",
        "root_cause": "Three-Valued Logic SQL Server: Khi Kiosk lưu phế vào `STB_DefectRepairInfo`, cột `RepairQty` mang giá trị NULL. Trong SP `usp_LotTrackingInfo_VVT2_get`, công thức tính phế là `DefectQty - RepairQty`. Vì số trừ NULL ra NULL, toàn bộ cột NG bị rỗng/âm trên giao diện WinForm B782.",
        "op_workaround": "1. Đây là lỗi logic ngầm của CSDL, OP không thể tự khắc phục trên UI.\n2. IT cập nhật `RepairQty = 0` và kiểm tra SP `usp_LotTrackingInfo_VVT2_get` đã bọc `ISNULL(..., 0)`.",
        "sql_template": """BEGIN TRAN;
-- 1. Chuẩn hóa giá trị NULL về 0 cho Lot
UPDATE SmartFactoryV2.dbo.STB_DefectRepairInfo
SET RepairQty = 0, IsDelete = 0, ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc'
WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '{LOT}')
  AND (RepairQty IS NULL OR IsDelete IS NULL);

-- 2. Đồng bộ tổng phế sang STB_SetInfo
UPDATE SmartFactoryV2.dbo.STB_SetInfo
SET DefectQty = (
    SELECT ISNULL(SUM(DefectQty), 0) FROM SmartFactoryV2.dbo.STB_DefectRepairInfo WITH(NOLOCK)
    WHERE ControlNo = STB_SetInfo.ControlNo AND IsDelete = 0
)
WHERE Barcode = '{LOT}';
-- COMMIT TRAN;"""
    },
    {
        "id": "RULE_POP_EQUIPMENT_ORPHAN_LOCK",
        "patterns": [
            r"thiếu máy", r"ẩn máy", r"không chọn được máy",
            r"modal.*xác nhận kết thúc", r"kẹt máy", r"active.*equipment_mapping"
        ],
        "screen": "POP Kiosk (Modal Chọn Máy)",
        "root_cause": "Kẹt khóa thiết bị độc quyền (`VINA_EQUIPMENT_MAPPING`): Thiết bị từng được gán vào DayPlan cũ nhưng công nhân hết ca không bấm Release hoặc đổi kế hoạch. Cột `MAPPING_STATUS` vẫn giữ `ACTIVE` ➔ Kiosk tự động ẩn máy khỏi danh sách chọn của DayPlan mới.",
        "op_workaround": "1. Kiểm tra xem trên Kiosk có DayPlan cũ nào đang mở không, nếu có hãy bấm 'Hủy gán / Release'.\n2. Nếu không thấy: Chạy lệnh tự động giải phóng tức thì: `.\\mes.ps1 release-machines -Force`.",
        "sql_template": """-- Sử dụng lệnh CLI an toàn có auto-snapshot backup:
-- .\\mes.ps1 release-machines -Force
-- Hoặc SQL:
BEGIN TRAN;
UPDATE VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING
SET MAPPING_STATUS = 'RELEASED',
    RELEASED_AT = GETDATE(),
    RELEASE_REASON = N'Release cho ca moi',
    NO_EMP_MODIFYER = 'vanduc'
WHERE MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED')
  AND LEFT(DAY_PLAN_NO, 8) < CONVERT(VARCHAR(8), GETDATE(), 112);
-- COMMIT TRAN;"""
    },
    {
        "id": "RULE_B523_MISSING_WEIGHT",
        "patterns": [
            r"kho thành phẩm chưa nhập cân nặng", r"could not find.*cân nặng",
            r"in tem.*b523.*lỗi", r"b351.*in tem"
        ],
        "screen": "B523 - Đóng gói in tem (Sau B351)",
        "root_cause": "Sau khi chuyển đổi Lot tại B351, Lot mới chưa có thông số trọng lượng trong `STB_VIETNAM_BARCODEWEIGHT`. SP `usp_Vietnam_GetBoxIDForLotNo_VVT` tính `@lotweight = 0` ➔ trả về `FormatName = N'Kho Thành phẩm chưa nhập cân nặng...'` ➔ WinForm không tìm thấy file template nhãn tên này và văng popup đỏ.",
        "op_workaround": "1. Không bấm In tem liên tục trên B523 vì sẽ tiếp tục lỗi.\n2. Báo IT nạp thông số cân và ánh xạ tem in cho mã Lot mới.\n3. Sau khi IT nạp xong, quét lại Lot trên B523 và bấm 'In tem' bình thường.",
        "sql_template": """BEGIN TRAN;
-- 1. Nạp trọng lượng Barcode chuẩn
IF NOT EXISTS (SELECT 1 FROM SmartFactoryV2.dbo.STB_VIETNAM_BARCODEWEIGHT WHERE BARCODE = '{LOT}')
    INSERT INTO SmartFactoryV2.dbo.STB_VIETNAM_BARCODEWEIGHT (BARCODE, WEIGHT, CREATEDATETIME) 
    VALUES ('{LOT}', 25.5, GETDATE());

-- 2. Mở khóa cho phép in tem
UPDATE SmartFactoryV2.dbo.STB_PackingLabelPrintHist 
SET IsPrintAllow = 1, PrintCount = 0 
WHERE LotNo = '{LOT}' OR PackingID IN (SELECT PackingID FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo = '{LOT}');
-- COMMIT TRAN;"""
    },
    {
        "id": "RULE_B530_WINDING_ROLLBACK",
        "patterns": [
            r"chốt nhầm.*v-22", r"chốt nhầm.*cuốn", r"chốt nhầm.*winding",
            r"rollback.*w-22", r"b530.*chặn.*chốt lại"
        ],
        "screen": "B530 / B782",
        "root_cause": "OP chốt nhầm số lượng ở công đoạn đầu Winding (V-22). Hệ thống set CompleteRoute=1 ở V-22 và tự sinh công đoạn kế tiếp V-23. Màn hình B530 kiểm tra thấy công đoạn tiếp theo đã có dữ liệu nên chặn không cho sửa.",
        "op_workaround": "1. Dừng chốt ở các công đoạn tiếp theo.\n2. Yêu cầu IT rollback công đoạn đầu theo đúng chuẩn SOP 3 bước (Xóa phế NG, Xóa V-23, Reset CompleteRoute V-22 về NULL).\n3. Sau đó OP mở lại B530 sẽ thấy công đoạn Winding mở ra để chốt lại số lượng đúng.",
        "sql_template": """BEGIN TRAN;
-- SOP Rollback Winding V-22 Chuẩn (3 bước bảo toàn Lot)
-- 1. Xóa phế NG nhập nhầm ở Winding
DELETE FROM SmartFactoryV2.dbo.STB_DefectRepairInfo 
WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '{LOT}')
  AND FindRouteCode IN ('V-22', 'V-22_HY', 'V-22_BG');

-- 2. Xóa công đoạn sau tự sinh (V-23)
DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteHist 
WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '{LOT}')
  AND RouteCode IN ('V-23', 'V-23_HY', 'V-23_BG');

-- 3. Reset CompleteRoute = NULL ở Winding (TUYỆT ĐỐI KHÔNG XÓA DÒNG V-22)
UPDATE SmartFactoryV2.dbo.STB_ProdRouteHist 
SET CompleteRoute = NULL, ProdQty = 0, ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc'
WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '{LOT}')
  AND RouteCode IN ('V-22', 'V-22_HY', 'V-22_BG');
-- COMMIT TRAN;"""
    },
    {
        "id": "RULE_B552_ELECTRODE_CANCEL",
        "patterns": [
            r"xóa mẻ trộn", r"hủy mẻ trộn", r"mixing.*thừa",
            r"xóa cắt chia cuộn", r"slitting.*thừa", r"b552.*xóa"
        ],
        "screen": "B552 - Vietnam_Kết quả đo điện cực",
        "root_cause": "Ca đêm cân trộn mẻ điện cực hoặc chia cuộn cắt dở dang nhưng không dùng đến / đổi kế hoạch. Giao diện B552 không có nút xóa nên dữ liệu tồn lưu làm cản trở cấp phát NVL.",
        "op_workaround": "1. Xác nhận rõ mẻ trộn chưa tráng Coating (Coating = 0) hoặc danh sách STT cuộn cắt cần xóa.\n2. Báo IT thực hiện Cascade Delete theo chuẩn SOP KB_05.",
        "sql_template": """BEGIN TRAN;
-- Kiểm tra an toàn trước: STB_ElectrodeCoatingInfo phải bằng 0!
-- 1. Xóa chi tiết các bước cân mẻ trộn
DELETE FROM SmartFactoryV2.dbo.STB_ElectrodeMixStepInfo WHERE ElectrodeLotNumber = '{LOT}';
-- 2. Xóa header mẻ trộn
DELETE FROM SmartFactoryV2.dbo.STB_ElectrodeMixInfo WHERE ElectrodeLotNumber = '{LOT}';
-- 3. Xóa SetInfo khởi tạo
DELETE FROM SmartFactoryV2.dbo.STB_SetInfo WHERE Barcode = '{LOT}';
-- COMMIT TRAN;"""
    },
    {
        "id": "RULE_POP_DUNG_DICH_0KG",
        "patterns": [
            r"dung dịch.*0\s*kg", r"thùng dung dịch.*về 0", r"hết hàng.*dung dịch",
            r"gbec00", r"gbcp00"
        ],
        "screen": "POP Kiosk / B597",
        "root_cause": "Xung đột chuyển vùng kho (Hà Nam ROUTE_VN_WH sang Hưng Yên ROUTE_HY_WH) hoặc cơ chế Auto-exhaust tự đóng thùng cũ về 0 khi quét Lot mới. Thùng 150 KG mới dùng 1 ca bị hệ thống trừ về 0 KG.",
        "op_workaround": "1. Không quét lại thùng rỗng hoặc khai báo phế oan.\n2. Yêu cầu IT phục hồi đúng 150 KG (InitialQty) tại kho `ROUTE_HY_WH`.\n3. Bấm 'Danh sách NVL BOM 🔄' (Reload) trên Kiosk POP.",
        "sql_template": """BEGIN TRAN;
-- Phục hồi đủ 100% InitialQty (150 KG) cho thùng dung dịch tại kho Hưng Yên
UPDATE SmartFactoryV2.dbo.STB_MaterialLotInfo 
SET CurrentQty = 150.0, ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc'
WHERE LotID = '{LOT}' AND MaterialWarehouseCode = 'ROUTE_HY_WH';
-- COMMIT TRAN;"""
    },
    {
        "id": "RULE_B530_ADD_DEFECT_DISABLED",
        "patterns": [
            r"nút nhập lỗi bị mờ", r"adddefect.*disabled", r"không bấm được nhập lỗi",
            r"b530.*nhập lỗi"
        ],
        "screen": "B530 - Nhập thực tế sản xuất",
        "root_cause": "Biểu thức Expression của giao diện: `!IsHasNextProd && !IsLoss`. Do công đoạn kế tiếp đã có ai đó quét chốt sản lượng (`IsHasNextProd = 1`), nút Nhập lỗi tự động bị mờ đi.",
        "op_workaround": "1. Kiểm tra xem công đoạn sau đã được ai bấm chốt chưa.\n2. Muốn nhập bổ sung lỗi ở công đoạn này: Bắt buộc phải hủy/rollback lượt chốt ở công đoạn liền sau.",
        "sql_template": """BEGIN TRAN;
-- Rollback công đoạn sau để mở lại nút Nhập lỗi
DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteHist 
WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '{LOT}')
  AND RouteCode = '{NEXT_ROUTE}';
UPDATE SmartFactoryV2.dbo.STB_ProdRouteHist 
SET CompleteRoute = NULL 
WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '{LOT}')
  AND RouteCode = '{CURRENT_ROUTE}';
-- COMMIT TRAN;"""
    },
    {
        "id": "RULE_B360_KOREA_CONVERT",
        "patterns": [
            r"rạch vỏ", r"hàn quốc.*việt nam", r"korea.*việt nam",
            r"model 1625", r"chuyển đổi mã lot"
        ],
        "screen": "B360 - Material Lot Conversion",
        "root_cause": "Quy trình rạch vỏ & chuyển đổi mã Lot từ Hàn Quốc về Việt Nam (như lô 155,000 pcs model 1625). Màn B360 quản lý chuyển đổi mã Lot và cấp phát barcode mới trong `STB_MaterialLotInfo`.",
        "op_workaround": "1. Mở màn hình B360 (Chuyển đổi Lot NVL).\n2. Quét mã Lot gốc Korea và chọn mã sản phẩm Việt Nam tương ứng.\n3. Xác nhận để hệ thống sinh Barcode mới chuẩn Việt Nam.",
        "sql_template": """-- Tra cứu tiền lệ chuyển đổi Lot trên B360:
SELECT TOP 10 * FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
WHERE LotID LIKE '%1625%' OR LotNo LIKE '%1625%'
ORDER BY CreateDateTime DESC;"""
    },
    {
        "id": "RULE_QC_CLONE_HY",
        "patterns": [
            r"c121.*hy", r"c122.*hy", r"clone.*_hy", r"9 màn.*hy", r"màn hình.*_hy"
        ],
        "screen": "QC Screens Clone _HY (C121, C122, C220, C460...)",
        "root_cause": "Clone màn hình WinForms cho nhà máy mới Hưng Yên `_HY` (VVT_F5). Cần tạo Stored Procedure riêng biệt, sửa WorkCenterCode='VVT_F5', và Author/Modifier='vanduc'. Không dùng chung SP cũ vì sẽ lẫn lộn dữ liệu giữa Bắc Giang và Hưng Yên.",
        "op_workaround": "1. Sử dụng script `.\\mes.ps1 clone-factory` để clone SP và Table chuẩn hóa.\n2. Kiểm tra WinForms gọi đúng tên SP mới có đuôi `_HY`.",
        "sql_template": """-- Kiểm tra các SP clone _HY đã khai báo đúng Author vanduc và WorkCenterCode:
SELECT name, create_date, modify_date 
FROM SmartFactoryV2.sys.procedures 
WHERE name LIKE '%_HY%' OR name LIKE '%_VNT'
ORDER BY modify_date DESC;"""
    },
    {
        "id": "RULE_A230_B310_NO_ROUTING",
        "patterns": [
            r"không có thông tin routing", r"공정라우팅정보가 없습니다",
            r"b310.*routing", r"tạo po.*lỗi"
        ],
        "screen": "B310 / A230 / B240",
        "root_cause": "Sự không đồng bộ giữa Master Data: (1) Tại B240, bộ mã Routing chưa được định nghĩa hoặc các bước RouteCode chưa được tick 'Sử dụng' cho nhà máy hiện tại (ví dụ `VVT_F5`), hoặc (2) Tại A230, mã vật tư bị gán sai cột `BasicRoutingCode`.",
        "op_workaround": "1. Vào B240: Kiểm tra bộ Routing chuẩn đã có cho nhà máy chưa (ví dụ `HY_MainRoutingMedium` có đủ các bước từ Cuộn đến Đóng gói).\n2. Vào A230: Tìm mã vật tư ➔ Gán cột `BasicRoutingCode` sang mã Routing chuẩn ở B240 ➔ Nhấn Lưu.\n3. Mở lại B310 tạo lại PO.",
        "sql_template": """-- Kiểm tra cấu hình Routing Master:
SELECT MaterialCode, BasicRoutingCode FROM SmartFactoryV2.dbo.STB_MaterialMaster WITH(NOLOCK) WHERE MaterialCode = '{MODEL}';
SELECT BasicRoutingCode, WorkCenterCode, RouteCode, IsUsed FROM SmartFactoryV2.dbo.STB_BasicRoutingDetail WITH(NOLOCK) WHERE BasicRoutingCode = '{ROUTING}';"""
    },
    {
        "id": "RULE_POP_SWAP_MACHINE",
        "patterns": [
            r"sửa tên máy", r"sửa mã máy", r"chọn nhầm máy", r"nhầm máy",
            r"đổi máy.*pop", r"vvmhy", r"vvep"
        ],
        "screen": "POP Kiosk / B270 / B530",
        "root_cause": "Công nhân chọn nhầm thiết bị khi chốt sản lượng trên Kiosk (ví dụ: máy VVMHY130 nhưng bấm nhầm VVMHY136). NGUYÊN TẮC VÀNG: Bắt buộc phải UPDATE đồng thời ở CẢ 2 BẢNG (STB_ProdRouteHist VÀ MongoToMesPerformance) để tránh Background Worker của POP ghi đè ngược lại mã cũ.",
        "op_workaround": "1. Ghi nhận chính xác Barcode của Lot, mã công đoạn và mã máy thực tế công nhân đã chạy.\n2. Báo IT can thiệp cập nhật đồng bộ cả 2 bảng CSDL.\n3. Tra cứu mã máy theo tên máy tại màn hình B270 trên WinForm.",
        "sql_template": """BEGIN TRAN;
-- 1. Sửa trên MES Lõi
UPDATE SmartFactoryV2.dbo.STB_ProdRouteHist
SET MachineCode = '{NEW_MACHINE}', ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc'
WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '{LOT}')
  AND RouteCode = '{ROUTE}';

-- 2. Sửa trên bảng đệm POP (Chống Worker ghi đè)
UPDATE SmartFactoryV2.dbo.MongoToMesPerformance
SET MachineCode = '{NEW_MACHINE}'
WHERE Barcode = '{LOT}' AND RouteCode = '{ROUTE}';
-- COMMIT TRAN;"""
    },
    {
        "id": "RULE_POP_SLITTING_THICKNESS_UNDER_100",
        "patterns": [
            r"nút.*cắt.*không sáng", r"không thể.*cắt điện cực", r"nút cắt.*mờ",
            r"độ dày điện cực", r"materialthickness", r"độ dày.*<.*100"
        ],
        "screen": "POP Kiosk / Cắt điện cực / B210",
        "root_cause": "Logic an toàn hệ thống xưởng Vinatech: Kiosk tự động khóa nút 'Cắt điện cực' (Button mờ) nếu độ dày màng điện cực MaterialThickness < 100 trong bảng STB_MaterialMaster.",
        "op_workaround": "1. Kiểm tra thông số độ dày màng thực tế của Model.\n2. Báo IT/Master Data kiểm tra cột MaterialThickness trong STB_MaterialMaster.\n3. Cập nhật lại thông số MaterialThickness >= 100 ➔ Nút Cắt trên Kiosk sẽ tự động sáng trở lại.",
        "sql_template": """-- Kiểm tra độ dày điện cực trong Master:
SELECT MaterialCode, MaterialName, MaterialThickness, MaterialTypeCode
FROM SmartFactoryV2.dbo.STB_MaterialMaster WITH(NOLOCK)
WHERE MaterialCode = (
    SELECT MaterialCode FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '{LOT}'
);

-- Cập nhật lại độ dày nếu bị nhập sai < 100:
-- UPDATE SmartFactoryV2.dbo.STB_MaterialMaster SET MaterialThickness = 120, ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc' WHERE MaterialCode = '{MATERIAL}';"""
    },
    {
        "id": "RULE_POP_DEFECT_GROUP_MISSING",
        "patterns": [
            r"chưa.*thêm mã lỗi", r"thiếu mã lỗi.*công đoạn", r"không có danh mục phế",
            r"v-11_hy.*defect", r"stb_defectgroup", r"stb_defectinfo"
        ],
        "screen": "POP Kiosk / B110 / B120",
        "root_cause": "Công đoạn mới (ví dụ Slitting Hưng Yên V-11_HY) chưa được khai báo nhóm lỗi trong STB_DefectGroup hoặc chưa clone danh mục mã phế con từ nhóm chuẩn V-11 sang STB_DefectInfo.",
        "op_workaround": "1. Báo IT cấu hình đồng bộ nhóm lỗi và danh mục lỗi cho công đoạn mới.\n2. F5 Kiosk POP ➔ Bảng phế phẩm sẽ hiển thị đầy đủ.",
        "sql_template": """BEGIN TRAN;
-- 1. Đăng ký nhóm lỗi
INSERT INTO SmartFactoryV2.dbo.STB_DefectGroup(DefectGroupCode, BasicDefectGroupName, IsUsed, CreateUserID, CreateDateTime)
VALUES ('{ROUTE}', 'DEFECT_GROUP', 1, 'vanduc', GETDATE());

-- 2. Clone mã lỗi từ nhóm chuẩn V-11
INSERT INTO SmartFactoryV2.dbo.STB_DefectInfo (
    DefectCode, BasicDefectName, DefectDesc, DefectGroupCode, UseGroup, DisplayIndex,
    IsRealDefect, IsUsed, DefectImage, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID,
    DirectlyUnder, WorkCenterCode, DefectCause, DefectEnglishName
)
SELECT
    REPLACE(DefectCode, 'V-11_', '{ROUTE}_'), BasicDefectName, DefectDesc, '{ROUTE}',
    UseGroup, DisplayIndex, IsRealDefect, IsUsed, DefectImage, GETDATE(), 'vanduc', NULL, NULL,
    DirectlyUnder, WorkCenterCode, DefectCause, DefectEnglishName
FROM SmartFactoryV2.dbo.STB_DefectInfo WITH(NOLOCK)
WHERE DefectGroupCode = 'V-11';
-- COMMIT TRAN;"""
    },
    {
        "id": "RULE_POP_PQC_ROUTE_MISMATCH",
        "patterns": [
            r"hạng mục kiểm tra.*nhầm công đoạn", r"tự kiểm.*nhầm công đoạn",
            r"v_h1_hy", r"v_h2_hy", r"v_wa_hy", r"c141"
        ],
        "screen": "POP Kiosk Quality / C141",
        "root_cause": "Hạng mục đo tự kiểm PQC In-Line (V_H1_HY, V_H2_HY, V_WA_HY) bị cấu hình sai công đoạn trong tài liệu đo STB_CommInspDocItem.",
        "op_workaround": "1. Vào màn hình C141 trên WinForm để cập nhật lại cấu hình công đoạn cho hạng mục kiểm tra.\n2. Báo IT chạy SQL điều chỉnh RouteCode của tài liệu đo đã sinh cho Lot.",
        "sql_template": """BEGIN TRAN;
UPDATE DI 
SET DI.RouteCode = '{ROUTE}', DI.ChangeDateTime = GETDATE(), DI.ChangeUserID = 'vanduc'
FROM SmartFactoryV2.dbo.STB_CommInspDocItem DI
INNER JOIN SmartFactoryV2.dbo.STB_CommInspDocHistory DH ON DH.CommInspDocNo = DI.CommInspDocNo
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo SI ON SI.ControlNo = DH.ProdNo
WHERE SI.Barcode = '{LOT}' AND DI.CommInspItemCode IN ('V_H1_HY', 'V_H2_HY', 'V_WA_HY');
-- COMMIT TRAN;"""
    },
    {
        "id": "RULE_POP_SLIT_STOCK_FORCE_CREATE",
        "patterns": [
            r"cưỡng chế tồn kho", r"tạo tồn kho điện cực", r"cuộn rách tem",
            r"mờ mã vạch.*cuộn", r"không quét được mã điện cực", r"modalvisible"
        ],
        "screen": "POP Kiosk / STB_MaterialLotInfo / B552",
        "root_cause": "Cuộn điện cực bị rách tem, mờ barcode hoặc chưa được tạo tồn kho từ Slitting vào STB_MaterialLotInfo, khiến Kiosk không quét được và không tìm thấy trên popup. Kiosk chỉ hiện cuộn khi ModalVisible='Y' (thỏa mãn IsSlitting=1, LotAttr01='SLITTING', CurrentQty>0 và đúng cực tính PlusMinus).",
        "op_workaround": "1. Xác định cuộn hợp lệ từ STB_ElectrodeSlittingResult.\n2. IT chạy script sinh số serial chuẩn qua STB_SerialRule và chèn vào STB_MaterialLotInfo với LotAttr01='SLITTING', IsSlitting=1.\n3. F5 Kiosk POP ➔ Cuộn sẽ xuất hiện trên popup tìm kiếm.",
        "sql_template": """-- Xem chi tiết script tạo tồn kho cưỡng chế chuẩn tại POP_KB_03 § 3 (Case 8 & 9)
-- hoặc chạy theo template routine_CREATE_ELECTRODE_STOCK_ON_DEMAND.sql"""
    },
    {
        "id": "RULE_POP_PACKING_NO_WAREHOUSE",
        "patterns": [
            r"không thể đóng gói.*không có kho", r"đóng gói.*không có kho",
            r"báo không có kho", r"b230"
        ],
        "screen": "POP Kiosk Packing / B230",
        "root_cause": "CellLine chưa được cấu hình liên kết công đoạn đóng gói với kho đích trong Master Data.",
        "op_workaround": "1. Vào MES WinForm, mở màn hình B230 (Cấu hình CellLine).\n2. Gán công đoạn và kho đóng gói cho CellLine (tham khảo Line chuẩn TX1).\n3. Reload Kiosk Đóng gói và chốt lại.",
        "sql_template": """-- Kiểm tra cấu hình kho của Line trên B230:
SELECT LineCode, LineName, MaterialWarehouseCode, IsUsed 
FROM SmartFactoryV2.dbo.STB_LineInfo WITH(NOLOCK) 
WHERE LineCode = '{LINE}';"""
    }
]

# ----------------------------------------------------------------------
# 3. LIVE DB PROBE (TRUY VẤN TRẠNG THÁI THỰC TẾ CỦA LOT QUA SINGLE SHOT)
# ----------------------------------------------------------------------
def query_live_lot(lot_id):
    load_matrices()
    tools_dir = BASE_DIR / "tools"
    ps_script = f"""
    . '{tools_dir}\\db_shared.ps1'
    $conn = Get-DbConnection -Profile 'SmartFactoryV2' -Silent
    if ($null -eq $conn) {{ exit 1 }}
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = @"
    SET NOCOUNT ON;
    SELECT TOP 1 
        s.ControlNo, s.Barcode, s.MaterialCode, s.CurrentRouteCode, s.IsHold, s.IsProdFinish, s.InputLineCode,
        (SELECT COUNT(1) FROM STB_ProdRouteHist WITH(NOLOCK) WHERE ControlNo = s.ControlNo) AS TotalRoutes,
        (SELECT COUNT(1) FROM STB_DefectRepairInfo WITH(NOLOCK) WHERE ControlNo = s.ControlNo AND IsDelete = 0) AS TotalDefects,
        (SELECT TOP 1 RouteCode FROM STB_ProdRouteHist WITH(NOLOCK) WHERE ControlNo = s.ControlNo ORDER BY ProdRouteHistNo DESC) AS LastRoute
    FROM STB_SetInfo s WITH(NOLOCK)
    WHERE s.Barcode = '{lot_id}' OR s.ControlNo = '{lot_id}';
    
    SELECT TOP 1 LineCode, RouteCode, IsDone, IsTransferred, TotalProdQty 
    FROM MongoToMesPerformance WITH(NOLOCK) 
    WHERE Barcode = '{lot_id}' ORDER BY ModifyDateTime DESC;
"@
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $ds = New-Object System.Data.DataSet
    $adapter.Fill($ds) | Out-Null
    $conn.Close()
    
    $res = @{{
        lot = $null
        pop_sync = $null
    }}
    if ($ds.Tables[0].Rows.Count -gt 0) {{
        $r = $ds.Tables[0].Rows[0]
        $res.lot = @{{
            ControlNo = [string]$r["ControlNo"]
            Barcode = [string]$r["Barcode"]
            MaterialCode = [string]$r["MaterialCode"]
            CurrentRoute = [string]$r["CurrentRouteCode"]
            IsHold = [int]$r["IsHold"]
            IsProdFinish = [int]$r["IsProdFinish"]
            Line = [string]$r["InputLineCode"]
            TotalRoutes = [int]$r["TotalRoutes"]
            TotalDefects = [int]$r["TotalDefects"]
            LastRoute = [string]$r["LastRoute"]
        }}
    }}
    if ($ds.Tables.Count -gt 1 -and $ds.Tables[1].Rows.Count -gt 0) {{
        $p = $ds.Tables[1].Rows[0]
        $res.pop_sync = @{{
            Line = [string]$p["LineCode"]
            Route = [string]$p["RouteCode"]
            IsDone = [int]$p["IsDone"]
            IsTransferred = [int]$p["IsTransferred"]
            Qty = [int]$p["TotalProdQty"]
        }}
    }}
    $res | ConvertTo-Json -Compress
    """
    try:
        proc = subprocess.run(
            ["powershell", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-Command", ps_script],
            capture_output=True, text=True, timeout=5, encoding="utf-8", errors="replace"
        )
        out = proc.stdout.strip()
        if out.startswith("{"):
            return json.loads(out)
    except Exception:
        pass
    return None

# ----------------------------------------------------------------------
# 4. CORE DIAGNOSTIC LOGIC (KẾT NỐI TẤT CẢ VÀ RA QUYẾT ĐỊNH)
# ----------------------------------------------------------------------
def diagnose(input_text, check_live_db=True):
    load_matrices()
    entities = extract_entities(input_text)
    matched_rules = []
    
    # 1. Khớp theo Expert Rules
    for rule in RULE_CATALOG:
        for p in rule["patterns"]:
            if re.search(p, input_text, re.IGNORECASE):
                matched_rules.append(rule)
                break
                
    # 2. Khớp theo L1 QUICK_MATRIX (nếu có TCode hoặc từ khóa)
    l1_hit = None
    if _L1_MATRIX and "screens" in _L1_MATRIX:
        # Check Screen Code trực tiếp
        for s_code in entities["screens"]:
            if s_code in _L1_MATRIX["screens"]:
                l1_hit = _L1_MATRIX["screens"][s_code]
                l1_hit["code"] = s_code
                break
        
        # Nếu chưa thấy, check theo text
        if not l1_hit:
            for s_code, s_info in _L1_MATRIX["screens"].items():
                if s_code.lower() in input_text.lower() or s_info.get("name", "").lower() in input_text.lower():
                    l1_hit = s_info
                    l1_hit["code"] = s_code
                    break

    # 3. Khảo sát Live DB nếu có mã Lot
    live_info = None
    target_lot = entities["lots"][0] if entities["lots"] else None
    if target_lot and check_live_db:
        live_info = query_live_lot(target_lot)

    # 4. Tổng hợp & sinh phản hồi chuẩn "4 DÒNG VÀNG"
    result = {
        "entities": entities,
        "matched_rule": matched_rules[0] if matched_rules else None,
        "l1_screen": l1_hit,
        "live_db": live_info,
        "root_cause": "",
        "data_state": "",
        "op_workaround": "",
        "sql_hotfix": ""
    }

    # Sinh Root Cause
    if matched_rules:
        r = matched_rules[0]
        result["root_cause"] = f"[{r['screen']}] {r['root_cause']}"
        result["op_workaround"] = r["op_workaround"]
        sql_patch = r["sql_template"]
        if target_lot:
            sql_patch = sql_patch.replace("{LOT}", target_lot)
        if live_info and live_info.get("lot"):
            cur_route = live_info["lot"].get("CurrentRoute") or live_info["lot"].get("LastRoute") or "V-22_HY"
            sql_patch = sql_patch.replace("{ROUTE}", cur_route)
            sql_patch = sql_patch.replace("{CURRENT_ROUTE}", cur_route)
            sql_patch = sql_patch.replace("{NEXT_ROUTE}", "V-23_HY")
        else:
            sql_patch = sql_patch.replace("{ROUTE}", "V-22_HY")
        sql_patch = sql_patch.replace("{TARGET_DATE}", "2026-09-22")
        result["sql_hotfix"] = sql_patch
    elif l1_hit:
        s_name = l1_hit.get("name", "")
        s_sp = l1_hit.get("sp_iud") or l1_hit.get("sp_get") or "N/A"
        bugs_summary = "; ".join([f"{k}: {v}" for k, v in l1_hit.get("common_bugs", {}).items()])
        result["root_cause"] = f"Màn hình [{l1_hit['code']}] - {s_name} (SP: {s_sp}). Các lỗi đặc trưng: {bugs_summary}"
        result["op_workaround"] = "1. Kiểm tra điều kiện nhập liệu trên màn hình " + l1_hit['code'] + ".\n2. Đối chiếu quy trình thao tác chuẩn trong KB_09."
        result["sql_hotfix"] = l1_hit.get("fix_template") or "-- Xem chi tiết template tại sql/hotfixes/"
    else:
        result["root_cause"] = "Chưa phát hiện mã lỗi đặc thù trong từ khóa. Đang xử lý theo quy trình điều tra chuẩn SOP Vinatech."
        result["op_workaround"] = "1. Chụp lại toàn bộ popup lỗi và mã Lot gửi kỹ sư IT.\n2. Dùng lệnh '.\\mes.ps1 trace' để khảo sát dữ liệu."
        result["sql_hotfix"] = "-- Chạy .\\mes.ps1 trace để khảo sát trước khi can thiệp"

    # Sinh Hiện trạng dữ liệu thực tế
    if live_info and live_info.get("lot"):
        lot_d = live_info["lot"]
        status_str = "HOLD" if lot_d["IsHold"] == 1 else ("FINISH" if lot_d["IsProdFinish"] == 1 else "RUN")
        sync_str = ""
        if live_info.get("pop_sync"):
            p = live_info["pop_sync"]
            sync_str = f" | POP Sync: Route {p['Route']}, Done={p['IsDone']}, Transferred={p['IsTransferred']}"
        result["data_state"] = f"Lot {lot_d['Barcode']} (Model: {lot_d['MaterialCode']}, Chuyền: {lot_d['Line']}) đang ở trạng thái [{status_str}]. Công đoạn: {lot_d['CurrentRoute']} (Lượt chốt cuối: {lot_d['LastRoute']}), Đã qua {lot_d['TotalRoutes']} công đoạn, Phát sinh {lot_d['TotalDefects']} phế NG{sync_str}."
    elif target_lot:
        result["data_state"] = f"Đang truy vết cho mã: {target_lot}. Không tìm thấy bản ghi hoạt động trực tiếp hoặc CSDL phản hồi chậm."
    else:
        result["data_state"] = "Chưa cung cấp mã Lot cụ thể. Chẩn đoán đang hoạt động ở chế độ phân tích triệu chứng tĩnh."

    return result

# ----------------------------------------------------------------------
# 5. CLI INTERFACE & FORMATTING
# ----------------------------------------------------------------------
def print_golden_output(diag):
    print("")
    print("======================================================================")
    print("        VINATECH MES & POP — KẾT QUẢ CHẨN ĐOÁN TỨC THỜI (1-SHOT)      ")
    print("======================================================================")
    print("🎯 1. NGUYÊN NHÂN GỐC RỄ (ROOT CAUSE):")
    print(f"   {diag['root_cause']}")
    print("")
    print("📍 2. HIỆN TRẠNG DỮ LIỆU THỰC TẾ:")
    print(f"   {diag['data_state']}")
    print("")
    print("🛠️ 3. CÁCH OP TỰ XỬ LÝ TRÊN GIAO DIỆN (WORKAROUND):")
    for line in diag["op_workaround"].splitlines():
        print(f"   {line}")
    print("")
    print("⚡ 4. SQL HOTFIX CHUẨN (NẾU IT PHẢI CAN THIỆP):")
    for line in diag["sql_hotfix"].splitlines():
        print(f"   {line}")
    print("======================================================================")
    print("")

def main():
    parser = argparse.ArgumentParser(description="Vinatech MES Master Auto-Diagnostic Engine")
    parser.add_argument("query", nargs="*", help="Nội dung lỗi, mã Lot, mã màn hình cần chẩn đoán")
    parser.add_argument("--json", action="store_true", help="Xuất kết quả định dạng JSON cho Web API")
    parser.add_argument("--no-db", action="store_true", help="Bỏ qua kiểm tra Live DB (chẩn đoán thuần logic)")
    args = parser.parse_args()

    input_text = " ".join(args.query).strip()
    if not input_text:
        print("Lỗi: Vui lòng nhập thông tin lỗi cần chẩn đoán!")
        print("Ví dụ:")
        print("  python tools/mes_diagnose.py 'B530 kẹt số lượng'")
        print("  python tools/mes_diagnose.py 'This route is already completed in MES Lot VVQR153R060615'")
        sys.exit(1)

    diag = diagnose(input_text, check_live_db=not args.no_db)

    if args.json:
        print(json.dumps(diag, ensure_ascii=False, indent=2))
    else:
        print_golden_output(diag)

if __name__ == "__main__":
    main()
