# TỔNG HỢP CÁC CASE STUDY THỰC TẾ DÀNH CHO KỸ SƯ EA/MES KHI XUỐNG XƯỞNG

> **🔑 Keywords:** case study, EA, xưởng, vận hành, onboard, training, xuống xưởng, thực tế, hướng dẫn
> ← [Về INDEX](KB_INDEX.md)

Tài liệu này tổng hợp các tình huống (Case Studies) thường gặp nhất mà một Kỹ sư Hỗ trợ Ứng dụng Doanh nghiệp (EA) / Kỹ sư MES phải đối mặt khi trực tiếp "xuống line". Hiểu rõ các nguyên nhân gốc rễ và cách xử lý nhanh sẽ giúp EA làm chủ hệ thống và hỗ trợ sản xuất không bị gián đoạn.

---

## NHÓM 1: LỖI THAO TÁC CÔNG NHÂN (Human Errors & Process Bypass)

### Case 1.1: Công nhân làm "tắt" công đoạn (Bypass Routing)
* **Tình huống:** Trạm hiện tại (VD: Trạm B) báo lỗi "Lô hàng chưa qua trạm A" hoặc "Missing Operation", trong khi thực tế sản phẩm vật lý đã ở trạm B.
* **Nguyên nhân:** Công nhân trạm A quên thao tác MES, quét rớt, hoặc do mạng chập chờn lúc quét không kiểm tra lại màn hình hiển thị, sau đó tự ý đẩy hàng sang trạm B.
* **Cách xử lý:** 
    * Xác minh sản phẩm thực tế đã qua xử lý ở trạm A chưa.
    * Gọi QA/Leader xác nhận, dùng quyền Admin/Leader "Bù thao tác" (Move / Catch-up) trên MES tại trạm A.
    * Đào tạo lại quy trình; cân nhắc gắn cảm biến (sensor/quang trở) tại trạm để báo động nếu hàng trôi qua mà chưa có tín hiệu từ MES.

### Case 1.2: Double Click do mạng / UI chậm (Race Condition)
* **Tình huống:** Sản lượng bị x2, hoặc hệ thống báo lỗi trùng lặp dữ liệu (Duplicate Exception/Primary Key Violation) liên tục ở một trạm.
* **Nguyên nhân:** Mạng nội bộ lag hoặc DB Server phản hồi chậm, công nhân bấm "Hoàn thành" thấy vòng xoay nhiều lần nên mất kiễn nhẫn bấm tiếp 2-3 lần.
* **Cách xử lý:**
    * Kỹ thuật / EA kiểm tra Database, xóa các record Duplicate phát sinh sát giờ nhau (nếu được phép sửa Data tay).
    * Báo Dev team/Backend xử lý `Idempotency` (1 request ID gửi n lần chỉ tính 1) hoặc Frontend thêm tính năng Disable/Grey out nút bấm ngay sau khi click lần đầu.

### Case 1.3: Quên kết thúc Lô/Ca (End Lot / End Shift)
* **Tình huống:** Đầu ca mới vào sản xuất Model sản phẩm mới, nhưng hệ thống MES báo lỗi không cho bắt đầu (Start Line / Mount Component).
* **Nguyên nhân:** Ca trước ra về vội quên bấm "Hoàn thành Lô" hoặc chưa Un-mount (tháo) các linh kiện tiêu hao khỏi thiết lập trên hệ thống.
* **Cách xử lý:**
    * EA dùng quyền hỗ trợ Force End / Force Un-mount cưỡng chế trên hệ thống; giải phóng máy trạm cho ca mới làm việc.
    * Report lỗi tuân thủ cho quản đốc ca trước.

---

## NHÓM 2: LỖI PHẦN CỨNG & THIẾT BỊ NGOẠI VI (Hardware & IoT)

### Case 2.1: Máy in kẹt giấy, in ra tem trùng (Duplicate Barcode)
* **Tình huống:** Chuyền đóng gói (Packing) quét 2 sản phẩm khác nhau nhưng MES báo trùng Barcode, không cho đóng thùng.
* **Nguyên nhân:** Máy in Zebra in mờ hoặc kẹt, công nhân bấm "Reprint" in lại. Tem cũ bị nhầm lẫn và được người khác gỡ ra dán lên một sản phẩm thứ 2.
* **Cách xử lý:** 
    * Phối hợp kiểm tra vật lý 2 sản phẩm, xé bỏ 1 tem nhăn/lỗi.
    * Truy cập MES làm lệnh Void/Hủy 1 tem trên hệ thống, phát hành 1 tem mới (Generate mới) dán cho sản phẩm đó.

### Case 2.2: Súng mã vạch (Barcode Scanner) bị lỗi Font chữ / Caps Lock
* **Tình huống:** Quét mã Barcode là "P12345" nhưng MES lại nhận ra "p!@#$%" rồi báo mã không tồn tại.
* **Nguyên nhân:** Súng quét cấu hình mô phỏng Keyboard đầu vào. Máy trạm đang vô tình bật Unikey ở chế độ tiếng Việt hoặc dính phím Caps Lock, phím Shift trên bàn phím.
* **Cách xử lý:** 
    * Tắt Unikey, gỡ Caps Lock trên máy tính trạm ngay lập tức.
    * Nếu súng mất cấu hình: Dùng sổ User Manual của súng quét bắn vào các mã vạch (Scan Barcode) Reset Factory để khôi phục định dạng tiếng Anh mặc định.

### Case 2.3: Thiết bị PLC / Cân điện tử gửi dữ liệu rác (Garbage Data)
* **Tình huống:** Trạm Test tự động hoặc Cân hiển thị toàn chữ loằng ngoằng, MES nhận kết quả "NG" hoặc văng "System Error".
* **Nguyên nhân:** Dây tín hiệu RS232 (Cổng COM) bị nhiễu do từ trường máy móc tại xưởng, gãy cáp hoặc cấu hình sai tốc độ truyền (Baud Rate, Parity bits).
* **Cách xử lý:** 
    * Dùng tool HyperTerminal/PuTTY/Serial Port Monitor trên máy trạm đọc cổng COM xem tín hiệu thô (Raw Data). 
    * Kéo IT phần cứng xuống thay cáp chống nhiễu chuyên hoặc thiết lập lại tham số kết nối cho súng/PLC.

---

## NHÓM 3: LỖI DỮ LIỆU & HỆ THỐNG (Data & Master Data)

### Case 3.1: Sai lệch Master Data (Routing, BOM) ngay trong ca
* **Tình huống:** Dây chuyền đang lắp ráp, công nhân xuất kho và chuẩn bị lắp IC mã `A`, nhưng dùng máy quét MES thì MES chặn và báo hiệu còi "Sai định mức / Wrong Material".
* **Nguyên nhân:** Kỹ thuật (PE) vừa cập nhật Revision (Phiên bản BOM mới) dùng con IC mã `B` bên hệ thống gốc (ERP/PLM), trong khi hàng vật lý ngoài xưởng chưa đổi; hoặc hệ thống đã đổi nhưng chưa Sync xong với MES.
* **Cách xử lý:** 
    * EA lập tức Stop Line chặn rủi ro. Gọi họp khẩn PE, QA và Quản đốc: "Phiên bản hôm nay đang chạy đúng luật phải dùng Part A hay Part B?". 
    * Nếu lỗi do MES chưa Update kịp: Trigger Force-Sync tay từ ERP xuống MES. 

### Case 3.2: WIP (Hàng dở dang) trên MES bị mất tích hoặc sai số
* **Tình huống:** Kế hoạch lập phiếu xuất 1000 sản phẩm, xưởng đếm vật lý đủ 1000 nhưng trên báo cáo MES chỉ hiển thị 950 có sãn ở khâu đóng gói.
* **Nguyên nhân:** 50 hàng kia đang nằm kẹt ở trạng thái "Rework" (chưa xuất lại chuyền chính) hoặc bị gán nhầm vào trạm "Scrap" (Lỗi phế phẩm) vì công nhân thao tác sai.
* **Cách xử lý:** 
    * EA viết câu Query SQL tìm kiếm Status History của mã lệnh sản xuất đó xem hàng chui đi đâu.
    * Hỗ trợ làm lệnh "Return to Line" (Đưa lại về chuyền chính) trên Application.

### Case 3.3: Treo hệ thống do Locking / Deadlock Database
* **Tình huống:** Tại 1 thời điểm cuối ca, tất cả các trạm trong 1 line đồng loạt kêu trời vì vòng quay Loading xoay liên tục mãi không báo OK chữ xanh.
* **Nguyên nhân:** Một Quản đốc nào đó đang chạy 1 cái Report (Báo cáo) tổng hợp dữ liệu nguyên tháng quá nặng, câu lệnh truy vấn đó đã lock bảng Database Transaction, khiến cho lệnh insert của công nhân bị block xếp hàng chờ.
* **Cách xử lý:** 
    * Kỹ sư System/EA vào Server Database (VD: SQL Server SSMS), chạy `sp_who2` hoặc bật Activity Monitor.
    * Tra cứu Session ID (SPID) đang gây block, tiến hành Kill (đóng băng/hủy bỏ) session đó để "thông tắc" cho Line sản xuất. Nhắc nhở người chạy báo cáo hoặc nhờ Dev tối ưu thêm câu lệnh `WITH (NOLOCK)`.

---

## NHÓM 4: AUDIT & QUẢN LÝ CHẤT LƯỢNG (Audit & QA Traceability)

### Case 4.1: Chặn khẩn cấp (Hold / Lock) toàn bộ Lệnh hàng
* **Tình huống:** QA bóc thăm một linh kiện tại trạm kiểm tra và phát hiện nguyên liệu bị ngâm hóa chất quá thời gian quy định 2 phút. Lệnh báo động đỏ: Phải Block toàn bộ thiết bị đang chứa nguyên liệu đó!
* **Cách xử lý (Action của EA):** 
    * Sử dụng Tool **Forward Traceability**: Nhập mã linh kiện của lô hóa chất ngâm đó vào, truy vấn trên DB bung ra danh sách toàn bộ các Barcode thành phẩm có liên đới/thừa kế. 
    * Export danh sách này ra Excel, sau đó dùng công cụ "Batch Lot Hold" để gắn cờ Status = "Hold" trên MES. Lúc này công nhân đem quét hệ thống sẽ đỏ màn hình báo "Lot is on HOLD".

### Case 4.2: Khách hàng (Vendor) Audit "Truy Xuất Nóng"
* **Tình huống:** Đoàn đánh giá của Apple/Samsung xuống xưởng. Họ nhấc ngẫu nhiên một cụm Màn Hình trên máy đóng gói và hỏi: *"Sản phẩm này đi qua quy trình nào, giờ giấc, ai lắp và nguồn gốc keo là xuất xứ từ thùng Vendor nào?"*.
* **Cách xử lý:** 
    * Yêu cầu các báo cáo truy xuất nguồn gốc hoạt động nhanh. 
    * Bắn mã Barcode vào ô tìm kiếm (Genealogy Search) để ra cấu trúc hình cây (Tree View) toàn bộ lịch sử nguyên vật liệu (Backward Trace). Kỹ năng đọc Tree View của EA hướng dẫn cho line leader là yếu tố ghi điểm trong Audit MES.

---

## NHÓM 5: TÍCH HỢP HỆ THỐNG KHÁC (ERP, ANDON, CMS)

### Case 5.1: Công nhân thiếu chứng chỉ / Quyền (CMS Integration)
* **Tình huống:** Nữ công nhân thay vì đứng máy test (như mọi ngày) nay được điều sang máy dập. Khi Login/quẹt thẻ vào máy trạm bị MES từ chối.
* **Nguyên nhân:** Hệ thống Training/CMS chưa chứng nhận (Certification) bạn này đủ skill cho công đoạn máy dập ở mức cấu hình Master Data.
* **Cách xử lý:** 
    * Kiểm tra hệ thống skill matrix, nếu có sự nhầm lẫn hoặc duyệt thiếu trên hệ thống CMS/HR, EA hỗ trợ can thiệp mở Certification qua cơ chế ngoại lệ (By pass có sự đồng thuận ký form của QA).

### Case 5.2: Không thể tải Lệnh Sản Xuất (Work Order từ ERP)
* **Tình huống:** Lệnh sản xuất tháng `WO-45609` hiển thị trên ERP (SAP/Oracle) từ sáng, nhưng xưởng không thể Start lệnh trên máy do không nhìn thấy lệnh đổ về phần mềm MES.
* **Nguyên nhân:** API Middleware quá tải, Job tích hợp (Interface EDI / REST API) tải dữ liệu bị fail vì thiếu trường dữ liệu mapping hoặc lỗi ký tự.
* **Cách xử lý:** 
    * Kiểm tra Logger Kafka / Hangfire / API Middleware Server Log. 
    * Re-run (chạy lại) cục bộ message đó, hoặc chỉnh tay table trung gian (staging/interface table).

---

## NHÓM 6: LỖI NGUYÊN VẬT LIỆU VÀ CHUẨN BỊ LẮP RÁP (Material Management & Kitting)

### Case 6.1: Lắp sai cuộn linh kiện (Wrong Reel/Part) trên máy SMT
* **Tình huống:** Máy gắp đặt linh kiện (SMT Pick & Place) báo lỗi dừng khẩn cấp. Màn hình máy quét MES chớp đỏ báo "Parts Mismatch / Wrong Component".
* **Nguyên nhân:** Nhân viên tiếp liệu (Material Handler) quét nhầm cuộn (Reel) linh kiện của Model cũ gắn nhầm vào bảng mạch Model mới (Mã Item Code sai khác với định mức bản vẽ BOM). 
* **Cách xử lý:** 
    * Kiểm tra đối chiếu mã Part Number trên hình dán cuộn vật lý và Part Number yêu cầu trên màn hình máy.
    * Gỡ cuộn sai, gắn lại cuộn bảo đảm đúng mã. Cài đặt thao tác Un-mount (tháo rỡ rạc) cuộn cũ trên MES để xóa tồn kho ảo. Quét lại (Mount) cuộn mới cho chính xác.

### Case 6.2: Linh kiện hết hạn sử dụng (Shelf-life) hoặc hết thời gian xả ẩm (Floor-life)
* **Tình huống:** Quản lý kho cấp bo mạch MCU ra, công nhân đưa bo vào Line quét MES thì màn hình chớp cảnh báo "Material Expired" từ chối mở dòng chảy.
* **Nguyên nhân:** Các IC cao cấp hoặc keo tản nhiệt/hóa chất có hạn mức sử dụng (Shelf-life) rất khắt khe. Nếu quá hạn tĩnh hoặc mở vỏ bao bì ra môi trường không khí vượt quá 48 tiếng (Floor-life), MES sẽ lock chặt nguyên liệu này theo luật chất lượng.
* **Cách xử lý:** 
    * Dừng Line, thu hồi lô NVL đó ngay lập tức. Cấm dùng tuyệt đối tài khoản Admin để Bypass/Skip cho qua.
    * Trả linh kiện cho phòng QC đánh giá/đưa vào tủ sấy Baking. Nếu sau khi test lại nguyên liệu đạt chuẩn chất lượng mới gia hạn (Extend Shelf-life) trên hệ thống MES kèm Reason Code.

### Case 6.3: Tách lô hoặc Gộp lô sai số liệu (Split/Merge Data Mismatch)
* **Tình huống:** Thùng đầu vào có 100 chiếc, anh Leader thao tác tách lấy ra 30 chiếc, nhưng ấn MES nhầm lẫn thế nào thành ra Gộp (Merge) luôn với mã lô cũ, khiến lượng tồn nhảy thành 200 chiếc.
* **Nguyên nhân:** Thao tác nhầm các Layout chức năng "Chia tách lô" (Split Lot) và "Xác nhập lô" (Merge Lot) trên hệ thống giao diện con.
* **Cách xử lý:** 
    * Truy cứu Transaction History (Truy xuất Lịch sử Thao tác) tìm đúng User/Thời điểm gộp sai.
    * EA hỗ trợ chức năng "Undo Transaction" hoặc điều chỉnh Re-adjust cấu hình vật tư để trả 2 lô về trạng thái ban đầu của trước ca sản xuất. 

---

## NHÓM 7: LỖI BẢO TRÌ THIẾT BỊ VÀ ANDON (Equipment & TPM)

### Case 7.1: Thiết bị sản xuất quá hạn kiểm định (Calibration Overdue) 
* **Tình huống:** Sáng sớm công nhân vẫy gọi ầm ĩ: "Máy cấp điện áp Test báo chặn tài khoản không cho Login". Màn hình báo "Equipment Calibration Expired".
* **Nguyên nhân:** Setup trong hệ thống MES / TPM định nghĩa máy này kiểm định 6 tháng 1 lần. Hôm nay vừa vượt qua ngày Due Date mà chưa cập nhật trên phần mềm.
* **Cách xử lý:** 
    * Xác minh ngay thực tế: Nhóm Kỹ thuật Thiết bị (ME) đã đo đạc kiểm định dán tem chưa?
    * Nếu đã làm rồi vật lý nhưng quên nhập liệu vào phần mềm -> Báo nhân sự ME chạy Update Status "Calibration Completed Date" lại.
    * Nếu chưa làm thật -> Chặn máy luôn chờ bảo trì.

### Case 7.2: Liên tiếp Test NG (Consecutive Failure Auto-Lock)
* **Tình huống:** Chuyền tự động đang chạy rất mượt thì văng còi hú chớp nháy từ 1 máy test Function, màn hình khóa chặt "Machine Auto-Locked by Consecutive Yield Fail!".
* **Nguyên nhân:** Chuyên gia thiết lập hệ thống ghim quy tắc: "Phát hiện 3 sản phẩm liên tiếp có kết quả NG thì tự động dừng chuyền" (Thay vì để chạy hàng loạt tạo nùi 100 sản phẩm phế thải).
* **Cách xử lý:** 
    * Giúp Line Leader kiểm tra biểu đồ đồ thị (SPC Trend Chart) hoặc Log data để xem giá trị nào bị sai lệch. 
    * Gọi QA / Kỹ thuật máy tinh chỉnh lại Sensor, Test Pin đầu dò. QA nhập Supervisor Password mở lại máy (Unlock Equipment) tiếp tục chạy.

### Case 7.3: Gọi Andon vượt cấp mà không ai cứu (SLA Time-out Escalation)
* **Tình huống:** Nhấn nút máy hỏng Andon kêu 30 phút mà chẳng có ai xuống sửa, sau đó Andon tự tắt đèn chuyển qua màu Tím/Xám "Escalated".
* **Nguyên nhân:** Service Level Agreement (SLA). Quá 10 phút anh Thợ chính bảo trì không bấm trên phần mềm là "Tôi đã nhận việc" nên hệ thống MES đã Auto gửi Mail + SMS lên cấp Quản lý cao nhất. 
* **Cách xử lý:** 
    * Đọc log Andon Message Broker (như MQTT hay Web Socket) trên Server để check xem hệ thống có Miss Message không hay người thật quên tới ấn nút xử lý.
    * Check mạng nội bộ văn phòng tổ kĩ thuật có rớt hay không.

---

## NHÓM 8: LỖI MÔI TRƯỜNG CỤC BỘ TRẠM HỖ TRỢ (Edge / Infra Local Issues)

### Case 8.1: Lỗi Định dạng Vùng WinDows (Regional Setting - Dấu Phẩy/Chấm)
* **Tình huống:** Nhập kết quả cân thủ công là `3.14` kg bấm Save nhưng MES Error bung pop-up "Casting Data Type Error - Input string was not in a correct format".
* **Nguyên nhân:** IT cài đặt lại máy tính trạm đổi cấu hình Regional Setting sang VN (sử dụng dấu phẩy `,` cho số thập phân). MES do Tây hoặc Nhật Code thiết kế lấy chuẩn US dấu chấm `.`. 
* **Cách xử lý:** 
    * Bật Control Panel > Clock and Region > Thiết lập chuẩn Format về "English (United States)". 
    * Dài hạn: Báo Bug Developer viết Code sử dụng `CultureInfo.InvariantCulture` lúc Parse chuỗi.

### Case 8.2: Trình duyệt bị Cache bản Web tĩnh cũ (Browser Cache Issues)
* **Tình huống:** Cả nhà máy vừa Release cập nhật lớn MES có thêm nút "Đính kèm Hình ảnh" ở trang báo cáo kiểm hàng. Nhưng xưởng Báo là 3 line nhìn thấy, còn 2 line không thấy. 
* **Nguyên nhân:** Trình duyệt Chrome máy công nhân đang lấy file Frontend.js cũ bị Cache cứng (Hard Cache).
* **Cách xử lý:** 
    * Nhấn phím cứng `Ctrl + F5` hoặc `Ctrl + Shift + R` tải tệp mới nguyên. Hoặc Clear User Data Chrome.
    * Góp ý Dev team dùng thủ thuật đổi chuỗi Versioning sau file js mỗi lần Release, ví dụ: `app.main.js?v=2.1`. 

### Case 8.3: Máy quét Súng (Barcode Scanner) tự Auto Enter gấp 2 lần
* **Tình huống:** Quét mã vạch thì ô input nhảy mã liên tục sang màn hình thứ 2 hoặc văng thông báo Loading bị ngắt nửa chừng.
* **Nguyên nhân:** Mặc định đa phần các súng Barcode USB khi mua về đều Auto Suffix một phím "[Enter]". Nhưng nếu Developer code MES viết hàm ngầm lắng nghe `14 ký tự xong thì Submit`, súng lại nháy Enter dư phát nữa sẽ chọc hư Flow của Form Post Data.
* **Cách xử lý:** 
    * Lấy cuốn Sách Manual mã vạch của Súng Quét (Symbole, Zebra, Honeywell) mở Mode "Remove CR/LF Suffix". Dùng súng quét lệnh đó trên giấy là khỏi ngay.

---

## NHÓM 9: LỖI HẠ TẦNG MẠNG VÀ KẾT NỐI (Network & Infrastructure)

### Case 9.1: Trạm khuất sóng mất tín hiệu Wifi (Offline Mode Sync Failure)
* **Tình huống:** Công nhân đẩy xe PDA/Tablet vào góc xưởng quét mã đóng gói, quét 50 thùng ngon ơ, nhưng về đến bàn màn hình báo "Un-synced / Fail to Upload".
* **Nguyên nhân:** Khu vực đó bị điểm mù Wifi (Wifi Blind Spot) hoặc AP băng tần quá tải. Ứng dụng MES rớt về chế độ Offline lưu tạm vào Database Local (SQLite/IndexDB). Đến khi ra vùng có mạng đẩy Data lên thì văng lỗi Timeout hoặc bị xung đột Data do trong thời gian mất mạng, có cấp trên ở xa đã thao tác hủy hoặc chỉnh sửa đè lên 1 mã thùng đó rồi.
* **Cách xử lý:** 
    * Thu dọn dữ liệu: EA/IT trích xuất Data từ PDA, rà soát lại trên máy tính xem mã nào đã đồng bộ thành công, mã nào văng lỗi để thao tác thủ công đắp vào.
    * Giải pháp hạ tầng: Báo IT Network đo sóng kéo thêm Access Point (AP). Đề xuất lên đội Developer viết thêm hàm báo âm thanh còi hú "tít tít" (Beep) trên Mobile App nếu thiết bị rớt mạng trễ quá 5 giây, thay vì để User quét miệt mài nhưng không đẩy data lên sever.

### Case 9.2: Đứt cáp quang / Downtime Server giữa Ca (Server Outage)
* **Tình huống:** Bụp một phát, toàn bộ 4 dây chuyền đồng loạt hiện "Cannot connect to Server / Gateway Timeout 504". Hàng trăm công nhân không làm việc được, đứng chơi xơi nước vì Line "mù" không có lệnh sản xuất chạy tiếp.
* **Nguyên nhân:** Đứt cáp mạng quang từ xưởng lên phòng Server Trung tâm, hoặc Switch Core bị cháy nguồn. Mất điện trạm UPS trung tâm.
* **Cách xử lý (Action của EA):** 
    * Không hoảng loạn. Check ping đến Server, điện thoại xác nhận với IT System xem sự cố sẽ khắc phục mất bao lâu.
    * Báo động cấp 1: Kích hoạt Phương án "Sản xuất khẩn cấp bằng tay - Business Continuity Plan (BCP)". Yêu cầu Quản đốc chuyển qua SOP chạy bằng Giấy (Manual Paper Routing) kết hợp scan súng vào lưới Offline Excel (nhà máy phải mạc định cung cấp file Excel Marco sẵn). 
    * Sau khi Server chạy lại: Chuẩn bị tinh thần ngồi cọ mặt vào màn hình để sử dụng chức năng Dumper / Data Import Tool nạp ngược lại dữ liệu thủ công từ hàng trăm file Excel lên Cloud MES.

### Case 9.3: Sự cố Bảo mật và Virus lây chéo qua USB từ máy CNC
* **Tình huống:** Trạm điều khiển máy dập/CNC dưới xưởng PC tự nhiên đơ cứng xoay vòng, mở trình duyệt lên bị dính trang quảng cáo liên tục hoặc văng hộp thoại tống tiền Bitcoin (Ransomware), CPU treo 100%. Tín hiệu từ PLC lên MES đứt hoàn toàn.
* **Nguyên nhân:** Kỹ sư thiết kế hoặc thợ máy dùng USB cá nhân cắm vô máy tính từ xưởng để copy bản vẽ CAD / mã G-Code. Khuyến mãi thêm Virus làm sập máy trạm. Virus lan dần qua mạng LAN ngắm vào Data MES.
* **Cách xử lý:** 
    * Phản xạ 5 giây đầu: Rút phăng dây cáp LAN vật lý của máy dính độc khỏi Router ngay lập tức để ngắt nó khỏi hệ sinh thái nhà máy.
    * Kéo 1 PC Sơ cua (Backup Workstation) thay thế cắm dây USB Barcode vào setup lại ngay cho Line kịp chạy. 
    * Hành động dài hạn (SOP IT): Force Update Group Policy Server (AD) khóa quyền Read/Write USB, bịt keo silicon cổng USB trên thân máy cây, chỉ chừa port kết nối thiết bị.

---

## NHÓM 10: VĂN HÓA NGƯỜI DÙNG VÀ ĐÀO TẠO (User Culture & Training)

### Case 10.1: Sự kháng cự và chống đối (Resistance to Change - Bắt lỗi MES)
* **Tình huống:** Cả tháng nay, cứ 3 giờ chiều là anh X lên báo hỏng hệ thống MES, chửi ứng dụng văng "System Error" làm trễ KPI lượng làm việc. Lôi giấy ra viết tay rồi nhờ Leader ký xin bypass (Nhảy bước).
* **Nguyên nhân:** Hệ thống MES kiểm soát Cycle Time (Đếm thời gian chu kỳ sản phẩm) chính xác từng giây. Nó triệt tiêu thời gian gian lận đi "hút thuốc" hoặc ngồi lướt TopTop của một số công nhân. Công nhân này cố tình (Soft-sabotage): Gõ sai mã, quét 2 lần liên tục, rút lỏng dây mạng cho màn hình báo đứt kết nối để đổi thừa "tại phần mềm".
* **Cách xử lý:** 
    * Bật chức năng Action Logger "Audit Trail / User Activity Log Level Debug" truy nguyên mọi vết bấm chuột, thời gian chênh lệch. 
    * Trích xuất Camera an ninh (CCTV) tại khu vực đó để khớp với nhật ký số Data Log. Khi đủ thời gian/thao tác (VD: thấy công nhân vung súng bắn cố tình vào sai Barcode ngoài rìa nhãn). Xuất báo cáo gửi cho Trưởng Xưởng và QA phân xử kỷ luật. "Phần mềm không thể tự hư lỗi được".

### Case 10.2: Chia sẻ thông tin và mượn Thẻ Quẹt (Credential Sharing)
* **Tình huống:** Khách hàng QA xuống Audit xưởng điện tử, màn hình máy trạm báo người lắp ráp công đoạn 3 tên "Nguyễn Thị A" với giấy phép Kỹ thuật Hàn Level 3. Nhưng khách kiểm tra bảng tên người thật đang ngồi làm đó là anh Lao động thời vụ. Khách hàng bật báo động đỏ phạt Minor Report.
* **Nguyên nhân:** Máy tính trạm duy trì phiên đăng nhập Login vô tận (hoặc thẻ ID ai nhét chả được). Nhân viên xịn đi uống nước / hoặc chưa lấy thẻ được, quăng thẻ cho công nhân dưới quyền nhét vô khe đọc (RFID/Smart Card) để Log-in thao tác thế vào định mức.
* **Cách xử lý:** 
    * Kỷ luật Leader quản lý vì ko đi Line thường xuyên.
    * Gửi request lên đội C&A (Control & Access) Team: Setup tính năng Timeout Auto-Logout (Nếu màn hình đứng im quá 10 phút, tự văng ra màn hình nhập Pass). Gắn chuỗi dây đeo thẻ không được phép tháo rời cổ. Xịn hơn thì làm hệ thống FaceID Login / Vân tay tại các chỗ ráp nguy hiểm. 
    * Trích xuất Tool Data: Đảo số lượng sản phẩm làm trong khung giờ sai đó trả về cho mã thẻ đúng. 

### Case 10.3: Mù thông báo và căn bệnh "Văng Vào Enter" (Fatigue Alarms)
* **Tình huống:** Popup hộp thoại hiện lên to đùng trên màn hình màu vàng viền đỏ, ghi: *"Cảnh Báo: Bạn đang chuẩn bị Xóa Lệnh Sản Xuất toàn bộ Model. Số lượng sẽ Reset về Không [0]. Bạn chắc chắn CÓ / KHÔNG?"*. Công nhân không nhìn màn hình, thao tác phản xạ nhấp luôn chuột trái vào dấu `[CÓ] / [OK]`. Data bốc hơi sập chuyền xưởng.
* **Nguyên nhân:** Nhìn một giao diện cảnh báo hiển thị cả ngày cả tháng liên tục mỗi khi chuyển mã (Alarm Fatigue). Dẫn tới hội chứng phản xạ cơ bắp, cứ cái bảng nhảy lên khỏi màng hình là ngón tay người ta tự bấm Enter, không thèm nghĩ hay phân tích một chút nào.
* **Cách xử lý:** 
    * Lỗi này do người nhưng "Nguyên Nhân Gốc Rễ phần lớn là do Thiết Kế UX Của Hệ Thống kén người dùng".
    * Giải pháp: Các hành vi Delete, Void, End, Scrap... KHÔNG ĐƯỢC CHỈ ĐỂ NÚT BẤM. Bắt buộc: 
      - Hoặc đổi sang form nhập chữ: *"Vui lòng nhập số "1234" để xác nhận thao tác của bạn"*
      - Hoặc yêu cầu quét lại mã Thẻ Thẩm Quyền (Leader Badge) để bypass. 
      - Đổi nút nguy hiểm sang Góc trái thay vì Center để tay họ với con trỏ khó hơn.

---

## NHÓM 11: LỖI ĐIỀU ĐỘ QUẢN LÝ / CHÊNH LỆCH DỮ LIỆU TỒN KHO TỔNG (Planning & ERP Gap)

### Case 11.1: Trưởng kho lên kế hoạch nhầm Version của Lệnh (Wrong BOM Rev)
* **Tình huống:** Lệnh sản xuất là ráp Bơm Nước model nội địa. Máy Test cuối chuyền tự động kết nối TCP/IP vào Server lấy thông số cấu hình điện áp chạy. Mới lấy về vặn Test phát thì cháy máy đen khói. 
* **Nguyên nhân:** Nhân viên kế hoạch (Planner) tải lịch sản xuất từ ERP xuống thả Version nhầm BOM Châu Âu chạy điện 110V. MES là thằng ở giữa rất ngoan ngoãn: lấy đúng spec tải từ hệ thống ERP mẹ nạp vô cho máy Test dưới line. Kết cục là bòm.
* **Cách xử lý:** 
    * Khắc phục bằng rào cản kỹ thuật (Poka-Yoke): Hệ thống MES phải ép "Quy trình First Article Inspection" (Mô phỏng Mẫu Đầu Tiên). Nghĩa là Con Hàng đầu tiên trên Line phải do đích thân Trưởng nhóm hoặc thanh tra QA dùng tài khoản của mình scan pass qua các trạm (kèm ảnh chụp) để xác nhận Setup chuẩn. Sau đó nút "Start Line Mass Production - Thả chạy dây chuyền" mới có tác dụng (Activate). Không bao giờ được mở lỏng cho xưởng tự do.

### Case 11.2: Vênh kho ảo API - Hệ nhị phân hai cuốn sổ
* **Tình huống:** Gần hết linh kiện, hệ thống Cảnh báo Andon réo gào Tổ Kho mang xe nâng chở ra 10 Pallete Thép cuộn. Công nhân kho scan súng trên tay vô mã lô chíp Barcode nháy tít: `Lỗi. Cảnh Báo: Tồn kho trên MES không tồn tại hoặc < Số lượng cần nạp`. Tổ Kho quát lớn: "Thép cả đống đứng sờ sờ chình ình xe Nâng đây bộ System hệ thống mù hả?". Cả bên cãi nhau.
* **Nguyên nhân:** Vừa hôm qua thôi, Bộ phận Logistic làm một thao tác Cấn trừ (Inventory Re-adjustment / Material Transfer) trong nội dung bảng tính của cha đẻ nó là SAP ERP. Trong lúc API truyền Interface từ SAP nhảy gửi tín hiệu sang cắm cục Data Cache Sync bên MES thì API lăn ra đứt Server (Dead Message Queue). Cuốn sổ DB của EA chưa được cập nhật số mới từ Kế Toán.
* **Cách xử lý:** 
    * Kỹ sư EA phải chạy về màn hình Administration Panel / Sync Logger. 
    * Bấm tìm chuỗi "Failed Queue Transaction" hoặc Job Background đang đứt. Nhấn `Re-run` hoặc `Reprocess Message` để bơm lại dữ liệu bằng cú "thọc sườn" tay. Ngay lập tức màn hình của Tổ Kho nhảy đủ lượng Tồn (Stock-On-Hand). Line tiếp tục nhả hàng.

### Case 11.3: "Sát Thủ Report" của phòng Kế Toán / Giám Đốc làm gãy Data
* **Tình huống:** Cứ sáng mùng 1 đầu tháng, cả dây chuyền từ line 1 đến line 8 mỗi lúc quẹt lệnh Barcode là quay cái vòng tròn Loading lag 5 đến 7 giây chờ lưu. Ai cũng than thở server lỗi. 
* **Nguyên nhân:** Không lỗi cái gì cả! Đó là giờ bà Trưởng Phòng Kế Toán/ Giám đốc bật máy tính lên, bấm vào cái Menu `[Report Tổng Hợp]`. Chọn điều kiện lọc: *Từ Ngày 01.01.2021 đến 31.12.2026*, bấm nút *`[Xuất File Excel Download Toàn Bô Giao Dịch Ra Nào]`*. 
* Bùm! Câu truy vấn (Query) Data khổng lồ đó chiếm mẹ nó 100% tài nguyên Memory CPU, Lock Row lại đi đếm, dẫn tới các lệnh Insert bé xíu 1kb của hàng trăm công nhân xưởng bên dưới bị Block đợi cổ dài như hươu.
* **Cách xử lý:** 
    * Phản xạ ngay tại rốn Data: Người quản trị Database (DBA/EA) chui vô Sql Server chạy lệnh `sp_who2` xem cái process Session nào thao túng, lấy mã ID đó `KILL Id` lập tức cho Line xưởng có đường chạy. Kệ bà mạng bị báo lỗi truy vấn.
    * Giải pháp đường dài (Architecture): Lên phàn nàn chửi thẳng mặt Developer (Dev team): Báo Cáo Truy Xuất thì phải đổ sang Server Phụ Cụm DataWarehouse (Read Replica). Chỉ cho phép "Các sếp" đọc báo cáo bên DB phụ đó. Không bao giờ cho bà Kế toán Query lệnh khủng vào chung cùng 1 Bảng Database Write - Master DB (nơi công nhân đang dùng tốc độ phần nghìn Mili giây). Cộng thêm Limit Block Query: Ai filter Date quá 7 ngày là bắt ép xuất File Async chạy ngầm rồi Gửi Link Download qua Email sau.

---

## 🔥 BÍ TÍP XƯƠNG MÁU "3 BƯỚC KHẮC PHỤC DỨT ĐIỂM" DÀNH CHO EA

1. **"Làm lại từ đầu cho anh xem":** Hãy luôn yêu cầu User tái hiện từng Click chuột (Reproduce Steps) ở đúng chỗ họ gây lỗi chứ đừng nghe họ kể lại qua diện thoại. 90% nguyên do sẽ lòi ra do họ bỏ qua SOP quy trình.
2. **Kỹ năng Check "Đồ Đo Lường" (Network/Logs):** Đừng bao giờ chỉ nhìn mỗi giao diện MES màu đỏ chữ báo "Error". Bạn phải là người nhạy bén bật F12 (Google Chrome Net) đối với ứng dụng web, mở Event Viewer / File Server Log với phần mềm Win. Để chụp ngay trực tiếp mã lỗi thực sau Data (VD: `Timeout 504`, Database trả chuỗi `Is null`, hay Request URL cấu hình sai do VPN gãy?).
3. **Phân biệt rạch ròi LỖI QUY TRÌNH và LỖI KỸ THUẬT PHẦN MỀM:**
   * User bấm sai Logic, hệ thống Cấm và đưa Red Screen -> **Quy trình User yếu**, hệ thống đã Catch được. Báo cáo Line Leader đi đào tạo lại User.
   * User làm đúng từng bước 1 nhưng ứng dụng Không Ghi Nhận, Data không nhảy -> **Phần mềm BUG Tester lọt / DB Architecture bị lỗi**, EA mới phải lao vào Support và fix. Tuyệt đối cấm chỉnh Database Table trực tiếp vì áp lực KPI hay Line Leader khóc lóc nếu chưa xin phép/thông qua Developer.
