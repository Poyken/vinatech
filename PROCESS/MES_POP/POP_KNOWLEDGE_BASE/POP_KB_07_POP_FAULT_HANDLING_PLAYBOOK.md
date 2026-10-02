<!--
AI-READY METADATA
Purpose: Cẩm nang xử lý sự cố hệ thống POP Kiosk Vinatech (Bản chuẩn hóa thực chiến từ EA Team)
Authors: Nguyễn Văn Đức (vanduc) & Hải Triều (EA Team)
Source Document: HƯỚNG DẪN XỬ LÝ HỆ THỐNG POP KHI GẶP LỖI.docx (E:\Group Sharing\EA team\Hải Triều)
Single Source of Truth: POP_KB_07_POP_FAULT_HANDLING_PLAYBOOK.md
Target Tables: STB_SetInfo, STB_DayProdPlan, STB_MaterialMaster, STB_MaterialLotInfo, STB_ProdRouteHist, MongoToMesPerformance, STB_CommInspDocHistory, STB_ElectrodeSlittingResult, VINATECH_POP.dbo.VINA_GROUP_INPUT_ROUTE, VINATECH_POP.dbo.VINA_BOM_INPUT_ROUTE
Related Files:
  - [POP_KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md)
  - [POP_KB_03_TROUBLESHOOTING.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md)
  - [POP_MATRIX.json](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/AI_AGENT_CONFIG/POP_MATRIX.json)
-->

# POP_KB_07 — Cẩm Nang Xử Lý Hệ Thống POP Khi Gặp Lỗi (EA Fault Handling Playbook)

> **Hệ thống:** POP Kiosk Xưởng Sản Xuất Vinatech (`https://pop.vinatech.com/`) & Core MES WinForm  
> **Tác giả & Vận hành:** Nguyễn Văn Đức (`vanduc`) & Hải Triều (EA Team)  
> **Nguyên tắc cốt lõi:** Luôn bọc Transaction (`BEGIN TRAN...ROLLBACK`), tác giả ghi nhận `Author = 'vanduc'` / `ChangeUserID = 'vanduc'`, tuân thủ Rule 20 (EA Playbook) & Rule 22 (Định danh sự cố là POP).  
> **Công cụ điều phối nhanh:** `.\pop.ps1 trace "<Lot>"`, `.\pop.ps1 nvl "<Lot>"`, `.\pop.ps1 unlock "<Machine>"`

---

## MỤC LỤC TỔNG QUAN

- [PHẦN I: 14 BẢNG CƠ BẢN TRONG MES & POP](#phần-i-14-bảng-cơ-bản-trong-mes--pop)
- [PHẦN II: 26 KỊCH BẢN XỬ LÝ LỖI HIỆN TRƯỜNG THỰC TẾ](#phần-ii-26-kịch-bản-xử-lý-lỗi-hiện-trường-thực-tế)
  - [Mục 01: Cắt Đóng Gói Điện Cực Báo Sai Line (Bắc Ninh yêu cầu Line ElectrodeBN)](#mục-01-cắt-đóng-gói-điện-cực-báo-sai-line-bắc-ninh-yêu-cầu-line-electrodebn)
  - [Mục 02: Chưa Thêm Mã Lỗi Ứng Với Từng Công Đoạn (Clone STB_DefectInfo)](#mục-02-chưa-thêm-mã-lỗi-ứng-với-từng-công-đoạn-clone-stb_defectinfo)
  - [Mục 03: Lỗi Dùng MES Rồi Quay Sang Dùng POP (Xung Đột CompleteRoute 1 vs NULL)](#mục-03-lỗi-dùng-mes-rồi-quay-sang-dùng-pop-xung-đột-completeroute-1-vs-null)
  - [Mục 04: Lỗi Chặn Nạp Cuộn Điện Cực (Ràng Buộc Tối Đa 2 Đến 3 LOTNO)](#mục-04-lỗi-chặn-nạp-cuộn-điện-cực-ràng-buộc-tối-đa-2-đến-3-lotno)
  - [Mục 05: Không Thể Đóng Gói Được Do Báo Không Có Kho (Thiết Lập Màn Hình B230)](#mục-05-không-thể-đóng-gói-được-do-báo-không-có-kho-thiết-lập-màn-hình-b230)
  - [Mục 06: Hạng Mục Tự Kiểm PQC In-Line Thiết Lập Nhầm Công Đoạn (C141 + CommInspDocItem)](#mục-06-hạng-mục-tự-kiểm-pqc-in-line-thiết-lập-nhầm-công-đoạn-c141--comminspdocitem)
  - [Mục 07: Báo Hết Tồn Kho Nguyên Vật Liệu (3 Trường Hợp Xử Lý)](#mục-07-báo-hết-tồn-kho-nguyên-vật-liệu-3-trường-hợp-xử-lý)
  - [Mục 08: Tìm Kiếm Tồn Kho Điện Cực Khi Không Quét Được Mã Barcode](#mục-08-tìm-kiếm-tồn-kho-điện-cực-khi-không-quét-được-mã-barcode)
  - [Mục 09: Tạo Cưỡng Chế Tồn Kho Điện Cực (Force Slitting Roll Stock 3 Bước)](#mục-09-tạo-cưỡng-chế-tồn-kho-điện-cực-force-slitting-roll-stock-3-bước)
  - [Mục 10: Thiết Lập Cấu Hình Slot NVL CellLine Trong CSDL VINATECH_POP](#mục-10-thiết-lập-cấu-hình-slot-nvl-cellline-trong-csdl-vinatech_pop)
  - [Mục 11: Phân Quyền Hủy Đóng Gói Box Và Hủy Hoàn Thành Công Đoạn (Rollback)](#mục-11-phân-quyền-hủy-đóng-gói-box-và-hủy-hoàn-thành-công-đoạn-rollback)
  - [Mục 12: Nguyên Vật Liệu Thay Thế Trong Định Mức BOM (Delegate Material)](#mục-12-nguyên-vật-liệu-thay-thế-trong-định-mức-bom-delegate-material)
  - [Mục 13: Lỗi Ấn Nhầm Sang Chế Độ (+) Nhập Lượng Hoàn Thành Thay Vì (-) Phế Phẩm](#mục-13-lỗi-ấn-nhầm-sang-chế-độ--nhập-lượng-hoàn-thành-thay-vì---phế-phẩm)
  - [Mục 14: MES Tự Sinh Công Đoạn Kế Tiếp Khi POP Chưa Chốt](#mục-14-mes-tự-sinh-công-đoạn-kế-tiếp-khi-pop-chưa-chốt)
  - [Mục 15: Lỗi Chưa Lưu Độ Nhớt Tại Công Đoạn Trộn (Mixing)](#mục-15-lỗi-chưa-lưu-độ-nhớt-tại-công-đoạn-trộn-mixing)
  - [Mục 16: Lỗi Gán Nhầm Mã Máy Khi Chốt Sản Lượng (RULE 20: Atomic 2 Bảng)](#mục-16-lỗi-gán-nhầm-mã-máy-khi-chốt-sản-lượng-rule-20-atomic-2-bảng)
  - [Mục 17: Nút Cắt Điện Cực Bị Mờ Không Sáng (RULE 20: Khóa Dưới 100um)](#mục-17-nút-cắt-điện-cực-bị-mờ-không-sáng-rule-20-khóa-dưới-100um)
  - [Mục 18: Kiểm Tra Cực Tính Điện Cực Trong Master/BOM (+/-)](#mục-18-kiểm-tra-cực-tính-điện-cực-trong-masterbom--)
  - [Mục 19: Không Tìm Thấy Mã NVL Từ Trụ Sở Khi Ấn Tồn Kho Để Cắt (Kho ROUTE)](#mục-19-không-tìm-thấy-mã-nvl-từ-trụ-sở-khi-ấn-tồn-kho-để-cắt-kho-route)
  - [Mục 20: Quản Lý Cấp Chất Lượng (Grade) Khi Đóng Gói Model 35105 (Quan Hệ 3 Bảng)](#mục-20-quản-lý-cấp-chất-lượng-grade-khi-đóng-gói-model-35105-quan-hệ-3-bảng)
  - [Mục 21: Thừa NVL Do Thêm Vật Tư Thay Thế (Bảng VINA_BOM_INPUT_ROUTE)](#mục-21-thừa-nvl-do-thêm-vật-tư-thay-thế-bảng-vina_bom_input_route)
  - [Mục 22: Cùng 1 Model Nhưng Nạp NVL Khác Nhau Do Chưa Thiết Lập GROUP](#mục-22-cùng-1-model-nhưng-nạp-nvl-khác-nhau-do-chưa-thiết-lập-group)
  - [Mục 23: Điện Cực Báo Chưa Cắt Nhưng Hết Số Lượng (Báo Phế Nhầm)](#mục-23-điện-cực-báo-chưa-cắt-nhưng-hết-số-lượng-báo-phế-nhầm)
  - [Mục 24: Báo Đã Hoàn Thành Trên MES Nhưng Thực Tế Đã Xong Trên POP](#mục-24-báo-đã-hoàn-thành-trên-mes-nhưng-thực-tế-đã-xong-trên-pop)
  - [Mục 25: Dung Dịch, Giấy, Tape Báo Hết Tồn (Đối Soát & Cân Bằng Định Mức BOM)](#mục-25-dung-dịch-giấy-tape-báo-hết-tồn-đối-soát--cân-bằng-định-mức-bom)
  - [Mục 26: Nhập Điện Cực Trụ Sở Về Xưởng Không Tìm Thấy (Thiếu Xuất Kho ROUTE)](#mục-26-nhập-điện-cực-trụ-sở-về-xưởng-không-tìm-thấy-thiếu-xuất-kho-route)

---

## PHẦN I: 14 BẢNG CƠ BẢN TRONG MES & POP

| STT | Tên Bảng | Ý Nghĩa Chức Năng | Các Cột Trọng Yếu Cần Chú Ý |
|:---:|:---|:---|:---|
| **1** | `STB_SetInfo` | Thông tin định danh Lot sản phẩm | - `Barcode`: Mã vạch Lot<br>- `IsProdFinish`: Đóng gói đủ số lượng = 1 (mặc định = 0)<br>- `ProdQty`: Sản lượng thực tế<br>- `SIExtText07`: Lưu mã Marking ở công đoạn bọc vỏ |
| **2** | `STB_DayProdPlan` | Kế hoạch sản xuất theo ngày | - `LineCode`: Mã dây chuyền<br>- `PONo`: Mã chỉ thị sản xuất<br>- `MaterialCode`: Mã thành phẩm/BTP<br>- `IsFixed`: **BẮT BUỘC = 1** mới tạo được Lot |
| **3** | `STB_MaterialMaster` | Master dữ liệu nguyên vật liệu & BTP | - `MaterialCode`: Mã vật tư<br>- `MaterialName`: Tên vật tư (chứa cực tính +/-)<br>- `MaterialThickness`: Độ dày điện cực (khóa nút cắt nếu < 100)<br>- `ProductGroupCode`: Nhóm sản phẩm (cực kỳ quan trọng để map NVL vào Slot)<br>- `PlusMinus`: Cực tính âm (-) hoặc dương (+) |
| **4** | `STB_MaterialQcInfo` | Kết quả kiểm tra chất lượng IQC, OQC | - `MaterialQcNo`: Mã vạch barcode kiểm tra<br>- `DecisionResult`: Kết quả (PASS/FAIL)<br>- `PickingQty`: Số lượng lấy mẫu IQC |
| **5** | `STB_MaterialQcDetail` | Chi tiết từng hạng mục kiểm tra QC | - `SampleQty`: Số lượng mẫu mục tiêu cần đo |
| **6** | `STB_MaterialQcSampleResult` | Kết quả đo thực tế của từng mẫu | - Giá trị đo từng lần, trạng thái đánh giá mẫu |
| **7** | `STB_QcInspectionItem` | Danh mục hạng mục kiểm tra chuẩn | - Mã hạng mục, tên tiêu chuẩn kiểm tra |
| **8** | `STB_MaterialQcInspectionItem` | Cấu hình hạng mục kiểm tra theo Model | - Model áp dụng, InspectionLevel, chuẩn AQL |
| **9** | `STB_InspectionLevel` | Bảng tra cỡ mẫu chuẩn ANSI/AQL | - `InspectionLevel`, dải sản lượng `MinGrQty ~ MaxGrQty` ➔ `SampleQty` |
| **10** | `STB_CommInspTypeInfo` | Danh mục các loại kiểm tra In-Line | - Phân loại tự kiểm tra công đoạn PQC |
| **11** | `STB_CommInspItem` | Danh sách hạng mục kiểm tra chung | - Mã chỉ tiêu đo kiểm (kích thước, ngoại quan, lực kéo) |
| **12** | `STB_CommInspIndividualSpec` | Quy cách Spec riêng theo từng vật tư | - Giới hạn trên (USL), giới hạn dưới (LSL), chuẩn Target |
| **13** | `STB_CommInspMeasureHist` | Lịch sử các lần đo kiểm tra thực tế | - Lưu kết quả từng lần công nhân đo trên Kiosk |
| **14** | `VINA_QC_DECISION_HIST` | Lịch sử đánh giá kết quả kiểm tra trên POP | - Lưu phán định cuối cùng khi kiểm tra qua Web POP |

---

## PHẦN II: 26 KỊCH BẢN XỬ LÝ LỖI HIỆN TRƯỜNG THỰC TẾ

### Mục 01: Cắt Đóng Gói Điện Cực Báo Sai Line (Bắc Ninh yêu cầu Line ElectrodeBN)
- **Hiện tượng:** Tại màn hình Cắt/Đóng gói điện cực nhà máy Bắc Ninh, OP thao tác chọn Line nhưng hệ thống báo lỗi không hợp lệ.
- **Root Cause:** Logic hệ thống POP quy định riêng cho nhà máy Bắc Ninh: bắt buộc Line cắt điện cực phải là `ElectrodeBN`. Nếu Lot được tạo với `LineCode` khác trong Kế hoạch ngày (`STB_DayProdPlan`) sẽ bị chặn.
- **Cách OP tự xử lý:** Báo Quản đốc kiểm tra lại Lệnh sản xuất xem có đang chọn nhầm Line khác không.
- **SQL Hotfix:**
  ```sql
  -- 1. Kiểm tra DayPlanNo và LineCode hiện tại
  SELECT SI.Barcode, SI.DayPlanNo, DPP.LineCode, DPP.MaterialCode
  FROM SmartFactoryV2.dbo.STB_SetInfo SI WITH(NOLOCK)
  INNER JOIN SmartFactoryV2.dbo.STB_DayProdPlan DPP WITH(NOLOCK) ON DPP.DayPlanNo = SI.DayPlanNo
  WHERE SI.Barcode = 'VVQP1420001E08';

  -- 2. Cập nhật lại LineCode đúng chuẩn Bắc Ninh
  BEGIN TRAN;
  UPDATE SmartFactoryV2.dbo.STB_DayProdPlan
  SET LineCode = 'ElectrodeBN', ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc'
  WHERE DayPlanNo = (SELECT DayPlanNo FROM SmartFactoryV2.dbo.STB_SetInfo WHERE Barcode = 'VVQP1420001E08');
  COMMIT;
  ```

---

### Mục 02: Chưa Thêm Mã Lỗi Ứng Với Từng Công Đoạn (Clone STB_DefectInfo)
- **Hiện tượng:** Kiosk báo lỗi không có danh mục mã lỗi khi công nhân bấm vào phân hệ phế phẩm tại công đoạn mới (vd: Slitting Hưng Yên `V-11_HY`).
- **Root Cause:** Công đoạn mới chưa được đăng ký trong `STB_DefectGroup`, hoặc chưa clone danh mục mã phế từ công đoạn chuẩn sang `STB_DefectInfo`.
- **SQL Hotfix:**
  ```sql
  BEGIN TRAN;
  -- 1. Đăng ký nhóm lỗi cho công đoạn mới
  IF NOT EXISTS (SELECT 1 FROM SmartFactoryV2.dbo.STB_DefectGroup WHERE DefectGroupCode = 'V-11_HY')
  BEGIN
      INSERT INTO SmartFactoryV2.dbo.STB_DefectGroup (DefectGroupCode, BasicDefectGroupName, IsUsed, CreateUserID, CreateDateTime)
      VALUES ('V-11_HY', 'SLITTING_HY', 1, 'vanduc', GETDATE());
  END

  -- 2. Clone mã lỗi từ nhóm chuẩn V-11 sang V-11_HY
  INSERT INTO SmartFactoryV2.dbo.STB_DefectInfo (
      DefectCode, BasicDefectName, DefectDesc, DefectGroupCode, UseGroup, DisplayIndex,
      IsRealDefect, IsUsed, DefectImage, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID,
      DirectlyUnder, WorkCenterCode, DefectCause, DefectEnglishName
  )
  SELECT
      REPLACE(DefectCode, 'V-11_', 'V-11_HY_'),
      BasicDefectName,
      DefectDesc,
      'V-11_HY',
      UseGroup,
      DisplayIndex,
      IsRealDefect,
      IsUsed,
      DefectImage,
      GETDATE(),
      'vanduc',
      NULL,
      NULL,
      DirectlyUnder,
      WorkCenterCode,
      DefectCause,
      DefectEnglishName
  FROM SmartFactoryV2.dbo.STB_DefectInfo WITH(NOLOCK)
  WHERE DefectGroupCode = 'V-11'
    AND REPLACE(DefectCode, 'V-11_', 'V-11_HY_') NOT IN (
        SELECT DefectCode FROM SmartFactoryV2.dbo.STB_DefectInfo WHERE DefectGroupCode = 'V-11_HY'
    );
  COMMIT;
  ```

---

### Mục 03: Lỗi Dùng MES Rồi Quay Sang Dùng POP (Xung Đột CompleteRoute 1 vs NULL)
- **Hiện tượng:** POP Kiosk báo `This route is already completed in MES` khi công nhân quét Lot vào làm việc.
- **Root Cause:** Khi hoàn thành 1 công đoạn trên MES WinForm, MES tự động sinh 1 dòng ở công đoạn kế tiếp với `CompleteRoute = 1`. Ngược lại, POP Kiosk chỉ sinh dòng hoàn thành với `CompleteRoute = NULL`. Khi chuyển từ MES sang POP, POP thấy đã có sẵn bản ghi nên chặn lại.
- **SQL Hotfix:**
  ```sql
  -- 1. Tìm bản ghi sinh thừa ở công đoạn kế tiếp (RouteCode = 'V-23')
  SELECT ProdRouteHistNo, ControlNo, RouteCode, CompleteRoute, CreateDateTime
  FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
  WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WHERE Barcode = 'vvqq283r072712')
    AND RouteCode = 'V-23';

  -- 2. Xóa bản ghi thừa trong WorkerHist và ProdRouteHist
  BEGIN TRAN;
  DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteWorkerHist 
  WHERE ProdRouteHistNo = '<ProdRouteHistNo_Lấy_Được>';

  DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteHist 
  WHERE ProdRouteHistNo = '<ProdRouteHistNo_Lấy_Được>';
  COMMIT;
  ```

---

### Mục 04: Lỗi Chặn Nạp Cuộn Điện Cực (Ràng Buộc Tối Đa 2 Đến 3 LOTNO)
- **Hiện tượng:** OP quét nạp cuộn điện cực vào máy thì Kiosk báo `This roll has already been used for 2 product LOTs. Input blocked`.
- **Root Cause:** Cấu hình nghiệp vụ giới hạn 1 mã cắt cuộn BTP điện cực chỉ được nạp tối đa vào 2 LOTNO sản phẩm (đang được nâng cấp lên 3 LOTNO).
- **Cách OP tự xử lý:** Đổi sang cuộn điện cực mới còn tồn kho. Không cố quét ép cuộn đã dùng đủ định mức 2-3 LOT.

---

### Mục 05: Không Thể Đóng Gói Được Do Báo Không Có Kho (Thiết Lập Màn Hình B230)
- **Hiện tượng:** Công đoạn đóng gói Kiosk báo không tìm thấy kho đích để nhập kho thành phẩm.
- **Root Cause:** Dây chuyền (CellLine) chưa được cấu hình liên kết công đoạn đóng gói với kho trong hệ thống Master MES.
- **Cách xử lý:** Đăng nhập MES WinForm -> Màn hình `B230` (Thiết lập quy trình dây chuyền) -> Gán công đoạn và kho đóng gói cho CellLine (tham khảo cấu hình chuẩn tại Line thủ công `TX1`).

---

### Mục 06: Hạng Mục Tự Kiểm PQC In-Line Thiết Lập Nhầm Công Đoạn (C141 + CommInspDocItem)
- **Hiện tượng:** Biên bản tự kiểm tra hiển thị nhầm các mã hạng mục kiểm tra (`V_H1_HY`, `V_H2_HY`, `V_WA_HY`) tại công đoạn không tương ứng.
- **Cách xử lý:**
  1. Vào màn hình `C141` trên WinForm để cập nhật lại cấu hình công đoạn cho các mã kiểm tra.
  2. Chạy Hotfix cập nhật lại tài liệu đo đã sinh cho Lot:
  ```sql
  BEGIN TRAN;
  UPDATE DI 
  SET DI.RouteCode = 'V-24_HY', DI.ChangeDateTime = GETDATE(), DI.ChangeUserID = 'vanduc'
  FROM SmartFactoryV2.dbo.STB_CommInspDocItem DI 
  INNER JOIN SmartFactoryV2.dbo.STB_CommInspDocHistory DH ON DH.CommInspDocNo = DI.CommInspDocNo 
  INNER JOIN SmartFactoryV2.dbo.STB_SetInfo SI ON SI.ControlNo = DH.ProdNo 
  WHERE SI.Barcode = 'VVQR163R825713' 
    AND DI.CommInspItemCode IN ('V_H1_HY', 'V_H2_HY', 'V_WA_HY');
  COMMIT;
  ```

---

### Mục 07: Báo Hết Tồn Kho Nguyên Vật Liệu (3 Trường Hợp Xử Lý)
- **Hiện tượng:** Kiosk báo hết tồn kho khi OP quét nạp NVL vào Slot.
- **3 Trường hợp chẩn đoán & xử lý:**
  - **TH1 (Có NVL thay thế trong BOM):** Hướng dẫn OP chạm vào icon [Nguyên vật liệu thay thế 🔄] trên Kiosk để chọn mã tương đương.
  - **TH2 (Hàng sản xuất liên xưởng Bắc Ninh - Hưng Yên):** Cần làm thủ tục chuyển kho và đổi kho nạp trên hệ thống.
  - **TH3 (Hết tồn kho thực tế):** Kiểm tra `STB_MaterialLotInfo`:
    ```sql
    SELECT LotID, MaterialCode, InitialQty, CurrentQty, MaterialWarehouseCode
    FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
    WHERE LotID = 'ML20260331000035';
    ```
    Nếu `CurrentQty = 0`: Kiểm tra xem kho đã xuất NVL trên màn hình WinForm `F430` chưa, hoặc cấp bổ sung mã NVL mới.

---

### Mục 08: Tìm Kiếm Tồn Kho Điện Cực Khi Không Quét Được Mã Barcode
- **Hiện tượng:** Cuộn điện cực bị rách tem, mờ mã vạch hoặc scanner Kiosk kén mã.
- **Quy trình:** Sử dụng tính năng "Tìm kiếm tồn kho điện cực thủ công" trên Kiosk POP.
- **Điều kiện để cuộn hiển thị trên Modal tìm kiếm:**
  - `CompanyCode = 'VVT'`
  - `IsSlitting = 1`
  - `LotAttr01 = 'SLITTING'`
  - `CurrentQty > 0`
  - `MaterialWarehouseCode = 'ROUTE_VN_WH'` (hoặc kho chuyền)
  - Khớp cực tính âm (-) hoặc dương (+) trong `STB_MaterialMaster`.

---

### Mục 09: Tạo Cưỡng Chế Tồn Kho Điện Cực (Force Slitting Roll Stock 3 Bước)
- **Áp dụng:** Khi cuộn điện cực thực tế có tại chuyền nhưng chưa có trong `STB_MaterialLotInfo` hoặc tem bị hỏng hoàn toàn.
- **Quy trình 3 bước chuẩn mực:**

#### Bước 0: Xác định cuộn dựa vào Base Lot (`ElectrodeLotNumber`):
```sql
DECLARE @baseLot varchar(50) = 'VWQO2720001E03'; -- Base Lot xẻ màng

SELECT ESR.Barcode, ESR.Seq, ESR.SlittingWidth AS WidthMm, ESR.ElectrodeThick AS ThickUm, ESR.GoodQtyLength AS LengthM,
       DPP.MaterialCode AS BaseCoatingCode, RTRIM(ISNULL(BaseMM.PlusMinus,'')) AS BasePM,
       ESR.SlittingMaterialCode, RTRIM(ISNULL(SlitMM.PlusMinus,'')) AS SlitPM,
       CASE WHEN SlitMM.MaterialCode IS NOT NULL AND NULLIF(RTRIM(SlitMM.PlusMinus),'') = NULLIF(RTRIM(BaseMM.PlusMinus),'')
            THEN ESR.SlittingMaterialCode ELSE DPP.MaterialCode END AS ResolvedMaterialCode,
       CASE WHEN EXISTS (SELECT 1 FROM STB_MaterialLotInfo M2 WITH(NOLOCK) WHERE M2.LotID = ESR.Barcode) THEN 'Y' ELSE 'N' END AS AlreadyInMLI,
       CASE WHEN EXISTS (SELECT 1 FROM STB_RawMaterialInputHist H WITH(NOLOCK)
                         WHERE H.RawMaterialInputHistNo >= CONVERT(varchar(8), DATEADD(MONTH, -3, GETDATE()), 112) + '000000'
                           AND H.Status = 'ACTIVE'
                           AND (H.LotMaterialCode = ESR.Barcode OR (H.InputType = 'MES' AND H.RawMaterialBarcode LIKE '%' + ESR.Barcode + '%')))
            THEN 'Y' ELSE 'N' END AS InputHist
FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK)
INNER JOIN STB_SetInfo SI WITH(NOLOCK) ON SI.Barcode = ESR.ElectrodeLotNumber
INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK) ON DPP.DayPlanNo = SI.DayPlanNo
LEFT  JOIN STB_MaterialMaster BaseMM WITH(NOLOCK) ON BaseMM.MaterialCode = DPP.MaterialCode
LEFT  JOIN STB_MaterialMaster SlitMM WITH(NOLOCK) ON SlitMM.MaterialCode = ESR.SlittingMaterialCode
WHERE ESR.ElectrodeLotNumber = @baseLot AND ESR.CompanyCode = 'VVT'
ORDER BY ESR.Seq;
```

#### Bước 1: Cấp số tự động qua `STB_SerialRule` và tạo tồn kho:
```sql
DECLARE @rollBarcode   varchar(50) = 'VWQO2720001E03-001';
DECLARE @warehouseCode varchar(20) = 'ROUTE_VN_WH';

BEGIN TRAN;
DECLARE @matCode varchar(50), @lengthM numeric(13,3), @electrodeLot varchar(50), @wcCode varchar(20);
SELECT TOP 1
    @matCode = CASE WHEN SlitMM.MaterialCode IS NOT NULL AND NULLIF(RTRIM(SlitMM.PlusMinus),'') = NULLIF(RTRIM(BaseMM.PlusMinus),'')
                    THEN ESR.SlittingMaterialCode ELSE DPP.MaterialCode END,
    @lengthM = ISNULL(ESR.GoodQtyLength, 0),
    @electrodeLot = ESR.ElectrodeLotNumber,
    @wcCode = ISNULL(W.WorkCenterCode, 'VVT_F1')
FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK)
INNER JOIN STB_SetInfo SI WITH(NOLOCK) ON SI.Barcode = ESR.ElectrodeLotNumber
INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK) ON DPP.DayPlanNo = SI.DayPlanNo
LEFT  JOIN STB_MaterialMaster BaseMM WITH(NOLOCK) ON BaseMM.MaterialCode = DPP.MaterialCode
LEFT  JOIN STB_MaterialMaster SlitMM WITH(NOLOCK) ON SlitMM.MaterialCode = ESR.SlittingMaterialCode
LEFT  JOIN STB_MaterialWarehouse W WITH(NOLOCK) ON W.MaterialWarehouseCode = @warehouseCode AND W.CompanyCode = 'VVT'
WHERE ESR.Barcode = @rollBarcode AND ESR.CompanyCode = 'VVT' AND ESR.TransferDateTime IS NULL
ORDER BY ESR.Seq DESC;

IF @matCode IS NULL BEGIN RAISERROR('ESR khong ton tai', 16, 1); ROLLBACK; RETURN; END
IF ISNULL(@lengthM, 0) <= 0 BEGIN RAISERROR('ESR GoodQtyLength <= 0', 16, 1); ROLLBACK; RETURN; END
IF EXISTS (SELECT 1 FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE LotID = @rollBarcode)
BEGIN RAISERROR('Da ton tai trong MLI', 16, 1); ROLLBACK; RETURN; END

-- Cấp số Serial chuẩn
DECLARE @curDate varchar(8) = CONVERT(varchar(8), GETDATE(), 112);
DECLARE @prefix varchar(12), @serialLen int, @lastNo int, @lastPrefix varchar(12);
SELECT @prefix = REPLACE(REPLACE(REPLACE(REPLACE(PrefixData, 'YYYY', SUBSTRING(@curDate,1,4)), 'YY', SUBSTRING(@curDate,3,2)), 'MM', SUBSTRING(@curDate,5,2)), 'DD', SUBSTRING(@curDate,7,2)),
       @serialLen = SerialLen, @lastNo = LastSerialNo, @lastPrefix = ISNULL(LastPrefixData, '')
FROM SmartFramework.dbo.STB_SerialRule WITH(ROWLOCK, UPDLOCK)
WHERE TableName = 'STB_MaterialLotInfo';

IF @prefix != @lastPrefix
BEGIN
    UPDATE SmartFramework.dbo.STB_SerialRule SET LastPrefixData = @prefix, LastSerialNo = 1 WHERE TableName = 'STB_MaterialLotInfo';
    SET @lastNo = 0;
END
ELSE
BEGIN
    UPDATE SmartFramework.dbo.STB_SerialRule SET LastSerialNo = LastSerialNo + 1 WHERE TableName = 'STB_MaterialLotInfo';
END

DECLARE @materialLotNo varchar(20) = @prefix + RIGHT(REPLICATE('0', @serialLen) + CAST(@lastNo + 1 AS varchar(10)), @serialLen);

INSERT INTO STB_MaterialLotInfo (
    MaterialLotNo, LotID, CompanyCode, WorkCenterCode,
    MaterialWarehouseCode, MaterialLocationCode, MaterialCode, MaterialStockAttribute,
    StockAttrib2, StockAttrib3,
    GRDate, InitialQty, CurrentQty, PickingQty,
    LotNo, IsSplitLot, LotAttr01,
    IsSlitting, LengthSlitting,
    CreateDateTime, CreateUserID
) VALUES (
    @materialLotNo, @rollBarcode, 'VVT', @wcCode,
    @warehouseCode, '', @matCode, 'NORMAL',
    '', '',
    CONVERT(VARCHAR(10), GETDATE(), 23), @lengthM, @lengthM, 0,
    @electrodeLot, 0, 'SLITTING',
    1, @lengthM,
    GETDATE(), 'vanduc'
);
COMMIT;
```

#### Bước 2: Kiểm tra cờ `ModalVisible = 'Y'`:
```sql
SELECT MLI.MaterialLotNo, MLI.LotID, MLI.MaterialCode, MLI.CurrentQty, MLI.MaterialWarehouseCode,
       RTRIM(ISNULL(MM.PlusMinus,'')) AS Polarity,
       CASE WHEN MLI.CompanyCode = 'VVT' AND MLI.IsSlitting = 1
                 AND RTRIM(ISNULL(MLI.LotAttr01,'')) = 'SLITTING'
                 AND MLI.CurrentQty > 0
                 AND MLI.MaterialWarehouseCode = @warehouseCode
                 AND NULLIF(RTRIM(ISNULL(MM.PlusMinus,'')), '') IS NOT NULL
            THEN 'Y' ELSE 'N' END AS ModalVisible
FROM STB_MaterialLotInfo MLI WITH(NOLOCK)
LEFT JOIN STB_MaterialMaster MM WITH(NOLOCK) ON MM.MaterialCode = MLI.MaterialCode
WHERE MLI.LotID = @rollBarcode;
```
*Lưu ý: Nếu `ModalVisible = 'N'`, kiểm tra ngay cực tính `PlusMinus` (+/-) trong `STB_MaterialMaster`.*

---

### Mục 10: Thiết Lập Cấu Hình Slot NVL CellLine Trong CSDL VINATECH_POP
- **Áp dụng:** Khi triển khai Chuyền mới hoặc sắp xếp lại thứ tự các Slot nạp NVL.
- **Bảng liên quan (Database `VINATECH_POP`):**
  - `VINA_ASSEMBLY_GROUP_MODE`: Chế độ Group nạp NVL theo từng Chuyền (`LINE_CODE`).
  - `VINA_GROUP_INPUT_ROUTE`: Thiết lập chi tiết từng Slot nạp (`SLOT_CODE`, `SLOT_NAME`, `ROUTE_CODE`, `IS_REQUIRED`, `DISPLAY_ORDER`).
- **Nguyên tắc cấu hình:** Tuân theo `ProductGroupCode` trong bảng `STB_MaterialMaster` và tiêu chuẩn nhóm mặt hàng định mức trong BOM.
- **Thao tác giao diện:** Chỉ tài khoản có quyền Admin mới truy cập được màn hình Thiết lập CellLine trên Web POP.

---

### Mục 11: Phân Quyền Hủy Đóng Gói Box Và Hủy Hoàn Thành Công Đoạn (Rollback)
- **Quy định bảo mật & an toàn:** Quyền hủy đóng gói Box (B523/Packing Kiosk) và hủy kết quả hoàn thành sản xuất chỉ cấp cho tài khoản Trưởng nhóm / IT Quản trị (`vanduc`, Leader được chỉ định).
- **Hành động:** Khi công nhân có yêu cầu hủy Box, liên hệ IT để kiểm tra và thực hiện lệnh rollback an toàn bằng tool `.\mes.ps1 fix-cancel-pack -Target "<Lot>"`.

---

### Mục 12: Nguyên Vật Liệu Thay Thế Trong Định Mức BOM (Delegate Material)
- **Hiện tượng:** BOM thừa mã NVL hoặc Kiosk không hiển thị nút chuyển đổi NVL tương đương.
- **Cách xử lý:**
  - Nếu BOM đang thừa NVL: Vào WinForm [A230] xóa NVL thừa trong BOM.
  - Thiết lập mã thay thế: Điền các mã tương đương vào các cột `DelegateMaterialCode1`, `DelegateMaterialCode2`... trong `STB_MaterialMaster`.
  - Trên Kiosk POP: Bấm nút [Làm mới NVL 🔄] để cập nhật lại danh sách.

---

### Mục 13: Lỗi Ấn Nhầm Sang Chế Độ (+) Nhập Lượng Hoàn Thành Thay Vì (-) Phế Phẩm
- **Hiện tượng:** Công nhân ấn nhầm vào dấu (+) ở bên giao diện nhập lỗi làm Kiosk nhảy sang chế độ nhập lượng hoàn thành. Khi ấn kết thúc sản xuất bị crash hoặc báo lỗi logic.
- **Cách xử lý:** Rollback lại lượt chốt bị lỗi bằng `.\mes.ps1 fix-rollback`, sau đó hướng dẫn OP chọn đúng dấu (-) để nhập phế phẩm.

---

### Mục 14: MES Tự Sinh Công Đoạn Kế Tiếp Khi POP Chưa Chốt
- **Hiện tượng:** Trên MES WinForm đã nhảy cóc sang công đoạn tiếp theo dù trên Kiosk POP công đoạn trước chưa chốt xong.
- **Cách xử lý:** Rollback xóa dòng tự sinh trên MES về công đoạn đang thao tác trên POP để công nhân chốt sản lượng tuần tự.

---

### Mục 15: Lỗi Chưa Lưu Độ Nhớt Tại Công Đoạn Trộn (Mixing)
- **Hiện tượng:** Kiosk không cho phép bấm hoàn tất mẻ trộn Mixing.
- **Root Cause:** Công nhân đo độ nhớt mẻ keo xong nhưng chưa ấn nút [Lưu] giá trị đo trên Kiosk trước khi bấm hoàn thành.
- **Cách xử lý:** Nhắc OP mở lại mẻ trộn, kiểm tra ô đo độ nhớt, ấn [Lưu], sau đó mới ấn Hoàn thành mẻ trộn.

---

### Mục 16: Lỗi Gán Nhầm Mã Máy Khi Chốt Sản Lượng (RULE 20: Atomic 2 Bảng)
- **Hiện tượng:** OP chọn nhầm máy trên Kiosk (ví dụ chốt nhầm máy `VVMHY136` thay vì `VVMHY130`).
- **NGUYÊN TẮC BẤT BIẾN:** BẮT BUỘC UPDATE ĐỒNG THỜI CẢ 2 BẢNG (`STB_ProdRouteHist` VÀ `MongoToMesPerformance`). Nếu chỉ sửa 1 bảng, Worker đồng bộ ngầm sẽ ghi đè lại dữ liệu sai!
- **SQL Hotfix chuẩn mực:**
  ```sql
  BEGIN TRAN;
  -- 1. Cập nhật bảng CSDL lõi MES
  UPDATE SmartFactoryV2.dbo.STB_ProdRouteHist
  SET MachineCode = 'VVMHY130', ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc'
  WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WHERE Barcode = 'VVQR193R072730')
    AND RouteCode = 'V-22_HY';

  -- 2. Cập nhật bảng đồng bộ POP Kiosk
  UPDATE SmartFactoryV2.dbo.MongoToMesPerformance
  SET MachineCode = 'VVMHY130'
  WHERE Barcode = 'VVQR193R072730'
    AND RouteCode = 'V-22_HY';
  COMMIT;
  ```
- *Lưu ý:* Mở màn hình WinForm `B270` để tra cứu chính xác `MachineCode` theo Tên máy (`MachineName`) xưởng cung cấp.

---

### Mục 17: Nút Cắt Điện Cực Bị Mờ Không Sáng (RULE 20: Khóa Dưới 100um)
- **Hiện tượng:** Nút [Cắt điện cực] trên giao diện Kiosk bị mờ xám, không thể bấm cắt.
- **Root Cause:** Khóa an toàn hệ thống: Chặn thao tác cắt nếu độ dày màng điện cực `MaterialThickness < 100` trong `STB_MaterialMaster`.
- **SQL Hotfix:**
  ```sql
  -- Kiểm tra độ dày hiện tại
  SELECT SI.Barcode, SI.MaterialCode, MM.MaterialName, MM.MaterialThickness, MM.MaterialTypeCode
  FROM SmartFactoryV2.dbo.STB_SetInfo SI WITH(NOLOCK)
  INNER JOIN SmartFactoryV2.dbo.STB_MaterialMaster MM WITH(NOLOCK) ON SI.MaterialCode = MM.MaterialCode
  WHERE SI.Barcode = 'VWQQ2609501E13';

  -- Cập nhật lại độ dày đạt chuẩn >= 100um
  BEGIN TRAN;
  UPDATE SmartFactoryV2.dbo.STB_MaterialMaster
  SET MaterialThickness = 120, ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc'
  WHERE MaterialCode = 'CRPSC5-005';
  COMMIT;
  ```

---

### Mục 18: Kiểm Tra Cực Tính Điện Cực Trong Master/BOM (+/-)
- **Hiện tượng:** Kiosk không cho gán cuộn điện cực vào Slot nạp Chuyền.
- **Root Cause:** Cột `PlusMinus` trong `STB_MaterialMaster` bị trống hoặc sai định dạng.
- **Kiểm tra:**
  ```sql
  SELECT MaterialCode, MaterialName, ProductGroupCode, PlusMinus 
  FROM SmartFactoryV2.dbo.STB_MaterialMaster WITH(NOLOCK)
  WHERE MaterialCode IN ('SRFPSC0-287','SRENCA5-277');
  ```
- **Quy tắc:** Bắt buộc `PlusMinus` phải là `1 (-)` (cực âm) hoặc `1 (+)` (cực dương). Nếu sai lệch, liên hệ bộ phận KTSP cập nhật lại Master.

---

### Mục 19: Không Tìm Thấy Mã NVL Từ Trụ Sở Khi Ấn Tồn Kho Để Cắt (Kho ROUTE)
- **Hiện tượng:** Bên sản xuất ấn tìm kiếm cuộn NVL chuyển từ trụ sở về nhưng Kiosk báo danh sách trống.
- **Root Cause:** Bên Kho chưa làm thủ tục Nhập kho hoặc chưa Xuất kho sang kho `ROUTE_VN_WH`.
- **Nguyên tắc:** Query tìm kiếm tồn kho của Kiosk POP bắt buộc vật tư phải nằm tại kho `ROUTE_VN_WH`. Báo Kho hoàn tất xuất kho nội bộ sang kho Chuyền.

---

### Mục 20: Quản Lý Cấp Chất Lượng (Grade) Khi Đóng Gói Model 35105 (Quan Hệ 3 Bảng)
- **Kiến trúc liên kết dữ liệu Grade:**
  - `STB_MaterialLotInfo`: Bảng lưu số lượng tồn vật lý theo `LotID`.
  - `STB_MaterialDocLotInfo`: **Bảng cầu nối trung gian** — không lưu Grade nhưng lưu cặp khóa `(LotID, MaterialDocDetailNo)`.
  - `STB_MaterialDocDetail`: Bảng chi tiết phiếu nhập/xuất, chứa cột `Grade` (Cấp A/B/C...).
- **SQL Truy vết Grade:**
  ```sql
  SELECT MLI.LotID, MLI.MaterialCode, MLI.CurrentQty, MLI.MaterialWarehouseCode,
         MDL.MaterialDocDetailNo, MDL.MaterialDocNo,
         MDD.Grade
  FROM SmartFactoryV2.dbo.STB_MaterialLotInfo MLI WITH(NOLOCK)
  INNER JOIN SmartFactoryV2.dbo.STB_MaterialDocLotInfo MDL WITH(NOLOCK) ON MDL.LotID = MLI.LotID
  INNER JOIN SmartFactoryV2.dbo.STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo = MDL.MaterialDocDetailNo
  WHERE MLI.LotID = 'VVQQ113R072719-357';
  ```

---

### Mục 21: Thừa NVL Do Thêm Vật Tư Thay Thế (Bảng VINA_BOM_INPUT_ROUTE)
- **Hiện tượng:** Giao diện nạp NVL hiển thị thừa các mã vật tư không cần thiết.
- **SQL Sửa chữa:**
  ```sql
  -- Kiểm tra cấu hình NVL thay thế
  SELECT DELEGATE_MATERIAL_CODE, DELEGATE_MATERIAL_CODE_2, DELEGATE_MATERIAL_CODE_3, *
  FROM VINATECH_POP.dbo.VINA_BOM_INPUT_ROUTE WITH(NOLOCK)
  WHERE MATERIAL_CODE = 'ECVT30-357';

  -- Cập nhật cột thừa thành NULL
  BEGIN TRAN;
  UPDATE VINATECH_POP.dbo.VINA_BOM_INPUT_ROUTE
  SET DELEGATE_MATERIAL_CODE = NULL
  WHERE MATERIAL_CODE = 'ECVT30-357';
  COMMIT;
  ```

---

### Mục 22: Cùng 1 Model Nhưng Nạp NVL Khác Nhau Do Chưa Thiết Lập GROUP
- **Nguyên nhân:** Chuyền sản xuất chưa được cấu hình Group nạp NVL trong bảng `VINATECH_POP.dbo.VINA_GROUP_INPUT_ROUTE`.
- **Cách xử lý:** Quay lại áp dụng quy trình thiết lập tại [Mục 10](#mục-10-thiết-lập-cấu-hình-slot-nvl-cellline-trong-csdl-vinatech_pop).

---

### Mục 23: Điện Cực Báo Chưa Cắt Nhưng Hết Số Lượng (Báo Phế Nhầm)
- **Hiện tượng:** Màng cuộn điện cực còn dài nhưng trên hệ thống báo đã hết số lượng khả dụng để cắt.
- **Root Cause:** Công nhân bên xưởng điện cực báo phế nhầm số lượng mét màng.
- **SQL Kiểm tra & Phục hồi:**
  ```sql
  -- Kiểm tra các dòng báo phế (chú ý cột Remark ghi nhận số mét phế)
  SELECT WasteInfoNo, Barcode, DefectCode, WasteLength, Remark, CreateDateTime, CreateUserID
  FROM SmartFactoryV2.dbo.STB_ElectrodeWasteInfoNew WITH(NOLOCK)
  WHERE Barcode = 'VVQR2120001E03';

  -- Xóa bản ghi phế nhầm
  BEGIN TRAN;
  DELETE FROM SmartFactoryV2.dbo.STB_ElectrodeWasteInfoNew
  WHERE Barcode = 'VVQR2120001E03' AND WasteInfoNo = '<Mã_Phế_Nhầm>';
  COMMIT;
  ```

---

### Mục 24: Báo Đã Hoàn Thành Trên MES Nhưng Thực Tế Đã Xong Trên POP
- **Hiện tượng:** OP báo lỗi công đoạn đã hoàn thành trên MES, nghi ngờ dữ liệu bị kẹt.
- **Nguyên tắc an toàn:**
  ```sql
  SELECT ProdRouteHistNo, ControlNo, RouteCode, CompleteRoute, CreateDateTime
  FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK)
  WHERE ControlNo = (SELECT ControlNo FROM SmartFactoryV2.dbo.STB_SetInfo WHERE Barcode = 'vvqq283r072712')
    AND RouteCode = 'V-23';
  ```
  *Nếu `CompleteRoute IS NULL`: Bản ghi đã được POP chốt hoàn tất chuẩn xác. Tuyệt đối không xóa! Chỉ cần bảo OP ấn F5 reload lại màn hình Kiosk.*

---

### Mục 25: Dung Dịch, Giấy, Tape Báo Hết Tồn (Đối Soát & Cân Bằng Định Mức BOM)
- **Hiện tượng:** Thùng dung dịch điện giải, cuộn giấy cách điện hoặc băng dính Tape Pi báo hết tồn kho trên Kiosk dù thực tế còn hàng.
- **Quy trình 4 bước kiểm toán định mức:**
  1. Kiểm tra tồn kho ban đầu vs thực tế:
     ```sql
     SELECT LotID, MaterialCode, InitialQty, CurrentQty, MaterialWarehouseCode
     FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
     WHERE LotID = 'ML20260625000505';
     ```
  2. Tổng hợp số lượng đã xuất nạp cho các Lot:
     ```sql
     SELECT SUM(Qty) AS TotalUsedQty
     FROM SmartFactoryV2.dbo.STB_RawMaterialInputHist WITH(NOLOCK)
     WHERE RawMaterialBarcode = 'ML20260625000505';
     ```
  3. Đối chiếu định mức BOM:
     ```sql
     SELECT BD.MaterialCode, BD.BomVersion, BD.ChildMaterialCode, BD.UnitQty
     FROM SmartFactoryV2.dbo.STB_BomDetail BD WITH(NOLOCK)
     WHERE BD.MaterialCode = (SELECT MaterialCode FROM SmartFactoryV2.dbo.STB_SetInfo WHERE Barcode = 'VVQR252R750635')
       AND BD.BomVersion = '2001';
     ```
  4. Công thức chuẩn: `Số Lượng NVL Tiêu Hao Chuẩn = Định Mức BOM x Số Lượng Của Lot`.
     - Nếu phát hiện Lot nào bị trừ số lượng cao bất thường: Cập nhật lại `Qty` trong `STB_RawMaterialInputHist`, sau đó tính lại và cập nhật `CurrentQty = InitialQty - Tổng_Tiêu_Hao_Thực` trong `STB_MaterialLotInfo`.

---

### Mục 26: Nhập Điện Cực Trụ Sở Về Xưởng Không Tìm Thấy (Thiếu Xuất Kho ROUTE)
- **Hiện tượng:** Cuộn điện cực xuất từ Hàn Quốc/Trụ sở về xưởng Việt Nam nhưng Kiosk POP quét không ra.
- **SQL Kiểm tra:**
  ```sql
  SELECT LotID, LotNo, MaterialCode, CurrentQty, MaterialWarehouseCode
  FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
  WHERE LotNo = 'VWQR1510501E05';
  ```
- **Xử lý:** Liên hệ phụ trách kho xuất vật tư sang kho `ROUTE_VN_WH`. Hệ thống Kiosk POP chỉ hiển thị các cuộn BTP đã được xuất sang kho Chuyền `ROUTE_VN_WH`.
