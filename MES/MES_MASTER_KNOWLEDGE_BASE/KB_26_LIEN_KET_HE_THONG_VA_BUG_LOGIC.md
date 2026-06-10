# KB_26 — Liên Kết Hệ Thống & Phân Tích Lỗi Logic

> **Màn hình liên quan:** B597, B530, C443, C512, C530, C546, HN551, FG00
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 🔄 Luồng liên kết liên phòng ban vận hành (WMS ↔ Sản xuất ↔ QC ↔ Xuất hàng)

Hệ thống NAIS MES vận hành trơn tru dựa trên sự liên kết chặt chẽ về dữ liệu giữa các phòng ban. Luồng dữ liệu đi qua các công đoạn như sau:

```
[Kho WMS NVL] 
   │ (Nhập kho F330, tạo Lot ML... trong STB_MaterialLotInfo)
   ▼
[Sản xuất (Cuốn/Lắp ráp)] 
   │ (Scan Lot NVL tại B540/B597 -> Kiểm tra BOM/Hạn dùng -> Ghi STB_RawMaterialInputHist)
   ▼
[QC Inline (PQC)] 
   │ (Kiểm tra công đoạn tại C443 -> Nhập giá trị/số lượng lỗi vào STB_CommInspDocHistory)
   ▼
[Sản xuất chốt số lượng B530]
   │ (SP check IsRawMaterialInputFinish & CheckPQCInput -> Confirm và ghi STB_ProdRouteHist)
   ▼
[Đóng gói gộp thùng B523/B525]
   │ (Gộp thùng in tem Box/Carton -> Tạo PackingID/BoxID -> Lưu STB_MaterialLotInfo)
   ▼
[QC Audit xuất xưởng (OQC/FOQC)]
   │ (Kiểm mẫu tại C530/C546 -> Đánh giá Pass/Reject -> Cập nhật STB_VN_FINISHGOODS_forQCAudit)
   ▼
[Kho Thành phẩm & Xuất hàng]
   │ (Bắn mã box xuất kho -> SP check StatusCheck='Pass' -> Xuất Cargo và Sync Groupware)
```

---

## 2. 📦 Cơ chế trừ kho tự động (WMS ↔ Production Triggers)

Việc trừ tồn kho nguyên vật liệu khi đưa vào sản xuất không được thực hiện trực tiếp bằng câu lệnh `UPDATE` thủ công trong ứng dụng, mà được ủy thác cho cơ chế **Trigger liên hoàn** của database SQL Server:

### Bước 1: Khởi tạo chứng từ xuất kho sản xuất (Goods Issue)
Khi sản xuất tiêu hao nguyên vật liệu, hệ thống gọi SP [usp_DoProcessProdGIMaterialForBarcode](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES/sql/procedures/usp_DoProcessProdGIMaterialForBarcode.sql) để tạo một chứng từ xuất kho trong `STB_MaterialDocInfo` và chèn chi tiết lô vật tư vào `STB_MaterialDocLotInfo`.

### Bước 2: Kích hoạt Trigger chứng từ [tgMaterialDocLotInfoIUD](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/.gemini/antigravity-ide/brain/5ce6dcd8-26c3-4e84-9104-5749611d9fa4/scratch/tgMaterialDocLotInfoIUD.sql)
Khi một dòng được chèn vào `STB_MaterialDocLotInfo`, Trigger `tgMaterialDocLotInfoIUD` được kích hoạt tự động để cập nhật trạng thái lấy hàng (`PickingQty`) của Lot tương ứng:
```sql
-- Trigger tự động cộng dồn PickingQty vào STB_MaterialLotInfo
WHEN MATCHED THEN
    UPDATE SET PickingQty = T.PickingQty + S.PickingQty;
```

### Bước 3: Confirm xuất kho vật lý và trừ tồn kho Lot
Khi thủ kho hoặc hệ thống xác nhận xuất kho vật lý (ví dụ qua SP [usp_DoProcessMaterialLotInfoOutput](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/.gemini/antigravity-ide/brain/5ce6dcd8-26c3-4e84-9104-5749611d9fa4/scratch/usp_DoProcessMaterialLotInfoOutput.sql)):
* Hệ thống cập nhật giảm đồng thời `PickingQty` và `CurrentQty` (tồn kho thực tế của Lot):
  ```sql
  UPDATE STB_MaterialLotInfo
  SET PickingQty = PickingQty - @pUsedQty,
      CurrentQty = CurrentQty - @pUsedQty
  WHERE MaterialLotNo = @MaterialLotNo;
  ```
* Nếu số lượng tồn kho của Lot về bằng `0`, hệ thống sẽ tự động xóa Lot này khỏi bảng tồn kho hiện hành `STB_MaterialLotInfo`.

### Bước 4: Kích hoạt Trigger đồng bộ tồn kho tổng [tgMaterialLotInfoForUpdate](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/.gemini/antigravity-ide/brain/5ce6dcd8-26c3-4e84-9104-5749611d9fa4/scratch/tgMaterialLotInfoForUpdate.sql)
Khi `CurrentQty` trong `STB_MaterialLotInfo` thay đổi, trigger `tgMaterialLotInfoForUpdate` lập tức được kích hoạt để đồng bộ (cộng/trừ) lượng tồn kho tổng hợp trong bảng thống kê kho `STB_MaterialStock`:
```sql
-- Trigger đồng bộ số lượng tồn kho tổng
WHEN MATCHED THEN
    UPDATE SET StockQty = T.StockQty + S.StockQty; -- (hoặc - S.StockQty đối với dòng bị delete/giảm)
```

---

## 3. 🐛 4 Lỗi Logic (Bugs) Hệ Thống Phát Hiện & Script Khắc Phục

Dưới đây là 4 lỗi logic lập trình được phát hiện trực tiếp từ việc kiểm tra mã nguồn Stored Procedures trong database:

### Bug 1: Logic chặn PQC Gate 3 bắt buộc phải có lỗi mới cho đi tiếp
*   **Vị trí:** SP [usp_CheckPQCInputForProductHistForBarcode](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/.gemini/antigravity-ide/brain/5ce6dcd8-26c3-4e84-9104-5749611d9fa4/scratch/usp_CheckPQCInputForProductHistForBarcode.sql)
*   **Triệu chứng:** Khi công nhân confirm sản lượng ở màn hình B530, hệ thống báo lỗi `"Bên PQC chưa nhập số lượng NG. Vui lòng bảo bên PQC nhập số lượng NG."` dù lô hàng hoàn toàn đạt chuẩn và QC đã nhập mã không lỗi (các mã đuôi `_00` như `V-22_00` đại diện cho Đạt chất lượng).
*   **Nguyên nhân gốc:** SP đếm số lượng bản ghi phế lỗi (`DRI.DefectSummaryNo`) trong `STB_DefectRepairInfo` nhưng loại trừ các mã lỗi Đạt (`flag = 'QC'`) trong hàm `fn_VVT_QCPARTCODE()`. 
    Do đó, nếu lô hàng không có lỗi thực tế (hoặc chỉ có mã đạt `_00`), biến `@NG_Count` bằng `0`. Khối lệnh kiểm tra `IF (ISNULL(@NG_Count, 0) <= 0)` kích hoạt và ném ra ngoại lệ chặn đứng sản xuất.
*   **Giải pháp khắc phục:** Sửa đổi SP để kiểm tra xem PQC đã thực hiện đánh giá chưa (có dòng ghi nhận trong `STB_DefectRepairInfo` bất kể mã lỗi hay mã đạt), thay vì bắt buộc phải có lỗi thực tế:
    ```sql
    -- SỬA ĐỔI ĐỀ XUẤT:
    -- Đếm tổng tất cả các đánh giá của PQC tại công đoạn (bao gồm cả mã Đạt '_00')
    SELECT
        @NG_Count = COUNT(DRI.DefectSummaryNo)
    FROM
        STB_DefectRepairInfo DRI WITH(NOLOCK)
        INNER JOIN STB_SetInfo SI WITH(NOLOCK) ON SI.ControlNo = DRI.ControlNo
        LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK) ON DI.DefectCode = DRI.DefectCode
    WHERE
        SI.Barcode = @pBarcode AND
        DRI.FindRouteCode = @pRouteCode AND
        DI.DirectlyUnder IN ('PQC'); -- Không loại trừ flag='QC' nữa để ghi nhận các mã '_00'
    ```

---

### Bug 2: Sự bất đối xứng (Khóa cứng) trong QC Audit Pass/Reject
*   **Vị trí:** SP [usp_VN_WaitingCheckBeforeExport_forQCAudit_Pass](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/.gemini/antigravity-ide/brain/5ce6dcd8-26c3-4e84-9104-5749611d9fa4/scratch/usp_VN_WaitingCheckBeforeExport_forQCAudit_Pass.sql)
*   **Triệu chứng:** Tại màn hình duyệt QC Audit xuất kho, nếu người dùng lỡ tay bấm **Reject** một lô hàng, sau đó muốn bấm duyệt lại thành **Pass** thì hệ thống không cho phép cập nhật và nút Pass bị vô hiệu hóa. Ngược lại, nếu đang ở trạng thái **Pass**, nút **Reject** vẫn cho phép bấm tự do.
*   **Nguyên nhân gốc:** Trong SP Pass, điều kiện cập nhật chỉ chấp nhận khi trạng thái kiểm tra đang là `NULL`:
    ```sql
    ELSE IF (@getStatusCheck IS NULL)
        BEGIN
            UPDATE STB_VN_FINISHGOODS_forQCAudit SET StatusCheck = 'Pass' ...
        END
    ```
    Khi đã bị Reject, `StatusCheck = 'Reject'` (không phải `NULL`), dẫn đến khối lệnh UPDATE bị bỏ qua. Trái lại, trong SP Reject, không có cổng chặn trạng thái cũ, cho phép UPDATE đè thoải mái.
*   **Giải pháp khắc phục:** Cho phép cập nhật trạng thái từ `'Reject'` sang `'Pass'` để người dùng sửa sai khi thao tác nhầm:
    ```sql
    -- SỬA ĐỔI ĐỀ XUẤT:
    IF (@getStatusCheck = 'Pass')
        BEGIN
            RAISERROR(N'Packing này đã được đánh giá pass', 16, 1);
        END
    ELSE IF (@getStatusCheck IS NULL OR @getStatusCheck = 'Reject') -- Cho phép đổi từ Reject sang Pass
        BEGIN
            UPDATE STB_VN_FINISHGOODS_forQCAudit
            SET StatusCheck = 'Pass'
            WHERE ID = @pID;
        END
    ```

---

### Bug 3: Hardcode địa điểm Bắc Giang gây ẩn dữ liệu ở các kho khác
*   **Vị trí:** SP [usp_VN_WaitingCheckBeforeExport_forQCAudit_get](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/.gemini/antigravity-ide/brain/5ce6dcd8-26c3-4e84-9104-5749611d9fa4/scratch/usp_VN_WaitingCheckBeforeExport_forQCAudit_get.sql) và [usp_VN_WaitingCheckBeforeExport_forQCAudit_pass_get](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/.gemini/antigravity-ide/brain/5ce6dcd8-26c3-4e84-9104-5749611d9fa4/scratch/usp_VN_WaitingCheckBeforeExport_forQCAudit_pass_get.sql)
*   **Triệu chứng:** Khi mở màn hình kiểm định xuất xưởng tại nhà máy Hà Nam hoặc Hưng Yên, danh sách hàng chờ QC Audit bị trống rỗng, không hiển thị bất cứ dữ liệu nào.
*   **Nguyên nhân gốc:** Cả hai Stored Procedure tải dữ liệu chờ duyệt đều bị hardcode bộ lọc địa điểm:
    ```sql
    WHERE Flag = 1 AND FGLocation LIKE N'Bắc Giang'
    ```
*   **Giải pháp khắc phục:** Chuyển bộ lọc địa điểm thành tham số truyền vào từ UI hoặc bỏ lọc cứng nếu màn hình dùng chung cho toàn hệ thống:
    ```sql
    -- SỬA ĐỔI ĐỀ XUẤT:
    -- Thêm tham số @pFGLocation VARCHAR(50) = NULL vào SP
    -- Trong WHERE chỉnh thành:
    AND (@pFGLocation IS NULL OR FGLocation LIKE @pFGLocation)
    ```

---

### Bug 4: Lỗi lọc typo biến `@Statusout` gây validation sai dòng dữ liệu
*   **Vị trí:** SP [usp_VN_Update_ExportExcel_BG_test_Audit](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/.gemini/antigravity-ide/brain/5ce6dcd8-26c3-4e84-9104-5749611d9fa4/scratch/usp_VN_Update_ExportExcel_BG_test_Audit.sql) (Dòng 75)
*   **Triệu chứng:** Lỗi kiểm tra xuất xưởng hoạt động sai lệch khi một mã Lot có nhiều carton/thùng hàng (một số đã xuất, một số chưa xuất). Hệ thống báo lỗi chưa kiểm tra QC dù carton mới đã được Pass.
*   **Nguyên nhân gốc:** Ở câu lệnh query thông tin để kiểm lỗi chi tiết, lập trình viên đã viết nhầm điều kiện lọc bằng biến `@Statusout` thay vì cột `Statusout`:
    ```sql
    WHERE LotNo = @LotNo AND PackQty = @Qty AND @Statusout IS NULL
    ```
    Do `@Statusout` là biến và tại dòng 75 nó luôn có giá trị `NULL` (vì đã pass qua block kiểm tra trước), điều kiện này tương đương `AND NULL IS NULL` (luôn đúng). Câu lệnh SELECT sẽ lấy ngẫu nhiên 1 dòng trùng Lot và Qty bất kể dòng đó đã xuất hay chưa.
*   **Giải pháp khắc phục:** Đổi điều kiện lọc về đúng cột vật lý của bảng:
    ```sql
    -- SỬA ĐỔI ĐỀ XUẤT:
    -- Đổi @Statusout thành tên cột Statusout trong database
    WHERE LotNo = @LotNo AND PackQty = @Qty AND Statusout IS NULL
    ```

---
*Cập nhật: 2026-06-10 | Phát hiện và phân tích trực tiếp từ SmartFactoryV2 database*
