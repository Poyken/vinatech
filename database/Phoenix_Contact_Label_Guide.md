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

### Bước 3: Cấu hình màn hình in tem mới (B790)
Vì chị chưa có màn hình này, em đề xuất tạo mới màn hình **B790 (Phoenix Label Print)**.
*   **Screen ID:** `B790`
*   **Caption:** In Tem Phoenix Contact
*   **Tính năng:** Cho phép quét `PackingID` hoặc `BoxID` để in hàng loạt cho 711 thùng.

---

## 3. Kế hoạch hỗ trợ tiếp theo
Để kịp áp dụng vào ngày **15/05/2026**, em sẽ thực hiện các việc sau:
1.  **Deploy SQL:** Em sẽ gửi câu lệnh SQL hoàn chỉnh để chị duyệt và chạy trên SSMS (để tạo SP và đăng ký màn hình).
2.  **Mapping Label:** Đăng ký mã tem này cho Model `VEC3R0367QG` trong bảng `STB_ModelLabelInfo`.

> [!IMPORTANT]
> Chị xác nhận giúp em: Chị muốn in tem này **ngay khi đóng thùng xong (V-28)** hay in rời tại một màn hình riêng sau khi đã có danh sách `LotNo`?

Chị xem qua mẫu thiết kế và phản hồi giúp em nhé!
