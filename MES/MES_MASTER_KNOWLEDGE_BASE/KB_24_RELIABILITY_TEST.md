# KB_24 — Reliability Test (Kiểm Tra Độ Tin Cậy)

> **Màn hình liên quan:** RTM (Reliability Test Management)
> **Verified against DB:** 2026-06-10
> ← [Về INDEX](KB_INDEX.md)

---

## 1. Tổng Quan

Kiểm tra độ tin cậy (Reliability Test) là quy trình kiểm tra sản phẩm tụ điện dưới điều kiện khắc nghiệt (nhiệt độ, điện áp, độ ẩm) trong thời gian dài để đánh giá tuổi thọ sản phẩm.

---

## 2. 📋 Flow Kiểm Tra Độ Tin Cậy

```
1. Tạo Request (STB_ReliabilityTestRequestInfo)
   ├── RequestDeptCode: Bộ phận yêu cầu
   ├── MassProductionLotNo: Lot sản xuất hàng loạt
   ├── TestPurposeComment: Mục đích kiểm tra
   └── Conditions: Capacity, ACEsr, DCEsr, SD, LC, ETC
        ↓
2. Tiếp nhận & Lấy mẫu (STB_ReliabilityTestSampleInfo)
   ├── SampleLotNo: Lot mẫu kiểm tra
   ├── SampleQty: Số lượng mẫu
   ├── TestItemCode: Hạng mục kiểm tra
   └── Conditions: Volt, Temperature, Humidity
        ↓
3. Đo lường định kỳ (STB_ReliabilityTestMeasureInfo)
   ├── RTDate: Ngày đo
   ├── MeasureCycle: Chu kỳ đo (lần thứ mấy)
   ├── MeasureValue: Giá trị đo được
   ├── CharacterizationCode: Mã đặc tính đo
   └── OCV, Temp, Humi: Điều kiện lúc đo
        ↓
4. Kết luận & Đóng
```

---

## 3. 🗄️ Schema Chi Tiết

### 3.1 `STB_ReliabilityTestRequestInfo` — Yêu cầu kiểm tra

| Cột | Mô tả |
|-----|-------|
| `RTRequestNo` | Mã yêu cầu (PK) |
| `RequestDate` | Ngày yêu cầu |
| `RequestDeptCode` | Bộ phận yêu cầu |
| `RequesterID` | Người yêu cầu |
| `MassProductionLotNo` | Lot sản xuất |
| `TestPurposeComment` | Mục đích kiểm tra |
| `CapacityCondition` | Điều kiện dung lượng |
| `ACEsrCondition` | Điều kiện AC ESR |
| `DCEsrCondition` | Điều kiện DC ESR |
| `SDCondition` | Điều kiện tự phóng (Self-Discharge) |
| `LCCondition` | Điều kiện dòng rò (Leakage Current) |
| `ETCCondition` | Điều kiện khác |
| `RecipientID` | Người tiếp nhận |
| `ReceptionDate` | Ngày tiếp nhận |
| `ReceptionNo` | Mã tiếp nhận |
| `TestClassCode` | Phân loại kiểm tra |

### 3.2 `STB_ReliabilityTestSampleInfo` — Mẫu kiểm tra

| Cột | Mô tả |
|-----|-------|
| `RTSampleNo` | Mã mẫu (PK) |
| `RTRequestNo` | FK → Request |
| `SampleLotNo` | Lot mẫu |
| `TestItemCode` | Mã hạng mục kiểm tra |
| `VoltCondition` | Điện áp thử (V) |
| `TemperatureCondition` | Nhiệt độ thử (°C) |
| `HumidityCondition` | Độ ẩm thử (%) |
| `SampleQty` | Số lượng mẫu |
| `IsCapacity/IsACEsr/IsDCEsr/IsSD/IsLC` | Các hạng mục cần đo (bit flags) |
| `IsWeight/IsLength` | Đo cân nặng/chiều dài |

### 3.3 `STB_ReliabilityTestMeasureInfo` — Kết quả đo

| Cột | Mô tả |
|-----|-------|
| `RTMeasureNo` | Mã đo (PK) |
| `RTDate` | Ngày đo |
| `MeasureCycle` | Chu kỳ đo (1, 2, 3...) |
| `MeasureValue` | Giá trị đo được |
| `SampleLotNo` | Lot mẫu |
| `SampleSeqNo` | Số thứ tự mẫu trong Lot |
| `TestName` | Tên bài kiểm tra |
| `CharacterizationCode/2` | Mã đặc tính (Capacity, ESR...) |
| `OcvTemp/Humi` | Điều kiện đo |

---

## 4. 🔍 Tra cứu

```sql
-- Xem yêu cầu kiểm tra gần nhất
SELECT RTRequestNo, RequestDate, MassProductionLotNo,
       TestPurposeComment, RequesterID, TestClassCode
FROM STB_ReliabilityTestRequestInfo
ORDER BY RequestDate DESC

-- Xem mẫu đang kiểm tra
SELECT RS.RTSampleNo, RS.RTRequestNo, RS.SampleLotNo, RS.SampleQty,
       RS.VoltCondition, RS.TemperatureCondition, RS.HumidityCondition
FROM STB_ReliabilityTestSampleInfo RS
ORDER BY RS.CreateDateTime DESC

-- Xem kết quả đo theo chu kỳ
SELECT RTDate, MeasureCycle, SampleLotNo, SampleSeqNo,
       TestName, MeasureValue, CharacterizationCode
FROM STB_ReliabilityTestMeasureInfo
WHERE SampleLotNo = 'LOT_CẦN_TRA'
ORDER BY MeasureCycle, SampleSeqNo
```

---

*Cập nhật: 2026-06-10 — Tạo mới từ truy vấn DB thực tế*
