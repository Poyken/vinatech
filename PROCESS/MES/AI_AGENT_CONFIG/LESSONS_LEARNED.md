# 📘 LESSONS LEARNED & AGENT OPERATIONAL OPTIMIZATION PROTOCOL

> **Mục đích:** Ghi nhận các điểm vận hành kém hiệu quả trong quá khứ và quy chuẩn hóa các bước phản xạ tự động để đạt hiệu năng tối đa.
> **Cập nhật:** 2026-08-07

---

## 1. PHÂN TÍCH LỖI VẬN HÀNH TRONG QUÁ KHỨ (PAST INEFFICIENCIES)

| # | Điểm yếu / Sự cố cũ | Nguyên nhân gốc (Root Cause) | Tác hại |
|---|----------------------|-------------------------------|---------|
| 1 | **Query nhỏ giọt 1-2 bảng** | Nhìn hẹp (Snippet Tunnel Vision), chỉ SELECT 1 bảng đoán trước. | Sót bảng `Stb_SlittingStock_VVT` (tồn kho điện cực), tốn 3-4 turn SELECT nhặt nhạnh. |
| 2 | **Dò dẫm tìm SP khi có Screen ID / Ảnh** | Không tra cứu ngay Ma Trận `screen_id_reference` trong KI context. | Làm lãng phí token, tạo cảm giác AI "học vẹt / không thuộc hệ thống". |
| 3 | **Không check connection string khi Timeout** | Tin vào file `db_config.json` hỏng mà không check `git log` tìm Host `dbserver.hycap.co.kr`. | Trả lời lý thuyết suông thay vì SELECT trực tiếp dữ liệu Live Production. |
| 4 | **Báo cáo bề mặt (+1/-1 dòng)** | Tóm tắt sơ sài thay vì trích xuất chi tiết SP code logic, GATES, và Table Schemas. | Không mang lại giá trị kỹ thuật sâu cho IT / DBA vận hành nhà máy. |
| 5 | **Tự ý chèn bản ghi giả lập (Dummy/Suy đoán)** | Suy đoán ngắn hạn, không tra cứu SoT architecture (`KB_04_01_CORE_PACKAGING.md`). | Làm xuất hiện dòng thừa (348/318), sai lệch luồng UI B523. **CẤM TUYỆT ĐỐI!** |
| 6 | **INSERT trực tiếp vào STB_ProdRouteHist bằng SQL Ad-hoc** | Khóa chính `ProdRouteHistNo` bị lệch chuỗi Sequence của ứng dụng MES. |Gây lỗi trùng khóa chính **PRIMARY KEY Violation `PK_STB_ProdRouteHist` (Duplicate key `20260808000824`)** khi công nhân chốt sản xuất trên UI. **BẮT BỘC DÙNG UPDATE CompleteRoute=NULL ở công đoạn trước để MES tự sinh công đoạn sau!** |

---

## 2. QUY TRÌNH PHẢN XẠ VẬN HÀNH CHUẨN HÓA (5 NGUYÊN TẮC VÀNG)

```
[Nhận yêu cầu / Ảnh báo lỗi từ User]
                 │
                 ▼
 ┌────────────────────────────────────────┐
 │ 1. Tra ngay Screen ID Matrix trong KI  │ ➔ Tự động xác định 100% Screen Name, Search SP (_get), Process SP (_iud), DB Tables
 └───────────────────┬────────────────────┘
                     │
                     ▼
 ┌────────────────────────────────────────┐
 │ 2. Thực thi Golden Query 360° ngay 0.01s│ ➔ Dùng Mẫu 1/2/3/4 (WITH NOLOCK) trên dbserver.hycap.co.kr để quét sạch PO, Routing, Kho, Slitting, Packing
 └───────────────────┬────────────────────┘
                     │
                     ▼
 ┌────────────────────────────────────────┐
 │ 3. Trích xuất SP Internals & Root Cause│ ➔ Đọc IF checks, GATES, Error messages từ SP code live
 └───────────────────┬────────────────────┘
                     │
                     ▼
 ┌────────────────────────────────────────┐
 │ 4. Xuất Script Fix SQL (BEGIN TRAN)    │ ➔ Viết script rollback/commit đồng bộ đủ 4 bảng liên quan
 └───────────────────┬────────────────────┘
                     │
                     ▼
 ┌────────────────────────────────────────┐
 │ 5. Phản hồi Chuẩn 3 Khối & Tiết kiệm Token│ ➔ Đạt độ chính xác tuyệt đối, phản hồi cô đọng, không lan man
 └────────────────────────────────────────┘
```

---

## 3. QUY TẮC CẤU HÌNH BẮT BUỘC (RULES SUMMARY)

1. **GOLDEN QUERY FIRST:** Cấm SELECT nhỏ giọt. Quét 360° trong câu SELECT đầu tiên.
2. **IMMEDIATE SCREEN & SP MAPPING:** Nhận Screen ID/Ảnh ➔ Máp ngay cặp SP `_get`/`_iud` từ KI `screen_id_reference`.
3. **DIRECT LIVE VERIFICATION:** Dùng Host `dbserver.hycap.co.kr,5398` (`SmartFactoryV2` + `SmartFramework`) với `WITH(NOLOCK)` để lấy dữ liệu thực tế.
4. **4-TABLE SYNC INTEGRITY:** Sửa bất kỳ Lot nào phải đồng bộ đủ 4 bảng (`SetInfo`, `MaterialLotInfo`, `ProdRouteHist`, `LotChangeHistory`).
5. **TOKEN MINIMIZATION:** Chỉ đọc line-range cần thiết, xuất kết quả 3 khối ngắn gọn.
