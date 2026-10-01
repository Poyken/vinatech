# 📘 SỔ TAY VẬN HÀNH AI COPILOT DOANH NGHIỆP VINATECH (OPERATOR COPILOT GUIDE)

> **Người vận hành:** Kỹ sư IT Nguyễn Văn Đức (EA Team) | **Định danh hệ thống:** `Author = 'vanduc'`, `ChangeUserID = 'vanduc'`  
> **Tổng hành dinh:** `c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS`  
> **Phiên bản:** Enterprise Orchestration v4.0

---

## 🌟 1. TỔNG QUAN HỆ SINH THÁI ĐIỀU HÀNH 5 TRỤ CỘT

Toàn bộ hệ thống quản trị sản xuất và công nghệ thông tin Vinatech được điều phối hợp nhất qua **Enterprise Master Hub (`ops.ps1`)** kết nối với 5 phân hệ chuyên sâu:

```
                                  ┌─────────────────────────────┐
                                  │       ops.ps1 (v4.0)        │
                                  │   Enterprise Orchestrator   │
                                  └──────────────┬──────────────┘
                                                 │
         ┌──────────────────┬────────────────────┼───────────────────┬──────────────────┐
         ▼                  ▼                    ▼                   ▼                  ▼
  ┌─────────────┐    ┌─────────────┐      ┌─────────────┐     ┌─────────────┐    ┌─────────────┐
  │   mes.ps1   │    │   pop.ps1   │      │   gw.ps1    │     │   ksys.ps1  │    │   db.ps1    │
  │  Core MES   │    │  POP Kiosk  │      │  Groupware  │     │ K-System Ace│    │ 15 Multi-DB │
  │  Sản Xuất   │    │ Hiện Trường │      │   Bizbox    │     │   Web ERP   │    │  Engine     │
  └─────────────┘    └─────────────┘      └─────────────┘     └─────────────┘    └─────────────┘
```

---

## ⚡ 2. HỆ THỐNG LỆNH TOÀN CỤC (GLOBAL CLI SHORTCUTS)

Hệ thống đã cấu hình sẵn trong PowerShell Profile (`$PROFILE`). Bạn có thể mở PowerShell ở **bất kỳ thư mục nào** và gõ trực tiếp tên lệnh mà **không cần gõ `.\`**:

| Lệnh | Chức năng chính | Thời gian thực thi |
| :--- | :--- | :--- |
| `ops health` | **Morning Patrol 360°:** Quét đồng thời 15 DB, kết nối Kiosk, MES, GW, K-System, phát hiện khóa và zombie process. | ~2.0 giây |
| `ops trace <Mã>` | **Universal Auto-Router:** Tự nhận diện 10 loại mã (Lot, PO, Machine, Screen, SP, Table, K-System) và điều phối trúng đích. | <0.5 giây |
| `ops clean` | **Workspace Purge:** Dọn sạch tệp tạm `scratch/`, logs và phát hiện/tiêu diệt zombie process ngầm chống nóng máy. | <1.0 giây |
| `ops rollback -Target <Lot> -Deploy` | **1-Click Undo:** Khôi phục tức thời trạng thái CSDL từ Snapshot an toàn có Transaction. | <1.5 giây |
| `ops weekly-report` | **IT Weekly Report:** Tự động tổng hợp báo cáo sự cố tuần, chuẩn Rule 22 (tách bạch rõ POP vs MES). | <1.0 giây |
| `ops audit-kb` | **Anti-Drift Live Audit:** Đối soát 35.800+ SPs và 7.100+ Tables giữa KB L1 và Live CSDL. | <3.0 giây |

---

## 🧭 3. CÁC SLASH COMMANDS QUAN TRỌNG TRONG ANTIGRAVITY IDE

Khi trò chuyện với AI Copilot trong IDE, bạn có thể sử dụng các lệnh tắt (`/`) để điều khiển hành vi của Agent:

### 🔹 `/plan` — Lập Kế Hoạch Chặt Chẽ Trước Khi Làm
- **Khi nào dùng:** Khi đối mặt với tác vụ phức tạp, di chuyển dữ liệu lớn, can thiệp nhiều bảng CSDL, hoặc onboard tính năng mới.
- **Cách hoạt động:** Agent sẽ dừng lại, không chỉnh sửa code ngay mà sinh ra một bản kế hoạch chi tiết (`.md` plan) với các bước rõ ràng và yêu cầu bạn bấm `Proceed` duyệt trước khi làm.

### 🔹 `/learn` — Dạy Bài Học Mới Cho AI (Persist Knowledge)
- **Khi nào dùng:** Khi bạn vừa sửa một lỗi dị biệt, chỉ cho AI một mẹo thực tế trên chuyền sản xuất, hoặc nhắc nhở AI một nguyên tắc mới.
- **Cách hoạt động:** Agent sẽ tự động tổng hợp bài học và ghi nhận vĩnh viễn vào tệp `PROCESS/.agents/rules/02_learned_patterns.md` và cập nhật L1 Cache JSON, giúp AI không bao giờ lặp lại sai lầm.

### 🔹 `/grill-me` — Phỏng Vấn Làm Sáng Tỏ Thiết Kế (Interactive Interview)
- **Khi nào dùng:** Khi bạn có một ý tưởng nghiệp vụ nhưng chưa chốt hết mọi ngóc ngách kỹ thuật.
- **Cách hoạt động:** Agent sẽ hỏi bạn từng câu hỏi trắc nghiệm/tự luận sâu sắc để làm rõ ràng từng quyết định thiết kế trước khi bắt tay thực hiện.

### 🔹 `/goal` — Chế Độ Tác Chiến Bền Bỉ (Autonomous Deep Run)
- **Khi nào dùng:** Khi bạn giao việc lớn cần chạy xuyên đêm hoặc kiểm toán sâu toàn bộ hệ thống mà không muốn AI dừng lại nửa chừng.

### 🔹 `/schedule` — Hẹn Giờ & Lặp Lại Định Kỳ
- **Khi nào dùng:** Thiết lập lịch nhắc nhở kiểm tra tiến độ hoặc cron job giám sát tự động.

---

## 🛡️ 4. HỆ THỐNG BẢO MẬT & CHỐNG RỦI RO (LIFECYCLE HOOKS)

Hệ thống được trang bị 2 cổng kiểm soát vòng đời tự động (`hooks.json`):

1. **Safety Gateway (`PreToolUse`):**
   - Tự động bắt và chặn đứng mọi câu lệnh nguy hiểm: `DROP TABLE`, `DROP DATABASE`, `TRUNCATE TABLE`, hoặc `DELETE FROM` không có mệnh đề `WHERE`.
   - Cảnh báo bắt buộc xác nhận đối với các câu `UPDATE` diện rộng thiếu điều kiện.
2. **Governance Reminder (`PreInvocation`):**
   - Trước mỗi lượt suy nghĩ của AI, cổng ngầm tự động bơm chỉ dẫn bắt buộc: Nhớ Author/ChangeUserID='vanduc', luôn dùng CLI Hub, tối đa 1-2 tool calls, và phân loại đúng sự cố POP vs MES.

---

## 📋 5. QUY TẮC PHÂN LOẠI SỰ CỐ BẮT BUỘC (RULE 22)

Tuyệt đối ghi nhớ nguyên tắc phân định:
- **POP:** Toàn bộ sự cố liên quan đến Kiosk xưởng, màn hình Web POP, công nhân nạp NVL tại Kiosk, kẹt máy Kiosk, đồng bộ bảng `MongoToMesPerformance` ➔ **BẮT BUỘC GHI PHÂN LOẠI LÀ POP**, không được ghi là MES.
- **MES:** Chỉ dành riêng cho Core MES Sản Xuất WinForm (các màn hình B-series như B530, B540, B552, B781, B782) và CSDL lõi `SmartFactoryV2`.

---

## 🛠️ 6. BẢNG TRA CỨU NHANH CÁC LỆNH SUB-HUBS

### 🏭 Core MES (`mes`):
- `mes trace "<LotID>"`: Vòng đời Lot, Line, Thiết bị, Thùng 360°.
- `mes diagnose "<Lỗi/Màn_Hình>"`: Xuất ngay 4 Dòng Vàng (Root Cause, Hiện trạng, Workaround, Hotfix).
- `mes nvl "<Lot/PO>"`: Soi tồn kho xưởng `ROUTE_VN_WH` vs `MAIN_VN_WH`.
- `mes screen "<ScreenID>"`: Debug cấu trúc Grid, SP, Bảng của màn hình WinForm.
- `mes locks`: Soi real-time các khóa blocking trên CSDL.
- `mes deploy <file.sql>`: Triển khai Hotfix qua Transaction có Pre-flight Snapshot.
- `mes swap-machine -Lots "<Lot>" -Machine "<Machine>"`: Sửa đổi máy nhầm Kiosk chuẩn Rule 20.1 (Atomic 2 bảng).
- `mes fix-solution -Lots "<Lot>"`: Cấp cứu khôi phục thùng dung dịch điện giải 150kg.
- `mes fix-movedate -Lots "<Lot>" -TargetDate "yyyy-MM-dd"`: Chuyển ngày chốt B782 chuẩn 10h00 AM ca làm việc.
- `mes fix-electrode -Lots "<Lot>" [-Type Slitting|Mixing]`: Xóa mẻ trộn / cuộn slitting B552 kẹt.
- `mes fix-pop-clone -Lots "<Lot>"`: Xóa dòng tự sinh thừa mở chốt Kiosk POP.
- `mes fix-cancel-pack -Target "<Lot>" -BoxId "<BoxId>"`: Hủy lẻ từng Box đóng gói.
- `mes fix-defect-null -Lots "<Lot>"`: Chuẩn hóa RepairQty = 0 sửa mất cột NG trên B782.
- `mes validate-excel <File.xlsx> -Route F330`: Kiểm toán pre-flight chống lệch cột Excel import.
- `mes b598-price`: Soi nhanh đơn giá USD & tỷ lệ cân hardcode trong SP.

### 📱 POP Kiosk (`pop`):
- `pop trace "<Keyword>"`: Truy vết nhanh Kiosk hiện trường.
- `pop unlock "<Machine>" -Deploy`: Mở khóa giải phóng máy kẹt `ACTIVE`.
- `pop release-machines -Force`: Giải phóng toàn bộ máy kẹt theo Line.
- `pop sync`: Quét các Lot kẹt pipeline đồng bộ `IsDone=1, IsTransferred=0`.

### 📑 Groupware & ERP (`gw`):
- `gw trace "<PO/DocCode>"`: Truy vết tờ trình duyệt, lệnh mua hàng và ERP NEOE.
- `gw form "<FormName>"`: Tra cứu mã biểu mẫu, bảng detail và quy trình duyệt.

### 🏢 K-System Ace ERP (`ksys`):
- `ksys find "<Keyword>"`: Tra cứu 17 phân hệ và 213 quy trình K-System Ace.
- `ksys trace "<Lot/PO>"`: Truy vết ngược về màn hình quản lý Lot `FrmWPDLotList`.
- `ksys schema -Table "<TableName>"`: Tra cứu cấu trúc bảng và trường dữ liệu.

### 🗄️ Multi-DB Engine (`db`):
- `db find "<Keyword>"`: Tra cứu vị trí bảng trên 15 CSDL.
- `db schema -Profile <Profile> -Table <TableName>`: Xuất data dictionary của bảng.
- `db locks`: Giám sát deadlock và session lock.

---

## ⚡ 7. KHUÔN MẪU PHẢN HỒI LỖI CHUẨN MỰC ("4 DÒNG VÀNG")

Khi nhận được báo lỗi từ hiện trường, AI Copilot luôn phản hồi cô đọng theo 4 phần dứt khoát:
1. 🎯 **Nguyên nhân gốc rễ (Root Cause):** Tên màn hình, Stored Procedure, cơ chế gây lỗi.
2. 📍 **Hiện trạng thực tế:** Lot đang ở đâu, kẹt cái gì, bảng nào.
3. 🛠️ **Cách OP tự xử lý trên giao diện (Workaround):** Các bước 1-2-3 cho công nhân/tổ trưởng tại xưởng.
4. ⚡ **SQL Hotfix chuẩn (Nếu IT phải can thiệp):** Đã bọc `BEGIN TRAN...ROLLBACK`, có NOLOCK, ChangeUserID='vanduc'.

---

## 🚀 8. QUY TRÌNH TRIỂN KHAI VẬN HÀNH CHUẨN (STANDARD DEPLOYMENT RUNBOOK)

> **Chi tiết toàn diện:** Tham khảo tài liệu gốc [.agents/rules/DEPLOYMENT_SOP.md](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/PROCESS/.agents/rules/DEPLOYMENT_SOP.md)

### 🔹 Vòng đời 5 bước khi triển khai bất kỳ thay đổi CSDL nào:
1. **Khảo sát Hiện trạng:** `ops trace "<LotID>"` (Golden Query 360°).
2. **Sinh mã Hotfix an toàn:** Dùng các lệnh `mes fix-...` hoặc soạn file SQL theo chuẩn 4 pha bọc Transaction.
3. **Tiền kiểm định (Linting):** Chạy `validate_sql.ps1` phát hiện từ khóa nguy hiểm.
4. **Bấm lệnh Triển khai:**
   ```powershell
   ops deploy <đường_dẫn_file.sql> [-Profile <DbProfile>]
   ```
   *Hệ thống tự động chụp Pre-flight JSON Snapshot và sinh mã hoàn tác `undo_<Target>.sql` vào `backups/undo/` trước khi chạm vào dữ liệu.*
5. **Nghiệm thu & Học hỏi:** Trace lại dữ liệu xác nhận thành công, yêu cầu xưởng F5 màn hình, và kích hoạt `/learn` nếu phát hiện tiền lệ mới.

### 🔹 Kích hoạt Hoàn tác Khẩn cấp (1-Click Emergency Rollback):
Khi OP báo nhầm hoặc dữ liệu sai lệch sau khi sửa:
```powershell
# Xem trước nội dung hoàn tác:
ops rollback -Target <LotID_hoặc_MãSựCố>

# Thực thi khôi phục nguyên trạng trong < 1.5 giây:
ops rollback -Target <LotID_hoặc_MãSựCố> -Deploy
```

---

## 🔒 9. MA TRẬN PHÂN ĐỊNH TRÁCH NHIỆM TRIỂN KHAI (RACI MATRIX)

| Hoạt Động Triển Khai | AI Copilot (Antigravity) | IT Operator (Kỹ Sư Đức) | Quản Đốc / Tổ Trưởng Xưởng |
| :--- | :---: | :---: | :---: |
| **Tiếp nhận & Chẩn đoán lỗi** | Thực hiện (Trace 360°, Root Cause) | Giám sát & Phê duyệt | Báo mã Lot, màn hình lỗi |
| **Soạn mã Hotfix / Script** | Thực hiện (Theo chuẩn 4 pha, Author 'vanduc') | Kiểm tra cú pháp & Logic | Không can thiệp |
| **Tiền kiểm định & Snapshot** | Tự động hóa (`validate_sql`, `Snapshot`) | Xác nhận kết quả Lint | Không can thiệp |
| **Bấm lệnh Triển khai (Deploy)** | Đề xuất câu lệnh CLI hoàn chỉnh | **Quyết định & Thực thi** (`ops deploy`) | Không can thiệp |
| **Nghiệm thu sau triển khai** | Tự động trace xác nhận dữ liệu DB | Xác nhận hoàn thành | Thao tác thử trên WinForm / Kiosk |
| **Kích hoạt Hoàn tác (Rollback)** | Tự động trích xuất file Undo | **Quyết định & Thực thi** (`ops rollback -Deploy`) | Báo dừng chuyền nếu có lỗi |
| **Lưu trữ tri thức (`/learn`)** | Đề xuất bài học & Ghi nhận vào L1 Cache | Duyệt nội dung bài học | Không can thiệp |