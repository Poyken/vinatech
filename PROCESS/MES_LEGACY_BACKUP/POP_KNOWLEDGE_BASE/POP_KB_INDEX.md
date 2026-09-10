<!--
AI-READY METADATA
Purpose: Master Index — Bộ KB toàn diện cho hệ thống POP (Point of Production) Vinatech
Scope: POP Web Kiosk (pop.vinatech.com), VINATECH_POP DB, SmartFactoryV2 Integration
Single Source of Truth: POP_KNOWLEDGE_BASE/POP_KB_INDEX.md
Target Systems: POP Web UI, VINATECH_POP DB, SmartFactoryV2 DB, VINATECH_RESTFUL API
Related Files:
  - [MES KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_INDEX.md)
  - [POP_USER_MANUAL.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_USER_MANUAL.md)
  - [POP_SYSTEM_INTEGRATION_GUIDE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_SYSTEM_INTEGRATION_GUIDE.md)
-->

# 📋 POP KNOWLEDGE BASE — MASTER INDEX

> **Hệ thống:** POP (Point of Production) — Web Kiosk Sản xuất Vinatech  
> **URL:** `https://pop.vinatech.com/`  
> **Backend DB:** `VINATECH_POP` (riêng) + `SmartFactoryV2` (shared với MES)  
> **API Server:** `https://pop.vinatech.com/api/` (RESTful, JSON)  
> **Phiên bản KB:** v2.0 (Khởi tạo 2026-09-09 — Đồng bộ 100% Bộ Slide Đào Tạo POP.pptx của Hanbit Kang & Vietnam DX Team)  
> **🔑 Keywords:** POP, kiosk, sản xuất, đóng gói, nhập NVL, packing, merge pack, label, quality, IQC, PQC, OQC, slide mapping, marking, self inspection, auto-save

---

## 📚 BẢN ĐỒ TÀI LIỆU (KB FILE MAP)

| # | File | Nội dung | Khi nào dùng |
|---|------|----------|--------------|
| INDEX | [POP_KB_INDEX.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_INDEX.md) | Master Index + Routing Map | Điểm bắt đầu mọi tra cứu POP |
| 01 | [POP_KB_01_ARCHITECTURE_AND_API.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_01_ARCHITECTURE_AND_API.md) | Kiến trúc hệ thống, API endpoints, DB schema mapping | Debug API, hiểu data flow |
| 02 | [POP_KB_02_SCREEN_OPERATIONS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_02_SCREEN_OPERATIONS.md) | Hướng dẫn vận hành từng màn hình + DB impact (v2.0) | Thao tác sản xuất, đóng gói, marking |
| 03 | [POP_KB_03_TROUBLESHOOTING.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_03_TROUBLESHOOTING.md) | Lỗi thường gặp + Root cause + Fix | Xử lý sự cố khẩn cấp |
| 04 | [POP_KB_04_ROLLBACK_AND_SAFETY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_04_ROLLBACK_AND_SAFETY.md) | Phân tích khả năng Rollback trên UI + DB safety (v2.0) | Hủy đóng gói Box, an toàn dữ liệu |
| 05 | [POP_KB_05_DB_VERIFICATION_AUDIT.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_KB_05_DB_VERIFICATION_AUDIT.md) | Kết quả đối chiếu UI vs DB thực tế | Kiểm toán, xác minh tính chính xác |
| MAP | [POP_SLIDE_DECK_MAPPING_AND_ANALYSIS.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_SLIDE_DECK_MAPPING_AND_ANALYSIS.md) | Phân tích 51 slides POP.pptx & 50 ảnh trích xuất | Đối chiếu tài liệu đào tạo DX Team |
| REF | [POP_USER_MANUAL.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_USER_MANUAL.md) | Cẩm nang vận hành chi tiết 6 phần cho end-user (v2.0) | Training công nhân, thao tác Kiosk |
| REF | [POP_SYSTEM_INTEGRATION_GUIDE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_SYSTEM_INTEGRATION_GUIDE.md) | Tích hợp POP ⇄ MES ⇄ Groupware ⇄ ERP | Hiểu luồng dữ liệu liên hệ thống |
| REF | [POP_QUALITY_AND_SCREEN_REFERENCE.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_QUALITY_AND_SCREEN_REFERENCE.md) | Tham chiếu Quality screens + mapping | QC operations |
| REF | [POP_TRAINING_SCREEN_QUALITY.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/POP_KNOWLEDGE_BASE/POP_TRAINING_SCREEN_QUALITY.md) | Tài liệu training Quality screens | Đào tạo QC |

---

## 🗺️ ROUTING TABLE — TRA CỨU NHANH THEO TÌNH HUỐNG

| Tình huống | File chính | File phụ |
|-----------|-----------|---------|
| Lỗi đăng nhập POP, không load được trang | KB_01 §1.1 | KB_03 §1 |
| Không thấy Work Order / DayPlan | KB_02 §1.4 | KB_03 §2, Slide 13 |
| Lỗi nhập NVL (Material Input) | KB_02 §6 | KB_01 §3.2, Slide 21-23 |
| Nạp nhanh NVL theo BOM | KB_02 §6.2 ("Lượng kiến cấp") | USER_MANUAL §2.3.1 |
| Tra cứu đích danh LOT NVL trong kho | KB_02 §6.2 ("Tồn kho") | USER_MANUAL §2.3.2 |
| Nhập mã Marking công đoạn Bọc Vỏ | KB_02 §7.2 | USER_MANUAL §2.7, Slide 29 |
| Lỗi đóng gói / Merge Pack / Chia Box | KB_02 §9 | KB_03 §4, Slide 33-37 |
| Muốn hủy đóng gói Box (Rollback) | **KB_04 §2.5** (SoT) | KB_02 §9.2, Slide 39 |
| Lỗi in tem / label print | KB_02 §10 | KB_03 §5, Slide 38, 45-47 |
| Tự kiểm In-Line QC tại chuyền | KB_02 §12.1 | USER_MANUAL §6, Slide 49, 50 |
| Tra cứu ảnh slide gốc theo số slide | **SLIDE_MAPPING** (SoT) | assets/slides_images/ |
| Quality: IQC/PQC/OQC/FOQC | KB_02 §12 | POP_QUALITY_REF |
| API endpoint không phản hồi | KB_01 §2 | KB_03 §6 |
| Kiểm toán UI vs DB | **KB_05** (SoT) | KB_01 §3 |
| Hiểu kiến trúc tổng thể | KB_01 §1 | POP_SYSTEM_INTEGRATION |
| Training / Hướng dẫn end-user | POP_USER_MANUAL | KB_02 |

---

## 🔗 CROSS-REFERENCE VỚI MES KB

| POP KB | MES KB tương ứng | Ghi chú |
|--------|------------------|---------|
| POP_KB_01 (Architecture) | [KB_08_CORE_SP_ENGINE](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_08_CORE_SP_ENGINE.md) | POP gọi cùng SP engine |
| POP_KB_02 (Screens) | [KB_01_UI_AND_SCREENS](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_01_UI_AND_SCREENS.md) | POP Web ≠ MES WinForm |
| POP_KB_03 (Troubleshoot) | [KB_09_SCREEN_BUG_FIXBOOK](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_09_SCREEN_BUG_FIXBOOK.md) | Một số bug chung |
| POP_KB_04 (Rollback) | [KB_04_PACKING](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_04) | Logic hủy đóng gói chung |
| POP nhập NVL | [KB_03_PRODUCTION](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/MES_LEGACY_BACKUP/MES_MASTER_KNOWLEDGE_BASE/KB_03_PRODUCTION.md) | Trừ kho chia sẻ logic |

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
│  │  (POP-specific) │  │  (MES Core DB)   │                  │
│  │ VINA_MATERIAL_  │  │ STB_SetInfo      │                  │
│  │ INPUT_HIST      │  │ STB_ProdRouteHist│                  │
│  │ VINA_SSO_*      │  │ STB_MaterialLot  │                  │
│  └─────────────────┘  └──────────────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 📌 QUY TẮC ĐỌC KB CHO AI AGENT

1. **Luôn bắt đầu từ INDEX** → Xác định file cần đọc qua Routing Table.
2. **Chỉ đọc đoạn cần thiết** (20-40 dòng) — Surgical Retrieval.
3. **Cross-ref với MES KB** khi liên quan đến SP hoặc bảng chung trong SmartFactoryV2.
4. **POP Web ≠ MES WinForm** — Cùng DB backend nhưng UI/UX khác hoàn toàn.
5. **Mọi thao tác POP đều ghi log** — Kiểm chứng qua `VINATECH_POP.dbo.VINA_MATERIAL_INPUT_HIST`.
