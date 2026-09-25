# 🛡️ K-SYSTEM ACE ERP (FINAL) — AGENT OPERATIONAL RULES

> **Single Source of Truth:** `FINAL/AI_AGENT_CONFIG/RULES.md`  
> **Primary Command Hub:** `.\ksys.ps1` (hoặc `c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\ksys.ps1`)  
> **Cơ Sở Dữ Liệu:** `VINATECVN` & `VINATECVNCommon` trên `dbserver.hycap.co.kr,5398`  
> **Pháp Nhân:** `비나텍(베트남법인)` — Vinatech Vina (`CompanySeq = 1`)

---

## ⛔ QUY TẮC CỐT LÕI (BẤT BIẾN)

1. **RULE 0 (ZERO SELECT WITHOUT PRIOR KB):**
   - Tuyệt đối cấm chạy `SELECT` tùy tiện trên `VINATECVN` hoặc `VINATECVNCommon` trước khi tra cứu L1 Cache (`.\ksys.ps1 find`) hoặc đọc tài liệu trong `FINAL/ARCHITECTURE/`.

2. **RULE 1 (STRICTLY SELECT-ONLY ON PRODUCTION):**
   - K-System Ace ERP là sổ cái tài chính, kế toán và hoạch định nguồn lực cốt lõi của toàn công ty.
   - **TUYỆT ĐỐI CẤM** chạy các lệnh `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE` trực tiếp trên Production CSDL.
   - Khi khảo sát giao diện Web (`https://evn.vinatech.com`), tuyệt đối không ấn Submit, Save, Delete hay thay đổi dữ liệu.

3. **RULE 2 (BẮT BUỘC WITH(NOLOCK)):**
   - CSDL `VINATECVN` chứa hơn 5.500 bảng nghiệp vụ liên kết chặt chẽ. Mọi truy vấn bắt buộc phải có gợi ý khóa `WITH(NOLOCK)` trên tất cả các bảng để chống Deadlock và nghẽn hệ thống.

4. **RULE 4 (SURGICAL L1 RETRIEVAL FIRST):**
   - Ưu tiên tra cứu siêu tốc qua tệp L1 Cache JSON:
     * `FINAL/AI_AGENT_CONFIG/KSYSTEM_MATRIX.json` (17 phân hệ, 213 quy trình).
     * `FINAL/AI_AGENT_CONFIG/UNIFIED_INTEGRATION_MATRIX.json` (Ánh xạ liên thông 5 hệ thống).

5. **RULE 6 (BẢO VỆ PHÂN VÙNG PHÁP NHÂN - COMPANYSEQ):**
   - K-System Ace hỗ trợ mô hình Multi-Company. Mọi bảng dữ liệu nghiệp vụ đều có cột `CompanySeq`.
   - Đối với Vinatech Việt Nam: Bắt buộc luôn chỉ định điều kiện `CompanySeq = 1`.

6. **RULE 7 (NGUYÊN TẮC HỢP NHẤT ĐÍCH ĐẾN - UNIFIED HUB):**
   - K-System Ace là nền tảng đích (Final Target) mà các hệ thống cũ (MES, POP, Groupware, Douzone) sẽ hội tụ vào.
   - Luôn đối chiếu theo 3 trục: Thượng nguồn (Groupware) ➔ Hạ nguồn sản xuất (MES/POP) ➔ Hạch toán hội tụ (K-System ERP).
