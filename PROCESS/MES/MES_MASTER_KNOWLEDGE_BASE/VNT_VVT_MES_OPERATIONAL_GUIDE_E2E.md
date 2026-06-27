# 📖 HƯỚNG DẪN VẬN HÀNH MES VINATECH: LUỒNG ĐI MÀN HÌNH & THAO TÁC CHI TIẾT TỪ ĐẦU ĐẾN CUỐI (END-TO-END SCREEN GUIDE)

> **Mục tiêu:** Cung cấp tài liệu hướng dẫn vận hành chi tiết từng bước (Step-by-step) dành cho kỹ sư hệ thống và người vận hành MES. Tài liệu mô tả cụ thể **TCode màn hình nào**, **điền trường thông tin gì**, **quét mã nào**, **bấm nút nào**, và **dữ liệu chuyển đổi dưới database như thế nào** từ khi nguyên liệu về xưởng cho đến khi thành phẩm xuất đi khách hàng.

> 🧭 **Điều hướng nhanh:**
> - Cần **bản đồ luồng đi nhanh** (chỉ link) → [PROCESS_FLOW_MAP.md](PROCESS_FLOW_MAP.md)
> - Cần **giáo trình học bài bản** → [VNT_VVT_MES_OPERATIONAL_CURRICULUM.md](VNT_VVT_MES_OPERATIONAL_CURRICULUM.md)
> - Cần **tra cứu kỹ thuật 1 màn** → [ALL_SCREENS_DOCUMENTATION.md](ALL_SCREENS_DOCUMENTATION.md)
> - File này là **hướng dẫn thao tác chi tiết step-by-step** — đọc khi cần biết bấm nút nào.

---

## 🧭 BẢN ĐỒ TỔNG QUAN LUỒNG MÀN HÌNH (SCREEN FLOW MAP)

Hệ thống MES vận hành liên hoàn qua 7 bước màn hình chính dưới đây:

```
[A410/A419: Cấu hình Master]
         │
         ▼
[F312/F330/C220: Nhập NVL & IQC]
         │
         ▼
[F430: Xuất NVL ra dây chuyền]
         │
         ▼
[B450: Lập kế hoạch & Tạo Lot Cell]
         │
         ▼
[B540/B597: Nạp NVL & Tự kiểm tra trên Line]
         │
         ▼
[B530: Chốt sản lượng chặng (Backflush)]
         │
         ▼
[B523/C512/C530: Đóng gói & Đo kiểm OQC]
         │
         ▼
[C560/HN551: Nhập/Xuất kho thành phẩm]
```

---

## 📑 CHI TIẾT THAO TÁC & BIẾN ĐỔI DỮ LIỆU TỪNG BƯỚC

### 1. Bước 1: Khai Báo Master Data & Tiêu Chuẩn Sản Phẩm (Phase 0)

Trước khi chạy bất kỳ lô hàng nào, thông tin kỹ thuật và tiêu chuẩn của sản phẩm phải được khai báo đầy đủ trên hệ thống.

#### 1.1 Màn hình: A410 — Model Master Info (Thông tin Model)
- **Mục đích:** Khai báo thông tin kỹ thuật cốt lõi cho một Model sản phẩm mới.
- **Thao tác của User:**
  1. Click nút **Thêm mới (New)**.
  2. Nhập mã sản phẩm (`Model Code`, ví dụ: `ECVT30-197`) và tên sản phẩm (`Model Name`).
  3. Chọn nhóm loại hàng (`MaterialTypeCode = 'FERT'` cho thành phẩm, hoặc `'MDL'` cho hàng Module).
  4. **QUAN TRỌNG:** Nhập thông số Điện áp (`MBIExtText01` / `Vol`, ví dụ: `2.7`) và Điện dung (`MBIExtText02` / `Farad`, ví dụ: `100`). Nếu bỏ trống 2 trường này, hệ thống sẽ chặn không cho sinh Barcode sản phẩm ở các bước sau.
  5. Chọn loại kiểm tra OQC (`OqcType = 'MANUAL'`), cơ chế kiểm tra (`OqcInspectionRuleType = 'BY_MODEL'`), và cấp độ lấy mẫu (`InspectionType = 'SAMPLE'`, `InspectionLevel = 'SAMPLE'`).
  6. Nhấn **Lưu (Save)**.
- **Dưới Database:** Ghi nhận thông tin vào bảng `STB_ModelBasicInfo`.

#### 1.2 Màn hình: A419 — Packing Standard (Tiêu chuẩn đóng gói)
- **Mục đích:** Thiết lập số lượng quy định đóng thùng cho từng model.
- **Thao tác của User:**
  1. Nhấn nút Thêm dòng mới.
  2. Chọn mã hàng (`MaterialCode`) hoặc nhóm loại hàng (`MaterialTypeCode`), nhập kích thước (`Size`, ví dụ: `0813` cho tụ kích thước 8x13mm).
  3. Nhập số lượng Cell quy định đóng gói trong một Túi nilon (`VinylBagQty`, ví dụ: `500`), một Hộp nhỏ (`InnerBoxQty`, ví dụ: `4000`), và một Thùng carton lớn ngoài (`OutBoxQty`, ví dụ: `8000`).
  4. Nhấn **Lưu (Save)**.
- **Dưới Database:** Ghi dữ liệu vào bảng `STB_PackingStandard`.

#### 1.3 Màn hình: A210 — BOM Master (Định mức nguyên vật liệu)
- **Mục đích:** Khai báo định mức các nguyên liệu thành phần cấu thành sản phẩm.
- **Thao tác của User:**
  1. Chọn mã thành phẩm đầu ra (`Parent Material Code`).
  2. Add danh sách mã nguyên vật liệu thô thành phần (`Child Material Code`) kèm định mức tiêu hao.
  3. **QUAN TRỌNG:** Ở phần thuộc tính, tích chọn `IsUseProduction = 1` (Sử dụng cho SX) và cấu hình cờ đồng bộ `IsUseFlush = 1`, `IsUseBackFlush = 0` (để MES thực hiện trừ kho tự động khi sản xuất).
  4. Nhấn **Save**.
- **Dưới Database:** Ghi dữ liệu vào bảng `STB_BomHeader` và `STB_BomDetail`.

---

### 2. Bước 2: Nhập Kho Nguyên Vật Liệu & Kiểm Định IQC (Phase 1)

Quy trình quản lý WMS đầu vào để đưa nguyên vật liệu của nhà cung cấp vào kho sản xuất an toàn.

#### 2.1 Màn hình: F312 — Inward Slip (Phiếu ghi chú đơn hàng nhập)
- **Mục đích:** Tạo phiếu yêu cầu nhập kho nguyên vật liệu từ nhà cung cấp bên ngoài.
- **Thao tác của User:**
  1. Chọn Mã nhà cung cấp/Đối tác giao dịch (`Partner Code`).
  2. Chọn danh sách mã nguyên vật liệu cần nhập (`Material Code`).
  3. Nhập số lượng yêu cầu thực tế (`RequestQty`).
  4. Nhấn biểu tượng **Save** trên lưới.
- **Dưới Database:** Ghi một phiếu mới vào bảng `STB_MaterialDocInfo` (với trạng thái ban đầu `DocStatus = 'CREATE'`) và chi tiết vật tư vào `STB_MaterialDocDetail`.

#### 2.2 Màn hình: F330 — Goods Receipt & Part Labels (Nhập kho & In tem)
- **Mục đích:** Tạo Lot ID hệ thống (`ML...`) cho vật tư và in tem dán.
- **Thao tác của User:**
  1. Chọn số phiếu F312 vừa lập. Trạng thái phiếu lúc này hiển thị là `CREATE`.
  2. Bấm nút **"Xử lý hàng nhập về"**. Trạng thái phiếu sẽ chuyển sang `ARRIVAL`, các nút tạo tem mới sáng lên.
  3. Nhập `PackingQty` (Số lượng quy định đóng gói trên một tem/thùng NVL). Ví dụ: Nhập về 10,000 con, mỗi thùng đóng 2,000 con -> Nhập `PackingQty = 2000` -> Hệ thống tự động tính ra số tem cần in = 5.
  4. Nhấn nút **"Tạo tem"** để hệ thống tự động sinh ra danh sách 5 mã Lot tương ứng (Lot ID định dạng bắt đầu bằng `ML...`).
  5. **BẮT BUỘC (Trọng tâm vận hành):** Tại lưới danh sách các Lot vừa sinh, thủ kho bắt buộc phải quét hoặc nhập mã Lot của nhà cung cấp vào cột **"Đặc tính 10"** (`LotAttr10` / `LotExtText10`). Khi lưu, hệ thống tự động chạy hàm parse `fn_VVT_getdatebyVendorLot_MergeCode` để bóc tách ngày sản xuất và tự động điền hạn sử dụng. Nếu bỏ trống cột này hoặc điền định dạng sai khiến hàm parse trả về NULL, hệ thống sẽ tự động chuyển Lot này vào kho ảo **`HOLDING`** khi xuất kho và khóa không cho dùng.
  6. Click chọn các dòng Lot, nhấn **"In Tem"** để in nhãn mã vạch dán lên thùng hàng.
- **Dưới Database:** Sinh mã Lot lưu vào bảng `STB_MaterialLotInfo` và `STB_MaterialDocLotInfo` (lúc này cờ `IsUse` của Lot vẫn bằng `0` do chưa qua IQC).

#### 2.3 Màn hình: C220 — IQC Inspection (Kiểm tra chất lượng đầu vào)
- **Mục đích:** Ghi nhận kết quả kiểm định chất lượng Lot vật tư của phòng QC.
- **Thao tác của User (Nhân viên QC):**
  1. Mở màn hình C220, nhập mã Lot `ML...` vừa in ở F330.
  2. Hệ thống tự động hiển thị danh sách các hạng mục đo kiểm IQC (đã cấu hình ở màn hình A-series).
  3. QC đo đạc mẫu thực tế, nhập các giá trị đo được (kích thước, độ dày, nội trở...) vào lưới kết quả.
  4. Đánh giá tổng thể Lot: Click chọn kết quả là **PASS** (Lot đạt chất lượng).
  5. Nhấn **Lưu (Save)**.
- **Dưới Database:** Ghi nhận kết quả kiểm định vào bảng `STB_MaterialQcInfo` và lưu lịch sử vào `STB_CommInspDocHistory` (cột `QcResultCode` cập nhật thành `'PASS'`).

#### 2.4 Màn hình: F330 — Xác nhận kết thúc nhập kho
- **Mục đích:** Hoàn thành thủ tục nhập kho vật lý để hàng sẵn sàng xuất xưởng.
- **Thao tác của User (Thủ kho):**
  1. Chọn lại phiếu nhập kho.
  2. Nhấp nút **"Kết thúc nhập kho"**.
  3. Nhấp nút **"Xác nhận nhập kho"**.
     * *Cơ chế chặn:* Hệ thống tự động kiểm tra trạng thái QC tại màn hình C220. Nếu Lot chưa có kết quả kiểm định PASS, hệ thống sẽ hiện popup cảnh báo chặn cứng: *"Lô hàng chưa được đánh giá chất lượng PASS"* và không cho xác nhận.
- **Dưới Database:** Cập nhật trạng thái phiếu nhập thành `CONFIRM` trong `STB_MaterialDocInfo`, cập nhật số lượng tồn kho và kích hoạt cờ sử dụng của Lot trong `STB_MaterialLotInfo`.

#### 2.5 Màn hình: F721 — Báo cáo tồn kho & Vị trí kệ kho
- **Mục đích:** Gán vị trí kệ kho thực tế (Location) cho Lot hàng vừa nhập để dễ tìm kiếm.
- **Thao tác của User:**
  1. Nhập mã nguyên vật liệu và quét mã Lot `ML...`.
  2. Tại cột **Vị trí (Location)**, gõ hoặc chọn vị trí kệ kho tương ứng (ví dụ: `ROH_BG_WH_01`).
  3. Nhấn **Lưu (Save)**.
- **Dưới Database:** Cập nhật cột `MaterialLocationCode` trong bảng `STB_MaterialLotInfo`. Thông tin kệ kho này sẽ đồng bộ real-time lên màn hình Tivi giám sát vị trí kho.

---

### 3. Bước 3: Cấp Phát Nguyên Vật Liệu Ra Chuyền (Phase 1.5)

#### 3.1 Màn hình: F430 — Material Outbound (Cấp phát sản xuất)
- **Mục đích:** Xuất nguyên vật liệu từ kho vật lý chính sang kho ảo cạnh dây chuyền sản xuất để nạp máy.
- **Thao tác của User:**
  1. Chọn kho xuất (kho vật lý chính, ví dụ: `ROH_BG_WH`).
  2. Chọn Line sản xuất đích nhận vật tư (ví dụ: `VELINE-09`).
  3. Quét mã Lot nguyên liệu `ML...` cần xuất.
     * *Cơ chế chặn FIFO:* Hệ thống tự động thực thi SP `usp_VVTMaterialWarehouse_validFIFO`. Nếu trong kho đang tồn tại một Lot khác có ngày nhập kho cũ hơn nhưng chưa xuất, hệ thống sẽ báo lỗi: *"Vi phạm nguyên tắc FIFO, vui lòng xuất Lot [ML...] trước"*.
     * *Cơ chế chặn Hạn Dùng:* Hệ thống kiểm tra ngày hết hạn của Lot. Nếu Lot đã quá hạn sử dụng, hệ thống hiện thông báo lỗi và cấm xuất. (Muốn dùng phải làm thủ tục bypass đặc biệt qua bảng `stb_vvt_OpenExpiredMaterial`).
  4. Nhấn **Xác nhận xuất kho**.
- **Dưới Database:** Cập nhật kho quản lý của Lot trong bảng `STB_MaterialLotInfo` từ kho gốc `ROH_BG_WH` sang kho ảo cạnh chuyền `ROUTE_WH` (của Line sản xuất tương ứng). Chèn bản ghi giao dịch xuất kho vào bảng `STB_MaterialWarehouseInOutHist`.

---

### 3.5 Bước 3.5: Sản Xuất Điện Cực (Electrode Phase 2 - Dành riêng cho xưởng Điện cực)

Công đoạn chế tạo các cuộn điện cực dương/âm bằng cách trộn bột hoạt tính, tráng phủ foil nhôm/đồng và xả cuộn.

#### 3.5.1 Màn hình: B442 — Electrode Production Plan (Kế hoạch ngày điện cực)
- **Mục đích:** Khai báo kế hoạch sản xuất cuộn điện cực và sinh Lot điện cực thô.
- **Thao tác của User:**
  1. Chọn ngày chạy máy, chọn mã dây chuyền sản xuất điện cực.
  2. Chọn số PO, nhập số lượng cuộn kế hoạch.
     * *Cơ chế tự động:* Hệ thống liên kết trực tiếp với dữ liệu độ dày khai báo tại màn hình **A230 (Thông tin vật liệu)**. Nếu mã hàng đã được cài đặt thông số độ dày bên A230, hệ thống sẽ tự động điền thông số này vào cột **Độ dày** của B442. Nếu trống, người dùng bắt buộc phải điền tay.
  3. Nhấn **Lưu**, sau đó nhấn **Tạo Lot** để sinh mã Lot điện cực (bắt đầu bằng `EL...` hoặc mã thẻ kiểm soát).
  4. Bấm **In Tem** để in nhãn mã vạch điện cực dán lên cuộn core.
- **Dưới Database:** Thêm Lot điện cực vào bảng `STB_SetInfo` (với `@LabelType = 'ElectLabel'`).

#### 3.5.2 Phần mềm Electron: electrode.weighing (Cân điện cực Mixing)
- **Mục đích:** Hướng dẫn công nhân quét và cân định lượng các bột/dung dịch thành phần vào mẻ trộn (Than hoạt tính, chất dẫn điện, chất kết dính...).
- **Thao tác của User:**
  1. Mở phần mềm Electron trên máy tính trạm cân. Phần mềm kết nối cổng COM tự động đọc khối lượng từ cân điện tử.
  2. Quét mã Lot điện cực vừa in ở B442.
  3. Hệ thống gọi SP `usp_GetElectroMixPresentStep_vietnam` để load thứ tự các bước cân (`Seq` từ 1 đến 9).
  4. Công nhân tiến hành cân từng chất. Khi khối lượng nằm đúng khoảng sai số cho phép (`StdMinVal` - `StdMaxVal`), phần mềm tự động chốt bước đó và cho phép chuyển sang bước tiếp theo.
     * *Lưu ý Vận hành (Checkbox Ca Đêm):* Trên giao diện có ô tích **"CA ĐÊM CHUẨN BỊ TRƯỚC"** (`isnight`). Nếu tích chọn, hệ thống sẽ đưa bước cân dung dịch kết dính (CMC/Binder) lên trước than hoạt tính. Nếu ca ngày vận hành mà quên bỏ tích ô này, thứ tự bước sẽ bị nhảy lộn xộn và chặn cân. Công nhân cần bỏ tích và bấm "Làm mới màn hình".
     * *Reset Lot bị kẹt:* Nếu mẻ trộn bị kẹt nửa chừng do lỗi nhảy bước, IT cần chạy lệnh xóa dữ liệu cân tạm của Lot đó trong bảng `STB_ElectrodeMixStepInfo` để công nhân quét cân lại từ đầu.
- **Dưới Database:** Ghi nhận khối lượng thực tế từng mẻ cân vào bảng `STB_ElectrodeMixStepInfo` (qua SP `usp_DoCreateElectrodeMixStepInfo_electron`).

#### 3.5.3 Màn hình: B552 — Slitting Measure Result (Xả cuộn & In tem điện cực con)
- **Mục đích:** Ghi nhận thông số xả băng cuộn điện cực lớn thành các cuộn nhỏ và in tem thành phẩm điện cực cấp cho xưởng ráp Cell.
- **Thao tác của User:**
  1. Chọn tab công đoạn xả băng **Slitting** trên B552.
  2. Quét mã Lot điện cực lớn. Hệ thống kiểm tra:
     * *Chặn cấu hình:* Đối soát mã model điện cực với bảng cấu hình xả băng `stb_slittinglocationconfig_vvt`. Nếu model chưa được thiết lập các thông số (Cực dương `BY` có chiều rộng `Width = 200`, Cực âm `YP` có chiều rộng `Width = 180`, Vị trí kho...), hệ thống sẽ báo lỗi: *"Chưa CONFIG trong bảng STB_SLITTINGLOCATIONCONFIG_VVT"* và chặn quy trình.
  3. Tiến hành xả cuộn lớn thành các cuộn nhỏ. Nhập chiều dài, cân nặng từng cuộn nhỏ.
  4. Nhấn nút **In Tem** để in nhãn barcode cho từng cuộn điện cực con thành phẩm.
- **Dưới Database:**
  - Ghi nhận thông số đo đạc vào bảng `STB_ElectrodeSlittingResult` và `STB_ElectrodeStep`.
  - Tồn kho của các cuộn điện cực con đạt chuẩn được tự động cập nhật vào bảng `Stb_SlittingStock_VVT` để sẵn sàng cho trạm cuốn Cell quét kiểm tra ở B530.
  - Khấu trừ tồn kho của Lot nguyên vật liệu thô (foil đồng, nhôm) trong bảng `STB_MaterialLotInfo`.


---

### 4. Bước 4: Lập Kế Hoạch Sản Xuất & Khai Sinh Barcode (Phase 2.5)

#### 4.1 Màn hình: B450 — Kế hoạch sản xuất theo ngày (Day Plan)
- **Mục đích:** Tạo lệnh kế hoạch chạy máy hàng ngày và phát hành cuộn tem Barcode sản phẩm (ControlNo).
- **Thao tác của User:**
  1. Nhập ngày sản xuất (`PlanDate`), chọn dây chuyền sản xuất (`LineCode`), và chọn số PO sản xuất (`PONo`).
  2. Nhập số lượng kế hoạch cần chạy trong ngày (`PlanQty`).
  3. **QUAN TRỌNG:** Nhấn nút **Lưu**. Sau đó tích chọn cờ **"IsFixed = 1"** (Đã chốt kế hoạch) ở lưới dữ liệu.
  4. Nhấn nút **"Tạo Lot"** ở Tab bên dưới.
     * *Hành vi hệ thống:* Hệ thống gọi stored procedure `usp_DoCreateSetInfoForProdQty_VNT` để tự động tính toán và sinh ra các mã vạch (Barcode/ControlNo) định danh riêng cho từng sản phẩm (ví dụ: `VVQN1812001E23`). Số lượng barcode sinh ra tương ứng với quy mô lô sản xuất.
  5. Chọn dòng Lot vừa tạo, nhấn nút **"In Tem"** để in cuộn barcode sản phẩm ra máy in tem.
- **Dưới Database:**
  - Ghi nhận kế hoạch vào bảng `STB_DayProdPlan`.
  - Chèn danh sách Barcode sản phẩm mới sinh vào bảng `STB_SetInfo` (với trạng thái ban đầu `IsLineInput = 0` - chưa đưa vào chuyền).

---

### 5. Bước 5: Nạp Liệu & Vận Hành Trên Dây Chuyền (Phase 3)

#### 5.1 Màn hình: B540 — Assy Card Info (Nạp NVL đầu chuyền)
- **Mục đích:** Liên kết Barcode sản phẩm (`ControlNo` vừa in ở B450) với Lot nguyên liệu điện cực và ghi nhận thông số sấy lò.
- **Thao tác của User:**
  1. Quét mã Barcode sản phẩm (`ControlNo`) tại trạm lắp ráp đầu tiên (trạm Cuốn V-22).
  2. Quét Lot nguyên vật liệu điện cực dương/âm (đã xuất từ kho F430) để nạp vào máy.
  3. Nhập 4 thông số sấy bắt buộc tại tab sấy lò (Oven): Nhiệt độ sấy, Thời gian sấy bắt đầu, Thời gian sấy kết thúc, và Người kiểm tra.
  4. Nhấn **Lưu**.
- **Dưới Database:**
  - Ghi nhận lịch sử nạp nguyên liệu vào bảng `STB_RawMaterialInputHist`.
  - Cập nhật cờ đưa vào chuyền `IsLineInput = 1` và lưu thông số sấy lò vào bảng `STB_SetInfo` (các cột `SIExtText01` đến `SIExtText05`).

#### 5.2 Màn hình: B597 — Kiểm tra thường xuyên NVL phụ (Self-Inspection)
- **Mục đích:** Quét kiểm tra và nạp các nguyên vật liệu phụ (vỏ nhôm, nút cao su, dung dịch điện phân) lên máy sản xuất định kỳ.
- **Thao tác của User:**
  1. Quét mã Barcode sản phẩm (`ControlNo`) đang chạy trên máy.
  2. Quét mã Lot của nguyên vật liệu phụ (`ML...`) đang lắp trên máy.
     * *Cơ chế kiểm soát chất lượng:* Hệ thống tự động kiểm tra Lot NVL phụ. Nếu Lot đang bị QC đánh dấu **HOLD** hoặc đã **hết hạn sử dụng**, hoặc mã NVL phụ quét vào **không nằm trong định mức BOM** của PO đang sản xuất -> Hệ thống hiện cảnh báo lỗi màu đỏ và chặn không cho chạy máy.
  3. Nhấn nút **Lưu**.
- **Dưới Database:** Ghi nhận lịch sử kiểm tra và nạp NVL vào bảng `STB_RawMaterialInputHist` và `STB_CommInspDocHistory`.

#### 5.3 Màn hình: B530 — Nhập số lượng sản xuất công đoạn (Work Center Process)
- **Mục đích:** Ghi nhận sản lượng hoàn thành của Lot tại mỗi công đoạn chốt trong quy trình (V-23 Lắp cao su -> V-24 Curling -> V-25 Bọc vỏ -> V-27 Ngoại quan).
- **Thao tác của User:**
  1. Chọn công đoạn sản xuất (`RouteCode`, ví dụ: `V-23`).
  2. Quét mã Barcode sản phẩm (`ControlNo`).
  3. Nhập số lượng hoàn thành thực tế (`ProdQty`) và số lượng lỗi phát sinh (`DefectQty`, nếu có). Nếu có lỗi, chọn mã lỗi chi tiết trên lưới (ví dụ: `V-23_BM_BG` - Lỗi cuốn lệch).
  4. Nhấn nút **Xác nhận (Confirm)**.
     * *Cơ chế chặn cứng trên chuyền:* Hệ thống thực thi SP kiểm tra 7 cổng chặn (`usp_DoProcessProdRouteHistForCalc_SmartApp_VNT`):
       - Chặn nếu chưa quét nạp các NVL phụ bắt buộc ở màn hình B597 trước đó.
       - Chặn nếu số lượng chốt vượt quá sản lượng hoàn thành của công đoạn chặng trước đó.
       - Chặn nếu PO đang chạy không cấu hình công đoạn này.
- **Dưới Database (Công nghệ Backflush tự động):**
  - Hệ thống tự động chèn một dòng lịch sử quét mới vào bảng `STB_ProdRouteHist`.
  - Tự động gọi SP `usp_DoProcessProdGIMaterialByBOM` để trừ kho nguyên vật liệu phụ tương ứng theo định mức BOM nhân với số lượng sản phẩm vừa chốt (giảm tồn kho `CurrentQty` của Lot NVL phụ trong bảng `STB_MaterialLotInfo`).
  - **Tại công đoạn chặng cuối (`IsOutputRoute = 1`):** Hệ thống tự động cập nhật sản lượng hoàn thành PO trong `STB_ProductionOrderInfo.ProdFinishQty`, đánh dấu tụ điện hoàn thành (`IsProdFinish = 1` trong `STB_SetInfo`) và tự động gọi SP `usp_DoProcessProdGRMaterialByOne` để sinh phiếu nhận bán thành phẩm/thành phẩm (GR) tạm thời.

---

### 6. Bước 6: Đóng Gói Sản Phẩm & QC Đầu Ra OQC (Phase 5)

Sản phẩm hoàn thành từ xưởng được đóng thùng và kiểm định chất lượng xuất xưởng lần cuối.

#### 6.1 Màn hình: B523 — Đóng gói (Gộp Box / Carton)
- **Mục đích:** Quét gom các sản phẩm riêng lẻ thành túi nilon/hộp nhỏ, đóng vào thùng carton lớn và in nhãn thùng.
- **Thao tác của User:**
  1. Quét hoặc nhập mã Barcode Cell sản phẩm (`ControlNo`).
     * *Cơ chế kiểm soát:* Hệ thống tự động kiểm tra Cell đã qua hết các chặng sản xuất chưa (`IsProdFinish = 1`), đã có kết quả kiểm tra PQC PASS chưa, và đã được đóng vào hộp khác chưa. Nếu không đạt, chặn không cho đóng gói.
  2. Hệ thống load số lượng đóng gói tiêu chuẩn từ `STB_PackingStandard`.
  3. Xếp các Cell sản phẩm vào hộp/thùng carton lớn.
  4. **QUY TẮC MỚI BẮT BUỘC:** Công nhân phải nhấp chọn nút **"In tem Box To trước"** để in tem thùng carton ngoài (Outer Box) trước. Hệ thống gọi SP `usp_Vietnam_DoProcessProdPacking_VVT` để sinh mã thùng hàng (`PackingID` / `BoxID`, ví dụ: `PK202606180001`) và in nhãn.
     * *Cơ chế đổi đầu mã:* Hệ thống tự động kiểm tra cấu hình trong `STB_Vietnam_PackingPrinting`. Nếu model có cấu hình chuyển đổi đầu mã xuất khẩu, hệ thống tự động đổi đầu nhãn in từ `VV` (Sản xuất) sang `VJ` (Thành phẩm xuất bán).
  5. Sau khi in tem Box To thành công, nút **"Chia Box (Split Box)"** mới sáng lên. Công nhân nhấn nút này để hệ thống sinh danh sách tem cho các hộp nhỏ bên trong (`Inner Box`) và in nhãn dán cho từng hộp nhỏ.
- **Dưới Database:** Ghi nhận mã thùng hàng (`PackingID`) liên kết với danh sách barcode sản phẩm vào bảng đóng gói `STB_DividePackaging` và tạo bản ghi Lot thành phẩm mới trong bảng tồn kho `STB_MaterialLotInfo`.

#### 6.2 Màn hình: C512 — Quản lý Lot kiểm tra OQC
- **Mục đích:** Tạo yêu cầu và Lot kiểm định chất lượng đầu ra (OQC) cho thùng hàng.
- **Thao tác của User (Nhân viên OQC):**
  1. Quét mã vạch thùng hàng (`PackingID` / `BoxID` vừa in ở B523).
  2. Nhấn nút **"Tạo Lot kiểm tra OQC"**.
     * *Hành vi hệ thống:* Tự động sinh mã phiếu QC (`MaterialQcNo`, bắt đầu bằng chữ `A` + tên BoxID, ví dụ: `APK202606180001`).
- **Dưới Database:** Ghi nhận Lot QC mới vào bảng `STB_MaterialQcInfo`.

#### 6.3 Màn hình: C530 — OQC Sample (Kiểm tra mẫu OQC thủ công)
- **Mục đích:** Kiểm tra và nhập kết quả đo mẫu OQC cho Lot thành phẩm.
- **Thao tác của User (QC):**
  1. Nhập mã Lot OQC (`MaterialQcNo`).
  2. Bấm nút **"Tổng hợp hạng mục"** để load các hạng mục chất lượng quy định của model (ngoại quan, rò rỉ dung dịch, kích thước chân...).
  3. Lấy mẫu thực tế theo số lượng quy định (Sample Qty, ví dụ: 20 hoặc 50 mẫu).
  4. Đo đạc và nhập kết quả đo của từng mẫu vào bảng kết quả bên phải -> Nhấn **Lưu (Save)** ở bảng bên phải.
  5. Click chọn kết quả tổng thể ở khung bên trái là **PASS** (Đạt chất lượng) -> Nhấn **Lưu (Save)** bên trái.
  6. Nhấn nút **"Đánh giá OK"** để chính thức phê duyệt thông quan cho lô hàng xuất xưởng.
- **Dưới Database:** Cập nhật kết quả Lot QC thành PASS (`QcResultCode = 'PASS'`) trong bảng `STB_MaterialQcInfo`, lưu chi tiết đo mẫu vào `STB_MaterialQcSampleResult`.

#### 6.4 Màn hình: C546 — FOQC (Đo kiểm OCV/ESR tự động xuất kho)
- **Mục đích:** Dành cho các lô hàng kiểm tra điện áp (OCV) và nội trở (ESR) tự động bằng máy đo.
- **Thao tác của User (QC):**
  1. Mở màn hình C546, quét mã Lot OQC.
  2. Nhấn nút **"Lấy kết quả đo từ máy"**.
     * *Hành vi hệ thống:* MES tự động gọi SP `usp_MaterialQcSampleResult_get` để truy vấn dữ liệu đo thực tế của Lot từ bảng giám sát máy `Stb_ESRValueMonitor` và tự động điền đầy đủ 50 dòng kết quả đo OCV & ESR lên lưới giao diện mà không cần QC nhập tay.
  3. Kiểm tra dữ liệu tự động điền, nhấn **Xác nhận OK** để thông quan.

---

### 7. Bước 7: Nhập/Xuất Kho Thành Phẩm & Xuất Hàng (Phase 6)

#### 7.1 Màn hình: C560 — Finished Goods Receipt (Nhập kho thành phẩm)
- **Mục đích:** Xác nhận nhập thùng hàng thành phẩm đã qua OQC PASS vào kho thành phẩm vật lý của nhà máy.
- **Thao tác của User (Thủ kho thành phẩm):**
  1. Quét mã nhãn thùng hàng (`PackingID` / `BoxID`).
     * *Cơ chế chặn:* Hệ thống kiểm tra trạng thái Lot QC trong bảng `STB_MaterialQcInfo`. Nếu Lot chưa đạt trạng thái PASS ở bước OQC, hệ thống sẽ chặn không cho quét nhập kho thành phẩm.
  2. Nhấn **Xác nhận nhập kho**.
- **Dưới Database:** Ghi nhận giao dịch vào bảng lịch sử `STB_MaterialWarehouseInOutHist`, cập nhật kho lưu trữ thực tế của Lot trong `STB_MaterialLotInfo` về kho thành phẩm (ví dụ: `FG_BG_WH`).

#### 7.2 Màn hình: HN551 — Xuất kho thành phẩm (Hà Nam / Bắc Giang)
- **Mục đích:** Thực hiện quét xuất kho thành phẩm để vận chuyển giao cho khách hàng theo hóa đơn.
- **Thao tác của User:**
  1. Chọn mã hóa đơn/phiếu xuất hàng (`Invoice No`) đồng bộ từ ERP/Groupware.
  2. Quét các mã vạch thùng hàng (`PackingID` / `BoxID`) xếp lên xe.
  3. Nhấn nút **Xác nhận xuất kho**.
- **Dưới Database:** Ghi nhận lịch sử xuất vào bảng `InvoiceFinishGoodStockOutBG`, trừ số lượng tồn kho của các thùng hàng tương ứng trong bảng `STB_MaterialLotInfo` về `0` (CurrentQty = 0) và ghi nhận log hoàn thành xuất xưởng.

---

## 🚦 TÓM TẮT CÁC CƠ CHẾ CHẶN CỦA HỆ THỐNG (VALIDATION GATES SUMMARY)

| TCode | Tên Màn Hình | Tác Nhân Chặn | Hành Vi Chặn | Cách Xử Lý Nhanh |
|:---|:---|:---|:---|:---|
| **F330** | Nhập kho NVL | Lot chưa được QC đánh giá PASS tại màn hình **C220** | Khóa nút "Xác nhận nhập kho" | Báo QC hoàn thành đo kiểm và lưu PASS ở C220 |
| **F430** | Xuất kho NVL | Có Lot cùng loại nhập kho trước đó chưa xuất (Vi phạm **FIFO**) | Hiện popup thông báo vi phạm FIFO và chặn xuất | Quét đúng Lot nhập trước theo thông báo, hoặc yêu cầu IT sửa cờ chặn FIFO ở `STB_MaterialStockAttributeInfo` |
| **F430** | Xuất kho NVL | Lot đã quá hạn sử dụng (Shelf Life) | Hiện popup thông báo Lot hết hạn và chặn xuất | QC kiểm định lại Lot. Nếu đạt, chạy lệnh INSERT Lot vào bảng bypass `stb_vvt_OpenExpiredMaterial` |
| **B530** | Chốt sản lượng | Chưa quét nạp các NVL phụ bắt buộc ở màn hình **B597** | Báo lỗi: *"Chưa nhập NVL cho Lắp Cao Su"* | Công nhân phải vào B597 quét nạp Lot NVL phụ trước rồi mới quay lại B530 chốt |
| **B530** | Chốt sản lượng | Sản lượng chốt vượt quá sản lượng hoàn thành chặng trước | Báo lỗi vượt sản lượng chặng trước | Kiểm tra lịch sử quét chặng trước ở B782. Bổ sung quét thiếu ở chặng trước hoặc chỉnh lại số lượng |
| **B523** | Đóng gói | Chưa có cấu hình số lượng đóng gói thùng | Báo lỗi: *"Chưa có tiêu chuẩn đóng gói"* | Vào màn hình **A419** cấu hình đầy đủ số lượng đóng gói thùng cho size của model |
| **C560** | Nhập kho TP | Thùng hàng chưa được OQC đánh giá PASS ở màn hình **C530** | Chặn quét mã thùng nhập kho thành phẩm | Báo QC hoàn thành đo kiểm mẫu OQC và lưu nút "Đánh giá OK" ở C530 |
