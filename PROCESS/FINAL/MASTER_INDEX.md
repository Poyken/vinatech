# 🗂️ MASTER INDEX — TOÀN THƯ TRA CỨU KIẾN TRÚC K-SYSTEM ACE (FINAL)

> **Mục Đích:** Mục lục kỹ thuật định vị nhanh tất cả 17 phân hệ, 213 nhánh quy trình, 4.473 chương trình, các bảng dữ liệu cốt lõi, và 7 tuyến đường huyết mạch liên thông hệ sinh thái Vinatech.  
> **Hệ Thống:** YoungLimWon K-System Ace Web ERP Suite (`https://evn.vinatech.com/`)  
> **Cơ Sở Dữ Liệu:** `VINATECVN` (5.571 Tables) & `VINATECVNCommon` (1.319 Tables)  
> ← [Quay lại README](README.md) | 🛡️ [Quy tắc Agent](AI_AGENT_CONFIG/RULES.md)

---

## 📑 MỤC LỤC CHÍNH
1. [MỤC LỤC 17 PHÂN HỆ VÀ MÃ SEQUENCE](#1-mục-lục-17-phân-hệ-và-mã-sequence)
2. [TỪ ĐIỂN 10 HỌ TIỀN TỐ BẢNG DỮ LIỆU CỐT LÕI](#2-từ-điển-10-họ-tiền-tố-bảng-dữ-liệu-cốt-lõi)
3. [DANH BẠ CÁC CHƯƠNG TRÌNH TRỌNG ĐIỂM (PGMSEQ MASTER DIRECTORY)](#3-danh-bạ-các-chương-trình-trọng-điểm-pgmseq-master-directory)
4. [BẢN ĐỒ ÁNH XẠ KHÓA LIÊN THÔNG XUYÊN HỆ THỐNG (CROSS-SYSTEM KEY MAP)](#4-bản-đồ-ánh-xạ-khóa-liên-thông-xuyên-hệ-thống-cross-system-key-map)
5. [CẨM NANG LỆNH ĐIỀU PHỐI CLI HUB (KSYS.PS1)](#5-cẩm-nang-lệnh-điều-phối-cli-hub-ksysps1)

---

## 1. MỤC LỤC 17 PHÂN HỆ VÀ MÃ SEQUENCE

| Seq | Mã Code | Tên Tiếng Việt | Tên Tiếng Hàn | Số Quy Trình | Số Form | Bảng DB Cốt Lõi |
| :---: | :---: | :--- | :--- | :---: | :---: | :--- |
| **1** | `ADMIN` | Điều hành | 시스템관리 / 운영관리 | 17 | 357 | `_TCAUser`, `_TCAPrcMenu`, `_TCAPgmControls` |
| **100** | `MASTER` | Cơ bản | 기준정보 (Master Data) | 5 | 105 | `_TDAItem`, `_TDACust`, `_TDAVendor`, `_TDAWH` |
| **2** | `HRM` | Nhân sự | 인사관리 | 8 | 168 | `_THREmp`, `_THRDept`, `_THRPosition` |
| **3** | `PAYROLL` | Lương, thù lao | 급여 / 근태관리 | 30 | 630 | `_TPRAttendance`, `_TPRBasTaxTableEmpCntTax` |
| **4** | `ACCOUNTING`| Kế toán | 재무회계 (General Accounting) | 30 | 630 | `_TACSlip`, `_TACSlipD`, `_TACSlipAutoEnvRowCol`|
| **118** | `FINTECH` | Fintech | 펌뱅킹 / 금융연계 | 5 | 105 | `_TFTBankTrnx`, `_TFTAccountBalance` |
| **6** | `SALES` | Kinh doanh / Xuất khẩu | 영업 / 무역관리 | 23 | 483 | `_TSASalesOrder`, `_TSAInvoice`, `_TSAExportDoc` |
| **126** | `TAX_CLOSING`| 회계결산/신고 | Kế toán quyết toán & Kê khai thuế | 14 | 294 | `_TACTaxClosing`, `_TACVATDeclaration` |
| **7** | `PURCHASING`| Mua hàng / Nhập khẩu | 구매 / 자재조달 | 12 | 252 | `_TMAPurchaseReq`, `_TMAPOH`, `_TMAPOL` |
| **8** | `PRODUCTION`| Sản xuất / gia công ngoài | 생산 / 외주관리 | 23 | 483 | `_TPRWorkOrder`, `_TPRBOM`, `_TPRProdResult` |
| **9** | `QUALITY` | Chất lượng sản phẩm | 품질관리 (QA/QC) | 7 | 147 | `_TQCInspIQC`, `_TQCInspPQC`, `_TQCInspOQC` |
| **10** | `INVENTORY` | Vật liệu | 자재 / 수불관리 | 17 | 357 | `_TMAItemStock`, `_TMAItemStockLot`, `_TDAWH` |
| **11** | `COSTING` | Giá vốn | 원가관리 (Costing & COGS) | 5 | 105 | `_TCOUnitProductCost`, `_TCODirectMat` |
| **15** | `EDI_B2B` | Đặt hàng / nhận đơn đối tác| B2B 수발주 (Partner EDI) | 1 | 21 | `_TEDIPartnerOrder`, `_TEDIPartnerDelivery` |
| **17** | `ESS` | ESS | 임직원 자기서비스 | 3 | 63 | `_TESSPaySlip`, `_TESSLeaveReq` |
| **18** | `DASHBOARD`| Mở đầu | 시작하기 (Dashboard) | 12 | 252 | `_TCOMDashboardWidget`, `_TCOMNotice` |
| **132** | `K_SMART` | K-스마트 | 스마트팩토리 연동 (Bridge MES) | 1 | 21 | `_TSFInterfaceWO`, `_TSFInterfaceProdResult` |
| **TỔNG**| **17** | **Toàn diện** | **Hệ thống ERP Vinatech** | **213** | **4.473**| **6.890 Tables (5.571 Bis + 1.319 Comm)** |

---

## 2. TỪ ĐIỂN 10 HỌ TIỀN TỐ BẢNG DỮ LIỆU CỐT LÕI

| Tiền Tố | Họ Phân Hệ | Số Lượng Bảng Ước Tính | Vai Trò Nghiệp Vụ Cốt Lõi |
| :---: | :--- | :---: | :--- |
| **`_TCA*`** | Common / System Admin | ~1.400 | Quản trị người dùng, từ điển đa ngôn ngữ, định nghĩa cột lưới, nút bấm và phân quyền. |
| **`_TDA*`** | Master Data | ~350 | Danh mục gốc: Sản phẩm/vật tư, khách hàng, nhà cung cấp, tỷ giá, kho bãi (`IsMES`). |
| **`_TAC*`** | Accounting & Finance | ~1.100 | Chứng từ kế toán nợ/có, sổ cái, tài sản cố định, quy tắc hạch toán tự động. |
| **`_TPR*`** | Production & Manufacturing | ~950 | Lệnh sản xuất, định mức kỹ thuật BOM, tiến độ công đoạn, máy móc, báo phế/lỗi. |
| **`_TMA*`** | Material & Warehouse | ~800 | Đơn mua hàng (PO), nhập xuất kho, quản lý thẻ kho chi tiết theo mã LOT. |
| **`_TSA*`** | Sales & Distribution | ~600 | Đơn đặt hàng bán, hóa đơn xuất khẩu, kiểm định thương mại quốc tế. |
| **`_TQC*`** | Quality Assurance (QA/QC) | ~250 | Nghiệm thu đầu vào IQC, kiểm soát công đoạn PQC, kiểm tra xuất xưởng OQC, mã lỗi NG. |
| **`_THR*`** | Human Resources & Payroll | ~500 | Hồ sơ 825 CBNV, phòng ban, chấm công, thang bảng lương, biểu tính thuế TNCN. |
| **`_TCO*`** | Costing & COGS | ~200 | Tập hợp chi phí NVL, nhân công, khấu hao máy móc để tự động tính giá thành đơn vị. |
| **`_TCOM*`**| Common Shared Framework | ~150 | Lịch làm việc ca kíp nhà máy, tham số môi trường và mã quy đổi đơn vị đo. |

---

## 3. DANH BẠ CÁC CHƯƠNG TRÌNH TRỌNG ĐIỂM (PGMSEQ MASTER DIRECTORY)

| PgmSeq | PgmId | Tên Màn Hình Tiếng Việt | Phân Hệ | Vai Trò Vận Hành & Khóa DB |
| :---: | :--- | :--- | :---: | :--- |
| **`522308`** | **`FrmWPDLotList`** | **Truy vấn truy xuất LOT (Lot 360° Trace)** | **Sản xuất (08)** | Màn hình tối cao: Lưới 1 Routing, Lưới 2 Tiêu hao BOM, Lưới 3 PO Vendor. Khóa: `LotNo`, `ItemSeq`. |
| **`524859`** | **`FrmWLGMakingLotNoENV`** | **Thiết lập tạo tự động LotNo** | **Vật liệu (10)** | Cấu hình quy tắc sinh số Lot (Prefix, Năm/Tháng, Serial). Khóa: `LotEnvSeq`. |
| **`502903`** | **`FrmWLGWHLOTStockRealList`**| **Truy vấn kiểm kê thực tế kho LOT** | **Vật liệu (10)** | Số dư tồn kho thực tế theo từng mã Lot tại kho chỉ định. Khóa: `WHSeq`, `LotNo`. |
| **`521504`** | **`FrmWLGWHLOTStockSumList`** | **Truy vấn tổng hợp xuất hàng LOT** | **Vật liệu (10)** | Tổng hợp xuất kho theo mã Lot và mục đích xuất. Khóa: `ItemSeq`, `LotNo`. |
| **`525585`** | **`FrmWCMUserEntrySinCompanyWeb`** | **Đăng ký người sử dụng** | **Điều hành (01)**| Quản lý tài khoản đăng nhập Web và gán nhân viên. Khóa: `UserSeq`, `EmpSeq`. |
| **`524337`** | **`FrmWCMPrcMenuGroupSecuEntry`** | **Đăng ký quyền hạn theo nhóm** | **Điều hành (01)**| Ma trận gán quyền nhóm người dùng theo Process Menu. Khóa: `UserGrpSeq`, `PrcMenuSeq`. |
| **`526700`** | **`FrmWCMPrcMenuPgmGroupSecuExcptAll`**| **Ngoại lệ bảo mật chương trình** | **Điều hành (01)**| Cấp/chặn chi tiết từng nút bấm và form cho nhóm. Khóa: `UserGrpSeq`, `PgmSeq`. |
| **`10002131`**| **`FrmSFSmartFactoryBridge`**| **[K-SMART] Thông tin cơ bản** | **K-Smart (132)**| Cầu nối đồng bộ Lệnh SX, BOM, Tồn kho với NAIS MES. Khóa: `InterfaceSeq`. |

---

## 4. BẢN ĐỒ ÁNH XẠ KHÓA LIÊN THÔNG XUYÊN HỆ THỐNG (CROSS-SYSTEM KEY MAP)

```
┌─────────────────────────┬──────────────────────────┬─────────────────────────────┬────────────────────────────┐
│ Nghiệp Vụ Liên Thống    │ Bảng Khóa K-System Ace   │ Bảng Khóa NAIS MES / POP    │ Bảng Khóa Groupware / ERP  │
├─────────────────────────┼──────────────────────────┼─────────────────────────────┼────────────────────────────┤
│ 1. Danh mục Vật tư/SP   │ _TDAItem.ItemNo          │ STB_MaterialMaster.MatCode  │ NEOE.MA_ITEM.CD_ITEM       │
│ 2. Định mức kỹ thuật BOM│ _TPRBOM.ParentItemSeq    │ STB_MaterialBOM.ParentMat   │ NEOE.PR_BOM.CD_ITEM        │
│ 3. Lệnh sản xuất ngày   │ _TPRWorkOrder.WorkOrderNo│ STB_DayProdPlan.DayPlanNo   │ GW.VINA_DOC_DAILY_PLAN     │
│ 4. Lô hàng & Barcode    │ _TPRProdResult.LotNo     │ STB_SetInfo.LotNo / Barcode │ GW.VINA_DOCUMENT_POH.NO_PO │
│ 5. Tiến độ gia công     │ _TPRProdResult.GoodQty   │ STB_ProdRouteHist.ProdQty   │ POP.MongoToMesPerformance  │
│ 6. Kho hàng & Trừ kho   │ _TDAWH (IsMES = 'Y')     │ STB_MaterialStock           │ NEOE.PU_POL.CD_SL          │
│ 7. Hồ sơ nhân viên      │ _THREmp.EmpNo            │ SmartFramework.STB_UserMst  │ GW.V_ORG_USER.USER_ID      │
│ 8. Chứng từ kế toán     │ _TACSlip.RefDocNo        │ N/A (Hạ tầng vật lý)        │ GW.VINA_DOCUMENT_SAVE_CODE │
└─────────────────────────┴──────────────────────────┴─────────────────────────────┴────────────────────────────┘
```

---

## 5. CẨM NANG LỆNH ĐIỀU PHỐI CLI HUB (KSYS.PS1)

Trung tâm chỉ huy `.\ksys.ps1` hỗ trợ các cú pháp chuẩn:

| Cú pháp thực thi | Chức năng thực hiện |
| :--- | :--- |
| `.\ksys.ps1 help` | Hiển thị bảng trợ giúp và danh mục lệnh. |
| `.\ksys.ps1 find "<Keyword>"` | Tìm kiếm siêu tốc qua 17 phân hệ, 213 quy trình và form IDs. |
| `.\ksys.ps1 trace "<LotNo>"` | Truy vết nguồn gốc Lô hàng 360° theo logic `FrmWPDLotList`. |
| `.\ksys.ps1 module [-Seq <N>]` | Liệt kê danh mục 17 phân hệ hoặc xem chi tiết một phân hệ cụ thể. |
| `.\ksys.ps1 schema -Prefix <_T>`| Liệt kê các bảng CSDL theo họ tiền tố (ví dụ `-Prefix _TPR`). |
| `.\ksys.ps1 schema -Table <T>` | Tra cứu chi tiết cột, kiểu dữ liệu và mô tả của bảng. |
| `.\ksys.ps1 bridge` | Kiểm tra tình trạng kết nối phân hệ cầu nối `K-스마트` (Module 132). |
| `.\ksys.ps1 health` | Kiểm tra độ trễ mạng và khả năng kết nối tới CSDL `VINATECVN`. |
