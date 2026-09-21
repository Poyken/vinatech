# 📝 Daily Operational Playbook — Vận Hành & Giám Sát Hệ Thống Vinatech Hằng Ngày

> **Cập nhật:** 2026-06-14 | **Dành cho:** Kỹ sư hệ thống Vinatech & AI Agent (Antigravity)
> ← [Về INDEX](README.md) | [Nhật ký Sự cố & Vận hành](MES_OPERATIONAL_LOG.md)

Tài liệu này chứa quy trình kiểm tra sức khỏe hệ thống (Health Check) hàng ngày, giúp phát hiện sớm các sự cố về nghẽn cơ sở dữ liệu, lỗi đồng bộ ERP, hoặc lỗi dữ liệu hiện trường. Kỹ sư vận hành hoặc AI Agent có thể chạy các câu lệnh SQL dưới đây thông qua SSMS hoặc `run_query.ps1` để giám sát hệ thống.

---

## 🧭 Lịch Trình Giám Sát Hằng Ngày (Daily Checklist)

| Thời gian | Tác vụ kiểm tra | Mục tiêu | Lệnh SQL tham chiếu |
| :--- | :--- | :--- | :--- |
| **08:00 (Đầu ca sáng)** | Kiểm tra Block Sessions (Khóa bảng) | Phát hiện nghẽn database gây treo Client | [Mục 1.1](#11-kiểm-tra-tranh-chấp-tài-nguyên-block-sessions) |
| **08:15** | Kiểm tra trạng thái SQL Agent Jobs | Xác nhận các Job đồng bộ ERP/Groupware chạy thành công | [Mục 1.2](#12-kiểm-tra-trạng-thái-sql-agent-jobs) |
| **08:30** | Kiểm tra Log lỗi Stored Procedure | Tìm các lỗi nghiệp vụ phát sinh từ tối hôm trước | [Mục 1.3](#13-quét-log-lỗi-stored-procedures-gần-đây) |
| **12:00 (Giữa ca)** | Kiểm tra Lag đồng bộ ERP/Groupware | Đảm bảo PO từ ERP đã đổ về MES đầy đủ | [Mục 1.4](#14-kiểm-tra-lag-đồng-bộ-erp-groupware-mes) |
| **16:00** | Kiểm tra các Lot hết hạn bị khóa | Rà soát tồn kho NVL cận date hoặc đã hết hạn | [Mục 1.5](#15-kiểm-tra-lô-vật-tư-hết-hạn-expiry-date-check) |
| **20:00 (Đầu ca đêm)** | Kiểm tra Block Sessions & Log lỗi | Đảm bảo hệ thống ca đêm vận hành trơn tru | [Mục 1.1](#11-kiểm-tra-tranh-chấp-tài-nguyên-block-sessions), [1.3](#13-quét-log-lỗi-stored-procedures-gần-đây) |

---

## ⚡ Các Kịch Bản SQL Giám Sát Chi Tiết

### 1.1 Kiểm tra tranh chấp tài nguyên (Block Sessions)
Nếu người dùng báo phần mềm MES bị xoay vòng (loading) vô tận hoặc báo lỗi timeout, rất có thể đang có một tiến trình khóa (block) các bảng giao dịch lớn như `STB_ProdRouteHist` hoặc `STB_MaterialLotInfo`.

```sql
-- Chạy trên database bất kỳ để tìm session đang khóa hệ thống
SELECT 
    r.blocking_session_id AS [ID_Người_Chặn],
    r.session_id AS [ID_Bị_Chặn],
    s1.host_name AS [Máy_Chặn],
    s1.login_name AS [User_Chặn],
    s2.host_name AS [Máy_Bị_Chặn],
    s2.login_name AS [User_Bị_Chặn],
    r.wait_time / 1000 AS [Thời_gian_chờ_(Giây)],
    r.wait_type AS [Loại_chờ],
    t.text AS [Câu_lệnh_SQL_đang_chạy]
FROM sys.dm_exec_requests r WITH(NOLOCK)
JOIN sys.dm_exec_sessions s1 WITH(NOLOCK) ON r.blocking_session_id = s1.session_id
JOIN sys.dm_exec_sessions s2 WITH(NOLOCK) ON r.session_id = s2.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.blocking_session_id <> 0;
```
*   **Giải quyết:** Nếu thời gian chờ vượt quá 60 giây và gây treo hệ thống diện rộng, hãy báo cáo DBA kiểm tra và dùng lệnh `KILL [ID_Người_Chặn]` nếu cần thiết sau khi đã xác minh tiến trình.

---

### 1.2 Kiểm tra trạng thái SQL Agent Jobs
Hệ thống sử dụng các Job chạy ngầm để đồng bộ BOM, Vật tư, Khách hàng từ ERP Douzone và Groupware sang MES.

```sql
-- Kiểm tra các SQL Agent Jobs thất bại trong vòng 24 giờ qua
SELECT 
    j.name AS [Tên_Job],
    h.step_id AS [Bước],
    h.step_name AS [Tên_Bước],
    h.message AS [Thông_báo_lỗi],
    run_date AS [Ngày_chạy],
    run_time AS [Giờ_chạy],
    h.run_duration AS [Thời_gian_chạy_(s)]
FROM msdb.dbo.sysjobs j WITH(NOLOCK)
JOIN msdb.dbo.sysjobhistory h WITH(NOLOCK) ON j.job_id = h.job_id
WHERE h.run_status = 0 -- 0 = Thất bại
  AND h.run_date >= CAST(CONVERT(VARCHAR(8), GETDATE() - 1, 112) AS INT)
ORDER BY h.run_date DESC, h.run_time DESC;
```
*   **Giải quyết:** Nếu phát hiện các job đồng bộ ERP bị fail, tiến hành khởi động lại job thủ công bằng SSMS hoặc kiểm tra kết nối mạng (VPN) liên kết giữa máy chủ MES và máy chủ ERP.

---

### 1.3 Quét log lỗi Stored Procedures gần đây
Hầu hết các Stored Procedure của MES đều ghi nhận lỗi vào bảng `STB_ProcedureLog` hoặc `STB_ProcessTerminalDataLog` khi gặp ngoại lệ.

```sql
-- Tìm các lỗi Stored Procedure phát sinh trong ngày
SELECT TOP 100
    ProcedureName AS [Tên_Procedure],
    VariableName AS [Tên_Biến],
    VariableValue AS [Thông_tin_lỗi_hoặc_Barcode],
    CreateDateTime AS [Thời_gian]
FROM SmartFactoryV2.dbo.STB_ProcedureLog WITH(NOLOCK)
WHERE CreateDateTime >= DATEADD(DAY, -1, GETDATE())
ORDER BY CreateDateTime DESC;
```
```sql
-- Tìm các gói tin Client gửi lên bị lỗi kết quả xử lý
SELECT TOP 100
    ProcessDateTime AS [Thời_gian],
    IPAddress AS [IP_Client],
    Data AS [Gói_tin_thô],
    ProcessResult AS [Kết_quả_Lỗi]
FROM SmartFactoryV2.dbo.STB_ProcessTerminalDataLog WITH(NOLOCK)
WHERE ProcessResult LIKE '%Error%' OR ProcessResult LIKE '%Exception%'
  AND ProcessDateTime >= DATEADD(DAY, -1, GETDATE())
ORDER BY ProcessDateTime DESC;
```

---

### 1.4 Kiểm tra lag đồng bộ ERP -> Groupware -> MES
Kiểm tra xem các đơn hàng sản xuất (PO) hoặc kế hoạch ngày đã được tạo thành công chưa, hay bị kẹt ở bảng trung gian (Bridge Tables).

```sql
-- Kiểm tra các PO chưa đồng bộ thành công hoặc bị lỗi ở bảng trung gian
-- ESM Bridge table check
SELECT TOP 50
    CD_COMPANY AS [Công_ty],
    NO_WO AS [Mã_PO_ERP],
    CD_PLANT AS [Nhà_máy],
    CD_ITEM AS [Mã_Vật_Tư],
    QT_WO AS [Số_lượng_PO],
    ST_WO AS [Trạng_thái],
    CREATE_DATE AS [Ngày_tạo]
FROM SmartFactoryV2.dbo.STB_ESM_WO_HEADER WITH(NOLOCK)
WHERE NO_WO NOT IN (SELECT PONo FROM SmartFactoryV2.dbo.STB_ProductionOrderInfo WITH(NOLOCK))
ORDER BY CREATE_DATE DESC;
```

---

### 1.5 Kiểm tra lô vật tư hết hạn (Expiry Date check)
Kiểm tra các Lot nguyên vật liệu đã hết hạn sử dụng nhưng vẫn còn tồn trong kho sản xuất, giúp ngăn ngừa việc sử dụng NVL hỏng.

```sql
-- Tìm 50 Lot nguyên vật liệu đã quá hạn sử dụng nhưng Qty tồn > 0
SELECT TOP 50
    MaterialLotNo AS [Mã_Lot],
    MaterialCode AS [Mã_Vật_Tư],
    WarehouseCode AS [Mã_Kho],
    CurrentQty AS [Tồn_hiện_tại],
    LotAttr10 AS [Ngày_Sản_Xuất],
    -- Giả định hạn sử dụng 1 năm (365 ngày) nếu không có cấu hình hạn riêng biệt
    DATEADD(DAY, 365, CAST(LotAttr10 AS DATE)) AS [Ngày_Hết_Hạn],
    DATEDIFF(DAY, GETDATE(), DATEADD(DAY, 365, CAST(LotAttr10 AS DATE))) AS [Số_ngày_quá_hạn]
FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
WHERE CurrentQty > 0
  AND LotAttr10 IS NOT NULL
  AND ISDATE(LotAttr10) = 1
  -- Lọc ra các Lot đã quá hạn sử dụng
  AND DATEADD(DAY, 365, CAST(LotAttr10 AS DATE)) < GETDATE()
  -- Loại trừ các Lot đã được khai báo bypass hạn dùng
  AND MaterialLotNo NOT IN (SELECT LotID FROM SmartFactoryV2.dbo.stb_vvt_OpenExpiredMaterial WITH(NOLOCK))
ORDER BY [Số_ngày_quá_hạn] ASC;
```

---

## 👥 Cơ Chế Phối Hợp Giữa Vận Hành & AI
1. **Mỗi sáng:** Kỹ sư vận hành chạy checklist hoặc yêu cầu AI chạy checklist thông qua chat.
2. **Khi phát hiện bất thường:** 
   - Sao chép log lỗi hoặc truy vấn SQL bị fail và dán vào bảng sự cố trong [MES_OPERATIONAL_LOG.md](MES_OPERATIONAL_LOG.md).
   - Tag AI `@Antigravity` và yêu cầu: *"Check sự cố ID [XX] trong log vận hành"*.
   - AI sẽ tự động phân tích cấu trúc Stored Procedure liên quan và đưa ra giải pháp khắc phục dựa trên các Volumes tương ứng.
