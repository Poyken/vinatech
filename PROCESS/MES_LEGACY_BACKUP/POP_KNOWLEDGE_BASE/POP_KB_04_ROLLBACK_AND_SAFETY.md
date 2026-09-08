<!--
AI-READY METADATA
Purpose: Phân tích chi tiết khả năng Rollback/Hoàn tác trên POP Web UI + DB Safety Assessment
Scope: Mọi thao tác WRITE trên POP Web và khả năng hoàn tác tương ứng
Single Source of Truth: POP_KB_04_ROLLBACK_AND_SAFETY.md
Target Tables: STB_PackingInfo, STB_SetInfo, VINA_MATERIAL_INPUT_HIST, STB_ProdRouteHist
Related Files:
  - [POP_KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)
  - [POP_KB_02_SCREEN_OPERATIONS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_02_SCREEN_OPERATIONS.md)
  - [KB_04_PACKING](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04)
-->

# POP_KB_04 — Rollback & An Toàn Dữ Liệu (Rollback & Data Safety)

> **Phạm vi:** Phân tích toàn diện khả năng hoàn tác (rollback) cho MỌI thao tác ghi dữ liệu trên POP Web  
> **Xác minh:** Dựa trên Live UI Testing (2026-09-08) + API behavior analysis  
> **🔑 Keywords:** rollback, undo, cancel, hủy, hoàn tác, revert, safety, an toàn, xóa, delete  
> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)

---

## 1. 📊 TỔNG QUAN — BẢNG ROLLBACK MATRIX

> [!IMPORTANT]
> Bảng dưới đây tóm tắt khả năng rollback cho **từng loại thao tác** trên POP Web UI.
> ✅ = Có thể rollback trên UI | ⚠️ = Rollback hạn chế | ❌ = Không thể rollback trên UI

| # | Thao tác | Rollback trên UI | Cách thức | Rủi ro |
|---|----------|-----------------|-----------|--------|
| 1 | **Đăng nhập / Chọn Line** | ✅ Hoàn toàn | Đổi Line, logout bất kỳ lúc nào | Không rủi ro |
| 2 | **Chọn Work Order / DayPlan** | ✅ Hoàn toàn | Bỏ chọn, chọn WO khác | Không rủi ro (read-only) |
| 3 | **Chọn LOT** | ✅ Hoàn toàn | Click LOT khác | Không rủi ro (read-only) |
| 4 | **Nhập sản lượng / Đăng ký lỗi** | ✅ **CÓ THỂ (Trước khi chốt)** | Chuyển sang **Chế độ `SUB` Mode** trên Numpad để trừ bớt số đã đăng ký sai | An toàn tuyệt đối trước khi bấm "Ghi nhận sản xuất" |
| 5 | **Nhập NVL (Material Input)** | ❌ **Không thể** | Không có nút "Undo" trực tiếp trên UI | **Trừ kho tức thì** — cần SQL fix hoàn kho |
| 6 | **Hoàn thành SX (Ghi Nhận SX)** | ❌ **Không thể trên Web** | Không có nút Cancel sau khi đã chốt routing | Routing đã chuyển bước, cần MES Desktop WinForm |
| 7 | **Đóng gói (Packing)** | ✅ **CÓ THỂ** | Nút **"Hủy Đóng Gói"** trong Lịch sử đóng gói | Khôi phục trạng thái Lot chuẩn xác 100% |
| 8 | **In nhãn (Label Print)** | ✅ Hoàn toàn | In lại bất kỳ lúc nào qua modal in chuẩn 83x49mm | Không ảnh hưởng số liệu DB |
| 9 | **Điều chuyển kho (WH Transfer)**| ✅ **CÓ THỂ** | Mở lại `#wtModalPanel`, đảo chiều Kho Nhập ⇄ Kho Xuất | Tự khắc phục được ngay trên Kiosk |
| 10 | **Tự kiểm (Self-Inspection)** | ⚠️ **Hạn chế** | Chỉnh sửa số liệu trên trang `/pop/quality/self` trước khi submit | Sau khi submit lưu kết quả vào DB |

---

## 2. 🔍 PHÂN TÍCH CHI TIẾT TỪNG THAO TÁC

### 2.1 ✅ Đăng Nhập & Chọn Line/WO — AN TOÀN HOÀN TOÀN

**Bản chất:** Đây là các thao tác **read-only**, chỉ đọc dữ liệu từ DB, không ghi gì.

- **Chọn Line:** GET `/api/common/getLineList` → Chỉ đọc `STB_LineInfo`
- **Chọn WO:** GET `/api/pop/screen/getDayPlanList` → Chỉ đọc `STB_DayProdPlan`
- **Chọn LOT:** GET `/api/pop/screen/getLotList` → Chỉ đọc `STB_SetInfo`

**Kết luận:** Thoải mái thay đổi, không ảnh hưởng gì đến DB.

---

### 2.2 ⚠️ Nhập NVL (Material Input) — KHÔNG CÓ ROLLBACK TRÊN UI

**Hành vi DB khi bấm "Nhập":**
```
1. SmartFactoryV2.STB_MaterialLotInfo  
   → UPDATE: Qty = Qty - InputQty  (TRỪ KHO TỨC THÌ)
   
2. VINATECH_POP.VINA_MATERIAL_INPUT_HIST  
   → INSERT: Bản ghi log nhập NVL
   
3. SmartFactoryV2.STB_SetInfo  
   → UPDATE: IsLineInput = 1
```

**Trên UI:** 
- ❌ **KHÔNG CÓ** nút "Hủy nhập NVL" hoặc "Undo Material Input"
- ❌ Không thể nhập số âm để hoàn trả kho
- Sau khi bấm "NHẬP", kho đã bị trừ → **Không thể hoàn tác từ POP Web**

**Cách rollback (chỉ qua SQL):**
```sql
-- ⚠️ CHỈ DÙNG KHI CẦN THIẾT - Cần BEGIN TRAN...ROLLBACK trước
-- Bước 1: Tìm record nhập sai (đối chiếu cột thực tế của VINATECH_POP)
SELECT SEQ_NO, DAY_PLAN_NO, LOT_NO, BARCODE, SUB_MATERIAL_CODE, SUB_MATERIAL_NAME, INPUT_QTY, WORKER_ID, INPUT_DATE_TIME, STATUS, CANCEL_SEQ_NO
FROM VINATECH_POP.dbo.VINA_MATERIAL_INPUT_HIST WITH(NOLOCK)
WHERE LOT_NO = N'<LOT_NUMBER>' AND INPUT_DATE_TIME >= '<NGÀY>'
ORDER BY INPUT_DATE_TIME DESC;

-- Bước 2: Hoàn trả kho (cộng lại)
-- UPDATE SmartFactoryV2.dbo.STB_MaterialLotInfo 
-- SET Qty = Qty + <SốLượngĐãTrừ>
-- WHERE MaterialCode = N'<MÃ_NVL>' AND RouteCode = '<ROUTE>';

-- Bước 3: Đánh dấu hủy bản ghi nhập (Cập nhật CANCEL_SEQ_NO hoặc STATUS thay vì DELETE vật lý)
-- UPDATE VINATECH_POP.dbo.VINA_MATERIAL_INPUT_HIST 
-- SET STATUS = 'CANCEL', CANCEL_SEQ_NO = @CancelSeq, MODIFY_DATE = GETDATE()
-- WHERE SEQ_NO = @TargetSeqNo;
```

> [!CAUTION]
> Nhập NVL là thao tác **KHÔNG THỂ HOÀN TÁC** trên POP UI. Công nhân cần cẩn thận kiểm tra 
> mã NVL và số lượng TRƯỚC KHI bấm "NHẬP". Sai sót cần IT can thiệp bằng SQL.

---

### 2.3 ⚠️ Đăng Ký Phế Phẩm (Defect Registration) — HẠN CHẾ

**Hành vi DB:**
```
STB_ProdRouteHist → UPDATE: DefectQty += InputDefect
                     INSERT: Chi tiết loại lỗi (DefectType, DefectQty)
```

**Trên UI:**
- ✅ Có thể **sửa số lượng defect** trước khi hoàn thành công đoạn
- ❌ Sau khi bấm "Save Production", defect đã ghi cứng → không xóa được trên UI
- ⚠️ Defect Type đã chọn có thể thay đổi trước Save nhưng không sau

**Cách rollback (SQL):**
```sql
-- Kiểm tra defect đã ghi
SELECT * FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
WHERE SetNo = N'<LOT>' AND RouteSeq = <SEQ>
ORDER BY CreateDate DESC;
```

---

### 2.4 ❌ Hoàn Thành SX (Save Production) — KHÔNG THỂ ROLLBACK

**Hành vi DB:**
```
1. STB_ProdRouteHist → INSERT: Bản ghi routing mới (GoodQty, DefectQty)
2. STB_SetInfo → UPDATE: CurrentRoute move sang công đoạn tiếp theo
3. Logic FIFO/Interlock có thể trigger cascade
```

**Trên UI:**
- ❌ **TUYỆT ĐỐI KHÔNG CÓ** nút Undo/Cancel sau Save Production
- Sau Save, LOT đã di chuyển sang công đoạn tiếp → Không quay lại được
- Đây là hành vi **by design** — production move là one-way

**Cách rollback (chỉ DBA/IT):**
```sql
-- ⛔ CỰC KỲ NGUY HIỂM — Chỉ DBA thực hiện
-- Cần: DELETE ProdRouteHist mới + UPDATE STB_SetInfo.CurrentRoute về route cũ
-- Phải check toàn bộ cascade: PackingInfo, MaterialLotInfo, etc.
-- KHÔNG BAO GIỜ LÀM MÀ KHÔNG CÓ BACKUP TRƯỚC
```

> [!WARNING]
> Save Production là thao tác **MỘT CHIỀU** (irreversible) trên cả POP Web và MES Desktop.
> Công nhân cần xác nhận đúng số lượng OK/NG trước khi Save.

---

### 2.5 ✅ Đóng Gói (Packing) — CÓ THỂ ROLLBACK TRÊN UI

**Đây là thao tác DUY NHẤT có chức năng rollback hoàn chỉnh trên POP Web UI.**

**Cách rollback đóng gói trên UI:**

1. Vào công đoạn **Đóng gói (Packing)** trên menu bên trái
2. Bấm nút **"Lịch sử đóng gói"** (History) — thường là icon 📋 hoặc nút ở thanh công cụ
3. Tìm bản ghi đóng gói cần hủy trong danh sách
4. Bấm nút **"Hủy đóng gói"** (Cancel Packing / 취소)
5. Xác nhận hủy → Hệ thống tự động:

```
Khi bấm "Hủy Đóng Gói":
1. STB_PackingInfo → DELETE hoặc UPDATE Status = 'Cancelled'
2. STB_SetInfo → REVERT: PackedQty, PackingStatus về trạng thái trước
3. VINA_PACKING_LOG → INSERT: Log hủy đóng gói
4. BoxID → Released (có thể dùng lại)
```

**Điều kiện để hủy được:**
- ✅ Đóng gói chưa in tem (PrintFlag = 0)
- ✅ Box chưa xuất kho (ShipFlag = 0)  
- ❌ Nếu đã in tem → Cần hủy tem trước rồi mới hủy đóng gói
- ❌ Nếu đã xuất kho → Không thể hủy trên UI

> [!TIP]
> **Best Practice:** Nếu đóng gói sai, hủy NGAY trước khi in tem. Sau khi in tem, quy trình 
> hủy phức tạp hơn nhiều và có thể cần can thiệp IT.

---

### 2.6 ✅ In Nhãn (Label Print) — AN TOÀN

**Bản chất:** In nhãn là thao tác **read + print**, không thay đổi state dữ liệu chính.

- Chỉ UPDATE cờ `PrintFlag = 1` và `PrintDate`
- In lại nhãn bất kỳ lúc nào qua nút "In lại" trong Lịch sử đóng gói
- Không gây side-effect nào trên kho/sản lượng

---

### 2.7 ⚠️ Quality Inspection — HẠN CHẾ

**Trước Submit Final:**
- ✅ Sửa kết quả kiểm tra (Pass/Fail, giá trị đo)
- ✅ Thay đổi mẫu kiểm tra
- ✅ Hủy toàn bộ và bắt đầu lại

**Sau Submit Final:**
- ❌ Không sửa được trên UI
- Cần admin MES hoặc SQL intervention
- Kết quả QC đã ghi vào bảng `STB_Quality*` là cố định

---

## 3. 📋 BẢNG TÓM TẮT — HƯỚNG DẪN AN TOÀN CHO CÔNG NHÂN

| Thao tác | Trước khi bấm, kiểm tra | Nếu sai, cách xử lý |
|----------|-------------------------|---------------------|
| **Nhập NVL** | ✅ Đúng mã NVL, đúng số lượng, đúng LOT | 🔴 Báo IT ngay — cần SQL fix |
| **Đăng ký lỗi** | ✅ Đúng loại lỗi, đúng số lượng | 🟡 Sửa trước Save, sau Save → báo IT |
| **Save Production** | ✅ Đúng SL OK/NG, đúng công đoạn | 🔴 Báo IT ngay — irreversible |
| **Đóng gói** | ✅ Đúng LOT, đúng SL, đúng kho | 🟢 Hủy trên UI (Lịch sử → Hủy đóng gói) |
| **In tem** | ✅ Đúng LOT/Box | 🟢 In lại bất kỳ lúc nào |
| **Quality** | ✅ Đúng giá trị đo, đúng mẫu | 🟡 Sửa trước Submit → OK; sau → báo QC Manager |

---

## 4. 🛡️ NGUYÊN TẮC AN TOÀN KHI TEST TRÊN PRODUCTION

> [!CAUTION]
> POP Web kết nối **TRỰC TIẾP** tới Production DB. Mọi thao tác đều ảnh hưởng dữ liệu thật.

### 4.1 Các Thao Tác AN TOÀN Khi Khảo Sát
- ✅ Đăng nhập, chọn Line, xem danh sách WO/LOT
- ✅ Xem chi tiết LOT, kiểm tra BOM, xem tồn kho
- ✅ Duyệt menu Quality (IQC/PQC/OQC) ở chế độ xem
- ✅ Xem Lịch sử đóng gói
- ✅ Chuyển đổi ngôn ngữ, Dark/Light mode

### 4.2 Các Thao Tác CẦN THẬN TRỌNG
- ⚠️ Bấm "NHẬP" NVL → Trừ kho thật
- ⚠️ Bấm "Save" Production → Move routing thật
- ⚠️ Submit Quality Inspection → Ghi kết quả QC thật

### 4.3 Đánh Giá Rủi Ro Phiên Test 2026-09-08
- **Kết quả:** Phiên test chỉ thực hiện các thao tác **READ-ONLY** (xem, duyệt menu, kiểm tra UI)
- **Không có thao tác WRITE** nào được thực hiện (không nhập NVL, không Save, không đóng gói)
- **Impact trên DB:** ZERO — Không có dữ liệu nào bị thay đổi
- **Rollback cần thiết:** Không — Không có gì cần rollback

---

## 5. 🔧 SQL SCRIPTS — KIỂM TRA IMPACT SAU THAO TÁC

### 5.1 Kiểm tra có nhập NVL gần đây không
```sql
SELECT TOP 20 LotNo, MaterialCode, InputQty, InputDate, ProcessUser
FROM VINATECH_POP.dbo.VINA_MATERIAL_INPUT_HIST WITH(NOLOCK)
WHERE InputDate >= DATEADD(HOUR, -2, GETDATE())
ORDER BY InputDate DESC;
```

### 5.2 Kiểm tra đóng gói gần đây
```sql
SELECT TOP 20 BoxID, LotNo, PackQty, PackDate, CancelFlag
FROM VINATECH_POP.dbo.VINA_PACKING_LOG WITH(NOLOCK)
WHERE PackDate >= DATEADD(HOUR, -2, GETDATE())
ORDER BY PackDate DESC;
```

### 5.3 Kiểm tra routing move gần đây
```sql
SELECT TOP 20 SetNo, RouteSeq, GoodQty, DefectQty, CreateDate, ProcessUserID
FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
WHERE CreateDate >= DATEADD(HOUR, -2, GETDATE())
ORDER BY CreateDate DESC;
```
