# KB_35 — Triggers, Agent Jobs, Label System & Database Audit Trail

> **Verified against DB:** 2026-06-18
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 🔫 Database Triggers — Bản đồ đầy đủ (33 triggers, ALL ACTIVE)

> Triggers là cơ chế auto-fire: mỗi khi INSERT/UPDATE/DELETE trên bảng cha → trigger tự động thực thi logic ngầm. **Đây là lý do nhiều bug "ma" xảy ra mà developer không hiểu.**

### 1.1 Material Doc Triggers (WMS — Trừ kho tự động)
| Trigger | Bảng cha | Mô tả |
|---|---|---|
| `tgMaterialDocDetailForInsert` | `STB_MaterialDocDetail` | **INSERT** → Auto-tạo bản ghi kho |
| `tgMaterialDocDetailForUpdate` | `STB_MaterialDocDetail` | **UPDATE** → Cập nhật số lượng kho |
| `tgMaterialDocDetailForDelete` | `STB_MaterialDocDetail` | **DELETE** → Hoàn trả kho |
| `tgMaterialDocInfoDelete` | `STB_MaterialDocInfo` | Delete phiếu → cascade |
| `tgMaterialDocLotInfoIUD` | `STB_MaterialDocLotInfo` | **IUD** → Cập nhật Lot kho |
| `tgMaterialDocPickingPlanIUD` | `STB_MaterialDocPickingPlan` | Picking plan → kho |

> ⚠️ **CRITICAL:** Đây là lý do khi xóa phiếu nhập kho F330 → tồn kho tự động giảm mà KHÔNG cần gọi SP riêng.

### 1.2 Material Lot Tracking Triggers
| Trigger | Bảng cha | Mô tả |
|---|---|---|
| `tgMaterialLotInfoForInsert` | `STB_MaterialLotInfo` | Tạo Lot mới → tracking |
| `tgMaterialLotInfoForUpdate` | `STB_MaterialLotInfo` | Cập nhật Lot → audit |
| `tgMaterialLotInfoForDelete` | `STB_MaterialLotInfo` | Xóa Lot → audit |

### 1.3 DayPlanNo Auto-Fill Triggers
| Trigger | Bảng cha | Mô tả |
|---|---|---|
| `utr_STB_SetInfo_DayPlanNo_iu` | `STB_SetInfo` | Tạo/cập nhật SetInfo → auto-fill DayPlanNo |
| `utr_ProdRouteHist_DayPlanNo_iu` | `STB_ProdRouteHist` | Route history → auto-fill DayPlanNo |
| `utr_ElectrodeCoatingInfo_DayPlanNo_iu` | `STB_ElectrodeCoatingInfo` | Electrode coating → DayPlanNo |
| `utr_ElectrodeRollPressingInfo_DayPlanNo_iu` | `STB_ElectrodeRollPressingInfo` | Roll pressing → DayPlanNo |
| `utr_ElectrodeSlittingResult_DayPlanNo_iu` | `STB_ElectrodeSlittingResult` | Slitting → DayPlanNo |
| `utr_ElectrodeWasteInfo_DayPlanNo_iu` | `STB_ElectrodeWasteInfoNew` | Waste → DayPlanNo |
| `utr_DefectRepairInfo_DayPlanNo_iu` | `STB_DefectRepairInfo` | Defect repair → DayPlanNo |

### 1.4 Audit Trail & Sync Triggers
| Trigger | Bảng cha | Mô tả |
|---|---|---|
| `utr_ModelSpecHist_insert` | `STB_ModelSpec` | **Thêm spec** → lưu lịch sử |
| `utr_ModelSpecHist_update` | `STB_ModelSpec` | **Sửa spec** → lưu lịch sử |
| `utr_ModelSpecHist_delete` | `STB_ModelSpec` | **Xóa spec** → lưu lịch sử |
| `utr_MachineInfoChangeHist` | `STB_MachineMaster` | Sửa máy → lưu lịch sử |
| `utr_SetInfoRemoveHist` | `STB_SetInfo` | Xóa SetInfo → lưu lịch sử |
| `utr_MaterialCodeByLine_i` | `STB_ProdRouteHist` | **INSERT** Route → log MaterialCode by Line |
| `utr_DeleteCheckScheduleExceptionHist` | `STB_LineInfo` | Xóa Line → cleanup |
| `trg_syncSTB_DefectRepairInfo` | `STB_DefectRepairInfo` | Đồng bộ defect repair |

### 1.5 Special Triggers
| Trigger | Bảng cha | Mô tả |
|---|---|---|
| `TR_DayProdPlan_Close` | `STB_DayProdPlan` | **★ Close DPP** → Auto-actions when closing daily plan |
| `TRG_FinalProductInfo` | `STB_FinalProductInfo` | Thành phẩm cuối → auto-process |
| `TR_RawMaterialInputHist_DelegateLog_Insert` | `STB_RawMaterialInputHist` | Insert NVL → delegate log |
| `TR_RawMaterialInputHist_DelegateLog_update` | `STB_RawMaterialInputHist` | Update NVL → delegate log |
| `utr_ProductStockInfoUpload_i/u/d` | `STB_ProductStockInfoUpload` | Upload tồn kho → 3 triggers (IUD) |
| `utr_UpdateDeleteRollbackForLogTable` | `DDLChangeLog` | **Prevent delete/update DDL log** |
| `utr_ProcedureChangesLog` | *(Server-level DDL)* | **★ DDL trigger** — Log mọi ALTER/CREATE/DROP SP |

---

## 2. 📋 Agent Jobs — 36 Active Jobs

### 2.1 Cross-Factory Sync Jobs (CRITICAL — 2 RUNNING)
| Job | SP/Command | Schedule | Mô tả |
|---|---|---|---|
| `Tranfer_BacGiang_To_BacNinh` | `usp_VN_Finshed_Waiting_BG` | Continuous | **★ RUNNING** — Sync FG BG→BN |
| `Tranfer_BN_BG` | (reverse) | Continuous | **★ RUNNING** — Sync BN→BG |
| `Transfer_FG00_To_C560` | `usp_vn_Transfer_FG00_To_C560` | Scheduled | FG→C560 product receipt |
| `VN_FINISHEDGOODS_TO_KR_FINISHEDGOODS` | Dynamic SQL | Scheduled | **VN→Korea** FG sync |

### 2.2 Alert/Email Jobs
| Job | SP/Command | Mô tả |
|---|---|---|
| `MakeMaterialExpirationEmailAlert` | `usp_DoAddMaterialLotExpiredRemindMail` | **Email NVL hết hạn** |
| `MakeEmailEquipmentCalibrationCheck` | (email) | Email hiệu chuẩn thiết bị |

### 2.3 Data Capture/Snapshot Jobs
| Job | Mô tả |
|---|---|
| `vvt_finishgoodCapture` | Capture FG snapshot |
| `VVT_GETDATA_FINISHEDGOOD` | Get FG data periodic |
| `vvt_materialSnapshot` | NVL snapshot |
| `vvt_semiInventoryCapture` | Bán thành phẩm inventory capture |
| `vvt_productreceipt560` | Product receipt C560 |

### 2.4 System/Maintenance Jobs
| Job | Mô tả |
|---|---|
| `SyncFingerData` | Đồng bộ vân tay chấm công |
| `NameShift` | Ca kíp tự động |
| `VCM_thoigian_08PM` | Tự động đóng ca 8PM |
| `CLR App Domain Reloading` | CLR maintenance |
| `CDW_VINATECH_MESTESTDB_SVR-VINAT2_0` | Cross-server sync |
| `syspolicy_purge_history` | Cleanup |
| `ERPU_DB_full-backup-daily` | **Full backup daily** |

---

## 3. 🏷️ Customer Label System (32 tables)

> Mỗi khách hàng lớn có một bảng Label riêng + SP in tem riêng. Đây là lý do thêm khách hàng mới = phải tạo bảng + SP mới.

### Customer-Specific Label Tables:
| Customer | Table | Ghi chú |
|---|---|---|
| **Acbel** | `STB_AcbelLabelPrintHist` | Power supply customer |
| **DigiKey** | `STB_DigiKeyLabelInnerPrintHist` | Electronic components |
| **Farnell** | `STB_FarnellLabelPrintHist` | UK distributor |
| **Jabil** | `STB_JabilManualLabelPrintHist` | EMS manufacturer |
| **Jabil Mexico** | `STB_JabilMexicoLabelPrintHist` | Mexico plant |
| **Klemove** | `STB_KlemoveLabelInfo` | Automotive |
| **Nordex** | `STB_NordexPackingLabelPrintingHist` | Wind turbine |
| **PAC** | `STB_PACLablePrintHist` | PAC customer |
| **PAC V1** | `STB_PACLabelPrintHistV1` | PAC version 1 |
| **Sanmina India** | `STB_SanminaIndiaLabelPrintHist` | India plant |
| **Bloom** | `STB_VN_BloomBoxLabelPrintHist` | Bloom Energy |
| **VinaEnesol** | `STB_VINAEnesolBoxLabelPrintHist` | Internal VNE |
| **Foxconn** | `STB_VN_STAMP_FOXCONN` | Foxconn stamp format |
| **Hong Kong** | `STB_VN_STAMP_HONGKONG` | HK customer stamp |
| **Thailand** | `STB_VN_STAMP_THAILO` / `STB_VN_THAILANSTAMP` | Thai customer |
| **Module** | `STB_VN_STAMP_MODULE` | Module label |

### System Label Tables:
| Table | Mô tả |
|---|---|
| `STB_ModelLabelInfo` | **★ Master** — Mapping Model→Label format |
| `STB_PackingLabelSpec` | Spec tem đóng gói |
| `STB_PackingLabelPrintHist` | Lịch sử in tem đóng gói |
| `STB_MarkingLabelPrintHist` | Lịch sử in tem marking |
| `STB_VietnamLabelPrintHist` | Lịch sử tem VN chung |
| `STB_Vietnam_SettingPackLabel` | Cài đặt tem pack |
| `STB_PassLabelPrintHist` | Lịch sử in tem Pass |

---

## 4. 🛡️ DDL Change Tracking System

> Mọi thay đổi cấu trúc SP/Table đều được ghi vào `DDLChangeLog` bởi server-level DDL trigger `utr_ProcedureChangesLog`.

### Schema:
| Column | Type | Mô tả |
|---|---|---|
| `LogID` | int | Auto-increment ID |
| `EventType` | nvarchar | ALTER_PROCEDURE / CREATE_TABLE / DROP_TABLE... |
| `PostTime` | datetime | Thời điểm thay đổi |
| `LoginName` | nvarchar | Login account (e.g., `vinaadmin`) |
| `UserName` | nvarchar | DB user (e.g., `dbo`) |

> ⚠️ **Bảo vệ:** Trigger `utr_UpdateDeleteRollbackForLogTable` ngăn chặn DELETE/UPDATE trên `DDLChangeLog` → log này KHÔNG THỂ XÓA.

---

## 5. 📊 VINATECH_POP — Shop Floor Terminal (42 tables)

> POP = Point of Production. Hệ thống terminal tại xưởng (Kiosk, PLC, BOM routing).

### Key Tables:
| Table | Mô tả |
|---|---|
| `VINA_BOM_INPUT_ROUTE` | **BOM theo route** (mapping NVL→công đoạn) |
| `VINA_KIOSK_LOG` | Log hoạt động Kiosk |
| `VINA_KIOSK_SESSION` | Session Kiosk |
| `VINA_PLC_BASELINE` | **PLC baseline** (giá trị chuẩn PLC) |
| `VINA_EQUIPMENT_SETTING` | Cài đặt thiết bị |
| `VINA_EQUIPMENT_MAPPING` | Mapping thiết bị |
| `VINA_EQUIPMENT_REMAINDER` | Nhắc bảo trì |
| `VINA_MODEL_SETTING` | Cài đặt model |
| `VINA_MODEL_SETTING_DETAIL` | Chi tiết setting |
| `VINA_MODEL_SETTING_MACRO` | Macro cho model |
| `VINA_FORMULA_CONFIG` | **Công thức tính toán** |
| `VINA_LINE_PROD_MODE` | Chế độ SX line |
| `VINA_MATERIAL_INPUT_HIST` | Lịch sử NVL input |
| `VINA_MATERIAL_ROUTE_MAP` | Mapping NVL→Route |
| `VINA_PACKING_REMAIN_QTY` | SL đóng gói còn lại |
| `VINA_WIP_STOCK_HIST` | **Lịch sử WIP** (Work In Progress) |

---

## 6. 🏭 Bending/Tapping & DryOver System (12 tables)

> Bending/Tapping = công đoạn uốn chân + đánh ren. DryOver = sấy khô.

| Table | Mô tả |
|---|---|
| `STB_VN_BENDING_TAPPING` | **Master** — Dữ liệu Bending/Tapping |
| `STB_VN_BENDING_TAPPING_WORKCENTER` | WorkCenter mapping |
| `STB_MaterialQcDetail_BendingCutting` | QC chi tiết Bending/Cutting |
| `STB_MaterialQcInfo_BendingCutting` | QC info Bending/Cutting |
| `STB_MaterialQcInspectionItem_BendingCutting` | Hạng mục kiểm tra |
| `STB_MaterialQcSampleResult_BendingCutting` | Kết quả mẫu QC |
| `Stb_TQC_Tapping_VVT` | TQC Tapping VVT |
| `STB_VN_DRYOVER` | **Dữ liệu sấy (DryOver)** |

---

*Cập nhật: 2026-06-18 — Deep discovery Phase 5-6*
