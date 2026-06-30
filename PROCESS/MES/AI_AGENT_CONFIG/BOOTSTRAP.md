# ⚡ BOOTSTRAP — Đọc file này ĐẦU TIÊN mỗi session mới

> **Cách dùng:** Khi bắt đầu session mới, user nói: *"Đọc file `MES/AI_AGENT_CONFIG/BOOTSTRAP.md` trước"*
> **Cập nhật:** 2026-06-19

---

## 🔒 QUY TẮC VÀNG (KHÔNG ĐƯỢC VI PHẠM)

1. **SELECT-ONLY** — Tuyệt đối KHÔNG INSERT/UPDATE/DELETE/ALTER/CREATE/DROP trực tiếp trên production DB
2. **Script → User chạy** — Viết script fix (bọc `BEGIN TRAN...ROLLBACK`) → user tự chạy SSMS hoặc qua `deploy_tool.ps1`
3. **Fetch trước khi sửa** — Query SP mới nhất từ `sys.sql_modules`
4. **Surgical changes** — Chỉ sửa đúng chỗ cần sửa, KHÔNG reformat toàn bộ SP
5. **Không commit SP lên Git** — Dùng `db_sync_tool.ps1` tải tạm, xong `db_sync_tool.ps1 -Clean`
6. **Hỏi trước khi làm** — Thiếu thông tin → dừng và hỏi user
7. **NOLOCK** — Luôn dùng `WITH(NOLOCK)` trên bảng giao dịch lớn

---

## 🔌 KẾT NỐI & TOOLS

| Server | `dbserver.hycap.co.kr,5398` |
|--------|-----|
| **DB chính** | `SmartFactoryV2` |
| **DB framework** | `SmartFramework` |
| **User** | `vinaadmin` |

```
.\run_query.ps1 -Query "SELECT ..."   # Query nhanh
.\validate_sql.ps1 <file.sql>          # Validate trước deploy
.\deploy_tool.ps1 <file.sql>           # Deploy SQL
.\db_sync_tool.ps1 -SPName "usp_xxx"   # Tải SP tạm
.\db_sync_tool.ps1 -Clean              # Xóa SP tạm
```

---

## 🧭 TRA CỨU — Đọc gì?

> **Nguyên tắc token:** Đọc INDEX → chọn chunk phù hợp → KHÔNG đọc full file >40KB

| Cần gì | Đọc file | Ghi chú |
|--------|----------|---------|
| **Bảng/SP/Column reference** | `KNOWLEDGE.md` | Cheat sheet nén gọn |
| **SQL templates/Debug** | `SKILLS.md` | Copy-paste ready |
| **Quy tắc chi tiết** | `RULES.md` | Đầy đủ hơn section trên |
| **Bug theo màn hình** | **KB_31** (Bug Fixbook) | 70+ bugs, đọc trước |
| **KB chuyên sâu** | `KB_INDEX.md` → chunk cụ thể | 5 folders đã CHUNKED |
| **Screen→SP→Table** | KB_32 hoặc KI: screen_id_reference | |

### KB Routing nhanh

| Triệu chứng | KB | Chunk gợi ý |
|---|---|---|
| Sản xuất/chốt SL | KB_03/ | → 02_CELL_LINE |
| Đóng gói/in tem | KB_04/ | → 01_CORE_PACKAGING |
| QC/Electrode | KB_05/ | → 01_QC_OVERVIEW hoặc 02_ELECTRODE |
| Kho NVL/TP | KB_02/ | → 01_NVL_WMS hoặc 02_FG_WMS |
| Model mới | KB_06_MASTER_DATA_TOOLS.md | Không chunked |
| Hưng Yên | KB_25/ | → 01_OVERVIEW |
| Hà Nam screens | KB_36_HANAM_FACTORY_SCREENS.md | Không chunked |
| Phân quyền / Tạo màn hình | KB_01_UI_AND_SCREENS.md | Không chunked |

---

## 🐛 LESSONS LEARNED (KHÔNG được mắc lại)

1. `= Null` ≠ `IS NULL` — Gate 20 phút fail
2. `STB_MaterialHoldInfo` **KHÔNG tồn tại** → dùng `MaterialWarehouseCode = 'HOLDING_*'`
3. `CompleteRoute='1'` set cho MỌI route → dùng `IsOutputRoute`
4. `STB_BarrelBarcodeInfo` **KHÔNG tồn tại** → `STB_VietNam_CheckBarcode_2624`
5. `STB_AluCaseMapping_VVT` **KHÔNG tồn tại** → hardcode trong SP
6. Git root là Desktop → scope vào `MES/`
7. Electrode SP: `usp_ElectrodeStep_get` (không phải `_Vietnam`)
8. Packing SP: `usp_Vietnam_DoProcessProdPacking_VVT` (không phải `usp_De...`)
9. OQC Grade C531 → bảng `VVT_OQC_REFER`
10. `STB_HN_AccountingPrice` / `CellTestResult` → legacy/typo
11. CRLF warning → không mass-edit .md files

---

## 🚀 WORKFLOW XỬ LÝ BUG — 5 bước

```
1. THU THẬP  → Màn hình? Barcode? Thao tác? Lỗi gì?
2. TRA CỨU   → KB_31 (Bug Fixbook) → KB chuyên sâu qua INDEX
3. XÁC MINH  → .\run_query.ps1 -Query "SELECT ..."
4. FIX        → SQL (BEGIN TRAN...ROLLBACK) → validate → deploy
5. GHI CHÉP  → hotfixes/README.md + commit
```

---

## 📋 TRẠNG THÁI DỰ ÁN

- **Hotfixes deployed:** 17 scripts (01-05: Bug fix SX, 06-17: Clone SP Hưng Yên)
- **Hotfix tiếp theo:** ID = **18**
- **Nhà máy:** VNT (Bắc Ninh), VVT_F1/F2 (Bắc Giang), VVT_F3 (Hà Nam), VVT_F4 (Hưng Yên)

---

## 📁 CẤU TRÚC DỰ ÁN

```
MES/
├── GEMINI.md              ← Auto-context
├── AI_AGENT_CONFIG/       ← BOOTSTRAP, RULES, KNOWLEDGE, SKILLS
├── MES_MASTER_KNOWLEDGE_BASE/
│   ├── KB_INDEX.md        ← Mục lục + routing
│   ├── KB_02/ → KB_05/    ← ⚡ 4 CHUNKED: KB_02,03,04,05
│   └── KB_01..KB_36       ← Files gốc + non-chunked
├── sql/hotfixes/           ← 17 scripts
└── *.ps1                   ← 4 tools
```

---

## ⚠️ CHECKLIST TRƯỚC KHI TRẢ LỜI

- [ ] Hiểu user hỏi về nhà máy nào? (BN/BG/HN/HY)
- [ ] Cần query DB? → `run_query.ps1`
- [ ] Cần đọc SP? → `db_sync_tool.ps1`
- [ ] Vi phạm SELECT-ONLY? → DỪNG
- [ ] Script fix đã bọc `BEGIN TRAN...ROLLBACK`?

---
*Cập nhật: 2026-06-30 — Trimmed for token efficiency. Đã rút gọn 65% KB, tập trung tối đa vào nhận/fix bug và tạo màn hình.*
