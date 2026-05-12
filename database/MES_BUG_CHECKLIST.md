# 📋 MES BUG PROCESSING CHECKLIST

## 🎯 PHASE 1: NHẬN LỖI
- [ ] **Thu thập thông tin đầy đủ** theo template
- [ ] **Screenshot lỗi** rõ nét
- [ ] **Thời gian chính xác** xảy ra lỗi
- [ ] **User và quyền truy cập**

## 🔍 PHASE 2: PHÂN TÍCH NHANH
- [ ] **Kết nối database** kiểm tra real-time
- [ ] **Chạy debug script** với barcode/PO
- [ ] **Kiểm tra data consistency** (SetInfo vs ProdRouteHist)
- [ ] **Xem ProcedureLog** gần nhất

## 📊 PHASE 3: XÁC ĐỊNH NGUYÊN NHÂN
- [ ] **Data inconsistency** (barcode không tồn tại)
- [ ] **Missing route step** (bỏ qua công đoạn)
- [ ] **Validation failed** (PQC, NVL, machine)
- [ ] **System error** (timeout, connection)

## 🛠️ PHASE 4: GIẢI PHÁP
### Option 1: UI Fix (Ưu tiên)
- [ ] **Hướng dẫn user qua màn hình**
- [ ] **Kiểm tra validation logic**
- [ ] **Xác nhận user thao tác đúng**

### Option 2: Script Fix (Khi UI lỗi)
- [ ] **Viết script SELECT** để kiểm tra
- [ ] **Viết script UPDATE/INSERT** an toàn
- [ ] **Backup data trước khi sửa**
- [ ] **User tự chạy script**

### Option 3: System Fix (Lỗi hệ thống)
- [ ] **Kiểm tra SP logic**
- [ ] **Fix root cause**
- [ ] **Test với nhiều cases**

## 📝 PHASE 5: DOCUMENTATION
- [ ] **Cập nhật KB** với lỗi mới
- [ ] **Ghi chú solution** cho lần sau
- [ ] **Training user** nếu cần
- [ ] **Monitor** sau khi fix

## ⚡ QUICK FIXES CHO LỖI THƯỜNG GẶP

### 🐛 Lỗi: "부임공정 실적처리 에러"
**Nguyên nhân:** Barcode chưa qua các công đoạn trước
**Fix:** Kiểm tra STB_ProdRouteHist, chạy lại từ đầu

### 🐛 Lỗi: "Số lượng thực tế = 0"
**Nguyên nhân:** UI chưa tính auto, user cần nhập
**Fix:** Nhập Actual Qty = Plan Qty - NG Qty

### 🐛 Lỗi: "Barcode không tồn tại"
**Nguyên nhân:** ControlNo vs SetInfoNo khác nhau
**Fix:** Kiểm tra mapping trong STB_SetInfo

### 🐛 Lỗi: "Connection timeout"
**Nguyên nhân:** Network hoặc DB issue
**Fix:** Kiểm tra connection, restart app

## 🎯 ESCALATION RULES
- **Level 1:** User errors → UI fix
- **Level 2:** Data errors → Script fix  
- **Level 3:** System errors → Developer fix
- **Level 4:** Production down → Immediate escalation
