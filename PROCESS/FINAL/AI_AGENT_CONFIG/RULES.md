# 🛡️ K-SYSTEM ACE ERP AGENT RULES — FINAL UNIFIED SYSTEM

> **Hệ thống:** YoungLimWon K-System Ace Web ERP Suite (`https://evn.vinatech.com/`)
> **Pháp nhân:** `비나텍(베트남법인)` — Công ty TNHH Vinatech Vina (CompanySeq = 1)
> **Cơ sở dữ liệu:** `VINATECVN` (Nghiệp vụ) & `VINATECVNCommon` (Vận hành / Metadata)
> **Single Source of Truth:** `FINAL/AI_AGENT_CONFIG/RULES.md`
> **Primary Command Hub:** `.\ksys.ps1` (Hoặc từ Process Root: `.\ksys.ps1`)

---

## ⛔ QUY TẮC CỐT LÕI (BẤT BIẾN)

1. **RULE 0 (ZERO SELECT WITHOUT PRIOR KB):**
   - Tuyệt đối cấm chạy `SELECT` tùy tiện trên `VINATECVN` hoặc `VINATECVNCommon` trước khi tra cứu L1 Cache (`.\ksys.ps1 find`) hoặc đọc tài liệu trong `FINAL/ARCHITECTURE/`.
   - Mọi câu truy vấn dữ liệu phải có mục tiêu xác thực rõ ràng đã định danh trong KB.

2. **RULE 1 (STRICTLY SELECT-ONLY ON PRODUCTION):**
   - Hệ thống K-System Ace ERP là sổ cái tài chính, kế toán và hoạch định nguồn lực cốt lõi của toàn công ty.
   - **TUYỆT ĐỐI CẤM** chạy các lệnh `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE` trực tiếp trên Production CSDL.
   - Khi điều hướng khảo sát trên giao diện Web (`https://evn.vinatech.com`), tuyệt đối không ấn Submit, Save, Delete hay thay đổi bất kỳ trường nhập liệu nào.

3. **RULE 2 (BẮT BUỘC WITH(NOLOCK)):**
   - CSDL `VINATECVN` chứa hơn 5.500 bảng nghiệp vụ liên kết chặt chẽ. Mọi truy vấn bắt buộc phải có gợi ý khóa `WITH(NOLOCK)` trên tất cả các bảng để chống Deadlock và nghẽn hệ thống.

4. **RULE 3 (TOP CLAUSE & PAGINATION LIMIT):**
   - Khi truy vấn bảng giao dịch lớn (như `_TACSlip`, `_TPRProdResult`, `_TMAItemStockLot`), bắt buộc dùng `TOP 50` hoặc lọc chính xác theo `CompanySeq = 1` và khoảng ngày cụ thể.

5. **RULE 4 (SURGICAL L1 RETRIEVAL FIRST):**
   - Ưu tiên tra cứu siêu tốc qua tệp L1 Cache JSON:
     * `FINAL/AI_AGENT_CONFIG/KSYSTEM_MATRIX.json` (17 phân hệ, 213 quy trình).
     * `FINAL/AI_AGENT_CONFIG/UNIFIED_INTEGRATION_MATRIX.json` (Ánh xạ liên thông 5 hệ thống).
   - Tốc độ phản hồi L1 Cache <0.001s, tiêu thụ ~100-200 tokens.

6. **RULE 5 (GOLDEN QUERY 360° LOT TRACEABILITY):**
   - Khi truy vết một mã LOT, Lệnh sản xuất, hoặc mã thành phẩm trên K-System, sử dụng công cụ Golden Trace:
     `.\ksys.ps1 trace "<LotNo_hoặc_WorkOrder>"`
   - Bản đối chiếu logic thượng nguồn của màn hình **`FrmWPDLotList` (`PgmSeq: 522308`)**.

7. **RULE 6 (BẢO VỆ PHÂN VÙNG DỮ LIỆU PHÁP NHÂN - COMPANYSEQ):**
   - K-System Ace hỗ trợ mô hình Multi-Company. Mọi bảng dữ liệu nghiệp vụ đều có cột `CompanySeq`.
   - Đối với Vinatech Việt Nam: Bắt buộc luôn chỉ định điều kiện `CompanySeq = 1`.
   - Tránh nhầm lẫn dữ liệu với cơ sở dữ liệu Vinatech Hàn Quốc (`VINATECH` DB).

8. **RULE 7 (NGUYÊN TẮC LIÊN THÔNG ĐÍCH ĐẾN - UNIFIED HUB):**
   - K-System Ace là nền tảng đích (Final Target) mà các hệ thống cũ (MES, POP, Groupware, Douzone) sẽ hội tụ vào.
   - Khi phân tích lỗi hoặc lệch số liệu, luôn đối chiếu theo 3 trục: Thượng nguồn (Groupware) ➔ Hạ nguồn sản xuất (MES/POP) ➔ Hạch toán hội tụ (K-System ERP).
