# 🤖 Vinatech MES — Quy Tắc & Vai Trò Vận Hành Của Antigravity

## ⚠️ QUY TẮC BẮT BUỘC — ĐỌC TRƯỚC KHI XỬ LÝ BẤT KỲ YÊU CẦU NÀO

Khi làm việc với User Vinatech (DESKTOP-RJJSEQU), **trước khi trả lời bất kỳ yêu cầu nào liên quan đến hệ thống MES/NAIS**, tôi **BẮT BUỘC phải tuân thủ**:

---

---

## ⚡ Nguyên Tắc Vàng (Hoạt Động)

1. **Không sửa DB production khi chưa SELECT xem dữ liệu trước**: Luôn kiểm chứng trạng thái hiện tại.
2. **Luôn backup bằng SELECT trước UPDATE/DELETE**: Đảm bảo có thể khôi phục dữ liệu nếu có sai sót.
3. **Triggers & SP**: Tồn kho có thể cập nhật qua trigger **hoặc** chuỗi SP. Khi debug tồn kho, kiểm tra cả hai hướng.
4. **3 Bảng Kho**: Khi sửa kho, thường phải update đồng thời `STB_MaterialDocInfo` + `STB_MaterialDocDetail` + `STB_MaterialLotInfo`.
5. **Knowledge First**: Luôn tra cứu `KB_INDEX.md` và `MES_UNIFIED_DEBUG_MAP.md` trước khi tự suy luận.
6. **Fetch Before Edit**: Luôn lấy bản mới nhất từ database về (`fetch_sp.ps1`) trước khi sửa SP.
7. **NO DIRECT UID**: Antigravity **TUYỆT ĐỐI KHÔNG** được tự ý chạy `UPDATE/INSERT/DELETE` trực tiếp trên Production. Chỉ viết script đề xuất.
8. **Quy Trình 5 Bước**: Tuân thủ quy trình điều tra tại `BUG_INVESTIGATION_FLOW.md`.
9. **HỎI TRƯỚC KHI LÀM**: Nếu thiếu thông tin (mã Lot, Screen ID) -> Dừng lại và hỏi User ngay.

---

## 📚 3 File Context Bắt Buộc Phải Kiểm Tra

### 1. 🗂️ KB_INDEX.md (Knowledge Base)
**Path:** `c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\MES_MASTER_KNOWLEDGE_BASE\KB_INDEX.md`
**Mục đích:**
- Điểm neo (Index) để tra cứu các lỗi đã biết được chia nhỏ thành các file KB_01 đến KB_06.
- Có chứa script fix chuẩn cho từng loại lỗi.
**Khi nào đọc:** Khi có bất kỳ yêu cầu sửa lỗi, fix data, hoặc xử lý sự cố.

### 2. 📊 Vinatech_MES_Complete_DataFlow.md
**Path:** `c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\MES_MASTER_KNOWLEDGE_BASE\Vinatech_MES_Complete_DataFlow.md`
**Mục đích:**
- Hiểu kiến trúc hệ thống (Metadata, SP, Triggers).
- Nắm rõ luồng dữ liệu (Data flow Phase 0→5) và dependency giữa các bảng.
**Khi nào đọc:** Khi cần debug Stored Procedures, viết truy vấn phức tạp hoặc thiết kế tính năng.

### 4. 🗺️ MES_UNIFIED_DEBUG_MAP.md
**Path:** `c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\MES_UNIFIED_DEBUG_MAP.md`
**Mục đích:**
- Tra cứu nhanh Screen ID -> SP -> Tables.
- Tổng hợp các "điểm nóng" của hệ thống (F330, B523, B781...).
**Khi nào đọc:** Khi bắt đầu điều tra một Bug cụ thể trên màn hình MES.

### 5. 🛠️ BUG_INVESTIGATION_FLOW.md
**Path:** `c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\database\BUG_INVESTIGATION_FLOW.md`
**Mục đích:**
- Quy trình 5 bước để điều tra bug an toàn và hiệu quả.
**Khi nào đọc:** Áp dụng cho mọi case sửa lỗi data/logic.

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
*Cập nhật lần cuối: 2026-05-12*
