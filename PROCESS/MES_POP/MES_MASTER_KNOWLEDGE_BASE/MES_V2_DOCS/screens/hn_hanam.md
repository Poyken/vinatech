# 🏛️ HN-Series: Hà Nam Factory Specific Screens

> Nhà máy Hà Nam (F3 — `VVT_F3`) sử dụng phân hệ 83 màn hình riêng biệt có tiền tố `HN`, quản lý các công đoạn đặc thù `VE01` $\rightarrow$ `VE18`.

---

## 📺 Các Màn Hình Trọng Điểm Hà Nam

| TCode | Tên Màn Hình / Chức Năng | Stored Procedure Chính | Ghi Chú Kỹ Thuật |
|---|---|---|---|
| **HN523** | **Vietnam_Donggoi_Hnam** | `usp_Vietnam_GetBoxIDForLotNo_VVT` | Đóng gói thành phẩm Hà Nam (tương tự B523) |
| **HN530** | Kho BTP Aging Hà Nam | `usp_DoSplitLotAgingHN` | Quản lý thời gian ủ Aging theo Gate Time |
| **HN542** | Chia tem & in tem đóng gói | `usp_DoSplitPackagingHN` | Tách nhỏ số lượng để in nhãn con |
| **HN544** | **Gộp túi bóng thành hộp nhỏ** | `usp_DoMergePackagingHN` | Hủy gộp: Xóa `STB_DividePackaging` & set `PackingID = NULL` |
| **HN551** | Quản lý kho thành phẩm HN | `usp_FinishGoodStock_HN_get` | Quản lý tồn kho FERT tại nhà máy F3 |
| **HN782** | Lot Tracking Hà Nam | `usp_LotTrackingInfo_HN_get` | Truy vết lịch sử routing của công đoạn VE |
