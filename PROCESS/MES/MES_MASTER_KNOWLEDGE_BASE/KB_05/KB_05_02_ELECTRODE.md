## 8. ⚡ Điện cực (Electrode)

### 8.1 Chỉnh chiều rộng Slitting (B552)

```sql
-- Xem cấu hình master slitting
SELECT * FROM STB_CoatingToSlittingMaster
-- WHERE CoatingMaterialCode = 'Mã_Coating'

-- Cập nhật chiều rộng slitting
UPDATE stb_slittinglocationconfig_vvt
SET Width = 16
WHERE SlittingCode = 'YP' AND SlittingSize = 200 AND PartNo = '1625' AND id = 12
```

---

### 8.2 Lỗi "Chưa CONFIG trong STB_SLITTINGLOCATIONCONFIG_VVT"

**Triệu chứng:** `"Không tồn tại thiết lập Điện cực của LotNo... Chưa CONFIG trong bảng: STB_SLITTINGLOCATIONCONFIG_VVT"`

**Debug:**
```sql
-- Xem thông số lỗi trong thông báo (VD: PartNo=1025, Farad=10, Width=17.7)
-- Kiểm tra bảng đã có chưa
SELECT * FROM stb_slittinglocationconfig_vvt WHERE PartNo = '1025'
```

**Fix — Thêm cấu hình mới:**
```sql
-- Template: BY = Cực dương (+), YP = Cực âm (-)
INSERT INTO stb_slittinglocationconfig_vvt
    (PartNo, SlittingCode, SlittingSize, Farad, Width, WarehouseLocation, LocationWarehouse)
VALUES
    ('1025', 'BY', '200', '10', '17.7', 'VVT_F2', 'kho2'),  -- Cực dương
    ('1025', 'YP', '180', '10', '17.7', 'VVT_F2', 'kho2')   -- Cực âm

-- Xác nhận đã thêm
SELECT * FROM stb_slittinglocationconfig_vvt WHERE PartNo = '1025'
```

**Template thêm nhiều model cùng lúc:**
```sql
INSERT INTO stb_slittinglocationconfig_vvt
    (PartNo, SlittingCode, SlittingSize, Farad, Width, WarehouseLocation, LocationWarehouse)
VALUES
    ('1025', 'BY', '200', '10', '17.7', 'VVT_F2', 'kho2'),
    ('1025', 'YP', '180', '10', '17.7', 'VVT_F2', 'kho2'),
    ('1325', 'BY', '200', '15', '18.7', 'VVT_F2', 'kho2'),
    ('1325', 'YP', '180', '15', '18.7', 'VVT_F2', 'kho2'),
    ('1030', 'BY', '200', '10', '23.7', 'VVT_F2', 'kho2'),
    ('1030', 'YP', '180', '10', '23.7', 'VVT_F2', 'kho2')

-- Sau đó cập nhật số cuộn và vị trí kho
UPDATE stb_slittinglocationconfig_vvt
SET RollQty = 20, PositiveLocation = 'A6-T3', NegativeLocation = 'B6-T3'
WHERE PartNo IN ('1025', '1325', '1030')
```

---

### 8.3 Checklist khi B597 báo lỗi khi lưu NVL

```
Theo thứ tự SP usp_Vietnam_RawMaterialInputHist_uid kiểm tra:
□ 1. HOLDING? → SELECT MaterialWarehouseCode FROM STB_MaterialLotInfo (Check 'HOLDING_%')
□ 2. Hết hạn? → Truy vấn LotAttr10 từ STB_MaterialDocLotInfo (nếu rỗng và là Lot tách %SP%/%SL%/%SM% thì check trong STB_MaterialLotInfo) + MMExtInt01 (xem KB_02 Mục 4.10)
□ 3. Sai chủng loại? → Kiểm tra BOM có mã NVL đó không (STB_BomDetail)
□ 4. Sai độ dày điện cực? → Kiểm tra MaterialThickness (phải là số nguyên)
□ 5. Sai mã Electrolyte? → Kiểm tra CTE eleclyte1 trong SP
□ 6. Thiếu cấu hình Vỏ Nhôm? → Sửa hardcode trong SP (Bảng AluCaseMapping không tồn tại)
□ 7. Thiếu cấu hình Slitting? → Kiểm tra STB_SLITTINGLOCATIONCONFIG_VVT
```

> 🚦 **Tham chiếu mở rộng:** Toàn bộ 7 gates trên đã được tổng hợp cùng 11 nhóm chặn tương tự (B530, B523, B452, B618, QC Audit, Returns, Lò Sấy, Slitting Knife...) tại **[KB_14 §6 — Tổng Hợp Pattern Validation Gates](../KB_14/KB_14_01_METHODOLOGY.md#6-tổng-hợp-pattern-validation-gates)**. Xem đó để biết cách mở rộng/thêm gate mới theo 4 Pattern thiết kế (A/B/C/D).

---

### 8.4 Logic kho điện cực

```
Mã lot điện cực Slitting: VV... hoặc VJ...
Mã lot kho nguyên liệu: ML...

P (BY) = Cực Dương (+)
M (YP) = Cực Âm (-)

Kiểm tra tồn kho điện cực → **Stb_SlittingStock_VVT**
```

> Điện cực phải dùng mã Lot kho (prefix `ML`) khi nhập kho nguyên liệu.

### 8.5 Lỗi popup không hiện dữ liệu ở B270

👉 **Chi tiết Trace & Fix:** Xem tại [KB_01_UI_PHAN_QUYEN.md § 1.3](KB_01_UI_PHAN_QUYEN.md)

---

### 8.6 Quy trình cân điện cực Mixing & Phần mềm Cân điện cực (electrode.weighing)

#### A. Giới thiệu phần mềm Cân điện cực (`electrode.weighing`):
*   **Mục đích:** Ứng dụng Electron Desktop App dùng để quản lý quá trình cân nguyên liệu (Than hoạt tính, chất dẫn điện, chất kết dính, nước cất...) trước khi cho vào máy trộn (Mixing) để tạo dung dịch Slurry.
*   **Kết nối phần cứng:** Kết nối cổng COM (RS232) đọc số cân trực tiếp từ cân điện tử, chống công nhân nhập tay sai số.
*   **Kết nối Database:** Kết nối trực tiếp đến database `SmartFactoryV2` của Vinatech qua tài khoản `vinaadmin`.
*   **Logic xử lý:** Khi scan mã Lot điện cực, ứng dụng gọi SP `usp_ElectrodeStep_get` (đọc cấu hình bước cân) và `usp_GetElectroMixPresentStep_vietnam` (đọc bước hiện tại) để load công thức và thứ tự bước cân (`Seq`). Khi cân đúng khoảng spec (`StdMinVal` - `StdMaxVal`), phần mềm lưu dữ liệu qua SP `usp_DoCreateElectrodeMixStepInfo_electron` và chốt mẻ trộn để chuyển sang công đoạn tráng phủ (Coating).

#### B. Các lỗi thường gặp và cách khắc phục:

##### 1. Lỗi nhảy bước cân, không cân lần lượt từ trên xuống (Than hoạt tính bị đẩy xuống dưới)
*   **Triệu chứng:** "Các bước cân cứ nhảy không đúng thứ tự process nên không cân được", "Mã điện cực HCE đang lỗi chưa thao tác được, sản xuất ra mà không được ghi nhận trên hệ thống".
*   **Nguyên nhân:** 
    *   Trên giao diện phần mềm có checkbox **"CA ĐÊM CHUẨN BỊ TRƯỚC"** (`isnight`). Ở ca đêm, Binder/CMC cần khuấy trước (20-40 phút) nên hệ thống cung cấp tùy chọn này để đảo thứ tự cân, đưa Binder lên trước Than hoạt tính (SP sẽ nhận tham số `@pOrder = 'kdem'`).
    *   Nếu ca ngày làm việc mà **quên bỏ tích checkbox này**, thứ tự cân sẽ bị nhảy lộn xộn khiến công nhân không thể cân lần lượt từ trên xuống và bị hệ thống chặn. Mẻ trộn bị kẹt không thể chốt hoàn thành, dẫn đến sản phẩm sản xuất ra không được ghi nhận trên MES.
*   **Cách khắc phục:**
    *   *Bước 1 (Vận hành):* Công nhân ca ngày **bỏ tích checkbox "CA ĐÊM CHUẨN BỊ TRƯỚC"** trên giao diện chính của phần mềm, sau đó bấm nút **"Làm mới màn hình"** để quay lại thứ tự cân than trước.
    *   *Bước 2 (IT reset Lot bị kẹt):* Nếu Lot điện cực (Ví dụ: Lot của mã `HCE-202`) đã bị ghi nhận sai thứ tự và kẹt giữa chừng, IT chạy lệnh xóa dữ liệu cân tạm của Lot đó để cân lại đúng từ đầu:
        ```sql
        BEGIN TRANSACTION;
        DELETE FROM STB_ElectrodeMixStepInfo WHERE ElectrodeLotNumber = 'Mã_Lot_Điện_Cực_HCE';
        COMMIT TRANSACTION;
        ```
        *Mẹo:* Có thể dùng 2 Stored Procedures sau để kiểm tra cấu hình và bước cân hiện tại của bến điện cực CMC (kết hợp đọc code JavaScript trong phần mềm):
        ```sql
        -- Kiểm tra bước hiện tại (tham số thứ 2 truyền 'kdem' nếu là ca đêm)
        EXEC usp_GetElectroMixPresentStep_vietnam 'VVQN1620001E28', '';
        
        -- Lấy chi tiết cấu hình bước cân trộn
        EXEC usp_Vietnam_ElectrodeMixingConfig_get 'VVQN1620001E28', '', 'ML20260124000020', '';
        ```

##### 2. Điện cực mã liệu `3582-600F CY` không tạo/in được tem
*   **Triệu chứng:** Khi sản xuất điện cực mã liệu `3582-600F CY`, hệ thống không cho in tem điện cực.
*   **Chi tiết & Giải pháp:** Đây là model mới thiếu cấu hình Slitting. Xem hướng dẫn chi tiết từng bước xử lý và SQL script thêm cấu hình tại [Kịch bản 5](#kịch-bản-sự-cố-khẩn-cấp-5-điện-cực-3582-600f-cy-không-tạo-được-tem).

---

*Cập nhật: 2026-05-26*

---

### 8.7 Tổng Quan Quy Trình Sản Xuất & Kiểm Tra Chất Lượng Điện Cực (Electrode Flow)

Quy trình quản lý sản xuất và kiểm định chất lượng đối với công đoạn Điện cực được vận hành khép kín qua các bước sau:

#### 1. Lập Kế Hoạch & In Tem Điện Cực (B310, B442, A230)
*   **Tạo PO (B310):** Bộ phận kế hoạch khởi tạo đơn đặt hàng sản xuất PO làm căn cứ chạy chuyền.
*   **Tạo Kế hoạch ngày (B442):** Dựa trên PO tháng đã duyệt, kế hoạch ngày được lập trên B442. Khi kế hoạch được xác nhận lưu, hệ thống sẽ tự động sinh mã Lot điện cực và bắt đầu cho phép in tem nhãn.
*   **Liên kết độ dày vật liệu (A230):** Màn hình B442 liên kết trực tiếp với dữ liệu độ dày khai báo tại màn hình **A230 (Thông tin vật liệu)**. Tại tab "Mã nguyên liệu", nếu mã vạch barcode tương ứng đã được cài đặt thông số độ dày hoặc người dùng điền độ dày bên A230, hệ thống sẽ tự động liên kết và điền thông số này vào cột độ dày của B442. Nếu chưa được cấu hình, OP buộc phải nhập thủ công bằng tay (thao tác này dễ gây sai sót và chậm trễ).


*   **Cấu hình in tem Electrode (A460 → STB_ModelLabelInfo):** Để in tem từ B442, model Electrode phải có record trong bảng `STB_ModelLabelInfo`. Nếu thiếu → lỗi **"Not found label type"** khi bấm LabelPrint.

    ```sql
    -- Kiểm tra: SELECT ModelCode, LabelType FROM STB_ModelLabelInfo WHERE ModelCode = 'MÃ_MODEL';
    -- Nếu thiếu → copy từ model cũ cùng loại. Xem KB_04 §6.20 cho SQL chi tiết.
    ```

    > **LabelType phổ biến cho Electrode:** `ElectLabel` (tem điện cực B442), `AssembleLabel` (tem SX B450/B540), `PartLabel` (tem vật tư F330), `BoxLabel2` (tem box đặc biệt).

*   **Checklist thêm model Electrode mới (CRF%):**
    1. A230 → `MaterialThickness` (VD: 120, 180, 200)
    2. A460 → `STB_ModelLabelInfo` (ElectLabel + các label type cần thiết)
    3. B442 → Tạo lot test → kiểm tra cột "Độ dày" + in tem

    > 🔗 Xem thêm: KB_04 §6.20, KB_14 §7.2

#### 2. Vận Hành 4 Công Đoạn Điện Cực & Nhập Liệu trên B552
Quy trình sản xuất điện cực gồm 4 công đoạn chính và mỗi công đoạn tương ứng với một tab dữ liệu trên màn hình **B552**:
1.  **Mixing (Pha trộn):** 
    *   Sử dụng cấu hình cân điện cực thiết lập trên màn **B470** (Thẻ công đoạn do bên Kỹ thuật sản xuất - KTSP thiết lập và ban hành). 
    *   Hệ thống máy CMC sẽ thực hiện cân trộn theo công thức. Tab Mixing trên B552 sẽ tự động lấy dữ liệu từ hệ thống cân CMC sang. OP chỉ cần kiểm tra và nhập số lượng NG phát sinh (nếu có) lên hệ thống.
2.  **Coating (Phủ):** Tráng phủ hỗn hợp dung dịch điện cực lên foil. OP thực hiện nhập lượng phế NG phát sinh.
3.  **Rollpress (Ép):** Ép nén cuộn foil để đạt độ dày tiêu chuẩn và đảm bảo lớp phủ bám đều. OP nhập thông số NG.
4.  **Slitting (Cắt):** Cắt cuộn điện cực lớn thành các cuộn nhỏ theo kích thước spec yêu cầu để chuyển sang chuyền Cell lắp ráp. Tại tab Slitting trên B552, OP sẽ tiến hành tạo tem nhãn và in tem barcode dán lên từng cuộn điện cực sau khi cắt.

#### 3. Báo Cáo & Đối Soát Điện Cực (B802)
*   **B802 (Tra cứu lịch sử sản xuất điện cực):** Tra cứu toàn bộ thông tin sản lượng, phế thải (NG), chi phí sản xuất, và chi phí phế phẩm.
*   **⚠️ Lưu ý lỗi thiếu công đoạn:** Một mã Lot điện cực bắt buộc phải đi qua đầy đủ cả 4 công đoạn (Mixing, Coating, Rollpress, Slitting). Nếu trên báo cáo B802 hiển thị thiếu bất kỳ công đoạn nào, nguyên nhân chắc chắn là do OP quên hoặc chưa nhập đầy đủ dữ liệu công đoạn đó tại màn hình **B552**. Khi tra cứu trên B802, OP click vào một mã Lot cụ thể để hiển thị chi tiết thông số từng công đoạn ở tab phía dưới.
*   **Quy tắc nhập cột số liệu:**
    *   Cột `Defect (KG)`: Do OP nhập thủ công số kg phế thải thực tế cân được.
    *   Cột `Số lượng OK`: Số lượng cuộn/mét điện cực đạt chất lượng được OP nhập vào.
    *   Cột `Số lượng NG`: Số lượng cuộn/mét điện cực lỗi được OP nhập vào. Các cột chỉ số chi phí và tỷ lệ lỗi còn lại sẽ do hệ thống tự động tính theo công thức.

#### 4. Quy Trình Kiểm Tra Chất Lượng QC Điện Cực (C460, C141, C143)
*   Bên cạnh hệ thống cân CMC tự động, bộ phận QC thực hiện kiểm tra ngoại quan và đo đạc kích thước cơ lý của cuộn điện cực.
*   **C460 (Nhập kết quả kiểm tra QC):** Công nhân QC trực tiếp nhập các kết quả đo đạc kiểm tra cuộn điện cực tại đây.
*   **C141 & C143 (Thiết lập hạng mục kiểm tra):** Các hạng mục kiểm tra chung và spec dung sai riêng biệt cho từng model điện cực được định nghĩa trước tại màn hình **C141 (Hạng mục chung)** và **C143 (Spec theo Model)** để làm căn cứ cho C460 validate tự động.

---

### 8.8 Hỗ trợ lưu nhiều mã vạch nguyên vật liệu (Multi-barcode Appending) cho Điện cực và Vỏ Case

*   **Mô tả:** Hệ thống hỗ trợ bắn nối tiếp nhiều cuộn nguyên vật liệu khác nhau (ngăn cách bởi dấu `;`) trên cùng một Lot sản phẩm để tránh trường hợp cuộn cũ hết giữa chừng nhưng Lot chưa chạy xong.
*   **Chi tiết & Giải pháp:** Xem chi tiết về logic kiểm tra và lưu trong SP `usp_Vietnam_RawMaterialInputHist_uid`, cũng như cách gộp hiển thị trên lưới tại [../KB_03/KB_03_02_CELL_LINE.md#619-hỗ-trợ-lưu-nhiều-mã-vạch-nguyên-vật-liệu-multi-barcode-appending-cho-điện-cực-và-vỏ-case](../KB_03/KB_03_02_CELL_LINE.md#619-hỗ-trợ-lưu-nhiều-mã-vạch-nguyên-vật-liệu-multi-barcode-appending-cho-điện-cực-và-vỏ-case).

---

### 8.9 🔴 Lỗi Mất Sản Lượng Đầu Vào (Mixing Input = 0) — BY/YP 120/180 A301 1.5B

> **Phát hiện:** 2026-06-19 | **Ảnh hưởng:** ~1 tháng sản xuất (từ ~26/05/2026)

#### Triệu chứng:
*   Sản xuất gần 1 tháng nhưng trên MES **không có sản lượng đầu vào** (cột "Trọng lượng vật liệu 1/2" = 0).
*   **Có sản lượng đầu ra** (Coating output) → gây sai lệch kiểm kê.
*   Bảng `STB_ElectrodeMixStepInfo` có **0 records** cho các lot prefix `VVQO1812xxx`.
*   Bảng `STB_ElectrodeCoatingInfo` **CÓ records** (VD: E22=270kg, E25=420kg).

#### Models bị ảnh hưởng:

| Model | MaterialCode | Mức độ |
|-------|-------------|--------|
| BY 120 A301 1.5B (+) | `CREBL85L` | 🔴 100% thiếu |
| YP 120 A301 1.5B (-) | `CRFYL85-01` | 🔴 100% thiếu |
| YP 180 A301 1.5B (-) | `CRFYN85L-01` | 🔴 100% thiếu |
| YP 200 1.5B (+) | `CREYO85-03` | ⚠️ Gián đoạn |

#### Nguyên nhân đã loại trừ (DB + SP đều OK):
*   ✅ `STB_ElectrodeStep` — cấu hình bước cân **ĐẦY ĐỦ** (9 bước D/G/K/S) cho cả `CREBL85L` và `CRFYL85-01`.
*   ✅ `usp_DoCreateElectrodeMixStepInfo_electron` — SP ghi data không có validation chặn.
*   ✅ `usp_GetElectroMixPresentStep_vietnam` — trả về đúng bước hiện tại.
*   ✅ `usp_Vietnam_ElectrodeMixingConfig_get` — trả về 5 config giống model hoạt động bình thường.

#### Nguyên nhân gốc — Phần mềm cân NVL Mixing (electrode.weighing):
*   Ứng dụng Electron cài trên **máy CMC nhà máy Bắc Ninh** (KHÔNG phải app `4.8.Warehouse Weight` — đó là cân thành phẩm B523).
*   App cân mixing không gọi hoặc gọi thất bại SP `usp_DoCreateElectrodeMixStepInfo_electron`.

#### Query kiểm tra:
```sql
-- Kiểm tra Lot có mixing data không
SELECT SI.Barcode, SI.MaterialCode,
    CASE WHEN EXISTS (SELECT 1 FROM STB_ElectrodeMixStepInfo M WITH(NOLOCK)
        WHERE M.ElectrodeLotNumber = SI.Barcode) THEN 'YES' ELSE 'NO' END AS HasMixing,
    CASE WHEN EXISTS (SELECT 1 FROM STB_ElectrodeCoatingInfo C WITH(NOLOCK)
        WHERE C.ElectrodeLotNumber = SI.Barcode) THEN 'YES' ELSE 'NO' END AS HasCoating
FROM STB_SetInfo SI WITH(NOLOCK)
WHERE SI.MaterialCode IN ('CREBL85L', 'CRFYL85-01', 'CRFYN85L-01')
    AND SI.CreateDateTime >= '2026-05-20'
ORDER BY SI.CreateDateTime DESC
```

---

