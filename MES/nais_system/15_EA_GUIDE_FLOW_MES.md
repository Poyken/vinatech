# HƯỚNG DẪN DÀNH CHO KỸ SƯ EA: PHÂN TÍCH LUỒNG DỮ LIỆU MES (TỪ NHẬP KHO ĐẾN THÀNH PHẨM)

> **Mục đích:** Tài liệu này bỏ qua các thao tác click chuột thông thường của người dùng, tập trung hoàn toàn vào **Trạng thái dữ liệu (Data Status)**, **Các cờ hệ thống (System Flags)**, **Nút thắt kỹ thuật (Bottlenecks)** và **Cách xử lý sự cố (Troubleshooting)** dành riêng cho EA/Support IT tại xưởng.

---

## 1. SƠ ĐỒ LUỒNG DỮ LIỆU CỐT LÕI (CORE DATA FLOW)

Dưới đây là sơ đồ dòng chảy dữ liệu (Data Flow) nhìn dưới góc độ của hệ thống MES, tập trung vào các **Bảng dữ liệu (Table/Lot)** và **Chốt chặn (Gate/Flag)**:

```mermaid
flowchart TD
    %% Định nghĩa màu sắc cho các node
    classDef kho fill:#f9f0ff,stroke:#cc99ff,stroke-width:2px
    classDef sx fill:#e6f3ff,stroke:#66b3ff,stroke-width:2px
    classDef qc fill:#ffebcc,stroke:#ffb366,stroke-width:2px
    classDef erp fill:#e6ffe6,stroke:#66cc66,stroke-width:2px
    classDef flag fill:#ffe6e6,stroke:#ff6666,stroke-width:3px,stroke-dasharray: 5 5
    classDef systemLog fill:#f2f2f2,stroke:#cccccc,stroke-width:1px,stroke-dasharray: 2 2

    %% --- PHASE 0: CẤU HÌNH HỆ THỐNG MASTER DATA ---
    subgraph PHASE_MD [Phase 0 - Master Data Từ ERP PLM Xuống MES]
        ERP_MD["(Hệ thống ERP)"]:::erp
        API_1(API Sync Interface):::systemLog
        MASTER_TABLES[("Các Bảng Cấu Hình MES<br/>(A230, A310, A418)")];
        
        ERP_MD --> |1. Đồng bộ Dữ liệu| API_1
        API_1 --> |2. Insert M_Materials| M_MATERIAL["Tạo Danh mục NVL<br/>(Loại: RAW/WIP/FG)"]
        API_1 --> |3. Insert M_BOMs| M_BOM["Lưu Công thức BOM<br/>(Lưu ý: BomVersion 99/2001)"]
        
        M_MATERIAL --> MASTER_TABLES
        M_BOM --> MASTER_TABLES
    end

    %% --- PHASE 1: KẾ HOẠCH BƠM XUỐNG XƯỞNG ---
    subgraph PHASE_PLAN [Phase 1 - Khởi Tạo Lệnh SX & Chốt Ngày]
        ERP_WO["(ERP - Đẩy Lệnh SX)"]:::erp 
        API_2(WO API Interface):::systemLog
        
        ERP_WO --> |4. Gửi Order Data| API_2
        API_2 --> |5. B310: Cắt làm PO Tháng| WO_TBL["Lệnh Tháng (W_WorkOrders)<br/>Trạng Thái: Active"]
        WO_TBL --> |6. B450: Khai báo Ca/Line| DP_TBL["Kế hoạch Ngày (W_DayPlans)"]
        
        DP_TBL --> |7. Nút FixDayPlan| FLAG_FIX{"Cờ Kế Hoạch:<br/>IsFixed == True?"}:::flag
        
        FLAG_FIX -- False / Null --> BLOCK_WO("Lock B540:<br/>Lỗi 'Plan is not Fixed'")
    end

    %% --- PHASE 2: KHO NVL & IQC ---
    subgraph PHASE_KHO [Phase 2 - Giao dịch Nhập Kho & Kích Hoạt NVL]
        F330_UI(Màn hình Nhập kho F330)
        F330_UI --> |8. Tách Tem & In Barcode| MAT_LOT["Table M_Lots:<br/> Sinh Lot NVL"] 
        MAT_LOT --> |9. Khởi tạo Vòng Đời| FLAG_DATE{"Cờ Đặc Tính 10:<br/>ExpireDate != Null?"}:::flag
        
        FLAG_DATE -- Null --> HOLD_MAT["/Kho Tạm Giữ/ (SubInv: Holding)<br/>Khóa xuất xưởng"]:::kho
        FLAG_DATE -- Co Date --> C220_UI(C220: IQC Đo lường) 
        
        C220_UI --> |10. Lưu Bảng QC| IQC_DATA["Q_IQC_Results<br/>Insert Value"]:::qc
        IQC_DATA -- Status == Fail --> BLOCK_MAT("Lock M_Lots:<br/>Trả lại NCC")
        IQC_DATA -- Status == Pass --> STOCK_TBL["I_Inventory: Cộng Tồn Kho<br/>(SubInv: Main)"]:::kho
        
        STOCK_TBL --> |11. F430: Xuất Line| ST_MOVE["Update I_Inventory:<br/>Chuyển SubInv -> Line"]:::systemLog
    end

    %% ĐIỀU KIỆN TIÊN QUYẾT MỞ KHÓA SẢN XUẤT (VẠN SỰ KHỞI ĐẦU NAN)
    FLAG_FIX -- 'True' --> ALLOW_RUN(MES Line B540 Sẵn Sàng Sáng Đèn)
    ST_MOVE --> ALLOW_RUN

    %% --- PHASE 3: DÂY CHUYỀN SẢN XUẤT CHÍNH ---
    subgraph PHASE_SX [Phase 3 - Quét Trạm, Trừ Kho & PQC]
        ALLOW_RUN --> |12. B540: Trigger Scan| CREATE_LOT(Bóp cò Scan Mã NVL):::sx
        
        CREATE_LOT --> |13. Bắn SP Transaction| WIP_LOT["W_WIPLots: Sinh Lot Mới<br/>Operation: Routing Trạm"]:::sx
        CREATE_LOT --> |14. Đối chiếu BOM Backflush| SP_CONSUME["Cấn Trừ Tồn Kho<br/>Dựa trên: UsageQty x ProQty"]:::systemLog
        SP_CONSUME --> |Trừ đi I_Inventory| STOCK_TBL
        
        WIP_LOT --> B597_UI(B597: SX tự đo)
        B597_UI --> |15. Check cấu hình TEST| TEST_OP_DATA["Insert Q_TestResults<br/>Flag: TEST"]:::sx
        
        WIP_LOT --> B530_UI(B530: Khai Lỗi)
        B530_UI --> |16. Gọi C132 Code| DEFECT_DATA["Insert Q_DefectHistory"]:::sx
        
        WIP_LOT --> C443_UI(C443: PQC Độc Lập)
        C443_UI --> |17. Check cấu hình QUALITY| PQC_DATA["Insert Q_PQC_Results<br/>Flag: QUALITY"]:::qc
        
        PQC_DATA -- Trạng thái = Fail --> BLOCK_OP("Force W_WIPLots.Status = Hold<br/>Lỗi: PQC Failed")
        PQC_DATA -- Trạng thái = Pass --> OP_DONE("W_WIPLots.Status = Run<br/>Chuyển Trạm")
    end

    %% --- PHASE 4 & 5: ĐÓNG GÓI CHỐT KẾT QUẢ ---
    subgraph PHASE_OUT [Phase 4 & 5 - Đóng Gói FG và OQC Đánh Giá Cuối]
        OP_DONE --> |18. B523: Check điều kiện đóng| FLAG_PKG{"Kiểm tra F110:<br/>IsUseBarCode / IsLotUse == True?"}:::flag
        FLAG_PKG -- False --> BLOCK_PKG("Lỗi:<br/>Item không cấu hình đóng gói")
        FLAG_PKG -- True --> PACKING_OP(Map Box Cha nối N Box Con)

        PACKING_OP --> |19. Sinh Barcode Outer 1 Lần| PACK_TBL["W_PackingLots:<br/>Chứa OuterBarcode"]:::sx
        
        PACK_TBL --> |20. C512: OQC Gọi Barcode| OQC_UI(C530: Test 10-20 Params)
        OQC_UI --> |21. Nguy cơ DB Deadlock cao| OQC_TEST_TBL["Q_OQC_Results:<br/>Insert Rất Nặng DB"]:::qc
        
        OQC_TEST_TBL --> FLAG_OQC{"Cờ OQC Thẩm phán:<br/>EvaluateResult == OK?"}:::flag
        FLAG_OQC -- Null / Fail --> BLOCK_FG("Từ chối cất Kho.<br/>Hold Line FG")
        FLAG_OQC -- OK --> FG_IN("Update Line Status: P-OQC")
        FG_IN --> |22. Lưu Bảng Hàng Hóa| FG_TBL["I_FG_Inventory (Kho FG)"]:::kho
    end

    %% --- PHASE 6: XUẤT KẾ TOÁN ---
    subgraph PHASE_END [Phase 6 - Interface Kết Thúc API Lên Kế Toán]
        FG_TBL --> |23. B453: Đánh dấu In tem| FLAG_OUTER{"UI: Tick 'Là tem ngoài'?"}:::flag
        FLAG_OUTER -- True --> OUT_DELIVERY("Update I_FG_Inventory.IsOuterPrinted = True")
        OUT_DELIVERY --> |24. Trigger Background Job| JOB_SYNC(Hangfire Job:<br/>Đẩy Data qua EDI):::systemLog
        JOB_SYNC --> |25. Báo Cáo Ghi Nhận Doanh Thu Tạm Tính| ERP_SYNC["(Nhảy Data Kế Toán ERP)"]:::erp
    end
```

---

## 2. TỔNG QUAN LUỒNG DỮ LIỆU CHÍNH & EA CHECKPOINTS

Luồng đi vật lý: `Kho NVL` → `Cell Line / Sản xuất` → `QC` → `Đóng gói` → `Kho Thành Phẩm`.
Dưới lăng kính Database của MES, 1 Lot hàng phải đi qua các trạng thái (Status) nghiêm ngặt. Chỉ 1 Status bị kẹt/sai, toàn bộ chuỗi phía sau sẽ dừng chạy. 

---

## 2. PHASE 1: KHO NVL - NGUYÊN VẬT LIỆU ĐẦU VÀO
*Nhiệm vụ của MES: Khai sinh dữ liệu, gán mã vạch và cấp quyền sử dụng.*

| Màn hình | Sự kiện Dữ liệu (Event) | ⚠️ Điểm Nóng DB / EA Cần Xử Lý (Troubleshooting) |
|---|---|---|
| **F312** | Ghi nhận Inovice. Trạng thái: `CREATE` | Giao tiếp API ERP thường đổ dữ liệu vào `W_WorkOrder_IF`. Kiểm tra Middleware / Log nếu mất DO/PO. |
| **F330** | Nhập kho. Trạng thái: `ARRIVAL` | **Lỗi `Null` cờ Đặc tính 10 (Hạn sử dụng):** Nếu F330 chạy xong mà cột `ExpireDate` rỗng, Data rớt thẳng vào kho `Holding` (Bị giam cấm xuất). EA cần check Màn A để xem Master Data vòng đời vật tư đã khai báo chưa. |
| **F330** | Tách tem (Lô nhỏ lưu vào `M_Lots`) | Bắt buộc `ScanQty` phải == `ReceiveQty`. Lỗi máy in treo ngắt điện sinh in đè tem trùng (Duplicate ID). EA cần `Void` lệnh in trên DB nếu kẹt cứng. |
| **C220** | IQC QC check (`Q_IQC_Results`) | Nếu Fail -> Trả NCC. Nếu Pass -> Mở khóa cờ `Status` để Update Tồn kho. |
| **F430** | Đổi kho (Lệnh `Move Inventory`) | Về bản chất DB là lệnh **Update `SubInv` từ `Main` sang `Line`**. Nếu Line bóp cò báo "No stock", bật SSMS Query xem lô M_Lots này đang kẹt ở cõi `Holding` hay `Main`. |

---

## 3. PHASE 2: CẤU HÌNH & KẾ HOẠCH SẢN XUẤT
*Nhiệm vụ của MES: Tạo Work Order (WO) và mở cổng nối dữ liệu với xưởng.*

| Màn hình | Sự kiện Dữ liệu (Event) | ⚠️ Điểm Nóng DB / EA Cần Xử Lý (Troubleshooting) |
|---|---|---|
| **B310** | Tạo WO Lệnh Tháng (`W_WorkOrders`) | **Lỗi Khai Báo BOM (`BomVersion`):** Nếu Line dính Error "Lắp sai Part / Null Data", Check Column `BomVersion` ở bảng này. Việc kéo bản Version 99 hay 2001 (Bắc Ninh) sai sẽ khiến Backend Backflush chênh lệch định mức. |
| **B310** | Chốt PO | Update cờ `Status` = `Active`/`Released`. Cờ này bằng False thì B450 tịt ngòi. |
| **B450** | Kế hoạch Ngày (`W_DayPlans`) | **Cờ FixDayPlan (`IsFixed` = T/F):** Chạm mặt 100 lần 1 ngày. Nếu Cột này null, Màn Scan Máy trạm trả Error `Plan is locked`. EA gọi ĐT réo Planner bấm tick Checkbox liền! |

---

## 4. PHASE 3: CHẠY DÂY CHUYỀN (SẢN XUẤT & PQC)
*Nhiệm vụ của MES: Cấn trừ BOM (Backflush), đếm sản lượng, ghi nhận NG và truy xuất nguồn gốc (Traceability).*

| Màn hình | Sự kiện Dữ liệu (Event) | ⚠️ Điểm Nóng DB / EA Cần Xử Lý (Troubleshooting) |
|---|---|---|
| **B540** | Nuốt Mã NVL, Sinh `W_WIPLots` | Lỗi DB **"Wrong Component"**: Do Tool đọc sai BOM ở bảng `M_BOMs` kết hợp với `ExpireDate` rỗng. Hàm Store Proc SP_CONSUME không trừ được `I_Inventory` (`UsageQty` x `TargetQty`). |
| **B540** | Chuyển trạm (`Operation` Routing) | **Lỗi Bypass (Trốn Trạm):** Dữ liệu cột `Operation` nhảy cóc, DB báo Error *"Missing Operation"*. EA mở Admin Menu chạy tool `Catch-up` / `Return Line` ép lưu lại Log ảo. |
| **B530** | Nhập Lỗi Phế (`Q_DefectHistory`) | **Nạn Ách Tắc DEADLOCK Table:** Cuối ca, chục máy cùng gọi hàm Update `DefectQty` -> Query đụng ngầm Time-out. EA dùng SQL `sp_who2` kill Session treo. |
| **B597/C443** | SX và PQC bắn kết quả lên DB | **Lỗi nhầm Flag Cấu Hình:** Bảng Test lưu cờ định danh `TEST` (B597). Bảng PQC lưu `QUALITY` (C443). Móc lộn Cờ (Flag) trong Master C143 khiến Admin mò Truy xuất rỗng dữ liệu! |

---

## 5. PHASE 4: GỘP THÙNG & ĐÓNG GÓI
*Nhiệm vụ của MES: Nested Barcode (Mã vạch lồng nhau) - Thùng cha chứa nhiều Thùng con.*

| Màn hình | Sự kiện Dữ liệu (Event) | ⚠️ Điểm Nóng DB / EA Cần Xử Lý (Troubleshooting) |
|---|---|---|
| **A418, F110** | Đọc Config Màn Pack | Bắt buộc bảng thuộc tính phải tick True cột `IsUseBarCode` và `IsLotUse`. Khuyết Data thì giao diện B523 Tối thui không nút để gộp. |
| **B523** | Insert `W_PackingLots` | **Luật In Độc Quyền 1 Lần:** Insert dòng mới kèm Map (`Outer` chứa `n` `Inner` Barcodes). Máy Zebra lỗi in nát mã vạch -> Cấm In Đè. EA mở Menu Tool Backend chạy lệnh **Void In** (Trả cờ về False) để thả cửa in lại lần 2. |
| **B523** | Chia lô (Split Box) | Người dùng ngáy ngủ chia nhầm hệ số `Qty`, Data nở toác. EA Trace `Transaction_History` đọc Log Rollback lại thao tác bằng dòng Query tay. |

---

## 6. PHASE 5 & 6: OQC VÀ KHO THÀNH PHẨM (FG)
*Nhiệm vụ của MES: Gắn cờ "HÀNG OK", khóa sổ dữ liệu sản xuất, đồng bộ lên ERP.*

| Màn hình | Sự kiện Dữ liệu (Event) | ⚠️ Điểm Nóng DB / EA Cần Xử Lý (Troubleshooting) |
|---|---|---|
| **C512** | Kéo Mẫu OQC Local DB | Lỗi UI Empty Box: Quét mãi không nảy số? Check DB bảng Cấu Hình Màn A410 xem 2 cột `Type_Check` và `OQC_Type` đã map chưa! |
| **C530** | Insert 20 Cột `Q_OQC_Results` | **Hiệu Năng Rùa Bò (Laggy):** Bóp Cò C530 tương đương lệnh SQL Save 20 Variables! Nếu Timeout rớt mạng ngang -> Record Insert nhưng rỗng cờ `EvaluateResult = OK`. Cờ này bằng Null = Khóa cửa vô kho FG! |
| **C546** | Đo điện trở cuộn ESR | Pass thì Update cờ `Status` Lô gốc trong `W_WIPLots` thành `P-OQC` (Án chết của vòng đời WIP). |
| **B453** | Tick Cờ In `IsOuterPrinted` | Lên xe tải: Nếu Tool check Cột Cờ này `=== False` -> Lệnh Delivery `I_FG_Inventory` mồ côi Không Load vô Bill xuất hàng! Bắt User Click Tick Lại là xong. |
| **Job_EDI** | API ERP Tích Tắc 10 Phút | Logic API Đẩy/Kéo Data Fail do timeout mạng. Kế toán ới lệch Data Phế Liệu? Log vào IIS / Kestrel / Hangfire Re-Run Cục Gạch Job API! |

---

## 7. BỘ KỸ NĂNG VÀ TOOLKIT CỦA EA SỬ DỤNG HÀNG NGÀY TRÊN MES

1. **Genealogy Tree Search (Cây Truy Xuất):** Trace NG ngược/xuôi cực lẹ. Khi Audit xuống kiểm tra, gõ 1 Barcode FG ra luôn cái sơ đồ 10 bước lắp các thành phần, từ ca nào làm, nhân viên nào hàn.
2. **Forward Traceability (Truy Xuất Xuôi) & Lot Hold:** Truy tìm các lô thành phẩm liên đới để Block/Khóa khẩn cấp nguyên một dàn lô khi phát hiện hóa chất đầu vào bị hỏng.
3. **Database Activity Monitor / Logs Check:** Luôn tự trang bị thói quen bấm F12 (Web) hoặc coi Event Viewer/Log folder khi User than "Lỗi". EA tin vào Log Server ghi `Deadlock` hay `NullRef` chứ ko tin mắt nhìn chữ "Error rớt mạng" ngoài màn hình.
4. **Hiểu "Hai Cuốn Sổ" (MES vs ERP):** Lệnh Kế hoạch (Work Order) và Tồn kho Tổng sống ở nhà Kế Toán (ERP/SAP). Tiến độ dây chuyền và Serial Number cực chi tiết sống ở MES. Lệch số là do Cầu nối API / Sync Batch Job bị đứt đoạn. EA chính là người xây và thông cái cống mương API này!

*Tài liệu đúc kết cho khối EA System Admin | Ngày tạo: 2026-03-10*
