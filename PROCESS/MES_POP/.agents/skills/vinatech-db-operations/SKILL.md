---
name: vinatech-db-operations
description: Quản trị, truy vấn an toàn và giám sát 15 cơ sở dữ liệu hệ sinh thái Vinatech (SmartFactoryV2, SmartFramework, Groupware, ERP, POP, Andon, KSOX...).
---

# Vinatech Multi-Database Operations Skill

## Khi Nào Kích Hoạt Skill Này?
Kích hoạt khi cần truy vấn dữ liệu giữa các phân hệ (Groupware, ERP, POP, MES), kiểm tra kết nối CSDL, chạy Morning Health Check, kiểm tra Lock/Deadlock hoặc Audit đối soát schema tài liệu vs DB Live.

## Các Thao Tác Trọng Tâm:

### 1. Truy Vấn Đa CSDL An Toàn (SELECT-Only)
- Mặc định MES: `.\mes.ps1 query "SELECT TOP 10 * FROM STB_SetInfo WITH(NOLOCK)"`
- Groupware: `.\mes.ps1 query "SELECT TOP 10 * FROM GW_APPROVAL_DOC WITH(NOLOCK)" -Profile "Groupware"`
- POP Kiosk: `.\mes.ps1 query "SELECT TOP 10 * FROM STB_POP_TerminalInfo WITH(NOLOCK)" -Profile "POP"`
- SmartFramework: `.\mes.ps1 query "SELECT TOP 10 * FROM SF_UserInfo WITH(NOLOCK)" -Profile "SmartFramework"`

### 2. Giám Sát Sức Khỏe Vận Hành (Morning Health Check)
- Chạy: `.\mes.ps1 health -Detail`
- Kiểm tra 5 CSDL core, quét Lot bị HOLD (kho `HOLDING_WH`), đếm giao dịch 24h và kiểm tra session lock trên SQL Server.

### 3. Audit Độ Tin Cậy Tài Liệu Markdown vs Live DB
- Chạy: `.\mes.ps1 audit`
- Tự động đối soát 1,673 bảng và 3,659 SP, xuất báo cáo `KB_RELIABILITY_REPORT.md`.
