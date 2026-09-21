# 🛡️ 10 QUY TẮC VÀNG VẬN HÀNH AGENT GROUPWARE (VINATECH_GROUP)

> **Phạm vi áp dụng:** Workspace `PROCESS/GROUPWARE` | **Single Source of Truth:** `.agents/rules/00_groupware_rules.md`

---

## ⛔ CÁC NGUYÊN TẮC BẤT BIẾN:

1. **RULE 0 - ZERO SELECT WITHOUT PRIOR KB (TRA CỨU TRƯỚC KHI TRUY VẤN):**
   - Luôn tra cứu L1 `GW_FORM_MATRIX.json` qua `.\gw.ps1 find "<Keyword>"` hoặc 12 file KB trước khi chạy bất kỳ câu lệnh SQL SELECT nào.

2. **RULE 1 - SELECT-ONLY ON PRODUCTION DATABASE:**
   - Tuyệt đối CẤM thực thi DML (`UPDATE`, `DELETE`, `INSERT`) hoặc DDL trực tiếp trên `VINATECH_GROUP`.
   - Mọi đề xuất hotfix/điều chỉnh dữ liệu phải có `BEGIN TRAN...ROLLBACK` và được review bởi Quản trị viên hệ thống.

3. **RULE 2 - TÔN TRỌNG TÍNH TOÀN VẸN CỦA STATE MACHINE (001 -> 002 -> 008):**
   - Tuyệt đối CẤM update thủ công `DOCUMENT_SAVE_STATE = '008'` trên CSDL để bypass phê duyệt, vì sẽ làm gãy chuỗi Trigger/Job tự động đồng bộ sang ERP `NEOE`.

4. **RULE 3 - BẢO TOÀN ĐỊNH DANH `DOCUMENT_SAVE_CODE`:**
   - Mã `DOCUMENT_SAVE_CODE` là khóa ngoại duy nhất liên kết giữa `VINA_DOCUMENT_SAVE`, các bảng Detail và `VINA_DOCUMENT_SAVE_RELATION`. Cấm mọi hành vi sửa đổi mã này.

5. **RULE 4 - SURGICAL RETRIEVAL (TRÍCH XUẤT CHÍNH XÁC):**
   - Ưu tiên đọc L1 JSON Matrix (<0.001s, ~150 tokens). Khi cần đọc file KB Markdown, chỉ đọc đúng đoạn 30-50 dòng cần thiết để tiết kiệm ngữ cảnh.

6. **RULE 5 - GOLDEN QUERY TRACE 360° FIRST:**
   - Khi nhận mã chứng từ (`NO_PO`, `DOCUMENT_SAVE_CODE`, `NO_EMP`, `CD_ITEM`), luôn chạy `.\gw.ps1 trace "<Target>"` đầu tiên để quét đồng thời cả Groupware, ERP và MES trong một lần truy vấn.

7. **RULE 6 - BẢO VỆ WORKSPACE & TIÊU CHUẨN CÔNG CỤ:**
   - Không tạo các file script `.ps1` rời rạc ngoài thư mục gốc. Bắt buộc dùng CLI Hub `.\gw.ps1`.
   - File nháp tạm thời phải lưu trong `tools/scratch/`.

8. **RULE 7 - BẢO MẬT CREDENTIAL & TOKEN SSO:**
   - Tuyệt đối không commit Access Token hay Session Key lên kho mã nguồn. Mọi Token phải được lưu vào file cấu hình bảo mật riêng.

9. **RULE 8 - ĐỐI SOÁT ĐA NỀN TẢNG (GW ↔ ERP ↔ MES):**
   - Khi giải quyết một sự cố (ví dụ không nhập được kho F330), phải kiểm tra chuỗi 3 mắt xích: Trạng thái duyệt trên GW ➔ Chứng từ trên ERP ➔ Trạng thái hiển thị trên MES.

10. **RULE 9 - TỐC ĐỘ PHẢN HỒI (<5-10s):**
    - Tối đa 1-2 tool calls cho mỗi câu hỏi. Trả lời ngay khi có đủ thông tin, không chạy chuỗi dài lặp lại.
