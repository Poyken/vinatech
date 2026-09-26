# 🛡️ VINATECH GROUPWARE AGENT RULES (00_groupware_rules.md)

> **Phạm vi áp dụng:** Workspace `PROCESS/GROUPWARE` | **Phiên bản:** 2.0 (Master Governance Edition)  
> **Tài liệu kim chỉ nam (North Star):** `GROUPWARE_KNOWLEDGE_BASE/GW_00_CORE_OPERATING_PRINCIPLES.md`  
> **Nền tảng:** Bizbox Alpha (Douzone Bizon) | **CSDL:** `VINATECH_GROUP`  

---

## 🧭 BẢN CHẤT CỐT LÕI CỦA GROUPWARE TRONG HỆ SINH THÁI VINATECH
Groupware không phải là cổng thông tin văn phòng thông thường, mà là **TRỤC THẨM QUYỀN ĐIỀU HÀNH THƯỢNG NGUỒN (Upstream Operational & Governance Authority)**:
- **Nguyên lý Tối cao:** *"No Approved Document, No Physical Movement"* — Mọi giao dịch tài chính (`FI_DOCU`), lệnh mua hàng (`PU_PO`), tiếp nhận kho NVL (`F330`), lệnh sản xuất (`B310`/`B450`), và xuất xưởng container (`B752`) đều bắt buộc xuất phát từ một Tờ trình Điện tử đạt trạng thái Phê chuẩn Hoàn tất (`DOCUMENT_SAVE_STATE = '008'`).

---

## ⛔ CÁC QUY TẮC BẮT BUỘC (INVARIANT RULES):

### 1. RULE 0 - ZERO SELECT WITHOUT PRIOR KB (TRA CỨU TRƯỚC KHI TRUY VẤN):
- Cấm chạy lệnh SQL `SELECT` tự do trước khi tra cứu L1 `GW_FORM_MATRIX.json` qua `.\gw.ps1 find "<Keyword>"` hoặc 16 file KB.

### 2. RULE 1 - SELECT-ONLY ON PRODUCTION DATABASE (CHỈ ĐỌC AN TOÀN):
- Tuyệt đối CẤM thực thi DML (`UPDATE`, `DELETE`, `INSERT`) hoặc DDL trực tiếp trên `VINATECH_GROUP` và `NEOE_ERP`. Mọi câu truy vấn phải là đọc an toàn kèm hint `WITH (NOLOCK)`.

### 3. RULE 2 - TÔN TRỌNG TÍNH TOÀN VẸN CỦA STATE MACHINE (001 -> 002 -> 008):
- Tuyệt đối CẤM sửa thủ công `DOCUMENT_SAVE_STATE = '008'` trên CSDL để bypass quy trình duyệt.
- **Lý do kỹ thuật cốt lõi:** Khi người duyệt cuối bấm Duyệt trên giao diện, Bizbox Alpha thực thi 5 side-effects ngầm (Ký số & render PDF trên `streamdocs`, cấp mã `ED-...`, bắn trigger/interface sang ERP `NEOE`, phát tín hiệu WebSocket, đóng băng dữ liệu). Update SQL thô bạo sẽ biến văn bản thành "Bản ghi ma" (Orphan Record) gây tê liệt ERP và MES.

### 4. RULE 3 - BẢO TOÀN ĐỊNH DANH MỎ NEO `DOCUMENT_SAVE_CODE`:
- Khóa ngoại `DOCUMENT_SAVE_CODE` là mắt xích sống còn liên kết giữa Header (`VINA_DOCUMENT_SAVE`) và hơn 17 bảng Detail chuyên biệt. Cấm mọi hành vi sửa đổi hoặc tạo mã lệch chuẩn.

### 5. RULE 4 - TRÍCH XUẤT CHÍNH XÁC (SURGICAL RETRIEVAL):
- Ưu tiên đọc L1 JSON Matrix (<0.001s, ~150 tokens). Khi cần đọc file Markdown, chỉ đọc đúng đoạn 30-50 dòng cần thiết để tiết kiệm ngữ cảnh.

### 6. RULE 5 - GOLDEN QUERY TRACE 360° FIRST:
- Khi nhận mã chứng từ (`NO_PO`, `DOCUMENT_SAVE_CODE`, `NO_EMP`, `CD_ITEM`), luôn chạy `.\gw.ps1 trace "<Target>"` đầu tiên để quét đồng thời cả Groupware, ERP và MES trong một lần truy vấn.

### 7. RULE 6 - BẢO VỆ WORKSPACE & TIÊU CHUẨN CÔNG CỤ:
- BẮT BUỘC sử dụng CLI Hub `.\gw.ps1`. Không tạo script `.ps1` rời rạc ở thư mục gốc. Script test phải nằm trong `tools/scratch/`.

### 8. RULE 7 - BẢO MẬT CREDENTIAL & TOKEN SSO:
- Tuyệt đối không để lộ hoặc commit các Session Key, SSO Token (`VINATECH_RESTFUL.dbo.VINA_SSO_TOKEN`) thật lên Git.

### 9. RULE 8 - ĐỐI SOÁT ĐA NỀN TẢNG (GW ↔ ERP ↔ MES):
- Khi điều tra lỗi người dùng phản ánh, phải kiểm tra sự thống nhất giữa 3 tầng: GW (Duyệt) ➔ ERP (Chứng từ) ➔ MES (Hiện trường).

### 10. RULE 9 - TỐC ĐỘ PHẢN HỒI (<5-10s):
- Tối đa 1-2 tool calls cho mỗi câu hỏi. Lấy xong thông tin cốt lõi là dừng và trả lời ngay.

### 11. RULE 10 - CẤM TỰ Ý TẠO SCRIPT SỬA CSDL KHI CHƯA ĐƯỢC YÊU CẦU:
- Khi người dùng hỏi nguyên nhân hoặc yêu cầu kiểm tra: Chỉ phân tích và báo cáo hiện trạng. Không tự ý tạo script hotfix hay can thiệp CSDL.

### 12. RULE 11 - XỬ LÝ YÊU CẦU THIẾU THÔNG TIN (UNDERSPECIFIED INPUT):
- Nếu người dùng chỉ gõ "check" hoặc "kiểm tra": Kích hoạt `.\gw.ps1 health` để quét các phiếu tồn đọng và đưa ra các tùy chọn tra cứu nhanh.

### 13. RULE 12 - KHÓA PHIÊN BẢN ĐỊNH MỨC BOM 2001/2002:
- Khi kiểm tra hoặc tạo PO sản xuất, bắt buộc phiên bản BOM phải là **2001** (Việt Nam) hoặc **2002** (Cell line mới). Bất kỳ BOM version nào khác đều bị MES `B310`/`B450` từ chối nhận lệnh và không cho phát hành Lot.

### 14. RULE 13 - TÔN TRỌNG CHỐT CHẶN KỸ THUẬT IQC (C220 PASS GATEKEEPER):
- Khi người dùng thắc mắc không lập được phiếu Receiving Confirmation trên GW: Bắt buộc kiểm tra kết quả kiểm định IQC trên màn hình MES `C220`. Nếu QC chưa bấm Confirm PASS (`QcResult = 'PASS'`), Groupware có quyền từ chối mở form theo đúng tiêu chuẩn ISO.

### 15. RULE 21 - BẮT BUỘC LUÔN DÙNG TOOL CHUYÊN DỤNG (CLI HUBS) — TUYỆT ĐỐI CẤM QUERY DÒ DẪM (ZERO BLIND SQL EXPLORATION):
- BẮT BUỘC dùng Tool CLI Hubs (`.\gw.ps1 [trace|form|find|routine]`, `.\mes.ps1`, `.\pop.ps1`, `.\ksys.ps1`).
- CẤM TUYỆT ĐỐI dùng `.\db.ps1 query` để mò mẫm cấu trúc bảng hoặc chạy chuỗi SELECT thử sai.
- Muốn biết form, menu, trường dữ liệu ➔ BẮT BUỘC tra cứu L1 Cache (`GW_FORM_MATRIX.json`, `APPROVAL_LINE_MATRIX.json`) hoặc `find`.
- Giới hạn cứng 1-2 tool calls trúng đích, xong là DỪNG NGAY.

