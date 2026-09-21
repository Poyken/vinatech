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

## 4. Truy Vấn SELECT An Toàn
```powershell
.\db.ps1 query -Profile <Profile> -Query "SELECT TOP 10 ... FROM <table> WITH(NOLOCK) WHERE ..."
```
- CLI tự động kiểm tra cú pháp SELECT-ONLY.
- Tự động cảnh báo nếu thiếu `WITH(NOLOCK)`.
- Giới hạn tối đa 50 dòng kết quả.
