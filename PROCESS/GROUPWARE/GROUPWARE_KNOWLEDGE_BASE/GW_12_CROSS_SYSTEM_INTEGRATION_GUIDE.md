# 🌐 GW_12 — Hướng Dẫn Tích Hợp Đa Nền Tảng (Groupware ↔ ERP ↔ MES ↔ POP)

> **Mục tiêu:** Mô tả chi tiết 4 luồng giao dịch khép kín liên thông giữa 4 hệ thống cốt lõi tại Vinatech: **Groupware (GW)**, **ERP Douzone iU (NEOE)**, **NAIS MES (SmartFactoryV2)**, và **Kiosk POP (VINATECH_POP)**.

---

## 🧭 1. Bản Đồ Tổng Thể Luồng Tích Hợp 4 Chiều (4-Way Integration Matrix)

| Giai Đoạn Nghiệp Vụ | Thượng Nguồn (GW) | Trung Nguồn (ERP) | Hạ Nguồn Hiện Trường (MES) | Trạm Kiosk (POP) |
| :--- | :--- | :--- | :--- | :--- |
| **1. Mua hàng & Nhập kho NVL** | Duyệt PO & Khai báo Arrival | Lưu chứng từ PO & B/L hải quan | Quét Barcode nhận hàng F330 & IQC C220 | - |
| **2. Kế hoạch & Điều hành SX** | Duyệt Month Plan & Suju | Lưu lệnh sản xuất PR_WO & BOM | Tạo chỉ thị B310, phát hành Lot B450 | Bắn mã máy, chốt mẻ, báo phế POP Web |
| **3. Kiểm định & Đóng gói Box** | Theo dõi tiến độ | Ghi nhận chi phí dở dang WIP | Kiểm tra PQC/OQC C512, Đóng thùng B620 | Quét từng Cell vào Box Kiosk POP |
| **4. Xuất hàng & Doanh thu** | Duyệt Suju & Shipment Request | Hạch toán Doanh thu & Công nợ | Quét Packing ID xuất kho FG01, Tem B750 | - |

---

## 🔄 2. Chi Tiết 4 Luồng Giao Dịch Khép Kín (Closed-Loop Workflows)

### 2.1 Luồng 1: Mua Hàng & Quản Lý Kho Nguyên Vật Liệu (Procurement & Inbound WMS)

```mermaid
sequenceDiagram
    autonumber
    actor Staff as Nhân sự Mua hàng
    participant GW as Groupware (VINATECH_GROUP)
    participant ERP as ERP Douzone (NEOE)
    participant MES as NAIS MES (SmartFactoryV2)
    actor QC as Kỹ thuật QC IQC
    actor Store as Thủ kho NVL

    Staff->>GW: Tạo & Phê duyệt Purchase Order (PO)
    GW->>ERP: Auto-sync đăng ký PO vào PU_PO
    Note over Staff,Store: Hàng từ Vendor về đến cổng nhà máy
    Staff->>GW: Tạo Arrival Confirmation (Khai báo hàng về)
    GW->>MES: Đẩy dữ liệu Arrival kích hoạt màn hình F330
    Store->>MES: Mở F330, nhận hàng vật lý & in tem barcode NVL
    Store->>MES: Chuyển lô hàng sang khu vực chờ kiểm IQC
    QC->>MES: Mở màn hình C220, kiểm tra ngoại quan & thông số
    alt Kết quả IQC: PASS
        QC->>MES: Xác nhận PASS trên C220
        Staff->>GW: Tạo Receiving Confirmation (Nhập kho chính thức)
        GW->>ERP: Tự động đăng ký chứng từ nhập kho PU_RCV
        GW->>MES: Cập nhật tồn kho khả dụng để cấp phát sản xuất
        Staff->>GW: Tạo Purchase Resolution gửi Kế toán thanh toán
        GW->>ERP: Tự động tạo bút toán công nợ nhà cung cấp
    else Kết quả IQC: FAIL / REJECT
        QC->>MES: Gắn cờ REJECT trên C220, chuyển hàng vào kho cách ly
        Staff->>GW: Tạo biểu mẫu Return Product trả hàng về Vendor
    end
```

---

### 2.2 Luồng 2: Kế Hoạch & Điều Hành Sản Xuất Hiện Trường (Production Closed-Loop)

```mermaid
sequenceDiagram
    autonumber
    actor Planner as Phòng Kế Hoạch
    participant GW as Groupware (VINATECH_GROUP)
    participant ERP as ERP Douzone (NEOE)
    participant MES as NAIS MES (SmartFactoryV2)
    participant POP as Kiosk POP (VINATECH_POP)
    actor Worker as Công nhân hiện trường

    Planner->>GW: Lập kế hoạch sản xuất tháng (Month Production Plan)
    GW->>ERP: Đăng ký kế hoạch tổng thể & kiểm tra định mức BOM
    Planner->>GW: Phê duyệt kế hoạch ngày (Daily Plan)
    GW->>MES: Phân rã kế hoạch ngày vào STB_DayProdPlan
    MES->>MES: Mở màn hình B310 (Lệnh sản xuất) & B450 (Phát hành Lot)
    Worker->>POP: Mở Kiosk POP, chọn chuyền, đăng nhập ca làm việc
    Worker->>POP: Bắn Barcode Lot vào máy sản xuất (Winding, Curling...)
    Worker->>POP: Hoàn thành mẻ, bấm chốt sản lượng & ghi nhận phế
    POP->>MES: Sync dữ liệu realtime qua bảng MongoToMesPerformance
    MES->>ERP: Đồng bộ kết quả sản lượng và tiêu hao NVL theo ca
```

---

### 2.3 Luồng 3: Bán Hàng & Xuất Kho Thành Phẩm (Sales & Outbound WMS)

```mermaid
sequenceDiagram
    autonumber
    actor Sales as Phòng Kinh Doanh
    participant GW as Groupware (VINATECH_GROUP)
    participant ERP as ERP Douzone (NEOE)
    participant MES as NAIS MES (SmartFactoryV2)
    actor WMS as Thủ kho Thành phẩm

    Sales->>GW: Đăng ký đơn đặt hàng khách hàng (Suju / Sales Order)
    GW->>ERP: Auto-sync đăng ký đơn bán vào SA_SO
    Sales->>GW: Tạo phiếu đề nghị xuất kho (Shipment Request)
    GW->>MES: Đẩy lệnh xuất kho xuống màn hình FG01
    WMS->>MES: Quét Packing ID từng Box thành phẩm tại màn hình FG01
    MES->>MES: Kiểm tra trạng thái OQC (C512) & FIFO trước khi trừ tồn
    Sales->>GW: Tạo Shipment Confirmation (Xác nhận xuất hàng)
    GW->>ERP: Tự động đăng ký chứng từ xuất kho bán hàng SA_IV
    WMS->>MES: In tem Pallet dán niêm phong tại màn hình B750
    Sales->>GW: Tạo Sales Resolution để Phòng Kế toán ghi nhận doanh thu
```

---

## 🔒 3. Bảo Mật & Xác Thực Người Dùng Tập Trung (Single Sign-On SSO)

1. **Cổng Đăng Nhập Duy Nhất:** Toàn bộ nhân sự đăng nhập tại `https://gw.vinatech.com`.
2. **Cơ chế Token SSO:**
   - Dịch vụ xác thực sinh mã Token và ghi nhận vào cơ sở dữ liệu `VINATECH_RESTFUL.dbo.VINA_SSO_TOKEN`.
   - Khi người dùng bấm liên kết chuyển tiếp sang MES Web Portal (`http://mes.hycap.co.kr:9952`) hoặc Kiosk POP (`https://pop.vinatech.com`), Token được truyền kèm header `Authorization: Bearer <TOKEN>`.
3. **Cơ Chế Khớp Nối Nhân Sự Liên Hệ Thống:**
   - Tài khoản Groupware (`VINA_EMP.NO_EMP`) được đối chiếu trực tiếp với mã người dùng ERP (`NEOE.MA_USER.ID_USER`).
   - Trên MES, bảng `SmartFramework.dbo.STB_UserInfo` liên kết thông qua cột `Appendix8 = NO_EMP`, đảm bảo quyền hạn được đồng nhất trên toàn bộ dây chuyền.
