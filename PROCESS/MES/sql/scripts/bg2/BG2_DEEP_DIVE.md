# Bắc Giang 2 (VVT_F4) — Deep Dive

> **DB verified:** 2026-06-24 | **WorkCenter:** `VVT_F4` | **Company:** `VVT`

---

## 1. Cơ Sở Hạ Tầng

### WorkCenter
| Code | Name | Company |
|---|---|---|
| `VVT_F4` | Nhà Máy Bắc Giang 2 | VVT |

### Lines (3 dây chuyền Module)
| LineCode | LineName |
|---|---|
| `VVBG2MD-01` | BG2 Module Line #1 |
| `VVBG2MD-02` | BG2 Module Line #2 |
| `VVBG2MD-03` | BG2 Module Line #3 |

> ⚠️ Chỉ có Module lines — **không có Cell lines, không có Electrode lines.**

### Routes (2 dòng sản phẩm)

**Nordex (ND01-ND08):** 8 công đoạn
| Route | Tên công đoạn |
|---|---|
| `ND01` | Wave soldering, Label |
| `ND02` | AOI inspection |
| `ND03` | RTV Silicon |
| `ND04` | Balancing, SD checking |
| `ND05` | Measure the F and AC-ESR |
| `ND06` | Module Assembly, Label |
| `ND07` | Module Capacitance, ESR(DC,AC) Check |
| `ND08` | Packing, Label |

**Vietpower (VP01-VP18):** 18 công đoạn
| Route | Tên công đoạn |
|---|---|
| `VP01` | PCBA Wave Soldering, Label |
| `VP02` | AOI inspection |
| `VP03` | RTV Silicone |
| `VP04` | PCBA FCT |
| `VP05` | Conformal Coating (Top side) |
| `VP06` | Conformal Coating (Bottom side 1st) |
| `VP07` | **Conformal Coating (Bottom side 2nd)** ← hardcoded trong SP |
| `VP08` | SCM Assembly |
| `VP09` | SCM Top Cover Assembly, Label |
| `VP10` | SCM Ground Bond Test |
| `VP11` | SCM Hi-Pot Test |
| `VP12` | **SCM FCT** ← hardcoded trong SP |
| `VP13` | Enclosure Assembly 1, Label |
| `VP14` | Enclosure Hi-pot |
| `VP15` | Enclosure Assembly 2, Label |
| `VP16` | Enclosure FCT |
| `VP17` | Burn-in Test |
| `VP18` | **Enclosure Packing** ← hardcoded trong SP |

> ⚠️ **Vấn đề:** SP `usp_Vietnam_GetProdPackingForBarcodeForBacGiang2` hardcode `VP07, VP18, VP12`. Nếu thêm route mới → phải sửa SP.

### Sản Phẩm (8 models)
| MaterialCode | MaterialName | ProductGroup |
|---|---|---|
| `BEASSY-001` | 100099 | ETC |
| `BEASSY-005` | 030187 | ETC |
| `BEPCBA-001` | 164181 | MD-PCB |
| `EDVTMD-246` | VEM540R0335QG | ETC |
| `EDVTMD-246-002` | VEM540R0335QG CELL+CABLE ASSY MODULE | ETC |
| `EDVTMD-248` | 100099 | ETC |
| `EDVTSY-001` | 711711 | MD-PCB |
| `PBSJ00-001` | PCBA | MD-PCB |

---

## 2. Kiến Trúc Screens

### Menu BG2 (`BG2Factory` → Parent: `Vietnam_TOP_MENU`)

| TCode | Screen Name | Chức năng | Objects |
|---|---|---|---|
| **B779** | `RepairInfoBg2` | Quản lý sửa lỗi (Repair) | 11 |
| **B889** | `RepairHistory` | Lịch sử Repair | 4 |
| **C5300** | `VVTF4_CheckOQC` | OQC kiểm tra BG2 | 39 |
| **C5400** | `VVT_CoatingThicknessInspHist` | Đo chiều dày Coating | 2 |
| **K360** | `PrintLabelPCBNordex` | In tem PCB Nordex | 3 |
| **K361** | `HoanThanhCongDoanTheoY` | Hoàn thành công đoạn + lưu SL | 7 |
| **K366** | `ThongTinHienTrangLoiBG2` | Thông tin lỗi BG2 | 4 |
| **K781** | `KetQuaSanLuongHoanThanh` | Kết quả sản lượng hoàn thành | 2 |
| **Z366** | `DefectInfoReport` | Báo cáo lỗi | 2 |

### Screens ngoài menu nhưng liên quan BG2

| TCode | Screen Name | BG2 SP/Object |
|---|---|---|
| `B745` | `MergeMaterialLotBG2` | 9 objects — Gộp lot NVL BG2 |
| `FGBG2` | `ThanhPhamBacGiang2` | 2 objects — Thành phẩm BG2 |
| `F723` | `VVTF4_CellMaterialStockList` | 3 objects — Tồn kho NVL BG2 |

### Screens dùng chung có logic BG2 bên trong

| TCode | Screen | BG2-specific SP |
|---|---|---|
| `B530` | `VNT_ProdRouteByBarcode` | `usp_CompleteRouteFinalForBacGiang2` |
| `B540` | `AssyCardInfo` | `usp_RawMaterialInputHist_get_forBG2` |
| `C220` | `MaterialIqcInfoSampleManagement` | `usp_ModifyRevisionsVerFromC220_VVTF4` |
| `F330` | `MaterialReceiptAndPrintLabel` | Logic filter `VVT_F4` trong SP chung |

---

## 3. SPs — Phân Loại Theo Chức Năng

### 3.1 Repair System (Độc quyền BG2)

```
                    ┌─────────────────────────┐
                    │  B779 (RepairInfoBg2)   │
                    └─────────┬───────────────┘
                              │
           ┌──────────────────┼──────────────────┐
           ▼                  ▼                  ▼
  AddRepairInfor_BG2   RepairSuccess_BG2   RepairFail_BG2
  (Chuyển vào repair)  (Sửa OK → quay      (Sửa thất bại
   Insert STB_RepairInfor  lại sản xuất)     → scrap)
           │                  │                  │
           ▼                  ▼                  ▼
  STB_RepairInfor      StatusRepair = 1    StatusRepair = 2?
  (StatusRepair = 0)
```

| SP | Size | Chức năng |
|---|---|---|
| `usp_AddRepairInfor_BG2` | 3.2K | Chuyển barcode vào repair — validate `VVT_F4` only |
| `usp_RepairSuccess_BG2` | 1.7K | Xác nhận repair thành công → `StatusRepair = 1` |
| `usp_RepairFail_BG2` | 1.9K | Xác nhận repair thất bại |
| `usp_GetRepairInfor_BG2` | 1.7K | Lấy danh sách repair hiện tại |
| `usp_GetRepairInforHistory_BG2` | 1.2K | Lịch sử repair |
| `usp_MaterialInputRepair_iud` | 2.8K | IUD NVL repair (dùng chung) |

**Table:** `STB_RepairInfor` (2,322 records)
- `Barcode`, `RouteCode`, `DefectRepairCode`, `RepairCode`, `StatusRepair` (0=chờ, 1=OK), `Note`

### 3.2 Production Completion (Chốt công đoạn)

| SP | Size | Chức năng |
|---|---|---|
| `usp_CompleteRouteFinalForBacGiang2` | 3.0K | Chốt sản lượng công đoạn cuối |
| `usp_CancelCompleteRouteForBG2WithConditionPassOrFail` | 1.2K | **Gate:** chặn nếu chưa Pass/Fail |
| `usp_Vietnam_GetProdPackingForBarcodeForBacGiang2` | 1.4K | Xem trạng thái packing |
| `usp_SavePackingTime_VVT_F4` | 2.4K | Lưu thời gian packing |
| `usp_GetSavePackingPrintTimeFor_VVT_F4` | 2.3K | Lấy thời gian packing |

**Flow chốt công đoạn:**
```
B530 scan barcode
    → usp_CancelCompleteRouteForBG2WithConditionPassOrFail
        → Check STB_PassOrFailRouteStatus (phải có record Pass/Fail)
        → Nếu chưa → RAISERROR "chưa được đánh giá PASS hay FAIL"
    → usp_ChecRawMaterialWhenFinishProd
        → Check NVL đã bắn đủ chưa
    → Check CompleteRoute = 1? (đã chốt rồi?)
    → UPDATE STB_ProdRouteHist SET CompleteRoute = 1
```

**Table:** `STB_PassOrFailRouteStatus`
- `Barcode`, `RouteCode`, `WorkCenterCode`, `Status` (Pass/Fail), `CreatedDate`

### 3.3 OQC (Kiểm tra chất lượng)

| SP | Size | Chức năng |
|---|---|---|
| `usp_GetMaterialOQcInfo_VVTF4` | 10.4K | **Lấy danh sách OQC cho BG2** |
| `usp_Vietnam_MaterialOQcDetail_VVTF4_get` | 4.7K | Chi tiết OQC |
| `usp_DoUpdateMaterialQcInfo_Success` | — | Đánh giá Pass (dùng chung) |
| `usp_DoUpdateMaterialQcInfo_Fail` | — | Đánh giá Fail (dùng chung) |
| `usp_DoUpdateMaterialQcInfo_Hold` | — | Hold (dùng chung) |
| `usp_DoUpdateMaterialQcInfo_Rescreening` | — | Re-screening (dùng chung) |
| `usp_DoUpdateMaterialQcInfo_Complete` | — | Complete (dùng chung) |

**Screen C5300** — OQC BG2 = phiên bản tùy biến của C530 (OQC chung), có 39 objects riêng.

### 3.4 Lot Tracking & NVL

| SP | Size | Chức năng |
|---|---|---|
| `usp_LotTrackingInfo_VVTF4_get` | 6.5K | Tracking lot BG2 — DefectStatus + MaterialInput + Inspection |
| `usp_RawMaterialInputHist_get_forBG2` | 6.4K | Lấy lịch sử NVL nhập cho BG2 |
| `usp_RawMaterialInputHist_get_for_BG2_History` | 5.4K | Lịch sử NVL (historical) |
| `usp_VVTF4_CellMaterialLotInfo_get` | 19.4K | Tồn kho NVL BG2 |
| `usp_vvtf4_MaterialLotExpired_get` | 18.1K | NVL hết hạn BG2 |
| `usp_GetMaterialLotInfo_BG2_Test` | 4.6K | Test NVL BG2 |
| `usp_GetMaterialLotInfoPackingBG2` | 4.6K | NVL đóng gói BG2 |
| `usp_Vietnam_LocateOfRawMaterials_BG2` | 4.3K | Vị trí NVL BG2 |

### 3.5 Thành Phẩm & Kho

| SP | Size | Chức năng |
|---|---|---|
| `usp_VN_ShowAllFinishGoodMES_BG2` | **129.5K** | **SP LỚN NHẤT** — Hiển thị toàn bộ thành phẩm BG2 |
| `usp_VN_Add_ImportExcel_BG2` | 7.1K | Import Excel thành phẩm |
| `usp_VN_Update_ExportExcel_BG2` | 2.2K | Update export Excel |
| `usp_extension_warhouse_BG2` | 1.7K | Gia hạn kho BG2 |

**Table:** `STB_VN_FINISHGOODS_BG2` (13 records — mới bắt đầu)
- 42 cột — nhiều hơn FinishGoods thường (có thêm `LotNoPCBA`, `CODELOCTION`, `TYPEEXPORT`, etc.)

### 3.6 SPs Dùng Chung Có Logic BG2 (Quan Trọng!)

> Những SP này **không** tên BG2 nhưng **bên trong có IF VVT_F4** — sửa ảnh hưởng nhiều nhà máy!

| SP | Size | Vì sao liên quan BG2 |
|---|---|---|
| `usp_Vietnam_RawMaterialInputHist_uid` | **176.5K** | SP **LỚN NHẤT HỆ THỐNG** — có branch VVT_F4 |
| `usp_vvt_MaterialLotInfo_get` | 56.6K | Tồn kho chung — filter VVT_F4 |
| `usp_RawMaterialInputHist_iud` | 44.7K | IUD NVL — branch VVT_F4 |
| `usp_GetCommInspectionHistoryForBarcode` | 44.6K | CommInsp — branch BG2 |
| `usp_MaterialQcInfo_get` | 42.3K | QC header — branch VVT_F4 |
| `usp_MaterialDocDetail_iud` | 37.0K | Chi tiết phiếu kho — branch VVT_F4 |
| `usp_VNSparePartInfo_iud` | 35.8K | Spare part — branch VVT_F4 |
| `usp_MaterialWarehouseInOutHist_iud` | 30.6K | Xuất kho — branch VVT_F4 |
| `usp_DoAddMaterialLotExpiredRemindMail` | 31.0K | Email NVL hết hạn — branch BG2 |
| `usp_GetCommInspection_HistoryForBarcode_Vietnam` | 25.0K | CommInsp VN — branch BG2 |
| `usp_DoSendEmailForDefectReport` | 23.9K | Email defect — branch BG2 |
| `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` | 22.1K | Routing SX SmartApp — branch VVT_F4 |
| `usp_DoChangeMaterialDocLotInfo` | 21.3K | Thay đổi lot — branch VVT_F4 |
| `usp_RawMaterialInputHist_get` | 21.1K | Lấy NVL — branch BG2 |
| `usp_MaterialQcSampleResult_get` | 17.8K | QC sample — branch VVT_F4 |
| `usp_DoCreateSetInfoForProdQty_VNT` | 16.4K | Tạo SetInfo — branch VVT_F4 |
| `usp_LotTrackingInfo_get` | 16.3K | Lot tracking chung — branch VVT_F4 |
| `usp_HYStagePrices_iud` | 16.2K | Stage prices HY — reference BG2 |
| `usp_RawMaterialInputHist_popup` | 14.2K | Popup NVL — branch BG2 |
| `usp_GetProdRouteHistForBarcode_VNT` | 13.3K | Routing history — branch VVT_F4 |
| `usp_ViewWeighScale` | 13.2K | Cân trọng lượng — branch VVT_F4 |

---

## 4. Tables Riêng BG2

| Table | Records | Chức năng |
|---|---|---|
| `STB_RepairInfor` | 2,322 (97% duplicate!) | Lịch sử sửa lỗi (repair) |
| `STB_RawMaterialInputHistForBG2` | 7,862 | NVL nhập cho BG2 |
| `STB_BasicRawMaterialInputHistForBG2` | 17 | NVL cơ bản BG2 |
| `STB_VN_FINISHGOODS_BG2` | 13 | Thành phẩm BG2 |
| `STB_PassOrFailRouteStatus` | 3,543 (3,519 Pass / 24 Fail) | Gate Pass/Fail trước chốt |
| `STB_DefectInspectionDetail` | 949 | Chi tiết lỗi kiểm tra (BG2 dùng nhiều) |

---

## 5. Production Flow BG2

```
B310 (PO) → B450 (Plan ngày) → B530 (Nhập SX)
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
              Nhập ProdQty    Bắn NVL (B540)   Check NVL đủ?
                    │               │               │
                    ▼               ▼               ▼
            STB_ProdRouteHist  STB_RawMaterialInput  usp_ChecRawMaterial
                    │                                     │
                    ▼                                     ▼
            Đánh giá Pass/Fail                    CompleteRoute
            (STB_PassOrFailRouteStatus)      (usp_CompleteRouteFinal)
                    │                                     │
                    │         ┌────────────────┐          │
                    │    NG → │  B779 (Repair) │          │
                    │         │  Add → OK/Fail │          │
                    │         └────────────────┘          │
                    ▼                                     ▼
              C5300 (OQC)                          K361 (Chốt SL)
              Check QC                             Lưu packing time
                    │                                     │
                    ▼                                     ▼
              Pass/Fail/Hold                     FGBG2 (Thành phẩm)
```

---

## 6. Vấn Đề & Rủi Ro Phát Hiện

### 🔴 Critical Issues

1. **🚨 STB_RepairInfor có 97% duplicate records (2,253 / 2,322)**
   - Root cause: `usp_AddRepairInfor_BG2` line 93-101 dùng `SELECT FROM STB_DefectRepairInfo WHERE ControlNo = @ControlNo`
   - Nếu 1 lot có 3 defect codes → INSERT 3 rows (duplicate Barcode+RouteCode)
   - Check EXISTS (line 85) kiểm tra `RouteCode` nhưng INSERT không filter unique
   - **Fix:** Thêm `AND NOT EXISTS(SELECT 1 FROM STB_RepairInfor WHERE Barcode=@Barcode AND RouteCode=@RouteCode AND DefectRepairCode=dri.FindRouteCode)` hoặc `DISTINCT`
   - **Data fix:** Cần dedup 1,492 records thừa

2. **Hardcoded Route Codes**
   - `usp_Vietnam_GetProdPackingForBarcodeForBacGiang2`: hardcode `VP07, VP18, VP12`
   - Nếu thêm route mới hoặc Nordex → SP không hoạt động
   - **Fix:** Thay bằng query dynamic hoặc config table

3. **SP quá lớn không maintain được**
   - `usp_VN_ShowAllFinishGoodMES_BG2`: 129.5K chars — impossible to debug
   - `usp_Vietnam_RawMaterialInputHist_uid`: 176.5K chars — shared SP, sửa = risk

4. **Thiếu WITH(NOLOCK) nhất quán**
   - `usp_AddRepairInfor_BG2`: query `STB_ProdRouteHist` không NOLOCK
   - `usp_CompleteRouteFinalForBacGiang2`: UPDATE trực tiếp không NOLOCK ở SELECT

### 🟡 Moderate Issues

5. **Commented-out code trong production**
   - `usp_CompleteRouteFinalForBacGiang2`: block INSERT vào `STB_MaterialQcInfo` bị comment ra (line 46-96)
   - Có thể là intentional disable nhưng không có ghi chú lý do

6. **Naming inconsistency**
   - Mix giữa `BG2`, `VVTF4`, `BacGiang2`, `VVT_F4` trong tên SP
   - Khó search, khó maintain

7. **STB_DefectRepairInfo có 14 bảng backup**
   - `STB_DefectRepairInfo_200814_CHAE`, `_20220126`, `_20220306`... đến `_20260527`
   - Dấu hiệu data hay bị lỗi → cần backup trước khi sửa

### 🟢 Minor Issues

8. **Typos trong error messages**
   - "rổi" thay vì "rồi" (line 35, CompleteRouteFinal)
   - "côn đoạn" thay vì "công đoạn" (line 29)

9. **Logic condition phức tạp**
   - `usp_AddRepairInfor_BG2` line 66-72: nested IF khó đọc, dễ gây bug

---

## 7. Data Volume (2026-06-24)

| Metric | Value |
|---|---|
| Repair records | 2,322 |
| Raw material BG2 | 7,862 |
| Finish goods BG2 | 13 (mới bắt đầu) |
| Lines | 3 (Module only) |
| Routes | 26 (8 Nordex + 18 Vietpower) |
| Products | 8 |
| BG2-specific SPs | 26 |
| Shared SPs with BG2 logic | 44+ |
| BG2-specific screens | 12 |

---

## 8. So Sánh Với Các Nhà Máy Khác

| Feature | BN (VVT_F2) | BG2 (VVT_F4) | HY (VVT_F5) |
|---|---|---|---|
| Lines | Cell + Module + Electrode | Module only | Cell + Module (Electrode planned) |
| Repair system | ❌ Không có | ✅ Hệ thống riêng | ❌ Không có |
| PassOrFail gate | ❌ | ✅ `STB_PassOrFailRouteStatus` | ❌ |
| OQC screen | C530 (chung) | C5300 (39 obj, riêng) | HY530 (43 obj, riêng) |
| FinishGoods | `STB_VN_FINISHGOODS` | `STB_VN_FINISHGOODS_BG2` (riêng) | Dùng chung |
| Complexity | Cao (Electrode + Cell) | Trung bình (Module + PCBA) | Đang xây dựng |

---

*DB verified: 2026-06-24 — SmartFactoryV2 + SmartFramework*
