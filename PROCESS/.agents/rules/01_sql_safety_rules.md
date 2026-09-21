# 🛡️ VINATECH SQL SAFETY RULES & PROTOCOL

## 1. NGUYÊN TẮC CỐT LÕI
1. **SELECT-ONLY trên Production:** Mọi câu lệnh chạy trực tiếp qua `.\mes.ps1 query`, `.\gw.ps1 query`, `.\db.ps1 query` đều bị kiểm tra chặt chẽ: CẤM tuyệt đối `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE`, `EXEC`.
2. **ANTI-LOCK WITH(NOLOCK):** Mọi câu lệnh `SELECT` trên bảng sản xuất lớn (`STB_SetInfo`, `STB_ProdRouteHist`, `STB_MaterialLotInfo`, `VINA_DOCUMENT_SAVE`) BẮT BUỘC phải kèm `WITH(NOLOCK)`.
3. **TRANSACTION BOUNDARY:** Bất kỳ thao tác can thiệp dữ liệu (hotfix) nào BẮT BUỘC phải bọc trong khối:
   ```sql
   BEGIN TRAN
   -- [Thao tác dữ liệu]
   ROLLBACK TRAN -- (hoặc COMMIT TRAN sau khi kiểm tra kỹ lưỡng)
   ```
4. **SNAPSHOT BACKUP TRƯỚC KHI SỬA:**
   Luôn tạo bảng backup dạng `_BK_YYYYMMDD` trước khi chỉnh sửa bất kỳ dòng nào trên Production.
