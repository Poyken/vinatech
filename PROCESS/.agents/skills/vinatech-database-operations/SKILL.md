---
name: vinatech-database-operations
description: Quy trình thao tác an toàn trên 15 CSDL Vinatech, tra cứu schema, kiểm tra sức khỏe và chạy SELECT tối ưu.
---

# 🛠️ Vinatech Database Operations Skill

Kỹ năng này hướng dẫn cách thực hiện các tác vụ đọc dữ liệu và tra cứu từ điển dữ liệu (Data Dictionary) trên 15 CSDL tại máy chủ `dbserver.hycap.co.kr,5398`.

## 1. Nguyên Tắc L1 Cache & Surgical Retrieval
- Trước khi chạy query, dùng `.\db.ps1 find "<TênBảng>"` để lấy ngay: CSDL chứa bảng, Khóa chính, và mục đích nghiệp vụ.
- Chỉ đọc đoạn 20-40 dòng cần thiết trong file Markdown KB tương ứng.

## 2. Kiểm Tra Sức Khỏe Toàn Diện (Morning Health Check)
```powershell
.\db.ps1 health
```
Lệnh này quét đồng thời 15 CSDL, đo thời gian phản hồi (ms) và xác nhận trạng thái sẵn sàng của connection pool.

## 3. Tra Cứu Cấu Trúc Bảng (Schema & Data Dictionary)
```powershell
.\db.ps1 schema -Profile <Profile> -Table <TableName>
```
Xuất ra danh sách toàn bộ cột, kiểu dữ liệu, độ dài, nullability, và khóa chính.

## 5. Giám Sát Khóa & Deadlock (Real-time Locks)
```powershell
db locks [-Profile <Profile>]
```
Soi ngay lập tức các phiên bị block (`blocking_session_id <> 0`), danh sách SQL text gây nghẽn và thời gian giữ lock.

## 6. Giao Thức Bảo Vệ 3 Bảng Khổng Lồ (Rule 15):
1. **`STB_VVT_ESRDATA` (423 Triệu dòng, 64.8 GB):** CẤM câu lệnh `SELECT` không có điều kiện `id` (ví dụ `WHERE id > ...`).
2. **`STB_ProductStockInfo` (69 Triệu dòng, 13.1 GB):** BẮT BUỘC luôn lọc theo `WHERE BaseDate = '...'`.
3. **`STB_SetInfo` (789K dòng, HEAP):** Luôn lọc theo `Barcode`, `LotNumber`, `DayPlanNo`.

## 7. Kỷ Luật Tuyệt Đối (Rule 21 - Zero Blind SQL Exploration):
- CẤM chạy chuỗi SELECT thử sai mò mẫm bảng/cột.
- Luôn tra cứu cấu trúc qua `db find "<Keyword>"` và `DATABASE_MATRIX.json` trước.

