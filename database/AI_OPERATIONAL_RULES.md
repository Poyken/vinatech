# 🤖 Vinatech MES — Quy Tắc & Vai Trò Vận Hành Của Antigravity

## ⚠️ QUY TẮC BẮT BUỘC — ĐỌC TRƯỚC KHI XỬ LÝ BẤT KỲ YÊU CẦU NÀO

Khi làm việc với User Vinatech (DESKTOP-RJJSEQU), **trước khi trả lời bất kỳ yêu cầu nào liên quan đến hệ thống MES/NAIS**, tôi **BẮT BUỘC phải tuân thủ**:

---

## ⚡ Nguyên Tắc Vàng (Hoạt Động)

1. **Không sửa DB production khi chưa SELECT xem dữ liệu trước**: Luôn kiểm chứng trạng thái hiện tại.
2. **Luôn backup bằng SELECT trước UPDATE/DELETE**: Đảm bảo có thể khôi phục dữ liệu nếu có sai sót.
3. **Nhớ Triggers**: Tồn kho tự cập nhật qua triggers — đừng quên logic ngầm này khi debug.
4. **3 Bảng Kho**: Khi sửa kho, thường phải update đồng thời `STB_MaterialDocInfo` + `STB_MaterialDocDetail` + `STB_MaterialLotInfo`.
5. **Knowledge First**: Luôn tra cứu `KB_INDEX.md` trong thư mục `MES_MASTER_KNOWLEDGE_BASE` trước khi tự suy luận hoặc viết SQL mới.
6. **Fetch Before Edit**: Mỗi lần thao tác với bất kỳ Stored Procedure nào, **BẮT BUỘC** phải lấy bản mới nhất từ database về (`fetch_sp.ps1`) rồi mới tiến hành chỉnh sửa. Tuyệt đối không tự ý sửa trên file local cũ.
7. **NO DIRECT UID (Tối Quan Trọng)**: Antigravity **TUYỆT ĐỐI KHÔNG** được tự ý chạy các câu lệnh thay đổi dữ liệu (Update, Insert, Delete - UID) trực tiếp trên Production. Chỉ được phép tìm phương án, viết script (Fix script) và đề xuất. Việc thực thi bắt kỳ script thay đổi dữ liệu nào **PHẢI** do User quyết định và tự chạy tay qua SSMS.
8. **HỎI TRƯỚC KHI LÀM**: Luôn hỏi đầy đủ thông tin, yêu cầu rõ ràng từ User trước khi thực hiện. Phải tuân thủ **ĐÚNG THEO TÀI LIỆU** và quy trình đã đề ra, không tự ý phỏng đoán hoặc nhảy cóc các bước.

---

## 📚 3 File Context Bắt Buộc Phải Kiểm Tra

### 1. 🗂️ KB_INDEX.md (Knowledge Base)
**Path:** `c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\MES_MASTER_KNOWLEDGE_BASE\KB_INDEX.md`
**Mục đích:**
- Điểm neo (Index) để tra cứu các lỗi đã biết được chia nhỏ thành các file KB_01 đến KB_06.
- Có chứa script fix chuẩn cho từng loại lỗi.
**Khi nào đọc:** Khi có bất kỳ yêu cầu sửa lỗi, fix data, hoặc xử lý sự cố.

### 2. 📊 Vinatech_MES_Complete_DataFlow.md
**Path:** `c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\Vinatech_MES_Complete_DataFlow.md`
**Mục đích:**
- Hiểu kiến trúc hệ thống (Metadata, SP, Triggers).
- Nắm rõ luồng dữ liệu (Data flow Phase 0→5) và dependency giữa các bảng.
**Khi nào đọc:** Khi cần debug Stored Procedures, viết truy vấn phức tạp hoặc thiết kế tính năng.

### 3. 📋 ZALO_MES_MASTER_TASKS.md
**Path:** `c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\ZALO_MES_MASTER_TASKS.md`
**Mục đích:**
- Xem danh sách các task đang pending hoặc đã xử lý.
- Cập nhật trạng thái sau khi hoàn thành.
**Khi nào đọc:** Khi nhận task mới.

---

## 🔄 Quy Trình Xử Lý Chuẩn

Với **MỌI** yêu cầu, thực hiện theo thứ tự sau:

1. **TIẾP NHẬN & HỎI:** Đọc yêu cầu. Nếu thiếu thông tin (mã Lot, yêu cầu không rõ, thiếu context) → **Dừng lại và hỏi User ngay.**
2. **TRA CỨU:** Đọc `KB_INDEX.md` xem lỗi đã có cách giải quyết chưa. Đọc DataFlow nếu cần hiểu luồng dữ liệu.
3. **FETCH:** Kéo SP mới nhất từ DB về bằng PowerShell script nếu thao tác với Code.
4. **PHÂN TÍCH:** Viết SQL SELECT để kiểm tra dữ liệu thực tế (chạy tự động được vì chỉ là truy vấn Read-Only).
5. **ĐỀ XUẤT:** Viết script SQL (UPDATE/DELETE/INSERT) kèm giải thích.
6. **CHỜ DUYỆT:** Bàn giao script cho User tự thực thi.
7. **CẬP NHẬT:** Ghi chép lại lỗi/giải pháp mới vào Knowledge Base tương ứng, và tick done trong file Task.

---

## 🏢 Thông Tin Hệ Thống Vinatech MES

| Thuộc tính | Giá trị |
|-----------|---------|
| **Server DB** | `dbserver.hycap.co.kr,5398` |
| **Database chính** | `SmartFactoryV2` |
| **Database framework** | `SmartFramework` |
| **Tài khoản dev** | `vinaadmin` |
| **Hệ thống** | NAIS (SmartFramework by Awoo) |
| **Các nhà máy** | VVT (Bình Dương), BG (Bắc Giang), HN (Hà Nam) |

---
*Cập nhật lần cuối: 2026-05-06*
