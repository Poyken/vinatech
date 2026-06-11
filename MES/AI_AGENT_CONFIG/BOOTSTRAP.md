# ⚡ BOOTSTRAP — Đọc file này ĐẦU TIÊN mỗi session mới

> **Cách dùng:** Khi bắt đầu session mới, user nói: *"Đọc file `MES/AI_AGENT_CONFIG/BOOTSTRAP.md` trước"*
> File này chứa TẤT CẢ context cần thiết, nén gọn nhất có thể. Không cần đọc thêm file nào khác trừ khi thiếu thông tin.
> **Cập nhật:** 2026-06-11

---

## 🔒 QUY TẮC VÀNG (KHÔNG ĐƯỢC VI PHẠM)

1. **SELECT-ONLY** — Tuyệt đối KHÔNG INSERT/UPDATE/DELETE/ALTER/CREATE/DROP trực tiếp trên production DB
2. **Script → User chạy** — Viết script fix (bọc `BEGIN TRAN...ROLLBACK`) → hướng dẫn user tự chạy SSMS hoặc qua `deploy_tool.ps1`
3. **Fetch trước khi sửa** — Query SP mới nhất từ `sys.sql_modules` trước khi phân tích/sửa
4. **Surgical changes** — Chỉ sửa đúng chỗ cần sửa, KHÔNG reformat toàn bộ SP
5. **Không commit SP lên Git** — Dùng `db_sync_tool.ps1` để tải tạm, xong phải `db_sync_tool.ps1 -Clean`
6. **Hỏi trước khi làm** — Thiếu thông tin → dừng và hỏi user
7. **NOLOCK** — Luôn dùng `WITH(NOLOCK)` trên bảng giao dịch lớn

---

## 🔌 KẾT NỐI & TOOLS

| Key | Value |
|-----|-------|
| **Server** | `dbserver.hycap.co.kr,5398` |
| **DB chính** | `SmartFactoryV2` |
| **DB framework** | `SmartFramework` |
| **DB file** | `SmartFramework_File` |
| **User** | `vinaadmin` |

### Tools có sẵn (chạy từ thư mục `MES/`)
```
.\run_query.ps1 -Query "SELECT ..."           # Query nhanh (Table/JSON/CSV)
.\validate_sql.ps1 <file.sql>                  # Kiểm tra an toàn trước deploy
.\deploy_tool.ps1 <file.sql>                   # Deploy SQL lên production
.\db_sync_tool.ps1 -SPName "usp_xxx"           # Tải SP tạm từ DB để đọc
.\db_sync_tool.ps1 -Clean                      # Xóa SP tạm, giữ Git sạch
```

---

## 🏭 FACTORY MATRIX

| Nhà máy | Code | Route prefix | Ghi chú |
|---------|------|-------------|---------|
| Bắc Ninh (Electrode) | VNT | `E-xx` | Sản xuất điện cực |
| Bắc Giang (Cell) | VVT (F1/F2) | `V-xx` | Sản xuất Cell/Module |
| Hà Nam | VVT_F3 | `VE-xx` | Nhà máy mới |
| **Hưng Yên (VNES)** | **VVT_F4** | **HY-xx** | **Nhà máy mới nhất — SP dùng suffix `_HY`** |

---

## 📊 BẢNG DỮ LIỆU TRỌNG TÂM (Top 10)

| Bảng | Dùng khi |
|------|----------|
| `STB_SetInfo` | Debug barcode (ControlNo, LotDecisionResult, IsDefect) |
| `STB_ProdRouteHist` | Trace routing (RouteCode, ProdQty, JobDate) |
| `STB_MaterialLotInfo` | Kho, đóng gói (LotNo, CurrentQty, PackingID) |
| `STB_MaterialMaster` | Check mã NVL |
| `STB_ModelBasicInfo` | Model + Vol/Farad |
| `STB_PackingStandard` | Tiêu chuẩn đóng gói |
| `STB_ProductionOrderRouting` | Route config PO |
| `STB_DayProdPlan` | Kế hoạch ngày |
| `STB_CommInspDocHistory` | QC pass/fail |
| `STB_ElectrodeStep` | Cấu hình bước cân điện cực |

---

## 🔍 SP NAMING CONVENTION

| Pattern | Ý nghĩa |
|---------|---------|
| `usp_Get...` / `usp_..._get` | SELECT/Load data |
| `usp_Do...` / `usp_..._iud` | Execute/Save/Delete |
| `usp_Vietnam_...` / `usp_VN_...` | Custom cho VN |
| `usp_VVT_...` | Vinatech-specific |
| `usp_HN_...` | Hà Nam-specific |
| `usp_..._HY_get/iud` | **Hưng Yên-specific** |

---

## 🧭 TRA CỨU NHANH — Lỗi → Đọc KB nào?

| Triệu chứng | KB file |
|-------------|---------|
| Không đăng nhập MES | KB_01 |
| Không in được tem | KB_01, KB_04, KB_09 |
| Gộp box lỗi | KB_04 |
| Lỗi QC/chưa pass | KB_05 |
| NVL hết hạn | KB_02 |
| Chốt công đoạn lỗi | KB_14 |
| Model mới chưa cấu hình | KB_06 |
| Phế NVL B598 | KB_03 |
| Kho HN lỗi | KB_08 |
| Hưng Yên (VNES) | KB_25 |
| Máy móc/bảo trì | KB_20 |
| Dashboard/Andon | KB_22 |

**Đường dẫn KB:** `MES/MES_MASTER_KNOWLEDGE_BASE/KB_XX_TEN_FILE.md`

---

## 🐛 LESSONS LEARNED (Bẫy đã gặp — KHÔNG được mắc lại)

1. **`= Null` ≠ `IS NULL`** — Bug trong `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` khiến Gate 20 phút fail
2. **`STB_MaterialHoldInfo` KHÔNG tồn tại** — HOLD dùng `MaterialWarehouseCode = 'HOLDING_*'`
3. **`CompleteRoute='1'` set cho MỌI route** — Dùng `IsOutputRoute` để xác định route cuối
4. **`STB_BarrelBarcodeInfo` KHÔNG tồn tại** — Bảng thực: `STB_VietNam_CheckBarcode_2624`
5. **`STB_AluCaseMapping_VVT` KHÔNG tồn tại** — Logic vỏ nhôm hardcode trong SP
6. **Git root là Desktop** — Luôn scope git commands vào `MES/` (cd `c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES`)
7. **Electrode SP naming** — `usp_ElectrodeStep_get` (không phải `_Vietnam`)
8. **Packing SP** — `usp_Vietnam_DoProcessProdPacking_VVT` (không phải `usp_De...`)

---

## 📋 TRẠNG THÁI DỰ ÁN HIỆN TẠI (Cập nhật: 2026-06-11)

### Hotfixes đã triển khai: 17 scripts
- **01-05** (2026-06-10): Các bug fix sản xuất (Dry Oven, Doping Jig, Slitting, Rework, Returns)
- **06-17** (2026-06-11): Clone toàn bộ SP cho **nhà máy Hưng Yên (_HY)**
  - 06-07: QC Inspection Group/Item HY + Data migration
  - 08-09: Material QC Inspection HY + Data migration
  - 10-11: Incoming QC (IQC) HY (20 SPs) + Config data migration
  - 12: Production Order HY (7 SPs)
  - 13: Daily Plan HY (4 SPs)
  - 14: Electrode Process Card HY (6 SPs)
  - 15: Electrode Measure Result HY (21 SPs)
  - 16: Electrode Route History HY (2 SPs)
  - 17: QC Electrode Inspection HY (6 SPs)

### Hotfix tiếp theo: ID = **18**

---

## 🚀 WORKFLOW XỬ LÝ BUG — Quy trình 5 bước

```
1. THU THẬP  → Màn hình? Barcode? Thao tác? Lỗi gì? Ai/Khi nào?
2. TRA CỨU   → Bảng "Lỗi → KB" ở trên → đọc đúng 1 KB file
3. XÁC MINH  → .\run_query.ps1 -Query "SELECT ... WHERE Barcode='xxx'"
4. FIX        → Viết hotfix SQL (bọc BEGIN TRAN) → validate_sql → deploy_tool
5. GHI CHÉP  → Cập nhật hotfixes/README.md + commit Git
```

---

## 📁 CẤU TRÚC DỰ ÁN

```
MES/
├── AI_AGENT_CONFIG/
│   ├── BOOTSTRAP.md    ← BẠN ĐANG ĐÂY — Đọc file này mỗi session mới
│   ├── RULES.md        ← Quy tắc chi tiết (đọc thêm nếu cần)
│   ├── KNOWLEDGE.md    ← Bảng/SP cheat sheet chi tiết
│   └── SKILLS.md       ← SQL/PS templates + debug recipes
├── MES_MASTER_KNOWLEDGE_BASE/
│   ├── KB_INDEX.md     ← Mục lục tra cứu 30 KB files
│   └── KB_01 → KB_30   ← Tài liệu chuyên sâu từng phân hệ
├── sql/hotfixes/        ← 17 hotfix scripts (lịch sử triển khai DB)
├── run_query.ps1        ← Query DB nhanh
├── validate_sql.ps1     ← Validate SQL trước deploy
├── deploy_tool.ps1      ← Deploy SQL lên production
└── db_sync_tool.ps1     ← Tải/xóa SP tạm từ DB
```

---

## ⚠️ CHECKLIST TRƯỚC KHI TRẢ LỜI

- [ ] Đã đọc hết file BOOTSTRAP.md này?
- [ ] Hiểu user đang hỏi về nhà máy nào? (BN/BG/HN/HY)
- [ ] Có cần query DB để xác minh không? → Dùng `run_query.ps1`
- [ ] Có cần đọc source SP không? → Dùng `db_sync_tool.ps1`
- [ ] Câu trả lời có vi phạm quy tắc SELECT-ONLY không?
- [ ] Nếu viết script fix: đã bọc trong `BEGIN TRAN...ROLLBACK`?

---

*File này được tạo và duy trì bởi AI Agent. Khi có thay đổi lớn (hotfix mới, bảng mới, lesson learned mới), hãy yêu cầu AI cập nhật file này.*
