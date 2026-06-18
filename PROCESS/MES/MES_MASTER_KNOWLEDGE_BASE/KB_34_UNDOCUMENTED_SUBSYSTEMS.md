# KB_34 — Các Phân Hệ Phụ Trợ Chưa Document (Undocumented Subsystems)

> **Verified against DB:** 2026-06-18
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 📊 Screen Prefix Distribution (Phân bố màn hình theo tiền tố)

> Tổng: **1,467 screens** / **1,026 unique TCodes**

| Prefix | Count | Phân hệ | Document tại |
|---|---|---|---|
| B | 354 | Production / Sản xuất | KB_03, KB_04 |
| (blank) | 300 | Menus / Folders | — |
| H | 174 | HN (89) + HY (22) + misc | KB_02, KB_25 |
| C | 150 | Quality Control (QC) | KB_05 |
| F | 124 | WMS / Kho vật tư | KB_02 |
| Z | 52 | System Admin / Phân quyền | KB_01 |
| A | 33 | Master Data | KB_06 |
| **P** | **29** | **Nhân sự + Sự kiện + Điện nước** | **→ §2** |
| K | 28 | Korea-style screens | KB_03 |
| **V** | **26** | **Vietnam Mobile/PDA Menu** | **→ §3** |
| **L** | **25** | **Support Management (SPT)** | **→ §12** |
| **G** | **23** | **Product Stock & Shipment** | **→ §13** |
| **E** | **23** | **Electrode** | KB_05 |
| **M** | **22** | **MEA (Electrode Analysis)** | **→ §23** |
| **T** | **13** | **Cost Management** | **→ §24** |
| **S** | **12** | **SmartFactory IoT** | **→ §9** |
| **W** | **10** | **WorkTime Management** | **→ §15** |
| **R** | **9** | **Reliability Testing (RTM)** | **→ §14** |
| **FG** | **26** | **Finished Goods** | **→ §16** |
| D | 6 | VinaEnesol | KB_25 |
| I/Y | 8 | Misc | — |

---

## 2. 👥 P-Series: Nhân Sự, Sự Kiện & Tiện Ích (29 screens)

| TCode | Caption | Chức năng |
|---|---|---|
| `P110` | VNT_EventBasicInfo | Thông tin sự kiện cơ bản |
| `P111` | Attendance Time | **Chấm công nhân viên** (→ `STB_VN_ATTENDANCE_TIME`) |
| `P112` | EmployeeMoveLines | Di chuyển nhân viên giữa Lines |
| `P120` | VNT_EventProgressInfo | Tiến độ sự kiện |
| `P130` | VNT_EventAttendInfo | Điểm danh sự kiện |
| `P140` | VNT_EventAttendListForEmployee | DS điểm danh theo nhân viên |
| `P150` | VNT_EventScoreRanking | Xếp hạng điểm sự kiện |
| `P160` | EmployeeScoreSummary | Tổng hợp điểm nhân viên |
| `P170` | VNT_EmployeeInfo | **Thông tin nhân viên chi tiết** |
| `P171` | Danh sách nhân viên | Tra cứu nhân viên |
| `P210-P250` | DocManagement (5 screens) | **Quản lý tài liệu nội bộ** |
| `P410` | FacilityPowerInquiry | **Tra cứu điện năng** |
| `P411` | MonthlyElectricity | Điện hàng tháng |
| `P420` | WastewaterMeterReadingLog | **Log đồng hồ nước thải** |
| `P430-P450` | Electricity (3 screens) | Quản lý đồng hồ điện |
| `PM/PM01` | PriceAndMaterialCode | Giá & mã hàng VN |

---

## 3. 📱 V-Series: Vietnam Mobile/PDA Menu (26 screens)

Cấu trúc menu PDA cho công nhân Việt Nam:

| TCode | Caption | Nhóm |
|---|---|---|
| `V000` | Vietnam_Menu | Root menu |
| `V100` | Accounting | Kế toán |
| `V200` | HR | Nhân sự |
| `V300` | Production Cell | Sản xuất Cell |
| `V310` | Production Qty | Nhập sản lượng |
| `V320` | NG Qty | Nhập phế |
| `V330` | MaterialUpLine | Cấp NVL lên chuyền |
| `V400` | Production Module | Sản xuất Module |
| `V410` | Module Qty | Sản lượng Module |
| `V420` | NG Qty | Phế Module |
| `V500` | QC | Menu QC |
| `V510-V530` | IQC/PQC/OQC | Kiểm tra chất lượng |
| `V600` | Electrode Area | Khu vực điện cực |
| `V700` | Warehouse | Kho |
| `V710/V720` | Raw/Finish Goods | NVL/Thành phẩm |
| `V800` | Machine Manage | Quản lý thiết bị |
| `V900` | Stationery | Văn phòng phẩm |

---

## 4. 🏭 Phân Hệ Phụ Tùng (Spare Parts — 26 tables)

> **Chưa document trong bất kỳ KB nào.** HN-series (HN131, HN161, HN163, HN180, HN241, HN251, HN260, HN270) là UI chính.

### Tables chính:
| Table | Mô tả |
|---|---|
| `STB_SparePartInfo` | Master danh mục phụ tùng |
| `STB_SparePartStockInfo` | Tồn kho phụ tùng |
| `STB_SparePartIOHistory` | Lịch sử xuất/nhập phụ tùng |
| `STB_SparePartBasicLocation` | Vị trí lưu trữ |
| `STB_SparePartChangeHistory` | Lịch sử thay đổi |
| `STB_MachineSparePartInfo` | Mapping phụ tùng ↔ máy |
| `STB_TYPESPAREPART` | Phân loại phụ tùng |
| `STB_VNSparePartInfo` | Version Vietnam |
| `STB_VNSparePartStockInfo` | Tồn kho VN |
| `STB_VN_SpecialSparePartInfo` | Phụ tùng đặc biệt |

---

## 5. 🤖 Daifuku ASRS Interface (5 SPs + 1 table)

> Hệ thống kho tự động Daifuku tại BG2. Tham chiếu: KB_31 Bug §FG_WH.

| Object | Loại | Chức năng |
|---|---|---|
| `usp_DaifukuWarehouse_get` | SP | Lấy thông tin vị trí kho |
| `usp_DaifukuWarehouse_iud` | SP | Thêm/sửa/xóa vị trí |
| `usp_DaifukuWarehouse_Del` | SP | Xóa vị trí |
| `usp_DaifukuManualLabelPrintHist_get` | SP | Lịch sử in tem thủ công |
| `usp_VN_DaiFuku_Temp` | SP | Dữ liệu tạm Daifuku |
| `STB_VN_DaiFuku_Temp` | Table | Bảng tạm interface |

---

## 6. 📡 ANDON System (4 tables)

> Hệ thống hiển thị sản lượng real-time trên TV/Monitor tại xưởng. URLs: BG1 `:8006/andon`, BN `:8000/andon`

| Table | Mô tả |
|---|---|
| `CellLineANDON` | Dữ liệu ANDON Cell Line |
| `ProcessStepsANDON` | Các bước quy trình ANDON |
| `DefectReportsAnDon` | Báo cáo lỗi ANDON (BN) |
| `DefectReportsAndon_BG` | Báo cáo lỗi ANDON (BG) |

---

## 7. 📈 ESR System (14 tables)

> ESR = Equivalent Series Resistance. Dữ liệu đo ESR trực tiếp từ máy đo → lưu DB → C530/C546 tra cứu.

| Table | Mô tả |
|---|---|
| `Stb_ESRValueMonitor` | **Bảng chính** — Lưu giá trị ESR realtime |
| `STB_ESRInspectionData` | Dữ liệu kiểm tra ESR thô |
| `STB_ESRInspectionHist` | Lịch sử kiểm tra ESR |
| `STB_ESRSpecOverInfo` | Thông tin vượt Spec ESR |
| `STB_VVT_ESR_MONITOR` | Monitor ESR VVT |
| `STB_VVT_ESRDATA` | Dữ liệu ESR VVT (active) |
| `STB_VVT_ESRDATA_2021-2023*` | 6 backup tables theo thời gian |
| `STB_ESRDataBackup6Line` | Backup ESR 6 Line |
| `STB_Vietnam_ESRgrowup_dayByday` | Phân tích ESR tăng trưởng theo ngày |

---

## 8. 🔧 Machine Management (35 tables)

> Quản lý toàn bộ vòng đời thiết bị: PM (Preventive Maintenance), Sửa chữa, KPI, Phụ tùng.

### Core tables:
| Table | Mô tả |
|---|---|
| `STB_MachineMaster` | **Master** — Danh mục máy |
| `STB_MachineBasicInfo` | Thông tin cơ bản |
| `STB_MachineCapacity` | Năng lực máy |
| `STB_MachineSpecInfo` | Thông số kỹ thuật |
| `STB_MachinePmItem` | Hạng mục bảo trì định kỳ |
| `STB_MachinePmHistory` | Lịch sử PM |
| `STB_MachineRepairHistory` | Lịch sử sửa chữa |
| `STB_MachineRepairWorker` | Thợ sửa chữa |
| `STB_MachineConditionHist` | Lịch sử trạng thái máy |
| `STB_MachineConditionAlarm` | Cảnh báo trạng thái |

### Vietnam-specific:
| Table | Mô tả |
|---|---|
| `STB_VN_DEVICEMACHINES` | Thiết bị VN |
| `STB_VN_STATUSMACHINES` | Trạng thái máy VN |
| `STB_VN_LOCATIONMACHINES` | Vị trí máy VN |
| `STB_VN_KPIMACHINES` | KPI máy VN |
| `STB_VN_STAGEMACHINES_MATERS` | Master công đoạn máy |
| `STB_VN_STOREMACHINES` | Kho máy VN |
| `STB_VN_Form_Request_Machines` | Yêu cầu sửa chữa máy |

---

## 9. 🔌 S-Series: SmartFactory IoT (12 screens)

| TCode | Caption | Chức năng |
|---|---|---|
| `S110` | VNT_ImpregnationLevel | **Mức ngâm tẩm** (Impregnation) |
| `S120` | VNT_IoTMeasureHist | **Lịch sử đo IoT** |
| `S211` | VNT_DirectCoaterStatusInfo | Trạng thái máy Coater trực tiếp |
| `S212` | VisionGroupInspInfo | **Thông tin kiểm tra Vision** (camera AI) |
| `S213` | VNT_VisionInspectionResult | Kết quả Vision AI |
| `S215` | VNT_XRFInspInfo | **XRF** (X-Ray Fluorescence) inspection |

---

## 10. 🏭 Route System — Bản đồ đầy đủ mã công đoạn

### Cell Line Routes (V-series):
| Route | Tên | Ghi chú |
|---|---|---|
| V-22 / V-22_BG | Cuốn (Winding) | Công đoạn đầu |
| V-23 / V-23_BG | Cắt chân (Tab Welding) | |
| V-24 / V-24_BG | Nhúng hóa chất | |
| V-25 / V-25_BG | Sấy (Dry Oven) | |
| V-26 / V-26_BG | Đo ESR (Aging Check) | |
| V-27 / V-27_BG | Ngoại quan (Visual Insp.) | |
| V-28 / V-28_BG | Bao bì (Sleeving) | |
| V-29 → V-34 | Mở rộng | VE routes cho Hà Nam |
| V-33 | **Cascade breaker** | Logic đặc biệt |

### Module Line Routes (MV-series):
| Route | Tên |
|---|---|
| MV-01 / MV-01_BG | Lắp ráp (Assembly) |
| MV-02 / MV-02_BG | Kiểm tra trung gian |
| MV-03 / MV-03_BG | Kiểm tra giữa |
| MV-04 / MV-04_BG | Ngoại quan |
| MV-05 / MV-05_BG | Đóng gói |

### Hưng Yên Routes (P-series):
| Route | Tên | Ghi chú |
|---|---|---|
| P-01 | Assembly | **Cascade breaker** (logic đặc biệt như V-33) |
| P-02 | Testing | |
| P-03 | Mid-check | |
| P-04 | Visual | |
| P-05 | Packing/Final | |
| P-06 | Output | |

### Electrode Routes (E-series — 16 routes):
| Route | Ghi chú |
|---|---|
| E-01 to E-03 | Mixing/Coating/RollPress |
| E-11 | (Unknown) |
| E-22 to E-29 | Cell Electrode parallel routes |
| E-30 | VPC (VinaEnesol) |
| E-33 | **VPC cascade** (logic đặc biệt) |
| E-34 | (Extended) |
| E-99 | (Special/Final) |

### VinaEnesol PCBA Routes (VP-series — 18 routes × 2 variants):
| Route | Tên | Ghi chú |
|---|---|---|
| VP01 / VP01_HY | PCBA Wave Soldering, Label | Công đoạn đầu |
| VP02 / VP02_HY | AOI Inspection | Automated Optical Inspection |
| VP03 / VP03_HY | RTV Silicone | Phủ keo silicon |
| VP04 / VP04_HY | PCBA FCT | Functional Circuit Test |
| VP05 / VP05_HY | Conformal Coating (Top) | Phủ bảo vệ mặt trên |
| VP06-VP07 / _HY | Conformal Coating (Bottom) | Phủ mặt dưới (2 lớp) |
| VP08 / VP08_HY | SCM Assembly | Lắp ráp SCM |
| VP09 / VP09_HY | SCM Top Cover Assembly | Lắp nắp SCM |
| VP10-VP11 / _HY | SCM Ground Bond + Hi-Pot | Kiểm tra an toàn điện |
| VP12 / VP12_HY | SCM FCT | Test chức năng SCM |
| VP13-VP16 / _HY | Enclosure Assembly + Tests | Lắp vỏ + kiểm tra |
| VP17 / VP17_HY | **Burn-in Test** | Test lão hóa |
| VP18 / VP18_HY | Enclosure Packing | Đóng gói cuối |

### Electrode Module (EM-series — 3 routes):
| Route | Ghi chú |
|---|---|
| EM-01 | Stage 1 (→ EM-02 có gate Aging 12h) |
| EM-02 | Stage 2 (kiểm tra Aging ≥12h so với EM-01) |
| EM-03 | Stage 3 |

### Route Prefix Summary:
| Prefix | Count | Phân hệ |
|---|---|---|
| V | 53 | Cell Line (BN/BG1/BG2/HN) |
| E | 16 | Electrode |
| MV | 10 | Module (BN/BG) |
| S | 8 | Special/Support |
| P | 6 | Hưng Yên Cell |
| M | 6 | (Misc) |
| ME | 5 | Module Electrode |
| VP | 36 | **VinaEnesol PCBA** (18 × 2) |
| EM | 3 | Electrode Module |
| **TỔNG** | **~120** | **All routes** |

---

## 11. 🏗️ Doping JIG System (2 tables)

| Table | Mô tả |
|---|---|
| `Stb_VVT_DopingJIG` | Trạng thái JIG hiện tại (JigID, LotInUsed, Status, BeginDateTime, EndDateTime) |
| `Stb_VVT_DopingJIG_History` | Lịch sử chạy JIG (auto-archive khi JIG kết thúc) |

> ⚠️ **Bug đã phát hiện (KB_25):** SP `usp_Vietnam_DopingJIG_uid` có lỗi logic `dateadd(second,5,getdate())` khiến autoend không lưu History.

---

## 12. 📋 L-Series: Support Management (25 screens)

> Hệ thống Support = Mirror read-only của Production/QC/WMS dành cho role quản lý/ban lãnh đạo.

| TCode | Caption | Chức năng |
|---|---|---|
| `L120` | VNT_SPTRawMaterialInput | Tra cứu NVL cấp vào SX |
| `L130` | SPTRouteInspectionHistory | Lịch sử kiểm tra công đoạn |
| `L135` | SPTProdRouteByBarcode | Route theo barcode |
| `L137` | GetProdRouteHistForBarcode_SPT | Chi tiết route history |
| `L140` | SPTProdRouteForPacking | Route cho đóng gói |
| `L150` | ProductionOrderBatchInfo | Thông tin batch PO |
| `L160` | DayProdPlanOrderBatchInfo | Kế hoạch ngày batch |
| `L170` | SPTProdProcess | Quy trình sản xuất |
| `L180` | ProdRouteHistSPT | Lịch sử route SX |
| `L210` | SetListForOqcLotManagement | Quản lý Lot OQC |
| `L220` | MaterialOqcInfoSampleManagement | Quản lý mẫu OQC |
| `L230` | RotaryKilnItemSpecInfo | Spec Rotary Kiln |
| `L310` | SPTProductStock | **Tồn kho thành phẩm (SPT)** |
| `L410` | SPTRawMaterialStockLotInfo | Tồn kho NVL theo Lot |
| `L420` | SPTMaterialWarehouseInOutHist | Lịch sử XNK |
| `L430` | SPTRawMaterialMergeSplitHist | Lịch sử gộp/tách |
| `L440` | SPTRawMaterialStock | Tồn kho NVL tổng |

---

## 13. 📦 G-Series: Product Stock & Shipment (23 screens)

| TCode | Caption | Chức năng |
|---|---|---|
| `G612` | Vietnam_ProductStock | **Tồn kho thành phẩm VN** |
| `G660` | Daifuku_Warehouse | **Kho tự động Daifuku** |
| `G661` | WarehouseReceipt | Phiếu nhập kho |
| `G662` | WarehouseDelivery | **Phiếu xuất kho** (→ `usp_WarehouseDelivery_get`) |
| `G670` | Single_Shipment | Xuất hàng đơn lẻ |
| `G680` | VNT_ProductStockInfo | Thông tin tồn kho |
| `G690` | ProductStockInfoUpload | Upload tồn kho |
| `G691` | ProductStockInfoLookup | Tra cứu tồn kho |
| `G692` | ProductStockInfoUploadHist | Lịch sử upload |
| `G695` | PackingRemainingQtyInfo | SL đóng gói còn lại |
| `G710` | ShipmentHist | **Lịch sử xuất hàng** |

---

## 14. 🧪 R-Series: Reliability Test Management (9 screens)

> RTM = Quản lý kiểm tra độ tin cậy sản phẩm. Dùng cho bộ phận QC/R&D để theo dõi các bài test tuổi thọ, nhiệt độ, rung lắc...

| TCode | Caption | Chức năng |
|---|---|---|
| `R110` | ReliabilityTestRequestInfo | **Tạo yêu cầu kiểm tra** |
| `R210` | ReliabilityTestManagementInfo | **Quản lý bài test** |
| `R220` | ReliabilityTestMeasureInfo | **Kết quả đo** |
| `R230` | RTInfo | Thông tin RT chi tiết |

---

## 15. ⏰ W-Series: WorkTime Management (10 screens)

| TCode | Caption | Chức năng |
|---|---|---|
| `W110` | WorkGroupManagement | **Quản lý nhóm làm việc** |
| `W210` | DailyWorkTimeInfo | Thời gian làm việc ngày |
| `W220` | NormalWorkTimeInfo | Giờ làm việc tiêu chuẩn |
| `W230` | MonthWorkTimeInfo | Thời gian làm việc tháng |
| `W786` | VVT_Log_Weight | **Log cân nặng** (cân điện tử) |
| `W787` | VVT_Tracking_Weight | **Theo dõi cân nặng** |
| `W788` | GetDataSortingProgram | Chương trình phân loại |

---

## 16. 📦 FG-Series: Finished Goods (26 screens)

> Quản lý kho thành phẩm chi tiết, bao gồm BN, BG1, BG2, và HN.

| TCode | Caption | Chức năng |
|---|---|---|
| `FG00` | Thành Phẩm Bắc Giang | **Main FG BG1** |
| `FG01` | Tồn kho thành phẩm | **Tra cứu tồn kho FG** |
| `FG02` | Tổng hợp kho thành phẩm | Báo cáo tổng hợp |
| `FG04` | Lịch sử kho thành phẩm | Lịch sử XNK |
| `FG05` | **Kho tự động Daifuku** | Giao diện ASRS |
| `FG06` | Import and Export | Xuất nhập hàng |
| `FG07` | Phiếu xuất kho | Chứng từ xuất |
| `FG08` | Phiếu xuất NVL | Chứng từ xuất NVL |
| `FG09` | Phiếu nhập kho NVL | Chứng từ nhập NVL |
| `FG10` | **BN & BG combined** | Tổng hợp 2 nhà máy |
| `FG11` | Tồn TP vượt trên 3 tháng | Cảnh báo hàng tồn lâu |
| `FG13` | Nhập vị trí mã Lot TP | Quản lý vị trí |
| `FG16` | FinishGood_StockIn_BG | Nhập kho BG |
| `FG17` | FinishGoodStockOutBG | Xuất kho BG |
| `FG19` | Invoice_FinishGood_BG | Invoice BG |
| `FG20` | **Tổng hợp kho TP BN&BG** | Báo cáo tổng hợp |
| `FG21` | Tồn hàng TP trên CellLine | Hàng chưa nhập kho |
| `FG22` | Tồn kho NVL | Tra cứu NVL |
| `FGBG2` | Thành Phẩm BG2 | **FG BG2** |

---

## 17. 🔩 Mold Management (20 tables)

> Quản lý khuôn đúc/ép: vòng đời, vị trí, sản lượng, bảo trì, sửa chữa.

| Table | Mô tả |
|---|---|
| `STB_MoldBasicInfo` | **Master** — Thông tin khuôn |
| `STB_MoldTypeInfo` | Phân loại khuôn |
| `STB_MoldLocation` | Vị trí khuôn |
| `STB_MoldProdHist` | Lịch sử sản xuất |
| `STB_MoldProdPlanDetail` | Kế hoạch SX khuôn |
| `STB_MoldRepairHistory` | Lịch sử sửa chữa |
| `STB_MoldMoveHist` | Lịch sử di chuyển |
| `STB_MoldCheckSheetMaster` | Master check sheet |
| `STB_MoldCheckSheetItem` | Hạng mục kiểm tra |
| `STB_MoldMonthlySummary` | Báo cáo tháng |
| `STB_MoldProductMapping` | Mapping khuôn ↔ sản phẩm |
| `STB_MoldImprovementSheet` | Phiếu cải tiến |

---

## 18. ♻️ Scrap & Waste Management (27 tables)

> Quản lý phế liệu, cân nặng, đơn giá phế từ sản xuất Cell/Module/Electrode.

| Table | Mô tả |
|---|---|
| `STB_ElectrodeWasteInfoNew` | Phế điện cực (active) |
| `STB_ElectrodeWastePriceNew` | **Đơn giá phế** điện cực |
| `STB_WasteUnitPrice` | Đơn giá phế chung |
| `STB_WasteWeight` | Cân nặng phế |
| `STB_TypeWaste` | Phân loại phế |
| `STB_SCRAPHISTORY` | Lịch sử phế Cell |
| `STB_ScrapsByLot` | Phế theo Lot |
| `STB_VN_SCRAPLOT` | Phế VN theo Lot |
| `STB_VN_SCRAP_AFTERPRODUCTIONS` | Phế sau sản xuất |
| `STB_VN_SCRAP_WEIGHSCALE_PRODUCTIONS` | Cân phế sản xuất |
| `STB_AssemblyCellWeightInfo` | Cân nặng Cell |
| `STB_MainAssemblePartWeight` | Cân linh kiện chính |
| `Stb_vietnam_barcodeWeight` | Cân theo barcode |
| `stb_moudleWeightNG` | Cân Module NG |

---

## 19. 📅 Calendar, Shift & Salary (8 tables)

| Table | Mô tả |
|---|---|
| `STB_CalendarMaster` | Lịch nhà máy Master |
| `STB_CalendarDetail` | Chi tiết lịch |
| `STB_DayWorkCalendar` | Lịch làm việc ngày |
| `STB_DayWorkCalendarDetail` | Chi tiết ca ngày |
| `STB_VN_Shift` | Cấu hình ca VN |
| `HN_ShiftPeriods` | Khoảng ca Hà Nam |
| `STB_SalaryInfo` | Thông tin lương |

---

## 20. 🇻🇳 STB_VN_ Custom Vietnam Tables Summary

> **112 bảng** prefix `STB_VN_` — Toàn bộ do team Vietnam tự phát triển thêm, KHÔNG nằm trong framework gốc HQ.

### Phân nhóm chính:
| Nhóm | Số bảng | Ví dụ |
|---|---|---|
| **FINISHGOODS** | 15+ | `STB_VN_FINISHGOODS`, `_BG`, `_BG2`, `_HN`, `_HY` |
| **Machine/Equipment** | 8 | `STATUSMACHINES`, `LOCATIONMACHINES`, `KPIMACHINES` |
| **Spare Parts** | 6 | `VN_SpecialSparePartInfo`, `VN_SparePartLineUsage` |
| **HR/Employee** | 5 | `ATTENDANCE_TIME`, `Employees`, `EMPLOYEESTRANSFER` |
| **Label/Stamp** | 6 | `STAMP_FOXCONN`, `STAMP_HONGKONG`, `STAMP_MODULE` |
| **Scrap/Waste** | 4 | `SCRAPLOT`, `SCRAP_AFTERPRODUCTIONS` |
| **Inventory** | 3 | `InventoryFirst`, `MODEL_INVENTORY` |
| **Production** | 5 | `STAGE_PRODUCTION`, `PRODUCTION_ERROR` |
| **Misc** | 60+ | `CATEGORIES`, `CLASSIFY`, `COUNTRY`, `ECUS`... |

---

## 21. 🧩 SmartFramework — UI Engine Architecture (61 tables)

> SmartFramework = Bộ não UI. Chứa cấu hình layout, binding nút→SP, serial generation, phân quyền, label format.

### Core Architecture Tables:
| Table | Mô tả |
|---|---|
| `STB_ScreenInfo` | **Master** — Danh mục 1,467 screens (TCode, Caption, MenuPath) |
| `STB_ScreenObjects` | **★ UI→SP Binding Engine** — 7,605 bindings (ObjectType: Action/SearchFunction/ExecuteFunction/View) |
| `STB_ScreenLayoutInfo` | Cấu hình layout varbinary cho từng screen |
| `STB_SerialRule` | **★ Barcode/Serial Generation Engine** — Tạo mã tự động cho mọi bảng (PrefixData, SerialLen, LastSerialNo) |
| `STB_BaseCode` | Bảng mã cơ sở (Code tables) — phân loại, lookup values |
| `STB_LabelInfo` | Cấu hình tem nhãn |
| `STB_LabelTypeInfo` | Loại tem nhãn |
| `STB_LabelSpecInfo` | Spec tem nhãn |
| `STB_PDAMenu` | Menu PDA mobile |
| `STB_PDAStringResources` | Ngôn ngữ PDA |
| `STB_ScreenStringResources` | Ngôn ngữ screen |
| `STB_GlobalProcessRule` | Quy tắc xử lý global |
| `STB_DDLHistory` | **Audit trail** — Lịch sử thay đổi cấu trúc DB |
| `STB_VendorScreenInfo` | Màn hình dành cho nhà cung cấp bên ngoài |

### SerialRule Engine — Cách tạo mã tự động:
```
TableName = 'STB_CommInspDocHistory'
PrefixData = 'YYYYMMDD'     → LastPrefixData = '20260618'
SerialLen = 6                → LastSerialNo = 430
→ Mã tiếp theo = '20260618000431'
```

### ScreenObjects Binding — Cơ chế UI→SP:
| ObjectType | Count | Mô tả |
|---|---|---|
| Action | 2,362 | Nút bấm trên toolbar (Save, Delete, Print...) |
| SearchFunction | 1,856 | SP load data lên grid (usp_xxx_get) |
| ExecuteFunction | 1,573 | SP xử lý nghiệp vụ (usp_xxx_iud) |
| View | 1,814 | SP load detail/sub-grid |
| **TỔNG** | **7,605** | **Toàn bộ UI→SP bindings** |

---

## 22. 📊 Grand Totals — System-Wide Object Count

### Top 15 Largest Tables (by row count — Verified 2026-06-18):
| # | Table | Rows | Subsystem |
|---|---|---|---|
| 1 | `STB_VVT_ESRDATA` | **398,099,747** | ESR measurement (400M!) |
| 2 | `STB_ProductStockInfo` | 64,556,565 | Product stock snapshots |
| 3 | `STB_CommInspMeasureHist` | 60,073,965 | QC measurement |
| 4 | `STB_ESRInspectionData` | 39,668,717 | ESR inspection |
| 5 | `STB_CommInspDocItem` | 33,141,530 | QC doc items |
| 6 | `STB_IoTMeasureHist` | 28,786,142 | **IoT measurement** |
| 7 | `STB_Vvt_SdProds` | 22,868,733 | SD products |
| 8 | `STB_MaterialQcSampleResult` | 19,943,443 | QC sample results |
| 9 | `STB_ProcedureLog` | 19,318,631 | **SP execution log** |
| 10 | `STB_VN_FINISHGOODS_CAPTURE` | 13,555,570 | FG snapshot |
| 11 | `stb_DetailAgaingHN` | 11,113,742 | **Aging data Hà Nam** |
| 12 | `STB_MaterialLotSnapshot` | 9,912,516 | Material lot snapshot |
| 13 | `stb_SDValueTest` | 9,885,729 | SD test values |
| 14 | `STB_ProductStockInfoUpload` | 9,241,518 | Stock upload |
| 15 | `STB_VietnamSemiInventory` | 8,212,627 | Semi-FG inventory |

> [!IMPORTANT]
> **STB_VVT_ESRDATA** chiếm **398 triệu rows** — bảng lớn nhất hệ thống, lưu toàn bộ giá trị ESR từng cell. Đây là lý do SmartFactoryV2 = 572GB.

### SmartFactoryV2:
| Object Type | Count |
|---|---|
| Stored Procedures | **3,396** |
| User Tables | **994** |
| Scalar Functions | 76 |
| Views | 61 |
| Triggers | **33** |
| Table-Valued Functions | 30 |
| **TỔNG** | **4,590** |

### SmartFramework:
| Object Type | Count |
|---|---|
| Base Tables | **61** |
| Screen Bindings | **7,605** |
| Registered Screens | **1,467** |

### Across All 19 Databases (Total ~2 TB):
| Database | Size | Tables | Status |
|---|---|---|---|
| SmartFactoryV2 | **572 GB** | **994** | **PRIMARY** — 3,396 SPs |
| SmartFramework_File | **365 GB** | — | File storage (binary) |
| SmartFramework_Temp | **127 GB** | — | Temp storage |
| VINATECH_RESTFUL | **127 GB** | — | SSO/Identity |
| VINATECH_GROUP | **121 GB** | — | Groupware |
| NEOE | **70 GB** | **4,876** | ERP Douzone |
| AndonDB | **13 GB** | 3 | ANDON alerts |
| SmartFramework | **12 GB** | **61** | UI Engine (7,605 bindings) |
| SmartFactoryIncubator | **7 GB** | 50 | R&D Sandbox |
| erpdb | **6 GB** | 884 | ERP utility (Korean) |
| VINATECH_POP | **2 GB** | **42** | POP/Kiosk terminal |
| VINATECH_SPREADSHEET | 1.6 GB | — | Excel Online |
| DZICUBE | 1.4 GB | — | Bizbox Alpha |
| WCMS_STANDARD_NEW | 0.6 GB | — | Cash Management |
| streamdocs | 0.3 GB | — | PDF Viewer |
| VINATECH_DATA_KSOX | 34 MB | — | Compliance |
| VINATECH_WEBSOCKET | 12 MB | — | WebSocket |

### 21 Custom VVT Functions:
| Function | Type | Mô tả |
|---|---|---|
| `fn_VVT_StagePrices` | ITVF | **★ Tính giá công đoạn** |
| `fn_VVT_StagePricesINCREMENTAL` | ITVF | Giá lũy tiến |
| `fn_VVT_StagePricesMODULE` | ITVF | Giá Module |
| `fn_VVT_StagePricesNEW` | ITVF | Giá mới |
| `fn_VVT_getdatebyVendorLot` | Scalar | **★ Parse date từ vendor lot** (⚠️ risk crash!) |
| `fn_VVT_getdatebyVendorLot_MergeCode` | Scalar | Variant cho merged codes |
| `fn_VVT_getLastestBarCode` | Scalar | **Lấy barcode mới nhất** |
| `fn_VVT_QCPARTCODE` | ITVF | **Lọc mã lỗi QC** cho PQC gate |
| `fn_VVT_ElectrodeCodeStagePrice` | ITVF | Giá electrode theo code |
| `fn_VVT_ElectrodeTYPEweight` | ITVF | Cân nặng electrode theo type |
| `fn_VVT_ElecErrorPriceMeter2KG` | ITVF | Chuyển đổi mét→kg electrode |
| `fn_VVT_ElecMixingKg2Met` | ITVF | Chuyển đổi kg→mét mixing |
| `fn_VVT_PartnoModel` | ITVF | Mapping PartNo→Model |
| `fn_VVT_Stage2Weight` | ITVF | Cân nặng theo stage |
| `fn_VVT_WeightUnit598_723` | ITVF | Đơn vị cân B598/F723 |
| `fn_VVT_AccountTypeWarehouseType` | ITVF | Loại kho kế toán |
| `fn_VVTF4_GetMarkingDC` | Scalar | Lấy Marking DC (Hưng Yên) |
| `fnVVT_BasicRoutingCode` | Scalar | Mã routing cơ bản |
| `fnVVT_Machine2LineCode` | Scalar | **Mapping máy→line** |
| `VVT_INSTR` | Scalar | Custom INSTR function |

---

## 23. 🔬 M-Series: MEA — Electrode Analysis & Measurement (22 screens)

> MEA = Measurement of Electrode Assembly. Bộ phân tích và đo lường điện cực chuyên sâu.

| TCode | Caption | Chức năng |
|---|---|---|
| `M130` | RawMaterialInput | NVL cấp vào MEA |
| `M150` | MEARouteInspectionHistory | Lịch sử kiểm tra route |
| `M160` | MEAElectrodeMeasureHist | **Lịch sử đo điện cực** |
| `M170` | MEAProdRouteInspectionHistory | Lịch sử kiểm tra route SX |
| `M180` | MEARawMaterialInputHistForSample | NVL sample input |
| `M190` | MEARawMaterialInputFullHist | Full NVL history |
| `M195` | MEAElectrodeMixingHist | **Lịch sử mixing điện cực** |
| `M210` | MEA_SetListForOqcLotManagement | OQC Lot MEA |
| `M220` | MEA_MaterialOqcInfoSampleManagement | OQC Sample MEA |
| `M310` | MEAProductStock | **Tồn kho MEA** |
| `M410` | MEARawMaterialStock | Tồn NVL MEA |
| `M910` | MEAClassInfo | Phân loại MEA |
| `M920` | MEARawMaterialInfo | Thông tin NVL MEA |
| `M930` | MEABlueprintInfo | **Bản vẽ MEA** |

---

## 24. 💰 T-Series: Cost Management (13 screens)

> Quản lý giá thành sản xuất theo công đoạn (Manufacturing Cost by Route).

| TCode | Caption | Chức năng |
|---|---|---|
| `T110` | ManufacturingCostByRouteInfo | **Giá thành theo route** |
| `T120` | ManufacturingCostApplyInfo | Áp dụng giá thành |
| `T130` | ManufacturingCostExtend | Giá thành mở rộng |
| `T742` | SlittingLotMaterial | NVL Slitting (cross-ref KB_05) |
| `T888` | Thông Tin Phế | **Quản lý phế liệu** |
| `T990` | PageUrl | URL cấu hình page |

---

*Cập nhật: 2026-06-18 — Deep discovery từ production DB (Phases 1-4) + SmartFramework architecture + M/T-series*
