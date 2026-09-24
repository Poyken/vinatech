<!--
AI-READY METADATA
Purpose: Cẩm nang xử lý sự cố khẩn cấp trên hệ thống POP Web Kiosk Vinatech
Scope: Toàn bộ các lỗi vận hành POP, Kiosk phần cứng, API lỗi, kẹt Lot, lỗi in tem, và SQL Fix Scripts
Single Source of Truth: POP_KB_03_TROUBLESHOOTING.md
Target Tables: STB_SetInfo, STB_MaterialLotInfo, STB_PackingInfo, VINA_MATERIAL_INPUT_HIST, STB_DayProdPlan
Related Files:
  - [POP_KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)
  - [POP_KB_01_ARCHITECTURE_AND_API.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_01_ARCHITECTURE_AND_API.md)
  - [POP_KB_02_SCREEN_OPERATIONS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_02_SCREEN_OPERATIONS.md)
  - [POP_KB_04_ROLLBACK_AND_SAFETY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_04_ROLLBACK_AND_SAFETY.md)
-->

# POP_KB_03 — Cẩm Nang Xử Lý Sự Cố POP (Troubleshooting & Incident Guide)

> **Hệ thống:** POP Kiosk Web — `https://pop.vinatech.com/`  
> **Phạm vi:** Chẩn đoán sự cố, Root Cause Analysis (RCA), Hướng xử lý nhanh và SQL Hotfix cứu hộ  
> **🔑 Keywords:** troubleshoot, error, fix, bug, incident, timeout, printer, stuck lot, material error, packing error  
> ← [Về INDEX](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)

---

## 1. 🚨 DANH MỤC SỰ CỐ KHẨN CẤP NHANH (QUICK DIAGNOSTIC MATRIX)

| Mã lỗi / Hiện tượng | Nguyên nhân gốc (Root Cause) | Khắc phục nhanh | Cần can thiệp SQL? |
|---------------------|-----------------------------|-----------------|--------------------|
| **POP-ERR-01: Không đăng nhập được** | Hết hạn SSO Token, sai mật khẩu, hoặc IIS AppPool restart | Xóa cache trình duyệt (Ctrl+F5), đăng nhập lại | Không |
| **POP-ERR-02: Trống danh sách Work Order** | DayPlan chưa kích hoạt trạng thái Release trên MES WinForm | Kỹ sư MES kích hoạt DayPlan trên WinForm B530 | Không |
| **POP-ERR-03: Thẻ LOT không hiển thị** | Lot đang bị HOLD, hoặc Lot đã finish, hoặc sai Line Code | Kiểm tra trạng thái Lot trên MES WinForm | Kiểm tra SELECT |
| **POP-ERR-04: Lỗi NVL không khớp BOM** | Mã cuộn NVL quét vào không nằm trong định mức Model | Kiểm tra lại tem cuộn NVL, đối chiếu BOM | Không |
| **POP-ERR-05: Lỗi NVL âm kho (Negative Stock)** | Cuộn NVL trên hệ thống đã trừ hết Qty trước đó | Báo kho cấp thêm hoặc bổ sung Lot NVL mới | Có thể |
| **POP-ERR-06: Không Merge được các Lot lẻ** | Khác chủng loại (Model mismatch) hoặc khác quy cách | Chỉ gộp các Lot cùng chung Model Code | Không |
| **POP-ERR-07: Lỗi in tem (Zebra Printer Fail)** | Máy in offline, kẹt giấy, mất IP LAN, hoặc ZPL format lỗi | Bật máy in, check đèn đỏ, kiểm tra Print Spooler | Không |
| **POP-ERR-08: Kẹt nút "Hoàn thành sản xuất"** | Thiếu bước nạp NVL bắt buộc (IsLineInput = 0) | Hoàn thành nạp NVL theo định mức trước khi Save | Không |
| **POP-ERR-09: Lỗi "This route is already completed in MES"** | Công đoạn đã có lượt chốt cũ/thử trong `STB_ProdRouteHist`, WinForm chặn POP | Xóa lượt chốt kẹt cũ trong `STB_ProdRouteHist` & `STB_ProdRouteWorkerHist` | **CÓ (SQL Hotfix)** |
| **POP-ERR-10: Lỗi chốt sớm Đóng gói V-28_HY** | Chốt đóng gói trước khi hoàn tất BTP/Lot lẻ, kẹt `VINA_PACKING_REMAIN_QTY` | Rollback đồng bộ 3 bảng (`MaterialLotInfo`, `ProdRouteHist`, `VINA_PACKING_REMAIN_QTY`) | **CÓ (SQL Hotfix)** |
| **POP-ERR-11: Lỗi "Số mẫu mục tiêu là 0" (Quality PQC)** | Sample Size = 0 ở khung quy cách hoặc Master Data, không hiện ô nhập `#1, #2` | Chạm ô số mẫu ở khung tiêu chuẩn để tăng >0, hoặc cấu hình `STB_MaterialQcInspectionItem_HY` | Không (trừ khi sửa Master) |
| **POP-ERR-12: Khóa kết quả đo sau khi bấm "Hoàn thành"** | Phiên PQC đã đóng (`STB_CommInspDocHistory.IsFinished=1`), nút đổi thành "Hoàn tác" | Bấm Hoàn tác gửi yêu cầu (Admin duyệt `VINA_REOPEN_REQUEST`) hoặc IT reset `IsFinished=0` | Cần duyệt / SQL |
| **POP-ERR-13: Lệch / Không đồng nhất công đoạn giữa Kiosk POP và MES** | Chốt chéo WinForm trước Kiosk, nhảy cóc công đoạn V-27_HY sang V-28_HY, hoặc kẹt dở dang V-26_HY | Dùng Golden Query `.\mes.ps1 trace '<Lot>'`. Xóa bản ghi kẹt cũ qua Template 3 hoặc rollback Đóng gói qua Template 4 | **CÓ (SQL Hotfix)** |
| **POP-ERR-14: Thùng Dung Dịch Về 0 KG / Hết Hàng (VN ➔ HY)** | Xung đột chuyển vùng kho (Hà Nam sang Hưng Yên) hoặc cơ chế tự động đóng thùng cũ khi quét Lot mới | Phục hồi lại toàn bộ số lượng ban đầu (150 KG theo InitialQty) tại `ROUTE_HY_WH` và reload Kiosk POP | **CÓ (SQL Hotfix)** |
| **POP-ERR-15: Đã xóa STB_ProdRouteHist nhưng Kiosk vẫn hiện "Công đoạn đã hoàn thành"** | Chưa xóa bản ghi tương ứng trong `MongoToMesPerformance` (`IsDone = 1`) | Dùng Template 7 xóa dòng công đoạn kẹt trong `MongoToMesPerformance` và F5 Kiosk | **CÓ (SQL Hotfix)** |
| **POP-ERR-16: Tem Thùng In Từ Kiosk POP Bị Co Ngắn Mã Vạch (Scanner không đọc được)** | Kiosk POP thiếu engine sinh `PackingID` chuẩn 11 ký tự (`PK...`), `AutoModule` làm co vạch | In lại tem chuẩn từ MES WinForm (màn hình B523/B528) hoặc vệ sinh đầu in | Không (In WinForm) |
| **POP-ERR-17: Kiosk Hiển Thị Bước Kế Tiếp Dù Chuyền Mới Chốt Bước Trước** | Hành vi chuẩn: MES tự động tạo pre-allocated slot với `CompleteRoute = NULL` | Kiểm tra query `CompleteRoute IS NULL` là bình thường, không phải lỗi | Không |
| **POP-ERR-18: Kẹt Pipeline Đồng Bộ POP ➔ MES (Worker bị treo / `IsTransferred = 0`)** | Background Polling Worker IIS bị treo hoặc đứt kết nối SQL (Line `VVC-11`) | Dùng Template 8 kiểm tra, restart AppPool IIS, hoặc dùng Template 9 chốt bù thủ công | **CÓ (SQL Hotfix)** |
| **POP-ERR-19: Lỗi "Không Tìm Thấy LOT Trong Kho" Khi Nạp Cuộn Điện Cực / NVL BOM** | Bên Điện cực đã xuất vào kho `ROUTE_VN_WH` nhưng cuộn mang mã BTP mới (vd: `SRECYK0-900`) trong khi BOM của Lệnh SX (PO) lại khai báo mã quy cách cũ (`SRFCO85 / SREYO85`), hoặc mã cũ trong kho có tồn = 0 | Map bổ sung mã NVL mới vào BOM của PO (`STB_ProductionOrderBom`) hoặc sửa `MaterialCode` cuộn khớp BOM, sau đó bấm `Danh sách NVL BOM 🔄` (Reload) trên Kiosk POP | **CÓ (BOM Map / Master)** |
| **POP-ERR-20: POP Kiosk Thiếu Thiết Bị / Ẩn Máy Tại Modal "Xác Nhận Kết Thúc" (Winding/Curling/Sleeving)** | Máy bị kẹt trạng thái `MAPPING_STATUS = 'ACTIVE'` trong `VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING` từ Kế hoạch sản xuất (`DAY_PLAN_NO`) cũ do OP không bấm "Hủy gán / Release" khi xong ca và POP thiếu Auto-Release | Giải phóng máy: chạy script UPDATE `VINA_EQUIPMENT_MAPPING SET MAPPING_STATUS = 'RELEASED', RELEASED_AT = GETDATE(), NO_EMP_MODIFYER = 'vanduc'` cho các Plan cũ | **CÓ (SQL Hotfix)** |
| **POP-ERR-21: Mã Lỗi Phế Bị Ẩn / Thiếu DefectQty Do Three-Valued Logic** | Cột `IsDelete` và `RepairQty` trong `STB_DefectRepairInfo` bị `NULL`, mệnh đề `WHERE IsDelete = '0'` lọc mất bản ghi | Chạy Template 11: UPDATE `IsDelete = '0'`, `RepairQty = 0` và đồng bộ lại `STB_SetInfo.DefectQty` | **CÓ (SQL Hotfix)** |
| **POP-ERR-22: Lỗi "Already transferred to MES. Cannot modify"** | Bản ghi sản lượng hoặc phế đã được luồng ngầm đồng bộ sang MES WinForm (`IsTransferred = 1`), giao diện Kiosk khóa quyền xóa/sửa | Nếu nhập sai phế hoặc sản lượng, IT phải can thiệp điều chỉnh trực tiếp trên WinForm hoặc chạy Hotfix chuẩn bọc TRAN | **CÓ (SQL Hotfix)** |
| **POP-ERR-23: Lỗi "실적이 없는 공정입니다. 실적 등록 후 추가하세요"** | Chưa đăng ký số lượng tốt (Good Qty) mà OP đã bấm thêm phế phẩm hoặc bấm kết thúc công đoạn | Nhập sản lượng sản xuất tốt trước vào ô `양품수량`, sau đó mới mở modal phế phẩm và bấm hoàn tất | Không |
| **POP-ERR-24: Lỗi Chặn Nạp Cuộn "This roll has already been used for 2 product LOTs"** | Ràng buộc nghiệp vụ toàn vẹn: 1 cuộn BTP điện cực chỉ được phép cắt/nạp tối đa cho 2 LOT sản phẩm, quét sang LOT thứ 3 bị chặn | Đổi sang cuộn điện cực mới chưa vượt quá 2 LOT. Không cố quét ép cuộn đã dùng đủ định mức | Không |
| **POP-ERR-25: Lỗi Trình Tự Coating "코팅 생산수량 등록 후 불량등록이 가능합니다"** | Trình tự bắt buộc tại công đoạn Coating: Hệ thống yêu cầu phải ghi nhận chiều dài Coating trước khi đăng ký phế | Nhập mét màng Coating tốt trước, sau đó mới bấm đăng ký các mã phế phẩm mẻ trộn/tráng phủ | Không |
| **POP-ERR-26: Lỗi Thiếu Người Kiểm Tra "작업자를 먼저 지정해 주세요"** | Chưa chọn hoặc chưa quét thẻ nhân viên kiểm tra (Inspector) trước khi lưu biên bản PQC/In-Line QC | Quét thẻ nhân viên hoặc chọn mã công nhân kiểm tra tại ô `검사자` trước khi bấm Lưu | Không |
| **POP-ERR-27: Lỗi Khóa Liên Động Mixing ➔ Coating "믹싱 공정이 완료되지 않았습니다"** | Mẻ trộn Mixing chưa nạp đủ 100% các mã NVL theo định mức recipe (còn tồn đọng NVL chưa quét) | Mở bảng danh mục NVL Mixing, quét bổ sung đầy đủ các mã NVL còn thiếu rồi mới chốt Coating | Không |
| **POP-ERR-28: Lỗi Thiếu Foil "호일 부족: 코팅 생산수량 > 투입 호일 가용 길이"** | Cân bằng vật tư: Chiều dài sản phẩm Coating đăng ký vượt quá tổng chiều dài lá Foil kim loại đã quét nạp | Quét nạp thêm cuộn Foil kim loại bổ sung vào ô Slot NVL để bù đắp số mét thiếu hụt | Không |
| **POP-ERR-29: Lỗi Chặn Đóng Gói "Material input is required before packing"** | Công đoạn Đóng gói (Packing) bắt buộc phải quét nạp vật tư tiêu hao (thùng carton, túi hút ẩm, tem nhãn) | Quét đủ mã vạch thùng và túi đóng gói theo định mức rồi mới bấm Hoàn thành đóng gói | Không |
| **POP-ERR-30: Lỗi Sai Vùng Kho "Electrode roll cannot be input from another work center warehouse"** | Cuộn BTP điện cực đang nằm ở vị trí kho của Phân xưởng khác (chưa chuyển kho sang Line hiện tại) | Yêu cầu bộ phận kho làm phiếu chuyển kho (Warehouse Transfer) trên hệ thống sang đúng Chuyền | Không |



---

## 2. 🔍 CHI TIẾT SỰ CỐ & QUY TRÌNH XỬ LÝ CHUẨN

### 2.1 POP-ERR-01: Lỗi Truy Cập & Đăng Nhập Kiosk

**Hiện tượng:** Trình duyệt báo `401 Unauthorized`, `Token Expired`, hoặc màn hình trắng xóa khi mở `https://pop.vinatech.com/`.

**Quy trình kiểm tra:**
1. Mở Console trình duyệt (`F12`): Kiểm tra xem API gọi `/api/common/login` hay `/api/common/verifyToken` trả về mã gì.
2. Nếu mã lỗi `401`: Token JWT trong LocalStorage đã quá hạn (thường sau 8 giờ hoặc đổi ca).
   - **Xử lý:** Bấm nút **"Đăng xuất"** hoặc xóa Cookie/LocalStorage, sau đó đăng nhập lại bằng User ID & Password.
3. Nếu mạng báo `ERR_CONNECTION_REFUSED`: 
   - Kiểm tra kết nối mạng nội bộ của Kiosk tới IP Web Server (`dbserver.hycap.co.kr` hoặc Server IIS POP).
   - Kiểm tra dịch vụ IIS trên máy chủ POP.

---

### 2.2 POP-ERR-02 & 03: Không Thấy Lệnh Sản Xuất (WO) Hoặc Thẻ LOT

**Hiện tượng:** Chọn đúng Chuyền (Line) và đúng Ngày nhưng bảng danh sách Lệnh SX hoặc Thẻ Lot trống rỗng.

**Root Cause:**
1. **Lệnh SX chưa phát hành:** Quản lý sản xuất tạo Kế hoạch ngày nhưng chưa ấn nút "Phát hành" (Release/Confirm) trên MES WinForm.
2. **Lot chưa được gán vào Chuyền:** Lot được tạo nhưng `CurrentLineCode` bị lệch so với Line mà Kiosk đang chọn.
3. **Lot bị chặn (HOLD):** Lot bị QC gắn cờ `IsHold = 1` do phát sinh sự cố ở công đoạn trước.

**Kiểm chứng nhanh bằng SQL (SELECT-Only):**
```sql
-- Kiểm tra trạng thái Kế hoạch ngày
SELECT PlanDate, DayPlanID, LineCode, ModelCode, PlanQty, ProdQty, PlanStatus
FROM SmartFactoryV2.dbo.STB_DayProdPlan WITH(NOLOCK)
WHERE LineCode = N'<MÃ_LINE>' AND PlanDate = CONVERT(VARCHAR(10), GETDATE(), 120);

-- Kiểm tra trạng thái Lot
SELECT LotNo, ModelCode, CurrentLineCode, CurrentRouteCode, IsHold, IsComplete, BadQty, GoodQty
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
WHERE LotNo = N'<LOT_NO>';
```

---

### 2.3 POP-ERR-04 & 05: Sự Cố Nhập Nguyên Vật Liệu (Material Input)

**Hiện tượng:** Quét mã vạch cuộn NVL, màn hình báo popup đỏ: *"Vật liệu không hợp lệ"* hoặc *"Số lượng tồn kho không đủ"*.

**Nguyên nhân & Cách khắc phục:**
1. **Sai BOM:** Kiểm tra cấu trúc BOM của sản phẩm. Cuộn NVL quét vào phải có mã vật tư (`MaterialCode`) trùng khớp với BOM đã phê duyệt của Model hiện hành.
2. **Hết tồn kho trên hệ thống:** Dù thực tế cuộn vật liệu còn trên tay, nhưng trong hệ thống `SmartFactoryV2.dbo.STB_MaterialLotInfo`, cột `Qty` đã bằng 0 (do ca trước đã quét trừ hết).
   - *Khắc phục:* Yêu cầu thủ kho MES nhập phiếu bổ sung NVL hoặc đổi sang cuộn tem khác có tồn kho hợp lệ.
3. **⭐ Không hiển thị ô (Slot) quét NVL trên Kiosk (Dù trong BOM có đầy đủ):**
   - *Hiện tượng:* Mở công đoạn trên POP Kiosk (ví dụ Winding, Curling) nhưng không tìm thấy ô quét NVL (như Đế dán `BOTTOM-PLATE`, Terminal plate `TERMINAL-PLATE`, Cao su, Màng co...).
   - *Nguyên nhân:* Line đó đã được bật chế độ nạp theo nhóm (`VINA_ASSEMBLY_GROUP_MODE.INPUT_MODE = 'GROUP'`), nhưng chưa được cấu hình (thiếu slot) cho nhóm vật tư đó trong bảng `VINATECH_POP.dbo.VINA_GROUP_INPUT_ROUTE`.
   - *Khắc phục trên Web UI:* Vào **POP Setting ➔ Assembly Group Mapping (`/popSetting/assemblyGroupMapping`)**, chọn Line cần sửa ➔ Bấm **Thêm Slot** hoặc dùng nút **Copy cấu hình** từ Line mẫu đã chuẩn ➔ Công nhân bấm **F5** lại Kiosk là sẽ hiện ô quét.

---

### 2.4 POP-ERR-06: Lỗi Khi Đóng Gói Gộp Thùng (Merge Pack)

**Hiện tượng:** Bấm chọn thêm Lot lẻ thứ 2, hệ thống từ chối và báo lỗi *"Không thể gộp các Lot khác quy cách"*.

**Quy tắc nghiệp vụ bất biến:**
- **Quy tắc 1:** Chỉ được merge các Lot có **cùng ModelCode** chính xác 100%.
- **Quy tắc 2:** Các Lot tham gia merge phải ở **cùng công đoạn Đóng gói** (`CurrentRouteCode` = Packing Route).
- **Quy tắc 3:** Tổng số lượng sau khi merge **không được vượt quá quy cách đóng gói tối đa** của Model (ví dụ: Box tiêu chuẩn là 200 cái, tổng các Lot lẻ không được vượt quá 200).

---

### 2.5 POP-ERR-07: Sự Cố Máy In Tem Nhãn (Zebra Label Printer)

**Hiện tượng:** Bấm in tem nhưng máy in không phản hồi, hoặc in ra tem trắng, hoặc tem bị lệch hàng.

**Checklist xử lý tại chỗ:**
1. **Kiểm tra phần cứng máy in:**
   - Đèn trạng thái trên máy in Zebra: Xanh lá (Ready), Đỏ nhấp nháy (Hết giấy hoặc ruy-băng mực), Vàng (Nắp mở).
   - Bấm nút **Feed** trên máy in để kiểm tra xem tem có đẩy ra đúng 1 con tem chuẩn không. Nếu đẩy ra nhiều tem: Cần **Calibrate** lại sensor máy in (giữ nút Feed cho đến khi đèn nháy 2 lần rồi nhả).
2. **Kiểm tra kết nối mạng / USB:**
   - Đảm bảo Kiosk vẫn nhận máy in trong Windows Printers (`ZDesigner ZT230` hoặc tương đương).
3. **In lại từ Web:** Mở tab **Lịch sử đóng gói** → Chọn lô đóng gói → Bấm **"In lại"**.

---

### 2.6 POP-ERR-08: Kẹt Nút "Hoàn Thành Sản Xuất" (Thiếu Bước Nạp NVL)
**Hiện tượng:** Công nhân chọn công đoạn và bấm **"HOÀN THÀNH SẢN XUẤT"** hoặc **"Ghi nhận sản lượng"** nhưng nút bị mờ (disabled), hệ thống không cho lưu hoặc báo thiếu điều kiện nạp vật liệu.

**Nguyên nhân gốc (Root Cause):**
- Công đoạn đang làm việc có cấu hình bắt buộc nạp NVL theo định mức BOM (`VINA_BOM_INPUT_ROUTE` hoặc `STB_BomDetail`).
- Lot chưa được ghi nhận hoàn tất nạp NVL (`STB_SetInfo.IsLineInput = 0`), hoặc các cuộn NVL bắt buộc chưa được quét đủ số lượng tối thiểu.

**Khắc phục nhanh:**
1. Chuyển sang tab/modal **[Nhập NVL]** (Material Input).
2. Quét đầy đủ các cuộn NVL theo danh sách định mức BOM (Điện cực dương, Điện cực âm, Vỏ nhôm, Dung dịch...).
3. Sau khi cột trạng thái NVL chuyển sang xanh lá hoặc `IsLineInput` chuyển thành 1, quay lại màn hình chính bấm **"HOÀN THÀNH SẢN XUẤT"**.

---

### 2.7 POP-ERR-09: Lỗi "This route is already completed in MES" Khi Chốt Công Đoạn
**Hiện tượng:** Công nhân chọn công đoạn (ví dụ Aging `V-26_HY`) và bấm **"HOÀN THÀNH SẢN XUẤT"** trên POP Kiosk, hệ thống văng popup đỏ: *"Thất bại: This route is already completed in MES."*. Quay sang mở MES WinForm (B530/B540) để chốt thủ công thì MES chặn: *"Vui lòng sử dụng hệ thống POP để nhập sản lượng"*.

**Nguyên nhân gốc (Root Cause):**
- Trong bảng `SmartFactoryV2.dbo.STB_ProdRouteHist`, công đoạn đó của Lot đã tồn tại sẵn một bản ghi chốt cũ (do chốt nhầm, chốt thử hoặc chạy dở từ các ca trước).
- API POP kiểm tra thấy công đoạn đã tồn tại nên chặn không cho chốt đè để tránh nhân đôi sản lượng. Đồng thời MES WinForm đã cấu hình chuyển giao quyền sang Kiosk nên từ chối nhập liệu.

**Quy trình khắc phục:**
1. Tra cứu `ProdRouteHistNo` của bản ghi kẹt cũ:
   ```sql
   SELECT ProdRouteHistNo, ControlNo, RouteCode, ProdQty, JobDate, CreateDateTime
   FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
   WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = N'<LOT_NO>')
     AND RouteCode = N'<MÃ_ROUTE>';
   ```
2. Thực hiện xóa bản ghi kẹt cũ trong `STB_ProdRouteWorkerHist` và `STB_ProdRouteHist` qua Template 3.
3. Hướng dẫn công nhân F5 Kiosk, chọn lại Lot và bấm **"HOÀN THÀNH SẢN XUẤT"** bình thường.

---

### 2.8 POP-ERR-10: Kẹt Đóng Gói Do Chốt Sớm Công Đoạn V-28_HY
**Hiện tượng:** Lot không thể đóng gói gộp hoặc in tem thùng tại trạm đóng gói POP Kiosk, hoặc người dùng muốn hủy các Box đã đóng gói (kể cả Box đơn lẻ hay Box đóng gộp Merge Pack).

**Nguyên nhân gốc:** Công đoạn `V-28_HY` bị chốt trước khi hoàn tất đóng gói thực tế, làm sinh bản ghi mồ côi trong `STB_MaterialLotInfo` và `VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY`.
**Khắc phục:** 
- *Cách 1 (UI Kiosk):* Vào menu Đóng gói -> Chạm nút **"Lịch sử"** -> Bấm **`[HỦY]`** trên từng Box hoặc **`[HỦY TẤT CẢ]`** (Slide 39).
- *Cách 2 (SQL Rollback đồng bộ):* Áp dụng **Template 4** (Case 1: chốt đơn lẻ, Case 2: đóng gói chia nhiều Box & Box gộp Merge Pack như incident `VVQR113R060640`).

---

### 2.9 POP-ERR-11 & 12: Sự Cố Phân Hệ Chất Lượng Quality (`/pop/quality/self`)
**Hiện tượng 1:** Màn hình đo PQC hiện thông báo *"Số mẫu mục tiêu là 0 — tăng số mẫu mục tiêu ở khung quy cách để hiện ô nhập"*, không có ô gõ số liệu.
- **Xử lý:** Chạm vào ô số mẫu `0/0` ở khung quy cách bên phải (bên dưới ô Tiêu chuẩn) để tăng số lượng mẫu đo lên (>0). Nếu là hạng mục đo định kỳ không bắt buộc theo Lot thì bỏ qua.

**Hiện tượng 2:** Nút "Hoàn thành" biến mất, thay bằng nút **`Hoàn tác`** và popup *"Lý do mở lại"*.
- **Nguyên nhân:** Phiên đo kiểm đã bấm `Hoàn thành` (`STB_CommInspDocHistory.IsFinished = 1` - Pass). Hệ thống khóa Read-only theo chính sách `VINA_REOPEN_POLICY`.
- **Cách mở lại:**
  - *Cách 1 (Chuẩn UI):* Gõ lý do bấm **"Gửi yêu cầu"**, Quản lý QC hoặc IT vào bảng `VINA_REOPEN_REQUEST` duyệt `STATUS = 'APPROVED'`.
  - *Cách 2 (SQL khẩn cấp):* IT reset cờ hoàn thành qua Template 5.

---

### 2.10 POP-ERR-13: Hiện Tượng Không Đồng Nhất Công Đoạn Giữa POP Kiosk và MES WinForm
**Hiện tượng:** 
1. Cùng 1 mã Lot nhưng xem trên POP Kiosk hiển thị công đoạn khác so với MES WinForm Desktop (B530/HY530).
2. Tại POP Kiosk, bấm "Hoàn thành sản xuất" bị chặn báo *"This route is already completed in MES"*, hoặc sang Đóng gói Kiosk bị báo *"Vượt quá số lượng còn lại (0 EA)"*.
3. Tại MES WinForm (B530), quét Lot thì bị popup chặn: *"Search failed: Vui lòng sử dụng hệ thống POP để nhập sản lượng"*.

**Nguyên nhân gốc (Root Cause):**
- **Xung đột chốt chéo (Dual-entry):** Dữ liệu công đoạn đã được chốt trước trên WinForm, DB đã ghi nhận bản ghi trong `STB_ProdRouteHist`. Kiosk POP đối chiếu thấy đã có bản ghi nên chặn ghi đè để bảo vệ số liệu.
- **Nhảy cóc công đoạn (Skip Route):** Bỏ qua công đoạn trung gian (như `V-27_HY` Ngoại quan) nhảy thẳng từ `V-26_HY` sang `V-28_HY` Đóng gói, hoặc công đoạn liền trước bị treo dở dang `CompleteRoute = NULL`.
- **Chốt sớm công đoạn đóng gói:** Chốt `V-28_HY` trên WinForm làm sinh BTP trong `STB_MaterialLotInfo` và tiêu thụ hết sản lượng khả dụng của Lot trên Kiosk.

**Quy trình chuẩn đoán & Khắc phục:**
1. Chạy Golden Query 360: `.\mes.ps1 trace '<LotID>'` để lấy `ControlNo`, đối soát trạng thái `STB_SetInfo` và các dòng trong `STB_ProdRouteHist`.
2. Nếu kẹt bản ghi công đoạn cũ ở giữa (Aging `V-26_HY`): Áp dụng **Template 3** xóa bản ghi kẹt cũ trong `STB_ProdRouteWorkerHist` và `STB_ProdRouteHist`.
3. Nếu chốt sớm công đoạn đóng gói (`V-28_HY`): Áp dụng **Template 4** rollback đồng bộ 3 bảng (`STB_MaterialLotInfo`, `STB_ProdRouteHist`, `VINA_PACKING_REMAIN_QTY`).

> [!NOTE]
> **Quy ước đánh số mục:** Các mục từ §2.14 trở đi được đánh số trực tiếp tương ứng với mã định danh lỗi `POP-ERR-14` đến `POP-ERR-20` để đồng bộ tuyệt đối với bảng chẩn đoán sự cố khẩn cấp (§1 Quick Diagnostic Matrix) và đảm bảo các liên kết tra cứu chéo không bị đứt gãy.

---

### 2.14 POP-ERR-14: Xung Đột Chuyển Vùng Kho (VN ➔ HY) & Thùng Dung Dịch (Electrolyte) Bị Trừ Hết 0 KG

**Hiện tượng:** 
- Trên màn hình POP Kiosk tại các chuyền lắp ráp Cell Hưng Yên (ví dụ: `HY Cell Line #13`, URL `https://pop.vinatech.com/pop/screen`), tại mục nạp NVL BOM, dòng Dung dịch điện phân (`전해액`, ví dụ `GBEC00-008` hoặc `GBCP00-004`) báo chữ đỏ **`Tồn kho: Hết hàng`** (0 KG).
- Nút **[NHẬP]** bị mờ/vô hiệu hóa, không cho công nhân nạp dung dịch vào Lot hiện tại (như `VVQR163R825715`).
- Mặc dù thực tế dưới chuyền, thùng dung dịch mới 150 KG vừa đưa lên máy chạy chưa được bao lâu (thực tế 150 KG dùng cho cả chuyền phải 2 ngày mới hết).

**Nguyên nhân gốc (Root Cause):**
1. **Xung đột chuyển vùng kho (Inter-Plant Warehouse Conflict):**
   - Thùng dung dịch được phòng ban kho xuất ban đầu tại nhà máy Hà Nam (`ROUTE_VN_WH`).
   - Khi chuyển sang nhà máy Hưng Yên để đưa lên chuyền Cell (`HY Cell Line`), màn hình POP Kiosk lọc tồn kho theo kho cục bộ **`ROUTE_HY_WH`**.
   - Khi công nhân quét Lot tại Hưng Yên, hệ thống tự động sinh 1 bản ghi mới ở `ROUTE_HY_WH` và đưa bản ghi cũ ở `ROUTE_VN_WH` về `0 KG`.
2. **Cơ chế chốt thùng tự động khi quét Lot mới (Auto-exhaust):**
   - Logic cấp liệu dung dịch trên chuyền coi mỗi máy chỉ gắn 1 thùng cấp liệu duy nhất.
   - Khi có công nhân quét một mã Lot dung dịch mới (hoặc quét lại Lot khi đổi ca/đổi line), hệ thống xem thùng cũ trước đó đã cạn và tự động cập nhật `CurrentQty = 0` cho bản ghi của thùng cũ ở `ROUTE_HY_WH`.
   - Kết quả: Thùng 150 KG thực tế dưới xưởng vẫn còn đầy, nhưng toàn bộ bản ghi trên CSDL MES đều bị đưa về 0 KG ➔ Kiosk POP báo "Hết hàng".

**Quy trình chuẩn đoán & Khắc phục:**
1. Tra cứu tồn kho thực tế của mã dung dịch trên live DB:
   ```sql
   SELECT LotID, MaterialWarehouseCode, InitialQty, CurrentQty, CreateDateTime, ChangeDateTime
   FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
   WHERE MaterialCode = 'MÃ_NVL_DUNG_DỊCH' -- ví dụ: 'GBEC00-008'
   ORDER BY CreateDateTime DESC;
   ```
2. Xác định LotID của thùng đang đặt tại máy ở Hưng Yên (ví dụ `ML20260331000035`).
3. **Phục hồi hoàn toàn đủ số lượng:** Bắt buộc phải phục hồi **100% số lượng ban đầu (`InitialQty = 150 KG`)**, KHÔNG phục hồi số lượng nhỏ lẻ, vì thùng còn gần như nguyên vẹn và cần dung sai lớn để chuyền chạy liên tục 2 ngày mà không bị ngắt quãng hệ thống giữa ca.
4. Áp dụng **Template 6** để UPDATE trả lại `CurrentQty = InitialQty` (hoặc 150 KG) tại `ROUTE_HY_WH`.
5. Yêu cầu công nhân trên Kiosk bấm nút **`Danh sách NVL BOM 🔄` (Reload)** ➔ Cột Tồn kho lập tức chuyển sang xanh (150 KG) và bấm **[NHẬP]** thành công.

> [!NOTE]
> **Trạng thái thực tế (Operational Status):** Sự cố điển hình này đã được EA Team (kỹ sư Nguyễn Văn Đức) can thiệp xử lý dứt điểm thành công cho Lot `ML20260331000035` trên Line #13 bằng Template 6. Về mặt vận hành, ca sự cố này đã ở trạng thái **RESOLVED / CLOSED**. Nếu tái diễn hiện tượng thùng dung dịch mới bị tụt về 0 KG tại các chuyền khác, tiếp tục kích hoạt Template 6 để khôi phục nhanh cho sản xuất.

---

### 2.15 POP-ERR-15: Đã Xóa `STB_ProdRouteHist` Nhưng Trên Kiosk POP Vẫn Hiện "Công Đoạn Này Đã Hoàn Thành"

**Hiện tượng:** 
- Đã chạy SQL xóa lượt chốt công đoạn downstream (ví dụ: `V-26_HY Aging` hoặc `V-24_HY`, `V-25_HY`) trong `STB_ProdRouteHist` và `STB_ProdRouteWorkerHist`.
- Đã UPDATE `STB_SetInfo.CurrentRouteCode = 'V-24_HY'`.
- Nhưng khi mở Kiosk POP Web (`pop.vinatech.com/pop/screen`), các công đoạn 24, 25, 26 vẫn hiển thị **dấu tích xanh `[✓]`**, số lượng **`987/987`**, thẻ Lot vẫn mang nhãn công đoạn sau (`[Visual Inspection (Ngoại quan)]`), và khi bấm vào công đoạn thì nút **`GHI NHẬN SẢN XUẤT`** vẫn bị mờ kèm dòng chữ: **`■ Công đoạn này đã hoàn thành`**.

**Nguyên nhân gốc (Root Cause):**
- Kiosk POP Web KHÔNG đọc trực tiếp từ `STB_ProdRouteHist` để vẽ trạng thái tiến độ tuần tự của Lot trên giao diện.
- Hệ thống POP Kiosk đọc từ bảng đồng bộ trung gian: **`SmartFactoryV2.dbo.MongoToMesPerformance`**.
- Bảng `MongoToMesPerformance` lưu trạng thái chốt công đoạn từ Kiosk (`IsDone = 1`, `TotalProdQty`, `SourceType = 'MANUAL'`).
- Dù đã xóa ở `STB_ProdRouteHist`, nhưng bản ghi trong `MongoToMesPerformance` vẫn còn `IsDone = 1`, khiến Kiosk POP tiếp tục hiểu là công đoạn đó đã được hoàn thành.

**Quy trình chuẩn đoán & Khắc phục:**
1. Tra cứu trực tiếp bảng `MongoToMesPerformance` theo mã Barcode của Lot:
   ```sql
   SELECT DayPlanNo, Barcode, RouteCode, TotalProdQty, IsDone, IsTransferred, SourceType, ModifyDateTime
   FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK)
   WHERE Barcode = 'MÃ_BARCODE'
   ORDER BY RouteCode;
   ```
2. Nếu thấy các công đoạn cần rollback có `IsDone = 1` (True):
   * Áp dụng **Template 7** để snapshot backup và xóa các dòng công đoạn đó khỏi `MongoToMesPerformance`.
3. Đồng bộ lại `STB_SetInfo.CurrentRouteCode` về công đoạn mong muốn.
4. Yêu cầu công nhân nhấn **F5** trên Kiosk POP ➔ Giao diện sẽ lập tức cập nhật lại trạng thái chưa hoàn thành và mở lại nút Ghi nhận sản xuất.

---

### 2.16 POP-ERR-16: Tem Thùng (Box Packing Label) In Từ POP Kiosk Bị Co Ngắn Mã Vạch & Máy Quét Không Đọc Được

**Hiện tượng:**
- Công nhân in tem dán thùng Box (`포장라벨NewVietNam`) từ màn hình Đóng gói Kiosk POP.
- Tờ tem in ra có mã vạch ở góc trên bên phải (`barCode4` - `PackingID`) bị co rúm lại bất thường, thanh vạch rất hẹp, ít nét hơn bình thường.
- Máy quét mã vạch (Barcode Scanner) tại chuyền hoàn toàn không đọc được mã này.

**Nguyên nhân gốc (Root Cause):**
1. **Thiết kế tem DevExpress:** Đối tượng `barCode4` dùng chuẩn **Code 128**, xoay 90° `RotateLeft`, nhận tham số `Expression = ?PackingID` với thuộc tính `AutoModule = true`. Độ rộng toàn dải mã vạch phụ thuộc trực tiếp vào **độ dài ký tự** của `PackingID`.
2. **Khác biệt luồng sinh mã:**
   - Trên **MES WinForm (B523)**: Gọi Stored Procedure `usp_Vietnam_DoProcessProdPacking_VVT` ➔ `usp_DoProcessProdPackingByOne_VNT`, tự động sinh mã `PackingID` chuẩn **11 ký tự** (`PK` + Năm/Tháng + Ngày + Serial 5 số, vd: `PKQR1900142`). Chuỗi 11 ký tự này tạo ra hệ vạch trải rộng hết chiều ngang của khung tem, scanner đọc ăn ngay 100%.
   - Trên **POP Kiosk**: Thiết kế cho thao tác chốt sản lượng nhanh, **không chạy engine sinh `PackingID` chuẩn vào bảng `STB_MaterialLotInfo`**. Khi bấm in trên POP, tham số `?PackingID` bị thiếu hoặc rút gọn ít ký tự ➔ `AutoModule = true` co cụm thanh vạch lại cực ngắn.
3. **Phần cứng máy in:** Đầu in nhiệt (thermal printhead) bị bẩn, trục lăn cao su hoặc ribbon mực bị chùng tạo bóng mờ kép (ghosting/double print) làm nhòe các vạch mảnh.

**Quy trình chuẩn đoán & Khắc phục:**
1. **Dưới xưởng (In lại tem chuẩn ngay):**
   - Mở MES WinForm trên máy tính ➔ Vào màn hình **B523** hoặc **B528**.
   - Quét mã Lot cha ➔ Chọn đúng Box con tương ứng (đã có sẵn mã `PKQR19001xx` 11 ký tự trong `STB_MaterialLotInfo`).
   - Bấm **"In lại tem"** ➔ Dán đè tem mới in từ WinForm lên thùng hàng.
2. **Bảo dưỡng phần cứng:** Vệ sinh ngay đầu in nhiệt bằng cồn chuyên dụng; căng lại cuộn ribbon mực tại Line.

---

### 2.17 POP-ERR-17: POP Kiosk Hiển Thị Bước Kế Tiếp (Slot Chờ Chốt) Dù Chuyền Mới Chốt Bước Trước

**Hiện tượng:**
- Công nhân mới chốt xong công đoạn Cuốn (`V-22_HY`), nhưng trên Kiosk POP đã hiển thị công đoạn tiếp theo là Lắp cao su (`V-23_HY`) với số lượng sản xuất, khiến tổ trưởng hiểu nhầm là hệ thống bị nhảy cóc hoặc đã chốt trước.

**Nguyên nhân gốc (Root Cause):**
- **Đây là hành vi ĐÚNG theo thiết kế của hệ thống MES, không phải lỗi:**
  - Khi chốt sản lượng tại `V-22_HY`, SP `usp_DoProcessProdRouteHist` tự động:
    1. Cập nhật `CompleteRoute = 1` cho `V-22_HY`.
    2. Tự động `INSERT` dòng công đoạn kế tiếp `V-23_HY` vào `STB_ProdRouteHist` với **`CompleteRoute = NULL`**.
  - Dòng có `CompleteRoute = NULL` này là **"slot chờ chốt" (pre-allocated slot)**, cho phép công nhân ở trạm tiếp theo quét barcode và bắt đầu thực hiện thao tác.
  - Kiosk POP đọc toàn bộ các dòng routing trong `STB_ProdRouteHist` nên hiển thị công đoạn này.

**Cách kiểm chứng:**
```sql
SELECT ControlNo, RouteCode, CompleteRoute, ProdQty, ProdDateTime 
FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH (NOLOCK) 
WHERE ControlNo = 'MÃ_CONTROL_NO' 
ORDER BY ProdDateTime ASC;
```
- Nếu dòng công đoạn tiếp theo có `CompleteRoute IS NULL` ➔ Hoàn toàn bình thường, chưa chốt thực tế.
- Nếu dòng đó có `CompleteRoute = '1'` hoặc `'Y'` ➔ Đã chốt thực tế.

---

### 2.18 POP-ERR-18: Sự Cố Kẹt Pipeline Đồng Bộ POP ➔ MES (Worker `getPendingTransferList` Bị Treo / `IsTransferred = 0`)

**Hiện tượng:**
- Công nhân đã bấm chốt sản lượng hoàn thành trên Kiosk POP (đã trừ NVL, đã hiện dấu tích xanh trên POP).
- Nhưng trên MES WinForm (màn hình B782, B530, B540) hoặc các báo cáo tiến độ không hề thấy sản lượng đâu.

**Nguyên nhân gốc (Root Cause):**
- Background Polling Worker trên IIS Server (`pop.vinatech.com`) gặp sự cố gián đoạn kết nối tới SQL Server, hoặc logic xử lý bị lock bởi một bản ghi lỗi trên dây chuyền cụ thể (điển hình từng kẹt trên Line `VVC-11`).
- Dữ liệu bị ứ đọng trong `SmartFactoryV2.dbo.MongoToMesPerformance` với trạng thái `IsDone = 1` nhưng `IsTransferred = 0`.

**Quy trình khắc phục:**
1. Chạy câu truy vấn kiểm tra danh sách các bản ghi bị nghẽn:
   ```sql
   SELECT DayPlanNo, Barcode, RouteCode, TotalProdQty, IsDone, IsTransferred, ModifyDateTime 
   FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK) 
   WHERE IsDone = 1 AND IsTransferred = 0 AND IsSkipped = 0 
   ORDER BY ModifyDateTime ASC;
   ```
2. Nếu số lượng nghẽn tăng dần:
   - Báo bộ phận Server Admin restart lại Application Pool của Web POP trên IIS.
   - Hoặc nếu chỉ kẹt riêng 1 Line (như `VVC-11`), kiểm tra xem Line đó có bị exclude trong cấu hình Worker hay không.

---

### 2.19 POP-ERR-19: Lỗi "Không Tìm Thấy LOT Trong Kho / Không Còn Tồn Kho" Khi Nạp Cuộn Điện Cực (Winding)

**Hiện tượng:**
- Tại chuyền Quấn (Winding / Thu công xưởng 1), công nhân mở nạp NVL BOM trên Kiosk POP cho Lot (ví dụ: `VVQR203R072749`, Model 35105 / `ECVT30-357`).
- Dòng cuộn điện cực hiển thị **`SL Kho: 0`** hoặc chữ đỏ **`Hết hàng`** (ví dụ: `SREY085 - ELECTRODE ROLL YP85-200`, `SRFC085 - ELECTRODE ROLL CY85-200F`).
- Khi quét tem barcode cuộn điện cực thực tế (ví dụ: `VWQO2220001E13-003 CY`, `VWQO2620001E04-015 CY`) hoặc bấm nút Tồn kho, Kiosk POP bật popup cảnh báo:
  > *"Không tìm thấy LOT trong kho"*  
  > *"Không tìm thấy LOT vật liệu hoặc không còn tồn kho."*
- Bộ phận xưởng Điện cực khẳng định: *"Đã xuất trên hệ thống ra SX rồi"*.

**Nguyên nhân gốc (Root Cause):**
1. **Xưởng Điện cực đã xuất kho thành công:** Kiểm tra trong `SmartFactoryV2.dbo.STB_MaterialLotInfo`, các cuộn điện cực `VWQO...` đã nằm trong kho công đoạn **`ROUTE_VN_WH`** với đầy đủ số lượng (251m, 290m).
2. **Lệch mã BOM giữa Lệnh SX (PO) và Bán thành phẩm (BTP) xuất kho:**
   - Xưởng Điện cực chia cuộn Slitting và in tem theo mã BTP mới: **`SRECYK0-900`** (*Slitting-Roll Etching-CY 203 900*).
   - Trong khi đó, Lệnh sản xuất (PO `260829000045`) được duyệt theo Master BOM cũ chứa mã: **`SRFCO85`** (cực âm CY) và **`SREYO85`** (cực dương YP).
   - Hai mã cũ `SRFCO85 / SREYO85` trong kho `ROUTE_VN_WH` có tồn kho = 0.
   - Khi công nhân quét cuộn mã `SRECYK0-900`: Kiosk POP đối soát thấy mã này **KHÔNG CÓ trong bảng `STB_ProductionOrderBom`** của PO hiện hành, đồng thời các mã trong BOM thì hết tồn kho ➔ Chặn không cho nạp và báo lỗi.

**Quy trình chuẩn đoán & Khắc phục nhanh (SOP 3 Bước):**
1. **Truy vết đối soát Live DB (SELECT-Only):**
   ```sql
   -- 1. Kiểm tra BOM của Lệnh sản xuất đang chạy:
   SELECT ChildMaterialCode, UsedQty, RouteCode 
   FROM SmartFactoryV2.dbo.STB_ProductionOrderBom WITH(NOLOCK) 
   WHERE PONo = '<MÃ_PO_CỦA_LOT>';

   -- 2. Kiểm tra mã NVL, kho và tồn kho của cuộn điện cực thực tế:
   SELECT LotID, MaterialCode, MaterialWarehouseCode, CurrentQty 
   FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) 
   WHERE LotID IN ('<MÃ_BARCODE_CUỘN_1>', '<MÃ_BARCODE_CUỘN_2>');
   ```
2. **Cứu chuyền khẩn cấp (Hotfix):**
   - *Cách A (Chuẩn BOM):* Bổ sung mã `SRECYK0-900` vào `STB_ProductionOrderBom` cho PO đó qua WinForm **B310** (hoặc SQL Hotfix).
   - *Cách B (Chuẩn hóa mã kho theo cuộn):* Cập nhật `MaterialCode = 'SRFCO85'` cho các cuộn đó trong `STB_MaterialLotInfo` tại `ROUTE_VN_WH` nếu thực chất cùng quy cách kỹ thuật.
   - *Thao tác Kiosk:* Yêu cầu công nhân bấm nút **`Danh sách NVL BOM 🔄` (Reload)** trên màn hình Kiosk POP ➔ Cột Tồn kho sẽ hiển thị xanh và quét cuộn nạp bình thường.
3. **Chuẩn hóa Master Data:**
   - Báo bộ phận Kế hoạch / BOM Master (Anh Huy) cập nhật mã điện cực chuẩn vào Model tại màn hình **A310** để các PO sau tự động thừa kế.

---

### 2.20 POP-ERR-20: POP Kiosk Thiếu Thiết Bị / Ẩn Máy Tại Modal "Xác Nhận Kết Thúc" (Winding/Curling/Sleeving)

**Triệu chứng:**
Khi công nhân bấm nút **"GHI NHẬN SẢN XUẤT"** để mở modal popup *"Xác nhận Kết thúc?"*, danh sách thiết bị hiển thị thiếu máy (ví dụ: chỉ hiện 16 máy Cuộn từ C#3 đến C#10, thiếu hoàn toàn 4 máy đầu chuyền: `Winding C#1 -1`, `Winding C#1 -2`, `Winding C#2 -1`, `Winding C#2 -2`, cùng các máy Curling/Sleeving C#1, C#2). Dù trong `SmartFactoryV2.dbo.STB_ProductMachine` các máy đều đã được khai báo cho Model và Line.

**Nguyên nhân gốc rễ (Root Cause):**
1. **Cơ chế lọc xung đột độc quyền của POP Kiosk:**
   - Khi render danh sách máy trên modal, Backend POP Kiosk truy vấn từ `STB_ProductMachine` + `STB_MachineMaster`, đồng thời áp dụng điều kiện loại trừ các máy đang bị chiếm dụng:
     ```sql
     WHERE NOT EXISTS (
         SELECT 1 FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING M
         WHERE M.EQUIPMENT_ID = E.EQUIPMENT_ID
           AND M.MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED')
           AND M.DAY_PLAN_NO <> @CurrentDayPlanNo
     )
     ```
2. **Kẹt khóa mồ côi (Orphan Lock):**
   - Các máy bị thiếu đã từng được gán vào Kế hoạch sản xuất cũ (`DAY_PLAN_NO` của các ngày trước) nhưng khi kết thúc kế hoạch không được giải phóng (`MAPPING_STATUS` vẫn giữ nguyên là `'ACTIVE'`).
   - Kiosk POP hiện tại chưa có cron job Auto-Release khi hết ca hoặc sang ngày mới, khiến trạng thái `ACTIVE` cũ tồn lưu vĩnh viễn và chặn không cho Lệnh sản xuất mới nhìn thấy máy.

**Quy trình chuẩn đoán & Khắc phục chuẩn (3 Bước):**
1. **Kiểm tra các máy đang bị kẹt lock:**
   ```sql
   SELECT MAPPING_ID, DAY_PLAN_NO, LINE_CODE, ROUTE_CODE, EQUIPMENT_ID, EQUIPMENT_NAME, MAPPING_STATUS, MAPPED_AT
   FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING WITH(NOLOCK)
   WHERE EQUIPMENT_ID IN ('MÃ_MÁY_BỊ_ẨN_1', 'MÃ_MÁY_BỊ_ẨN_2')
     AND MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED');
   ```
2. **Xuất Backup Snapshot trước khi can thiệp (Pre-flight Backup):**
   - Dùng script PowerShell xuất JSON các dòng sẽ tác động và lưu vào `tools/backups/`.
3. **Thực thi Hotfix giải phóng thiết bị (Lưu ý: `RELEASE_REASON` tối đa 50 ký tự):**
   ```sql
   USE VINATECH_POP;
   BEGIN TRANSACTION;
   
      UPDATE VINA_EQUIPMENT_MAPPING
    SET MAPPING_STATUS      = 'RELEASED',
        RELEASED_AT         = GETDATE(),
        RELEASE_REASON      = N'Release cho Model 35105',
        NO_EMP_MODIFYER     = 'vanduc',
        CD_COMPANY_MODIFYER = 'VINA'
    WHERE MAPPING_ID IN (DANH_SÁCH_MAPPING_ID)
      AND MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED');
   
   -- Kiểm tra đúng số dòng trước khi COMMIT
   IF @@ROWCOUNT = SO_DONG_DU_KIEN
       COMMIT TRANSACTION;
   ELSE
       ROLLBACK TRANSACTION;
   ```
4. **Kiểm tra sau Hotfix:**
   - OP đóng modal và bấm lại nút "GHI NHẬN SẢN XUẤT" (hoặc F5 Kiosk). Toàn bộ danh mục máy sẽ xuất hiện đầy đủ 100%.

---

### 2.21 📊 Bảng Phân Tích & Giải Mã Top 10 Thông Báo Lỗi Runtime Thực Tế (Production Telemetry)

Dựa trên kiểm toán thực tế hơn 231,000 bản ghi thao tác trong `VINATECH_POP.dbo.VINA_POP_ACTION_LOG`, dưới đây là danh sách thông báo lỗi xuất hiện thường xuyên nhất tại các xưởng sản xuất kèm nguyên nhân kỹ thuật và cách xử lý:

| # | Thông báo lỗi trên màn hình Kiosk POP | `ACTION_TYPE` | Số lần ghi nhận | Nguyên nhân kỹ thuật & Cách xử lý |
|---|---------------------------------------|---------------|----------------:|-----------------------------------|
| 1 | **"This route is already completed in MES."** | `MANUAL_COMPLETE` | 498 | **Trùng lặp công đoạn**: Công đoạn đã được chốt hoàn thành trên MES WinForm hoặc lượt trước, WinForm chặn ghi đè từ Kiosk. <br>➔ **Xử lý:** Dùng Golden Query `.\mes.ps1 trace '<Lot>'` kiểm tra `STB_ProdRouteHist`. Xóa lượt kẹt cũ qua Template 3 hoặc chuyển Lot sang công đoạn kế tiếp. |
| 2 | **"Already transferred to MES. Cannot modify."** | `MANUAL_DEFECT` | 162 | **Đã đồng bộ sang MES, khóa sửa**: Bản ghi sản lượng/phế của công đoạn đã được Worker đồng bộ sang `STB_ProdRouteHist` (`IsTransferred = 1`). Kiosk POP khóa cứng không cho OP tự sửa. <br>➔ **Xử lý:** Kỹ sư MES can thiệp sửa trực tiếp trên WinForm (B530/B540) hoặc dùng Template 7 để rollback. |
| 3 | **"실적이 없는 공정입니다. 실적 등록 후 추가하세요."**<br>*(Công đoạn chưa có sản lượng. Hãy đăng ký sản lượng trước)* | `WORKER_HIST_ADD` | 120 | **Thao tác ngược trình tự**: OP bấm thêm/chỉnh sửa công nhân thao tác hoặc phế phẩm khi công đoạn đó chưa hề được bấm "Ghi nhận sản lượng". <br>➔ **Xử lý:** Nhập số lượng sản xuất tốt (`Good Qty`) trước, sau đó hệ thống mới cho phép ghi nhận phế/công nhân. |
| 4 | **"This roll has already been used for 2 product LOTs. Input blocked."**<br>*(Cuộn này đã được dùng cho 2 LOT sản phẩm. Bị chặn nạp)* | `AUTO_MATERIAL_INPUT` | 100 | **Ràng buộc an toàn vật tư (Business Integrity Rule)**: 1 cuộn điện cực BTP chỉ được phép cắt/nạp tối đa cho 2 LOT sản phẩm nhằm kiểm soát phế và chống âm kho. Quét vào LOT thứ 3 bị chặn. <br>➔ **Xử lý:** Đổi sang cuộn điện cực mới còn tồn kho hợp lệ và chưa vượt quá 2 LOT. |
| 5 | **"코팅 생산수량 등록 후 불량등록이 가능합니다."**<br>*(Chỉ đăng ký phế sau khi đã nhập sản lượng Coating)* | `AUTO_ELECTRODE_WASTE` | 73 | **Ràng buộc Xưởng Điện Cực**: Bắt buộc phải có sản lượng màng Coating hợp lệ (`Coating ProdQty > 0`) thì mới được phép khai báo phế phẩm cuộn. |
| 6 | **"작업자를 먼저 지정해 주세요. (검사자 미기록 저장 불가)"**<br>*(Vui lòng chỉ định công nhân trước khi lưu)* | `AUTO_INSPECTION_ADDPROCESS` | 60 | **Thiếu mã người kiểm tra**: Khi lưu kết quả đo tự kiểm PQC In-Line, ô công nhân (`WorkerID`) bị để trống. Kiosk chặn lưu để tránh dữ liệu mồ côi không quy được trách nhiệm. <br>➔ **Xử lý:** Quét mã QR thẻ nhân viên trước khi bấm lưu. |
| 7 | **"Same material input is already in progress. Please wait."** | `AUTO_MATERIAL_INPUT` | 44 | **Xung đột bấm đúp (Double click)**: Công nhân bấm quét barcode NVL liên tiếp 2 lần nhanh hơn thời gian API xử lý xong giao dịch trừ kho. <br>➔ **Xử lý:** Đợi 2-3 giây để popup hoàn tất, không bấm liên thanh. |
| 8 | **"믹싱 공정이 완료되지 않았습니다. 전 자재 투입 완료 후 코팅 실적 등록이 가능합니다. (미투입 자재 ...건)"**<br>*(Mixing chưa hoàn thành. Cần nạp đủ NVL trước khi chốt Coating)* | `MANUAL_PROD` | 40 | **Khóa liên động (Interlock) công đoạn**: Công đoạn Trộn keo/Dung môi (Mixing) chưa quét nạp đủ danh mục NVL định mức BOM. Kiosk khóa không cho chuyển sang công đoạn Tráng phủ (Coating). <br>➔ **Xử lý:** Kiểm tra tab Nạp NVL của mẻ Mixing, quét nạp nốt các vật tư còn thiếu. |
| 9 | **"equipment.mapping.preempted"** | `AUTO_MAPPING_ADD` | 35 | **Xung đột chiếm dụng máy**: Máy móc đã được một Kiosk khác hoặc ca làm việc trước đó gán ở trạng thái `ACTIVE` (sự cố [POP-ERR-20](#220-pop-kiosk-thiếu-thiết-bị--ẩn-máy-tại-modal-xác-nhận-kết-thúc-windingcurlingsleeving)). <br>➔ **Xử lý:** Chạy `.\mes.ps1 release-machines -Target <Line> -Force` hoặc dùng Template 10 giải phóng máy. |
| 10 | **"코팅 공정이 완료되지 않았습니다. 코팅 양품수량 등록 후 롤프레싱 실적 등록이 가능합니다."**<br>*(Coating chưa chốt. Cần nhập sản lượng OK trước khi cán Roll Press)* | `MANUAL_PROD` | 29 | **Tuần tự công đoạn Điện Cực**: Cấm nhảy cóc từ Coating sang Roll Pressing khi chưa có sản lượng đạt (Yield OK). |
| 11 | **"Material input is required before packing."** | `AUTO_PACKING_EXECUTE_MULTI` | 24 | **Thiếu nạp NVL đóng gói**: Thùng hoặc Lot chưa hoàn tất bước nạp vỏ/nhãn/hạt hút ẩm theo quy cách đóng gói. <br>➔ **Xử lý:** Thực hiện nạp NVL đóng gói trước khi chốt chia Box / Merge Pack. |
| 12 | **"이미 완료된 검사 문서입니다. 추가 측정이 불가합니다."**<br>*(Phiếu đo đã hoàn thành. Không thể đo thêm)* | `AUTO_INSPECTION_ADDPROCESS` | 25 | **Phiếu kiểm tra đã chốt đóng**: Tài liệu đo PQC đã bấm Hoàn thành (`IsFinished = 1`) (sự cố [POP-ERR-12](#28-pop-err-11--12-sự-cố-phân-hệ-chất-lượng-quality-popqualityself)). <br>➔ **Xử lý:** Bấm "Hoàn tác" để gửi yêu cầu mở lại hoặc dùng Template 5. |
| 13 | **"호일 부족: 코팅 생산수량 > 투입 호일 가용 길이"**<br>*(Thiếu lá kim loại Foil)* | `MANUAL_PROD` | 15 | **Cân bằng tiêu hao vật tư**: Tổng mét màng Coating đăng ký vượt quá chiều dài lá kim loại Foil đã nạp. <br>➔ **Xử lý:** Quét nạp cuộn Foil bổ sung vào ô Slot NVL để bù đắp chiều dài thiếu hụt. |
| 14 | **"폐기할 잔여 폭이 없습니다. (잔여 폭 0)"** | `AUTO_ELECTRODE_WASTE` | 12 | **Thanh lý rìa mép cuộn**: Hệ thống ghi nhận cuộn đã thanh lý hết phần rìa mép hoặc chưa khai báo chiều rộng màng cuộn. <br>➔ **Xử lý:** Kiểm tra lại lịch sử phế phẩm của cuộn. Nếu đã thanh lý trước đó thì không thao tác lại. |
| 15 | **"Electrode roll cannot be input from another work center's warehouse."** | `AUTO_MATERIAL_INPUT` | 8 | **Sai vị trí kho phân xưởng**: Cuộn BTP điện cực đang nằm ở vị trí kho của Phân xưởng khác (chưa chuyển kho sang Line hiện tại). <br>➔ **Xử lý:** Yêu cầu thủ kho làm phiếu chuyển kho (Warehouse Transfer) trên hệ thống sang đúng Chuyền. |


---

### 2.22 POP-ERR-22: Lỗi "Already transferred to MES. Cannot modify"
* **Hiện tượng:** Công nhân trên Kiosk bấm nút "Sửa" hoặc "Xóa" lượt chốt sản lượng/phế phẩm nhưng màn hình hiện popup đỏ: `"Already transferred to MES. Cannot modify."`
* **Nguyên nhân cốt lõi:** Bản ghi sản lượng hoặc phế đã được Background Worker của POP đồng bộ thành công sang bảng đệm `SmartFactoryV2.dbo.MongoToMesPerformance` và đẩy vào `SmartFactoryV2.dbo.STB_ProdRouteHist` (`IsTransferred = 1`). Cơ chế bảo vệ dữ liệu của Kiosk tự động khóa cứng để chống sai lệch giữa Web và CSDL MES WinForm.
* **Cách OP xử lý:** Không cố bấm sửa trên Kiosk. Thông báo cho Quản lý ca / Kỹ sư IT.
* **Thao tác IT:** Nếu cần điều chỉnh sản lượng hoặc xóa lượt chốt sai:
  1. Dùng Golden Query: `.\mes.ps1 trace '<Mã_Lot>'` để xác định bản ghi kẹt.
  2. Rollback trên WinForm bằng `.\mes.ps1 fix-rollback -Lots '<Mã_Lot>' -Route '<Mã_Công_Đoạn>'` hoặc dùng Hotfix Template 3.

---

### 2.23 POP-ERR-23: Lỗi "실적이 없는 공정입니다. 실적 등록 후 추가하세요"
* **Hiện tượng:** Công nhân mở modal "Phế phẩm" hoặc bấm nút "Kết thúc công đoạn" thì hệ thống báo lỗi tiếng Hàn: `"실적이 없는 공정입니다. 실적 등록 후 추가하세요."` *(Công đoạn chưa có sản lượng. Vui lòng đăng ký sản lượng trước)*.
* **Nguyên nhân cốt lõi:** Thao tác ngược trình tự logic. Công đoạn hiện tại chưa có bản ghi sản lượng tốt (`GoodQty > 0`), nhưng công nhân đã bấm lưu phế hoặc bấm hoàn tất.
* **Cách OP xử lý:**
  1. Nhập số lượng sản xuất đạt (`양품수량` / Good Qty) vào ô chính của màn hình.
  2. Sau khi số lượng tốt hiển thị hợp lệ, mới mở lại modal để nhập số lượng phế phẩm (`불량수량`).
  3. Bấm "Xác nhận kết thúc" để hoàn tất công đoạn.

---

### 2.24 POP-ERR-24: Lỗi Chặn Nạp Cuộn "This roll has already been used for 2 product LOTs. Input blocked"
* **Hiện tượng:** Công nhân tại trạm Cuốn lõi (Winding) hoặc Xẻ cuộn (Slitting) quét mã barcode cuộn điện cực BTP vào ô nạp NVL, Kiosk báo lỗi: `"This roll has already been used for 2 product LOTs. Input blocked."`
* **Nguyên nhân cốt lõi:** Ràng buộc an toàn toàn vẹn định mức (Business Integrity Rule). Trên hệ thống MES Vinatech, 1 cuộn điện cực BTP chỉ được phép cắt xẻ và phân bổ tối đa cho **2 LOT thành phẩm**. Nếu quét sang LOT thứ 3, trigger chặn lại nhằm ngăn chặn gian lận phế, âm kho và lẫn lộn truy vết Lot.
* **Cách OP xử lý:**
  1. Kiểm tra tem cuộn điện cực: Cuộn này đã được sử dụng hết định mức cho 2 LOT trước đó.
  2. Lấy cuộn điện cực mới từ giá chờ nạp, quét kiểm tra mã vạch mới.
  3. Tuyệt đối không cố quét ép cuộn đã hết định mức.
* **Thao tác IT:** Nếu thực tế cuộn vẫn còn dư màng do dung sai và phân xưởng yêu cầu tận dụng: IT kiểm tra bảng `SmartFactoryV2.dbo.STB_MaterialLotInfo` để xác minh số lượng tồn thực tế trước khi hỗ trợ thủ tục tách Lot BTP mới.

---

### 2.25 POP-ERR-25: Lỗi Trình Tự Coating "코팅 생산수량 등록 후 불량등록이 가능합니다"
* **Hiện tượng:** Tại màn hình Tráng phủ (Coating), khi công nhân bấm nhập phế phẩm cuộn thì popup báo: `"코팅 생산수량 등록 후 불량등록이 가능합니다."` *(Chỉ đăng ký phế sau khi đã nhập sản lượng Coating)*.
* **Nguyên nhân cốt lõi:** Logic tính toán tỷ lệ thu hồi màng (Yield Rate): Hệ thống yêu cầu phải có tổng chiều dài màng tráng phủ đạt tiêu chuẩn (`Coating ProdQty > 0`) làm cơ sở đối chiếu trước khi ghi nhận chiều dài phế đầu/cuối cuộn.
* **Cách OP xử lý:**
  1. Nhập chiều dài mét màng tráng phủ đạt vào ô sản lượng tốt trước.
  2. Sau đó mở khung phế phẩm để khai báo chiều dài phế mép, phế bọt keo, phế khởi động.

---

### 2.26 POP-ERR-26: Lỗi Thiếu Người Kiểm Tra "작업자를 먼저 지정해 주세요"
* **Hiện tượng:** Khi lưu biên bản tự kiểm tra chất lượng PQC In-Line (`/pop/quality/self`), màn hình hiện lỗi: `"작업자를 먼저 지정해 주세요. (검사자 미기록 저장 불가)"`.
* **Nguyên nhân cốt lõi:** Trường mã nhân viên kiểm tra (`WORKER_ID` / `INSPECTOR_ID`) bị để trống. Hệ thống chặn lưu các biên bản kiểm tra không có định danh người thực hiện để đảm bảo quy chuẩn ISO / IATF 16949.
* **Cách OP xử lý:**
  1. Chạm vào ô `검사자` (Người kiểm tra) trên đầu màn hình Kiosk.
  2. Dùng súng barcode quét mã QR trên thẻ nhân viên hoặc chọn tên từ danh sách tổ ca.
  3. Bấm nút Lưu biên bản kiểm tra.

---

### 2.27 POP-ERR-27: Lỗi Khóa Liên Động Mixing ➔ Coating "믹싱 공정이 완료되지 않았습니다"
* **Hiện tượng:** Tại Kiosk Tráng phủ Coating, khi chọn mẻ để sản xuất thì hệ thống báo: `"믹싱 공정이 완료되지 않았습니다. 전 자재 투입 완료 후 코팅 실적 등록이 가능합니다. (미투입 자재 ...건)"`.
* **Nguyên nhân cốt lõi:** Khóa liên động (Interlock) giữa công đoạn Trộn keo (Mixing) và Tráng phủ (Coating). Mẻ trộn Mixing chưa hoàn thành nạp đủ 100% các mã nguyên vật liệu theo định mức recipe BOM (còn tồn đọng NVL chưa quét xác nhận).
* **Cách OP xử lý:**
  1. Quay lại Kiosk trạm Mixing hoặc thông báo cho thợ pha trộn.
  2. Mở tab "Nạp NVL" của mẻ trộn tương ứng.
  3. Quét nạp nốt các mã hóa chất/dung môi/bột than còn thiếu theo danh sách cảnh báo rồi bấm "Hoàn tất mẻ trộn".
  4. Sau khi Mixing hoàn tất, Kiosk Coating sẽ tự động mở khóa.

---

### 2.28 POP-ERR-28: Lỗi Thiếu Foil "호일 부족: 코팅 생산수량 > 투입 호일 가용 길이"
* **Hiện tượng:** Khi chốt sản lượng Coating, Kiosk báo lỗi: `"호일 부족: 코팅 생산수량 > 투입 호일 가용 길이"`.
* **Nguyên nhân cốt lõi:** Cân bằng định mức vật tư tiêu hao. Chiều dài sản phẩm Coating đăng ký vượt quá tổng chiều dài của các cuộn lá kim loại Foil (Al/Cu) đã được quét nạp vào máy.
* **Cách OP xử lý:**
  1. Kiểm tra cuộn Foil kim loại thực tế đang lắp trên máy.
  2. Quét mã vạch nạp thêm cuộn Foil kim loại bổ sung vào Slot NVL trên Kiosk.
  3. Sau khi chiều dài khả dụng của Foil lớn hơn hoặc bằng chiều dài sản phẩm, bấm Lưu sản lượng.

---

### 2.29 POP-ERR-29: Lỗi Chặn Đóng Gói "Material input is required before packing"
* **Hiện tượng:** Khi bấm "Đóng gói / Merge Pack" tại trạm Packing, Kiosk hiện lỗi: `"Material input is required before packing."`
* **Nguyên nhân cốt lõi:** Quy chuẩn đóng gói thành phẩm bắt buộc phải quét nạp vật tư tiêu hao (thùng carton, túi hút ẩm, khay xốp, tem nhãn) vào danh mục vật tư công đoạn Đóng gói trước khi hệ thống cho phép sinh mã Box và in tem.
* **Cách OP xử lý:**
  1. Chuyển sang tab "Nạp NVL đóng gói" trên màn hình Kiosk.
  2. Quét mã vạch thùng carton và các vật tư theo định mức của Lệnh SX.
  3. Quay lại tab Đóng gói và thực hiện hoàn tất chia box / in tem.

---

### 2.30 POP-ERR-30: Lỗi Sai Vùng Kho "Electrode roll cannot be input from another work center's warehouse"
* **Hiện tượng:** Quét nạp cuộn BTP điện cực vào máy thì Kiosk báo lỗi: `"Electrode roll cannot be input from another work center's warehouse."`
* **Nguyên nhân cốt lõi:** Cuộn BTP điện cực trên CSDL vẫn đang ghi nhận vị trí tại kho của Phân xưởng khác (ví dụ: kho Hà Nam `ROUTE_VN_WH` nhưng Line đang sản xuất tại Hưng Yên `ROUTE_HY_WH`, hoặc khác Line).
* **Cách OP xử lý:**
  1. Kiểm tra tem cuộn và vị trí thực tế của cuộn BTP.
  2. Báo thủ kho thực hiện thao tác Chuyển kho (Warehouse Transfer) trên hệ thống MES WinForm (màn hình F430) về đúng mã kho của Phân xưởng/Line hiện tại.
  3. Sau khi chuyển kho thành công, quét lại mã vạch cuộn trên Kiosk POP.

---

## 3. 🛠️ TEMPLATE SQL CỨU HỘ VẬN HÀNH (SAFETY HOTFIX TEMPLATES)

> [!CAUTION]
> Tuân thủ tuyệt đối **RULE 1 (SELECT-Only)**. Chỉ chạy lệnh ghi khi có sự đồng ý bằng văn bản của Quản lý MES.
> Luôn sử dụng cú pháp an toàn `BEGIN TRAN ... ROLLBACK` để kiểm tra số dòng ảnh hưởng trước khi Commit!

### Template 1: Hoàn Trả Kho Khi Quét Nhầm NVL Trên POP
```sql
BEGIN TRAN;

DECLARE @LotNo NVARCHAR(50) = N'VNCELL260908001';
DECLARE @MatLotNo NVARCHAR(50) = N'RAW-MAT-2026-09-0012';
DECLARE @RefundQty DECIMAL(18,4) = 50.0;

-- 1. Hoàn trả số lượng tồn kho NVL
UPDATE SmartFactoryV2.dbo.STB_MaterialLotInfo
SET Qty = Qty + @RefundQty,
    ModifyDate = GETDATE()
WHERE MaterialLotNo = @MatLotNo;

-- 2. Ghi chú điều chỉnh vào nhật ký POP
INSERT INTO VINATECH_POP.dbo.VINA_MATERIAL_INPUT_HIST (
    LOT_NO, MATERIAL_LOT_NO, INPUT_QTY, INPUT_DATE_TIME, WORKER_ID, STATUS
) VALUES (
    @LotNo, @MatLotNo, -@RefundQty, GETDATE(), N'ADMIN_FIX', N'CANCEL'
);

-- Kiểm tra kết quả
SELECT MaterialLotNo, Qty FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) WHERE MaterialLotNo = @MatLotNo;

-- Nếu đúng số lượng mong muốn: Thay ROLLBACK bằng COMMIT
ROLLBACK;
```

---

### Template 2: Giải Tỏa Lot Bị Treo Trạng Thái Khóa (HOLD Release)
```sql
BEGIN TRAN;

DECLARE @TargetLot NVARCHAR(50) = N'VNCELL260908002';

UPDATE SmartFactoryV2.dbo.STB_SetInfo
SET IsHold = 0,
    HoldReason = NULL,
    ModifyDate = GETDATE()
WHERE LotNo = @TargetLot AND IsHold = 1;

-- Xác minh
SELECT LotNo, IsHold, CurrentRouteCode FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE LotNo = @TargetLot;

ROLLBACK; -- Thay bằng COMMIT sau khi verify
```

---

### Template 3: Giải Phóng Lượt Chốt Công Đoạn Kẹt (This route is already completed in MES)
```sql
-- Áp dụng khi POP chặn chốt công đoạn do có bản ghi cũ trong MES
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @TargetHistNo VARCHAR(20) = '20260830000798';
    DECLARE @TargetControlNo VARCHAR(20) = '20260807000462';
    DECLARE @TargetRoute VARCHAR(20) = 'V-26_HY';

    -- 1. Snapshot backup an toàn
    -- SELECT * INTO BAK_STB_ProdRouteHist_<Date> FROM STB_ProdRouteHist WHERE ProdRouteHistNo = @TargetHistNo;
    -- SELECT * INTO BAK_STB_ProdRouteWorkerHist_<Date> FROM STB_ProdRouteWorkerHist WHERE ProdRouteHistNo = @TargetHistNo;

    -- 2. Xóa bản ghi worker mapping
    DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteWorkerHist WHERE ProdRouteHistNo = @TargetHistNo;

    -- 3. Xóa bản ghi routing kẹt
    DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteHist 
    WHERE ProdRouteHistNo = @TargetHistNo AND ControlNo = @TargetControlNo AND RouteCode = @TargetRoute;

    IF @@ROWCOUNT = 1
        COMMIT TRANSACTION;
    ELSE
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Số dòng ảnh hưởng khác 1, đã rollback!', 16, 1);
    END
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

---

### Template 4: Rollback Lượt Chốt Sớm / Hủy Đóng Gói V-28_HY

#### Case 1: Chốt đơn lẻ (Incident 17/09/2026 - Lot VVQR013R072727)
```sql
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @MatLotNo VARCHAR(50) = '20260917000404';
    DECLARE @LotNo VARCHAR(50) = 'VVQR013R072727';
    DECLARE @HistNo VARCHAR(20) = '20260917000709';
    DECLARE @ControlNo VARCHAR(20) = '20260901000137';

    -- 1. Xóa bán thành phẩm sinh sớm
    DELETE FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WHERE MaterialLotNo = @MatLotNo AND LotNo = @LotNo;

    -- 2. Xóa lượt chốt công đoạn V-28_HY
    DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteHist WHERE ProdRouteHistNo = @HistNo AND ControlNo = @ControlNo AND RouteCode = 'V-28_HY';

    -- 3. Xóa tồn dư tạm trong POP
    DELETE FROM VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY WHERE BARCODE = @LotNo AND ROUTE_CODE = 'V-28_HY';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

#### Case 2: Đóng gói chia nhiều Box & Box gộp Merge Pack (Incident 19/09/2026 - Lot VVQR113R060640)
> **Ngữ cảnh:** Lot `VVQR113R060640` (985 EA) đóng vào 2 Box: Box lẻ 500 EA (`PKQR1800400`) và Box gộp 1,477 EA (`PKQR1800401`). Đã chốt `V-28_HY` lúc 17:45:51 ngày 18/09/2026. Cần rollback đồng bộ để xưởng đóng gói lại hoặc hủy Box sai.

```sql
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @LotNo VARCHAR(50) = 'VVQR113R060640';
    DECLARE @ControlNo VARCHAR(20) = '20260911000618';
    DECLARE @HistNo VARCHAR(20) = '20260918001335';

    -- 1. Thu hồi các bản ghi Box đã sinh trong STB_MaterialLotInfo
    DELETE FROM SmartFactoryV2.dbo.STB_MaterialLotInfo 
    WHERE LotNo = @LotNo 
      AND MaterialLotNo IN ('20260918001377', '20260918001378', '20260918001379');

    -- 2. Xóa lượt chốt công đoạn đóng gói V-28_HY
    DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteHist 
    WHERE ProdRouteHistNo = @HistNo 
      AND ControlNo = @ControlNo 
      AND RouteCode = 'V-28_HY';

    -- 3. Phục hồi trạng thái tồn dư trên POP Kiosk (trả lại 985 EA cho công nhân đóng gói lại)
    UPDATE VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY
    SET PACKED_QTY = 0,
        REMAIN_QTY = TOTAL_PROD_QTY
    WHERE BARCODE = @LotNo 
      AND ROUTE_CODE = 'V-28_HY';

    -- 4. Trả trạng thái IsProdFinish về False trong STB_SetInfo
    UPDATE SmartFactoryV2.dbo.STB_SetInfo
    SET IsProdFinish = 0,
        ModifyDateTime = GETDATE()
    WHERE ControlNo = @ControlNo;

    COMMIT TRANSACTION;
    PRINT N'>> Rollback hoan tat dong goi thanh cong cho Lot ' + @LotNo;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

#### Case 3: Chạy Stored Procedure Chuẩn Của Hệ Thống (Khuyên dùng nhất - Auto-sync 6 bảng)
> **Ngữ cảnh:** Thay vì viết các câu lệnh `DELETE`/`UPDATE` thủ công nhiều bảng có nguy cơ sót dữ liệu, kỹ sư MES / DBA có thể gọi trực tiếp Stored Procedure chính thức được POP Web và WinForm [B520] sử dụng:

```sql
USE SmartFactoryV2;
GO

-- Chạy hủy đóng gói tự động đồng bộ (Ghi audit, xóa BTP, xóa V-28, trừ PO, hủy chứng từ kho, mở SetInfo)
EXEC dbo.usp_DoCancelProdPacking_LotNo
     @pProcessUserID   = '92603003',       -- Mã tài khoản quản trị duyệt hủy
     @pProcessLanguage = 'VIETNAMESE',    -- 'VIETNAMESE' hoặc 'KOREAN'
     @pRouteCode       = 'V-28',           -- V-28 (Bắc Ninh), V-28_HY (Hưng Yên), VE10 (Hà Nam)
     @pBarcode         = 'VVQQ253R072701'; -- Mã Lot cần hủy
GO
```

---

### Template 5: Mở Lại Phiếu Đo Kiểm PQC Đã Đóng (Reopen Inspection)
```sql
-- Reset trạng thái phiếu đo kiểm đã đóng để mở lại ô nhập liệu trên Kiosk
UPDATE SmartFactoryV2.dbo.STB_CommInspDocHistory
SET IsFinished = 0,
    ChangeDateTime = GETDATE(),
    ChangeUserID = N'ADMIN_REOPEN'
WHERE CommInspDocNo = N'<COMM_INSP_DOC_NO>';
```

---

### Template 6: Phục Hồi Tồn Kho Thùng Dung Dịch Bị Về 0 KG (POP-ERR-14)

> **Ngữ cảnh:** Thùng dung dịch (Electrolyte) 150 KG bị xung đột chuyển vùng kho VN ➔ HY, hoặc bị cơ chế auto-exhaust khi quét Lot mới, dẫn đến `CurrentQty = 0` trên cả 2 bản ghi (ROUTE_VN_WH + ROUTE_HY_WH). Cần phục hồi **100% InitialQty** (thùng 150 KG thực tế chạy 2 ngày mới hết).
> 
> **Incident thực tế (19/9/2026):** Lot `ML20260331000035` (GBEC00-008) và `ML20260625000450` (GBCP00-004) bị về 0 KG chỉ sau 1 lần quét. Chuyền HY Cell Line #13 báo "Hết hàng" trên Kiosk POP.

```sql
BEGIN TRAN;
BEGIN TRY

    -- ===== BƯỚC 1: Xác minh trạng thái hiện tại =====
    SELECT LotID, MaterialCode, MaterialWarehouseCode, InitialQty, CurrentQty, 
           CreateDateTime, ChangeDateTime, ChangeUserID
    FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
    WHERE LotID = '<LOT_ID>'  -- VD: 'ML20260331000035'
    ORDER BY CreateDateTime;

    -- ===== BƯỚC 2: Phục hồi hoàn toàn số lượng tại ROUTE_HY_WH =====
    -- Phục hồi 100% InitialQty (150 KG) — KHÔNG phục hồi số lẻ
    DECLARE @LotID NVARCHAR(50) = N'<LOT_ID>';
    DECLARE @RestoreQty DECIMAL(18,10) = 150.0000000000;  -- = InitialQty gốc

    UPDATE SmartFactoryV2.dbo.STB_MaterialLotInfo
    SET CurrentQty = @RestoreQty,
        ChangeDateTime = GETDATE(),
        ChangeUserID = N'IT_RESTORE_ELECTROLYTE'
    WHERE LotID = @LotID
      AND MaterialWarehouseCode = 'ROUTE_HY_WH';

    -- ===== BƯỚC 3: Kiểm tra kết quả =====
    SELECT LotID, MaterialWarehouseCode, InitialQty, CurrentQty
    FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
    WHERE LotID = @LotID;

    -- ⚠️ Xác nhận CurrentQty = 150 KG tại ROUTE_HY_WH rồi mới COMMIT
    -- Nếu đúng: Thay ROLLBACK bằng COMMIT
    ROLLBACK;

END TRY
BEGIN CATCH
    ROLLBACK;
    THROW;
END CATCH;
```

> [!IMPORTANT]
> **Sau khi COMMIT:** Yêu cầu công nhân trên Kiosk POP bấm nút **`Danh sách NVL BOM 🔄` (Reload)**. Cột Tồn kho sẽ chuyển từ **Hết hàng (Đỏ)** sang **150 KG (Xanh)** và bấm **[NHẬP]** thành công ngay.
> 
> **Lưu ý đặc biệt cho dung dịch điện phân:** Mỗi thùng 150 KG thực tế dùng cho **2 ngày liên tục** trên chuyền Cell. Hệ thống MES không trừ dần theo lần quét mà chỉ ghi nhận "đã nạp". Do đó khi phục hồi, phải phục hồi **đủ 150 KG** (hoặc đúng `InitialQty` của Lot) để tránh bị ngắt quãng báo Hết hàng giữa ca.

---

### Template 7: Xóa Trạng Thái Chốt Kẹt Trên Kiosk POP (MongoToMesPerformance)
```sql
-- Áp dụng khi POP vẫn hiện công đoạn đã chốt dù đã xóa STB_ProdRouteHist
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @TargetBarcode VARCHAR(50) = 'VVQR023R060672';
    DECLARE @TargetControlNo VARCHAR(20) = '20260902000418';

    -- 1. Snapshot backup an toàn bảng MongoToMesPerformance
    -- SELECT * INTO BAK_MongoToMesPerformance_<Date>_<Barcode> 
    -- FROM SmartFactoryV2.dbo.MongoToMesPerformance 
    -- WHERE Barcode = @TargetBarcode;

    -- 2. Xóa các công đoạn kẹt hoàn thành trong MongoToMesPerformance
    DELETE FROM SmartFactoryV2.dbo.MongoToMesPerformance 
    WHERE Barcode = @TargetBarcode 
      AND RouteCode IN ('V-24_HY', 'V-25_HY', 'V-26_HY', 'V-27_HY');

    -- 3. Đồng bộ lại công đoạn hiện tại trên STB_SetInfo
    UPDATE SmartFactoryV2.dbo.STB_SetInfo
    SET CurrentRouteCode = 'V-24_HY',
        ChangeDateTime = GETDATE()
    WHERE ControlNo = @TargetControlNo;

    -- 4. Kiểm tra lại kết quả
    SELECT Barcode, RouteCode, TotalProdQty, IsDone 
    FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK)
    WHERE Barcode = @TargetBarcode;

    -- Nếu kết quả đúng: Đổi ROLLBACK thành COMMIT
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

---

### Template 8: Đối Soát Toàn Diện & Giải Tỏa Kẹt Pipeline Đồng Bộ POP ➔ MES
```sql
-- 1. Kiểm tra nhanh các bản ghi bị kẹt IsTransferred = 0
SELECT 
    MMP.DayPlanNo,
    MMP.Barcode,
    MMP.RouteCode,
    MMP.TotalProdQty,
    MMP.IsDone,
    MMP.IsTransferred,
    MMP.ModifyDateTime,
    DATEDIFF(MINUTE, MMP.ModifyDateTime, GETDATE()) AS [MinutesPending]
FROM SmartFactoryV2.dbo.MongoToMesPerformance MMP WITH (NOLOCK)
WHERE MMP.IsDone = 1 
  AND MMP.IsTransferred = 0 
  AND MMP.IsSkipped = 0
ORDER BY MMP.ModifyDateTime ASC;

-- 2. Đối soát từng Lot giữa POP và MES trong ngày
SELECT 
    MMP.Barcode,
    SETI.ControlNo,
    MMP.RouteCode,
    MMP.TotalProdQty AS [SL_Chot_POP],
    ISNULL(PRH.ProdQty, 0) AS [SL_Nhan_MES],
    CASE 
        WHEN PRH.ProdRouteHistNo IS NULL THEN N'❌ CHƯA SANG MES'
        WHEN MMP.TotalProdQty <> PRH.ProdQty THEN N'⚠️ LỆCH SỐ LƯỢNG'
        ELSE N'✅ KHỚP 100%'
    END AS [TrangThaiDongBo],
    MMP.ModifyDateTime AS [ThoiDiemChotPOP],
    PRH.ProdDateTime   AS [ThoiDiemNhanMES]
FROM SmartFactoryV2.dbo.MongoToMesPerformance MMP WITH (NOLOCK)
LEFT JOIN SmartFactoryV2.dbo.STB_SetInfo SETI WITH (NOLOCK) 
    ON MMP.Barcode = SETI.Barcode
LEFT JOIN SmartFactoryV2.dbo.STB_ProdRouteHist PRH WITH (NOLOCK) 
    ON PRH.ControlNo = SETI.ControlNo 
   AND PRH.RouteCode = MMP.RouteCode
WHERE MMP.IsDone = 1
  AND MMP.ModifyDateTime >= CAST(GETDATE() AS DATE)
ORDER BY MMP.ModifyDateTime DESC;
```

---

### Template 9: Chốt Bù Sang MES Thủ Công Khi Job Đồng Bộ Bị Treo (IsTransferred = 0)
> **Ngữ cảnh:** Một số Line (như `VVC-11`) bị kẹt `IsTransferred = 0` không tự đẩy sang `STB_ProdRouteHist`, khiến báo cáo B782/B530 bị thiếu hụt sản lượng. Áp dụng template an toàn sau để chốt bù từng Lot:

```sql
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @TargetBarcode VARCHAR(50) = '<TARGET_BARCODE>'; -- VD: 'VVQR173R050520'
    DECLARE @TargetRoute VARCHAR(20) = '<TARGET_ROUTE>';     -- VD: 'V-23'
    DECLARE @ControlNo VARCHAR(20);
    DECLARE @DayPlanNo VARCHAR(20);
    DECLARE @WorkCenterCode VARCHAR(20);
    DECLARE @ProdQty DECIMAL(18,5);
    DECLARE @NewHistNo VARCHAR(20);

    -- 1. Lấy thông tin từ bảng trung gian và SetInfo
    SELECT 
        @ControlNo = SI.ControlNo,
        @DayPlanNo = MMP.DayPlanNo,
        @WorkCenterCode = SI.WorkCenterCode,
        @ProdQty = CAST(MMP.TotalProdQty AS DECIMAL(18,5))
    FROM SmartFactoryV2.dbo.MongoToMesPerformance MMP WITH(NOLOCK)
    JOIN SmartFactoryV2.dbo.STB_SetInfo SI WITH(NOLOCK) ON MMP.Barcode = SI.Barcode
    WHERE MMP.Barcode = @TargetBarcode 
      AND MMP.RouteCode = @TargetRoute 
      AND MMP.IsDone = 1;

    IF @ControlNo IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy bản ghi cần chốt bù trên MongoToMesPerformance!', 16, 1);
    END

    -- 2. Sinh số Serial ProdRouteHistNo chuẩn hệ thống
    EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProdRouteHist', @NewHistNo OUTPUT;

    -- 3. INSERT vào STB_ProdRouteHist
    INSERT INTO SmartFactoryV2.dbo.STB_ProdRouteHist (
        ProdRouteHistNo, CompanyCode, FactoryCode, ControlNo, DayPlanNo,
        RouteCode, WorkCenterCode, ProdQty, LossQty, ProdDateTime,
        CreateUserID, CreateDateTime
    )
    VALUES (
        @NewHistNo, 'VNT', 'VVT_F5', @ControlNo, @DayPlanNo,
        @TargetRoute, @WorkCenterCode, @ProdQty, 0, GETDATE(),
        N'IT_MANUAL_SYNC', GETDATE()
    );

    -- 4. Đánh dấu đã chuyển giao trên bảng đệm POP
    UPDATE SmartFactoryV2.dbo.MongoToMesPerformance
    SET IsTransferred = 1,
        ModifyDateTime = GETDATE()
    WHERE Barcode = @TargetBarcode AND RouteCode = @TargetRoute;

    -- 5. Kiểm tra kết quả
    SELECT ProdRouteHistNo, ControlNo, RouteCode, ProdQty, ProdDateTime, CreateUserID 
    FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK) 
    WHERE ProdRouteHistNo = @NewHistNo;

    -- Nếu chính xác: Đổi ROLLBACK thành COMMIT
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

---

### Template 10: Giải Phóng Thiết Bị Bị Kẹt Khóa ACTIVE Trên Kiosk POP (Equipment Release)

> **Ngữ cảnh:** Thiết bị Winding / Curling / Sleeving bị ẩn trên giao diện modal "Xác nhận Kết thúc?" do bản ghi `VINA_EQUIPMENT_MAPPING` bị treo trạng thái `ACTIVE` ở Kế hoạch sản xuất cũ (`DAY_PLAN_NO`).
> **Lưu ý quan trọng:** Cột `RELEASE_REASON` có kiểu dữ liệu `NVARCHAR(50)`, tuyệt đối không truyền chuỗi quá 50 ký tự để tránh lỗi `String or binary data would be truncated`.

```sql
USE VINATECH_POP;
BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Kiểm tra danh sách bản ghi trước khi cập nhật
    SELECT MAPPING_ID, DAY_PLAN_NO, LINE_CODE, ROUTE_CODE, EQUIPMENT_ID, EQUIPMENT_NAME, MAPPING_STATUS, MAPPED_AT
    FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING WITH (NOLOCK)
    WHERE MAPPING_ID IN (<DANH_SÁCH_MAPPING_ID>)
      AND MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED');

    -- 2. Thực hiện giải phóng thiết bị
    UPDATE VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING
    SET MAPPING_STATUS      = 'RELEASED',
        RELEASED_AT         = GETDATE(),
        RELEASE_REASON      = N'Release cho Model 35105', -- Rút ngắn <= 50 ký tự
        NO_EMP_MODIFYER     = 'vanduc',
        CD_COMPANY_MODIFYER = 'VINA'
    WHERE MAPPING_ID IN (<DANH_SÁCH_MAPPING_ID>)
      AND MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED');

    -- 3. Kiểm tra số dòng tác động
    DECLARE @AffectedRows INT = @@ROWCOUNT;
    IF @AffectedRows = <SO_DONG_DU_KIEN>
    BEGIN
        PRINT N'Thành công giải phóng ' + CAST(@AffectedRows AS NVARCHAR(10)) + N' thiết bị.';
        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        PRINT N'Số dòng thực tế (' + CAST(@AffectedRows AS NVARCHAR(10)) + N') khác dự kiến! Thực hiện ROLLBACK.';
        ROLLBACK TRANSACTION;
    END
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

---

### Template 11: Chuẩn Hóa Lỗi Phế POP Bị Ẩn Do Three-Valued Logic (IsDelete IS NULL, RepairQty IS NULL)

> **Ngữ cảnh:** Mã lỗi phế đã ghi nhận trên POP Kiosk (bảng `MongoToMesDefect` và `STB_DefectRepairInfo`), nhưng giao diện Kiosk/B782 không hiển thị mã lỗi hoặc tổng phế trên `STB_SetInfo.DefectQty` bị thiếu.
> **Nguyên nhân gốc:** Cột `IsDelete` và `RepairQty` trong `STB_DefectRepairInfo` không có ràng buộc `DEFAULT '0'` / `DEFAULT 0`. Khi chèn từ POP bị để trống (`NULL`), mệnh đề SQL `WHERE IsDelete = '0'` cho kết quả `UNKNOWN` (Three-Valued Logic) và loại bỏ hoàn toàn các bản ghi này. Ngoài ra `DefectQty - RepairQty` bị ra `NULL` thay vì số lượng thực.

```sql
USE SmartFactoryV2;
BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Snapshot backup trước khi sửa
    -- SELECT * INTO BAK_STB_DefectRepairInfo_<Date>_<Barcode> 
    -- FROM STB_DefectRepairInfo WHERE ControlNo = '<ControlNo>' AND FindRouteCode = '<RouteCode>';

    -- 2. Chuẩn hóa IsDelete và RepairQty cho bản ghi phế của Lot
    UPDATE STB_DefectRepairInfo
    SET IsDelete       = '0',
        RepairQty      = ISNULL(RepairQty, 0),
        ChangeDateTime = GETDATE(),
        ChangeUserID   = 'vanduc'
    WHERE ControlNo = '<ControlNo>'
      AND FindRouteCode = '<RouteCode>'
      AND (IsDelete IS NULL OR RepairQty IS NULL);

    -- 3. Cập nhật lại tổng DefectQty trên STB_SetInfo
    UPDATE s
    SET s.DefectQty = ISNULL((
            SELECT SUM(DefectQty) 
            FROM STB_DefectRepairInfo WITH(NOLOCK) 
            WHERE ControlNo = s.ControlNo AND IsDelete = '0'
        ), 0),
        s.IsDefect = CASE WHEN ISNULL((SELECT SUM(DefectQty) FROM STB_DefectRepairInfo WITH(NOLOCK) WHERE ControlNo = s.ControlNo AND IsDelete = '0'), 0) > 0 THEN 1 ELSE 0 END,
        s.ChangeDateTime = GETDATE(),
        s.ChangeUserID = 'vanduc'
    FROM STB_SetInfo s
    WHERE s.ControlNo = '<ControlNo>';

    PRINT N'>> Hoàn tất chuẩn hóa phế thành công!';
    -- Đổi ROLLBACK thành COMMIT TRANSACTION sau khi verify:
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

---

## 3. 🛠️ CẨM NANG 17 CA BỆNH THỰC CHIẾN NỘI BỘ EA TEAM (HƯỚNG DẪN XỬ LÝ HỆ THỐNG POP KHI GẶP LỖI)

> **Tài liệu gốc:** `HƯỚNG DẪN XỬ LÝ HỆ THỐNG POP KHI GẶP LỖI.docx` (Master Playbook - EA Team)  
> **Tác giả & Vận hành:** Nguyen Van Duc (`vanduc`) - Ban IT / EA Team Vinatech  
> **Nguyên tắc vận hành:** Đây là 17 ca bệnh thực tế phát sinh trực tiếp tại các chuyền sản xuất Hà Nam & Hưng Yên, chứa đựng cơ chế ngầm và câu lệnh SQL can thiệp chuẩn mực.

---

### Case 1: Lỗi Cắt Đóng Gói Điện Cực Báo Sai Line
* **Hiện tượng:** Khi thực hiện cắt đóng gói điện cực trên Kiosk POP, hệ thống báo lỗi không thể tiếp tục.
* **Nguyên nhân cốt lõi:** Hệ thống POP mặc định yêu cầu chọn line Cắt là `ElectrodeBN` đối với nhà máy Bắc Ninh (hoặc Line tương ứng ở Hưng Yên). Nếu `STB_DayProdPlan` của Lot đang bị gán sai Line thì Kiosk chặn thực thi.
* **Query kiểm tra:**
  ```sql
  SELECT SI.Barcode, SI.DayPlanNo, DPP.LineCode, DPP.PONo, DPP.MaterialCode
  FROM SmartFactoryV2.dbo.STB_SetInfo SI WITH(NOLOCK)
  INNER JOIN SmartFactoryV2.dbo.STB_DayProdPlan DPP WITH(NOLOCK) ON DPP.DayPlanNo = SI.DayPlanNo
  WHERE SI.Barcode = '<Mã_Lot>';
  ```
* **Cách khắc phục:** Cập nhật lại `LineCode` trong `STB_DayProdPlan` về đúng Line cắt quy định (`ElectrodeBN`).

---

### Case 2: Chưa Thêm Mã Lỗi Ứng Với Từng Công Đoạn (`STB_DefectGroup` & `STB_DefectInfo`)
* **Hiện tượng:** Trên Kiosk POP không hiển thị bảng danh mục phế phẩm khi công nhân bấm nút khai báo phế, hoặc báo lỗi công đoạn chưa có nhóm phế.
* **Nguyên nhân cốt lõi:** Công đoạn mới (ví dụ: `V-11_HY` - Slitting Hưng Yên) chưa được đăng ký nhóm phế trong `STB_DefectGroup` hoặc chưa clone danh mục mã phế con từ nhóm chuẩn `V-11` sang `STB_DefectInfo`.
* **Hai bảng quản trị:** `STB_DefectGroup` (Nhóm lỗi) và `STB_DefectInfo` (Chi tiết mã lỗi).
* **SQL Hotfix chuẩn (Author: vanduc):**
  ```sql
  USE SmartFactoryV2;
  BEGIN TRANSACTION;
  BEGIN TRY
      -- 1. Đăng ký nhóm phế công đoạn nếu chưa có
      IF NOT EXISTS (SELECT 1 FROM STB_DefectGroup WHERE DefectGroupCode = 'V-11_HY')
      BEGIN
          INSERT INTO STB_DefectGroup(DefectGroupCode, BasicDefectGroupName, IsUsed, CreateUserID, CreateDateTime)
          VALUES ('V-11_HY', 'SLITTING', 1, 'vanduc', GETDATE());
      END

      -- 2. Clone mã lỗi từ nhóm gốc sang nhóm mới
      INSERT INTO STB_DefectInfo (
          DefectCode, BasicDefectName, DefectDesc, DefectGroupCode, UseGroup, DisplayIndex,
          IsRealDefect, IsUsed, DefectImage, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID,
          DirectlyUnder, WorkCenterCode, DefectCause, DefectEnglishName
      )
      SELECT
          REPLACE(DefectCode, 'V-11_', 'V-11_HY_'), BasicDefectName, DefectDesc, 'V-11_HY',
          UseGroup, DisplayIndex, IsRealDefect, IsUsed, DefectImage, GETDATE(), 'vanduc', NULL, NULL,
          DirectlyUnder, WorkCenterCode, DefectCause, DefectEnglishName
      FROM STB_DefectInfo WITH(NOLOCK)
      WHERE DefectGroupCode = 'V-11'
        AND NOT EXISTS (
            SELECT 1 FROM STB_DefectInfo 
            WHERE DefectCode = REPLACE(STB_DefectInfo.DefectCode, 'V-11_', 'V-11_HY_')
        );

      COMMIT TRANSACTION;
      PRINT N'>> Đã cấu hình danh mục mã lỗi thành công.';
  END TRY
  BEGIN CATCH
      IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
      THROW;
  END CATCH;
  ```

---

### Case 3 & 14: Xung Đột Dữ Liệu MES WinForm vs Web POP & Lỗi Nhảy Cóc Công Đoạn
* **Hiện tượng:** 
  * Khi hàng đã thao tác trên MES WinForm rồi quay sang POP, Kiosk báo lỗi: `"This route is already completed in MES"`.
  * Hoặc công đoạn chưa kịp chốt trên POP thì hệ thống đã tự sinh ra công đoạn tiếp theo.
* **Nguyên nhân gốc rễ (Bản chất kỹ thuật):**
  * **Cơ chế MES WinForm:** Khi chốt hoàn thành 1 công đoạn, hệ thống **tự động sinh sẵn 1 dòng ở công đoạn kế tiếp** trong `STB_ProdRouteHist` với `CompleteRoute = 1`.
  * **Cơ chế Web POP:** Khi hoàn thành 1 công đoạn, hệ thống **chỉ sinh ra duy nhất 1 dòng hoàn thành cho công đoạn đó** và để `CompleteRoute = NULL`.
  * **Xung đột:** Khi OP quay lại Web POP, Kiosk kiểm tra thấy đã tồn tại bản ghi ở công đoạn đó rồi ➔ Chặn không cho nhập và báo lỗi đã hoàn thành.
* **Quy trình xử lý chuẩn:**
  ```sql
  USE SmartFactoryV2;
  BEGIN TRANSACTION;
  BEGIN TRY
      -- Bước 1: Lấy ProdRouteHistNo bị sinh thừa ở công đoạn kế tiếp
      SELECT ProdRouteHistNo, ControlNo, RouteCode, CompleteRoute, CreateDateTime
      FROM STB_ProdRouteHist WITH(NOLOCK)
      WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = '<Mã_Lot>')
        AND RouteCode = '<Mã_Công_Đoạn_Bị_Sinh_Sớm>';

      -- Bước 2: Xóa công nhân và xóa lượt chốt thừa
      DELETE FROM STB_ProdRouteWorkerHist 
      WHERE ProdRouteHistNo IN (
          SELECT ProdRouteHistNo FROM STB_ProdRouteHist 
          WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = '<Mã_Lot>') 
            AND RouteCode = '<Mã_Công_Đoạn_Bị_Sinh_Sớm>'
      );

      DELETE FROM STB_ProdRouteHist 
      WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = '<Mã_Lot>') 
        AND RouteCode = '<Mã_Công_Đoạn_Bị_Sinh_Sớm>';

      COMMIT TRANSACTION;
      PRINT N'>> Đã xóa lượt sinh sớm, công đoạn sẵn sàng chốt trên POP.';
  END TRY
  BEGIN CATCH
      IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
      THROW;
  END CATCH;
  ```

---

### Case 4: Ràng Buộc Nạp Cuộn Điện Cực Tối Đa 3 LOTNO (Đã Nâng Cấp Từ 2 Lên 3)
* **Hiện trạng hiện hành:** Hệ thống POP Kiosk đã được cấu hình nâng cấp cho phép nạp **tối đa 3 LOTNO sản phẩm** cho một mã cắt cuộn điện cực BTP (thay vì định mức cũ 2 LOTNO).
* **Hiện tượng lỗi nếu vượt quá:** Quét cuộn BTP điện cực vào Kiosk báo: `"This roll has already been used for 3 product LOTs. Input blocked."`
* **Nguyên nhân:** Ràng buộc an toàn vật tư của nhà máy Vinatech: Giới hạn số Lot thành phẩm sử dụng chung một cuộn BTP để kiểm soát phế phẩm, sai số dung sai độ dày và chống âm kho.
* **Hướng xử lý:**
  1. Đổi sang cuộn điện cực mới còn tồn kho hợp lệ.
  2. Nếu cuộn cũ thực tế vẫn còn màng dài do dung sai sản xuất: Báo Quản đốc/Kỹ sư xưởng làm thủ tục tách mã phụ Lot BTP trên MES WinForm để tiếp tục cấp phát hợp lệ.

---

### Case 5: Không Thể Đóng Gói Khi Báo Không Có Kho
* **Hiện tượng:** Tại trạm Đóng gói, công nhân bấm hoàn thành thì Kiosk báo lỗi không xác định được kho thành phẩm.
* **Nguyên nhân:** CellLine chưa được cấu hình liên kết công đoạn đóng gói với kho đích trong Master Data.
* **Cách xử lý:** Vào MES WinForm, mở màn hình **B230** (Cấu hình CellLine), kiểm tra thiết lập gắn công đoạn và kho đóng gói (tham khảo cấu hình chuẩn tại Line Thủ công TX1).

---

### Case 6: Hạng Mục Tự Kiểm PQC In-Line Thiết Lập Nhầm Công Đoạn
* **Hiện tượng:** Công nhân kiểm tra chất lượng mở Kiosk PQC nhưng hạng mục đo bị gắn sai công đoạn (ví dụ: các mã đo `V_H1_HY`, `V_H2_HY`, `V_WA_HY` đáng lẽ ở `V-24_HY` nhưng lại nằm ở công đoạn khác).
* **Quy trình xử lý 2 bước:**
  1. **Bước 1 (Master):** Vào màn hình **C141** trên WinForm để cập nhật lại cấu hình công đoạn chuẩn cho hạng mục kiểm tra.
  2. **Bước 2 (SQL Data Fix):** Cập nhật dữ liệu tài liệu kiểm tra đã sinh cho Lot:
     ```sql
     USE SmartFactoryV2;
     BEGIN TRANSACTION;
     BEGIN TRY
         UPDATE DI 
         SET DI.RouteCode = 'V-24_HY'
         FROM STB_CommInspDocItem DI
         INNER JOIN STB_CommInspDocHistory DH ON DH.CommInspDocNo = DI.CommInspDocNo
         INNER JOIN STB_SetInfo SI ON SI.ControlNo = DH.ProdNo
         WHERE SI.Barcode = '<Mã_Lot>'
           AND DI.CommInspItemCode IN ('V_H1_HY', 'V_H2_HY', 'V_WA_HY');

         COMMIT TRANSACTION;
         PRINT N'>> Đã điều chỉnh công đoạn tài liệu kiểm tra thành công.';
     END TRY
     BEGIN CATCH
         IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
         THROW;
     END CATCH;
     ```

---

### Case 7: Báo Hết Tồn Kho Nguyên Vật Liệu Khi Nạp Kiosk
* **Hiện tượng:** Kiosk báo lỗi hết tồn kho NVL hoặc không tìm thấy Lot NVL khả dụng.
* **Quy trình chẩn đoán 3 kịch bản:**
  * **TH1 (Có NVL thay thế trong BOM):** Bấm biểu tượng icon chuyển đổi NVL thay thế ngay trên Kiosk để chọn mã NVL tương đương.
  * **TH2 (Hàng sản xuất liên phân xưởng BN & HY):** Cuộn NVL đang nằm ở kho Phân xưởng khác (chưa chuyển kho). Yêu cầu thủ kho làm phiếu Chuyển kho (F430) trên WinForm.
  * **TH3 (Kiểm tra số lượng tồn kho `CurrentQty`):**
    ```sql
    SELECT MaterialLotNo, LotID, MaterialCode, MaterialWarehouseCode, InitialQty, CurrentQty
    FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
    WHERE LotID = '<Mã_Cuộn_NVL>';
    ```
    * Nếu `CurrentQty = 0`: Cần cập nhật lại tồn kho thực tế hoặc kiểm tra lại lịch sử xuất kho trên F430.

---

### Case 8 & 9: Tìm Kiếm & Tạo Cưỡng Chế Tồn Kho Điện Cực (Cho Cuộn Bị Mờ/Rách Tem)
* **Ngữ cảnh:** Cuộn điện cực tại xưởng bị rách tem, mờ barcode hoặc chưa được đồng bộ từ Slitting vào `STB_MaterialLotInfo`, công nhân không thể quét nạp.
* **Cơ chế lọc Kiosk:** Popup tìm kiếm cuộn trên Kiosk chỉ hiển thị cuộn khi thỏa mãn:
  `CompanyCode = 'VVT' AND IsSlitting = 1 AND LotAttr01 = 'SLITTING' AND CurrentQty > 0 AND MaterialWarehouseCode = @warehouseCode AND PlusMinus IS NOT NULL`
* **Lưu ý cực tính (+/-):** Hệ thống phân biệt rõ cực tính Âm `(-)` và Dương `(+)` dựa trên `STB_MaterialMaster.PlusMinus` hoặc tên `MaterialName`.
* **Script tạo cưỡng chế chuẩn (Author: vanduc):**
  ```sql
  USE SmartFactoryV2;
  -- STEP 0: Xác định cuộn hợp lệ từ kết quả Slitting
  DECLARE @baseLot VARCHAR(50) = 'VWQO2720001E03'; -- Base Lot
  SELECT ESR.Barcode, ESR.Seq, ESR.SlittingWidth, ESR.ElectrodeThick, ESR.GoodQtyLength,
         ESR.SlittingMaterialCode, RTRIM(ISNULL(SlitMM.PlusMinus,'')) AS Polarity
  FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK)
  LEFT JOIN STB_MaterialMaster SlitMM WITH(NOLOCK) ON SlitMM.MaterialCode = ESR.SlittingMaterialCode
  WHERE ESR.ElectrodeLotNumber = @baseLot AND ESR.CompanyCode = 'VVT'
  ORDER BY ESR.Seq;

  -- STEP 1: Tạo bản ghi tồn kho cưỡng chế qua STB_SerialRule
  DECLARE @rollBarcode VARCHAR(50) = '<Mã_Cuộn_Cần_Tạo>';
  DECLARE @warehouseCode VARCHAR(20) = 'ROUTE_VN_WH';

  BEGIN TRANSACTION;
  BEGIN TRY
      -- Lấy thông tin cuộn
      DECLARE @matCode VARCHAR(50), @lengthM NUMERIC(13,3), @electrodeLot VARCHAR(50), @wcCode VARCHAR(20);
      SELECT TOP 1 
          @matCode = CASE WHEN SlitMM.MaterialCode IS NOT NULL THEN ESR.SlittingMaterialCode ELSE DPP.MaterialCode END,
          @lengthM = ISNULL(ESR.GoodQtyLength, 0),
          @electrodeLot = ESR.ElectrodeLotNumber,
          @wcCode = ISNULL(W.WorkCenterCode, 'VVT_F1')
      FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK)
      INNER JOIN STB_SetInfo SI WITH(NOLOCK) ON SI.Barcode = ESR.ElectrodeLotNumber
      INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK) ON DPP.DayPlanNo = SI.DayPlanNo
      LEFT JOIN STB_MaterialMaster SlitMM WITH(NOLOCK) ON SlitMM.MaterialCode = ESR.SlittingMaterialCode
      LEFT JOIN STB_MaterialWarehouse W WITH(NOLOCK) ON W.MaterialWarehouseCode = @warehouseCode AND W.CompanyCode = 'VVT'
      WHERE ESR.Barcode = @rollBarcode AND ESR.CompanyCode = 'VVT';

      -- Sinh số serial chuẩn từ STB_SerialRule
      DECLARE @curDate VARCHAR(8) = CONVERT(VARCHAR(8), GETDATE(), 112);
      DECLARE @prefix VARCHAR(12), @serialLen INT, @lastNo INT;
      SELECT @prefix = REPLACE(REPLACE(PrefixData, 'YYYY', SUBSTRING(@curDate,1,4)), 'MM', SUBSTRING(@curDate,5,2)),
             @serialLen = SerialLen, @lastNo = LastSerialNo
      FROM SmartFramework.dbo.STB_SerialRule WITH(UPDLOCK, ROWLOCK)
      WHERE TableName = 'STB_MaterialLotInfo';

      UPDATE SmartFramework.dbo.STB_SerialRule SET LastSerialNo = LastSerialNo + 1 WHERE TableName = 'STB_MaterialLotInfo';
      DECLARE @newLotNo VARCHAR(20) = @prefix + RIGHT(REPLICATE('0', @serialLen) + CAST(@lastNo + 1 AS VARCHAR(10)), @serialLen);

      -- Chèn tồn kho với LotAttr01 = 'SLITTING' và IsSlitting = 1
      INSERT INTO STB_MaterialLotInfo (
          MaterialLotNo, LotID, CompanyCode, WorkCenterCode, MaterialWarehouseCode, MaterialLocationCode,
          MaterialCode, MaterialStockAttribute, StockAttrib2, StockAttrib3, GRDate, InitialQty, CurrentQty,
          PickingQty, LotNo, IsSplitLot, LotAttr01, IsSlitting, LengthSlitting, CreateDateTime, CreateUserID
      ) VALUES (
          @newLotNo, @rollBarcode, 'VVT', @wcCode, @warehouseCode, '', @matCode, 'NORMAL', '', '',
          CONVERT(VARCHAR(10), GETDATE(), 23), @lengthM, @lengthM, 0, @electrodeLot, 0, 'SLITTING', 1, @lengthM, GETDATE(), 'vanduc'
      );

      COMMIT TRANSACTION;
      PRINT N'>> Tạo tồn kho cưỡng chế thành công cho cuộn: ' + @rollBarcode;
  END TRY
  BEGIN CATCH
      IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
      THROW;
  END CATCH;
  ```

---

### Case 10: Hướng Dẫn Thiết Lập Nguyên Vật Liệu Theo Từng CellLine Trên POP Web
* **Mục đích:** Thiết lập các ô Slot NVL trên Kiosk của từng Line theo đúng cấu trúc lắp ráp.
* **Bảng CSDL quản trị (`VINATECH_POP`):**
  * `VINA_ASSEMBLY_GROUP_MODE`: Cấu hình chế độ nạp theo cụm / group của Line.
  * `VINA_GROUP_INPUT_ROUTE`: Thiết lập thứ tự Slot, mã Route và tính bắt buộc (`IS_REQUIRED`).
* **Truy vấn kiểm tra:**
  ```sql
  SELECT * FROM VINATECH_POP.dbo.VINA_ASSEMBLY_GROUP_MODE ORDER BY LINE_CODE;
  SELECT LINE_CODE, SLOT_CODE, SLOT_NAME, ROUTE_CODE, IS_REQUIRED, DISPLAY_ORDER
  FROM VINATECH_POP.dbo.VINA_GROUP_INPUT_ROUTE
  WHERE LINE_CODE = 'VVHYC-13'
  ORDER BY DISPLAY_ORDER;
  ```
* **Quy tắc:** Mapping theo Group trên Kiosk tuân thủ theo tiêu chuẩn nhóm mặt hàng trong BOM (`ProductGroupCode` trong bảng `STB_MaterialMaster`). Chỉ tài khoản Admin mới có quyền thao tác trên UI Kiosk.

---

### Case 11: Hủy Đóng Gói Và Hủy Hoàn Thành Công Đoạn (Cơ Chế Phân Quyền Rollback)
* **Hiện tượng:** Công nhân muốn hủy lượt đóng gói hoặc hoàn tác công đoạn nhưng không tìm thấy nút hoặc bị báo lỗi quyền.
* **Cơ chế phân quyền:** Hệ thống POP Web giới hạn nghiêm ngặt thao tác Rollback để chống thất thoát dữ liệu. Chỉ các tài khoản được ủy quyền (Leader / Kỹ sư IT) mới được phân quyền thực hiện hủy đóng gói và hủy sản lượng trên giao diện.

---

### Case 12: Xử Lý Nguyên Vật Liệu Thay Thế Trong BOM
* **Ngữ cảnh:** Thực tế sản xuất có NVL thay thế từ nhà cung cấp khác hoặc mã NVL cũ hết hàng.
* **Cách xử lý:**
  1. Nếu BOM thừa hoặc có NVL thay thế: Thiết lập mã thay thế tại các cột `DelegateMaterialCode1`, `DelegateMaterialCode2`... trong Master Data.
  2. Trên giao diện Kiosk: Khi quét mã NVL thay thế đã được định nghĩa, Kiosk tự động nhận diện và đối trừ định mức hợp lệ.

---

### Case 13: Lỗi Khi Bấm Nhầm Chế Độ (+) Nhập Lượng Hoàn Thành vs (-) Phế Phẩm
* **Hiện tượng:** Công nhân ấn nhầm vào dấu `(+)` ở phần nhập phế làm Kiosk chuyển sang chế độ nhập lượng hoàn thành, sau đó bấm kết thúc bị lỗi hệ thống.
* **Cách xử lý:** Tiến hành Rollback lại lượt thao tác để công nhân chọn lại dấu `(-)` cho đúng phân hệ nhập phế phẩm.

---

### Case 15: Lỗi Chưa Lưu Độ Nhớt Ở Công Đoạn Trộn (Mixing)
* **Hiện tượng:** Kiosk công đoạn Mixing không cho bấm hoàn thành mẻ trộn hoặc Kiosk Coating chặn không cho nhận mẻ keo.
* **Nguyên nhân:** Công nhân pha trộn chưa lưu chỉ số đo độ nhớt của mẻ keo vào bảng kết quả đo.
* **Cách xử lý:** OP mở lại mẻ Mixing trên Kiosk, nhập đầy đủ giá trị độ nhớt đo thực tế và bấm Lưu trước khi chốt hoàn thành.

---

### Case 16: Lỗi Sửa Tên Máy / Gán Nhầm Mã Máy Khi Chốt Sản Lượng
* **Hiện tượng:** Công nhân chọn nhầm máy trên Kiosk (ví dụ: chạy máy `VVMHY130` nhưng bấm nhầm `VVMHY136`).
* **⚠️ NGUYÊN TẮC VÀNG BẮT BUỘC:** Phải UPDATE đồng thời ở **CẢ 2 BẢNG** (`STB_ProdRouteHist` **VÀ** `MongoToMesPerformance`). Nếu chỉ sửa bảng MES WinForm thì Background Worker của POP sẽ ghi đè ngược lại mã cũ!
* **SQL Hotfix chuẩn (Author: vanduc):**
  ```sql
  USE SmartFactoryV2;
  BEGIN TRANSACTION;
  BEGIN TRY
      DECLARE @Barcode VARCHAR(50) = '<Mã_Lot>';
      DECLARE @RouteCode VARCHAR(50) = 'V-22_HY';
      DECLARE @NewMachineCode VARCHAR(50) = 'VVMHY130'; -- Mã máy đúng

      -- 1. Cập nhật trên MES Lõi
      UPDATE STB_ProdRouteHist
      SET MachineCode    = @NewMachineCode,
          ChangeDateTime = GETDATE(),
          ChangeUserID   = 'vanduc'
      WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = @Barcode)
        AND RouteCode = @RouteCode;

      -- 2. Cập nhật trên bảng đệm POP (Chống Worker ghi đè)
      UPDATE MongoToMesPerformance
      SET MachineCode = @NewMachineCode
      WHERE Barcode = @Barcode
        AND RouteCode = @RouteCode;

      COMMIT TRANSACTION;
      PRINT N'>> Đã sửa đổi mã máy đồng bộ trên cả MES và POP!';
  END TRY
  BEGIN CATCH
      IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
      THROW;
  END CATCH;
  ```
* *(Ghi chú: Có thể vào màn hình **B270** trên WinForm để tra cứu `MachineCode` theo `MachineName` mà OP cung cấp).*

---

### Case 17: Nút Bấm "Cắt Điện Cực" Bị Mờ / Không Thể Nhấn
* **Hiện tượng:** Trên Kiosk công đoạn Cắt điện cực, nút bấm Cắt bị mờ (Disable), công nhân không thể thực hiện thao tác cắt màng.
* **NGUYÊN NHÂN CỐT LÕI (Logic Hệ Thống):** Hệ thống có thuật toán kiểm tra an toàn chất lượng: **Nếu độ dày màng điện cực `< 100` (`MaterialThickness < 100` trong `STB_MaterialMaster`) thì hệ thống tự động khóa nút Cắt!**
* **Câu lệnh kiểm tra độ dày:**
  ```sql
  SELECT MaterialCode, MaterialName, MaterialThickness, MaterialTypeCode
  FROM SmartFactoryV2.dbo.STB_MaterialMaster WITH(NOLOCK)
  WHERE MaterialCode = (
      SELECT MaterialCode FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = '<Mã_Lot>'
  );
  ```
* **Khắc phục:** Kiểm tra lại quy cách độ dày màng trong Master Data (`STB_MaterialMaster`). Nếu thông số thực tế hợp lệ nhưng cấu hình nhập sai `< 100`, Kỹ sư IT/Master Data cập nhật lại `MaterialThickness >= 100` để nút Cắt tự động sáng trở lại.

