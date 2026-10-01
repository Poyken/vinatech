---
name: groupware-erp-sync
description: Kỹ năng chẩn đoán và khắc phục sự cố không đồng bộ chứng từ giữa Groupware (VINATECH_GROUP) và ERP Douzone iU (NEOE).
---

# Kỹ Năng Chẩn Đoán Đồng Bộ GW-ERP (groupware-erp-sync)

## Khi Nào Sử Dụng:
- Khi biểu mẫu trên Groupware đã chuyển sang trạng thái `008` (Approved) nhưng ERP không tìm thấy chứng từ (PO, BL, SO, BOM).
- Khi có sự sai lệch số lượng, đơn giá, hoặc tỷ giá giữa GW và ERP.

## Quy Trình Xử Lý:
1. **Bước 1: Đối soát Header & Line trên Groupware:**
   - Truy vấn `VINA_DOCUMENT_POH` và `VINA_DOCUMENT_POL` để kiểm tra tính hợp lệ của mã đối tác `CD_PARTNER` và mã vật tư `CD_ITEM`.
   - Kiểm tra `DOCUMENT_SAVE_STATE`: Nếu chưa phải `008` (Hoàn tất duyệt), hệ thống Bizbox chưa kích hoạt trigger/API bắn dữ liệu sang ERP.
2. **Bước 2: Kiểm tra Master Data trên ERP Douzone (NEOE):**
   - Kiểm tra xem đối tác có bị khóa giao dịch trong `NEOE.dbo.MA_PARTNER WITH (NOLOCK)` không (`USE_YN = 'Y'`).
   - Kiểm tra xem vật tư có tồn tại và đang hoạt động trong `NEOE.dbo.MA_PITEM WITH (NOLOCK)` không.
3. **Bước 3: Kiểm tra Bảng Chứng Từ ERP:**
   - Kiểm tra đơn hàng trong `NEOE.dbo.PU_PO WITH (NOLOCK)` hoặc `NEOE.dbo.SA_SO WITH (NOLOCK)`.
   - Nếu văn bản GW đã duyệt `008` nhưng bảng ERP trống: Kiểm tra log interface trong `DZICUBE.dbo.ABDOCU` hoặc bảng trung gian đồng bộ.
4. **Bước 4: Đưa ra giải pháp an toàn:**
   - Tuyệt đối CẤM sửa trực tiếp `DOCUMENT_SAVE_STATE = '008'` trên CSDL (Rule 2).
   - Kích hoạt lại mã đối tác/vật tư trên ERP nếu bị khóa.
   - Báo cáo cho IT/Kế toán kích hoạt thủ tục tái đồng bộ trên Bizbox Alpha.

