# 🤖 VINATECH GROUPWARE AGENT ECOSYSTEM (.agents)

> **Workspace:** `PROCESS/GROUPWARE` | **Phiên bản:** 1.0

## Cấu Trúc Hệ Sinh Thái:
- **`rules/`**
  - `00_groupware_rules.md`: 12 Quy tắc vàng cốt lõi khi vận hành và hỗ trợ người dùng Groupware.
  - `01_sql_safety_rules.md`: Quy tắc an toàn CSDL Production (SELECT-only, NOLOCK, bảo toàn dữ liệu).
- **`skills/`**
  - `groupware-form-trace`: Kỹ năng truy vết toàn diện một biểu mẫu từ khi tạo nháp, qua các cấp duyệt đến khi đồng bộ sang ERP và kích hoạt màn hình MES.
  - `groupware-erp-sync`: Kỹ năng kiểm tra và xử lý điểm nghẽn đồng bộ chứng từ giữa Groupware và ERP Douzone iU (NEOE).
  - `groupware-db-operations`: Kỹ năng truy vấn CSDL VINATECH_GROUP an toàn và giải mã các bảng quan hệ phức tạp.
- **`agents/`**
  - `form-auditor`: Agent chuyên trách kiểm toán tình trạng biểu mẫu, thời gian tồn đọng và lịch sử phê duyệt.
  - `sync-investigator`: Agent chuyên trách phân tích và điều tra các sự cố mất mát/sai lệch dữ liệu giữa GW, ERP và MES.
  - `masterdata-coordinator`: Agent theo dõi và điều phối đăng ký vật tư mới, BOM version 2001 và đối tác.

## Tra Cứu Nhanh:
- L1 In-Memory Cache: `AI_AGENT_CONFIG/GW_FORM_MATRIX.json` (17 forms, <0.001s)
- Central CLI Hub: `.\gw.ps1` (Tra cứu, truy vết, kiểm tra kết nối, sức khỏe hệ thống)
