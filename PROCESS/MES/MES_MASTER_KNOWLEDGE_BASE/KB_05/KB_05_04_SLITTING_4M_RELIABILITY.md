## 10. ⚡ Điện Cực — Slitting Hà Nam (F743~F748, C243)

### 10.1 Flow Slitting Hà Nam

```
F744 (Thiết lập chiều rộng)
    → Thêm MaterialCode + Width + Đơn vị (M2 hoặc KG)
    → NG_ConPaper + NG_Poil: 2 mã đặc biệt KHÔNG được xóa/sửa
    ↓
F743 (Thực hiện Slitting)
    → Chọn MaterialCode → Tìm kiếm → Xem foil ban đầu (trái) + đã cắt (phải)
    → Thêm foil đã cắt: (+) → Chọn mã NVL con → Nhập Length → Save
    → Sau khi xong: Ấn "Chốt Slitting" → Chuyển sang C243
    → In tem: Tick chọn → Ấn "Phát hành tem" → Chọn máy in
    ↓
C243 (QC Kiểm tra Lot Slitting)
    → QC check sau khi Slitting đã chốt
    → Đánh giá OK: Tự động Pass + Chuyển NG_ConPaper/NG_Poil → kho NG
    → Đánh giá NG: Lot bị Reject → kho NG
    ↓
F746 (Lịch sử Slitting) → F747 (Lịch sử check NG/Pass) → F748 (Chuyển về kho NVL)
```

#### ⚠️ Hủy/Rollback Slitting (F742)
*   **Quy tắc:** Để thực hiện rollback cắt điện cực và cho phép cắt lại ở màn hình **F742**, bắt buộc phải xóa lịch sử ghi nhận ở màn hình **F746** trước.

**Lỗi thường gặp Slitting:**

| Lỗi | Nguyên nhân | Giải pháp |
|-----|-------------|-----------|
| "Trùng mã nguyên liệu" | Mã NVL đã thiết lập trong F744 rồi | Kiểm tra và sửa bản ghi cũ |
| Lot không tồn tại khi chuyển F430 | Lot chưa được QC check ở C243 | Vào C243 check trước |
| Không chuyển về kho được | Lot bị QC đánh Reject | Không thể chuyển — xử lý theo quy trình NG |

👉 **Chi tiết Script Fix (Thiết lập & Cấu hình Slitting):** Xem tại [KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md § 4](KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md).

---

## 11. 🔄 4M Change, CAPA & Phân Loại Mã Lỗi (Gộp từ KB_23)

Hệ thống quản lý biến động chất lượng hiện trường và quy trình xử lý hành động khắc phục/phòng ngừa.

### 11.1 Quản Lý Thay Đổi 4M (Man, Machine, Material, Method)
Ghi nhận mọi biến động liên quan đến con người, máy móc, nguyên vật liệu hoặc phương pháp sản xuất qua bảng `STB_QC4MChangeDataRecord`.
Màn hình: `VVT_DoCreateQC4MChange` (Tạo mới), `VVT_ViewDetailQC4MChange` (Phê duyệt), `VVT_View4MChange` (Xem lịch sử).

```sql
-- Xem các bản ghi 4M Change gần đây
SELECT QC4MNo, ChangeType4M, Model, LineCode, RouteCode,
       ReasonForChange, Status, ApprovalDate, EffectiveDate
FROM STB_QC4MChangeDataRecord
WHERE CreateDateTime >= DATEADD(MONTH, -1, GETDATE())
ORDER BY CreateDateTime DESC;

-- Lọc theo thay đổi Nguyên vật liệu (Material)
SELECT * FROM STB_QC4MChangeDataRecord
WHERE ChangeType4M = 'Material'
ORDER BY CreateDateTime DESC;
```

### 11.2 CAPA (Corrective And Preventive Action)
Khi phát hiện lỗi hệ thống hoặc lỗi nghiêm trọng từ khách hàng, Lot hàng bị ảnh hưởng sẽ được tách riêng tại màn hình `VVT_CAPAInputSeparateLot` để kiểm tra đánh giá trước khi thực hiện hành động khắc phục.

### 11.3 Sửa Chữa Sản Phẩm Lỗi (Defect Repair)
Sản phẩm lỗi được tái chế/sửa chữa và ghi nhận tại các bảng:
*   `STB_DefectRepairInfo`: Thông tin chung về sửa chữa sản phẩm lỗi.
*   `STB_DefectRepairDetailInfo`: Chi tiết công đoạn/hạng mục sửa chữa.
*   `STB_DefectRepairPartInfo`: Phụ tùng hoặc vật tư tiêu hao dùng cho sửa chữa.

```sql
-- Xem lịch sử sửa chữa sản phẩm lỗi trong tuần
SELECT * FROM STB_DefectRepairInfo
WHERE CreateDateTime >= DATEADD(DAY, -7, GETDATE())
ORDER BY CreateDateTime DESC;
```

### 11.4 Phân Loại Nhóm Lỗi & Nguyên Nhân (Defect Master)
Danh sách mã lỗi nghiệp vụ được lưu trữ tập trung để phục vụ thống kê:
*   `STB_DefectGroup`: Nhóm lỗi lớn (Major, Minor, Critical).
*   `STB_DefectInfo`: Danh mục mã lỗi chi tiết hiển thị trên các màn hình scan.
*   `STB_DefectCauseGroup`: Nhóm nguyên nhân lỗi.
*   `STB_DefectCauseInfo`: Chi tiết nguyên nhân lỗi.

```sql
-- Xem danh sách mã lỗi đang hoạt động (IsUsed=1)
SELECT DefectCode, DefectName, DefectGroupCode
FROM STB_DefectInfo
WHERE IsUsed = 1
ORDER BY DefectGroupCode, DefectCode;
```

### 11.5 Báo Cáo Chất Lượng QC (QC Defect Reports)
Các bảng ghi nhận chi tiết lỗi IQC/PQC/OQC:
*   `STB_QcDefectReport`: Báo cáo lỗi QC chung.
*   `STB_IOQCDefectInfo` & `STB_IOQCDefectDetail`: Thông tin chi tiết lỗi IQC và OQC.
*   `STB_QCDefectDetailsRecord`: Nhật ký record lỗi chi tiết.

---

## 12. 🔬 Reliability Test — Kiểm Tra Độ Tin Cậy (Gộp từ KB_24)

Quy trình thử nghiệm sản phẩm tụ điện trong môi trường khắc nghiệt (nhiệt độ cao, điện áp cao, độ ẩm cao) để đánh giá tuổi thọ và độ ổn định.

### 12.1 Quy Trình Vận Hành
1.  **Tạo Request (`STB_ReliabilityTestRequestInfo`):** Bộ phận QC hoặc R&D gửi yêu cầu kiểm tra, xác định Lot sản xuất hàng loạt cần test và điều kiện kiểm tra (ESR, dung lượng, dòng rò).
2.  **Lấy Mẫu (`STB_ReliabilityTestSampleInfo`):** Tiếp nhận yêu cầu, tách Lot mẫu, khai báo điều kiện test (Điện áp, Nhiệt độ, Độ ẩm) và số lượng mẫu kiểm tra.
3.  **Đo Lường Định Kỳ (`STB_ReliabilityTestMeasureInfo`):** Tiến hành đo thông số tụ điện theo chu kỳ (Cycle 1, 2, 3...) và ghi nhận kết quả OCV, ESR, dung lượng.
4.  **Kết luận & Đóng yêu cầu.**

### 12.2 Truy Vấn Dữ Liệu Kiểm Thử
```sql
-- Xem các yêu cầu kiểm tra độ tin cậy gần đây
SELECT RTRequestNo, RequestDate, MassProductionLotNo,
       TestPurposeComment, RequesterID, TestClassCode
FROM STB_ReliabilityTestRequestInfo
ORDER BY RequestDate DESC;

-- Xem thông tin mẫu đang kiểm tra
SELECT RTSampleNo, RTRequestNo, SampleLotNo, SampleQty,
       VoltCondition, TemperatureCondition, HumidityCondition
FROM STB_ReliabilityTestSampleInfo
ORDER BY CreateDateTime DESC;

-- Xem kết quả đo kiểm chi tiết theo chu kỳ của một Lot
SELECT RTDate, MeasureCycle, SampleLotNo, SampleSeqNo,
       TestName, MeasureValue, CharacterizationCode
FROM STB_ReliabilityTestMeasureInfo
WHERE SampleLotNo = 'LOT_CẦN_TRA'
ORDER BY MeasureCycle, SampleSeqNo;
```

---

> 📌 **Phân tích sâu & DB Audit:** Xem chi tiết phân tích kiến trúc database, DNA hệ thống và kết quả Audit tại [KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md](KB_12_DEEP_CORE_ANALYSIS_AND_AUDIT.md).

*Cập nhật: 2026-06-14 | Gộp nội dung từ KB_23 và KB_24 để đồng bộ hoá tri thức quản lý chất lượng (QC)*




---

