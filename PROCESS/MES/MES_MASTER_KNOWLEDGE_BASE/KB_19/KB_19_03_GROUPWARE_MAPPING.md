
Dưới đây là cẩm nang tích hợp tối thượng giải thích cách từng biểu mẫu (Form) trên Groupware vận hành, tác động đến cơ sở dữ liệu nào, ánh xạ xuống màn hình MES nào và cung cấp câu lệnh SQL truy vấn đối soát thực tế:

### 9.1. Đơn Yêu Cầu Mua Sắm (PR / Expense Report)
*   **Mã Form ID:** `expenseReportDocument` hoặc `purchaseRequestDocument`
*   **Vận hành của User:** Người dùng đề xuất mua sắm nguyên vật liệu, thiết bị hoặc thanh toán dịch vụ. Chọn đồng tiền giao dịch, nhập tổng số tiền và đính kèm báo giá.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE` (Header chung, trạng thái duyệt).
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_PURCHASE_REQUEST` (Chi tiết danh mục yêu cầu mua).
    *   `NEOE.dbo.PU_PRH` (Header yêu cầu mua trên ERP) & `PU_PRL` (Line chi tiết).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình:* Mua hàng trên Groupware không có màn hình MES trực tiếp ở giai đoạn này.
    *   *Stored Procedure:* `usp_SyncPurchaseRequest` (đồng bộ PR từ Groupware sang ERP).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        GW_S.DOCUMENT_SAVE_CODE AS [GW Code],
        GW_S.DOCUMENT_SAVE_SUBJECT AS [Subject],
        GW_S.DOCUMENT_SAVE_STATE AS [State],
        ERP_H.NO_PR AS [ERP PR No],
        ERP_L.CD_ITEM AS [Item Code],
        ERP_L.QT_PR AS [Qty Requested]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE GW_S WITH(NOLOCK)
    INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_PURCHASE_REQUEST GW_R WITH(NOLOCK)
        ON GW_S.DOCUMENT_SAVE_CODE = GW_R.DOCUMENT_SAVE_CODE
    LEFT JOIN NEOE.dbo.PU_PRH ERP_H WITH(NOLOCK)
        ON GW_S.DOCUMENT_SAVE_CODE = ERP_H.NO_PR -- Mã document map sang số phiếu PR ERP
    LEFT JOIN NEOE.dbo.PU_PRL ERP_L WITH(NOLOCK)
        ON ERP_H.NO_PR = ERP_L.NO_PR
    WHERE GW_S.DOCUMENT_SAVE_CODE = 'MÃ_YÊU_CẦU_MUA_GW';
    ```

---

### 9.2. Đơn Đặt Hàng (Purchase Order - PO)
*   **Mã Form ID:** `purchaseOrderDocument`
*   **Vận hành của User:** Nhân viên thu mua tạo đơn PO với nhà cung cấp, liên kết với PR đã duyệt, chọn đơn giá, thuế VAT, BOM phiên bản 2001 và kho nhận dự kiến.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_POH` (PO Header) & `VINA_DOCUMENT_POL` (PO Lines).
    *   `NEOE.dbo.PU_POH` (ERP PO Header) & `PU_POL` (ERP PO Lines).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* **B310** (PO Info - Giám sát tiến độ đơn hàng sản xuất).
    *   *Stored Procedure:* `usp_GetPurchaseOrderList` (load PO lên màn hình MES B310).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        POH.NO_PO AS [PO No],
        POL.CD_ITEM AS [Item Code],
        POL.QT_PO AS [Qty Ordered],
        POL.DOCUMENT_POL_REMAIN_QT_PO AS [Qty Remaining],
        -- Kiểm tra xem MES B310 có truy vấn được PO này không
        (SELECT COUNT(*) FROM SmartFactoryV2.dbo.STB_ProductionOrderInfo WITH(NOLOCK) WHERE PONo = POH.NO_PO) AS [MES PO Record Count]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_POH POH WITH(NOLOCK)
    INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_POL POL WITH(NOLOCK)
        ON POH.DOCUMENT_SAVE_CODE = POL.DOCUMENT_SAVE_CODE
    WHERE POH.NO_PO = 'MÃ_PO_CẦN_TRA';
    ```

---

### 9.3. Xác Nhận Hàng Về (Arrival Confirmation)
*   **Mã Form ID:** `arrivalConfirmationDocument`
*   **Vận hành của User:** Khi xe chở nguyên vật liệu về đến nhà máy, thủ kho lập phiếu báo hàng về, ghi nhận số lượng thực tế giao, số thông quan, số lượng in tem nhãn và đẩy thông báo cho QC.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_H` & `_L`.
    *   `SmartFactoryV2.dbo.STB_MaterialDocInfo` (Tài liệu tiếp nhận kho) & `STB_MaterialDocDetail`.
    *   `SmartFactoryV2.dbo.STB_MaterialLotInfo` (Sinh mã Lot tạm dạng `ML...`).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* **F330** (Goods Receipt - Nhận hàng hiện trường và in tem).
    *   *Stored Procedure:* `usp_WarehouseDelivery_get` (lấy dữ liệu Arrival lên lưới F330), `usp_DoCreateMaterialLot` (sinh tem nhãn Lot ID).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        ARR_H.DOCUMENT_SAVE_CODE AS [Arrival Doc],
        ARR_L.CD_ITEM AS [Item Code],
        ARR_L.QT_RECEIVING_PHYSICAL AS [Arrival Qty],
        -- Kiểm tra chứng từ tiếp nhận tương ứng dưới MES
        MDI.MaterialDocNo AS [MES Doc No],
        MDI.InOutType AS [Doc Type], -- Thường là 'In'
        MLI.LotID AS [Generated LotID],
        MLI.InitialQty AS [Lot Qty]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_H ARR_H WITH(NOLOCK)
    INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_L ARR_L WITH(NOLOCK)
        ON ARR_H.DOCUMENT_SAVE_CODE = ARR_L.DOCUMENT_SAVE_CODE
    LEFT JOIN SmartFactoryV2.dbo.STB_MaterialDocInfo MDI WITH(NOLOCK)
        ON ARR_H.DOCUMENT_SAVE_CODE = MDI.MaterialDocNo
    LEFT JOIN SmartFactoryV2.dbo.STB_MaterialLotInfo MLI WITH(NOLOCK)
        ON MDI.MaterialDocNo = MLI.MaterialDocNo AND ARR_L.CD_ITEM = MLI.MaterialCode
    WHERE ARR_H.DOCUMENT_SAVE_CODE = 'MÃ_PHIẾU_ARR_GW';
    ```

---

### 9.4. Xác Nhận Nhập Kho (Receiving Confirmation)
*   **Mã Form ID:** `receivingConfirmationDocument`
*   **Vận hành của User:** Sau khi QC kiểm tra chất lượng và đánh giá đạt (**PASS**), nhân viên mua hàng lập phiếu nhập kho chính thức trên Groupware, chỉ chọn những Lot đã PASS QC để cộng tồn kho chính thức.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_PU_RCVH` (GR Header) & `VINA_DOCUMENT_PU_RCVL` (GR Lines).
    *   `SmartFactoryV2.dbo.STB_MaterialLotInfo` (Cập nhật cột `CurrentQty` chính thức).
    *   `NEOE.dbo.PU_RCVH` & `PU_RCVL` (Chứng từ nhập kho hạch toán ERP).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* Kho vật lý MES cập nhật số lượng tồn kho tự động.
    *   *Stored Procedure:* `usp_DoApplyIncomingQty` (cộng tồn kho MES và trigger đồng bộ sang ERP).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        RCV.DOCUMENT_SAVE_CODE AS [GW GR Code],
        RCVL.CD_ITEM AS [Item Code],
        RCVL.QTY_RCV AS [Qty Received],
        -- Đối chiếu tồn kho thực tế trong MES
        (SELECT SUM(CurrentQty) FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) 
         WHERE MaterialDocNo = RCV.DOCUMENT_SAVE_CODE AND MaterialCode = RCVL.CD_ITEM) AS [MES Current Stock],
        -- Đối chiếu ERP nhập kho hạch toán
        (SELECT SUM(QT_RCV) FROM NEOE.dbo.PU_RCVL WITH(NOLOCK) 
         WHERE NO_RCV = RCV.DOCUMENT_SAVE_CODE AND CD_ITEM = RCVL.CD_ITEM) AS [ERP Stock Added]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_PU_RCVH RCV WITH(NOLOCK)
    INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_PU_RCVL RCVL WITH(NOLOCK)
        ON RCV.DOCUMENT_SAVE_CODE = RCVL.DOCUMENT_SAVE_CODE
    WHERE RCV.DOCUMENT_SAVE_CODE = 'MÃ_PHIẾU_RCV_GW';
    ```

---

### 9.5. Sổ Quyết Toán Mua Hàng (Purchase Resolution)
*   **Mã Form ID:** `purchaseResolutionDocument`
*   **Vận hành của User:** Kế toán viên lập quyết toán chi phí mua hàng, phân bổ tài khoản chi phí định khoản, gán mã thuế suất và quyết toán cước vận tải logistics đi kèm.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_PURCHAE_RESOLUTION` & `_LINE`.
    *   `NEOE.dbo.FI_DOCU` (ERP Slip Header) & `FI_DOCU_D` (ERP Slip Lines).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình:* Đây là nghiệp vụ tài chính thuần túy, không tác động màn hình MES.
    *   *Stored Procedure:* `usp_DoCreateAccountingSlip` (sinh bút toán sang sổ cái ERP).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        PR.DOCUMENT_SAVE_CODE AS [GW Resolution Code],
        PR.PAYMENT_DATE AS [Scheduled Payment],
        PRL.CD_ACCT AS [Expense Account],
        PRL.AM AS [Amount VND],
        -- Tra cứu bút toán tương ứng trong ERP
        FD.NO_DOCU AS [ERP Slip No],
        FD.CD_ACCT AS [ERP Account Code],
        FD.AM_DR AS [ERP Debit],
        FD.AM_CR AS [ERP Credit]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_PURCHAE_RESOLUTION PR WITH(NOLOCK)
    INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_PURCHAE_RESOLUTION_LINE PRL WITH(NOLOCK)
        ON PR.DOCUMENT_SAVE_CODE = PRL.DOCUMENT_SAVE_CODE
    LEFT JOIN NEOE.dbo.FI_DOCU_D FD WITH(NOLOCK)
        ON PR.DOCUMENT_SAVE_CODE = FD.NO_IS -- Link qua cột Interface
    WHERE PR.DOCUMENT_SAVE_CODE = 'MÃ_QUYẾT_TOÁN_GW';
    ```

---

### 9.6. Đơn Xin Nghỉ Việc (Employee Retire Document)
*   **Mã Form ID:** `empRetireDocument`
*   **Vận hành của User:** Nhân viên lập đơn xin thôi việc, xác định ngày làm việc cuối cùng, đăng ký bàn giao tài sản thiết bị và tài liệu công việc.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_EMP_RETIRE` & `_CHECKLIST`.
    *   `NEOE.dbo.MA_EMP` (Cập nhật cột trạng thái `CD_INCOM = '099'`).
    *   `SmartFramework.dbo.STB_UserInfo` (Cập nhật `AllowFlag = 'Deny'`).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* **Z410** (User Configuration - Phân quyền và trạng thái người dùng).
    *   *Stored Procedure:* `usp_DoGUILogin` (tự động kiểm tra trạng thái và chặn đăng nhập).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        R.DOCUMENT_SAVE_CODE AS [GW Doc],
        R.NO_EMP AS [Employee ID],
        R.DT_RETIRE AS [Retire Date],
        -- Kiểm tra trạng thái tài khoản trên ERP
        E.CD_INCOM AS [ERP Incom Code], -- '099' đại diện cho nghỉ việc
        -- Kiểm tra trạng thái trên MES SmartFramework
        U.UserID AS [MES UserID],
        U.AllowFlag AS [MES Allow Status] -- 'Deny' đại diện cho bị khóa
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_EMP_RETIRE R WITH(NOLOCK)
    LEFT JOIN NEOE.dbo.MA_EMP E WITH(NOLOCK)
        ON R.NO_EMP = E.NO_EMP
    LEFT JOIN SmartFramework.dbo.STB_UserInfo U WITH(NOLOCK)
        ON R.NO_EMP = U.Appendix8 -- Appendix8 chứa mã nhân viên ERP
    WHERE R.NO_EMP = 'MÃ_NHÂN_VIÊN_NGHỈ';
    ```

---

### 9.7. Đi Làm Ngày Nghỉ / Lễ (Holiday Work Request)
*   **Mã Form ID:** `holidayWorkRequest`
*   **Vận hành của User:** Đăng ký tăng ca ngày chủ nhật hoặc ngày lễ. Sau khi hoàn thành, nhân viên cập nhật số giờ thực tế làm việc để gửi duyệt ngày công.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_HOLIDAY_WORK`.
    *   `SmartFactoryV2.dbo.STB_VN_ATTENDANCE_TIME` (Ghi nhận giờ công tích lũy).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* Chấm công tự động qua máy quét vân tay.
    *   *Stored Procedure:* `usp_SyncFingerData` (quét chấm công và đồng bộ giờ làm việc).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        HW.DOCUMENT_SAVE_CODE AS [GW Doc],
        HW.NO_EMP AS [Employee ID],
        HW.WORK_DATE AS [Date],
        HW.ACTUAL_WORK_HOURS AS [GW Overtime Hours],
        -- Kiểm tra bảng chấm công thực tế của MES
        AT.WorkHours AS [MES Work Hours],
        AT.OvertimeHours AS [MES Overtime Hours],
        AT.CreateDateTime AS [Log Time]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_HOLIDAY_WORK HW WITH(NOLOCK)
    LEFT JOIN SmartFactoryV2.dbo.STB_VN_ATTENDANCE_TIME AT WITH(NOLOCK)
        ON HW.NO_EMP = AT.WorkerCode AND HW.WORK_DATE = AT.JobDate
    WHERE HW.NO_EMP = 'MÃ_NHÂN_VIÊN' AND HW.WORK_DATE = '2026-06-12';
    ```

---

### 9.8. Đăng Ký Đơn Bán Hàng (Sales Order / Suju)
*   **Mã Form ID:** `salesOrderDocument`
*   **Vận hành của User:** Nhân viên kinh doanh đăng ký đơn hàng chính thức từ đối tác, điền thông tin Incoterms, đồng tiền, đơn giá bán và số lượng đặt hàng.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_SALES_ORDER` & `_LINE`.
    *   `NEOE.dbo.SA_SOH` (ERP Suju Header) & `SA_SOL` (ERP Suju Lines).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình:* Đơn hàng được đẩy sang ERP và tự động khởi tạo Month Production Plan.
    *   *Stored Procedure:* `usp_SyncSalesOrder` (đồng bộ đơn hàng Suju sang ERP).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        SO.NO_SO AS [ERP SO No],
        SOL.CD_ITEM AS [Product Code],
        SOL.QT_SO AS [Qty Ordered],
        -- Kiểm tra đơn hàng bán tương ứng trên ERP
        ERP_H.NO_SO AS [ERP Voucher SO],
        ERP_L.QT_SO AS [ERP SO Qty]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_SALES_ORDER SO WITH(NOLOCK)
    INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_SALES_ORDER_LINE SOL WITH(NOLOCK)
        ON SO.DOCUMENT_SAVE_CODE = SOL.DOCUMENT_SAVE_CODE
    LEFT JOIN NEOE.dbo.SA_SOH ERP_H WITH(NOLOCK)
        ON SO.NO_SO = ERP_H.NO_SO
    LEFT JOIN NEOE.dbo.SA_SOL ERP_L WITH(NOLOCK)
        ON ERP_H.NO_SO = ERP_L.NO_SO AND SOL.CD_ITEM = ERP_L.CD_ITEM
    WHERE SO.NO_SO = 'MÃ_SUJU_CẦN_TRA';
    ```

---

### 9.9. Yêu Cầu Xuất Hàng (Shipment Request)
*   **Mã Form ID:** `deliverOutDocument`
*   **Vận hành của User:** Khi hàng thành phẩm OQC đạt chất lượng, nhân viên logistics lập phiếu yêu cầu xuất hàng, ghi nhận số lượng và chọn hóa đơn xuất khẩu đính kèm.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_DELIVER_OUT_CONFIRMATION_IV` & `_LINE`.
    *   `NEOE.dbo.SA_GIRH` (ERP Issue Header) & `SA_GIRL` (ERP Issue Lines).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* **FG01** (PDA Xuất kho thành phẩm - Quét mã thùng Box Packing ID).
    *   *Stored Procedure:* `usp_GetShipmentRequestList` (load danh sách yêu cầu xuất hàng lên PDA).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        SR.DOCUMENT_SAVE_CODE AS [GW Request Code],
        SR.CD_PARTNER AS [Customer Code],
        SRL.CD_ITEM AS [Item Code],
        SRL.QT_REQUEST AS [Qty Requested],
        -- Kiểm tra phiếu yêu cầu xuất kho hạch toán tương ứng ở ERP
        GIR.NO_GIR AS [ERP GIR No],
        GIR.CD_PARTNER AS [ERP Customer],
        GIL.QT_GIR AS [ERP GIR Qty]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_DELIVER_OUT_CONFIRMATION_IV SR WITH(NOLOCK)
    INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_DELIVER_OUT_CONFIRMATION_IV_LINE SRL WITH(NOLOCK)
        ON SR.DOCUMENT_SAVE_CODE = SRL.DOCUMENT_SAVE_CODE
    LEFT JOIN NEOE.dbo.SA_GIRH GIR WITH(NOLOCK)
        ON SR.DOCUMENT_SAVE_CODE = GIR.NO_GIR
    LEFT JOIN NEOE.dbo.SA_GIRL GIL WITH(NOLOCK)
        ON GIR.NO_GIR = GIL.NO_GIR AND SRL.CD_ITEM = GIL.CD_ITEM
    WHERE SR.DOCUMENT_SAVE_CODE = 'MÃ_PHIẾU_YÊU_CẦU_XUẤT';
    ```

---

### 9.10. Xác Nhận Thực Xuất (Shipment Confirmation)
*   **Mã Form ID:** `deliverOutConfirmationDocument`
*   **Vận hành của User:** Bốc xếp hàng lên Container thực tế, in tem Pallet và quét dán nhãn pallet xe, nhập số tờ khai hải quan và số vận đơn Bill of Lading để kế toán ghi nhận doanh thu.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_DELIVER_OUT_CONFIRMATION`.
    *   `SmartFactoryV2.dbo.STB_SetInfo` (Ghi nhận gộp Pallet và trừ tồn kho vật lý).
    *   `NEOE.dbo.MM_GI_LINE` (Trừ tồn kho thành phẩm thực tế hạch toán ERP).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* **B750** (Pallet Label - In tem nhãn Pallet), **B752** (Container Monitor - Giám sát bốc cont).
    *   *Stored Procedure:* `usp_DoApplyRealShipment` (trừ tồn kho MES và trigger xuất hàng thực tế lên ERP).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        SC.DOCUMENT_SAVE_CODE AS [GW Confirm Code],
        SC.NO_CUSTOMS AS [Customs Declaration],
        SC.NO_BL AS [B/L Number],
        -- Kiểm tra Pallet đã được quét đóng niêm phong trong MES chưa
        (SELECT COUNT(DISTINCT Barcode) FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) 
         WHERE PONo = SC.DOCUMENT_SAVE_CODE) AS [Pallets Loaded in MES],
        -- Kiểm tra trừ kho hạch toán trên ERP
        (SELECT SUM(QT_GI) FROM NEOE.dbo.MM_GI_LINE WITH(NOLOCK) 
         WHERE NO_IS = SC.DOCUMENT_SAVE_CODE) AS [ERP Outbound Qty]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_DELIVER_OUT_CONFIRMATION SC WITH(NOLOCK)
    WHERE SC.DOCUMENT_SAVE_CODE = 'MÃ_PHIẾU_XÁC_NHẬN_XUẤT';
    ```

---

### 9.11. Chỉ Thị Sản Xuất Ngày (Daily Production Order)
*   **Mã Form ID:** `dailyProductionOrderDocument`
*   **Vận hành của User:** Lập lịch ngày sản xuất, phân bổ Line máy chạy, Ca làm việc, ngày bắt đầu chạy và số lượng chỉ thị chi tiết.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_DAILY_PRODUCTION_ORDER` & `_LOT`.
    *   `SmartFactoryV2.dbo.STB_DayProdPlan` (Mở ca sản xuất ngày trên MES).
    *   `SmartFactoryV2.dbo.STB_SetInfo` (Sinh cấu trúc Lot hàng sản xuất).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* **B450** (Daily Production Plan - Thiết lập kế hoạch ngày, chia Lot, in tem Lot).
    *   *Stored Procedure:* `usp_SyncDailyProductionPlan` (đồng bộ kế hoạch ngày từ Groupware xuống MES).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        GW_D.DAY_PLAN_NO AS [GW Plan No],
        GW_D.LINE_CODE AS [Line],
        GW_D.WORK_DATE AS [Date],
        GW_D.PLAN_QTY AS [GW Qty],
        -- Đối chiếu kế hoạch sản xuất ngày dưới MES
        MES_D.DayProdPlanNo AS [MES Plan No],
        MES_D.ProdOrderQty AS [MES Qty],
        MES_D.JobState AS [MES State], -- '0' = Đang chốt, '1' = Chạy máy
        -- Kiểm tra số lượng Lot con đã được chia ở MES B450
        (SELECT COUNT(*) FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE DayPlanNo = GW_D.DAY_PLAN_NO) AS [Lots Split Count]
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_DAILY_PRODUCTION_ORDER GW_D WITH(NOLOCK)
    LEFT JOIN SmartFactoryV2.dbo.STB_DayProdPlan MES_D WITH(NOLOCK)
        ON GW_D.DAY_PLAN_NO = MES_D.DayProdPlanNo
    WHERE GW_D.DAY_PLAN_NO = 'MÃ_KẾ_HOẠCH_NGÀY_GW';
    ```

---

### 9.12. Báo Cáo Sản Xuất Ngày (Daily Production Report)
*   **Mã Form ID:** `dailyProductionReportDocument`
*   **Vận hành của User:** Báo cáo sản lượng ca kết quả của Line máy, ghi nhận số lượng đầu vào, số lượng lỗi phế, thực tế sản xuất và link với Lot sản phẩm đã in tem.
*   **CSDL bị tác động:**
    *   `VINATECH_GROUP.dbo.VINA_DOCUMENT_DAILY_PRODUCTION_ORDER_LOT` (Cập nhật sản lượng thực tế Lot).
    *   `SmartFactoryV2.dbo.STB_ProdRouteHist` (Lịch sử công đoạn chạy máy).
*   **Màn hình MES & SP liên đới:**
    *   *Màn hình MES:* **B530** (Prod Route Input - Quét ghi nhận sản lượng hoàn thành công đoạn).
    *   *Stored Procedure:* `usp_DoFinishRouteOperation` (chốt công đoạn, cộng sản lượng tốt và ghi nhận lỗi).
*   **SQL Đối soát vận hành (SELECT-only):**
    ```sql
    SELECT 
        GW_L.LOT_NO AS [Lot/Box No],
        GW_L.PLAN_QTY AS [GW Target Qty],
        GW_L.PROD_QTY AS [GW Actual Qty],
        -- Kiểm tra lịch sử quét máy thực tế tại MES B530
        (SELECT SUM(ProdQty) FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK) 
         WHERE ControlNo = SI.ControlNo AND RouteCode = 'GATE_NAME') AS [MES Route Qty],
        SI.IsProdFinish AS [Is MES Lot Finished] -- 1 = Đã chốt sản xuất xong
    FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_DAILY_PRODUCTION_ORDER_LOT GW_L WITH(NOLOCK)
    LEFT JOIN SmartFactoryV2.dbo.STB_SetInfo SI WITH(NOLOCK)
        ON GW_L.LOT_NO = SI.Barcode
    WHERE GW_L.LOT_NO = 'MÃ_LOT_CẦN_TRA';
    ```

---

*Tài liệu được biên soạn và chuẩn hóa dựa trên phân tích trực tiếp cấu trúc của toàn bộ 13 hệ thống cơ sở dữ liệu vật lý tại Vinatech Việt Nam.*





---

## 11. Bảng Tra Cứu Cột Quan Trọng & Sơ Đồ ERD Cốt Lõi (Gộp từ KB_18)
