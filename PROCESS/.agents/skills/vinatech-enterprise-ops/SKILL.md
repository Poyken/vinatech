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

## 2. Quy Trình Hotfix An Toàn Tuyệt Đối (Rule 24 - Zero Irreversible Hotfix)
Mọi can thiệp CSDL phải tuân thủ nghiêm ngặt quy trình Pre-flight Snapshot:
1. **Pre-flight Snapshot:** Trước khi chạy DML trên Production, hệ thống tự động lưu bản chụp JSON các bản ghi gốc tại `backups/snapshots/` và sinh script hoàn tác `backups/undo/undo_<Target>_<Timestamp>.sql`.
2. **Triển khai an toàn:** Luôn có `BEGIN TRAN...ROLLBACK` và thông tin định danh `Author = 'vanduc'`, `ChangeUserID = 'vanduc'`.
3. **1-Click Rollback:**
   ```powershell
   # Xem trước câu lệnh hoàn tác:
   ops rollback -Target <LotID_hoặc_Mã>
   # Thực thi hoàn tác an toàn qua Transaction:
   ops rollback -Target <LotID_hoặc_Mã> -Deploy
   ```

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
