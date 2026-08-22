// Data for all manual modules and slides
const MANUAL_DATA = [
  {
    "id": "sec-0",
    "part": "Phần 0",
    "partTitle": "Tổng Quan Giao Diện POP Kiosk",
    "partIcon": "🖥️",
    "topics": [
      {
        "slide": 7,
        "title": "Bố Cục Màn Hình POP Kiosk",
        "tag": "Layout Overview",
        "image": "assets/images/image19.png",
        "overview": "Hiển thị tổng thể bố cục 4 khu vực chính của màn hình POP Kiosk cảm ứng tại xưởng sản xuất.",
        "steps": [
          {"num": 1, "title": "Header (Thanh tiêu đề)", "desc": "Hiển thị tên công nhân hiện tại, ngày/giờ thực tế và tên dây chuyền sản xuất."},
          {"num": 2, "title": "Menu Quy trình (Process Menu)", "desc": "Danh sách các công đoạn của dây chuyền hiện tại. Chạm để chuyển đổi giao diện công đoạn."},
          {"num": 3, "title": "Thanh trạng thái thiết bị (Equipment Chip Bar)", "desc": "Hiển thị kết nối thời gian thực (Bình thường / Trì hoãn / Ngắt kết nối) của các thiết bị ngoại vi gắn với kiosk."},
          {"num": 4, "title": "Khu vực Chính (Main Work Area)", "desc": "Màn hình nghiệp vụ thay đổi theo quy trình đang được chọn."}
        ],
        "notes": "Nút chuyển đổi đa ngôn ngữ (KO / EN / VI) và công tắc Chế độ tối (Dark mode) nằm ở phía dưới cùng màn hình.",
        "calloutType": "note"
      },
      {
        "slide": 8,
        "title": "Chức Năng Chung Của Header",
        "tag": "Header Navigation",
        "image": "assets/images/image20.png",
        "overview": "Giải thích các tính năng điều khiển dùng chung được bố trí trên thanh Header.",
        "steps": [
          {"num": 1, "title": "Ngày và Giờ", "desc": "Ngày và giờ hiện tại hiển thị theo thời gian thực của máy chủ."},
          {"num": 2, "title": "Tên Dây chuyền", "desc": "Chạm để thay đổi dây chuyền sản xuất. Lưu ý: Thay đổi dây chuyền sẽ đặt lại (reset) lệnh sản xuất hiện tại."},
          {"num": 3, "title": "Tên Công nhân", "desc": "Chạm để đổi người vận hành khác."}
        ],
        "notes": "Sử dụng nút Làm mới (↻) ở góc phải header để tải lại dữ liệu mới nhất từ hệ thống máy chủ MES.",
        "calloutType": "tip"
      }
    ]
  },
  {
    "id": "sec-1",
    "part": "Phần 1",
    "partTitle": "Bắt Đầu Ca Làm Việc",
    "partIcon": "🚀",
    "topics": [
      {
        "slide": 10,
        "title": "Chọn Công Nhân (Đăng Nhập)",
        "tag": "Worker Select",
        "image": "assets/images/image21.png",
        "overview": "Đăng ký thông tin công nhân trước khi bắt đầu thực hiện các thao tác sản xuất.",
        "steps": [
          {"num": 1, "title": "Chuyển đổi Công ty", "desc": "Chọn Trụ sở chính (Vinatech) hoặc Chi nhánh."},
          {"num": 2, "title": "Chọn Phòng ban", "desc": "Chọn phòng ban làm việc tại danh mục cây bên trái."},
          {"num": 3, "title": "Chọn Nhân viên", "desc": "Chạm vào thẻ tên nhân viên của bạn ở danh sách bên phải."},
          {"num": 4, "title": "Xác nhận chọn", "desc": "Tên công nhân đăng ký thành công sẽ hiển thị ngay trên thanh Header."}
        ],
        "notes": "Nếu bạn có thẻ nhân viên in mã QR, bạn có thể quét bằng máy đọc mã vạch (barcode reader) để đăng nhập tức thì mà không cần tìm thủ công.",
        "calloutType": "tip"
      },
      {
        "slide": 11,
        "title": "Chọn Dây Chuyền Sản Xuất",
        "tag": "Line Select",
        "image": "assets/images/image22.png",
        "overview": "Chọn dây chuyền sản xuất bạn sẽ trực tiếp vận hành.",
        "steps": [
          {"num": 1, "title": "Chọn Nơi làm việc (WorkCenter)", "desc": "Chọn xưởng / nơi làm việc từ danh sách bên trái."},
          {"num": 2, "title": "Chọn Dây chuyền", "desc": "Chạm chọn dây chuyền bạn sẽ đứng máy từ danh sách bên phải."},
          {"num": 3, "title": "Xác nhận", "desc": "Khi chọn chuyền thành công, tên dây chuyền sẽ hiển thị lên thanh Header."}
        ],
        "notes": "CẢNH BÁO: Thay đổi dây chuyền sau khi đã tải lệnh sản xuất sẽ xóa và đặt lại dữ liệu phiên làm việc hiện tại.",
        "calloutType": "warning"
      },
      {
        "slide": 12,
        "title": "Chọn Ngày Sản Xuất (Lịch)",
        "tag": "Calendar",
        "image": "assets/images/image23.png",
        "overview": "Chọn ngày làm việc để tìm kiếm và nạp các lệnh sản xuất theo lịch kế hoạch.",
        "steps": [
          {"num": 1, "title": "Điều hướng Tháng", "desc": "Sử dụng nút ◀ ▶ để di chuyển đến tháng trước hoặc tháng sau."},
          {"num": 2, "title": "Chọn Ngày", "desc": "Chạm vào ngày làm việc. Ngày hôm nay được hệ thống tự động chọn mặc định."},
          {"num": 3, "title": "Tóm tắt Thực hiện", "desc": "Số lượng Kế hoạch / Đạt / Lỗi cho ngày đã chọn hiển thị ở thanh phía dưới."}
        ],
        "notes": "Con số nhỏ bên dưới mỗi ô ngày biểu thị số lượng lệnh sản xuất (DayPlan) của ngày đó.",
        "calloutType": "note"
      },
      {
        "slide": 13,
        "title": "Chọn Lệnh Sản Xuất (Work Order / DayPlan)",
        "tag": "Work Order Select",
        "image": "assets/images/image25.png",
        "overview": "Chọn lệnh sản xuất để bắt đầu nạp danh sách LOT cần gia công.",
        "steps": [
          {"num": 1, "title": "Số Lệnh Sản Xuất", "desc": "Mã DayPlan duy nhất của đợt sản xuất."},
          {"num": 2, "title": "Thông tin Sản phẩm", "desc": "Xác minh mã và tên sản phẩm cần sản xuất."},
          {"num": 3, "title": "Kiểm tra Số lượng", "desc": "Xác nhận số lượng kế hoạch và tổng số LOT."},
          {"num": 4, "title": "Chọn dòng", "desc": "Chạm vào dòng lệnh sản xuất để hệ thống tự động tải toàn bộ danh sách LOT."}
        ],
        "notes": "Quét trực tiếp mã vạch trên phiếu LOT bằng đầu đọc scanner sẽ tự động tìm và tải đúng Lệnh sản xuất tương ứng.",
        "calloutType": "tip"
      },
      {
        "slide": 14,
        "title": "Menu Quy Trình & Danh Sách Thẻ LOT",
        "tag": "LOT List",
        "image": "assets/images/image26.png",
        "overview": "Chọn quy trình và theo dõi danh sách LOT trực quan dưới dạng thẻ (Cards).",
        "steps": [
          {"num": 1, "title": "Menu Quy trình", "desc": "Trình tự các công đoạn của dây chuyền hiển thị bên trái; chạm để chuyển màn hình công đoạn đó."},
          {"num": 2, "title": "Quy trình Hoạt động", "desc": "Công đoạn đang xem được tô sáng viền nổi bật."},
          {"num": 3, "title": "Thẻ LOT", "desc": "Danh sách các LOT của lệnh sản xuất hiển thị dạng thẻ trực quan."},
          {"num": 4, "title": "Huy hiệu Trạng thái", "desc": "Hiển thị tiến độ của mỗi LOT: Chờ vật liệu / Đang tiến hành / Hoàn thành."}
        ],
        "notes": "Chạm vào bất kỳ thẻ LOT nào để hiển thị bảng làm việc và thông tin chi tiết ở khu vực bên phải.",
        "calloutType": "note"
      }
    ]
  },
  {
    "id": "sec-2",
    "part": "Phần 2",
    "partTitle": "Quy Trình Thao Tác Thủ Công",
    "partIcon": "⚙️",
    "topics": [
      {
        "slide": 16,
        "title": "Bố Cục Màn Hình Quy Trình Thủ Công",
        "tag": "Manual Process Layout",
        "image": "assets/images/image27.png",
        "overview": "Hiển thị bố cục tổng thể của màn hình gia công quy trình thủ công.",
        "steps": [
          {"num": 1, "title": "Danh sách LOT", "desc": "Cột trái hiển thị danh sách các thẻ LOT của Lệnh sản xuất đã chọn."},
          {"num": 2, "title": "Bảng LOT Hiện tại", "desc": "Thông tin LOT đang chọn kèm bàn phím số cảm ứng để nhập phế phẩm/lỗi."},
          {"num": 3, "title": "Thanh nút phía dưới", "desc": "Các nút thao tác chính: Nhập vật liệu · Đăng ký lỗi · Hoàn thành sản xuất."}
        ],
        "notes": "Giao diện được thiết kế với nút bấm kích thước lớn, dễ thao tác cảm ứng kể cả khi đeo găng tay bảo hộ.",
        "calloutType": "note"
      },
      {
        "slide": 17,
        "title": "Chọn Thẻ LOT Làm Việc",
        "tag": "Select LOT",
        "image": "assets/images/image28.png",
        "overview": "Chạm vào thẻ LOT để kích hoạt bảng điều khiển sản xuất cho LOT đó.",
        "steps": [
          {"num": 1, "title": "Thanh Lệnh SX", "desc": "Hiển thị Số lệnh / Tên sản phẩm / Ngày sản xuất."},
          {"num": 2, "title": "Thẻ LOT", "desc": "Chạm số LOT để chọn. Thông tin LOT sẽ mở ra ở bảng bên phải."},
          {"num": 3, "title": "Thanh Tiến trình", "desc": "So sánh trực quan giữa Kế hoạch và Thực tế cho công đoạn hiện tại."},
          {"num": 4, "title": "Huy hiệu Quy trình", "desc": "Ví dụ: 0/6 nghĩa là đã hoàn thành 0 trong tổng số 6 công đoạn của chu trình."}
        ],
        "notes": "Luôn kiểm tra đúng số LOT trước khi nhập vật tư hoặc phế phẩm.",
        "calloutType": "tip"
      },
      {
        "slide": 18,
        "title": "Truy Cập Nhập Vật Liệu (Bắt Buộc)",
        "tag": "Material Input Check",
        "image": "assets/images/image28.png",
        "overview": "Bắt buộc phải nhập vật liệu trước khi bắt đầu gia công hoặc hoàn thành LOT.",
        "steps": [
          {"num": 1, "title": "Nút Nhập vật liệu", "desc": "Nút màu cam ở góc dưới bên phải. Chỉ số (0/6) hiển thị số loại vật tư đã nhập / tổng số loại vật tư theo định mức BOM."}
        ],
        "notes": "QUY TẮC BẮT BUỘC: Nút 'Hoàn thành sản xuất' sẽ bị KHÓA (Disabled) cho đến khi toàn bộ vật liệu theo BOM được nhập đầy đủ!",
        "calloutType": "danger"
      },
      {
        "slide": 19,
        "title": "Nhập Vật Liệu — Chi Tiết Từng LOT",
        "tag": "Material Detail Input",
        "image": "assets/images/image29.png",
        "overview": "Nhập nguyên vật liệu đầu vào cho một LOT đơn lẻ.",
        "steps": [
          {"num": 1, "title": "Chọn LOT", "desc": "Chọn LOT mục tiêu cần cấp phát vật tư."},
          {"num": 2, "title": "Chọn Vật liệu", "desc": "Chạm vào thẻ vật tư trong danh sách bảng kê BOM."},
          {"num": 3, "title": "Nhập Số lượng", "desc": "Gõ số lượng xuất dùng và bấm Lưu. (Khi kết nối cân điện tử, số lượng/khối lượng được tự động điền từ cân)."}
        ],
        "notes": "Kiểm tra kỹ đơn vị tính (kg, chiếc, cuộn) trước khi lưu.",
        "calloutType": "tip"
      },
      {
        "slide": 20,
        "title": "Nhập Vật Liệu — Phân Phối Hàng Loạt (Batch Distribution)",
        "tag": "Batch BOM Distribution",
        "image": "assets/images/image31.png",
        "overview": "Cấp phát vật liệu cùng lúc cho nhiều LOT, hệ thống tự động phân chia theo tỷ lệ BOM.",
        "steps": [
          {"num": 1, "title": "Danh sách LOT", "desc": "Các LOT sử dụng chung loại vật liệu này sẽ hiển thị dạng thẻ."},
          {"num": 2, "title": "Tổng Số lượng", "desc": "Nhập tổng số lượng vật liệu xuất dùng bằng bàn phím số."},
          {"num": 3, "title": "Tự động Phân phối", "desc": "Tự động phân bổ theo tỷ lệ định mức BOM của từng LOT. Ví dụ: LOT 1 cần 7.28, LOT 2 cần 7.28 -> Nhập tổng 14.56 -> Hệ thống chia đều 7.28 cho mỗi LOT."}
        ],
        "notes": "Kiểm tra kết quả phân phối trước khi bấm 'Xác nhận nhập' để lưu toàn bộ cùng lúc.",
        "calloutType": "note"
      },
      {
        "slide": 21,
        "title": "Chọn Loại Lỗi / Phế Phẩm (Defect Type)",
        "tag": "Defect Selection",
        "image": "assets/images/image30.png",
        "overview": "Khai báo loại lỗi phát sinh trong quá trình sản xuất.",
        "steps": [
          {"num": 1, "title": "Nút Loại lỗi", "desc": "Chạm vào nút màu xanh lá ở góc dưới bên phải."},
          {"num": 2, "title": "Chọn Loại lỗi", "desc": "Chạm chọn thẻ loại lỗi phù hợp từ danh sách popup."},
          {"num": 3, "title": "Hoàn thành chọn", "desc": "Tên loại lỗi đã chọn sẽ hiển thị ngay ở đầu màn hình nhập số lượng."}
        ],
        "notes": "Chọn chính xác mã lỗi để phục vụ thống kê chất lượng và phân tích SPC của bộ phận QC.",
        "calloutType": "tip"
      },
      {
        "slide": 22,
        "title": "Nhập Số Lượng Lỗi & Đăng Ký (Defect Register)",
        "tag": "Defect Qty Input",
        "image": "assets/images/image32.png",
        "overview": "Gõ số lượng lỗi và bấm nút Đăng ký vào hệ thống.",
        "steps": [
          {"num": 1, "title": "Hiển thị Loại & Số lượng", "desc": "Xem loại lỗi đã chọn và số lượng đang gõ trên màn hình hiển thị."},
          {"num": 2, "title": "Bàn phím Số", "desc": "Gõ số lượng lỗi phát sinh bằng bàn phím cảm ứng."},
          {"num": 3, "title": "Chạm Đăng ký", "desc": "Bấm nút Đăng ký. Hệ thống ghi nhận và tự động reset về 0 để sẵn sàng cho lần nhập tiếp theo."}
        ],
        "notes": "Nút Đăng ký sẽ bị vô hiệu hóa nếu chưa chọn loại lỗi hoặc số lượng đang bằng 0.",
        "calloutType": "warning"
      },
      {
        "slide": 23,
        "title": "Hoàn Thành Đăng Ký Sản Xuất",
        "tag": "Complete Production",
        "image": "assets/images/image33.png",
        "overview": "Kết thúc ca/LOT làm việc sau khi đã hoàn tất nhập vật liệu và các loại lỗi.",
        "steps": [
          {"num": 1, "title": "Nút Hoàn thành Sản xuất", "desc": "Chạm nút để kết thúc công việc của LOT hiện tại."},
          {"num": 2, "title": "Popup Xác nhận", "desc": "Kiểm tra lần cuối: Dây chuyền / Tên công nhân / Sản phẩm / Sản lượng đạt và lỗi."},
          {"num": 3, "title": "Sau Xác nhận", "desc": "Trạng thái LOT chuyển thành Hoàn thành (Completed) và tự động chuyển chọn sang LOT tiếp theo."}
        ],
        "notes": "Nút này sẽ bị khóa nếu chưa nhập đầy đủ vật liệu đầu vào theo BOM.",
        "calloutType": "danger"
      },
      {
        "slide": 24,
        "title": "Menu Thêm (Nút ⋯) & Kiểm Tra BOM",
        "tag": "Extra Menu & BOM",
        "image": "assets/images/image34.png",
        "overview": "Truy cập các tính năng nâng cao: Tái phân loại (Re-sorting) và Tra cứu định mức BOM.",
        "steps": [
          {"num": 1, "title": "Nút ⋯ (Menu Thêm)", "desc": "Nằm ở góc dưới cùng bên phải. Chạm vào để mở chức năng Tái phân loại (trích xuất sản phẩm đạt từ LOT lỗi)."},
          {"num": 2, "title": "Nút Kiểm tra BOM", "desc": "Nằm ở góc trên phải danh sách LOT. Cho phép xem vật liệu nhập, số lượng định mức yêu cầu và đơn vị tính."}
        ],
        "notes": "Công nhân có thể đối soát BOM bất kỳ lúc nào nếu nghi ngờ sai sót mã vật tư.",
        "calloutType": "tip"
      }
    ]
  },
  {
    "id": "sec-3",
    "part": "Phần 3",
    "partTitle": "Đóng Gói & Đóng Gói Gộp",
    "partIcon": "📦",
    "topics": [
      {
        "slide": 27,
        "title": "Vào Quy Trình Đóng Gói & Điều Kiện",
        "tag": "Enter Packing",
        "image": "assets/images/image37.png",
        "overview": "Chuyển sang công đoạn Đóng gói trên Menu quy trình.",
        "steps": [
          {"num": 1, "title": "Chạm Đóng gói", "desc": "Chạm mục Đóng gói trong Menu quy trình bên trái để mở màn hình đóng gói."}
        ],
        "notes": "ĐIỀU KIỆN HIỂN THỊ: Chỉ những LOT đã hoàn thành 100% tất cả các quy trình sản xuất trước đó mới hiển thị trên màn hình đóng gói!",
        "calloutType": "warning"
      },
      {
        "slide": 28,
        "title": "Bố Cục Màn Hình Đóng Gói & Cài Đặt Box",
        "tag": "Packing Screen Layout",
        "image": "assets/images/image38.png",
        "overview": "Thực hiện đóng gói đơn lẻ theo 3 bước chuẩn.",
        "steps": [
          {"num": 1, "title": "Bước 1: Chọn LOT", "desc": "Chạm LOT muốn đóng gói từ danh sách bên trái (hiển thị Có sẵn / Đã đóng / Còn lại)."},
          {"num": 2, "title": "Bước 2: Cài đặt Box", "desc": "Nhập số lượng sản phẩm mỗi hộp bằng bàn phím số (dùng << để xóa nếu nhầm)."},
          {"num": 3, "title": "Bước 3: Thực hiện Đóng gói", "desc": "Chạm nút 'Đóng gói' (PACK) để hoàn tất. Nút in nhãn sẽ tự động kích hoạt sau đó."}
        ],
        "notes": "Sử dụng nút 'Tìm Còn lại' và 'Đóng gói Gộp' ở khu vực giữa cho các trường hợp hàng lẻ cần ghép thùng.",
        "calloutType": "note"
      },
      {
        "slide": 31,
        "title": "Tìm LOT Còn Lại Từ Lệnh SX Khác (Find Remaining)",
        "tag": "Find Remaining",
        "image": "assets/images/image40.png",
        "overview": "Tìm kiếm các LOT lẻ cùng mã sản phẩm từ các Lệnh sản xuất khác để gom thùng.",
        "steps": [
          {"num": 1, "title": "Nút Tìm Còn lại", "desc": "Chạm nút Tìm Còn lại ở khu vực giữa."},
          {"num": 2, "title": "Kết quả tìm kiếm", "desc": "Danh sách các LOT cùng mã sản phẩm từ các Lệnh sản xuất (DayPlan) khác sẽ hiển thị."},
          {"num": 3, "title": "Thêm LOT", "desc": "Chạm nút 'Thêm' trên LOT mong muốn để nạp vào danh sách chờ đóng gói hiện tại."}
        ],
        "notes": "LOT gốc hiển thị theo định dạng chuẩn; LOT thêm từ ngoài sẽ được phân biệt bằng nhãn/màu sắc riêng biệt để dễ nhận biết.",
        "calloutType": "tip"
      },
      {
        "slide": 33,
        "title": "Đóng Gói Gộp Nhiều LOT (Merge Packing)",
        "tag": "Merge Packing Multi-LOT",
        "image": "assets/images/image42.png",
        "overview": "Gom nhiều LOT vào chung một Thùng (Box) duy nhất.",
        "steps": [
          {"num": 1, "title": "Kích hoạt Gộp", "desc": "Chạm nút 'Đóng gói Gộp' để chuyển sang chế độ chọn nhiều checkbox."},
          {"num": 2, "title": "Chọn LOT", "desc": "Tích chọn các LOT cần đóng gói chung (Bắt buộc chọn ít nhất 2 LOT)."},
          {"num": 3, "title": "Số lượng Tổng hợp", "desc": "Màn hình tự động tính và hiển thị tổng số lượng khả dụng của các LOT đã chọn."}
        ],
        "notes": "Cần chọn tối thiểu 2 LOT để thực hiện chế độ đóng gói gộp.",
        "calloutType": "warning"
      },
      {
        "slide": 34,
        "title": "Cơ Chế Trừ Số Lượng Đóng Gói Gộp (FIFO)",
        "tag": "Merge Quantity Deduction",
        "image": "assets/images/image43.png",
        "overview": "Số lượng đóng gói gộp được hệ thống tự động trừ tuần tự từ trên xuống dưới theo nguyên tắc FIFO.",
        "steps": [
          {"num": 1, "title": "Ví dụ thực tế", "desc": "LOT 1: 20 cái, LOT 3: 20 cái, LOT 4: 20 cái (Tổng: 60 cái)."},
          {"num": 2, "title": "Nhập đóng gói 50 cái", "desc": "Hệ thống sẽ trừ: LOT 1 trừ 20 (hết), LOT 3 trừ 20 (hết), LOT 4 trừ 10 (còn dư 10)."},
          {"num": 3, "title": "Hoàn tất", "desc": "Mã số LOT đóng gói / Box ID mới được tạo ra và có thể in tem ngay."}
        ],
        "notes": "Cơ chế FIFO đảm bảo hàng sản xuất trước sẽ được xuất đóng thùng trước.",
        "calloutType": "note"
      },
      {
        "slide": 35,
        "title": "Đóng Gói Liên Nhà Máy — Chọn Kho Đích (Mới v1.1)",
        "tag": "Cross-plant Packing",
        "image": "assets/images/image44.png",
        "overview": "Chọn kho nhập hàng khi đóng gói LOT được sản xuất từ nhà máy khác.",
        "steps": [
          {"num": 1, "title": "Tự động phát hiện", "desc": "Hộp thoại xuất hiện tự động khi nhà máy sản xuất LOT khác với nhà máy của dây chuyền hiện tại."},
          {"num": 2, "title": "Chọn Kho", "desc": "Chọn kho tiếp nhận nơi hàng hóa sẽ được nhập về."},
          {"num": 3, "title": "Đóng gói", "desc": "Thực hiện đóng gói và ghi nhận dữ liệu vào kho đã chọn."}
        ],
        "notes": "Hộp thoại này sẽ không xuất hiện nếu đóng gói các LOT thuộc cùng nhà máy.",
        "calloutType": "tip"
      },
      {
        "slide": 36,
        "title": "In Nhãn Sau Đóng Gói (Nhãn LOT / Box) (Mới v1.1)",
        "tag": "Post-pack Label Print",
        "image": "assets/images/image45.png",
        "overview": "Sau khi đóng gói, công nhân có thể in nhãn LOT và nhãn Box cùng lúc.",
        "steps": [
          {"num": 1, "title": "Tab LOT / Box", "desc": "Chuyển đổi giữa 2 tab ở khu vực xem trước để kiểm tra hình dạng từng nhãn."},
          {"num": 2, "title": "Tùy chọn in", "desc": "Sử dụng hộp kiểm để chọn in Nhãn LOT, Nhãn Box hoặc cả hai."},
          {"num": 3, "title": "Điều chỉnh số bản in", "desc": "Tăng giảm số lượng bản in bằng nút − / + nếu cần và bấm 'In'."}
        ],
        "notes": "Xem trước cẩn thận quy cách tem trước khi bấm lệnh in.",
        "calloutType": "note"
      },
      {
        "slide": 37,
        "title": "Lịch Sử Đóng Gói — In Lại & Hủy Đóng Gói (Mới v1.1)",
        "tag": "Packing History & Cancel",
        "image": "assets/images/image46.png",
        "overview": "Tra cứu danh sách Box đã đóng, in lại tem bị mất hoặc hủy đóng gói để khôi phục số lượng.",
        "steps": [
          {"num": 1, "title": "Mở Lịch sử", "desc": "Chạm vào nút 'Lịch sử' để mở hộp thoại danh sách Box đã đóng."},
          {"num": 2, "title": "Danh sách Box", "desc": "Hiển thị Box ID, số lượng, ngày/giờ đóng và tên công nhân thực hiện."},
          {"num": 3, "title": "In lại Nhãn", "desc": "Chạm nút 'In' trên bất kỳ Box nào để in lại tem của Box đó."},
          {"num": 4, "title": "Hủy đóng gói từng Box", "desc": "Chạm nút 'Hủy' trên Box để hủy đóng gói và KHÔI PHỤC số lượng về lại LOT gốc."},
          {"num": 5, "title": "Hủy tất cả", "desc": "Chạm nút 'Hủy tất cả' ở trên cùng để hủy toàn bộ Box cùng lúc."}
        ],
        "notes": "Sau khi hủy, số lượng còn lại của LOT sẽ tự động được hoàn trả ngay lập tức.",
        "calloutType": "warning"
      }
    ]
  },
  {
    "id": "sec-4",
    "part": "Phần 4",
    "partTitle": "Tái Phân Loại (Re-sorting)",
    "partIcon": "🔄",
    "topics": [
      {
        "slide": 39,
        "title": "Truy Cập Chức Năng Tái Phân Loại",
        "tag": "Enter Re-sorting",
        "image": "assets/images/image47.png",
        "overview": "Vào chức năng Tái phân loại để trích xuất sản phẩm đạt (OK) từ các LOT bị ghi nhận lỗi.",
        "steps": [
          {"num": 1, "title": "Menu Thêm", "desc": "Chạm nút ⋯ ở góc dưới cùng bên phải."},
          {"num": 2, "title": "Chọn Tái phân loại", "desc": "Chạm nút 'Tái phân loại' trong bảng menu mở ra."},
          {"num": 3, "title": "Điều kiện truy cập", "desc": "Bắt buộc phải chọn Lệnh sản xuất trước. Nếu chưa chọn, cảnh báo 'Vui lòng chọn lệnh sản xuất trước' sẽ xuất hiện."}
        ],
        "notes": "Chức năng này giúp cứu vãn sản lượng mà không làm sai lệch số liệu thống kê lỗi ban đầu.",
        "calloutType": "tip"
      },
      {
        "slide": 40,
        "title": "Tái Phân Loại — Tự Động Phân Phối Đều Theo Tỷ Lệ",
        "tag": "Auto Ratio Re-sort",
        "image": "assets/images/image48.png",
        "overview": "Nhập tổng số lượng cần tái phân loại, hệ thống tự động chia theo tỷ lệ lỗi còn lại của mỗi LOT.",
        "steps": [
          {"num": 1, "title": "Nhập Số lượng", "desc": "Nhập tổng số lượng đạt cần trích xuất tái phân loại."},
          {"num": 2, "title": "Phân phối Tự động", "desc": "Tự động phân bổ tỷ lệ thuận theo số lỗi của từng LOT. Ví dụ: LOT 1 (lỗi 20), LOT 2 (lỗi 10), nhập số lượng 25 -> LOT 1 trừ 13, LOT 2 trừ 12."},
          {"num": 3, "title": "Thực hiện", "desc": "Kiểm tra kết quả phân bổ và chạm nút 'Thực hiện'."}
        ],
        "notes": "Hệ thống hiển thị bản xem trước chi tiết trước khi bạn bấm thực hiện lưu.",
        "calloutType": "note"
      },
      {
        "slide": 41,
        "title": "Tái Phân Loại — Nhập Riêng Từng LOT",
        "tag": "Individual Re-sort",
        "image": "assets/images/image49.png",
        "overview": "Chỉ định số lượng trích xuất thủ công cho từng LOT cụ thể.",
        "steps": [
          {"num": 1, "title": "Nhập theo LOT", "desc": "Nhập trực tiếp số lượng vào ô nhập liệu của từng dòng LOT tương ứng."},
          {"num": 2, "title": "Kiểm tra Tổng", "desc": "Tổng số lượng trừ tự động hiển thị ở phía dưới."},
          {"num": 3, "title": "Thực hiện", "desc": "Lưu kết quả bằng nút thực hiện tái phân loại."}
        ],
        "notes": "Khi hoàn tất, một LOT Tái phân loại mới được tạo và số lượng đạt được tích lũy vào sản lượng. Số lượng lỗi không bị trừ mất mà được giữ lại làm lịch sử.",
        "calloutType": "tip"
      }
    ]
  },
  {
    "id": "sec-5",
    "part": "Phần 5",
    "partTitle": "In Nhãn Tem Mã Vạch",
    "partIcon": "🏷️",
    "topics": [
      {
        "slide": 43,
        "title": "Truy Cập Màn Hình In Nhãn",
        "tag": "Label Print Entry",
        "image": "assets/images/image50.png",
        "overview": "In tem nhãn mã vạch dán lên LOT sản xuất hoặc thùng đóng gói đã hoàn thành.",
        "steps": [
          {"num": 1, "title": "Nút In Nhãn", "desc": "Nằm ở góc trên bên phải màn hình lắp ráp hoặc phía dưới màn hình đóng gói."},
          {"num": 2, "title": "Mở Popup", "desc": "Chạm vào nút để mở hộp thoại in nhãn chuyên dụng."}
        ],
        "notes": "Kiểm tra kết nối máy in trước khi thực hiện.",
        "calloutType": "note"
      },
      {
        "slide": 44,
        "title": "Chọn LOT & Loại Nhãn In",
        "tag": "Label Type & Format",
        "image": "assets/images/image51.png",
        "overview": "Chọn LOT và loại tem nhãn cần in.",
        "steps": [
          {"num": 1, "title": "Chọn LOT", "desc": "Chạm chọn các LOT cần in (có thể chọn nhiều LOT hoặc bấm 'Chọn tất cả')."},
          {"num": 2, "title": "Loại Nhãn Gợi Ý", "desc": "Loại tem nhãn phù hợp với sản phẩm được hệ thống tự động đề xuất (có dấu sao ⭐)."},
          {"num": 3, "title": "Thông số & MaterialNo", "desc": "Định dạng nhãn áp dụng tự động theo Item. Có thể chỉnh sửa trực tiếp MaterialNo (tên vật tư) trước khi in nếu cần."}
        ],
        "notes": "Kiểm tra kỹ thông tin sản phẩm và quy cách tem trên bản xem trước.",
        "calloutType": "tip"
      },
      {
        "slide": 45,
        "title": "Thực Hiện In & Xem Trước",
        "tag": "Print Execution",
        "image": "assets/images/image51.png",
        "overview": "Xác minh bản xem trước tem thực tế và gửi lệnh in ra máy in.",
        "steps": [
          {"num": 1, "title": "Số tờ In", "desc": "Tổng số tem cần in được tự động tính toán theo số LOT đã chọn."},
          {"num": 2, "title": "Xem trước (Preview)", "desc": "Xem trước hình dạng thực tế của nhãn (mã vạch, số LOT, thông số) trước khi in."},
          {"num": 3, "title": "Nút In", "desc": "Chạm nút In để xuất nhãn trên máy in tem đã kết nối."}
        ],
        "notes": "Hệ thống hỗ trợ in lại cùng một nhãn bất kỳ lúc nào mà không bị giới hạn số lần in.",
        "calloutType": "note"
      }
    ]
  }
];

// Initialize UI
document.addEventListener('DOMContentLoaded', () => {
  renderSidebarNav();
  renderMatrixCards();
  renderSections();
  setupInteractions();
  setupSimulators();
  setupSearch();
  setupThemeToggle();
  setupLightbox();
});

// Render Sidebar Navigation Links
function renderSidebarNav() {
  const navContainer = document.getElementById('sidebar-nav');
  let html = `<div class="nav-section-title">Nội Dung Tài Liệu</div>`;

  MANUAL_DATA.forEach(section => {
    html += `
      <a href="#${section.id}" class="nav-link" data-target="${section.id}">
        <span class="nav-link-icon">${section.partIcon}</span>
        <span>${section.part}: ${section.partTitle}</span>
      </a>
    `;
  });

  html += `
    <div class="nav-section-title">Tiện Ích & Tra Cứu</div>
    <a href="#simulators-section" class="nav-link" data-target="simulators-section">
      <span class="nav-link-icon">⚡</span>
      <span>Công Cụ Mô Phỏng</span>
    </a>
    <a href="#rules-section" class="nav-link" data-target="rules-section">
      <span class="nav-link-icon">⚠️</span>
      <span>Bảng Quy Tắc Vận Hành</span>
    </a>
  `;

  navContainer.innerHTML = html;
}

// Render Quick Jump Matrix Cards
function renderMatrixCards() {
  const matrixGrid = document.getElementById('matrix-grid');
  let html = '';

  MANUAL_DATA.forEach(section => {
    html += `
      <div class="matrix-card" onclick="document.getElementById('${section.id}').scrollIntoView({behavior: 'smooth'})">
        <div>
          <div class="matrix-icon">${section.partIcon}</div>
          <div class="matrix-title">${section.part}: ${section.partTitle}</div>
          <div class="matrix-desc">Bao gồm ${section.topics.length} chủ đề hướng dẫn chi tiết kèm ảnh giao diện Kiosk thực tế.</div>
        </div>
        <div class="matrix-badge">
          <span>Xem chi tiết</span>
          <span>→</span>
        </div>
      </div>
    `;
  });

  matrixGrid.innerHTML = html;
}

// Render Manual Sections
function renderSections() {
  const container = document.getElementById('sections-container');
  let html = '';

  MANUAL_DATA.forEach((section, sIdx) => {
    html += `
      <section class="manual-section" id="${section.id}">
        <div class="section-header">
          <div class="section-title-wrap">
            <div class="section-number">${sIdx}</div>
            <h3 class="section-title">${section.partTitle}</h3>
          </div>
        </div>
    `;

    section.topics.forEach(topic => {
      let calloutClass = 'callout-note';
      let calloutIcon = 'ℹ️';
      if (topic.calloutType === 'tip') {
        calloutClass = 'callout-tip';
        calloutIcon = '💡';
      } else if (topic.calloutType === 'warning') {
        calloutClass = 'callout-warning';
        calloutIcon = '⚠️';
      } else if (topic.calloutType === 'danger') {
        calloutClass = 'callout-danger';
        calloutIcon = '🛑';
      }

      html += `
        <div class="topic-card" id="topic-slide-${topic.slide}">
          <div class="topic-header">
            <div class="topic-title">
              <span>${topic.title}</span>
            </div>
            <span class="slide-tag">Slide ${topic.slide} • ${topic.tag}</span>
          </div>

          <div class="topic-grid">
            <div class="topic-details">
              <p class="overview-text">${topic.overview}</p>
              
              <div class="steps-list">
                ${topic.steps.map(step => `
                  <div class="step-item">
                    <div class="step-num">${step.num}</div>
                    <div class="step-content">
                      <div class="step-title">${step.title}</div>
                      <div>${step.desc}</div>
                    </div>
                  </div>
                `).join('')}
              </div>

              ${topic.notes ? `
                <div class="callout ${calloutClass}">
                  <span class="callout-icon">${calloutIcon}</span>
                  <div>${topic.notes}</div>
                </div>
              ` : ''}
            </div>

            <div class="slide-visual-container" onclick="openLightbox('${topic.image}', '${topic.title}')">
              <img src="${topic.image}" alt="${topic.title}" class="slide-img" loading="lazy">
              <div class="zoom-hint">
                <span>🔍</span>
                <span>Nhấn để phóng to</span>
              </div>
            </div>
          </div>
        </div>
      `;
    });

    html += `</section>`;
  });

  container.innerHTML = html;
}

// Lightbox functionality
function setupLightbox() {
  const lightbox = document.getElementById('lightbox');
  const closeBtn = document.getElementById('lightbox-close');

  closeBtn.addEventListener('click', () => {
    lightbox.classList.remove('active');
  });

  lightbox.addEventListener('click', (e) => {
    if (e.target === lightbox) {
      lightbox.classList.remove('active');
    }
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      lightbox.classList.remove('active');
    }
  });
}

function openLightbox(src, alt) {
  const lightbox = document.getElementById('lightbox');
  const img = document.getElementById('lightbox-img');
  img.src = src;
  img.alt = alt;
  lightbox.classList.add('active');
}

// Interactive Simulators Setup
function setupSimulators() {
  // FIFO Simulator
  const btnFifo = document.getElementById('btn-calc-fifo');
  if (btnFifo) {
    btnFifo.addEventListener('click', runFifoSimulation);
    runFifoSimulation(); // Run on init
  }

  // Re-sorting Simulator
  const btnResort = document.getElementById('btn-calc-resort');
  if (btnResort) {
    btnResort.addEventListener('click', runResortSimulation);
    runResortSimulation(); // Run on init
  }
}

function runFifoSimulation() {
  const l1 = parseInt(document.getElementById('sim-lot1').value) || 0;
  const l2 = parseInt(document.getElementById('sim-lot2').value) || 0;
  const l3 = parseInt(document.getElementById('sim-lot3').value) || 0;
  let target = parseInt(document.getElementById('sim-target').value) || 0;

  const totalAvail = l1 + l2 + l3;
  const resultBox = document.getElementById('fifo-result-box');

  if (target > totalAvail) {
    resultBox.innerHTML = `
      <div style="color: var(--accent-danger); font-weight: 700;">
        ⚠️ Không đủ số lượng: Cần đóng <strong>${target}</strong> pcs nhưng tổng 3 LOT chỉ có <strong>${totalAvail}</strong> pcs!
      </div>
    `;
    return;
  }

  let deduct1 = Math.min(l1, target);
  let remTarget = target - deduct1;

  let deduct2 = Math.min(l2, remTarget);
  remTarget -= deduct2;

  let deduct3 = Math.min(l3, remTarget);

  let remain1 = l1 - deduct1;
  let remain2 = l2 - deduct2;
  let remain3 = l3 - deduct3;

  resultBox.innerHTML = `
    <div style="font-weight: 700; margin-bottom: 8px; color: var(--accent-success);">
      ✅ Kết quả trừ tuần tự FIFO cho Thùng ${target} chiếc (Mã Box mới được tạo):
    </div>
    <ul style="padding-left: 20px; line-height: 1.8;">
      <li><strong>LOT 1:</strong> Có ${l1} → Trừ <strong>${deduct1}</strong> → Còn lại: <span style="color: ${remain1 === 0 ? 'var(--text-muted)' : 'var(--accent-warning)'}">${remain1} pcs</span></li>
      <li><strong>LOT 2:</strong> Có ${l2} → Trừ <strong>${deduct2}</strong> → Còn lại: <span style="color: ${remain2 === 0 ? 'var(--text-muted)' : 'var(--accent-warning)'}">${remain2} pcs</span></li>
      <li><strong>LOT 3:</strong> Có ${l3} → Trừ <strong>${deduct3}</strong> → Còn lại: <span style="color: ${remain3 === 0 ? 'var(--text-muted)' : 'var(--accent-warning)'}">${remain3} pcs</span></li>
    </ul>
    <div style="margin-top: 8px; font-size: 0.8rem; color: var(--text-muted);">
      ℹ️ Nhãn thùng (Box Label) và Nhãn LOT tương ứng đã sẵn sàng in.
    </div>
  `;
}

function runResortSimulation() {
  const defA = parseInt(document.getElementById('resort-lot-a').value) || 0;
  const defB = parseInt(document.getElementById('resort-lot-b').value) || 0;
  const target = parseInt(document.getElementById('resort-target').value) || 0;

  const totalDefects = defA + defB;
  const resultBox = document.getElementById('resort-result-box');

  if (totalDefects === 0) {
    resultBox.innerHTML = `<div style="color: var(--accent-danger);">Tổng số lỗi phải lớn hơn 0.</div>`;
    return;
  }

  if (target > totalDefects) {
    resultBox.innerHTML = `
      <div style="color: var(--accent-danger); font-weight: 700;">
        ⚠️ Số lượng tái phân loại (${target}) không được lớn hơn tổng số lỗi (${totalDefects})!
      </div>
    `;
    return;
  }

  const ratioA = defA / totalDefects;
  const deductA = Math.round(target * ratioA);
  const deductB = target - deductA;

  resultBox.innerHTML = `
    <div style="font-weight: 700; margin-bottom: 8px; color: var(--accent-info);">
      📊 Kết quả phân bổ tỷ lệ tái phân loại (Tổng rút: ${target} chiếc đạt):
    </div>
    <ul style="padding-left: 20px; line-height: 1.8;">
      <li><strong>LOT A:</strong> ${defA} lỗi (Tỷ lệ ${(ratioA * 100).toFixed(1)}%) → Trừ <strong>${deductA}</strong> pcs</li>
      <li><strong>LOT B:</strong> ${defB} lỗi (Tỷ lệ ${((1 - ratioA) * 100).toFixed(1)}%) → Trừ <strong>${deductB}</strong> pcs</li>
    </ul>
    <div style="margin-top: 8px; font-size: 0.8rem; color: var(--accent-success);">
      🎉 Một LOT Tái Phân Loại Mới sẽ được sinh ra với số lượng = <strong>${target}</strong> pcs để tích lũy sản lượng đạt.
    </div>
  `;
}

// Search Filter Setup
function setupSearch() {
  const searchInput = document.getElementById('search-input');
  searchInput.addEventListener('input', (e) => {
    const q = e.target.value.toLowerCase().trim();
    const topicCards = document.querySelectorAll('.topic-card');

    topicCards.forEach(card => {
      const text = card.textContent.toLowerCase();
      if (!q || text.includes(q)) {
        card.style.display = 'block';
      } else {
        card.style.display = 'none';
      }
    });
  });
}

// Theme Toggle
function setupThemeToggle() {
  const themeBtn = document.getElementById('theme-toggle-btn');
  themeBtn.addEventListener('click', () => {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    document.documentElement.setAttribute('data-theme', newTheme);
  });
}

// Scroll spy and navigation
function setupInteractions() {
  const navLinks = document.querySelectorAll('.nav-link');
  const crumb = document.getElementById('current-crumb');

  window.addEventListener('scroll', () => {
    let current = '';
    const sections = document.querySelectorAll('.manual-section');
    
    sections.forEach(section => {
      const sectionTop = section.offsetTop - 120;
      if (window.pageYOffset >= sectionTop) {
        current = section.getAttribute('id');
      }
    });

    navLinks.forEach(link => {
      link.classList.remove('active');
      if (link.getAttribute('data-target') === current) {
        link.classList.add('active');
        crumb.textContent = link.querySelector('span:last-child').textContent;
      }
    });
  });
}
