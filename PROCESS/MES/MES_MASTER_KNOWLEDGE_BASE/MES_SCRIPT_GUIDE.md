# 🛠️ Script & Tool Guide — Hướng Dẫn Sử Dụng Script PowerShell Bổ Trợ

> **Dành cho:** AI Agent (Antigravity) & Kỹ sư EA/IT vận hành dự án MES Vinatech.
> **Vị trí các script:** Nằm trực tiếp tại thư mục gốc của dự án (`c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\PROCESS\MES\`).
> ← [Về INDEX](KB_INDEX.md)

Tài liệu này hướng dẫn chi tiết cách sử dụng, các tham số đầu vào, logic xử lý nội bộ và cơ chế bảo mật an toàn của 4 script PowerShell hỗ trợ đắc lực cho việc tương tác cơ sở dữ liệu và mã nguồn.

---

## 🧭 Bản Đồ Sử Dụng Script (Quick Workflow)

```mermaid
graph TD
    Start[Bắt đầu tác vụ] --> Choice{Loại tác vụ?}
    Choice -->|Query dữ liệu| SQ[run_query.ps1]
    Choice -->|Đọc/Sửa Stored Procedure| Sync[db_sync_tool.ps1]
    Choice -->|Deploy code lên DB| Val[validate_sql.ps1]
    Val -->|Đạt kiểm tra| Dep[deploy_tool.ps1]
    Sync -->|Xong việc| Clean[db_sync_tool.ps1 -Clean]
```

---

## 1. 🔍 run_query.ps1 — Chạy Truy Vấn SQL Nhanh

Script này cho phép chạy các câu lệnh SQL read-only trực tiếp từ Terminal lên SQL Server, hỗ trợ xuất kết quả dưới dạng bảng, định dạng JSON hoặc CSV.

### 📋 Cách sử dụng & Tham số:
```powershell
powershell -File .\run_query.ps1 -Query "Nội_dung_câu_lệnh_SQL" [-Format Table|JSON|CSV]
```
*   `-Query` *(Bắt buộc):* Nội dung câu lệnh SQL cần chạy. Bắt buộc sử dụng `WITH(NOLOCK)` cho các bảng giao dịch lớn.
*   `-Format` *(Tùy chọn):* Định dạng đầu ra của dữ liệu. Mặc định là `Table`.

### 💡 Ví dụ thực tế:
```powershell
# 1. Truy vấn nhanh 5 dòng trong SetInfo dạng bảng
powershell -File .\run_query.ps1 -Query "SELECT TOP 5 Barcode, LotDecisionResult, IsDefect FROM STB_SetInfo WITH(NOLOCK) WHERE IsDefect = 1"

# 2. Xuất dữ liệu cấu hình model dạng JSON để xử lý bằng script
powershell -File .\run_query.ps1 -Query "SELECT ModelCode, MBIExtText04, MBIExtText05 FROM STB_ModelBasicInfo WITH(NOLOCK) WHERE ModelCode = 'RDMD00-368'" -Format JSON
```

---

## 2. 🔄 db_sync_tool.ps1 — Tải & Dọn Dẹp Stored Procedure Tạm

Do mã nguồn các Stored Procedure của MES nằm hoàn toàn trong database và không được tracking bằng Git để tránh phình dung lượng, script này giúp tải định nghĩa SP từ DB về máy dưới dạng file `.sql` để đọc/sửa, và dọn dẹp sạch sẽ khi hoàn tất để giữ Git workspace luôn sạch.

### 📋 Cách sử dụng & Tham số:
```powershell
# Tải SP về máy (Tự động tạo thư mục tạm sql/procedures/ nếu chưa có)
powershell -File .\db_sync_tool.ps1 -SPName "Tên_Stored_Procedure"

# Dọn dẹp sạch sẽ các file SP đã tải tạm thời
powershell -File .\db_sync_tool.ps1 -Clean
```
*   `-SPName`: Tên của Stored Procedure cần tải về (ví dụ: `usp_DoProcessProdRouteHist`). File tải về sẽ nằm trong thư mục tạm `sql/procedures/[Tên_SP].sql`.
*   `-Clean`: Xóa toàn bộ các tệp tin trong thư mục tạm `sql/procedures/` để khôi phục trạng thái Git sạch trước khi commit.

### 💡 Ví dụ thực tế:
```powershell
# Tải SP chốt sản lượng về phân tích
powershell -File .\db_sync_tool.ps1 -SPName "usp_DoProcessProdRouteHistForCalc_SmartApp_VNT"

# Sau khi đã phân tích xong, dọn dẹp sạch thư mục tạm sql/
powershell -File .\db_sync_tool.ps1 -Clean
```

---

## 3. 🛡️ validate_sql.ps1 — Kiểm Tra Quy Tắc An Toàn SQL

Trước khi áp dụng bất kỳ thay đổi nào lên database Production, file `.sql` bắt buộc phải được chạy qua bộ kiểm tra an toàn `validate_sql.ps1`. Bộ kiểm tra này sẽ phân tích cú pháp tĩnh để đảm bảo code tuân thủ các quy tắc vàng của dự án.

### 📋 Cách sử dụng:
```powershell
powershell -File .\validate_sql.ps1 -SqlPath "Đường_dẫn_file_SQL"
```

### 🔒 Các quy tắc kiểm tra (Rules enforced):
1.  **Bắt buộc có Transaction:** File SQL thay đổi dữ liệu phải chứa khối `BEGIN TRAN` ... `ROLLBACK TRAN` (hoặc `COMMIT TRAN`).
2.  **Cấm chạy DROP/ALTER trực tiếp:** Cấm chạy các lệnh làm thay đổi vĩnh viễn cấu trúc bảng hoặc SP mà không có bọc an toàn.
3.  **Quy tắc SELECT-ONLY cho AI:** Chặn đứng các lệnh ghi (INSERT/UPDATE/DELETE) trực tiếp nếu AI agent tự ý gọi mà không qua bọc kiểm soát của người dùng.

### 💡 Ví dụ thực tế:
```powershell
# Kiểm tra file SQL sửa lỗi trong thư mục nháp/scratch trước khi deploy
powershell -File .\validate_sql.ps1 -SqlPath "C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\cab9e98e-f5af-4971-93ca-36def1d031e9\scratch\fix_slitting.sql"
```

---

## 🚀 deploy_tool.ps1 — Triển Khai Hotfix Lên Production

Khi file SQL sửa lỗi đã vượt qua bộ lọc an toàn của `validate_sql.ps1`, kỹ sư IT hoặc AI Agent (dưới sự phê duyệt cụ thể của User) sẽ thực hiện deploy script trực tiếp lên database.

### 📋 Cách sử dụng:
```powershell
powershell -File .\deploy_tool.ps1 -SqlPath "Đường_dẫn_file_SQL"
```
*   `-SqlPath` *(Bắt buộc):* Đường dẫn tới file SQL cần deploy.

### 💡 Ví dụ thực tế:
```powershell
# Triển khai SQL sửa lỗi từ thư mục nháp/scratch trực tiếp lên DB
powershell -File .\deploy_tool.ps1 -SqlPath "C:\Users\User Vinatech.DESKTOP-RJJSEQU\.gemini\antigravity-ide\brain\cab9e98e-f5af-4971-93ca-36def1d031e9\scratch\fix_slitting.sql"
```

---

## ⚠️ Quy Tắc An Toàn
Các script trên tương tác trực tiếp với cơ sở dữ liệu. Vui lòng tham khảo chi tiết các quy tắc an toàn dữ liệu bắt buộc tại [RULES.md](../AI_AGENT_CONFIG/RULES.md).

