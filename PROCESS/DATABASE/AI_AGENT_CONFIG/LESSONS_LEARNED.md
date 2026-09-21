# 🎓 LESSONS LEARNED — BÀI HỌC KINH NGHIỆM TRUY VẤN & SỬA LỖI CSDL VINATECH

> **Single Source of Truth:** `PROCESS\DATABASE\AI_AGENT_CONFIG\LESSONS_LEARNED.md`  
> **Nguồn tổng hợp:** 15 CSDL Vinatech + [HOTFIX_LOG_HISTORICAL.md](HOTFIX_LOG_HISTORICAL.md) (07/2026 - 08/2026)

---

## 1. Cạm Bẫy Three-Valued Logic (3VL) Với Giá Trị NULL
- **Hiện tượng:** Trong SQL Server, biểu thức `WHERE IsDelete = '0'` sẽ **bỏ qua tất cả các dòng có `IsDelete IS NULL`**!
- **Thực tế:** Trên bảng `STB_DefectRepairInfo` hoặc `MongoToMesPerformance`, nhiều dòng được tạo ra có `IsDelete IS NULL`. Nếu viết `WHERE IsDelete = '0'`, dữ liệu bị thiếu nghiêm trọng.
- **Giải pháp:** Luôn viết: `WHERE ISNULL(IsDelete, '0') = '0'`.

## 2. Cạm Bẫy Phép Trừ Với Giá Trị NULL
- **Hiện tượng:** `DefectQty - RepairQty` trả về `NULL` nếu `RepairQty IS NULL`.
- **Hậu quả:** Giao diện WinForms/Web hiển thị ô trống hoặc sai số lượng phế tồn.
- **Giải pháp:** Bắt buộc viết: `ISNULL(DefectQty, 0) - ISNULL(RepairQty, 0)`.

## 3. Cạm Bẫy Collation Tiếng Hàn Trên `erpdb`
- CSDL `erpdb` sử dụng Collation Hàn Quốc (`Korean_Wansung_Unicode_CS_AS`). Nếu viết JOIN trực tiếp với chuỗi từ `NEOE` hoặc `VINATECH_GROUP` mà không chỉ định Collation sẽ báo lỗi: `Cannot resolve the collation conflict between ...`.
- Luôn chỉ định: `ON a.Col1 COLLATE Korean_Wansung_Unicode_CS_AS = b.Col2 COLLATE Korean_Wansung_Unicode_CS_AS`.

## 4. Cạm Bẫy Khóa Bảng (Deadlock) Khi JOIN Giữa Groupware Và MES
- `VINATECH_GROUP` có nhiều giao dịch phê duyệt liên tục, trong khi `SmartFactoryV2` có hàng trăm trạm Kiosk quét barcode mỗi phút.
- Nếu chạy câu SELECT liên CSDL mà quên `WITH(NOLOCK)` ở bất kỳ bảng nào, truy vấn có thể bị giữ Intent Shared (IS) lock gây nghẽn toàn bộ dây chuyền quét xuất hàng.
- **Luôn kiểm tra kỹ cú pháp `WITH(NOLOCK)` sau mọi tên bảng.**

---

## 5. Cạm Bẫy Trigger `tgMaterialDocDetailForDelete` & Kỹ Thuật Bypass Bằng `CONTEXT_INFO 0x999997`
- **Hiện tượng:** Khi cần hủy box đóng gói hoặc rã Lot tại `HN523`/`B523`, lệnh `DELETE FROM STB_MaterialDocLotInfo` hoặc `STB_MaterialDocDetail` bị trigger chặn với thông báo lỗi trạng thái chứng từ không cho phép xóa.
- **Cơ chế:** Trigger `tgMaterialDocDetailForDelete` kiểm tra trạng thái chứng từ và cờ `CONTEXT_INFO`.
- **Giải pháp chuẩn:**
  ```sql
  -- Tạm mở DocStatus = 'CREATE' và đặt CONTEXT_INFO trước khi xóa
  UPDATE STB_MaterialDocInfo SET DocStatus = 'CREATE', IsCancel = 0 WHERE MaterialDocNo = '@DocNo';
  SET CONTEXT_INFO 0x999997;
  DELETE FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '@DocNo';
  SET CONTEXT_INFO 0;
  DELETE FROM STB_MaterialDocDetail WHERE MaterialDocNo = '@DocNo';
  UPDATE STB_MaterialDocInfo SET IsCancel = 1, CancelDateTime = GETDATE() WHERE MaterialDocNo = '@DocNo';
  ```

## 6. Cạm Bẫy Popup Đỏ "Kho Thành Phẩm Chưa Nhập Cân Nặng" Tại B523 Sau Khi Chuyển Đổi Lot (B351)
- **Hiện tượng:** Công nhân chuyển đổi Lot tại `B351`, ra `B523` bấm in tem dán thùng thì văng lỗi: *"Could not find Kho Thành phẩm chưa nhập cân nặng cho Lót hàng này! at ScreenControl.PrintLabel"*.
- **Nguyên nhân:**
  1. `B351` chỉ đổi mã trong `STB_SetInfo`, không tự nạp cân Barcode vào `STB_VIETNAM_BARCODEWEIGHT` và `STB_VN_FINISHGOODS`.
  2. SP `usp_Vietnam_GetBoxIDForLotNo_VVT` tính `@lotweight = 0` do thiếu dòng trong `STB_VIETNAM_BARCODEWEIGHT` ➔ gán `FormatName = N'Kho Thành phẩm chưa nhập cân nặng...'`.
  3. C# WinForm Client tìm template tem in theo tên đó không thấy nên crash popup.
- **Giải pháp:** Bổ sung ngay bản ghi cân nặng vào `STB_VIETNAM_BARCODEWEIGHT` và đồng bộ `STB_ChangePartNoAndLotNo` cho Lot mới.

## 7. Cạm Bẫy Nút "Nhập Lỗi" (AddDefect) Bị Mờ Tại B530 Do Biểu Thức UI
- **Hiện tượng:** Nút "Nhập lỗi" (`AddDefect`) trên màn hình `B530` bị disable khi muốn báo phế cho Barcode.
- **Nguyên nhân:** Biểu thức Expression của giao diện: `!IsHasNextProd && !IsLoss`. Do Barcode đã quét/chốt ở công đoạn tiếp theo, cờ `IsHasNextProd = 1` ➔ Nút tự động bị khóa.
- **Giải pháp:** Rollback công đoạn sau: xóa bản ghi `STB_DefectRepairInfo` và `STB_ProdRouteHist` của công đoạn sau, đồng thời reset `CompleteRoute = NULL` ở công đoạn hiện tại.

## 8. Cạm Bẫy Lệch Phân Quyền Xưởng & Điều Chuyển Lot Lệch Tuyến (BN/BG1 ➔ HY)
- **Hiện tượng:** Lot chuyển từ Bắc Ninh (`VVT_F1`) hoặc Bắc Giang (`VVT_F2`) về Hưng Yên (`VVT_F5`), khi quét chốt tại `HY530` bị báo *"Công đoạn này không có trong Routing hoặc là công đoạn cuối cùng"*.
- **Nguyên nhân:**
  1. Mã công đoạn chưa được quy đổi sang mã chuẩn của xưởng Hưng Yên (`V-26` ➔ `V-26_HY`) và `InputLineCode` vẫn là chuyền Bắc Ninh.
  2. Đăng nhập tài khoản sai xưởng: PO tạo ở BG1 phải chốt bằng `vvtworker_bg`; PO tạo ở Hưng Yên phải chốt bằng `vvtworker_hy`.
- **Giải pháp:** Đồng bộ `InputLineCode = 'VVHYC-01'`, cập nhật `RouteCode = 'V-26_HY'`, và nhắc người dùng đăng nhập đúng tài khoản xưởng.

## 9. Cạm Bẫy Autocheck Gate Aging 24 Giờ Khi Hoàn Thành Công Đoạn Ngoại Quan
- **Hiện tượng:** Quét Lot tại công đoạn Ngoại quan bị MES chặn: *"Chưa đủ thời gian Aging lão hóa theo quy định"*.
- **Nguyên nhân:** SP kiểm tra logic: `DATEDIFF(HOUR, CreateDateTime, GETDATE()) < 24`. Nếu chưa đủ 24 giờ kể từ khi hoàn tất công đoạn sấy/bọc vỏ, hệ thống tự động khóa Gate không cho chuyển trạm.

## 10. Cạm Bẫy Tạo PO Thủ Công Tại B310 Báo Lỗi "공정 라우팅 정보가 없습니다"
- **Hiện tượng:** Khi tạo PO thủ công trên `B310` văng lỗi: *"공정 라우팅 정보가 없습니다 (Không có thông tin routing công đoạn)"*.
- **Nguyên nhân:** SP `usp_DoCreateProductionOrder` lọc theo `BRD.WorkCenterCode = @WorkCenterCode`. Mã hàng đang gán `BasicRoutingCode` chỉ khai báo cho `VVT_F1` (Bắc Ninh), không có bản ghi nào cho xưởng Hưng Yên (`VVT_F5`) ➔ `@@ROWCOUNT = 0`.
- **Giải pháp:** Tra cứu `STB_BasicRoutingDetail WHERE WorkCenterCode = 'VVT_F5'` và cập nhật mã routing chuẩn cho Model tại `STB_MaterialMaster`.

## 11. Cạm Bẫy Cắt Điện Cực Dư Mẻ Tại B552 & Cơ Chế Audit Snapshot
- **Hiện tượng:** Thao tác lặp tạo nhiều mẻ cắt trùng nhau cho cùng một cuộn Lot mẹ trong `STB_ElectrodeSlittingResult` (ví dụ cuộn mẹ sinh từ Seq 1 đến Seq 70 trong khi chỉ cần 5 cuộn).
- **Quy tắc an toàn:** Trước khi `DELETE FROM STB_ElectrodeSlittingResult WHERE Seq BETWEEN @From AND @To`, **bắt buộc** lưu snapshot vào bảng audit `STB_ElectrodeSlittingResultHist` với `Flag = 'DELETE'` để đảm bảo 100% khả năng phục hồi dữ liệu khi cần.

## 12. Quy Tắc Bóc Tách Ngày Sản Xuất Vendor Lot
- **Dòng họ vỏ nhôm AOXING (`GBAXAC-%`):** Format 18 số: 5 ký tự đầu mã NCC + 2 ký tự Năm + 2 ký tự Tháng + 2 ký tự Ngày + Hậu tố. Ví dụ: `07281260806...` ➔ `2026-08-06`.
- **Dòng họ nút cao su (`GBNKSP-%`):** Format: 1 ký tự Năm (`5` ➔ 2025) + 1 ký tự Tháng (`1..9`, `X`/`A`=10, `Y`/`B`=11, `Z`/`C`=12) + 2 ký tự Ngày (`06`). Ví dụ: `5606N19B` ➔ `2025-06-06`, `5Y13...` ➔ `2025-11-13`.
- Hai hàm tính toán trung tâm: `fn_VVT_getdatebyVendorLot_MergeCode` và `fn_VVT_getdatebyVendorLot` trong `SmartFactoryV2`.
