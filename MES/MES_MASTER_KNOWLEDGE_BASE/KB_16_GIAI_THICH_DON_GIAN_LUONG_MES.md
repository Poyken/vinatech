# BẢN DỊCH BÌNH DÂN: HIỂU SƠ ĐỒ LUỒNG DỮ LIỆU MES TRONG 5 PHÚT

> **Dành cho ai?** Tài liệu này dành cho bất kỳ ai (kể cả không biết IT hay Database) muốn hiểu hệ thống NAIS MES đang làm cái trò gì dưới xưởng.
> **Cách đọc:** Hãy tưởng tượng luồng MES giống như **Quy trình mở một Tiệm Bánh Tráng Trộn Sinh Viên.**

---

## GIAI ĐOẠN 0: GIAO THỨC TỪ TỔNG CÔNG TY (Phase 0 - Master Data)
*Tưởng tượng:* Bạn chuẩn bị khai trương tiệm bánh tráng.

*   **Hệ thống ERP (Kế toán tổng):** Đây là Ông chủ lớn trên trụ sở. Ông ấy gửi cho bạn 2 cuốn sổ:
    1.  **Sổ Nguyên Liệu (M_Materials):** Danh sách các món ăn (Bánh tráng, Xoài, Bò khô, Lạc rang...).
    2.  **Sổ Công Thức (M_BOMs):** Dạy bạn 1 suất bánh tráng thì cần 100g bánh, 20g xoài, 10g bò khô. (Chính là cái gọi là `BomVersion`).
*   **Hành động của MES:** MES lấy 2 cuốn sổ này cất vào tủ sắt (`Cấu Hình Master Data`) để làm thước đo chuẩn mực không ai được làm sai.

---

## GIAI ĐOẠN 1: NHẬN CHỈ TIÊU BÁN HÀNG BẮT BUỘC (Phase 1 - Lệnh Sản Xuất)
*Tưởng tượng:* Sáng sớm, Quản lý giao chỉ tiêu bán hàng trong ngày.

*   **PO Tháng (B310):** Chỉ tiêu tháng này phải bán được 30.000 bịch bánh tráng.
*   **Kế hoạch Ngày (B450 - Kế hoạch Ca):** Chia nhỏ ra, Cửa hàng số 1 (Line 1) ca sáng hôm nay (Shift 1) phải làm xong 1.000 bịch.
*   **⚠️ CÚ CHỐT QUAN TRỌNG NHẤT (`Nút FixDayPlan`):** 
    Quản lý vạch nếp xong phải **Ký Tên Đóng Dấu Chốt Sổ (IsFixed = True)**. Nếu quản lý quên ký, nhân viên bên dưới tuyệt đối không được phép luộc trứng hay thái xoài. (Máy quét dưới xưởng sẽ văng lỗi *Plan is locked*).

---

## GIAI ĐOẠN 2: ĐI CHỢ NHẬP NGUYÊN LIỆU (Phase 2 - Kho NVL)
*Tưởng tượng:* Xe tải ba gác chở Bánh Tráng, Xoài, Bò khô tới trước cửa tiệm.

*   **Bơm vào kho (F330):** Bạn không vác cả bao tải 50kg bò khô ném vào bếp. Bạn lấy túi zip chia nhỏ ra mỗi túi 1kg. Dán lên mỗi túi zip một tờ giấy ghi ID: "Bò Khô - Lô 01". (Đây chính là quá trình **Tạo Mã Barcode nhỏ (`M_Lots`)**).
*   **⚠️ CÚ CHỐT SỐNG CÒN (Đặc Tính 10):** 
    Lúc dán tem, bạn **BẮT BUỘC phải ghi Hạn Sử Dụng (VD: Hết hạn ngày 30/12)**. Nếu bạn quên ghi ngày ném sổ, túi bò khô đó lập tức bị "Bảo vệ" ném vào phòng Giam Lỏng (kho `Holding`). Tuyệt đối cấm mang vào bếp!
*   **Thử Độc (C220 - IQC):** Quản lý chất lượng nếm thử miếng bò mốc không? Ngon (Pass) thì cho lên kệ. Dở (Fail) thì trả lại thằng bán.
*   **Nhập Bếp (F430 - Move Inventory):** Xách cái túi Zip 1kg Bò khô đó từ "Kho Ngoài" (`SubInv: Main`) ném vào "Bàn Bếp" (`SubInv: Line`) để chuẩn bị trộn.

---

## GIAI ĐOẠN 3: BẾP TRƯỞNG TRỘN BÁNH VÀ SỰ TÍCH CẤN TRỪ KHO (Phase 3 - Sản Xuất & Tự Kiểm)
*Tưởng tượng:* Quá trình trộn bánh tráng thực tế của Bếp trưởng. (Trái tim của hệ thống MES, nơi dữ liệu dao động dữ dội nhất).

*   **Bắt đầu làm (B540 - Quét mã sinh Lệnh):** 
    Bếp trưởng xách túi Bò Khô 1kg đó ra, lấy "súng bắn bill" tít một phát vào mã vạch trên túi zip. 
    Lúc này, hệ thống sẽ khai sinh ra một chiếc Nồi Trộn Ảo (phần mềm gọi là `W_WIPLots` - Lot Bán Thành Phẩm). Cái nồi này được dán nhãn: **"Đang làm Bịch Bánh Tráng Số 001. Trạng thái: ĐANG NẤU (Run)"**.

*   **⚠️ CÚ PHÉP THUẬT QUAN TRỌNG NHẤT: BACKFLUSH (Cấn trừ tồn kho tự động):**
    Ngay khi tiếng "tít" vang lên, một bóng ma vô hình trong máy tính (gọi là `SP_CONSUME`) sẽ lôi cuốn **Sổ Công Thức (BomVersion)** ra dò.
    *   Sổ ghi: "1 suất hao 10g Bò khô".
    *   Bóng ma sẽ chạy thẳng vào hệ thống máy tính của cái túi Zip Bò khô 1kg kia... nó tự động dùng bút tẩy con số 1000g đi, viết lại thành **990g**. 
    *   => *Đó chính là Backflush! Công nhân không cần phải tự chép tay sổ kho báo "hôm nay tôi xài hết 10g", máy tính đã trừ nợ dùm họ một cách vô hình.*

*   **Kiểm tra Giữa Chiều (B597 - Bếp tự nếm):** 
    Bếp phó nếm thử xem mẻ bánh này vừa miệng chưa. Ghi vào sổ tay nội bộ của nhà bếp (Bảng dữ liệu này mang cờ `TEST`). 
    *Lưu ý: Cái này chỉ là bếp tự kiểm tra nhau cho yên tâm, không có giá trị pháp lý với cơ quan chức năng.*

*   **Khai Báo Phế Liệu (B530 - Báo Lỗi / Defect):** 
    Đang trộn thì bếp trưởng hắt xì hơi văng nước bọt vào nồi! Rất tiếc, cả mẻ bánh đó phải đổ sọt rác. 
    Lúc này thợ phải bấm nút "Khai Báo Lỗi" trên màn hình. Họ chọn mã lỗi C132: "Lỗi mất vệ sinh". Hệ thống sẽ trừ điểm KPI ca làm việc đó. 
    *(⚠️ Chú ý: Cuối giờ chiều, 10 thằng thợ cùng thi nhau bấm "Lưu Lỗi" 1 lúc, cửa hàng sẽ nghẽn mạng! Thợ IT gọi cái này là `Deadlock Table` do nghẽn cổ chai dữ liệu).*

*   **Thanh Tra Y Tế Gõ Cửa (C443 - PQC Độc Lập):** 
    Đây là thanh tra của Cục Vệ sinh An toàn thực phẩm (Phòng QC riêng biệt). Họ lấy mẫu mang về phòng Lab xét nghiệm vi khuẩn. Dữ liệu của họ lưu vào một cuốn sổ xịn có Mộc Đỏ (Cờ `QUALITY`).
    *   **Nếu Thanh tra bảo MẶN QUÁ (Fail):** Chiếc "Nồi Trộn 001" ngay lập tức bị cảnh sát niêm phong! Phần mềm đổi Trạng thái nhãn nồi thành **HOLD (Khóa/Giam lỏng)**. Không ai được quyền đụng vào nồi bánh này để mang đi đóng gói.
    *   **Nếu Thanh tra OK (Pass):** Nồi bánh dán mộc XANH, tiếp tục chờ đi sang phòng Đóng Hộp.

---

## GIAI ĐOẠN 4 & 5: ĐÓNG HỘP VÀ DÁN TEM BẢO HÀNH (Phase 4 & 5 - Đóng gói & Đầu ra)
*Tưởng tượng:* Nhét 50 bịch bánh nhỏ vào 1 cái Thùng Cartoon lớn giao Shipper.

*   **Tạo thùng bự (B523 - Đóng Packing):** Gom 50 bịch bánh con nhét vô 1 Thùng Carton bự. Máy sinh ra mã vạch bự, dán lên thùng (Barcode `Outer`).
*   **⚠️ LƯU Ý MỰC IN:** Luật của xưởng là tem Thùng Bự chỉ được phát ra duy nhất 1 lần để chống làm giả nhái. Máy in rách tem thì khóc ròng, phải gọi IT vào phá khóa (`Void`) mới in lại được.
*   **Khám nghiệm tử thi lần cuối (C530 - Đo 20 Params):** Thùng đóng xong, QC lôi ra đo cân nặng, đo độ mặn ngọt, độ giòn bề mặt (20 thông số). 
*   **⚠️ CÚ CHỐT VÀO KHO (EvaluateResult = OK):** Đo xong phải đóng dấu MỘC ĐỎ chữ "OK / NGON". Cột dữ liệu thiếu chữ OK này thì kho Thành phẩm (Bắc Ninh/Bắc Giang) kiên quyết không mở cửa cho xe tải đổ hàng vào. (Lệnh bị khóa `Hold_Line_FG`).

---

## GIAI ĐOẠN CỐT: XE TẢI LĂN BÁNH & THU TIỀN (Phase 6 - Kết xuất ERP)
*Tưởng tượng:* Shipper tới bốc thùng hàng đi giao.

*   **In tem ra đường (B453):** Dán cái mã bưu điện ngoài cùng lên Thùng Cartoon. Trên phần mềm phải đánh dấu Tick vô cái ô "Là Tem Ngoài" (`IsOuterPrinted`). Không tick ô này, ông bảo vệ cổng không cho ra.
*   **Thu tiền (Job Sync ERP):** Khi Thùng Cartoon bước qua khỏi cổng điện tử nhà máy, Hệ thống Tự Động Gửi 1 Vạn Tin Nhắn SMS (`Trigger Background Job`) bắn báo cáo về Kế Toán Trụ Sở. 
*   **Kết cục:** Kế toán nghe "Ting Ting" -> Xuất Hóa Đơn -> Đếm tiền. Cây gia phả Lô sản phẩm khép lại một kiếp luân hồi êm đẹp.
