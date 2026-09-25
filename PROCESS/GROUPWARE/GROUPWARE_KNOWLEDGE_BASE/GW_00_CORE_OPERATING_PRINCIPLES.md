# 🏛️ GW_00 — Bản Chất Cốt Lõi & 7 Quy Tắc Vận Hành Bất Biến Của Hệ Thống Groupware Vinatech

> **Tài liệu nền tảng:** Single Source of Truth for Groupware Operational Essence & Architecture  
> **Nền tảng:** Bizbox Alpha (Douzone Bizon)  
> **CSDL Trung tâm:** `VINATECH_GROUP` | **CSDL Vệ tinh:** `VINATECH_RESTFUL`, `streamdocs`, `VINATECH_SPREADSHEET`, `VINATECH_WEBSOCKET`  
> **Hệ sinh thái liên kết:** Douzone ERP iU (`NEOE`) ↔ NAIS MES (`SmartFactoryV2` / `SmartFramework`) ↔ Kiosk POP (`VINATECH_POP`)  
> **Phạm vi áp dụng:** Toàn bộ nhân viên, Kỹ sư hệ thống, Quản trị viên CSDL và AI Agents tại Vinatech.

---

## 🧭 CHƯƠNG 1: BẢN CHẤT TRIẾT LÝ & VỊ THẾ CỦA GROUPWARE TRONG DOANH NGHIỆP

Trong mô hình kiến trúc công nghệ thông tin tại Vinatech, **Groupware (Bizbox Alpha)** thường bị hiểu nhầm là một công cụ văn phòng đơn thuần (gửi nhận email, xem thông báo, đặt phòng họp, xem lịch làm việc). **Tuy nhiên, trong thực tế vận hành sản xuất kinh doanh, bản chất cốt lõi của Groupware là: TRỤC THẨM QUYỀN ĐIỀU HÀNH THƯỢNG NGUỒN (Upstream Operational & Governance Authority) — Cánh cổng phê duyệt tối cao kiểm soát toàn bộ luồng tiền tệ, luồng vật tư, luồng nhân sự và luồng sản xuất.**

```
                     ┌────────────────────────────────────────────────────────┐
                     │           GROUPWARE (https://gw.vinatech.com)          │
                     │          CỔNG THẨM QUYỀN ĐIỀU HÀNH THƯỢNG NGUỒN         │
                     │   • Phê duyệt Mua sắm (PO)   • Kế hoạch SX (Month/Day)  │
                     │   • Duyệt Chi phí/Công nợ    • Đơn Bán hàng (Suju)      │
                     │   • Quản lý Nhân sự & Nghỉ   • Master Data & BOM 2001   │
                     └───────────────────────────┬────────────────────────────┘
                                                 │
                                                 │ Kích hoạt khi STATE = '008' (Approved)
                                                 ▼
                     ┌────────────────────────────────────────────────────────┐
                     │                 ERP DOUZONE iU (NEOE)                  │
                     │            TRỤC TÀI CHÍNH & HẠCH TOÁN DOANH NGHIỆP      │
                     │   • Đơn Mua Hàng (PU_PO)     • Định mức BOM (PR_BOM)   │
                     │   • Bút toán Kế toán (FI_DOCU)• Đơn Bán hàng (SA_SO)   │
                     └───────────────────────────┬────────────────────────────┘
                                                 │
                                                 │ Phân bổ kế hoạch & chỉ thị
                                                 ▼
                     ┌────────────────────────────────────────────────────────┐
                     │          NAIS MES & KIOSK POP (SmartFactoryV2)         │
                     │           TRỤC THỰC THI HIỆN TRƯỜNG & SẢN XUẤT VẬT LÝ   │
                     │   • Nhập hàng NVL (F330)     • Kiểm định IQC (C220)    │
                     │   • Giám sát PO (B310)       • Phát hành Lot (B450)    │
                     │   • Chuyền sản xuất (B530)   • Kho Thành phẩm (FG01)   │
                     └────────────────────────────────────────────────────────┘
```

### 1.1 Nguyên Lý "Không Có Tờ Trình Duyệt, Không Có Bất Kỳ Chuyển Động Nào"
- **Về Dòng Tiền (Financial Control):** Không một khoản chi phí, tạm ứng hay thanh toán nhà cung cấp nào trên ERP Douzone (`FI_DOCU`) được phép giải ngân nếu không gắn liền với một tờ trình điện tử (`VINA_DOCUMENT_SAVE`) đã được phê duyệt ở trạng thái hoàn tất (`DOCUMENT_SAVE_STATE = '008'`).
- **Về Dòng Vật Tư (Material Invariance):** Thủ kho tại màn hình MES `F330` không thể nhận một kiện nguyên vật liệu nào vào nhà máy nếu trên Groupware chưa có đơn mua hàng `VINA_DOCUMENT_POH` và phiếu thông báo hàng về `VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_H` đã được duyệt.
- **Về Dòng Sản Xuất (Manufacturing Invariance):** Quản đốc xưởng và kỹ thuật viên không thể phát hành lệnh Lot trên MES `B450` hay chạy máy trên Kiosk POP nếu kế hoạch sản xuất tháng `VINA_PROD_MONTH_PRODPLAN` và kế hoạch ngày chưa được phê chuẩn qua Groupware với phiên bản định mức BOM chuẩn (**2001/2002**).
- **Về Dòng Xuất Xưởng (Outbound Logistics):** Thủ kho thành phẩm tại trạm `FG01` và xe container tại cổng `B752` không thể lăn bánh nếu phiếu đề nghị xuất kho `VINA_SALES_PROD_HAND` và hóa đơn xuất khẩu chưa được ký duyệt.

---

## ⚡ CHƯƠNG 2: 7 QUY TẮC VẬN HÀNH BẢN CHẤT CỐT LÕI (THE 7 INVARIANT LAWS)

---

### QUY TẮC 1: CỖ MÁY TRẠNG THÁI BẤT BIẾN & CƠ CHẾ SIDE-EFFECTS HOOKS (STATE MACHINE INTEGRITY)

Mọi văn bản trong Groupware vận hành theo máy trạng thái xác định (Deterministic Finite State Machine) thông qua cột `DOCUMENT_SAVE_STATE` trong bảng `VINA_DOCUMENT_SAVE`:

```
   [001: Lưu nháp] ──(Gửi duyệt)──► [002: Đang trình ký] ──(Cấp cuối ký)──► [008: Phê duyệt hoàn tất]
          ▲                                 │                                          │
          │ (Hủy / Thu hồi)                 ├──────(Bị từ chối)──► [004: Từ chối]      │ Kích hoạt chuỗi
          └─────────────────────────────────┴──────(Thu hồi)────► [009: Hủy bỏ]       │ Side-effects tự động
                                                                                       ▼
                                                                             1. Ký số & Render PDF
                                                                             2. Cấp mã ED-...
                                                                             3. Ghi interface sang ERP
                                                                             4. Bắn WebSocket Event
                                                                             5. Đóng băng dữ liệu (Lock)
```

#### ⚠️ Bản Chất Kỹ Thuật Đằng Sau Lệnh Cấm "UPDATE STATE = '008'" (Rule 2):
Khi người phê duyệt cuối cùng bấm nút **"Phê duyệt" (Approved)** trên giao diện Groupware Web, Backend Java Spring của Bizbox Alpha (`vinatechDocumentSaveService`) không chỉ đổi giá trị `DOCUMENT_SAVE_STATE = '008'` trong bảng `VINA_DOCUMENT_SAVE`, mà nó còn thực thi **5 side-effects ngầm mang tính sống còn**:
1. **Render & Ký Số PDF Lưu Trữ Kiểm Toán:** Hệ thống kết nối sang CSDL `streamdocs` (bảng `pdf_resource`), nạp toàn bộ cấu trúc HTML của form, dán mộc số, đóng dấu chữ ký điện tử của từng cấp duyệt và tính toán chuỗi hash (SHA-256) để chống chỉnh sửa theo chuẩn kiểm toán K-SOX.
2. **Cấp Mã Lưu Trữ Hồ Sơ (`RECORD_INCREASE_CODE`):** Tạo ra mã số văn bản chính thức định dạng `ED-[MÃ_FORM][NĂM][SỐ_THỨ_TỰ]` (Ví dụ: `ED-VJPMTR000000021`).
3. **Kích Hoạt Cỗ Máy Tích Hợp ERP (Interface Trigger / Job):** Backend đọc dữ liệu từ các bảng chi tiết (`VINA_DOCUMENT_POH`, `VINA_DOCUMENT_POL`, `VINA_DOCUMENT_RECEIVING_CONFIRMATION_H`) và ghi vào các bảng trung gian hoặc gọi thẳng Stored Procedure của Douzone ERP iU (`NEOE.PU_PO`, `NEOE.FI_DOCU`) để sinh chứng từ nghiệp vụ.
4. **Bắn Tín Hiệu Thời Gian Thực (Push Notification):** Gửi bản tin qua WebSocket (`VINATECH_WEBSOCKET`) và thông báo đẩy (Push) tới ứng dụng Bizbox Mobile của các phòng ban liên quan (Receipt).
5. **Đóng Băng Dữ Liệu Chống Gian Lận (Row Immutability):** Khóa quyền sửa/xóa trên toàn bộ các dòng chi tiết liên quan.

> [!CAUTION]
> **HẬU QUẢ NẾU UPDATE TRỰC TIẾP QUA SQL:**  
> Nếu kỹ sư hoặc Agent tự ý chạy câu lệnh SQL `UPDATE VINA_DOCUMENT_SAVE SET DOCUMENT_SAVE_STATE = '008'`:
> - CSDL hiển thị là đã duyệt, **nhưng toàn bộ 5 side-effects trên hoàn toàn không được kích hoạt**.
> - Không có PDF lưu trữ, không có mã `ED-...`.
> - Hệ thống ERP **không nhận được sự kiện**, không sinh PO, không sinh chứng từ kế toán.
> - Màn hình MES hạ nguồn vĩnh viễn không nhận được dữ liệu.
> - Văn bản trở thành **"Bản ghi ma" (Orphan Record / Zombie Document)** làm tê liệt toàn bộ dây chuyền xử lý tự động.

---

### QUY TẮC 2: MỎ NEO ĐỊNH DANH TOÀN CỤC & CHUỖI TRUY VẾT 360° (UNIVERSAL ANCHOR KEY)

Mọi giao dịch trên Groupware đều xoay quanh một mỏ neo định danh duy nhất: `DOCUMENT_SAVE_CODE`.

```
                      ┌─────────────────────────────────────────┐
                      │          VINA_DOCUMENT_SAVE             │
                      │  DOCUMENT_SAVE_CODE (Mỏ neo toàn cục)   │
                      │  DOCUMENT_SAVE_STATE = '008'            │
                      │  RECORD_INCREASE_CODE = 'ED-...'        │
                      └────────────────────┬────────────────────┘
                                           │
         ┌─────────────────────────────────┼─────────────────────────────────┐
         │ (1:N Khóa ngoại)                │ (1:N Khóa ngoại)                │ (1:N Khóa ngoại)
         ▼                                 ▼                                 ▼
┌──────────────────────┐         ┌──────────────────────┐         ┌──────────────────────┐
│  VINA_DOCUMENT_POH   │         │ VINA_DOCUMENT_RECEIV-│         │ VINA_PROD_MONTH_     │
│  DOCUMENT_SAVE_CODE  │         │ ING_PHYSICAL_ITEM_H  │         │ PRODPLAN             │
│  NO_PO               │         │ DOCUMENT_SAVE_CODE   │         │ DOCUMENT_SAVE_CODE   │
└──────────┬───────────┘         └──────────┬───────────┘         └──────────┬───────────┘
           │                                │                                │
           ▼                                ▼                                ▼
  ERP PU_PO (NO_PO)               MES F330 (Arrival ID)            MES B310 / B450 (WO)
           │
           ▼
  ERP FI_DOCU (Ghi nhận chuỗi 'ED-...' vào cột NM_PUMM)
```

- **Tính Bất Biến:** Trường `DOCUMENT_SAVE_CODE` là khóa chính (hoặc khóa ngoại duy nhất) liên kết Header với hơn 17 bảng Detail chuyên biệt. Cấm mọi hành vi cập nhật hoặc tái tạo mã này.
- **Truy Vết Hai Chiều Ngược Ngược (Reverse Lineage):**
  - Nhờ việc hệ thống tự động ghi chuỗi `RECORD_INCREASE_CODE` (ví dụ `ED-VJPMTR000000021`) vào cột mô tả `NM_PUMM` của chứng từ kế toán ERP `NEOE.FI_DOCU`, Kiểm toán viên có thể từ 1 khoản tiền thanh toán trên sổ cái ERP tra ngược ngay về đúng tờ trình duyệt gốc trên Groupware trong 0.001 giây thông qua View:
    ```sql
    SELECT * FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_ERP_DOCU_INFO_VIEW WITH (NOLOCK)
    WHERE NO_DOCU = 'MÃ_CHỨNG_TỪ_KẾ_TOÁN_ERP';
    ```

---

### QUY TẮC 3: MA TRẬN PHÂN QUYỀN ĐA CHIỀU & CƠ CHẾ KÝ THAY KIỂM TOÁN (APPROVAL MATRIX & DELEGATION)

Tuyến phê duyệt điện tử trên Groupware không phải là một danh sách phẳng đơn giản, mà là một **Ma trận Phân quyền 4 Chiều (4-Dimensional Approval Matrix)**:
1. **Chiều Cấp bậc Phòng ban (Vertical Hierarchy):** Nhân viên ➔ Trưởng nhóm (Team Leader) ➔ Trưởng phòng / Giám đốc bộ phận (Group Leader / Director) ➔ Tổng Giám Đốc (CEO).
2. **Chiều Hạn mức Tài chính (Financial Threshold Gatekeeper):**
   - **Dưới 10,000,000 VNĐ:** Trưởng phòng phụ trách bộ phận phê duyệt cuối cùng.
   - **Từ 10,000,000 – 50,000,000 VNĐ:** Giám đốc bộ phận (Trần Quang Thỏa - `21910034`) phê duyệt cuối, thông báo tham chiếu (CC) Kế toán.
   - **Trên 50,000,000 VNĐ hoặc Ngoài kế hoạch ngân sách:** Bắt buộc Tổng Giám Đốc (Kim Kyeong Cheol) phê duyệt cuối cùng và Kế toán trưởng ký Thỏa thuận (Agreement).
3. **Chiều Chức năng Phối hợp (Cross-functional Interlocks):**
   - **Approval (결재):** Người có quyền ra quyết định tối hậu.
   - **Agreement (합의):** Bộ phận kiểm soát chéo (Kế toán kiểm tra ngân sách, Quản trị tài sản kiểm tra mã tài sản, IT kiểm tra an toàn thông tin). Nếu cấp Agree từ chối, văn bản dừng ngay lập tức.
   - **Receipt (수신):** Bộ phận tiếp nhận triển khai sau khi duyệt (Phòng Mua hàng nhận đơn yêu cầu mua sắm, Phòng Kho nhận lệnh chuẩn bị xuất hàng).
   - **Reference (참조):** Nhận thông báo giám sát tiến độ.
4. **Cơ Chế Ủy Quyền Ký Thay (Delegation / Proxy Rule - 대결):**
   - Khi cán bộ quản lý đi công tác hoặc nghỉ phép, họ phải thiết lập thời gian vắng mặt và người ký thay trên giao diện Groupware.
   - Khi người ký thay thực hiện phê duyệt, hệ thống tự động lưu vết mã nhân sự thực tế ký vào cột `NO_EMP_PROXY` và đóng dấu điện tử `[대결 - Ký thay]` trên bản PDF lưu trữ. Tuyệt đối không chia sẻ mật khẩu tài khoản.

---

### QUY TẮC 4: KHÓA LIÊN ĐỘNG HAI CHIỀU GIỮA CÁC HỆ THỐNG (BIDIRECTIONAL CIRCUIT BREAKERS)

Groupware, ERP và MES không chạy độc lập mà được kết nối bằng các **Khóa Liên Động Kỹ Thuật (Circuit Breakers & Technical Interlocks)**:

| Chiều Tác Động | Khóa Liên Động (Interlock) | Cơ Chế Bảo Vệ / Điểm Chặn | Hệ Quả Khi Vi Phạm |
| :--- | :--- | :--- | :--- |
| **GW ➔ MES** | **Arrival Interlock** | Phiếu Khai báo hàng về `VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_H` phải có `STATE = '008'` thì trạm kho MES `F330` mới hiển thị mã đơn hàng để quét barcode và in nhãn NVL. | Thủ kho không nhận được hàng ngoài luồng, không in được tem lậu. |
| **MES ➔ GW** | **IQC Gatekeeper** | Kỹ thuật viên kiểm tra chất lượng tại màn hình MES `C220` bắt buộc phải bấm **Confirm PASS** (`QcResult = 'PASS'` trong `STB_MaterialQcInfo`) thì Groupware mới mở khóa cho phép nhân viên Mua hàng tạo form `Receiving Confirmation`. | Ngăn chặn tuyệt đối việc làm thủ tục nhập kho tài chính cho nguyên vật liệu lỗi (NG). |
| **GW ➔ ERP ➔ MES**| **BOM Version Lock (2001/2002)** | Mọi đơn PO sản xuất từ Groupware bắt buộc phải nạp phiên bản BOM **2001** (hoặc **2002** cho Cell line mới) từ ERP `NEOE.PR_BOM`. | Nếu nạp BOM version cũ hoặc khác chuẩn, MES `B310`/`B450` lập tức từ chối lệnh, khóa không cho phát hành Lot sản xuất. |
| **GW ➔ Kho MES** | **Outbound Clearance** | Phiếu Đề nghị xuất kho `VINA_SALES_PROD_HAND` duyệt `008` kết hợp trạm MES `FG01` kiểm tra từng thùng đạt trạng thái **OQC PASS**, gom mã Pallet `B750` và đối chiếu container `B752`. | Ngăn chặn xuất sai hàng, thiếu hàng hoặc xuất hàng chưa qua kiểm định chất lượng xuất xưởng. |

---

### QUY TẮC 5: PHÂN TÁCH TRÁCH NHIỆM ĐA CƠ SỞ DỮ LIỆU (MULTI-DATABASE SEPARATION OF CONCERNS)

Hệ sinh thái Groupware Vinatech được kiến trúc hóa thành 5 cơ sở dữ liệu chuyên biệt phục vụ các mục đích phi chức năng (Non-functional requirements) tối ưu:

```
┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│                             KIẾN TRÚC ĐA CƠ SỞ DỮ LIỆU GROUPWARE                               │
├─────────────────────┬─────────────────────┬─────────────────────┬──────────────────────────────┤
│  VINATECH_GROUP     │  VINATECH_RESTFUL   │     streamdocs      │    VINATECH_WEBSOCKET &      │
│  (Database Cốt Lõi) │  (Cổng SSO Security)│  (Ký Số & PDF K-SOX)│    VINATECH_SPREADSHEET      │
├─────────────────────┼─────────────────────┼─────────────────────┼──────────────────────────────┤
│ • 17 Form Biểu mẫu  │ • VINA_SSO_TOKEN    │ • pdf_resource      │ • Push notification chuông   │
│ • State Machine     │ • Xác thực Token    │ • Lưu trữ văn bản   │ • Bảng tính động JSON nhúng  │
│ • Sơ đồ Tổ chức     │ • Chống IP Spoofing │   đã ký số chuẩn    │ • Đồng bộ trạng thái TV      │
│ • Native AI Agent   │ • Đăng nhập 1 lần   │   pháp lý kiểm toán │   Andon nhà xưởng            │
└─────────────────────┴─────────────────────┴─────────────────────┴──────────────────────────────┘
```

1. **`VINATECH_GROUP` (Data Plane):** Lưu trữ toàn bộ dữ liệu nghiệp vụ, vòng đời biểu mẫu, quan hệ phòng ban nhân sự và phân hệ AI Agent.
2. **`VINATECH_RESTFUL` (Security Plane):** Đóng vai trò SSO Token Provider. Mọi phiên đăng nhập từ Groupware Web sang cổng MES Portal hoặc ERP đều phải kiểm tra Token còn hiệu lực và đúng Client IP để ngăn chặn tấn công giả mạo (Session Hijacking).
3. **`streamdocs` (Compliance Plane):** Lưu trữ tài liệu dưới dạng PDF nhị phân kèm chữ ký điện tử. Đây là căn cứ pháp lý duy nhất được pháp luật và cơ quan thuế công nhận khi kiểm toán hồ sơ.
4. **`VINATECH_SPREADSHEET` & `VINATECH_WEBSOCKET` (Realtime Plane):** Đảm nhiệm xử lý các bảng tính động JSON và phát thông báo thời gian thực khi có người ký duyệt văn bản.

---

### QUY TẮC 6: ĐỒNG BỘ DỮ LIỆU GỐC NHÂN SỰ & TỔ CHỨC (HR MASTER DATA SINGLE SOURCE OF TRUTH)

- **ERP là Gốc Hồ Sơ Pháp Lý (`NEOE.MA_EMP`, `MA_USER`):** Khi phòng Hành chính Nhân sự tuyển mới hoặc điều chuyển nhân viên, thay đổi được thực hiện đầu tiên trên ERP.
- **Trigger Tự Động `UT_MA_EMP_BIZBOX_GW`:** Trigger này trên ERP sẽ tự động đồng bộ sang các bảng Groupware (`VINA_EMP`, `VINA_ORG_CHART_NODE`, `USER_MAPPING_INFO`).
- **Cầu Nối Định Danh Sang MES (`Appendix8`):** CSDL MES `SmartFramework.dbo.STB_UserInfo` quản lý tài khoản người dùng máy tính và Kiosk POP bằng cách ánh xạ mã nhân viên ERP/Groupware vào cột `Appendix8`. Nếu cột này bị trống hoặc lệch, nhân viên sẽ bị mất quyền thao tác trên chuyền sản xuất.

---

### QUY TẮC 7: NỀN TẢNG AI AGENT TÍCH HỢP NGUYÊN BẢN (NATIVE BIZBOX AI AGENT ENGINE)

Groupware Vinatech là một trong số ít các hệ sinh thái doanh nghiệp đã tích hợp cỗ máy AI Agent nguyên bản (Native AI Agent) ngay tại tầng CSDL (`VINA_AGENT_*`):

```
Người dùng ──► Giao diện Groupware / Nút "✨ AI Tinh Chỉnh"
                     │
                     ▼
         Bizbox AI Agent Gateway
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
  Universal Agent         Prompt Maker Agent
  (STATIC_DATA_000762)    (STATIC_DATA_000770)
         │                       │
         ├───────────────────────┤
         ▼                       ▼
  Tool Calling Suite      Dynamic APIs Bridge (Java Spring Beans)
  • Gmail                 • search_e_approval_documents (vinatechDocumentSaveService)
  • Google Drive          • search_employee_info (vinatechEmpService)
  • ECM Document          • Lấy dữ liệu Live từ VINATECH_GROUP & NEOE
  • E-Approval Draft
```

- **Universal Agent (`STATIC_DATA_000762`):** Hỗ trợ đàm thoại, streaming token, ghi nhớ ngữ cảnh ngắn hạn 10 lượt hội thoại gần nhất (`AGENT_TYPE_CHAT_SAVE_LENGTH = 10`), tích hợp bộ công cụ Tool Calling (Gmail, Drive, ECM, E-Approval).
- **Prompt Maker Agent (`STATIC_DATA_000770`):** Cung cấp nút bấm trợ lý ảo **"✨ AI Tinh Chỉnh"** ngay trên giao diện soạn thảo tờ trình (`draftDocument`), giúp nhân viên tối ưu hóa ngôn từ hành chính trước khi trình lãnh đạo.
- **Dynamic API Bridge:** Sử dụng Java Reflection để cho phép LLM truy vấn trực tiếp vào các Service Beans nội bộ (`vinatechDocumentSaveService`, `vinatechEmpService`), bảo toàn tính an toàn và quyền bảo mật dữ liệu doanh nghiệp.

---

## 🛠️ CHƯƠNG 3: CẨM NANG VẬN HÀNH DÀNH CHO KỸ SƯ VẬN HÀNH & AI AGENTS (OPERATIONS PLAYBOOK)

---

### 1. Quy Trình 3 Bước Xử Lý Phiếu Kẹt Duyệt (Non-Destructive Unblocking Runbook)
Khi người dùng phản ánh: *"Phiếu mua hàng / xin phép của tôi bị kẹt nhiều ngày không ai duyệt"*:
- **Bước 1: Tra cứu vị trí kẹt qua CLI Hub (RULE 0 & RULE 4):**
  ```powershell
  .\gw.ps1 trace "<DOCUMENT_SAVE_CODE>"
  ```
  Xác định chính xác văn bản đang ở bước duyệt nào, ai là người đang giữ phiếu.
- **Bước 2: Phân loại nguyên nhân:**
  - *Nếu người duyệt đi vắng / nghỉ phép:* Hướng dẫn người đó vào `Personal Settings → Absence / Delegation` để thiết lập cấp phó ký thay (`NO_EMP_PROXY`).
  - *Nếu người duyệt đã nghỉ việc khỏi công ty:* Quản trị viên HR/IT sử dụng chức năng Điều chuyển phê duyệt (Reassign Approval Line) trên Admin Portal, chuyển tuyến sang người kế nhiệm.
- **Bước 3: Tuyệt đối không can thiệp CSDL:**
  - CẤM chạy SQL Update trạng thái. Mọi can thiệp phải đi qua cổng điều hành người dùng hợp lệ để bảo toàn chuỗi side-effects.

---

### 2. Quy Trình Chẩn Đoán Lệch Đồng Bộ Giữa GW ↔ ERP (Sync Triage Runbook)
Khi PO đã duyệt hoàn tất (`008`) trên Groupware nhưng ERP không thấy:
- **Kiểm tra 1 (Mã đối tác):** Kiểm tra xem `CD_PARTNER` trong `VINA_DOCUMENT_POH` đã được tạo và kích hoạt (`YN_USE = 'Y'`) trên `NEOE.MA_PARTNER` chưa. Nếu chưa có mã đối tác trên ERP, giao dịch mua hàng sẽ bị hệ thống ERP từ chối tiếp nhận.
- **Kiểm tra 2 (Mã vật tư & Đơn vị tính):** Kiểm tra xem tất cả các mã `CD_ITEM` trong `VINA_DOCUMENT_POL` đã được phê chuẩn trong Master Data ERP (`NEOE.MA_PITEM`) và mã đơn vị tính (`CD_UNIT`) có khớp nhau không.
- **Kiểm tra 3 (Tái kích hoạt đồng bộ an toàn):** Yêu cầu Quản trị viên Mua hàng nhấn nút **"Tái đồng bộ ERP (Re-sync)"** trên giao diện Groupware hoặc sử dụng Stored Procedure đồng bộ chính thức, không sửa thô bảng dữ liệu.

---

### 3. Bảng Ma Trận Tóm Tắt 17 Biểu Mẫu Cốt Lõi & Điểm Giao Cắt Hệ Thống

| Nhóm Nghiệp Vụ | Tên Biểu Mẫu Groupware | Bảng Dữ Liệu Header / Detail | Trạng Thái Kích Hoạt | Điểm Giao Cắt ERP | Điểm Giao Cắt MES |
| :--- | :--- | :--- | :---: | :--- | :--- |
| **Mua Hàng** | Purchase Order (PO) | `VINA_DOCUMENT_POH`, `POL` | `008` | `NEOE.PU_PO` | Khai báo chuẩn bị hàng về |
| **Mua Hàng** | Arrival Confirmation | `VINA_DOCUMENT_RECEIVING_PHYSICAL_ITEM_H/L` | `008` | `NEOE.PU_BL` | Mở màn hình MES `F330` |
| **Mua Hàng** | Receiving Confirmation | `VINA_DOCUMENT_RECEIVING_CONFIRMATION_H/L` | `008` | `NEOE.PU_RCV` | Cập nhật kho vật liệu thực tế |
| **Kế Hoạch** | Month Production Plan | `VINA_PROD_MONTH_PRODPLAN` | `008` | `NEOE.PR_WO` | Mở màn hình MES `B310` |
| **Kế Hoạch** | Daily Production Plan | `dailyProductionOrderDocument` | `008` | BOM 2001/2002 | Phát hành Lot trên MES `B450` |
| **Bán Hàng** | Sales Plan / Suju | `VINA_SALES_SELLPLAN` | `008` | `NEOE.SA_SO` | Căn cứ lập kế hoạch sản xuất |
| **Bán Hàng** | Shipment Request | `VINA_SALES_PROD_HAND` | `008` | `NEOE.SA_GIR` | Mở trạm xuất kho MES `FG01` |
| **Bán Hàng** | Shipment Confirmation | `VINA_TRADE_ALL_INVOICE` | `008` | `NEOE.SA_IV` | In tem Pallet `B750`, Container `B752` |
| **Tài Chính** | Expense / Disbursement | `VINA_DOCUMENT_PURCHASE_RESOLUTION` | `008` | `NEOE.FI_DOCU` (`ED-...`) | Quyết toán chi phí mua hàng |
| **Master Data**| Đăng ký Mã Vật Tư Mới | `VINA_ITEM_REG_DOCU` | `008` | `NEOE.MA_PITEM` | Đồng bộ sang MES màn hình `A230` |
| **Master Data**| Đăng ký Đối Tác/Vendor | `VINA_PARTNER_REG_DOCU` | `008` | `NEOE.MA_PARTNER` | Mở mã giao dịch mua bán |
| **Nhân Sự** | Đơn Xin Nghỉ Phép | `VINA_DOCUMENT_LEAVE_REQUEST` | `008` | `NEOE.HR_WTM_*` | Khấu trừ ngày phép trên ERP |
| **Nhân Sự** | Đơn Đi Công Tác | `businessTripDocument` | `008` | `NEOE.HR_WTM_*` | Tự động chấm công công tác |
| **Nhân Sự** | Đơn Đi Làm Ngày Lễ/Nghỉ | `holidayWorkDocument` | `008` | `NEOE.HR_WTM_*` | Tính hệ số lương tăng ca (OT) |
| **Nhân Sự** | Yêu Cầu Tuyển Dụng | `empRequestDocument` | `008` | Kế hoạch nhân sự | Bổ sung nhân lực dây chuyền |
| **Nhân Sự** | Tờ Trình Nghỉ Việc | `employeeRetireDocument` | `008` | Chốt sổ bảo hiểm | Khóa tài khoản MES & Kiosk |
| **Hành Chính** | Tờ Trình Tự Do (Draft) | `draftDocument` | `008` | Lưu trữ số hóa | Kèm nút bấm "✨ AI Tinh Chỉnh" |

---

## 🎯 KẾT LUẬN & CAM KẾT VẬN HÀNH

Hệ thống Groupware (Bizbox Alpha) tại Vinatech là một chỉnh thể hoàn thiện, kết nối chặt chẽ giữa **Quyền lực quản trị (Governance)**, **Kỷ luật tài chính (ERP)** và **Thực thi sản xuất (MES/POP)**. Mọi tác vụ vận hành, lập trình hoặc hỗ trợ kỹ thuật phải tuyệt đối tuân thủ 7 quy tắc bất biến nêu trên nhằm đảm bảo tính toàn vẹn của dữ liệu và sự an toàn tuyệt đối cho dây chuyền sản xuất của tập đoàn.
