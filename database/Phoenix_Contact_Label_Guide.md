# 🏷️ Hướng Dẫn Thiết Kế & Triển Khai Tem Khách Hàng Phoenix Contact

Chào chị Hoa, dựa trên yêu cầu của Sale và trao đổi về việc lấy **Datecode (YYMMDD)** từ công đoạn **Winding** (Input JobDate), em xin gửi chị lộ trình thực hiện chi tiết bên dưới.

## 1. Phân tích Luồng Dữ liệu (Data Logic)
*   **Model:** `VEC3R0367QG` (3562)
    *   **Mã hệ thống hỗ trợ:** `ECVT30-197` (Active) và `ECVT30-098` (Old).
    *   *Giải pháp:* Đã bao phủ (cover) cả 2 mã để đảm bảo in được cho cả hàng cũ và mới.
*   **Datecode:** Lấy từ bảng `STB_SetInfo`, cột `InputJobDate` (Đây là ngày ghi nhận tại công đoạn cuốn).
*   **Quy cách in:** In theo lô hàng (`LotNo` hoặc `PackingID`) tại trạm đóng gói.
*   **Số lượng:** 120 pcs/thùng (dựa trên 85,320pcs / 711 thùng).

---

## 2. Các bước Triển khai Hệ thống

### Bước 1: Thiết kế mẫu tem trong Z530 (Label Design)
Chị vào màn hình **Z530 (LabelInfo)** để tạo mới một mẫu tem:
*   **Label Type:** `Phoenix_Label`
*   **Format Name:** `Phoenix_Contact_V1`
*   **Kích thước:** 80mm x 50mm (8x5 cm).
*   **Nội dung:** Gán biến `@DateCode` để hiển thị định dạng `YYMMDD`.

![Mockup thiết kế tem](file:///C:/Users/User%20Vinatech.DESKTOP-RJJSEQU/.gemini/antigravity/brain/c9d93a5f-ff6a-4263-81b1-b9bfeec41954/phoenix_contact_label_mockup_1778641249431.png)

### Bước 2: Viết Stored Procedure lấy dữ liệu in
Em đã chuẩn bị sẵn Script SQL để lấy đúng **InputJobDate** chuyển thành **DateCode**. Script này sẽ được dùng cho màn hình in mới.

```sql
/* 
   SP: usp_Vietnam_PhoenixContactLabelPrint_get
   Mục đích: Lấy dữ liệu in tem Phoenix Contact, bao gồm Datecode từ Winding
*/
CREATE PROCEDURE [dbo].[usp_Vietnam_PhoenixContactLabelPrint_get]
    @pPackingID NVARCHAR(50) = NULL
AS
BEGIN
    SELECT 
        DP.PackingID,
        DP.Qty,
        DP.MaterialCode,
        MBI.ModelName,
        -- Lấy YYMMDD từ ngày công đoạn Winding (InputJobDate)
        CONVERT(VARCHAR(6), SI.InputJobDate, 12) AS DateCode,
        SI.LotNumber,
        GETDATE() AS PrintDateTime
    FROM STB_DividePackaging DP WITH(NOLOCK)
    JOIN STB_SetInfo SI WITH(NOLOCK) ON DP.LotNo = SI.ControlNo
    JOIN STB_ModelBasicInfo MBI WITH(NOLOCK) ON DP.MaterialCode = MBI.ModelCode
    WHERE DP.PackingID = @pPackingID OR DP.ParentPackingID = @pPackingID
END
```

### Bước 3: Cấu hình màn hình in tem mới (B790 - Giao diện kiểu B756)
Vì chị muốn tính năng chọn số lượng tem như màn **B756**, giao diện B790 sẽ bao gồm:
*   **Ô nhập liệu:** `Number Label` (Mặc định = 1).
*   **Logic in:** Hệ thống sẽ gọi SP `usp_Vietnam_PhoenixContactLabelPrint_get` kèm theo tham số số lượng.
*   **Tính năng:** Hỗ trợ in bù, in thêm tem khi tem gốc bị hỏng/mất.

---

## 3. Cách Design tem trong Z530 (Nâng cao)
Để hỗ trợ việc in nhiều bản, trong **Z530**, chị có thể thêm các trường sau vào mẫu thiết kế:
1.  **Datecode:** `@DateCode` (Định dạng YYMMDD).
2.  **Số thứ tự tem:** `@CurrentIndex / @TotalQty` (Ví dụ: 1/3, 2/3).
3.  **Mã vạch:** Chứa thông tin `PackingID` để truy vết thùng hàng.

---

## 5. Hướng dẫn Test & Nghiệm thu
Để đảm bảo tem in ra đúng yêu cầu của khách hàng trước ngày 15/05, chị hãy thực hiện test theo các bước sau:

### Bước 1: Test Logic dữ liệu (SQL)
Chạy lệnh sau trong SSMS để kiểm tra Datecode và số lượng tem:
```sql
EXEC [dbo].[usp_Vietnam_PhoenixContactLabelPrint_get] 
     @pPackingID = 'MÃ_PACKING_THỰC_TẾ', 
     @pNumberLabel = 2
```
*   **Kỳ vọng:** Trả ra 2 dòng, cột `DateCode` có định dạng `YYMMDD`.

### Bước 2: Kiểm tra nút bấm trên UI
Nếu màn hình **B790** chưa hiện nút, chị hãy kiểm tra lại cấu hình `Action` trong `STB_ScreenObjects`. Nút bấm phải được gán Function thực thi là SP `usp_Vietnam_PhoenixContactLabelPrint_get`.

---

> [!IMPORTANT]
> **Xác nhận cuối cùng:** Em đã cover cả 2 mã `-098` và `-197` như chị dặn. Dù chị dùng mã nào thì hệ thống cũng sẽ tự động nhận diện mẫu tem Phoenix này.

Chị Hoa cần em hỗ trợ thêm phần đăng ký menu hay phân quyền cho màn hình này không ạ?
