<!--
AI-READY METADATA
Purpose: Tất cả trong một (All-in-one): Rules + DB + Tools + Lessons Learned cho AI Agent trong phiên làm việc mới
Scope: Entry Point & Core Operating Procedures
Single Source of Truth: BOOTSTRAP.md
Related Files:
  - [RULES.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/AI_AGENT_CONFIG/RULES.md)
  - [KNOWLEDGE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/AI_AGENT_CONFIG/KNOWLEDGE.md)
  - [SKILLS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/AI_AGENT_CONFIG/SKILLS.md)
  - [KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [run_query.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/tools/run_query.ps1)
  - [deploy_tool.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/tools/deploy_tool.ps1)
  - [db_sync_tool.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/tools/db_sync_tool.ps1)
-->

# ⚡ BOOTSTRAP — Đọc file này ĐẦU TIÊN mỗi session mới

> **Cách dùng:** Khi bắt đầu session mới, tra cứu nhanh quy tắc và 2 CLI Hubs của phân hệ `PROCESS/MES_POP`.
> **Cập nhật:** 2026-09-25

---

## 🔒 QUY TẮC VÀNG BẮT BUỘC (RULES 0 - 20)

> [!IMPORTANT]
> Chi tiết đầy đủ quy tắc → [GEMINI.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/GEMINI.md) hoặc [.agents/rules/00_vinatech_rules.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/.agents/rules/00_vinatech_rules.md)

0. **RULE 0:** CẤM chạy `SELECT` trước khi tra cứu `.\pop.ps1 find` / `.\mes.ps1 find` hoặc KB modules.
1. **RULE 1:** SELECT-ONLY trên Production DB. Mọi script can thiệp phải bọc `BEGIN TRAN...ROLLBACK`.
2. **RULE 14:** Tốc độ phản hồi thần tốc (<3-5s). Gọi đúng 1-Shot Golden Query (`.\pop.ps1 trace` hoặc `.\mes.ps1 trace`), có data dừng ngay.
3. **RULE 16:** KHÔNG DÙNG TRÌNH DUYỆT / KHÔNG HTML. 100% vận hành qua Console CLI, REPL Shell, Python và Telegram Bot.
4. **RULE 18:** Định danh IT: Author = 'vanduc' và ChangeUserID = 'vanduc'.
5. **RULE 20 (POP Bất Biến):** Đổi máy nhầm update 2 bảng (`STB_ProdRouteHist` + `MongoToMesPerformance`). Nút Cắt điện cực mờ do `< 100`. Cuộn BTP tối đa 3 LOTNO. Mở khóa máy kẹt qua `.\pop.ps1 unlock <Machine> -Deploy`.

---

## 🔌 2 TRUNG TÂM ĐIỀU PHỐI LỆNH VẬN HÀNH

> [!NOTE]
> Điều phối Kiosk POP: [pop.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/pop.ps1) | Điều phối MES Core: [mes.ps1](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/mes.ps1) | Cấu hình 15 DB: [db_config.json](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/db_config.json)

```powershell
# 1. KIOSK POP & NVL BOM (pop.ps1)
.\pop.ps1 trace "<Lot/PO/Line/Machine>"  # Golden Query 360 Kiosk: BOM, Kho ROUTE_VN_WH, Nạp NVL, Tiến độ
.\pop.ps1 nvl "<Lot/PO>"                # Soi nhanh định mức BOM & tồn khả dụng kho chuyền
.\pop.ps1 unlock "<Machine>" -Deploy    # Mở khóa giải phóng máy POP kẹt ACTIVE tức thời 1-Shot
.\pop.ps1 release-machines [-Force]     # Giải phóng toàn bộ máy POP kẹt lock mồ côi
.\pop.ps1 sync [-Line <Line>]           # Quét Lot nghẽn đồng bộ POP -> MES (MongoToMesPerformance)

# 2. LÕI MES & SẢN XUẤT (mes.ps1)
.\mes.ps1 trace "<LotID>"               # Golden Query 360° sản xuất MES (Single Round-Trip)
.\mes.ps1 shell                         # Bật Persistent REPL Shell tức thời (<0.05s response)
.\mes.ps1 diagnose "<Text/Lot>"         # Chẩn đoán tức thời 1-Shot xuất đúng chuẩn 4 Dòng Vàng
.\mes.ps1 lineage "<Lot/PO>"            # Truy vết huyết mạch: PO Master -> Kho -> MES -> POP
.\mes.ps1 screen "<ScreenID>"           # Debug màn hình MES WinForm (Grid, SP, Bảng: B530, B540...)
.\mes.ps1 health [-Detail]              # Morning Health Check quét Lot HOLD, WIP 24h, Lock
.\mes.ps1 fix-movedate -Lots "..."      # Sinh Hotfix chuyển ngày chốt B782 chuẩn 10h00 AM (Author vanduc)
.\mes.ps1 fix-electrode -Lots "..."     # Sinh Hotfix xóa cuộn/mẻ trộn B552 & reset IsLineInput
.\mes.ps1 fix-rollback -Lots "..."      # Sinh Hotfix rollback lượt chốt B530 / POP Kiosk
.\mes.ps1 deploy <file.sql> [-Force]    # Deploy SQL an toàn (Tự động Snapshot Pre-flight)
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

## 🐛 LESSONS LEARNED (Top 5 — Danh sách đầy đủ xem [SKILLS.md §8](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/AI_AGENT_CONFIG/SKILLS.md#8--lessons-learned-từ-các-cuộc-trò-chuyện))

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

- **Hotfixes deployed:** 44 scripts (Hotfix ID_01 ➔ ID_44 cập nhật đến 2026-09-11)
- **Hotfix tiếp theo:** ID = **45**
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


