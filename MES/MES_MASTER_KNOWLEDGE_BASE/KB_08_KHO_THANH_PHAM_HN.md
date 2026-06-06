# KB_08 — Kho Thành Phẩm (HN) & Xuất Kho

> **Màn hình liên quan:** HN551, HN544, HN866, HNC321, HN00, HN101, FG00
> ← [Về INDEX](KB_INDEX.md)

---

## 1. Lỗi Hàng xuất ở HN551 nhưng tồn kho HN866 vẫn còn

**Tư duy trace:**
- **HN551 (Xuất):** Ghi vào `STB_VN_FINISHGOODS_HN_Export` và đánh dấu "đã đi" vào sổ tồn kho.
- **HN866 (Tồn):** Chỉ đọc sổ tồn kho — cái nào `QtyOutput = 0` thì hiện lên.
- **Nguyên nhân thường gặp:** HN551 đã ghi sổ xuất nhưng **quên cập nhật** sổ tồn kho.

```sql
DECLARE @PackingID NVARCHAR(50) = 'PKHN023117'

-- BƯỚC 1: Kiểm tra trạng thái xuất kho
SELECT CodeExport, PackingID, LotNo, Qty, StatusExport, CreateDateTime
FROM STB_VN_FINISHGOODS_HN_Export WHERE PackingID = @PackingID

-- BƯỚC 2: Kiểm tra tồn kho thực tế
-- QtyOutput = 0 nhưng BƯỚC 1 có data → LỖI LOGIC TRỪ KHO
SELECT PackingID, Quantity, QtyOutput
FROM FinishGoodMESInstock_HN WHERE PackingID = @PackingID

-- BƯỚC 3: Kiểm tra Packing là "Tem To" hay "Tem Nhỏ"
SELECT PackingID FROM STB_PackingOutPutFinishGoods_HN
WHERE PackingOutPutFinishGoodsID = @PackingID
-- Có kết quả → Tem To → xuất 1 mã này sẽ tự động xuất các box con bên trong
```

**Fix (nếu QtyOutput sai):**
```sql
-- ⚠️ Xác minh DB (2026-05-17): Bảng KHÔNG có cột StatusInstock — chỉ có QtyOutput
UPDATE FinishGoodMESInstock_HN
SET QtyOutput = Quantity
WHERE PackingID = @PackingID

UPDATE STB_VN_FINISHGOODS_HN_Export
SET StatusExport = 1
WHERE PackingID = @PackingID
```

> **SP xuất kho:** `ExportWarehouseFinshGoodInventory_uid`

---

## 2. Phân biệt Tem To và Tem Nhỏ (Hà Nam)

| Loại tem | Định nghĩa | Bảng DB | Khi xuất |
|----------|-----------|---------|---------|
| **Tem To** (Pallet/Gộp) | Đại diện cho nhiều thùng gộp lại | `STB_PackingOutPutFinishGoods_HN` | Tự động xuất tất cả box con bên trong |
| **Tem Nhỏ** (Box đơn) | Dán trên từng thùng riêng lẻ | Không có trong bảng trên | Xuất từng box riêng |

```sql
-- Kiểm tra PackingID là Tem To hay Tem Nhỏ
SELECT COUNT(*) AS [SoKetQua]
FROM STB_PackingOutPutFinishGoods_HN
WHERE PackingOutPutFinishGoodsID = 'PKHN023117'
-- Có kết quả → Tem To | Không có → Tem Nhỏ
```

---

## 2.1 Lỗi Unique Constraint khi Gộp Túi Bóng (HN544) — PKQN2100175

**Triệu chứng:** Khi User nhập `Packing ID: PKQN2100175` trên màn hình **[HN544] Gộp túi bóng thành hộp nhỏ** và nhấn Tìm kiếm, hệ thống báo lỗi:
> **Column 'LotID' is constrained to be unique. Value '63RHHL180ME16XB001QN2100012' is already present.**

#### 🔴 Nguyên nhân gốc rễ:
Stored Procedure `usp_GetMaterialLotInfo_Packing_VVT_F3` sử dụng `UNION ALL` để gộp 3 truy vấn:

1. **Truy vấn 1:** Quét `STB_MaterialLotInfo` có `PackingID = 'PKQN2100175'` → Tìm **1 dòng** (LotID: `63RHHL180ME16XB001QN2100012`)
2. **Truy vấn 2:** Quét từ `STB_PackingNilonToBoxSmall_HN` (hộp nhỏ gộp)
3. **Truy vấn 3 (LỖI):** Quét `STB_DividePackaging` có `PackingID = 'PKQN2100175'`
   - Dòng này là **mã cha chưa được chia tách**, nên cột `PackingParentID` bị **NULL/trống**
   - JOIN condition: `LEFT JOIN STB_MaterialLotInfo MLI ON MLI.LotNo = DP.LotNo and MLI.PackingID = DP.PackingParentID`
   - Vì `DP.PackingParentID = NULL`, LEFT JOIN không khớp → **trả về dòng dummy với `LotID = NULL`**
   - Kết quả: Truy vấn 3 trả về **dòng thứ 2 có `LotID = NULL`**

4. **Khi DataTable nhận dữ liệu:** DataTable có constraint `Unique = true` trên cột `LotID`
   - Client-side code điền giá trị mặc định từ dòng 1 → **Duplicate LotID**
   - Ngoại lệ được ném ra

#### 🛠️ **Giải pháp:**

**Script 1: Hủy giao dịch lỗi (Revert Merge)**
```sql
BEGIN TRANSACTION;
BEGIN TRY

    -- 1. SAO LƯU BẢNG HỘP NHỎ TRƯỚC KHI XÓA
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'STB_PackingNilonToBoxSmall_HN_BK')
    BEGIN
        SELECT * INTO STB_PackingNilonToBoxSmall_HN_BK 
        FROM STB_PackingNilonToBoxSmall_HN 
        WHERE PackingNilonToBoxSmallID = 'PK202605210000000005';
    END
    ELSE
    BEGIN
        INSERT INTO STB_PackingNilonToBoxSmall_HN_BK
        SELECT * 
        FROM STB_PackingNilonToBoxSmall_HN 
        WHERE PackingNilonToBoxSmallID = 'PK202605210000000005';
    END

    -- 2. XÓA GIAO DỊCH LỖI Ở STB_DividePackaging
    DELETE FROM STB_DividePackaging 
    WHERE PackingID = 'PKQN2100175';
    
    -- 3. XÓA RECORD HỘP NHỎ
    DELETE FROM STB_PackingNilonToBoxSmall_HN 
    WHERE PackingNilonToBoxSmallID = 'PK202605210000000005';

    COMMIT TRANSACTION;
    PRINT '==> HOÀN THÀNH HỦY GIAO DỊCH THÀNH CÔNG!';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '==> CÓ LỖI XẢY RA. ĐÃ ROLLBACK!';
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
```

**Script 2: Sửa Stored Procedure (Ngăn chặn lỗi lặp lại)**

Sửa đổi câu truy vấn 3 để loại trừ các mã cha chưa phân tách:

```sql
USE [SmartFactoryV2]
GO

-- Tìm ra phần UNION ALL cuối cùng (truy vấn 3)
-- Thêm điều kiện: AND ISNULL(DP.PackingParentID, '') <> ''

-- THÊM DÒNG NÀY vào cuối WHERE clause của UNION ALL thứ 3:
WHERE DP.PackingID = @pPackingID  
  AND ISNULL(DP.PackingParentID, '') <> ''  -- ← DÒNG MỚI
```

> **SP đầy đủ:** Xem tệp [hn544_error_analysis.md](c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop.worktrees/agents-sql-command-line-execution/database/docs/hn544_error_analysis.md) để copy toàn bộ ALTER PROCEDURE

---

## 3. Lỗi Lot bị đổi MaterialCode sau khi sản xuất (VD: 5H1 → 6D1)

**Triệu chứng:** Hàng đang nhập liệu với Making = 5H1 nhưng sau đó trên hệ thống bị chuyển sang 6D1.

```sql
-- Bước 1: Kiểm tra MaterialCode hiện tại
SELECT SI.Barcode, SI.MaterialCode, SI.InputLineCode, SI.CreateDateTime
FROM STB_SetInfo SI
WHERE SI.Barcode IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')

-- Bước 2: Kiểm tra lịch sử thay đổi MaterialCode
SELECT * FROM STB_LotChangeMaterialHistory
WHERE NewBarcode IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')
   OR OldBarcode IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')
ORDER BY CreateDateTime DESC

-- Bước 3: Fix — đổi lại MaterialCode đúng
UPDATE STB_SetInfo SET MaterialCode = '5H1_MATERIAL_CODE_ĐÚNG'
WHERE Barcode IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')

UPDATE STB_MaterialLotInfo SET MaterialCode = '5H1_MATERIAL_CODE_ĐÚNG'
WHERE LotNo IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')

### 3.1 Đăng ký thay đổi mã vật tư thủ công qua STB_ChangeMaterialCode_HN (Màn hình HN15)
Trong một số trường hợp tại nhà máy Hà Nam, khi người dùng thực hiện thay đổi mã vật tư cho Lot đóng gói và cần ghi nhận lịch sử vào hệ thống để theo dõi và đồng bộ kho, ta thực hiện chèn dữ liệu lịch sử đổi mã vật tư:
```sql
INSERT INTO STB_ChangeMaterialCode_HN (
    oldMaterialCode, 
    IsUsed, 
    CreateDateTime, 
    CreateUserID, 
    NewMaterialCode, 
    PackingID, 
    LotID
)
VALUES (
    '2VSC820MC8XXXXVC01', -- Mã vật tư cũ
    1,                    -- Trạng thái sử dụng (Active)
    GETDATE(),            -- Ngày tạo
    'vanduc',             -- User thực hiện
    '2RSC820MC7XXXXB001', -- Mã vật tư mới
    'PKQN1100015',        -- Mã thùng đóng gói (PackingID)
    'SP260511-001'        -- Mã Lot sản phẩm (LotID)
);
```

---

## 4. Lỗi màn HNC321 (Qc nhập NG sản phẩm mang đi kiểm tra — Báo lỗi chữ Hàn Quốc)

**Triệu chứng:** Nhập phế liệu (NG) ở màn hình **HNC321** cho Barcode `ve260509-001` tại công đoạn `VE08` báo lỗi đỏ **Failed to save** với nội dung tiếng Hàn:
`이전 공정에 실적처리 이력이 없습니다.`
*(Dịch nghĩa: Không có lịch sử xử lý sản lượng ở công đoạn trước).*

#### 🔍 Nguyên nhân gốc rễ:
Stored Procedure xử lý (`usp_Vietnam_ScrapInput_HN`) chặn không cho phép nhập phế liệu tại công đoạn `VE08` nếu sản phẩm này chưa từng được scan ghi nhận sản lượng hoàn thành (Routing History) ở công đoạn ngay trước đó (Ví dụ: `VE07` hoặc trạm trước của `VE08` trong cấu hình Routing của PO).

#### 🛠️ Giải pháp khắc phục:

*   **Phương án 1 (Bypass nghiệp vụ trên giao diện):**
    Yêu cầu công nhân quay lại công đoạn trước (Ví dụ: `VE07`), thực hiện scan chốt sản lượng cho Barcode `ve260509-001` trước để tạo "Visa stamp" lịch sử. Sau đó quay lại màn **HNC321** nhập phế sẽ lưu thành công.

*   **Phương án 2 (Bypass khẩn cấp bằng SQL - Kỹ thuật chèn lịch sử giả lập):**
    Nếu hàng đã bị phế thực tế và công đoạn trước không thể scan lại, IT chèn một dòng lịch sử sản lượng giả lập cho công đoạn trước vào bảng `STB_ProdRouteHist`:

    ```sql
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Tìm mã ControlNo của Barcode bị lỗi
        DECLARE @ControlNo NVARCHAR(50);
        SELECT @ControlNo = ControlNo FROM STB_SetInfo WHERE Barcode = 've260509-001';

        -- 2. Tìm công đoạn ngay trước VE08 trong PO Routing (Ví dụ: VE07)
        SELECT RouteCode, RouteIndex 
        FROM STB_ProductionOrderRouting 
        WHERE PONo = (SELECT PONo FROM STB_SetInfo WHERE Barcode = 've260509-001')
        ORDER BY RouteIndex ASC;

        -- 3. Chèn dòng lịch sử giả lập cho công đoạn trước (Ví dụ: VE07)
        -- Sử dụng ProcSeq tiếp theo để tránh trùng PK
        INSERT INTO STB_ProdRouteHist 
            (ControlNo, ProcSeq, RouteCode, LineCode, MachineCode, InQty, OutQty, JobDate, ShiftCode, CreateUserID, CreateDateTime)
        VALUES 
            (@ControlNo, 
             (SELECT ISNULL(MAX(ProcSeq), 0) + 1 FROM STB_ProdRouteHist WHERE ControlNo = @ControlNo), 
             'VE07',            -- Thay thế bằng mã công đoạn trước VE08
             'MCVC20220',       -- Mã Line/Máy
             'MCVC20220',       -- Mã Máy
             20, 20,            -- Số lượng
             CAST(GETDATE() AS DATE), 'A', 
             'vinaadmin', GETDATE());

        COMMIT TRANSACTION;
        PRINT 'Đã chèn lịch sử giả lập thành công. Hãy bảo công nhân bấm Save lại trên UI!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Lỗi chèn lịch sử: ' + ERROR_MESSAGE();
    END CATCH;
    ```

---

## 5. Xóa nhập sản lượng công đoạn (VD: VE260509-004)

**Triệu chứng:** Cần hủy/xóa dữ liệu nhập sản lượng ở 1 công đoạn cụ thể.

> ⚠️ **Lưu ý:** Xóa phiếu F330 (nhập kho NVL) cần xóa IQC trước (nếu có).

**Xóa sản lượng công đoạn:**
```sql
-- Bước 1: Xem lịch sử routing của Barcode
SELECT * FROM STB_ProdRouteHist
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260509-004')
ORDER BY ProdDateTime DESC

-- Bước 2: Xóa dòng lịch sử routing cần xóa (VD: VE08)
DELETE FROM STB_ProdRouteHist
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260509-004')
AND RouteCode = 'VE08'

-- Bước 3: Reset DefectQty nếu cần
UPDATE STB_SetInfo
SET DefectQty = 0, IsDefect = 0
WHERE Barcode = 'VE260509-004'
-- Chỉ làm nếu DefectQty thực sự cần reset
```

**Xóa phiếu nhập kho F330 (có IQC):**
👉 **Chi tiết Script Fix:** Xem tại [KB_02_KHO_WMS.md § 4.16](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/database/MES_MASTER_KNOWLEDGE_BASE/KB_02_KHO_WMS.md)

---

## 6. HN00 — Tồn Kho Thành Phẩm Hà Nam

**Chức năng:** Màn hình quản lý thành phẩm riêng cho nhà máy **Hà Nam (VVT_F3)**.

- Route: Hà Nam dùng prefix `VE-` (thay vì `V-` của Bắc Ninh)
- Barcode: `VE260507-001` format
- Đơn giá: Lấy từ **HN101** theo mã kế toán

```sql
-- Kiểm tra tồn kho thành phẩm Hà Nam
SELECT PackingID, MaterialCode, Quantity, QtyOutput,
       Quantity - QtyOutput AS [TonThucTe]
FROM FinishGoodMESInstock_HN
WHERE Quantity - QtyOutput > 0
ORDER BY CreateDateTime DESC
```

---

## 7. HN101 — Thiết Lập Đơn Giá Theo Mã Kế Toán

**Chức năng:** Thiết lập đơn giá → hệ thống tự động tính tiền theo mã kế toán hiển thị tại HN00.

**Quy trình:** Tìm kiếm → (+) Thêm → Điền đầy đủ → Lưu

```sql
-- Kiểm tra đơn giá đã có chưa
SELECT * FROM STB_HN_AccountingPrice WHERE MaterialCode = 'Mã_Model'

-- Thêm đơn giá mới
INSERT INTO STB_HN_AccountingPrice (MaterialCode, AccountingCode, Price, CreateDateTime, CreateUserID)
VALUES ('Mã_Model', 'Mã_Kế_Toán', 0.254, GETDATE(), 'vinaadmin')
```

---

## 8. FG02 — Kho Thành Phẩm Bắc Giang (FG00)

**Chức năng:** Màn hình quản lý thành phẩm riêng cho nhà máy **Bắc Giang (VVT_F2)**.

- Route: Bắc Giang dùng prefix `V-` (thay vì `VE-` của Hà Nam)
- Barcode: `VVXX123R000001` format
- Bảng: `STB_VN_FINISHGOODS_BG`

```sql
-- Kiểm tra tồn kho thành phẩm Bắc Giang
SELECT IDCODE, MaterialCode, Quantity, CreateDate, DateExport
FROM STB_VN_FINISHGOODS_BG
WHERE CreateDate >= DATEADD(DAY, -30, GETDATE())
ORDER BY CreateDate DESC
```

**Sửa ngày màn FG00:**
```sql
-- Xem trước
SELECT IDCODE, CreateDate, DateExport FROM STB_VN_FINISHGOODS_BG
WHERE IDCODE = 'FGVN_BG20250211054041195484931'

-- Sửa cả 2 cột ngày
UPDATE STB_VN_FINISHGOODS_BG
SET CreateDate = CAST('2025-01-11' AS DATE),
    DateExport = CAST('2025-01-11' AS DATE)
WHERE IDCODE = 'FGVN_BG20250211054041195484931'
```

**So sánh HN00 vs FG00:**

| Đặc điểm | HN00 (Hà Nam) | FG00 (Bắc Giang) |
|----------|---------------|------------------|
| Bảng | `FinishGoodMESInstock_HN` | `STB_VN_FINISHGOODS_BG` |
| Route prefix | `VE-` | `V-` |
| Barcode format | `VE260507-001` | `VVXX123R000001` |
| Đơn giá | HN101 (theo mã kế toán) | Không có màn thiết lập riêng |

*Cập nhật: 2026-05-22*
