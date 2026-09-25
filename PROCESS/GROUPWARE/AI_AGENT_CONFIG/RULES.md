# 🛡️ CÁC QUY TẮC VÀNG VẬN HÀNH AGENT GROUPWARE (VINATECH_GROUP)

> **Phạm vi áp dụng:** Workspace `PROCESS/GROUPWARE` | **Single Source of Truth:** `.agents/rules/00_groupware_rules.md`  
> **Tài liệu kim chỉ nam:** `GROUPWARE_KNOWLEDGE_BASE/GW_00_CORE_OPERATING_PRINCIPLES.md`  
> **Phiên bản:** 2.0 (Master Governance Edition)

---

## 🧭 NGUYÊN LÝ CỐT LÕI
Groupware là **CỔNG THẨM QUYỀN ĐIỀU HÀNH THƯỢNG NGUỒN (Upstream Authority)**.  
*"No Approved Document, No Physical Movement"* — Mọi chuyển động vật tư, dòng tiền, nhân sự và sản xuất đều phải xuất phát từ Tờ trình duyệt trạng thái `008`.

---

## ⛔ CÁC NGUYÊN TẮC BẤT BIẾN:

1. **RULE 0 - ZERO SELECT WITHOUT PRIOR KB (TRA CỨU TRƯỚC KHI TRUY VẤN):**
   - Luôn tra cứu L1 `GW_FORM_MATRIX.json` qua `.\gw.ps1 find "<Keyword>"` hoặc 16 file KB trước khi chạy bất kỳ câu lệnh SQL SELECT nào.

2. **RULE 1 - SELECT-ONLY ON PRODUCTION DATABASE:**
   - Tuyệt đối CẤM thực thi DML (`UPDATE`, `DELETE`, `INSERT`) hoặc DDL trực tiếp trên `VINATECH_GROUP` và `NEOE_ERP`. Mọi câu truy vấn phải là đọc an toàn kèm `WITH (NOLOCK)`.

3. **RULE 2 - TÔN TRỌNG TÍNH TOÀN VẸN CỦA STATE MACHINE (001 -> 002 -> 008):**
   - Tuyệt đối CẤM update thủ công `DOCUMENT_SAVE_STATE = '008'` trên CSDL để bypass phê duyệt.
   - Thao tác này sẽ bỏ qua 5 side-effects ngầm (Ký số & render PDF `streamdocs`, cấp mã `ED-...`, bắn trigger sang ERP `NEOE`, phát tín hiệu WebSocket, đóng băng dữ liệu), biến bản ghi thành "zombie record" gây đứt gãy ERP & MES.

4. **RULE 3 - BẢO TOÀN ĐỊNH DANH MỎ NEO `DOCUMENT_SAVE_CODE`:**
   - Mã `DOCUMENT_SAVE_CODE` là khóa ngoại duy nhất liên kết giữa `VINA_DOCUMENT_SAVE`, các bảng Detail và `VINA_DOCUMENT_SAVE_RELATION`. Cấm mọi hành vi sửa đổi mã này.

5. **RULE 4 - SURGICAL RETRIEVAL (TRÍCH XUẤT CHÍNH XÁC):**
   - Ưu tiên đọc L1 JSON Matrix (<0.001s, ~150 tokens). Khi cần đọc file KB Markdown, chỉ đọc đúng đoạn 30-50 dòng cần thiết để tiết kiệm ngữ cảnh.

6. **RULE 5 - GOLDEN QUERY TRACE 360° FIRST:**
   - Khi nhận mã chứng từ (`NO_PO`, `DOCUMENT_SAVE_CODE`, `NO_EMP`, `CD_ITEM`), luôn chạy `.\gw.ps1 trace "<Target>"` đầu tiên để quét đồng thời cả Groupware, ERP và MES trong một lần truy vấn.

7. **RULE 6 - BẢO VỆ WORKSPACE & TIÊU CHUẨN CÔNG CỤ:**
   - Không tạo các file script `.ps1` rời rạc ngoài thư mục gốc. Bắt buộc dùng CLI Hub `.\gw.ps1`. File nháp tạm thời phải lưu trong `tools/scratch/`.

8. **RULE 7 - BẢO MẬT CREDENTIAL & TOKEN SSO:**
   - Tuyệt đối không commit Access Token hay Session Key (`VINATECH_RESTFUL.dbo.VINA_SSO_TOKEN`) lên Git.

9. **RULE 8 - ĐỐI SOÁT ĐA NỀN TẢNG (GW ↔ ERP ↔ MES):**
   - Khi giải quyết một sự cố, phải kiểm tra chuỗi 3 mắt xích: Trạng thái duyệt trên GW ➔ Chứng từ trên ERP ➔ Trạng thái hiển thị trên MES.

10. **RULE 9 - TỐC ĐỘ PHẢN HỒI (<5-10s):**
    - Tối đa 1-2 tool calls cho mỗi câu hỏi. Trả lời ngay khi có đủ thông tin, không chạy chuỗi dài lặp lại.

11. **RULE 10 - CẤM TỰ Ý TẠO SCRIPT SỬA CSDL KHI CHƯA ĐƯỢC YÊU CẦU:**
    - Khi người dùng hỏi nguyên nhân hoặc yêu cầu kiểm tra: Chỉ phân tích và báo cáo hiện trạng. Không tự ý tạo script hotfix hay can thiệp CSDL.

12. **RULE 11 - XỬ LÝ YÊU CẦU THIẾU THÔNG TIN (UNDERSPECIFIED INPUT):**
    - Nếu người dùng chỉ gõ "check" hoặc "kiểm tra": Kích hoạt `.\gw.ps1 health` để quét các phiếu tồn đọng và đưa ra các tùy chọn tra cứu nhanh.

13. **RULE 12 - KHÓA PHIÊN BẢN ĐỊNH MỨC BOM 2001/2002:**
    - Bắt buộc kiểm tra phiên bản BOM khi tạo PO sản xuất. Chỉ phiên bản BOM **2001** (cho toàn bộ sản phẩm VN) hoặc **2002** (Cell line mới) mới được MES `B310`/`B450` chấp nhận.

14. **RULE 13 - CHỐT CHẶN KỸ THUẬT IQC (C220 PASS GATEKEEPER):**
    - Nhập kho NVL Groupware (Receiving Confirmation) phụ thuộc hoàn toàn vào kết quả kiểm định IQC `PASS` trên MES `C220`. Không được bỏ qua bước này.
