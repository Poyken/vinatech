# 🏛️ VINATECH GROUPWARE — KNOWLEDGE BASE & OPERATIONAL HUB

> **Cổng thông tin:** `https://gw.vinatech.com` | **Môi trường:** Bizbox Alpha (Douzone) + Spring Framework + Java Dynamic APIs  
> **Cơ sở dữ liệu trung tâm:** `VINATECH_GROUP` trên SQL Server `dbserver.hycap.co.kr,5398`  
> **Trang chủ tra cứu:** [MASTER_INDEX.md](MASTER_INDEX.md)  
> **Bản đồ tích hợp 4 chiều:** [SYSTEM_INTEGRATION_MAP.md](SYSTEM_INTEGRATION_MAP.md)  
> **Quy tắc vận hành AI Agent:** [GEMINI.md](GEMINI.md)  

---

## 🧭 1. Tổng Quan Trụ Cột Groupware

Hệ thống Groupware là **Cổng Phê Duyệt Thượng Nguồn (Upstream Authority & Approval Gateway)** của Vinatech:
- Mọi đơn mua hàng (PO), kế hoạch sản xuất (Plan), đơn bán hàng (Suju), tuyển dụng/nghỉ việc (HR) đều được khởi tạo và phê duyệt tại đây.
- Sau khi được ký số hoàn tất (`DOCUMENT_SAVE_STATE = '008'` hoặc `'090'`), dữ liệu tự động đồng bộ sang **ERP Douzone (`NEOE`)** để hạch toán sổ sách kế toán và chuyển tiếp xuống **MES (`SmartFactoryV2`)** để thực thi hiện trường.

---

## 📂 2. Cấu Trúc Thư Mục

```
PROCESS/GROUPWARE/
├── 📄 MASTER_INDEX.md                      # Mục lục điều hướng tổng thể
├── 📄 SYSTEM_INTEGRATION_MAP.md            # Bản đồ tích hợp chi tiết GW ↔ ERP ↔ MES ↔ POP
├── 📄 GEMINI.md                            # Quy tắc AI Agent & bảng lệnh vận hành
├── 📄 db_config.json                       # Cấu hình kết nối đa Database (Profile Groupware)
├── 📄 gw.ps1                               # ⚡ CLI Hub điều phối vận hành (find, trace, form, audit, routine, agent)
│
├── 📂 .agents/                             # Hệ sinh thái AI Agent (Skills, Rules, Hooks)
├── 📂 AI_AGENT_CONFIG/                     # Bộ nhớ đệm L1 (GW_FORM_MATRIX.json, APPROVAL_LINE_MATRIX.json)
├── 📂 GROUPWARE_KNOWLEDGE_BASE/            # 15 Modules tri thức chuyên sâu (GW_01 → GW_15)
│   ├── 📂 attachments/                     # Biểu mẫu Excel, mẫu mã kho, bảng đa ngữ & Hóa đơn Logistics
│   │   ├── 📂 Logistic/
│   │   │   ├── 📄 Bee Logistics_Vina tech_By_Air_Inv-2925431946.pdf # Hóa đơn mẫu đối chiếu cước quốc tế
│   │   │   └── 📄 Logistics fee - division.xlsx
│   │   └── 📂 Accounting/                  # Form upload tài sản cố định
│   └── 📂 integrations/                    # 10 Tài liệu phân tích tích hợp chuyên sâu CSDL
│
├── 📂 docs/                                # 📚 TÀI LIỆU KIẾN TRÚC & PHÂN TÍCH CHUYÊN SÂU
│   ├── 📄 VOL_02_BUSINESS_WORKFLOWS_AND_FORMS.md     # Thuyết 4 Vương Quốc, 3 Master Lifecycles, 17 biểu mẫu
│   ├── 📄 groupware_mes_integration_analysis.md      # Khảo sát 882 dòng xác thực PWDCOMPARE & giao dịch DB
│   └── 📄 extracted_manuals_analysis.md              # Khai phá nghiệp vụ từ 14 slide deck PPTX chính thức
│
├── 📂 tools/                               # ⚡ Bộ công cụ PowerShell vận hành
│   ├── 📄 gw.ps1                           # Hub CLI trung tâm
│   ├── 📄 find_kb.ps1                      # Tra cứu siêu tốc L1 Cache (<0.001s)
│   ├── 📄 gw_trace.ps1                     # Golden Query 360° truy vết biểu mẫu
│   ├── 📄 audit_kb_reliability.ps1         # Kiểm toán độ tin cậy schema KB vs DB thực
│   ├── 📄 health_check.ps1                 # Kiểm tra phiếu chờ duyệt & nghẽn sync
│   ├── 📄 inspect_form.ps1                 # Soi chi tiết cấu trúc 1 form
│   └── 📄 run_query.ps1                    # SELECT an toàn tự động kèm NOLOCK
│
└── 📂 sql/                                 # 🗄️ Mã nguồn SQL, Routines & Views
    ├── 📂 routines/                        # 7 Stored Procedures & Functions trích xuất từ DB
    ├── 📂 views/                           # 4 Views nghiệp vụ quan trọng
    ├── 📂 queries/                         # Các câu truy vấn chẩn đoán mẫu
    └── 📄 template_gw_hotfix.sql           # Template hotfix an toàn UTF-8-BOM
```

---

## ⚡ 3. Bảng Lệnh CLI Nhanh (`gw.ps1`)

| Lệnh | Chức năng | Ví dụ |
| :--- | :--- | :--- |
| `.\gw.ps1 find <Keyword>` | Tra cứu siêu tốc L1 Cache | `.\gw.ps1 find "PO"` |
| `.\gw.ps1 trace <DocCode>` | Truy vết 360° xuyên hệ thống | `.\gw.ps1 trace "VINA_EXP202609001"` |
| `.\gw.ps1 form <FormID>` | Soi bảng DB, line, người duyệt | `.\gw.ps1 form "purchaseOrderDocument"` |
| `.\gw.ps1 audit [-Detail]` | Kiểm toán schema tài liệu vs DB | `.\gw.ps1 audit` |
| `.\gw.ps1 routine [Name]` | Tra cứu Stored Procedures & Views | `.\gw.ps1 routine "UP_HR_WTMCALC"` |
| `.\gw.ps1 agent` | Xem kiến trúc API & dynamic engine | `.\gw.ps1 agent` |
| `.\gw.ps1 health [-Detail]` | Báo cáo phiếu chờ duyệt & lỗi | `.\gw.ps1 health` |
| `.\gw.ps1 check` | Test kết nối các profile CSDL | `.\gw.ps1 check` |
