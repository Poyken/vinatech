## 7. 📋 CASE STUDY THỰC TẾ — Phương Pháp Truy Vết Từ Đầu Đến Cuối

### 7.1 Case Study: B353 chuyển đổi Lot nhưng B523 vẫn in tem Lot cũ (VJ/VV Prefix Mismatch)

> **Ngày:** 2026-06-18 | **Lot:** `VJQM153R025606` → `VVQM153R025606` | **Model:** `ECVT30-255`
> **Báo lỗi:** "Lot đã chuyển đổi ở màn B353 nhưng ra màn B523 in tem thì vẫn là lot cũ"

#### Bước 1: Thu thập triệu chứng
| Thông tin | Giá trị |
|-----------|---------|
| Màn hình gốc | B353 (Thay đổi tên lot hàng) |
| Màn hình lỗi | B523 (In tem đóng gói) |
| Barcode gốc (DB) | `VVQM153R025606` |
| Lot cũ (in tem) | `VJQM153R025606` |
| Lot mới (mong muốn) | `VVQM153R025606` |

#### Bước 2: Xác định Entry Point (UI → SP)
```sql
-- Tìm SP đằng sau B523 (in tem)
SELECT ObjectName, ObjectType FROM SmartFramework.dbo.STB_ScreenObjects 
WHERE ScreenName = (SELECT Name FROM SmartFramework.dbo.STB_ScreenInfo WHERE TCode = 'B523')
-- → SearchFunction: usp_Vietnam_GetBoxIDForLotNo_VVT (load data in tem)
```

#### Bước 3: Kiểm tra sức khỏe dữ liệu
```sql
-- 3a. Bản ghi B353 có lưu thành công không?
SELECT id, oldLotID, NewLotID, isLotID FROM STB_ChangePartNoAndLotNo WITH(NOLOCK)
WHERE oldLotID LIKE '%QM153R025606%' OR NewLotID LIKE '%QM153R025606%'
-- → ID=1572, oldLotID='VJQM153R025606', NewLotID='VVQM153R025606' ✅

-- 3b. Lịch sử B351?
SELECT * FROM STB_LotChangeMaterialHistory WHERE OldBarcode LIKE '%QM153R025606%'
-- → 0 rows ❌

-- 3c. Cấu hình auto VJ?
SELECT PrintVJ, MaterialCode FROM STB_Vietnam_PackingPrinting WITH(NOLOCK)
WHERE MaterialCode = 'ECVT30-255'
-- → PrintVJ = True ⚠️
```

#### Bước 4: Root Cause — Trace logic SP từng biến

| Bước | Dòng SP | Biến | Giá trị | Kết quả |
|------|---------|------|---------|---------|
| 1 | Input | `@LotNo` | `VVQM153R025606` | Barcode gốc DB |
| 2 | ~545 | `@LotNoFirst` | `NULL` | Không có trong STB_LotChangeMaterialHistory |
| 3 | ~548 | Lookup STB_ChangePartNoAndLotNo | `WHERE oldLotid=NULL OR oldLotid='VVQM...'` | ❌ MISS — bảng lưu VJ prefix |
| 4 | ~644 | CASE condition | `NULL = NULL` → FALSE | Skip conversion |
| 5 | ~754 | Fall-through | `@allowVJ=1` → `STUFF(LotNo,1,2,'VJ')` | Auto VJ ghi đè |

**Root Cause:** B353 lưu `oldLotID` với **VJ prefix** nhưng SP tra cứu bằng `@LotNo` có **VV prefix** → lookup miss.

#### Bước 5: Fix SP — Tóm tắt giải pháp

**Giải pháp:** Thêm 2 sửa đổi vào `usp_Vietnam_GetBoxIDForLotNo_VVT`:
1. **IF fallback block** (sau dòng ~548): Nếu lookup VV miss → thử STUFF thành VJ để tìm
2. **CASE condition mở rộng** (dòng ~644): Thêm guard `@newLotid IS NOT NULL`

**3 lớp guard an toàn:** `IF @oldLotid IS NULL` (chặn collision) + `LIKE 'VV%'` (chặn module lot) + `@newLotid IS NOT NULL` (chặn lot bình thường)

> 🔗 **SQL code fix chi tiết + diff:** Xem [KB_04 §6.18](../KB_04/KB_04_01_CORE_PACKAGING.md)

#### Bước 6: Kiểm chứng — Kết quả thực tế (2026-06-18)

| Chỉ số | Giá trị | Đánh giá |
|--------|---------|----------|
| Collision pairs (VV+VJ cùng tồn tại) | 4 cặp | ✅ Guard chặn |
| Lot VJ-only bị bug | 122 | Fix tác động đúng |
| Lot affected qua MaterialLotInfo | 58/58 valid, 0 false positive | ✅ An toàn |
| Module lots (MVV prefix) | 20,368 | ✅ Guard chặn 100% |

> 🔗 **Query kiểm chứng collision + false positive:** Xem [KB_04 §6.18](../KB_04/KB_04_01_CORE_PACKAGING.md)

#### Bài học rút ra
1. **VJ/VV prefix mismatch** là nguồn lỗi phổ biến — luôn kiểm tra cả 2 biến thể
2. **`NULL = NULL` → FALSE** trong SQL — tránh dùng `=` so sánh giá trị có thể NULL
3. **Có 4 cặp lot VV/VJ đều tồn tại** — fix mù quáng sẽ collision
4. **Khi debug lot conversion**: check đồng thời STB_LotChangeMaterialHistory (B351) + STB_ChangePartNoAndLotNo (B353) + STB_Vietnam_PackingPrinting (auto VJ)
5. **Trước khi sửa SP production**: chạy query kiểm chứng collision + false positive + write impact

> 🔗 **Chi tiết đầy đủ:** Xem KB_04 §6.18
---

### 7.2 Case Study: B442 in tem Electrode lỗi "Not found label type" + Độ dày = 0

> **Ngày:** 2026-06-18 | **Màn hình:** B442 (Kế hoạch Điện cực) | **Model:** `CRFYL85-01` (120µ), `CRFYN85L-01` (180µ)
> **Báo lỗi 1:** Cột "Độ dày" hiển thị `0.00` trên grid SetInfo
> **Báo lỗi 2:** Bấm in tem → popup `"Not found label type"`

#### Bước 1: Xác định Entry Point

**UI Trace (F5 → F4):**
```
F5 (Object) → [B442] ElectrodePlan_Vietnam
├── Search Function: usp_DayProdPlan_get, usp_SetInfo_get, usp_MainAssemblePartWeight_get
├── Execute Function: usp_SetInfo_iud_VNT
└── Action: LabelPrint → ActionType = PrintLabel
    └── Print Label options (라벨인쇄):
        • 라벨유형 필드 = LabelType          ← cột nào chứa loại tem
        • 참조뷰 이름 = SetInfo              ← data lấy từ grid SetInfo
        • 포맷형 필드 = FormatName           ← cột chứa tên template
```

**SQL Trace (SP JOIN chain):**
```sql
-- Trong usp_SetInfo_get: 3 bảng JOIN quyết định in tem
LEFT JOIN STB_MaterialMaster MM       ON MM.MaterialCode = SI.MaterialCode     -- → MaterialName (nội dung tem)
LEFT JOIN STB_ModelLabelInfo MLI      ON MLI.ModelCode = SI.MaterialCode        -- → FormatName (template nào)
                                     AND MLI.LabelType = @LabelType            -- ❌ Thiếu = "Not found label type"
LEFT JOIN LabelInfo LBI (Z530)       ON LBI.FormatName = MLI.FormatName        -- → XML layout
```

> 🔗 **Hướng dẫn trace đầy đủ:** Xem KB_04 §6.0.3
#### Bước 2: Debug "Độ dày = 0" (SIExtReal03)
```sql
-- Kiểm tra SetInfo
SELECT Barcode, MaterialCode, SIExtReal03 AS Thickness FROM STB_SetInfo WITH(NOLOCK) 
WHERE MaterialCode IN ('CRFYL85-01','CRFYN85L-01')
-- → SIExtReal03 = 0.00 ❌

-- Kiểm tra logic auto-fill trong usp_DayProdPlan_get:
-- CASE WHEN SI.SIExtReal03 IS NOT NULL THEN SI.SIExtReal03
--      ELSE CONVERT(NUMERIC(20,5), ISNULL(MM.MaterialThickness, '0.0'))
-- END AS SIExtReal03
-- → Lấy từ STB_MaterialMaster.MaterialThickness

-- Kiểm tra MaterialThickness
SELECT MaterialCode, MaterialThickness FROM STB_MaterialMaster WITH(NOLOCK)
WHERE MaterialCode IN ('CRFYL85','CRFYL85-01','CRFYN85L','CRFYN85L-01')
-- → Model cũ: 120/180 ✅ | Model mới: '' (rỗng) ❌
```

**Root Cause 1:** Model mới chưa được cấu hình `MaterialThickness` tại A230 (MaterialMaster).

**Fix 1:** Vào A230 hoặc chạy SQL set `MaterialThickness`.

> 🔗 **SQL fix chi tiết:** Xem [KB_04 §6.20](../KB_04/KB_04_01_CORE_PACKAGING.md) — checklist + query UPDATE MaterialThickness

#### Bước 3: Debug "Not found label type" (LabelPrint)
```sql
-- Kiểm tra STB_ModelLabelInfo (bảng mapping Model → LabelType)
SELECT ModelCode, LabelType, FormatName FROM STB_ModelLabelInfo WITH(NOLOCK) 
WHERE ModelCode IN ('CRFYL85','CRFYL85-01','CRFYN85L','CRFYN85L-01')
-- → Model cũ: có ElectLabel, AssembleLabel, PartLabel ✅
-- → Model mới: 0 rows ❌
```

**Root Cause 2:** Model mới chưa có record trong `STB_ModelLabelInfo` → client B442 tìm LabelType → không tìm thấy → exception.

**Fix 2:** Vào A460 thêm hoặc chạy SQL copy từ model cũ.

> 🔗 **SQL fix chi tiết:** Xem [KB_04 §6.20](../KB_04/KB_04_01_CORE_PACKAGING.md) — INSERT INTO STB_ModelLabelInfo template

#### Bước 4: Data Flow tổng thể
```
A230 (MaterialMaster) ─── MaterialThickness ───→ STB_MaterialMaster
         ↓                                              ↓
A460 (LabelInfo) ── LabelType/FormatName ──→ STB_ModelLabelInfo    usp_DayProdPlan_get
         ↓                                              ↓               ↓ (auto-fill)
B442 (ElectrodePlan) ─── LabelPrint ───→ Tìm LabelType      STB_SetInfo.SIExtReal03
         ↓                                 ↓                       ↓
    Exception nếu thiếu              "Not found label type"     Tem hiển thị "Độ dày"
```

#### Bước 5: Checklist thêm model Electrode mới (CRF%)
1. ☐ **A230** → `STB_MaterialMaster.MaterialThickness` = giá trị đúng (120/180/200...)
2. ☐ **A460** → `STB_ModelLabelInfo`: thêm `ElectLabel` (bắt buộc) + `AssembleLabel`, `PartLabel` (tùy dây chuyền)
3. ☐ **Verify:** Tạo lot test tại B442 → kiểm tra cột "Độ dày" → bấm in tem

#### Bài học rút ra
1. Lỗi in tem Electrode thường do **2 nguyên nhân đồng thời**: thiếu MaterialThickness + thiếu LabelType
2. **`STB_ModelLabelInfo`** là bảng ẩn quan trọng — không thấy rõ trên UI nhưng quyết định in tem có thành công không
3. **Luôn copy config từ model cũ cùng loại** khi thêm model mới — tránh bỏ sót
4. **Stack trace `Awoo.SmartFramework...PrintLabel`** → 100% là thiếu LabelType trong `STB_ModelLabelInfo`

> 🔗 **Chi tiết fix:** Xem KB_04 §6.20, KB_05 (Electrode), KB_01 §1.2


---

*Cập nhật: 2026-06-18 | Tổng hợp 12 nhóm Validation Gates + Case Study B353/B523 + B442 Electrode bởi Antigravity AI.*

