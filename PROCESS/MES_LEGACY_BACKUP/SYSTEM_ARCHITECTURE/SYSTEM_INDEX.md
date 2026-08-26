# 🗂️ HỆ THỐNG PHÂN HỆ TRI THỨC VẬN HÀNH TÍCH HỢP GROUPWARE & MES (MASTER INDEX)

> **Cập nhật:** 14/06/2026
> **Triết lý thiết kế tài liệu:** Tinh gọn, hệ thống hóa cao, triệt tiêu trùng lặp và phân mảnh dữ liệu (DRY Specification).

---

## 📋 Danh Sách Các Tập Tài Liệu Cốt Lõi (Volumes Map)

Toàn bộ hệ thống tri thức, quy trình nghiệp vụ và cẩm nang sửa lỗi được tổ chức chặt chẽ thành **3 Tập chuyên đề (Volumes)** cốt lõi:

| Tập | Tên Tài Liệu Chuyên Đề | Nội Dung Trọng Tâm | Phân Hệ & Màn Hình Liên Quan |
| :--- | :--- | :--- | :--- |
| **Tập 1** | [**Volume 1: Kiến Trúc & CSDL**](VOL_01_SYSTEM_ARCHITECTURE.md) | Kiến trúc metadata động 3 trụ cột, sơ đồ luồng dữ liệu coil-to-container, cấu trúc bảng 13 CSDL, Ma trận ánh xạ Form-to-DB-to-MES, Triggers cấn trừ kho, Agent Jobs, SMTP DB Mail, Script PowerShell và Siêu Prompt tự học hệ thống. | Toàn hệ thống / IT & Dev / DBA |
| **Tập 2** | [**Volume 2: Quy Trình Nghiệp Vụ & Biểu Mẫu**](VOL_02_BUSINESS_WORKFLOWS_AND_FORMS.md) | Phép ẩn dụ Bốn Vương Quốc, Mermaid Sequence Diagrams của 3 dòng đời nghiệp vụ chính (P2P, Prod, O2C), hướng dẫn vận hành chi tiết 17 Biểu mẫu Groupware và các đơn Hành chính/HR, và Từ điển thuật ngữ nghiệp vụ. | Người dùng mới / Vận hành / QA / HR |
| **Tập 3** | [**Volume 3: Cẩm Nang Vận Hành & Khắc Phục Sự Cố**](VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md) | Quy trình trace bug 5 bước chuẩn y khoa, cẩm nang tra cứu và xử lý lỗi phân loại chi tiết theo từng Screen ID (A230 đến Z530), script SQL sửa lỗi giao dịch kẹt, bypass hạn dùng, và case studies hiện trường (Unikey, deadlock, bypass routing). | Hỗ trợ ứng dụng (EA) / Kỹ thuật / QC |

---

## 📰 Nhật Ký Vận Hành & Giám Sát Hàng Ngày (Live Tools)

Bên cạnh 3 Tập tài liệu chuyên đề tĩnh, hệ thống duy trì 2 sổ tay cập nhật động phục vụ giám sát và ghi nhận sự cố:

*   [**Daily Operational Playbook (MES_DAILY_PLAYBOOK.md)**](MES_DAILY_PLAYBOOK.md): Cẩm nang giám sát sức khỏe hệ thống hằng ngày (kiểm tra block session, lag ERP, jobs ngầm, lock table).
*   [**Operational & Troubleshooting Log (MES_OPERATIONAL_LOG.md)**](MES_OPERATIONAL_LOG.md): Nhật ký tích hợp ghi nhận và theo dõi các sự cố phát sinh thực tế tại xưởng.

---

## ⚡ Bảng Tra Cứu Triệu Chứng Nhanh (Symptom Quick Reference)

| Triệu chứng lỗi / Nhu cầu xử lý | Tài liệu hướng dẫn xử lý |
| :--- | :--- |
| **Không đăng nhập được ứng dụng MES / Groupware** | [Tập 3 (Z410)](VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md#z410--user-configuration-cấu-hình-tài-khoản--phân-quyền) |
| **Lỗi không gộp được Box nhỏ tại B523** | [Tập 3 (B523)](VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md#b523--divide-packaging-gộp-box-nhỏ) |
| **Lỗi cấm Scan nhanh dưới 20 phút (Gate 20m) bị bypass** | [Tập 3 (B530)](VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md#b530--production-route-input-chốt-sản-lượng-công-đoạn) |
| **Không in được tem Lot, báo "Plan is locked" ở B450** | [Tập 3 (B450)](VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md#b450--daily-production-plan-lập-kế-hoạch-chạy-ngày) |
| **Model mới đăng ký không hiển thị thông số Vol/Farad** | [Tập 2 (Mục 3.17)](VOL_02_BUSINESS_WORKFLOWS_AND_FORMS.md#317-đăng-ký-các-loại-code-item-code-registration) |
| **Sự cố dính Caps Lock / Unikey khi dùng súng quét** | [Tập 3 (Mục 3.3)](VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md#33-súng-quét-mã-vạch-bị-dính-chữ-caps-lock--unikey) |
| **Lệch chỉ số mẫu ESR (Hiển thị 10 dòng thay vì 20) tại C530** | [Tập 3 (C530)](VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md#c530--oqc-audit-kiểm-định-chất-lượng-xuất-xưởng) |
| **Lỗi Database bị treo / Deadlock do chạy báo cáo quá nặng** | [Tập 3 (Mục 3.4)](VOL_03_SCREEN_OPERATIONS_AND_TROUBLESHOOTING.md#34-sát-thủ-báo-cáo-làm-nghẽn-hệ-thống-cuối-tháng-deadlocks) |
| **Đối soát đơn mua hàng (PO) liên thông chéo** | [Tập 1 (Mẫu 6.1)](VOL_01_SYSTEM_ARCHITECTURE.md#mẫu-61-đối-chiếu-đơn-mua-hàng-po-liên-thông-groupware--erp--mes) |
| **Đối soát Bán hàng & Xuất khẩu chéo** | [Tập 1 (Mẫu 6.5)](VOL_01_SYSTEM_ARCHITECTURE.md#mẫu-65-đối-chiếu-bán-hàng--xuất-khẩu---suju-so--shipment-request--pda-fg01b750b752--erp-giảm-tồn) |
| **Cách cấu hình Database Mail gửi cảnh báo SMTP** | [Tập 1 (Database Mail)](VOL_01_SYSTEM_ARCHITECTURE.md#53-cấu-hình-database-mail-gửi-cảnh-báo-tự-động) |
| **Hướng dẫn chạy tool script PowerShell bổ trợ** | [Tập 1 (Script Guide)](VOL_01_SYSTEM_ARCHITECTURE.md#7-hướng-dẫn-sử-dụng-script-powershell-bổ-trợ) |

---
*Tài liệu master được chuẩn hóa bởi đội ngũ IT & EA Vinatech Việt Nam.*
