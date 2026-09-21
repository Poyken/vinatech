# 🛡️ VINATECH GROUPWARE AGENT RULES (00_groupware_rules.md)

> **Phạm vi áp dụng:** Workspace `PROCESS/GROUPWARE` | **Phiên bản:** 1.0

## CÁC QUY TẮC BẮT BUỘC:

1. **RULE 0 - ZERO SELECT WITHOUT PRIOR KB:**
   - Cấm chạy lệnh SQL `SELECT` tự do trước khi tra cứu L1 `GW_FORM_MATRIX.json` qua `.\gw.ps1 find "<Keyword>"` hoặc 12 file KB.

2. **RULE 1 - SELECT-ONLY ON PRODUCTION DATABASE:**
   - Tuyệt đối CẤM thực thi DML (`UPDATE`, `DELETE`, `INSERT`) hoặc DDL trực tiếp trên `VINATECH_GROUP` và `NEOE_ERP`. Mọi câu truy vấn phải là đọc an toàn.

3. **RULE 2 - TÔN TRỌNG TÍNH TOÀN VẸN CỦA STATE MACHINE (001 -> 002 -> 008):**
   - Tuyệt đối CẤM sửa thủ công `DOCUMENT_SAVE_STATE = '008'` trên CSDL để bypass quy trình duyệt. Hành động này sẽ làm tê liệt cỗ máy đồng bộ tự động sang ERP.

4. **RULE 3 - BẢO TOÀN ĐỊNH DANH `DOCUMENT_SAVE_CODE`:**
   - Khóa ngoại `DOCUMENT_SAVE_CODE` là mắt xích sống còn liên kết giữa Header và Detail. Tuyệt đối không thay đổi mã này.

5. **RULE 4 - TRÍCH XUẤT CHÍNH XÁC (SURGICAL RETRIEVAL):**
   - Ưu tiên đọc L1 JSON Matrix (<0.001s). Chỉ đọc đúng đoạn 30-50 dòng cần thiết khi xem file Markdown.

6. **RULE 5 - GOLDEN QUERY TRACE 360°:**
   - Dùng `.\gw.ps1 trace "<Target>"` trong lần kiểm tra đầu tiên khi cần truy vết PO, mã chứng từ, mã nhân viên hoặc mã vật tư.

7. **RULE 6 - BẢO VỆ WORKSPACE & TIÊU CHUẨN CÔNG CỤ:**
   - BẮT BUỘC sử dụng CLI Hub `.\gw.ps1`. Không tạo script `.ps1` rời rạc ở thư mục gốc. Script test phải nằm trong `tools/scratch/`.

8. **RULE 7 - BẢO MẬT CREDENTIAL & TOKEN SSO:**
   - Tuyệt đối không để lộ hoặc commit các Session Key, SSO Token thật lên Git.

9. **RULE 8 - ĐỐI SOÁT ĐA NỀN TẢNG (GW ↔ ERP ↔ MES):**
   - Khi điều tra lỗi người dùng phản ánh, phải kiểm tra sự thống nhất giữa 3 tầng: GW (Duyệt) ➔ ERP (Chứng từ) ➔ MES (Hiện trường).

10. **RULE 9 - TỐC ĐỘ PHẢN HỒI (<5-10s):**
    - Tối đa 1-2 tool calls/câu hỏi. Lấy xong thông tin cốt lõi là dừng và trả lời ngay.

11. **RULE 10 - CẤM TỰ Ý TẠO SCRIPT SỬA CSDL KHI CHƯA ĐƯỢC YÊU CẦU:**
    - Khi người dùng hỏi nguyên nhân hoặc yêu cầu kiểm tra: Chỉ phân tích và báo cáo hiện trạng. Không tự ý tạo script hotfix hay can thiệp CSDL.

12. **RULE 11 - XỬ LÝ YÊU CẦU THIẾU THÔNG TIN (UNDERSPECIFIED INPUT):**
    - Nếu người dùng chỉ gõ "check" hoặc "kiểm tra": Kích hoạt `.\gw.ps1 health` để quét các phiếu tồn đọng và đưa ra các tùy chọn tra cứu nhanh.
