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
   - Xác định loại biểu mẫu và bảng CSDL tương ứng từ `AI_AGENT_CONFIG/GW_FORM_MATRIX.json` qua lệnh: `gw find "<Keyword>"`.
   - Các biểu mẫu cốt lõi:
     * `FORM_PO` (2608...): Đơn mua hàng ngoại/nội ➔ Bảng `VINA_DOCUMENT_POH`, `VINA_DOCUMENT_POL` ➔ ERP `NEOE.dbo.PU_PO`
     * `FORM_ARRIVAL`: Khai báo hàng về ➔ Bảng `VINA_DOCUMENT_ARRIVAL_MASTER` ➔ ERP `NEOE.dbo.PU_BL`
     * `FORM_RECEIVING`: Phiếu nhập kho ➔ Yêu cầu IQC Pass tại MES `C220`
     * `FORM_EXPENSE`: Tờ trình thanh toán / chi phí ➔ Bảng `VINA_DOCUMENT_EXPENSE` ➔ `DZICUBE.dbo.ABDOCU`
     * `FORM_DAILY_PLAN`: Kế hoạch sản xuất ngày ➔ Kích hoạt MES `B310`/`B450`
2. **Bước 2: Chạy Golden Query Trace:**
   - Sử dụng lệnh: `gw trace "<MÃ_PO_HOẶC_MÃ_VĂN_BẢN>"`.
   - Xem chi tiết cấu trúc form: `gw form "<FormName>"`.
3. **Bước 3: Phân tích kết quả:**
   - Trạng thái duyệt State Machine: `001` (Nháp), `002` (Đang duyệt), `008` (Hoàn tất Phê chuẩn), `004` (Từ chối).
   - Kiểm tra người duyệt hiện tại và thời gian chờ duyệt.
   - Nếu đã sang `008`: Xác nhận xem dữ liệu đã sang bảng ERP tương ứng (`PU_PO`, `PU_BL`, v.v.) chưa.
4. **Bước 4: Báo cáo ngắn gọn cho người dùng:**
   - Xuất bảng tóm tắt 4 trạng thái cốt lõi: Tiêu đề văn bản, Người lập phiếu, Cấp duyệt hiện tại, Tình trạng ERP & MES.

