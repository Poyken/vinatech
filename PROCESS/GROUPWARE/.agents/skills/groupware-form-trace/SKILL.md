---
name: groupware-form-trace
description: Kỹ năng truy vết toàn diện một biểu mẫu trên Groupware từ khi khởi tạo, qua các bước duyệt, đến khi đồng bộ sang ERP và kích hoạt MES.
---

# Kỹ Năng Truy Vết Biểu Mẫu Groupware (groupware-form-trace)

## Khi Nào Sử Dụng:
- Khi người dùng hỏi về tình trạng một đơn mua hàng (PO), đơn xin nghỉ phép, phiếu khai báo hàng về (Arrival), kế hoạch sản xuất, hoặc yêu cầu thanh toán.
- Khi cần kiểm tra văn bản đang nằm ở cấp duyệt nào hoặc tại sao chưa hoàn tất.

## Quy Trình Thực Hiện:
1. **Bước 1: Tra cứu L1 Matrix:**
   - Xác định loại biểu mẫu và bảng CSDL tương ứng từ `AI_AGENT_CONFIG/GW_FORM_MATRIX.json`.
2. **Bước 2: Chạy Golden Query Trace:**
   - Sử dụng lệnh: `.\gw.ps1 trace "<MÃ_PO_HOẶC_MÃ_VĂN_BẢN>"`.
3. **Bước 3: Phân tích kết quả:**
   - Trạng thái duyệt: `001` (Nháp), `002` (Đang duyệt), `008` (Hoàn tất), `004` (Từ chối).
   - Kiểm tra xem người duyệt hiện tại là ai.
   - Nếu đã sang `008`: Xác nhận xem dữ liệu đã sang bảng ERP tương ứng (`PU_PO`, `PU_BL`, v.v.) chưa.
4. **Bước 4: Báo cáo ngắn gọn cho người dùng:**
   - Xuất bảng tóm tắt 4 trạng thái cốt lõi: Tiêu đề, Người gửi, Cấp duyệt hiện tại, Tình trạng ERP.
