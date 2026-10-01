# 🛡️ K-SYSTEM ACE ERP (FINAL) — AGENT OPERATIONAL RULES

> **Single Source of Truth:** `..\.agents\rules\00_vinatech_master_rules.md` & `FINAL/AI_AGENT_CONFIG/RULES.md`  
> **Master Command Hub:** `.\ops.ps1` (Toàn hệ thống) & `.\ksys.ps1` (K-System Ace ERP)  
> **Cơ Sở Dữ Liệu:** `VINATECVN` & `VINATECVNCommon` trên `dbserver.hycap.co.kr,5398`  
> **Pháp Nhân:** `비나텍(베트남법인)` — Vinatech Vina (`CompanySeq = 1`)

---

## ⛔ QUY TẮC CỐT LÕI (BẤT BIẾN)

1. **RULE 0 (ZERO SELECT WITHOUT PRIOR KB):**
   - Tuyệt đối cấm chạy `SELECT` tùy tiện trên `VINATECVN` hoặc `VINATECVNCommon` trước khi tra cứu L1 Cache (`.\ksys.ps1 find`) hoặc đọc tài liệu trong `FINAL/ARCHITECTURE/`.

2. **RULE 1 (STRICTLY SELECT-ONLY ON PRODUCTION):**
   - K-System Ace ERP là sổ cái tài chính, kế toán và hoạch định nguồn lực cốt lõi.
   - **TUYỆT ĐỐI CẤM** chạy các lệnh `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE` trực tiếp trên Production CSDL.

3. **RULE 2 (BẮT BUỘC WITH(NOLOCK)):**
   - CSDL `VINATECVN` chứa hơn 5.500 bảng nghiệp vụ. Mọi truy vấn bắt buộc phải có `WITH(NOLOCK)`.

4. **RULE 4 (SURGICAL L1 RETRIEVAL FIRST):**
   - Ưu tiên tra cứu siêu tốc qua tệp L1 Cache JSON: `KSYSTEM_MATRIX.json` & `UNIFIED_INTEGRATION_MATRIX.json`.

5. **RULE 6 (BẢO VỆ PHÂN VÙNG PHÁP NHÂN - COMPANYSEQ):**
   - Đối với Vinatech Việt Nam: Bắt buộc luôn chỉ định điều kiện `CompanySeq = 1`.

6. **RULE 14 (TỐC ĐỘ PHẢN HỒI <5-10s):**
   - Tối đa 1-2 tool calls trúng đích/câu hỏi. Lấy xong data DỪNG NGAY.

7. **RULE 18 (ĐỊNH DANH IT):**
   - Mọi can thiệp hoặc script bắt buộc ghi `Author = 'vanduc'` và `ChangeUserID = 'vanduc'`.

8. **RULE 21 (TOOL CHUYÊN DỤNG - 0 BLIND SQL LOOPING):**
   - Bắt buộc dùng `.\ksys.ps1 [find|trace|module|schema]` hoặc `.\ops.ps1`. Cấm SELECT dò dẫm.

## ⚡ CLI HUBS LIÊN KẾT
- `.\ops.ps1 health` — Morning 360 Patrol quét toàn bộ 5 hệ thống
- `.\ksys.ps1 find "<Keyword>"` — Tra cứu siêu tốc L1 Cache (17 phân hệ, 213 quy trình)
- `.\ksys.ps1 trace "<LotNo/WO>"` — Truy vết 360° Lot / Lệnh SX
- `.\ksys.ps1 module [-Seq <N>]` — Liệt kê danh mục 17 phân hệ
- `.\ksys.ps1 schema [-Prefix <P>]` — Tra cứu bảng theo tiền tố (_TPR, _TMA, _TAC...)
