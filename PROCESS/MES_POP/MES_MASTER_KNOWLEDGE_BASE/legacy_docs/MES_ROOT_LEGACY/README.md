# ⚡ Vinatech MES Workspace (Enterprise MES_V2 Architecture)

Workspace quản trị và phát triển hệ sinh thái NAIS MES cho Vinatech.

---

## 🚀 1. Cấu Trúc Thư Mục Hiện Tại

```
MES/
├── MES_V2/                          # HỆ THỐNG MES THẾ HỆ MỚI (MODERN & MODULAR)
│   ├── config/                      # Cấu hình CSDL & AI Agent
│   ├── core/                        # Động cơ PowerShell Module hướng đối tượng (Vinatech.MES.psm1)
│   ├── cli/                         # Cổng giao diện dòng lệnh hợp nhất (mes.ps1, check, query...)
│   ├── docs/                        # 100% Tri thức phân tầng & Sổ tay cứu hộ 70+ bugs
│   ├── sql/                         # Templates, Patches & SP Cache
│   └── .agent/                      # Cấu hình AI Agent tối ưu Token
├── db_config.json                   # Cấu hình CSDL root
├── GEMINI.md                        # Auto-context cho AI Agent
└── README.md                        # Tài liệu hướng dẫn workspace
```

> **Lưu ý:** Các tài liệu và công cụ phiên bản cũ đã được lưu trữ an toàn tại thư mục backup `C:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\MES_LEGACY_BACKUP`.

---

## 🛠️ 2. Khởi Động Nhanh Qua Cổng Lệnh

```powershell
# Kiểm tra kết nối CSDL
.\MES_V2\cli\mes.ps1 check

# Truy vấn dữ liệu SELECT siêu tốc
.\MES_V2\cli\mes.ps1 query "SELECT TOP 5 MaterialCode, MaterialName FROM STB_MaterialMaster WITH(NOLOCK)"

# Chẩn đoán 360° Barcode
.\MES_V2\cli\mes.ps1 debug -Barcode "VVNP263R033573"

# Chẩn đoán màn hình & SP Mapping
.\MES_V2\cli\mes.ps1 debug -Screen "B523"
```
