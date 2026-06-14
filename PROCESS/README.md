# 🌐 VINATECH - CORE SYSTEMS ARCHITECTURE & OPERATION INDEX

> **Cập nhật:** 14/06/2026
> **Bối cảnh vận hành:** Hệ thống quản trị của Vinatech liên kết chặt chẽ giữa 3 nền tảng chính:
> 1. **Groupware (gw.vinatech.com):** Cổng phê duyệt tờ trình hành chính, nhân sự, mua sắm và kế hoạch ở thượng nguồn.
> 2. **ERP Douzone (NEOE):** Hệ thống quản trị tài chính, nhân sự gốc và lưu trữ Master Data trung tâm.
> 3. **NAIS MES (http://mes.hycap.co.kr:9952):** Hệ thống thực thi sản xuất tại hiện trường nhà xưởng (quét barcode, routing, QC và kho vật lý).

---

## 📁 BẢN ĐỒ CẤU TRÚC THƯ MỤC HỆ THỐNG (WORKSPACE STRUCTURE)

Để quản lý và vận hành hiệu quả, cơ sở dữ liệu và tài liệu kỹ thuật trong thư mục này được chia thành 3 phần rõ rệt:

```
PROCESS/ (Thư mục gốc)
│
├── 📂 GROUPWARE/                               # [PHẦN 1] THƯỢNG NGUỒN - PHÊ DUYỆT TỜ TRÌNH
│   └── 📂 GROUPWARE_KNOWLEDGE_BASE/            # Cơ sở tri thức vận hành Groupware
│       ├── GW_INDEX.md                         # ← Bắt đầu tra cứu Groupware từ đây
│       ├── GW_01_DANG_NHAP.md                  # Hướng dẫn đăng nhập & xử lý tài khoản
│       ├── GW_02_MUA_HANG.md                   # Luồng mua hàng: PO, Arrival, Receiving, Quyết toán
│       ├── GW_03_KE_HOACH_SX.md                # Kế hoạch sản xuất tháng, kế hoạch ngày, Lot
│       ├── GW_04_MASTER_DATA.md                # Đăng ký mã vật tư mới, BOM, Partner/Vendor
│       ├── GW_05_HANH_CHINH.md                 # Công tác, tăng ca ngày nghỉ, nhân sự nghỉ việc
│       ├── GW_06_THANH_TOAN.md                 # Dusbursenment Document (Thanh toán chi tiết)
│       ├── GW_07_KHO_THANH_PHAM.md             # Tra cứu mã kho & quét barcode thành phẩm
│       └── GW_08_BAN_HANG.md                   # Luồng bán hàng: Suju, Shipment Request, Thực xuất
│
├── 📂 MES/                                     # [PHẦN 2] HẠ NGUỒN - THỰC THI SẢN XUẤT HIỆN TRƯỜNG
│   ├── README.md                               # Entry point tra cứu kỹ thuật trạm MES
│   ├── 📂 MES_MASTER_KNOWLEDGE_BASE/           # Cơ sở tri thức nghiệp vụ trạm sản xuất/kho MES
│   │   ├── KB_INDEX.md                         # ← Bắt đầu tra cứu MES từ đây
│   │   ├── KB_01_UI_PHAN_QUYEN.md              # Đăng nhập MES, phân quyền tài khoản (Z410)
│   │   ├── KB_02_KHO_WMS.md                    # Kho NVL WMS, kiểm soát FIFO, tiếp nhận F330
│   │   ├── KB_03_SAN_XUAT.md                   # Quản lý Routing, chia ca, Lot sản xuất (B310, B450)
│   │   ├── KB_04_DONG_GOI_IN_TEM.md            # In tem nhãn, đóng gói hộp/pallet (B750, B752)
│   │   ├── KB_05_QC_ELECTRODE.md               # Kiểm định chất lượng IQC, PQC, OQC (C220, C443, C530)
│   │   └── ... (các tài liệu kỹ thuật phụ trợ khác)
│   ├── 📂 sql/                                 # Mã nguồn SQL và Hotfixes đã triển khai
│   └── 💻 db_sync_tool.ps1 / deploy_tool.ps1   # Script PowerShell hỗ trợ đồng bộ & deploy
│
└── 🤝 TƯƠNG TÁC CHUNG & CẦU NỐI ĐỒNG BỘ (COMMON INTERACTIVE LAYER)
    ├── 📜 groupware_mes_integration_analysis.md # Báo cáo nghiên cứu chi tiết cơ chế xác thực & sync
    ├── 📂 Partner Documents 20260610.pdf        # Tài liệu gốc: Quy trình lập Partner Management (Groupware)
    └── 📂 Disbursement Documents 20260611.pdf   # Tài liệu gốc: Quy trình lập Disbursement Document (Groupware)
```

---

## 🔁 CƠ CHẾ TƯƠNG TÁC VÀ LIÊN THÔNG DỮ LIỆU (INTEGRATION FLOWS)

### 1. Phân chia vai trò hệ thống
*   **Hệ thống Groupware:** Đóng vai trò khởi tạo thông tin và thu thập chữ ký phê duyệt. Dữ liệu sau khi duyệt được đẩy vào ERP và một phần đồng bộ xuống MES.
*   **Hệ thống MES:** Đóng vai trò thực thi vật lý tại nhà xưởng (nhập kho, xuất kho, kiểm định chất lượng, chạy máy). MES sử dụng Master Data đồng bộ từ ERP và đẩy dữ liệu kết quả (sản lượng thực tế, Lot ID, lượng tiêu hao) ngược lên ERP.
*   **Hệ thống ERP:** Đóng vai trò làm cổng trung gian, lưu trữ Master Data trung tâm và đồng bộ các giao dịch tài chính/kế toán.

### 2. Sơ đồ luồng giao tiếp chính
```
[Groupware: Đơn mua hàng PO] ──(Duyệt)──> [ERP: Ghi nhận PO]
                                                │ (Đồng bộ xuống)
                                                v
[Groupware: Hàng về Arrival] ──(Duyệt)──> [MES F330: Tiếp nhận & In tem Part Label]
                                                │
                                                v
                                          [MES C220: IQC Kiểm định chất lượng] ──> PASS
                                                │
                                                v (Điều kiện cần)
[Groupware: Nhập kho Receiving] ─(Duyệt)─> [MES: Tăng tồn kho] & [ERP: Ghi nhận nhập kho chính thức]
                                                │
                                                v
[Groupware: Tờ trình thanh toán] ──(Duyệt)─> [ERP: Hạch toán bút toán Nợ/Có (627/642/241/331)]
```

---

## 🔒 NGUYÊN TẮC AN TOÀN HỆ THỐNG (SECURITY RULES)
*   **Không trực tiếp can thiệp CSDL thực:** Mọi hoạt động cập nhật/sửa lỗi phải được viết dưới dạng kịch bản SQL an toàn (`BEGIN TRANSACTION ... ROLLBACK`), bàn giao cho đội ngũ vận hành hệ thống chạy kiểm tra trước trên môi trường Staging/Dev.
*   **Tuyệt đối không sử dụng tài khoản cứng (Hardcoded User ID):** Tuân thủ quy định phân quyền tự động từ màn hình **Z410** liên kết với nhân sự ERP qua thuộc tính `Appendix8`.
