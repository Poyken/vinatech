# 📓 MES_V2 — Hotfix Registry (Lịch Sử Sửa Lỗi Chi Tiết)

> **Mục đích:** Nhật ký lưu trữ chi tiết toàn bộ các bản sửa lỗi và hotfix đã được triển khai thành công trên hệ thống MES Vinatech.

---

### [B781]/[B523]/[HY530] — 📍 ID_31 Chuyển 36 Lô BTP 35105 Từ Bắc Giang Về Hưng Yên (Chia đều Line 1 & Line 2)
* **Ngày sửa:** `2026-08-19`
* **Màn hình liên quan (TCode):** `[B781] - Kiểm tra sản lượng hoàn thành theo Lot (Power BI Backend)`, `[B523] - Đóng gói Cell`, `[HY530] - Route Process Input Hưng Yên`
* **Triệu chứng lỗi:** Bán thành phẩm mẫu `35105` (`ECVT30-357`) chuyển từ Bắc Giang về Hưng Yên làm Ủ $\rightarrow$ Đóng gói không hiển thị và không liên kết được với hệ thống Power BI (màn hình B781).
* **Nguyên nhân gốc (Root Cause):** `STB_SetInfo.InputLineCode` vẫn giữ mã chuyền Bắc Giang (`VVBNTC-01`, `VVBGC-xx`) và `STB_ProdRouteHist.RouteCode` mang mã `V-28_BG`, `V-26_BG`, `V-27_BG`. Khi SP `usp_Vietnam_PackPrintTime_get` lọc theo Nhà máy Hưng Yên (`VVT_F5`), yêu cầu `c.RouteCode = 'V-28_HY'` và mã Line Hưng Yên nên trả về 0 dòng.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  BEGIN TRANSACTION;
  -- Chia đều 18 Lô nhóm 1 sang Line 1 (VVHYC-01) và 18 Lô nhóm 2 sang Line 2 (VVHYC-02)
  UPDATE STB_SetInfo SET InputLineCode = 'VVHYC-01', ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc' WHERE Barcode IN (...18 Lots...);
  UPDATE STB_SetInfo SET InputLineCode = 'VVHYC-02', ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc' WHERE Barcode IN (...18 Lots...);
  UPDATE STB_ProdRouteHist SET RouteCode = 'V-28_HY', ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc' WHERE RouteCode = 'V-28_BG' AND ControlNo IN (...36 ControlNos...);
  UPDATE STB_ProdRouteHist SET RouteCode = 'V-26_HY', ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc' WHERE RouteCode = 'V-26_BG' AND ControlNo IN (...36 ControlNos...);
  UPDATE STB_ProdRouteHist SET RouteCode = 'V-27_HY', ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc' WHERE RouteCode = 'V-27_BG' AND ControlNo IN (...36 ControlNos...);
  COMMIT TRANSACTION;
  ```


### [B530]/[B523]/[HY530] — 📍 ID_30 Lỗi "Công đoạn không có trong Routing" & Chặn Gate Aging 24h khi chuyển Lot về Hưng Yên
* **Ngày sửa:** `2026-08-18`
* **Màn hình liên quan (TCode):** `[B530] - Nhập thực tế sản xuất`, `[HY530] - Route Process Input Hưng Yên`, `[B523] - Đóng gói thùng sản xuất`
* **Triệu chứng lỗi:** Quét Lot bị văng popup đỏ: *"Công đoạn này không có trong Routing hoặc là công đoạn cuối cùng"* hoặc *"Chưa đủ thời gian Aging lão hóa theo quy định"*.
* **Nguyên nhân gốc (Root Cause):** Lệch `RouteCode = 'V-26_BG'` sang `V-26_HY`, `InputLineCode = 'VVBNTC-01'` sang `VVHYC-01`, cờ `CompleteRoute = NULL` bị xung đột giữa các công đoạn dở dang, và autocheck chặn Aging 24 giờ.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  BEGIN TRANSACTION;
  UPDATE STB_SetInfo SET InputLineCode = 'VVHYC-01' WHERE ControlNo IN ('20260619000076', '20260619000077', '20260818000302');
  UPDATE STB_ProdRouteHist SET RouteCode = 'V-26_HY' WHERE RouteCode IN ('V-26', 'V-26_BG') AND ControlNo IN ('20260619000076', '20260619000077', '20260818000302');
  DELETE FROM STB_ProdRouteHist WHERE RouteCode IN ('V-23_HY', 'V-27_HY') AND CompleteRoute IS NULL AND ControlNo IN ('20260818000302');
  UPDATE STB_ProdRouteHist SET CompleteRoute = NULL WHERE RouteCode IN ('V-22_HY', 'V-26_HY') AND ControlNo IN ('20260818000302');
  UPDATE STB_ProdRouteHist SET CreateDateTime = DATEADD(HOUR, -25, GETDATE()) WHERE ControlNo IN ('20260619000076', '20260619000077', '20260818000302');
  COMMIT TRANSACTION;
  ```

---

### [B552] — 📍 ID_29 Xóa 61 bản ghi kết quả cắt điện cực (STT 10-70) cho Lot VVQO2020001E36
* **Ngày sửa:** `2026-08-15`
* **Màn hình liên quan (TCode):** `[B552] - Vietnam_Kết quả đo điện cực (Tab Slitting)`
* **Triệu chứng lỗi:** Cần dọn dẹp các dòng kết quả cắt điện cực dở dang từ STT 10 đến STT 70 cho Lot `VVQO2020001E36`.
* **Nguyên nhân gốc (Root Cause):** Thao tác cắt chia cuộn dư hoặc lỗi dòng kết quả cần xóa bỏ bản ghi lịch sử trong `STB_ElectrodeSlittingResult`.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  BEGIN TRANSACTION;
  DELETE FROM STB_ElectrodeSlittingResult WHERE ElectrodeLotNumber = 'VVQO2020001E36' AND Seq BETWEEN 10 AND 70;
  COMMIT TRANSACTION;
  ```

---

### [B523] — 📍 ID_28 Popup "Could not find Kho Thành phẩm chưa nhập cân nặng" sau B351 chuyển đổi Lot
* **Ngày sửa:** `2026-08-15`
* **Màn hình liên quan (TCode):** `[B523] - Đóng gói Cell & [B351] - Lot Transition`
* **Triệu chứng lỗi:** Chuyển đổi Lot tại B351 sang `VVQQ143R850605`. Ra B523 bấm in tem thì bật popup đỏ: `Could not find Kho Thành phẩm chưa nhập cân nặng cho Lót hàng này!`.
* **Nguyên nhân gốc (Root Cause):** B351 không tự nạp cân Barcode vào `STB_VIETNAM_BARCODEWEIGHT` và cân kho `STB_VN_FINISHGOODS`. SP `usp_Vietnam_GetBoxIDForLotNo_VVT` tính `@lotweight = 0` ➔ gán `FormatName = N'Kho Thành phẩm chưa nhập cân nặng...'`.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  BEGIN TRANSACTION;
  INSERT INTO STB_VIETNAM_BARCODEWEIGHT (BARCODE, WEIGHT, CREATEDATETIME) VALUES ('VVQQ143R850605', 25.5, GETDATE());
  INSERT INTO STB_VN_FINISHGOODS (IDCODE, PackingID, LotNo, MaterialCode, MaterialName, PackQty, EmpNo, CreatDatePacked, PartNo, CreateDate)
  VALUES ('FGVN_BN' + REPLACE(CONVERT(VARCHAR(10), GETDATE(), 112), '-', ''), 'PKQQ1500133', 'VVQQ143R850605', 'LIVT38-018', 'VEL08253R8506G-B034', 2800, 'vvtworker_BG', CONVERT(VARCHAR(10), GETDATE(), 110), 'VEL08253R8506G-B034', GETDATE());
  UPDATE STB_ChangePartNoAndLotNo SET NewLotID = 'VVQQ143R850605' WHERE oldLotID = 'VVPN263R850606';
  UPDATE STB_LotChangeMaterialHistory SET OldBarcode = 'VVPN263R850606' WHERE NewBarcode = 'VVQQ143R850605';
  UPDATE STB_MaterialLotInfo SET LotNo = 'VVQQ143R850605' WHERE PackingID = 'PKQQ1500133';
  UPDATE STB_PackingLabelPrintHist SET IsPrintAllow = 1, PrintCount = 0 WHERE PackingID = 'PKQQ1500133';
  COMMIT TRANSACTION;
  ```

---

### [HN523] — 📍 ID_27 Hủy tem đóng gói PKQQ1400141 & Giảm sản lượng VE10 + PO
* **Ngày sửa:** `2026-08-14`
* **Màn hình liên quan (TCode):** `[HN523] - Đóng gói Hà Nam`
* **Triệu chứng lỗi:** Cần hủy tem đóng gói `PKQQ1400141` (Lot `VE260804-002`, SL 984 con) để rã Lot và đóng gói lại tại HN523.
* **Nguyên nhân gốc (Root Cause):** Đóng gói nhầm tem. Trigger `tgMaterialDocDetailForDelete` kiểm tra `DocStatus` ➔ Cần chuyển `DocStatus = 'CREATE'` và đặt `CONTEXT_INFO 0x999997`.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  BEGIN TRANSACTION;
  UPDATE STB_MaterialLotInfo SET PackingID = '' WHERE LotID = '16VHVL180MC6XXVC01QQ1400005' OR PackingID = 'PKQQ1400141';
  DELETE FROM STB_SavePackingTime_VVT WHERE PackingID = 'PKQQ1400141';
  UPDATE STB_MaterialDocInfo SET DocStatus = 'CREATE', IsCancel = 0 WHERE MaterialDocNo = '260814000155';
  SET CONTEXT_INFO 0x999997;
  DELETE FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '260814000155';
  SET CONTEXT_INFO 0;
  DELETE FROM STB_MaterialDocDetail WHERE MaterialDocNo = '260814000155';
  UPDATE STB_MaterialDocInfo SET IsCancel = 1, CancelDateTime = GETDATE(), CancelUserID = 'vanduc' WHERE MaterialDocNo = '260814000155';
  UPDATE STB_ProdRouteHist SET ProdQty = ProdQty - 984 WHERE ControlNo = '20260804000078' AND RouteCode = 'VE10';
  UPDATE STB_ProductionOrderInfo SET ProdFinishQty = ProdFinishQty - 984 WHERE PONo = '260804000007';
  COMMIT TRANSACTION;
  ```

---

### [B540]/[K361] — 📍 ID_26 Model Nordex hoàn thành công đoạn ND08 theo chuẩn K361
* **Ngày sửa:** `2026-08-08`
* **Màn hình liên quan (TCode):** `[B540] - Quét NVL & [K361] - Hoàn thành công đoạn BG2`
* **Triệu chứng lỗi:** Model Nordex (`EDVTMD-246`) cần hoàn thành công đoạn `ND08`. Dòng `ND08` hiển thị `Chưa hoàn thành` và tạm gắn tên công nhân làm `ND07`.
* **Nguyên nhân gốc (Root Cause):** Chuẩn nghiệp vụ BG2: `IsOutputRoute` giữ nguyên `NULL` (không set = 1). K361 gọi `usp_CompleteRouteFinalForBacGiang2` để chốt `CompleteRoute = 1`.
* **Phương án sửa lỗi (SQL Action):**
  ```sql
  UPDATE PRH
  SET PRH.CompleteRoute = 1, PRH.ProdDateTime = GETDATE(), PRH.ChangeDateTime = GETDATE(), PRH.ChangeUserID = '32606011'
  FROM STB_ProdRouteHist PRH
  INNER JOIN STB_SetInfo SI ON PRH.ControlNo = SI.ControlNo
  WHERE SI.MaterialCode = 'EDVTMD-246' AND PRH.RouteCode = 'ND08' AND (PRH.CompleteRoute IS NULL OR PRH.CompleteRoute <> 1);
  ```

---

### [HN544] — 📍 ID_21 Hủy gộp box / Rã box túi bóng ở màn hình HN544
* **Ngày sửa:** `2026-07-30`
* **Màn hình liên quan (TCode):** `[HN544] - Gộp túi bóng thành hộp nhỏ`
* **Triệu chứng lỗi:** Cần hủy gộp mã Packing `PK20260730000000004` giải phóng các Lot con.
* **Nguyên nhân gốc (Root Cause):** Gộp nhầm box hoặc thao tác hủy trên giao diện UI bị chặn/lỗi.
* **Phương án sửa lỗi (SQL Patch / Action):**
  ```sql
  BEGIN TRANSACTION;
  UPDATE STB_MaterialLotInfo SET PackingID = NULL WHERE PackingID = 'PK20260730000000004';
  DELETE FROM STB_DividePackaging WHERE PackingID = 'PK20260730000000004';
  COMMIT TRANSACTION;
  ```

### [B552] - CREYO85-04 model 3562 bi nhan doi dong va hien HCE/YP tren B552, san luong x2 tren B802
- Date: 2026-08-18
- TCode: B552
- Symptom: CREYO85-04 model 3562 bi nhan doi dong va hien HCE/YP tren B552, san luong x2 tren B802
- Root Cause: SP usp_ElectrodeSlittingResult_get so khop LIKE '%YP%' dinh SlittingCode HCE/YP; SP usp_Vietnam_ElectrodeProdRouteHist_get hardcode chia 5 cho CREYO85-04
- SQL Fix:
```sql
Chuan hoa matching logic trong usp_ElectrodeSlittingResult_get va loai CREYO85-04 khoi danh sach chia 5 trong usp_Vietnam_ElectrodeProdRouteHist_get
```


### [FG20] - Search failed: 실행 제한 시간을 초과했습니다 (SQL Execution Timeout)
- Date: 2026-08-19
- TCode: FG20
- Symptom: Search failed: 실행 제한 시간을 초과했습니다 (SQL Execution Timeout)
- Root Cause: SP usp_FinishGoodAllFactoryReport quet toan bo 625,000+ dong voi UDF fnPharseLotNo va nested subqueries
- SQL Fix:
```sql
Chuyen sang kien truc Temp Table (#BN_Base, #BN_Aging, #BG_Base, #BG_Aging, #HY_Base, #HY_Aging) giam thoi gian tu >60s xuong <5s
```

