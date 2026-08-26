<!--
AI-READY METADATA
Purpose: Tất cả trong một (All-in-one): Rules + DB + Tools + Lessons Learned cho AI Agent trong phiên làm việc mới
Scope: Entry Point & Core Operating Procedures
Single Source of Truth: BOOTSTRAP.md
Related Files:
  - [RULES.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/AI_AGENT_CONFIG/RULES.md)
  - [KNOWLEDGE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/AI_AGENT_CONFIG/KNOWLEDGE.md)
  - [SKILLS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/AI_AGENT_CONFIG/SKILLS.md)
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [run_query.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/run_query.ps1)
  - [deploy_tool.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/deploy_tool.ps1)
  - [db_sync_tool.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/db_sync_tool.ps1)
-->

# ⚡ BOOTSTRAP — Đọc file này ĐẦU TIÊN mỗi session mới

> **Cách dùng:** Khi bắt đầu session mới, user nói: *"Đọc file `MES/AI_AGENT_CONFIG/BOOTSTRAP.md` trước"*
> **Cập nhật:** 2026-07-02

---

## 🔒 QUY TẮC VÀNG

> [!IMPORTANT]
> Chi tiết đầy đủ quy tắc → [RULES.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/AI_AGENT_CONFIG/RULES.md)

1. **SELECT-ONLY** — Tuyệt đối KHÔNG INSERT/UPDATE/DELETE/ALTER/CREATE/DROP trực tiếp trên production DB
2. **Script → User chạy** — Viết script fix (bọc `BEGIN TRAN...ROLLBACK`) → user tự chạy SSMS hoặc qua [deploy_tool.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/deploy_tool.ps1)
3. **Fetch trước khi sửa** — Query SP mới nhất từ `sys.sql_modules` qua [db_sync_tool.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/db_sync_tool.ps1)
4. **Surgical changes** — Chỉ sửa đúng chỗ cần sửa, KHÔNG reformat toàn bộ SP
5. **Không commit SP lên Git** — Dùng `db_sync_tool.ps1` tải tạm, xong `db_sync_tool.ps1 -Clean`
6. **Hỏi trước khi làm** — Thiếu thông tin → dừng và hỏi user
7. **NOLOCK** — Luôn dùng `WITH(NOLOCK)` trên bảng giao dịch lớn

---

## 🔌 KẾT NỐI & TOOLS

> [!NOTE]
> Thông tin kết nối chi tiết → [db_config.json](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/db_config.json) | Hướng dẫn tool chi tiết → [MES_SCRIPT_GUIDE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/MES_SCRIPT_GUIDE.md)

| DB chính | `SmartFactoryV2` | DB framework | `SmartFramework` |
|----------|-------------------|--------------|-------------------|

```powershell
.\run_query.ps1 -Query "SELECT ..."   # Query nhanh (tự động hiển thị KB tham chiếu)
.\validate_sql.ps1 <file.sql>          # Validate trước deploy
.\deploy_tool.ps1 <file.sql>           # Deploy SQL
.\db_sync_tool.ps1 -SPName "usp_xxx"   # Tải SP tạm (tự động hiển thị KB tham chiếu)
.\db_sync_tool.ps1 -Clean              # Xóa SP tạm
.\record_hotfix.ps1 -TCode "B523" ...  # Tự động hóa ghi chép lỗi vào HOTFIX_LOG.md và KB_09
.\debug_screen.ps1 -TCode "B523"       # Chẩn đoán màn hình (Menu, SP, Grid) & đề xuất KB
.\debug_screen.ps1 -ErrorMsg "loi"     # Tìm SP ném lỗi qua chuỗi dịch nghĩa tiếng Việt/tiếng Anh
```


---

## 🧭 TRA CỨU — Đọc gì?

> **Nguyên tắc token:** Đọc INDEX → chọn chunk phù hợp → KHÔNG đọc full file >40KB

| Cần gì | Đọc file | Ghi chú |
|--------|----------|---------|
| **Bảng/SP/Column reference** | `KNOWLEDGE.md` | Cheat sheet nén gọn |
| **SQL templates/Debug** | `SKILLS.md` | Copy-paste ready |
| **Quy tắc chi tiết** | `RULES.md` | Đầy đủ hơn section trên |
| **Bug theo màn hình** | **KB_09** (Bug Fixbook) | 70+ bugs, đọc trước |
| **KB chuyên sâu** | `KB_INDEX.md` → chunk cụ thể | 5 folders đã CHUNKED |
| **Screen→SP→Table** | KB_11 hoặc KI: screen_id_reference | |

### KB Routing nhanh

| Triệu chứng | KB | Chunk gợi ý |
|---|---|---|
| Sản xuất/chốt SL | KB_03/ | → 02_CELL_LINE |
| Đóng gói/in tem | KB_04/ | → 01_CORE_PACKAGING |
| QC/Electrode | KB_05/ | → 01_QC_AND_ELECTRODE_CORE |
| Kho NVL/TP | KB_02/ | → 01_WMS_CORE |
| Model mới | KB_06_MASTER_DATA_TOOLS.md | Không chunked |
| Hưng Yên | KB_07/ | → 01_OVERVIEW |
| Hà Nam screens | KB_11_HANAM_FACTORY_SCREENS.md | Không chunked |
| Phân quyền / Tạo màn hình | KB_01_UI_AND_SCREENS.md | Không chunked |

---

## 🐛 LESSONS LEARNED (Top 5 — Danh sách đầy đủ xem [SKILLS.md §8](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/MES_LEGACY_BACKUP/AI_AGENT_CONFIG/SKILLS.md#8--lessons-learned-từ-các-cuộc-trò-chuyện))

1. `= Null` ≠ `IS NULL` — Gate 20 phút fail (KB_08 §4.2)
2. `STB_MaterialHoldInfo` **KHÔNG tồn tại** → dùng `MaterialWarehouseCode = 'HOLDING_*'`
3. `STB_BarrelBarcodeInfo` **KHÔNG tồn tại** → `STB_VietNam_CheckBarcode_2624`
4. Packing SP: `usp_Vietnam_DoProcessProdPacking_VVT` (không phải `usp_De...`)
5. CRLF warning → không mass-edit .md files

---

## 🚀 WORKFLOW XỬ LÝ BUG CHUẨN — 6 bước

```
1. THU THẬP  → Nhận mã màn hình (TCode), LotNo/Barcode, triệu chứng từ User
2. TRA CỨU   → TRA KB TRƯỚC (KB_09 / KI bug_fix_patterns). Nắm Root Cause + SP + Bảng DB
3. XÁC MINH  → .\debug_screen.ps1 -TCode <TCode> -Barcode <Barcode>
4. FIX & AUDIT → .\db_sync_tool.ps1 -SPName <SP> → Viết SQL (BEGIN TRAN...ROLLBACK)
5. GHI CHÉP  → .\record_hotfix.ps1 -TCode <TCode> -Symptom "..." -Cause "..." -SQLPatch "..."
6. DỌN DẸP   → Xóa SP tạm bằng .\db_sync_tool.ps1 -Clean và commit Git
```


---

## 📋 TRẠNG THÁI DỰ ÁN

- **Hotfixes deployed:** 17 scripts (01-05: Bug fix SX, 06-17: Clone SP Hưng Yên)
- **Hotfix tiếp theo:** ID = **24**
- **Nhà máy (SoT: KB_10):** VNT_F1/VVT_F1=Bắc Ninh, VNT_F2=Electrode/MEA, VVT_F2=BG1, VVT_F3=Hà Nam, VVT_F4=BG2, VNT_F5=Hưng Yên

---

## ⚠️ CHECKLIST TRƯỚC KHI TRẢ LỜI

- [ ] Hiểu user hỏi về nhà máy nào? (BN/BG/HN/HY)
- [ ] Cần query DB? → `run_query.ps1`
- [ ] Cần đọc SP? → `db_sync_tool.ps1`
- [ ] Vi phạm SELECT-ONLY? → DỪNG
- [ ] Script fix đã bọc `BEGIN TRAN...ROLLBACK`?

---
*Cập nhật: 2026-07-02 — Loại bỏ trùng lặp DB config & cấu trúc thư mục. SoT: db_config.json, RULES.md, README.md.*


