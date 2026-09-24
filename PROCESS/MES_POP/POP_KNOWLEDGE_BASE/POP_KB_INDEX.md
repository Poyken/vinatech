<!--
AI-READY METADATA
Purpose: Master Index — Bộ KB toàn diện cho hệ thống POP (Point of Production) Vinatech
Scope: POP Web Kiosk (pop.vinatech.com), VINATECH_POP DB (66 bảng), SmartFactoryV2 Integration
Single Source of Truth: POP_KNOWLEDGE_BASE/POP_KB_INDEX.md
Target Systems: POP Web UI, VINATECH_POP DB, SmartFactoryV2 DB, VINATECH_RESTFUL API
Last Updated: 2026-09-21 (Audit DB schema 66 bảng, đánh dấu 5 file archived)
Related Files:
  - [MES KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [POP_KB_01_ARCHITECTURE_AND_API.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_01_ARCHITECTURE_AND_API.md)
  - [POP_KB_02_SCREEN_OPERATIONS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_02_SCREEN_OPERATIONS.md)
  - [POP_KB_03_TROUBLESHOOTING.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md)
  - [POP_KB_06_MIGRATION_SPEC.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_06_MIGRATION_SPEC.md)
-->

# 📋 POP KNOWLEDGE BASE — MASTER INDEX

> **Hệ thống:** POP (Point of Production) — Web Kiosk Sản xuất Vinatech  
> **URL:** `https://pop.vinatech.com/`  
> **Backend DB:** `VINATECH_POP` (**66 bảng** — audit 2026-09-24) + `SmartFactoryV2` (shared với MES)  
> **API Server:** `https://pop.vinatech.com/api/` (RESTful, JSON)  
> **Phiên bản KB:** v3.0 (Cập nhật 2026-09-24 — Khảo sát Admin toàn diện, bóc tách 8 phân hệ ngầm, 58 PC biên, MongoDB Time-Series & 34 mã lỗi POP-ERR)  
> **🔑 Keywords:** POP, kiosk, sản xuất, đóng gói, nhập NVL, packing, merge pack, label, quality, IQC, PQC, OQC, interlock, admin release, reopen request, line prod mode, subtract, add, assembly group 10 slots, plc auto perf, pc mac dashboard, mongodb telemetry, POP-ERR-31, POP-ERR-32, POP-ERR-33, POP-ERR-34

---

## 📚 BẢN ĐỒ TÀI LIỆU (KB FILE MAP)

> [!NOTE]
> **Cập nhật 2026-09-24:** Tích hợp phát hiện thực tế quyền Admin cấp cao (EA Team): Bóc tách 8 phân hệ quản trị ngầm, ánh xạ 1:1 Schema 66 bảng CSDL `VINATECH_POP`, cơ chế tự động hóa PLC Auto Performance, và bộ xử lý hoàn tác QC Reopen.

| # | File | Nội dung | Khi nào dùng | Trạng thái |
|---|------|----------|--------------|------------|
| INDEX | [POP_KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md) | Master Index + Routing Map v3.0 | Điểm bắt đầu mọi tra cứu POP | ✅ Active |
| 01 | [POP_KB_01_ARCHITECTURE_AND_API.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_01_ARCHITECTURE_AND_API.md) | Kiến trúc hệ thống, API endpoints, **Data Pipeline & Hệ sinh thái Bảng đệm Trung gian** (MongoToMes*, STB_ERP_INTERFACE, STB_RFIDPrintQueue §3.5), DB schema mapping **66 bảng** (§3.6), **Bản đồ quan hệ dữ liệu 8 phân hệ Admin POP (§7)** | Debug API, hiểu data flow, kiến trúc staging, logic chọn máy Kiosk, cấu trúc bảng ngầm | ✅ Active |
| 02 | [POP_KB_02_SCREEN_OPERATIONS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_02_SCREEN_OPERATIONS.md) | Hướng dẫn vận hành 22 phân hệ màn hình Kiosk & Admin, Interlock Manager (§20), Quality Admin & Rollback Reopen (§21), PLC Automation & PC Mac Dashboard 58 PC biên (§22) | Thao tác sản xuất, đóng gói, marking, chọn máy, mở khóa Interlock, duyệt Reopen | ✅ Active |
| 03 | [POP_KB_03_TROUBLESHOOTING.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md) | Lỗi thường gặp + Root cause + Fix (**POP-ERR-01 đến POP-ERR-34**, Top 15 Telemetry, Lệch mốc SUBTRACT, Kẹt MAX_WAIT, Reopen QC) | Xử lý sự cố khẩn cấp, kẹt máy, nạp cuộn điện cực, sửa mốc sản lượng, restart agent | ✅ Active |
| 04 | [POP_KB_04_ROLLBACK_AND_SAFETY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_04_ROLLBACK_AND_SAFETY.md) | Phân tích khả năng Rollback trên UI + DB safety (v2.0) | Hủy đóng gói Box, an toàn dữ liệu | ✅ Active |
| 05 | [POP_KB_05_DB_VERIFICATION_AUDIT.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_05_DB_VERIFICATION_AUDIT.md) | Kết quả đối chiếu UI vs DB thực tế | Kiểm toán, xác minh tính chính xác | ✅ Active |
| 06 | [POP_KB_06_MIGRATION_SPEC.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/POP_KNOWLEDGE_BASE/POP_KB_06_MIGRATION_SPEC.md) | **Đặc tả chuyển đổi 100% POP Web**: Bảng quy chiếu 1:1 màn hình WinForm ➔ Web, Gap Analysis, 8 bước checklist Line Readiness | Quy hoạch tắt MES WinForm, chuẩn bị cutover | ✅ Active |
| AUDIT | [MES_POP_DEEP_DIVE_AUDIT_AND_INQUIRY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/docs/MES_POP_DEEP_DIVE_AUDIT_AND_INQUIRY.md) | **Nghiên cứu chuyên sâu & 12 câu hỏi bản chất vận hành MES & POP**: Phân tích 8 miền kiến trúc, Staging buffers, Dual-entry conflicts, 14 FAIL lines | Chiến lược vận hành, bóc tách điểm mù & đối thoại kỹ thuật | ✅ Active |
| ~~MAP~~ | ~~POP_SLIDE_DECK_MAPPING_AND_ANALYSIS.md~~ | ~~Phân tích 51 slides POP.pptx & 50 ảnh trích xuất~~ | ~~Đối chiếu tài liệu đào tạo DX Team~~ | ❌ **[ARCHIVED]** |
| ~~REF~~ | ~~POP_USER_MANUAL.md~~ | ~~Cẩm nang vận hành chi tiết 6 phần cho end-user~~ | ~~Training công nhân, thao tác Kiosk~~ | ❌ **[ARCHIVED]** |
| ~~REF~~ | ~~POP_SYSTEM_INTEGRATION_GUIDE.md~~ | ~~Tích hợp POP ⇄ MES ⇄ Groupware ⇄ ERP~~ | ~~Hiểu luồng dữ liệu liên hệ thống~~ | ❌ **[ARCHIVED]** |
| ~~REF~~ | ~~POP_QUALITY_AND_SCREEN_REFERENCE.md~~ | ~~Tham chiếu Quality screens + mapping~~ | ~~QC operations~~ | ❌ **[ARCHIVED]** |
| ~~REF~~ | ~~POP_TRAINING_SCREEN_QUALITY.md~~ | ~~Tài liệu training Quality screens~~ | ~~Đào tạo QC~~ | ❌ **[ARCHIVED]** |

---

## 🗺️ ROUTING TABLE — TRA CỨU NHANH THEO TÌNH HUỐNG

| Tình huống | File chính | File phụ |
|-----------|-----------|---------|
| Lỗi đăng nhập POP, không load được trang | KB_01 §1.1 | KB_03 §1 |
| Không thấy Work Order / DayPlan | KB_02 §1.4 | KB_03 §2 |
| Lỗi nhập NVL (Material Input) | KB_02 §6 | KB_01 §3.2 |
| Nạp nhanh NVL theo BOM | KB_02 §6.2 ("Lượng kiến cấp") | KB_02 §6 |
| Tra cứu đích danh LOT NVL trong kho | KB_02 §6.2 ("Tồn kho") | KB_01 §3.1 |
| Lỗi "Không tìm thấy LOT trong kho" khi nạp cuộn điện cực / BOM | **KB_03 §2.19 (POP-ERR-19)** | KB_02 §6 |
| POP Kiosk thiếu thiết bị / Ẩn máy tại modal "Xác nhận Kết thúc?" | **KB_03 §2.20 (POP-ERR-20)** | **KB_01 §3.3**, KB_02 §5, HOTFIX_LOG ID_57 |
| Lệch mốc sản lượng do chế độ `SUBTRACT` | **KB_03 §2.31 (POP-ERR-31)** | KB_01 §7.1, KB_02 §20 |
| Kẹt khóa liên động vượt thời gian chờ (`MAX_WAIT`) | **KB_03 §2.32 (POP-ERR-32)** | KB_01 §7.2.A, KB_02 §20.1 |
| Kẹt biên bản kiểm tra QC ("ko nhap dc kt") / Phê duyệt Reopen | **KB_03 §2.33 (POP-ERR-33)** | KB_01 §7.2.B, KB_02 §21.1 |
| Mất kết nối Agent thu thập PLC 58 PC biên (Restart/Update từ xa) | **KB_03 §2.34 (POP-ERR-34)** | KB_01 §7.2.D, KB_02 §22.3 |
| Lỗi không link số lượng NG từ POP Kiosk xuống NAIS MES (B782) | **MES KB_09 § [B782] Bug #5** | HOTFIX_LOG ID_56 |
| Nhập mã Marking công đoạn Bọc Vỏ | KB_02 §7.2 | KB_02 §7 |
| Lỗi đóng gói / Merge Pack / Chia Box | KB_02 §9 | KB_03 §4 |
| Muốn hủy đóng gói Box (Rollback) | **KB_04 §2.5** (SoT) | KB_02 §9.2 |
| Lỗi in tem / label print | KB_02 §10 | KB_03 §5 |
| Tự kiểm In-Line QC tại chuyền | KB_02 §12.1 | KB_02 §12 |
| Quality: IQC/PQC/OQC/FOQC | KB_02 §12 | KB_03 §2.8 |
| Tra cứu bảng tiền tố `MongoToMes*` & Bảng đệm tương tự (`STB_ERP_INTERFACE`, `STB_RFIDPrintQueue`) | **KB_01 §3.5 (SoT)** | **KB_03 §2.15, §2.18** |
| Kẹt đồng bộ POP ➔ MES / Lệch số lượng (`IsTransferred = 0`) | **KB_01 §3.5.4** | **KB_03 §2.18 (Template 7, 8, 9)** |
| API endpoint không phản hồi | KB_01 §2 | KB_03 §6 |
| Kiểm toán UI vs DB | **KB_05** (SoT) | KB_01 §3 |
| Hiểu kiến trúc tổng thể | KB_01 §1 | KB_01 §5 |
| Tra cứu danh mục đầy đủ 66 bảng VINATECH_POP | **KB_01 §3.6** (SoT) | KB_05 |
| Tra cứu Top 15 lỗi runtime thực tế Kiosk (Action Log Telemetry) | **KB_03 §2.21** (SoT) | KB_03 §1, POP_MATRIX.json |
| Lỗi cuộn điện cực đã nạp quá 2 Lot (`POP-ERR-24`) | **KB_03 §2.24** | POP_MATRIX.json, STB_MaterialLotInfo |
| Lỗi thứ tự công đoạn: Chưa chốt Coating/Mixing (`POP-ERR-23`, `POP-ERR-28`) | **KB_03 §2.23, §2.28** | KB_02 §4 |
| Tranh chấp máy sản xuất bị chiếm quyền (`equipment.mapping.preempted` - `POP-ERR-27`) | **KB_03 §2.27** | `.\mes.ps1 release-machines` |
| Bản đồ điều hướng 4 phân hệ UI Web POP | **KB_01 §2.4** (SoT) | KB_02 |
| Cấu hình 10 Slot nạp NVL chuẩn theo Line | **KB_01 §3.6 (Nhóm 2)** | KB_02 §6 |
| **Quy hoạch chuyển đổi 100% POP Web (Khai tử WinForm)** | **KB_06 (SoT)** | KB_01 |
| **Bảng ánh xạ 1:1 màn hình WinForm ➔ Web POP** | **KB_06 §1** (SoT) | KB_02 |
| **Checklist 8 bước sẵn sàng cắt WinForm cho Line** | **KB_06 §3** (SoT) | `.\mes.ps1 pop-readiness` |
| **Chuẩn hóa lỗi phế ẩn (Three-Valued Logic NULL)** | **KB_03 §3 (Template 11)** | HOTFIX_LOG ID_56 |
| **Giải phóng máy kẹt ACTIVE ở DayPlan cũ** | **`.\mes.ps1 release-machines`** | KB_03 Template 10, `routine_RELEASE_ORPHAN_MACHINE_LOCKS.sql` |
| **Sinh mã PackingID 11 ký tự (in tem thùng)** | **`template_GENERATE_POP_PACKING_ID.sql`** | KB_02 §10, KB_06 §2.1 |
| **Tra cứu chức năng, Button, View & Ma trận CRUD (Xem, Thêm, Sửa, Xóa)** | **KB_02 §17 (SoT)** | KB_01 §2 |
| **Phân hệ quản lý dữ liệu thiết bị IoT & Log PLC (`/equipmentData/*`)** | **KB_02 §18 (SoT)** | KB_01 §1.1, §1.2 |
| **Phân quyền Dashboard RBAC & Giải thích lỗi 403 Forbidden** | **KB_02 §19 (SoT)** | KB_01 §1.1 |
| **Danh mục 38 Frontend JavaScript Client Modules (`resources/js/`)** | **KB_01 §1.3 (SoT)** | KB_02 §16.1 |
| **Cẩm Nang 17 Ca Bệnh Thực Chiến Nội Bộ EA Team (Tài liệu gốc DOCX)** | **KB_03 §3 (SoT)** | `HƯỚNG DẪN XỬ LÝ HỆ THỐNG POP KHI GẶP LỖI.docx`, `POP_MATRIX.json` |


---

## 🔗 CROSS-REFERENCE VỚI MES KB

| POP KB | MES KB tương ứng | Ghi chú |
|--------|------------------|---------|
| POP_KB_01 (Architecture) | [KB_08_CORE_SP_ENGINE](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_08_CORE_SP_ENGINE.md) | POP gọi cùng SP engine |
| POP_KB_02 (Screens) | [KB_01_UI_AND_SCREENS](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_AND_SCREENS.md) | POP Web ≠ MES WinForm |
| POP_KB_03 (Troubleshoot) | [KB_09_SCREEN_BUG_FIXBOOK](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md) | Một số bug chung |
| POP_KB_04 (Rollback) | [KB_04_PACKING](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_04) | Logic hủy đóng gói chung |
| POP nhập NVL | [KB_03_PRODUCTION](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_POP/MES_MASTER_KNOWLEDGE_BASE/KB_03/INDEX.md) | Trừ kho chia sẻ logic |

---

## 🏗️ TỔNG QUAN KIẾN TRÚC NHANH

```
┌─────────────────────────────────────────────────────────────┐
│                    POP WEB CLIENT                            │
│  Browser (Kiosk Touch Screen / Desktop)                      │
│  URL: https://pop.vinatech.com/                              │
│  Routes: /pop/screen (SX) | /pop/quality (QC)               │
├──────────────────────┬──────────────────────────────────────┤
│                      │ HTTPS / REST API                      │
│                      ▼                                       │
│              POP API SERVER                                  │
│     /api/pop/* (Screen ops)                                  │
│     /api/quality/* (QC ops)                                  │
│     /api/common/* (Auth, Master data)                        │
├──────────────────────┬──────────────────────────────────────┤
│                      │ SQL / SP Calls                        │
│           ┌──────────┴──────────┐                            │
│           ▼                     ▼                            │
│  ┌─────────────────┐  ┌──────────────────┐                  │
│  │  VINATECH_POP   │  │ SmartFactoryV2   │                  │
│  │ (66 bảng riêng) │  │  (MES Core DB)   │                  │
│  │ VINA_KIOSK_LOG  │  │ STB_SetInfo      │                  │
│  │ VINA_EMP        │  │ STB_ProdRouteHist│                  │
│  │ VINA_EQUIP_*    │  │ STB_MaterialLot  │                  │
│  └─────────────────┘  └──────────────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 📌 QUY TẮC ĐỌC KB CHO AI AGENT

1. **Luôn bắt đầu từ INDEX** → Xác định file cần đọc qua Routing Table.
2. **Chỉ đọc đoạn cần thiết** (20-40 dòng) — Surgical Retrieval.
3. **Cross-ref với MES KB** khi liên quan đến SP hoặc bảng chung trong SmartFactoryV2.
4. **POP Web ≠ MES WinForm** — Cùng DB backend nhưng UI/UX khác hoàn toàn.
5. **Mọi thao tác POP đều ghi log** — Kiểm chứng qua `VINATECH_POP.dbo.VINA_POP_ACTION_LOG` (202K+ rows) hoặc `VINA_KIOSK_LOG` (27K+ rows).
6. **Danh mục đầy đủ 66 bảng VINATECH_POP** → Xem chi tiết tại KB_01 §3.6.

> [!WARNING]
> **Lưu ý (2026-09-21):** Bảng `VINA_MATERIAL_INPUT_HIST` (mô tả trong KB_01 §3.1 là SoT cho nhập NVL) hiện có **0 rows** trên production DB. Có khả năng dữ liệu nhập NVL POP hiện ghi trực tiếp vào `SmartFactoryV2.dbo.STB_MaterialLotInfo` mà không dùng bảng trung gian này. Cần xác minh với DX Team.
