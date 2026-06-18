## 6. Phân Hệ SCM, Rework, Trả Hàng & Kiểm Kê (Gộp từ KB_27)


> **Màn hình liên quan:** F750 (Kiểm kê), B618 (Lịch sử Rework), SCM01 (Sales Order), FG00/HN551 (Xuất kho thành phẩm), Return01 (Nhận hàng trả lại)
> ← [Về INDEX](KB_INDEX.md)

---

### 1. 🔄 Luồng SCM, Sales Order & Kế Hoạch Xuất Hàng (WMS ↔ Sales ↔ Cargo)

Hệ thống NAIS MES quản lý luồng bán hàng và xuất hàng thông qua mối liên kết từ Đơn đặt hàng (Sales Order) của bộ phận Kinh doanh cho tới chứng từ xuất kho thực tế (Delivery) của bộ phận Kho thành phẩm.

#### Sơ đồ luồng dữ liệu (Dataflow)
```
  [Bộ phận Kinh doanh] 
     │ (Nhập đơn hàng: STB_SalesOrder -> STB_SalesOrderItem)
     ▼
  [Kế hoạch Sản xuất] 
     │ (Sản xuất theo đơn PO/Model -> Đóng gói gộp box in PackingID)
     ▼
  [Kho Thành Phẩm] 
     │ (Quét PackingID đóng thùng thành phẩm -> Khớp PackingID vào ShipmentOrder)
     ▼
  [Bắn Barcode Xuất Hàng] 
     │ (Thao tác màn xuất Cargo -> Lưu OUT_ASN / Kết quả OUT_RSLT)
     ▼
  [Đồng bộ ERP / Groupware] 
     │ (Cập nhật giảm tồn kho thành phẩm thực tế)
     ▼
  [Cập nhật chi tiết lịch sử] 
     │ (Gọi SP usp_WarehouseDelivery_get)
```

#### Chi tiết các bảng liên quan (Table Schemas)
1. **`STB_SalesOrder` (Đơn đặt hàng):** Lưu trữ thông tin chung của đơn hàng (Mã đơn, Loại đơn `OrderType`, 거래처 `CustomerCode`, Ngày giao hàng yêu cầu `RequestDeliveryDate`).
2. **`STB_SalesOrderItem` (Chi tiết đơn hàng):** Chi tiết từng mặt hàng (`ModelCode`), số lượng đặt (`OrderQty`), số lượng đã sản xuất (`FixedQty`), số lượng kế hoạch xuất kho (`GIPlanQty`).
3. **`STB_ShipmentOrderInfo` (Thông tin xuất hàng):** Liên kết giữa Số lệnh xuất hàng (`ShipmentOrderNo`), Lô đóng gói (`PackingID`), Mã vật tư (`MaterialCode`) và Số lượng lấy hàng (`PickingQty`).
4. **`OUT_ASN` (Shipment Attempt Table) & `OUT_RSLT` (Shipment Result Table):** Hai bảng trung gian lưu thông tin xuất kho thành phẩm thực tế đi Cargo, liên kết qua `PACK_ID` (PackingID).

#### Stored Procedure Cốt Lõi: `usp_WarehouseDelivery_get`
Khi bộ phận vận hành hoặc PowerBI cần xem báo cáo xuất kho thành phẩm thực tế:
```sql
SELECT Substring(Convert(Varchar(10), RR.CRT_DT, 121), 0 ,12) AS WorkDate
      , RR.ITM_CD  AS Item_Cd
      , (SELECT SM.MaterialName FROM STB_MaterialMaster SM WHERE SM.MaterialCode = RR.ITM_CD) AS Item_Nm
      , RR.PACK_ID   AS PackingID
      , RR.ITM_QTY  AS ShipQty			  			  
      , CONVERT(BIT, 1) AS ShipStatus
FROM OUT_RSLT RR    -- Bảng kết quả xuất kho thực tế
     LEFT OUTER JOIN OUT_ASN RA ON RR.PACK_ID = RA.PACK_ID
    WHERE 1=1
   AND (Substring(Convert(Varchar(10), RR.CRT_DT, 121), 0 ,12) BETWEEN @FromDate AND @ToDate)
   AND RR.PACK_ID LIKE @PackingID
 ORDER BY WorkDate
```

---

### 2. 🛠️ Quy Trình Làm Lại Sản Phẩm (Rework Flow)

Khi phát hiện lô hàng bán thành phẩm hoặc thành phẩm không đạt chất lượng nhưng có thể tái chế/làm lại (Rework), bộ phận QC/Sản xuất sẽ thực hiện khai báo trên hệ thống để chuyển đổi lô hàng cũ sang trạng thái sản xuất lại.

#### Sơ đồ luồng dữ liệu Rework
```
  [Lô hàng lỗi/NG] ──> [Đánh giá QC] ──> [Khai báo Rework (B618)] 
                                                │
                                                ▼
                                    Tạo Lot Rework mới (LotNoRework)
                                                │
                                                ▼
                                    Ghi STB_LotReworkInfo_HN
                                                │
                                                ▼
                                    Chuyển lại dây chuyền chính
```

#### Chi tiết bảng `STB_LotReworkInfo_HN`
* `LotNo`: Mã lô ban đầu bị lỗi.
* `LotNoRework`: Mã lô làm lại mới được tạo ra để chạy tiếp trên Line.
* `MaterialCode`: Mã nguyên vật liệu/sản phẩm.
* `ReworkQty`: Số lượng làm lại.
* `CreateUserID` / `CreateDateTime`: Người thực hiện và thời gian khai báo.

#### SP Quản lý Rework: `usp_GetInforLotReworkHaNamFactory_uid`
Stored Procedure này xử lý thêm/sửa/xóa thông tin Lot Rework từ giao diện XML truyền vào.

#### 🐛 Bug Logic 1: Khóa cứng tài khoản người dùng thao tác Rework
* **Vị trí:** SP `usp_GetInforLotReworkHaNamFactory_uid` (Dòng 41-45)
* **Triệu chứng:** Khi quản lý sản xuất mới hoặc tài khoản vận hành khác (`vinaadmin`, v.v.) thực hiện khai báo Rework, hệ thống ném lỗi: `Bạn không có quyền vui lòng liên hệ EA !` và chặn đứng giao dịch.
* **Nguyên nhân gốc:** Lập trình viên hardcode danh sách tài khoản có quyền thao tác trực tiếp trong code SQL:
  ```sql
  IF (@pProcessUserID NOT IN ('HaiTrieu','hoangxuan','ngocanh','doanthao'))
  BEGIN
      RAISERROR(N'Bạn không có quyền vui lòng liên hệ EA !',16,1)
      RETURN;
  END
  ```
* **Giải pháp khắc phục:** Đã tạo bản vá SQL an toàn kết hợp cơ chế kiểm tra quyền hạn động qua `SmartFramework.dbo.STB_UserPermission` (cho ScreenID `'B618'`) và cơ chế Fallback danh sách user cũ để tránh làm gián đoạn sản xuất.
  * **Hotfix Script:** `04_FIX_REWORK_HARDCODED_PERMISSION.sql`
  * **Mã SQL thay thế:**
    ```sql
    -- Kiểm tra phân quyền động kết hợp Fallback an toàn
    DECLARE @HasPermission BIT = 0;
    IF @pProcessUserID IN ('vinaadmin', 'sa', 'vina_ea') SET @HasPermission = 1;
    IF @pProcessUserID IN ('HaiTrieu','hoangxuan','','ngocanh','doanthao') SET @HasPermission = 1;
    IF EXISTS (
        SELECT 1 FROM SmartFramework.dbo.STB_UserPermission 
        WHERE UserID = @pProcessUserID AND ScreenID = 'B618' AND Allow = 1
    ) SET @HasPermission = 1;

    IF @HasPermission = 0
    BEGIN
        RAISERROR(N'Bạn không có quyền thao tác Rework, vui lòng liên hệ bộ phận EA!', 16, 1);
        RETURN;
    END
    ```

> 🚦 **Tham chiếu mở rộng:** Chi tiết logic, mã SQL debug, và cách mở rộng cho phân quyền Rework được tổng hợp tại **[KB_14 §6.3 Nhóm 5 — Rework](KB_14_TRACE_BUG_METHODOLOGY.md#nhóm-5-b618--chặn-rework-sp-usp_getinforlotreworkhanamfactory_uid)**.

---

### 3. 📦 Phân Hệ Trả Hàng (Returns & RMA Flow)

Phân hệ Trả hàng giải quyết các trường hợp: (1) Trả lại nguyên vật liệu lỗi cho nhà cung cấp (Vendor Return) hoặc (2) Khách hàng trả lại thành phẩm lỗi (Customer Return).

#### Sơ đồ luồng xác thực và tạo nhãn trả hàng
```
  [Quét Barcode Lô hàng Trả] 
       │
       ▼
  [Xác thực thông tin: usp_DoValidateMaterialDocBarcodeForReturn]
       │ (Kiểm tra trạng thái nhập kho ARRIVAL & QC IQC Pass)
       ▼
  [Khai báo Tách/Trả hàng] 
       │
       ▼
  [Tạo mã/nhãn trả hàng: usp_DoCreateLabelForReturn]
       │ (Tự động sinh mã Lô mới qua usp_GetSerialRule)
       ▼
  [Ghi nhận vào STB_RouteMaterialLotInfo]
```

#### Chi tiết nghiệp vụ & Stored Procedures
1. **`STB_RouteMaterialLotInfo`:** Lưu thông tin lô vật tư trả lại sau khi được in nhãn mới để theo dõi trên chuyền hoặc xuất trả.
2. **`STB_MaterialLotSnapshot`:** Lưu ảnh chụp trạng thái tồn kho của Lô tại thời điểm trả hàng để đối soát.

#### 🐛 Bug Logic 2: Khóa cứng luồng trả hàng do bắt buộc kiểm định IQC
* **Vị trí:** SP `usp_DoValidateMaterialDocBarcodeForReturn` (Dòng 60-86)
* **Triệu chứng:** Khi thực hiện quét barcode để nhận hàng trả lại từ Khách hàng (Customer Return), hệ thống báo lỗi `"수입검사 합격처리가 되지 않았습니다."` (Chưa hoàn thành kiểm tra IQC đạt chất lượng).
* **Nguyên nhân gốc:** SP kiểm tra nếu loại tài liệu là Nhập kho (`@MaterialDocType = 'GR'`) và yêu cầu QC kiểm định (`@IsRequireQC = 1`), nó sẽ bắt buộc tìm thông tin 수입검사 (IQC - kiểm định mua hàng đầu vào) trong bảng `STB_MaterialQcInfo` với quyết định kiểm tra phải là `'P'` (Pass):
  ```sql
  IF @IsRequireQC = 1 BEGIN
      SELECT @InspectionType = MVM.InspectionType ...
      IF @InspectionType <> 'NONE' AND ISNULL(@MaterialIqcNo,'') = '' BEGIN
          EXEC usp_RaiseLocalizedError @ProcessLanguage, '수입검사의뢰 정보를 찾을 수 없습니다.' -- Không tìm thấy thông tin kiểm định IQC
          RETURN
      END
      
      SELECT @DecisionResult = MQI.DecisionResult FROM STB_MaterialQcInfo WHERE MaterialQcNo = @MaterialIqcNo
      IF @DecisionResult <> 'P' BEGIN
          EXEC usp_RaiseLocalizedError @ProcessLanguage, '수입검사 합격처리가 되지 않았습니다.' -- IQC chưa pass
          RETURN
      END
  END
  ```
  Tuy nhiên, hàng trả về từ khách hàng (Customer Return) là **Thành phẩm** do nhà máy sản xuất ra, không phải là Nguyên vật liệu mua ngoài nên hoàn toàn không đi qua quy trình IQC mua hàng đầu vào (IQC chỉ dành cho NVL nhà cung cấp). Điều này chặn đứng không cho phép nhận hàng khách trả lại.
* **Giải pháp khắc phục:** Đã tạo bản vá SQL an toàn để bỏ qua kiểm tra IQC đối với thành phẩm (FERT) hoặc bán thành phẩm (HALB) sản xuất nội bộ khi khách trả hàng, chỉ bắt buộc check IQC đối với NVL nhập mua ngoài (ROH).
  * **Hotfix Script:** `05_FIX_RETURNS_FG_IQC_VALIDATION.sql`
  * **Mã SQL thay thế:**
    ```sql
    -- Lấy loại vật tư từ STB_MaterialMaster để phân biệt
    SELECT @MaterialTypeCode = MaterialTypeCode FROM STB_MaterialMaster WHERE MaterialCode = @MaterialCode


    IF @MaterialDocType = 'GR' BEGIN
        -- Chỉ bắt buộc kiểm tra IQC nếu là Nguyên vật liệu mua ngoài (ROH)
        IF @IsRequireQC = 1 AND @MaterialTypeCode = 'ROH' BEGIN
            -- (Thực hiện logic check IQC cũ...)
        END
    END
    ```

> 🚦 **Tham chiếu mở rộng:** Chi tiết kịch bản lỗi trả hàng và giải thích luồng RMA được tổng hợp tại **[KB_14 §6.3 Nhóm 8 — Returns](KB_14_TRACE_BUG_METHODOLOGY.md#nhóm-8-returns--chặn-trả-hàng-sp-usp_dovalidatematerialdocbarcodeforreturn)**.

---

### 4. 📊 Quy Trình Kiểm Kê Kho Thực Tế (Stocktaking - F750)

Màn hình **[F750] Kiểm kê kho vật tư** dùng để đối soát số lượng tồn kho vật lý thực tế tại các vị trí trong kho so với số lượng sổ sách hiện thời trên MES.

#### Quy trình tự động cân bằng kho (Auto-reconciliation)
Khi người dùng bấm nút **Cập nhật kết quả kiểm kê (Apply Stocktaking)**:
1. **Đối soát số lượng:** SP `usp_DoApplyStocktakingToStock` so sánh `BasicQty` (Tồn sổ sách lúc tạo phiếu kiểm kê) với `StocktakingQty` (Tồn thực tế kiểm đếm được).
2. **Xử lý Hao hụt kho (BasicQty > StocktakingQty):**
   * Tự động sinh một chứng từ xuất kho ảo (`GIMaterialDocNo`) có loại là `GI_STOCKTAKING` và trạng thái `FINISH`.
   * Gọi SP `usp_DoMakeMaterialDocDetailLotForStocktaking` để tạo bản ghi giảm số lượng trong `STB_MaterialDocLotInfo`.
3. **Xử lý Thặng dư kho (BasicQty < StocktakingQty):**
   * Tự động sinh một chứng từ nhập kho ảo (`GRMaterialDocNo`) có loại là `GR_STOCKTAKING` và trạng thái `FINISH`.
   * Gọi SP `usp_DoMakeMaterialDocDetailLotForStocktaking` để tạo bản ghi tăng số lượng trong `STB_MaterialDocLotInfo`.
4. **Xác nhận giao dịch:** Chạy SP `usp_DoFixMaterialDoc` để chốt lượng xuất/nhập ảo này, tự động kích hoạt trigger cập nhật `STB_MaterialLotInfo.CurrentQty` và `STB_MaterialStock.StockQty`.
5. **Cập nhật thuộc tính:** Cập nhật vị trí kho mới, PackingID mới và gán `IsApplied = 1` trong bảng `STB_StocktakingPlanResult`.

```
                  ┌──────────────────────────────┐
                  │ So sánh BasicQty vs CountQty │
                  └──────────────┬───────────────┘
                                 │
                 ┌───────────────┴───────────────┐
                 ▼                               ▼
       [BasicQty > CountQty]           [BasicQty < CountQty]
         (Hao hụt kho)                   (Thừa tồn kho)
                 │                               │
  ┌──────────────▼──────────────┐ ┌──────────────▼──────────────┐
  │ Tạo phiếu xuất kho ảo GI     │ │ Tạo phiếu nhập kho ảo GR     │
  │ loại GI_STOCKTAKING         │ │ loại GR_STOCKTAKING         │
  └──────────────┬──────────────┘ └──────────────┬──────────────┘
                 │                               │
                 └───────────────┬───────────────┘
                                 ▼
                    ┌─────────────────────────┐
                    │ Chạy SP DoFixMaterialDoc│
                    │ Cân bằng tồn kho sổ sách│
                    └─────────────────────────┘
```

---

### 5. 🔬 Nghiên Cứu Điển Hình: Tự Động Tách Lô Giá Đỡ (Substrate Splitting Case Study)

Hệ thống NAIS MES có một thiết kế nghiệp vụ cực kỳ đặc thù cho việc tách lô vật liệu **Giá đỡ / Chất mang (Substrate - 지지체)**. Việc tách lô này không sử dụng màn hình chia Lot thông thường, mà **mượn cơ chế tự động kiểm kê (Stocktaking)** để thực hiện nhằm tránh việc tạo các chứng từ xuất/nhập phức tạp trên WMS.

#### SP Thực thi: `usp_DoMakeStocktakingPlanResultForSupport`
Quy trình diễn ra như sau:
1. **Kiểm tra trạng thái:** Đảm bảo lô gộp (`MergeLotID`) chưa được xác nhận hoàn thành (`IsFixed = 0`).
2. **Xác thực vị trí kho:** Kiểm tra xem lô nguyên liệu gốc có nằm trong cùng một kho công đoạn (`IsRouteWarehouse = 1`) hay không. Nếu nằm phân tán, chặn giao dịch:
   ```sql
   IF @MaterialWarehouseCode NOT IN (SELECT MaterialWarehouseCode FROM STB_MaterialWarehouse WHERE IsRouteWarehouse = 1) BEGIN
       EXEC usp_RaiseLocalizedError @pProcessLanguage, '원자재가 공정창고에 없습니다...' -- Nguyên liệu phải được xuất kho lên Line trước khi chia nhỏ.
       RETURN
   END
   ```
3. **Khởi tạo chứng từ kiểm kê ảo:** Tạo một mã phiếu kiểm kê mới trong `STB_StocktakingDoc` và chèn các dòng dữ liệu vào `STB_StocktakingPlanResult`:
   * **Lô gốc (Original Lots):** Gán số lượng kiểm kê thực tế bằng `0` (làm trống tồn kho lô gốc).
   * **Lô gộp mới (Merged Lot):** Gán số lượng kiểm kê thặng dư bằng lượng còn lại (`TotalMergeQty - TotalSplitQty`).
   * **Các lô con tách nhỏ (Split Lots):** Gán số lượng kiểm kê bằng lượng tách (`SplitQty`).
4. **Cân bằng tự động:** Gọi SP `usp_DoApplyStocktakingToStock` để thực hiện giao dịch GI/GR ảo, từ đó xóa các lô gốc và tạo mới các lô con trong bảng tồn kho `STB_MaterialLotInfo`.
5. **Khóa giao dịch:** Đổi trạng thái `IsFixed = 1` trong bảng lịch sử tách lô `STB_SupportRawMaterialSplitHist`.

> [!TIP]
> **Nhận xét kiến trúc:** Việc sử dụng cơ chế Kiểm kê (`Stocktaking`) để thực hiện tác vụ chia lô (Split Lot) là một giải pháp thiết kế thông minh giúp bypass các quy trình xét duyệt rườm rà của thủ kho WMS. Tuy nhiên, điều này sẽ tạo ra hàng loạt chứng từ `GI_STOCKTAKING`/`GR_STOCKTAKING` ảo trong lịch sử kho, có thể gây nhiễu cho việc đối soát dữ liệu kế toán kho trên ERP (Douzone Groupware).

---
*Cập nhật: 2026-06-10 | Phân tích chi tiết quy trình SCM, Returns, Rework và Stocktaking thực tế từ Database SmartFactoryV2 và SmartFramework*

---

