# TỔNG HỢP CHI TIẾT CÁC BẢNG, CỘT VÀ GIÁ TRỊ TRONG DATABASE MES (NAIS)

> Tài liệu này tổng hợp toàn bộ các bảng dữ liệu (Table), các cột quan trọng (Column) và ý nghĩa của các giá trị (Value / Flag) theo từng Phase của luồng MES, dựa trên tài liệu **13_FLOW_TONG_HOP** và **15_EA_GUIDE_FLOW_MES**. 
> Đặc biệt hữu ích cho Kỹ sư EA / Hỗ trợ sản xuất khi cần query truy xuất lỗi dữ liệu, đặc biệt trong các nghiệp vụ truy vết từ nguyên vật liệu (NVL) tới thành phẩm (FG) và ngược lại.

---

## 1. M_MASTER_DATA: MASTER DATA (CẤU HÌNH BAN ĐẦU TỪ ERP/PLM)
*Những bảng này lưu trữ dữ liệu gốc, tĩnh, hiếm khi biến động hàng ngày. Do bộ phận Master Data thiết lập ban đầu qua các màn hình A (A230, A310, A410...)*

### Bảng `M_Materials` (Danh mục Nguyên Vật Liệu / Sản phẩm - Màn hình A230)
| Cột (Column) | Ý nghĩa thao tác | Giá trị thường gặp (Value) | Giải thích sự cố EA |
| :--- | :--- | :--- | :--- |
| `MaterialID` / `PartNo` | Mã định danh Vật tư / Sản phẩm | (Mã quy định riêng của nhà máy, ví dụ: R12345) | Đây là Key chính (Primary Key/Foreign Key) để join với tất cả các bảng phía sau. |
| `MaterialType` | Loại vật tư | `RAW` (Nguyên vật liệu), `WIP` (Bán thành phẩm), `FG` (Thành phẩm) | Nếu NVL chưa được gán loại `RAW` đúng cấu hình, kho sẽ không xuất được qua màn hình sản xuất. |
| `Description` | Tên/Mô tả vật tư | "Tụ điện 10uF 50V" | Dùng để verify bằng mắt xem chọn đúng mã chưa. |

### Bảng `M_BOMs` (Danh sách thành phần - Công thức chế tạo - Màn hình A310)
| Cột (Column) | Ý nghĩa thao tác | Giá trị thường gặp (Value) | Giải thích sự cố EA |
| :--- | :--- | :--- | :--- |
| **`BomVersion`** | **Phiên bản BOM theo năm sản xuất NVL** | `99` (dùng NVL năm 1999), `2001` (Dùng nhiều ở Bắc Ninh), các số khác (Hà Nam hay dùng mix code) | **LỖI KINH ĐIỂN:** Nếu dây chuyền báo "Lắp sai Part / Wrong Component", EA hãy check lại `BomVersion` xem đã load bản nào lúc chốt lệnh ở B310. Kéo sai BOM sẽ lệch toàn bộ danh sách NVL cấn trừ phía sau. |
| `ParentPartNo` | SP cha cần chế tạo | SP A | Lắp ráp từ các `ChildPartNo` bên dưới. |
| `ChildPartNo` | NVL con cấu thành | NVL 1, NVL 2 | Bắt buộc phải có trong tồn kho (`I_Inventory`) khi cấn trừ (Backflush) ở B540. |
| `UsageQty` | Định mức tiêu hao | `1`, `2`, `0.5`... | Lỗi trừ lố hoặc không trừ kho phần lớn do sai định mức tại đây. |

### Bảng cấu hình đặc thù
| Tên Bảng | Ý nghĩa thao tác | Cột/Giá trị quan trọng | Giải thích sự cố EA |
| :--- | :--- | :--- | :--- |
| `M_PackRules` | Quy tắc đóng gói (Màn A418) | `PackQty`: `500`, `1000` | Nếu nhân viên báo máy gộp tem B523 ra dư/thiếu hàng, EA phải vô đây sửa lại số lượng chuẩn. |
| *(Cấu hình OQC)* | Cấu hình hàng Cell/Module (Màn A410) | `Loại kiểm tra`, `Loại OQC` | C512 quét không ra Lot OQC? Lỗi 90% do User quên móc cấu hình trong A410. |
| `M_Locations` | Phân khu vật lý kho | `F110` (Thuộc tính) | **ĐIỀU KIỆN SỐNG CÒN CỦA ĐÓNG GÓI:** Ở F110 bắt buộc phải tick cờ `IsUseBarCode = True` và `IsLotUse = True` thì Báo cáo đóng gói mới được phép gộp Box. |

---

## 2. W_WORK_ORDERS: LỆNH SẢN XUẤT (PHASE 1)
*Quản lý kế hoạch tháng (PO) và chia kế hoạch ca làm việc theo ngày. Đây là xương sống để mở khóa dây chuyền.*

### Bảng `W_WorkOrders` (Lệnh Tháng - B310)
| Cột (Column) | Ý nghĩa thao tác | Giá trị thường gặp (Value) | Giải thích sự cố EA |
| :--- | :--- | :--- | :--- |
| `OrderNo` | Mã lệnh SX (PO) | `PO_2403...` | Bị mất lệnh: EA check Log API đẩy từ ERP (`W_WorkOrder_IF` table) xem có bị kẹt rác không. |
| `Status` | Trạng thái PO gốc | `Create` (Mới tạo), `Active / Released` (Đã chốt) | **BẮT BUỘC** phải là `Active/Released` thì kế hoạch ngày (B450) bên dưới mới kéo dữ liệu ra xài được. |
| `BomVersion` | Version kế thừa từ A310 | `99`, `2001`... | Được Fix cứng lúc Planner bấm tạo lệnh tháng. |
| `ProQty` | Số lượng tổng cả tháng | `10000`, `50000` | Số lượng kỳ vọng (Target). |

### Bảng `W_DayPlans` (Kế hoạch Ngày / Ca - B450)
| Cột (Column) | Ý nghĩa thao tác | Giá trị thường gặp (Value) | Giải thích sự cố EA |
| :--- | :--- | :--- | :--- |
| `LineID` | Dây chuyền sản xuất | `LINE-01`, `CELL-1` | Định tuyến máy nào sẽ chạy. Dùng để tính toán Loading cho Line. |
| `PlanDate` | Ngày kế hoạch | `YYYY-MM-DD` | |
| `Shift` | Ca làm việc | `1` (Ngày), `2` (Đêm) | Dùng để khóa thời gian báo biểu (Cut-off time), tính hiệu suất nhân sự. |
| `TargetQty` | Số lượng chạy trong ca | `Integer` | Giao chỉ tiêu cho công nhân. |
| **`IsFixed`** | **Cờ mở khóa sản xuất (Nút FixDayPlan)** | `True` (Đã chốt - Chạy), `False/Null` (Chưa chốt - Khóa) | 💥 **LỖI CỰC HAY GẶP:** Màn hình B540 bóp cò súng quét mã nhưng báo *"Plan is locked or not found"*. Nguyên nhân do Planner tạo kế hoạch nhưng quên bấm nút "Chốt Kế Hoạch 1 Ngày" -> `IsFixed = False`. |

---

## 3. M_LOTS & I_INVENTORY: KHO NGUYÊN VẬT LIỆU (PHASE 2)
*Ghi nhận nhập kho, gán/tách tem Barcode NVL và Tồn kho tổng hợp.*

### Bảng `M_Lots` (Lô Vật Tư / Tem cuộn Vật tư - F330)
| Cột (Column) | Ý nghĩa thao tác | Giá trị thường gặp (Value) | Giải thích sự cố EA |
| :--- | :--- | :--- | :--- |
| `LotNo` | Mã Barcode được sinh ra | `LOT_2026...` | Công nhân dùng máy Scanner tít trực tiếp mã này trên Line. |
| `InvoiceNo` | Số hóa đơn gốc ở F312 | Lấy từ ERP sang | Dùng để đối soát với phiếu nhập mạn khi nảy sinh tranh chấp NCC. Mất phiếu ở Invoice nghĩa là kẹt API Sync giữa chừng. |
| `ReceiveQty` | Tổng số lượng nhận | `10000` | Tổng giá trị hàng trong lô. |
| `PackingQty` | Định mức đóng gói F330 | `150` | Mặc định xé nhỏ `ReceiveQty` ra thành từng Lot `LotNo` nhỏ có sức chứa `PackingQty`. |
| `ScanQty` | Số lượng đã xé tem/scan | `10000` | `ReceiveQty` phải **bằng** `ScanQty` thì quá trình F330 mới hoàn tất. Nếu lệch (thiếu mồ côi vài con), phải Void (Hủy) tem in lỗi trên DB. |
| **`ExpireDate`** | **Đặc tính 10 (Hạn sử dụng)** | `YYYY-MM-DD` | 💥 **LỖI FATAL:** Nếu hệ thống không sinh Giá trị Date ở F330 (bị `Null`), kho NVL bị "Đóng băng" rớt thẳng vào Sub-Inv `Holding`. Hành động xuất (F430) không hoạt động! EA Phải xem lại Master Data khai báo vòng đời NVL. |
| `Status` | Trạng thái tiếp nhận Lot | `Create` (F312), `Arrival` (F330) | Chỉ NVL mang cờ `Arrival` và trúng QA (như IQC Pass) mới được cho nối tiếp ra Line. |

### Bảng `Q_IQC_Results` (Kết quả đo lường đầu vào - C220)
| Cột (Column) | Ý nghĩa thao tác | Giá trị thường gặp (Value) | Giải thích sự cố EA |
| :--- | :--- | :--- | :--- |
| `LotNo` | Lô kiểm định | (Mã lô từ nhà Cung Cấp) | |
| `Status` | Án phạt IQC | `Pass` (Nhập kho), `Fail` (Trả NCC) | Mở/khóa chốt chặn trước khi nhảy số chính thức vào kho `I_Inventory`. |

### Bảng `I_Inventory` (Tồn Kho Tức Thời Thực Tế)
| Cột (Column) | Ý nghĩa thao tác | Giá trị thường gặp (Value) | Giải thích sự cố EA |
| :--- | :--- | :--- | :--- |
| `ItemCd` | Mã vật tư đang tồn | | |
| `LotNo` | Lô đang neo hàng | | |
| **`SubInv`** | **Khu vực ranh giới kho ảo** | `Main` (Kho tổng), `Holding` (Kho giam), `Line` (Kho tại máy) | Lệnh Xuất vật tư `F430` về bản chất DB là Update Row `SubInv` chuyển `Main` sang `Line`.<br>Máy tính trừ kho BOM (B540) **CHỈ QUÉT** Inventory có `SubInv = 'Line'`. NẾU CN than phiền "Lỗi No Stock", bật SQL kiểm tra ngay, 100% Batch NVL đó đang kẹt ở Main hoặc rớt vào Holding do hụt Đặc Tính 10. |
| `StockQty` | Tồn kho vật lý | `Int / Float` | |

---

## 4. W_WIPLOTS & TABLE LIÊN QUAN: SẢN XUẤT TRÊN CHUYỀN (PHASE 3)
*Ghi nhận chi tiết từng trạm nối tiếp nhau trong chu trình Routing. Quản lý toàn bộ tiến trình Work-in-Process. Transaction của nó đặc thù nhất.*

### Bảng `W_WIPLots` (Tem sản phẩm Work In Process - B540)
| Cột (Column) | Ý nghĩa thao tác | Giá trị thường gặp (Value) | Giải thích sự cố EA |
| :--- | :--- | :--- | :--- |
| `WIPLotNo` | Mã vạch hàng TẠO RA | `WIP-...` | Lot trung gian hình thành lúc sấy / lắp ráp đầu tiên. |
| `ComponentLot` | Mã NVL đã nuốt vào | `LOT_NVL_...` | Lưu log vết nuốt hàng, tạo Mapping Tree (Phả hệ) truy xuất. Phải khai quét Khung B ở B540. |
| **`Operation`** | **Trạm công đoạn hiện tại** | `Drying`, `Welding`... | Hệ thống dò Routing (B240). Nếu công nhân làm lách luật đứt Line (Bypass), chửi lỗi *"Missing Operation"*. EA mở Query Update trả về Line hoặc dùng Catch-up (Return line). |
| `Status` | Trạng thái sống chết của Lô | `Run` (Đang chạy), `Wait` (Chờ Move), `Hold` (Bị giữ) | Bị `Hold` = cấm thao tác ở khu vực trạm tiếp theo. EA vô Menu `M_HoldHistory` giải phóng (Lot Release). |
| `HoldReason` | Lý do Auto Block | Lỗi Máy / PQC chặn / Lặp thao tác | Tra bảng C385 Báo cáo bất thường nế u nhảy dòng. |

### Bảng `Q_TestResults` (Thông số **TỰ KIỂM SẢN XUẤT** - B597)
| Cột (Column) | Ý nghĩa thao tác | Giá trị thường gặp (Value) | Giải thích sự cố EA |
| :--- | :--- | :--- | :--- |
| **`Flag`** / `Code` | Phân nhóm QC Flag | **`TEST`** | 💥 Ở Màn B597 (Sản xuất đo đạc), dữ liệu Insert lên với cờ `TEST`. Đây là Self-Check của Công Nhân (Tổ Trưởng), không dính cục PQC của Kiểm định viên. |
| `TestValue` | Trị số ghi sổ thực tế | `0.15`, `50.2`... | Nếu Value này Over Limit ngưỡng (Upper/Lower), System tự sập rào quăng WIP Lot thành `Hold`. |

### Bảng `Q_PQC_Results` (Kết quả Đo lường Độc lập của QC - C443 / C460 / C521)
| Cột (Column) | Ý nghĩa thao tác | Giá trị thường gặp (Value) | Giải thích sự cố EA |
| :--- | :--- | :--- | :--- |
| **`Flag`** / `Code` | Phân nhóm QC Flag | **`QUALITY`** | Số liệu từ phòng Lab/QC bắn ngược vào bảng với cờ `QUALITY`. "User khóc báo nhập B597 đủ mà C430 dòm trống rỗng?" -> Do setup nhầm Flag `TEST` và `QUALITY` ở bộ Master C143! |
| `Status` | Án lệnh PQC phán xử | `Pass` (Dòng chảy OK), `Fail` (Kẹt) | Nếu `Fail`, Lot WIP bị cưỡng chế khóa cứng (Block). Buộc lập biên bản xả. |

### Bảng `Q_DefectHistory` (Lịch sử Nhập Lỗi Phế - B540 / B530 / B598)
| Cột (Column) | Ý nghĩa thao tác | Giá trị thường gặp (Value) | Giải thích sự cố EA |
| :--- | :--- | :--- | :--- |
| `DefectCode` | Mã Lỗi Quy Ước Nhóm | Cấu hình tại (C132) | Sinh các loại lỗi: Hàn hở chân, lệch tap, phù phế liệu. |
| `DefectQty` | Số lượng hàng vứt | `Integer` | Metrics làm Báo Cáo Cải Tiến (B782). Đặc biệt cảnh giác **Deadlock / Timeout Table** nếu giờ giao ca 15 máy cùng lưu vô DB 1 lúc. EA Monitor `sp_who2` kill Session nếu treo. |

---

## 5. CÁC BẢNG ĐÓNG GÓI VÀ KIỂM TRA OQC SAU CÙNG (PHASE 4 & 5)
*Gộp WIP rời thành Thùng lớn. Thẩm định 10-20 chỉ số vật lý/điện trở. DB khu vực này Insert rất khét.*

### Bảng `W_PackingLots` (Quy cách đóng hộp Màn ghép - B523)
| Cột (Column) | Ý nghĩa thao tác | Giá trị thường gặp (Value) | Giải thích sự cố EA |
| :--- | :--- | :--- | :--- |
| **`OuterBarcode`** | Mã vạch thùng to (Kiện Cha/Outer) | (Dùng Barcode Sinh) | Mô hình Dữ liệu Nested: 1 Thùng Cha gói `n` Lô Con WIP bên trong. **Luật Bất Cập: In 1 Lần.** Chống in nháp trùng nhãn. Kẹt giấy hoặc rách tem? Công nhân bó tay. EA phải vào DB gọi hàm Void Ticket nhả cờ In ra cho họ Make lại In mới. |
| `InnerBarcode` | Vạch túi nilon nhỏ (Con/Inner) |  | Sinh ra từ quá trình Split Box (Chia thùng nhỏ). Bấm Split khéo lộn chêm số, EA phải vào Undo Transaction. |

### Bảng `Q_OQC_Results` (Kết quả Đo lường Đầu Ra - C530 / C546)
| Cột (Column) | Ý nghĩa thao tác | Giá trị thường gặp (Value) | Giải thích sự cố EA |
| :--- | :--- | :--- | :--- |
| `InspectionParams` | Biến đo lường OQC | Kích Thước, Rò Rỉ... | ⚠️ **Cảnh báo Performance:** Do 1 Barcode lưu chục Parameter 1 lúc, Save rất chậm lỳ gánh. QA phàn nàn chửi lết! Yêu cầu IT Monitor Server Index và Dặn dò User click nhấp nhả từ tốn. |
| **`EvaluateResult`** | **Nút OQC Tổng Thẩm Quyền** | `OK` (Cho phép vô kho FG) <br> `Fail/Null` (Khóa OQC) | **Nguyên Nhân Kho Kêu Trời:** Màn C530 lag, User click lưu bị lọt rớt thao tác khiến Data bị Null cái cờ `EvaluateResult = OK` này! Hễ văng rớt cái chữ `OK`, Kho FG 100% không cho kéo hàng vô trạm. |
| `ESR_Value` | Điện trở ESR | Thông số `Ohm` (Màn C546) | Bài kiểm tra cuối cùng chốt hạ đo mức độ thuần khiết của Tụ Điện trước lúc xé vé xuất môn. |
| `Status` | Trạng thái WIP Lot Đổi Mầu | **`P-OQC`** (Passed OQC) | Cập nhật Trigger ngầm từ WIP -> P-OQC. Quá Trình WIP chính thức chết ngậm. Sẵn sàng luân sinh. |

---

## 6. I_FG_INVENTORY: KHO THÀNH PHẨM (PHASE 6)
*Quản trị kho thật tồn Thành phẩm (FG), tem giao hàng và báo cáo Doanh Thu lên ERP.*

### Bảng `I_FG_Inventory` (Kho Thành Phẩm Cuối Cùng - B525 / B453 / B528)
| Cột (Column) | Ý nghĩa thao tác | Giá trị thường gặp (Value) | Giải thích sự cố EA |
| :--- | :--- | :--- | :--- |
| `FG_LotNo` | Lô thành phẩm gác kệ | Đọc nối bảng ngược dóc lên `OuterBarcode` | |
| `Location` | Vị trí Địa Lý Kho Chứa | `FG00` (Bắc Giang)<br>`FG01` (Bắc Ninh)<br>`HN00` (Hà Nam) | Trạm cờ biên giới! Hàng tới trạm này, Background Service Scheduler (Hangfire/EDI) sẽ nhấc Data chọi API đưa lên Kế Toán ERP. Kế Toán cự lộn Số bị lệch không cân? 90% Job Sync timeout. EA bật Monitor Trigger Run thủ công! |
| `IsOuterPrinted` | Cờ In Tem dán Ngoài Xe tải (B453) | `True` / `False` | Phải tick checkbox *Là Tem Ngoài* ở UI thì Cột này mới nhẩy `True`. Có nó bằng True, Màn hình giao xuất lệnh Shipping (B528) mới chịu gom chùm Box vào 1 Bill. |

---
*Tài liệu dành cho khối Cải tiến hệ thống và Hỗ trợ nghiệp vụ MES (EA Team) | Ngày cập nhật: 2026-03-10*
