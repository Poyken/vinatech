---
name: vinatech-enterprise-ops
description: Điều hành tổng hành dinh Enterprise Hub (ops.ps1 v4.0), Morning Patrol quét 15 DB và 5 phân hệ, Universal Smart Auto-Router cho 10 loại mã, Pre-flight Snapshot & 1-Click Rollback an toàn, Weekly Report chuẩn Rule 22, và Anti-Drift Audit.
---

# 🌟 Vinatech Enterprise Operations Skill (Master Hub ops.ps1 v4.0)

Kỹ năng này hướng dẫn toàn bộ quy trình vận hành và điều phối cấp cao nhất trên toàn bộ hệ sinh thái số Vinatech thông qua Enterprise Orchestration Hub `ops.ps1`.

---

## 1. Điểm Tiếp Nhận Đầu Tiên (Rule 23 - ops.ps1 First)
Khi nhận bất kỳ yêu cầu nào từ người dùng liên quan đến một mã chưa rõ nguồn gốc hoặc khi bắt đầu ca làm việc:
- **Morning Patrol (<3s):**
  ```powershell
  ops health
  # Hoặc kiểm tra chi tiết:
  ops health -Detail
  ```
  Quét song song 15 CSDL, kết nối POP Kiosk, Core MES, Groupware Bizbox, K-System Ace, kiểm tra blocking locks và zombie processes.

- **Universal Smart Auto-Router (<0.5s):**
  ```powershell
  ops trace "<Keyword>"
  ```
  Tự động nhận diện 10 loại thực thể và điều phối sang sub-hub tương ứng:
  1. `VVM...` ➔ POP Kiosk / NVL BOM (`pop nvl`)
  2. `VV...` ➔ Core MES Lot Trace 360° (`mes trace`)
  3. `2608...` / `PO...` ➔ Groupware PO Trace (`gw trace`)
  4. `B[0-9]{3}` ➔ MES Screen Debug (`mes screen`)
  5. `_TPR...` / `_T...` ➔ K-System Module/Schema (`ksys schema`)
  6. `usp_...` ➔ Live Stored Procedure Inspection (`mes sp` / `db sp`)
  7. `STB_...` / `SF_...` ➔ MES/POP Table Data Dictionary
  8. `VINA_...` ➔ Groupware Document Table Data Dictionary
  9. `M[0-9]{2}` / `EQP...` ➔ POP Machine Unlock / Status
  10. `192.168...` / `dbserver...` ➔ Database Connectivity & Latency

---

## 2. Quy Trình Triển Khai Hotfix & Hoàn Tác An Toàn (Rule 24 & DEPLOYMENT_SOP)
Mọi can thiệp CSDL phải tuân thủ nghiêm ngặt quy trình 5 bước trong [DEPLOYMENT_SOP.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/.agents/rules/DEPLOYMENT_SOP.md):

1. **Sinh mã & Tiền kiểm định (Pre-flight Lint):**
   - Soạn script theo chuẩn 4 pha bọc Transaction, `Author = 'vanduc'`, `ChangeUserID = 'vanduc'`.
   - Kiểm tra an toàn qua `validate_sql.ps1`.

2. **Thực thi Triển Khai Qua Master Hub (`ops deploy`):**
   ```powershell
   # Triển khai Hotfix vào CSDL chỉ định (Mặc định SmartFactoryV2):
   ops deploy ".\MES_POP\sql\hotfixes\hotfix_20261002_VVQR2601001.sql" -Profile SmartFactoryV2
   ```
   *Cơ chế tự động:*
   - Bóc tách TargetId (Lot/PO/Mã sự cố) từ câu lệnh.
   - Tự động chụp JSON Snapshot tại `backups/snapshots/snap_<Target>_<ts>.json`.
   - Tự động sinh file hoàn tác `backups/undo/undo_<Target>_<ts>.sql` có đóng dấu `-- Profile: <DbProfile>`.
   - Thực thi từng batch `GO` an toàn qua ADO.NET và tự động cập nhật nhật ký tri thức `AI_AGENT_CONFIG/HOTFIX_LOG.jsonl`.

3. **1-Click Emergency Rollback (< 1.5s):**
   ```powershell
   # Bước 1: Xem trước câu lệnh hoàn tác (Dry-run):
   ops rollback -Target <LotID_hoặc_Mã>

   # Bước 2: Kích hoạt hoàn tác khôi phục nguyên trạng ngay lập tức:
   ops rollback -Target <LotID_hoặc_Mã> -Deploy
   ```
   Hệ thống tự động phát hiện Database Profile từ header của undo script, mở Transaction và khôi phục dữ liệu nguyên vẹn ban đầu.

---

## 3. Dọn Dẹp Workspace & Tiêu Diệt Zombie Process (Rule 25)
Bảo vệ độ sạch của thư mục gốc và ngăn ngừa quá tải CPU / quạt máy rú:
```powershell
ops clean
```
- Dọn dẹp các tệp tạm trong `scratch/`, `.tmp`, log rác.
- Tự động phát hiện và cảnh báo/tiêu diệt các tiến trình chạy ngầm mồ côi (`node`, `powershell`, `sqlcmd`).

---

## 4. Tự Động Soạn Báo Cáo Tuần IT Chuẩn Rule 22
Tổng hợp toàn bộ sự cố và công việc trong tuần, tự động phân loại rạch ròi giữa **POP** và **MES**:
```powershell
ops weekly-report
# Hoặc chỉ định khoảng ngày:
ops weekly-report -StartDate "2026-09-25" -EndDate "2026-10-02"
```
Kết quả được xuất ra file CSV chuẩn hóa tại thư mục Báo Cáo Tuần của IT.

---

## 5. Phòng Chống Sai Lệch Tri Thức (Rule 26 - Anti-Drift Audit)
Định kỳ kiểm toán đối soát giữa tài liệu KB / L1 Cache và cấu trúc CSDL thực tế:
```powershell
ops audit-kb
```
Quét hơn 35.000 Stored Procedures và 7.000 bảng trên 6 CSDL chính, phát hiện tức thời các bảng/SP bị đổi tên hoặc lệch định nghĩa.
