# 🛡️ 10 Quy Tắc Vàng Bất Biến (Core Operational Rules)

> [!CAUTION]
> **1. SELECT-ONLY TRÊN PRODUCTION:** Tuyệt đối không INSERT/UPDATE/DELETE/ALTER/DROP trực tiếp trên CSDL Production ngoài việc dùng `deploy` đã validate.
> **2. TRANSACTION SAFETY:** Mọi script DML sửa đổi phải được bọc trong `BEGIN TRANSACTION ... ROLLBACK` để kiểm thử trước khi commit.
> **3. KNOWLEDGE-FIRST HARD STOP:** Cấm chạy query khi chưa tra cứu `bug_playbook.md` hoặc KB liên quan. Trình bày căn cứ tài liệu trước khi SELECT verify.
> **4. TOKEN OPTIMIZATION:** Không đọc toàn bộ file lớn nếu không cần thiết; phản hồi ngắn gọn theo chuẩn 3 khối.
> **5. HỎI TRƯỚC KHI LÀM:** Nếu thông tin chưa rõ ràng hoặc thao tác rủi ro cao $\rightarrow$ Dừng lại hỏi User ngay lập tức.
> **6. GOLDEN QUERY FIRST:** Khi nhận mã Barcode/LotNo bất kỳ, bắt buộc dùng Golden Query 360° quét toàn bộ SetInfo, LotInfo, RouteHist trong 1 lần duy nhất.
> **7. IMMEDIATE SCREEN MAPPING:** Khi nhận Screen ID (B523, B530, C530...), tra ngay cặp SP `_get` / `_iud` và bảng DB từ `KB_MASTER_INDEX.md`.
> **8. CẤM CHÈN BẢN GHI DUMMY/SUY ĐOÁN:** Mọi thao tác sửa chữa dữ liệu phải tuân thủ chuẩn kiến trúc nghiệp vụ SoT.
> **9. 4-TABLE SYNC INTEGRITY:** Sửa bất kỳ Lot nào phải đồng bộ đủ 4 bảng (`STB_SetInfo`, `STB_MaterialLotInfo`, `STB_ProdRouteHist`, `STB_LotChangeMaterialHistory`).
> **10. SỬ DỤNG CÔNG CỤ CÓ SẴN:** Luôn sử dụng bộ công cụ `.\cli\mes.ps1`, cấm tạo file script rác tạm bợ trong workspace.
