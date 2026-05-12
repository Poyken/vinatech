# SOLO CONTEXT OVERVIEW — Vinatech MES (NAIS)
> Phạm vi: đọc tất cả file trong thư mục `database` **trừ `.docx`** (theo yêu cầu).  
> Nguyên tắc: khi trả lời/trace lỗi, SOLO **chỉ kết luận dựa trên file nguồn và bằng chứng truy vấn (SELECT/log)**, không suy đoán.

## 1) Bản chất thư mục này là gì?
Đây là “knowledge base” + script SQL phục vụ vận hành/trace bug hệ thống **Vinatech MES** (NAIS / SmartFramework) với trọng tâm:
- Tra cứu lỗi theo màn hình (B597, B523, F330, …)
- Quy trình trace từ UI → Stored Procedure → bảng dữ liệu/Log
- Tài liệu “DataFlow” mô tả vòng đời dữ liệu theo Phase 0→5

## 2) Quy tắc vận hành bắt buộc (đọc trước khi debug)
Nguồn: `AI_OPERATIONAL_RULES.md`
- **Không chạy I/U/D trực tiếp trên Production.** Chỉ đề xuất script, user tự chạy tay.
- **Luôn SELECT trước khi UPDATE/DELETE** và “backup bằng SELECT”.
- Khi cần sửa/đọc Stored Procedure: **phải fetch bản mới nhất từ DB** trước khi phân tích/sửa.
- Ưu tiên tra cứu Knowledge Base trước (KB_INDEX.md).

## 3) “Single source of truth” để hiểu flow
Nguồn: `CORE_WORKSPACE_MAP.md`
1) `MES_MASTER_KNOWLEDGE_BASE\Vinatech_MES_Complete_DataFlow.md`  
   - Tài liệu kỹ thuật lớn nhất; giải thích kiến trúc metadata-driven và dataflow theo Phase.
2) `MES_MASTER_KNOWLEDGE_BASE\KB_INDEX.md`  
   - Index để mở đúng file KB theo nhóm lỗi.
3) `MES_MASTER_KNOWLEDGE_BASE\KB_05_TRACE_BUG_METHODOLOGY.md`  
   - Quy trình trace 5 bước + truy vấn mẫu + cách đọc log.

## 4) Bản đồ dataflow theo Phase (tóm tắt)
Nguồn: `MES_MASTER_KNOWLEDGE_BASE\Vinatech_MES_Complete_DataFlow.md`
- **Phase 0 — Master Data (BOM & Routing)**  
  SPs tiêu biểu: `usp_BomHeader_iud`, `usp_BomDetail_iud`, `usp_RouteInfo_iud`
- **Phase 1 — Inbound & IQC (Kho NVL + kiểm tra)**  
  SPs tiêu biểu: `usp_RawMaterialInputHist_iud`, `usp_MaterialQcInfo_iud`, `usp_MaterialWarehouseInOutHist_iud`, `usp_VVTMaterialWarehouse_validFIFO`
- **Phase 2 — Electrode**  
  SPs tiêu biểu: `pop_Electrode_Coating_iud`, `pop_Electrode_RollPressing_iud`, `usp_ElectrodeSlittingResult_iud`, `usp_ElectrodeWasteInfoNew_iud`
- **Phase 3 — Assembly & Routing (core scan engine)**  
  SP core: `usp_DoProcessProdRouteHist`  
  Backflush BOM / kho: `usp_DoProcessProdGIMaterialByBOM`, `usp_DoProcessProdGRMaterialByOne`
- **Phase 4 — Aging/Sorting & Defect**  
  SPs tiêu biểu: `usp_InsertDataAgingAndSorting`, `usp_DefectInfo_iud`
- **Phase 5 — Packing & FG stock-in**  
  SPs tiêu biểu: `usp_DivideAndPrintPackagingLabels`, `usp_Vietnam_DoProcessBigBoxPacking_VVT_F3`, `usp_VN_FinishGood_BG_StockIn_iud`

## 5) “Entry points” thực tế khi trace bug
Nguồn: `KB_05_TRACE_BUG_METHODOLOGY.md` + `Vinatech_MES_Complete_DataFlow.md`
Khi user báo lỗi ở 1 màn hình:
1) Tra `SmartFramework.dbo.STB_ScreenInfo` theo `TCode` (VD: HN523, B597…)
2) Tra `SmartFramework.dbo.STB_ScreenObjects` để biết nút bấm gọi SP nào (Entry SP)
3) Verify state của Lot/Barcode trong các bảng lõi:
   - `STB_SetInfo`, `STB_ProdRouteHist`, `STB_MaterialLotInfo`
4) Đọc log:
   - `STB_ProcessTerminalDataLog` (gói tin UI)
   - `STB_ProcedureLog` (biến/trace trong SP)

## 6) Knowledge Base theo nhóm lỗi (mở đúng file)
Nguồn: `MES_MASTER_KNOWLEDGE_BASE\KB_INDEX.md`
- **KB_01_UI_PHAN_QUYEN.md**: login, phân quyền, stage prices (B682/B781), lỗi in tem cơ bản…
- **KB_02_KHO_WMS.md**: kho NVL (F330/F312/F430/F110/F721), FIFO/expiry…
- **KB_03_SAN_XUAT.md**: JobDate, routing history, PO, defect qty, đổi line…
- **KB_04_DONG_GOI_IN_TEM.md**: đóng gói/in tem (B523/B789/B351/A419)…
- **KB_05_QC_ELECTRODE.md**: QC (B597/C443/C512) + điện cực/slitting (B552)…
- **KB_06_MASTER_DATA_TOOLS.md**: master data/model, SQL tools, manual bypass…

## 7) SQL artifacts trong thư mục gốc
- `fn_VVT_getdatebyVendorLot_MergeCode.sql`: **neo + hướng dẫn export** — body function lấy từ DB (`OBJECT_DEFINITION`); không nhân bản logic dài trong repo.
- `test_GBSN00_002.sql`: test regression `GBSN00-002` + lot `12SR03-4628` → kỳ vọng `2024-06-28` (chạy trên `SmartFactoryV2`).
- [`BUG_REPORT_TEMPLATE.md`](BUG_REPORT_TEMPLATE.md): form gửi bug/trace để đủ context.

## 8) Cách bạn đưa yêu cầu để mình trace nhanh (template)
Ưu tiên copy form trong [`BUG_REPORT_TEMPLATE.md`](BUG_REPORT_TEMPLATE.md). Tóm tắt tối thiểu:
1) **Màn hình/TCode**: (VD: B523, B597, HN523…)  
2) **Thao tác**: bấm nút gì / scan gì / lưu gì  
3) **Mã đối tượng**: Barcode / ControlNo / LotID / MaterialDocNo / PONo  
4) **Thời điểm**: ngày/giờ xảy ra (để lọc log)  
5) **Thông báo lỗi / ảnh chụp** / stacktrace (nếu có)  
6) **Môi trường**: production hay test; có được phép chạy SELECT không

