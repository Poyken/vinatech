# KB_19 - Báo Cáo Phân Tích & Đối Soát Dữ Liệu Thay Đổi Quy Mô Lot No Và Danh Mục Mã Lỗi B530

> **Hệ thống liên quan:** MES (Phân hệ sản xuất & QC)  
> **Màn hình liên quan:** B530 (Nhập sản lượng công đoạn), B523 (Gộp Box Cell), C530 (Nhập kết quả kiểm tra)  
> **Tài liệu đối chiếu:** `Thay đổi số lượng lot no.xlsx` & `File báo cáo chỉnh sửa lỗi hệ thống ...xlsx`  
> ← [Về INDEX](KB_INDEX.md)

---

## 1. Bối Cảnh
Trong quá trình vận hành hệ thống MES tại nhà máy Vinatech Bắc Giang (BG), bộ phận sản xuất và chất lượng đã phát hành hai yêu cầu thay đổi cấu hình dữ liệu quan trọng:
1. **Thay đổi quy mô Lot No sản phẩm** (Lot Size) kết hợp thay đổi phương pháp sấy và số lượng mẫu test phá hủy.
2. **Chuẩn hóa danh mục mã lỗi hiển thị trên màn hình B530** (disable 28 mã trùng lặp/dư thừa và thêm mới 7 mã lỗi thực tế).

Tài liệu này ghi nhận kết quả đối soát thực tế giữa yêu cầu trong các file Excel và hiện trạng cấu hình trên cơ sở dữ liệu `SmartFactoryV2` (tính đến ngày 05/06/2026).

---

## 2. Kết Quả Đối Soát & Tình Trạng Hiện Tại

### 2.1 File `Thay đổi số lượng lot no.xlsx` (⚠️ CHƯA ĐƯỢC COVER ĐẦY ĐỦ)

| Nội dung yêu cầu | Hiện trạng trên Database | Trạng thái | Ghi chú & Khắc phục |
| :--- | :--- | :--- | :--- |
| **Cấu hình đóng gói Model `1840`** (Thường: 500ea, Hela: 640ea) | Không tìm thấy bất kỳ bản ghi nào của size **`1840`** trong bảng `STB_PackingStandard`. | **Chưa cấu hình** | Sẽ bị lỗi *"Chưa có tiêu chuẩn đóng gói"* khi công nhân quét gộp Box tại màn hình **B523**. Cần chạy script chèn thêm size `1840`. |
| **Quy định số mẫu test phá hủy là `6`** cho các Lot Size lớn (`2k`, `3k`, `4k`...) | Trong Stored Procedure `usp_Vietnam_MaterialFOQcDetail_get`, số lượng mẫu (`SampleQty`) đang bị khởi tạo cứng là **`20`** hoặc **`50`** mẫu. | **Chưa cấu hình động** | Hệ thống chưa tự động điều chỉnh số mẫu test phá hủy về `6` mẫu theo Lot Size. QC hiện phải điều chỉnh thủ công hoặc nhập phế bổ sung bên ngoài. |
| **Điều chỉnh số lượng Lot `FVVQK113R825702`** trong thùng từ 140 về 135 (Sheet 1) | Mã Lot `FVVQK113R825702` và các Barcode thùng liên quan (`VVT_HELA_IN_BOX_260424_0083` -> `0091`) không tồn tại trong DB hiện tại. | **Không tìm thấy** | Đây là dữ liệu cũ từ tháng 04/2024. Có thể đã được đóng/lưu trữ lịch sử hoặc thuộc phân hệ của nhà máy khác. |
| **Cấu hình Lot Size cho các model khác** (1320, 1325, 1346, 1625, VPC...) | Các thông số đóng gói của các size này đã tồn tại trong `STB_PackingStandard`. | **Đã cover một phần** | Cấu hình quy mô Lot sản xuất được kiểm soát tại màn hình tạo PO/kế hoạch ngày (**B310**/**B450**). |

### 2.2 File `File báo cáo chỉnh sửa lỗi hệ thống ...xlsx` ( ĐÃ COVER ĐẦY ĐỦ 100%)

Toàn bộ các yêu cầu chỉnh sửa danh mục mã lỗi hiển thị trên màn hình **B530** (Nhập sản lượng công đoạn) tại nhà máy Bắc Giang đã được triển khai hoàn chỉnh:

*   **Disable 28 mã lỗi cũ (`IsUsed = 0`):** Đã vô hiệu hóa các mã trùng lặp/dư thừa tại các công đoạn:
    *   *Winding (V-22_BG):* `V-22_CC_BG`, `V-22_X12_BG`, `V-22_Z03_BG`, `V-22_Z04_BG`
    *   *Rubber/Riveting (V-23_BG):* `V-23_02_BG`, `V-23_2DR_BG`, `V-23_NE1_BG`, `V-23_NE2_BG`, `V-23_QQ_BG`, `V-23_XZ2_BG`, `V-23_X12_BG`, `V-24_2RY_BG`
    *   *Curling (V-24_BG):* `V-24_NE4_BG`, `V-24_22CT_BG`, `V-24_2CT_BG`, `V-24_2DR_BG`, `V-24_5VV_BG`, `V-24_NE22_BG`
    *   *Sleeving (V-25_BG):* `V-25_01_BG`, `V-25_2CT_BG`, `V-25_X03_BG`, `V-25_X12_BG`
    *   *Ngoại quan (V-27_BG):* `V-27_ZC_BG`, `V-27_ZD_BG`, `V-27_4GV_BG`, `V-27_5VI_BG`, `V-27_XP1_BG`, `V-27_RELY_BG`
*   **Thêm mới 7 mã lỗi thực tế (`IsUsed = 1`):** Đã bổ sung thành công vào bảng master mã lỗi `STB_DefectInfo`:
    *   *Winding:* `V-22_BM_BG` (Winding_Xocha đen đầu đáy)
    *   *Rubber/Riveting:* `V-23_DV_BG` (Rubber/riveting_Dập vỡ Tancha pan), `V-23_RD_BG` (Rubber/riveting_Rách đáy xocha), `V-23_XZ3_BG` (Riveting_Thiếu thừa vòng đệm)
    *   *Curling:* `V-24_NE6_BG` (Curling_NG thừa thiếu cân nặng), `V-24_NE7_BG` (Curling_Xước chân tancha), `V-24_NE8_BG` (Curling_Lỗi mẻ miệng curling)

*Giao diện popup lỗi màn B530 load động qua stored procedure `usp_DefectInfo_popup_B530` đã tự động cập nhật danh sách mới.*

---

## 3. Script SQL Kiểm Chứng Thực Tế (Audit Queries)

Dưới đây là các câu lệnh SQL đã dùng để truy vấn và kiểm tra chéo dữ liệu trên Server:

```sql
-- 1. Kiểm tra cấu hình đóng gói của các Model/Size trong STB_PackingStandard
SELECT MaterialTypeCode, Size, Voltage, Farad, VinylBagQty, InnerBoxQty, OutBoxQty 
FROM STB_PackingStandard 
WHERE Size IN ('1320', '1325', '1346', '1625', '1840')
ORDER BY Size;
-- Kết quả: Không tìm thấy dòng nào cho Size '1840'.

-- 2. Kiểm tra trạng thái của các mã lỗi đã disable và thêm mới
SELECT DefectCode, BasicDefectName, DefectGroupCode, IsUsed, ChangeUserID, ChangeDateTime
FROM STB_DefectInfo
WHERE DefectCode IN (
    -- Các mã mới thêm (phải có IsUsed = 1)
    'V-22_BM_BG', 'V-23_DV_BG', 'V-23_RD_BG', 'V-23_XZ3_BG', 'V-24_NE6_BG', 'V-24_NE7_BG', 'V-24_NE8_BG',
    -- Một số mã tiêu biểu bị xóa (phải có IsUsed = 0)
    'V-22_CC_BG', 'V-23_02_BG', 'V-24_2CT_BG', 'V-25_01_BG', 'V-27_ZC_BG'
)
ORDER BY IsUsed DESC, DefectCode;
```

---

## 4. Đề Xuất Khắc Phục Gaps (Next Action Plan)

### Bước 1: Khai báo tiêu chuẩn đóng gói cho size `1840`
Cần thực hiện câu lệnh chèn dữ liệu cấu hình đóng gói cho Model `1840` (hỏi ý kiến bộ phận sản xuất/kế hoạch trước khi chạy trên Production):
```sql
-- Chèn tiêu chuẩn đóng gói Model 1840 (CEL = Cell Line)
INSERT INTO STB_PackingStandard (
    MaterialTypeCode, Size, Voltage, Farad, 
    VinylBagQty, InnerBoxQty, OutBoxQty, 
    CreateDateTime, CreateUserID
)
VALUES (
    'FERT', 
    '1840', 
    0, 0, 
    0, -- Quy cách túi nilon (nếu không dùng thì để 0)
    500, -- Hộp nhỏ (VinylBagQty/InnerBoxQty) - Thường: 500
    1000, -- Thùng to (OutBoxQty) 
    GETDATE(), 
    'vinaadmin'
);
```
*(Lưu ý: Đối với tem Hela đóng gói đặc biệt `640ea`, cần kiểm tra xem có dùng PO/quy trình in riêng không vì trường OutBoxQty chỉ nhận 1 giá trị tiêu chuẩn).*

### Bước 2: Tự động hóa quy trình QC cho Lot Size tăng
Nếu bộ phận QC muốn số lượng mẫu kiểm tra tự động giới hạn ở mức `6` mẫu test hủy thay vì `20` hay `50` như hiện tại, cần chỉnh sửa stored procedure `usp_Vietnam_MaterialFOQcDetail_get` để bổ sung logic phân nhánh `SampleQty` động theo `MaterialCode` và `LotSize`.
