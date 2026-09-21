---
name: groupware-db-operations
description: Hướng dẫn thực thi các thao tác truy vấn và kiểm tra an toàn trên CSDL VINATECH_GROUP và các CSDL liên quan.
---

# Kỹ Năng Thao Tác CSDL Groupware An Toàn (groupware-db-operations)

## Nguyên Tắc Vàng:
- Luôn sử dụng cú pháp `WITH (NOLOCK)` khi truy vấn bảng `VINA_DOCUMENT_*`.
- Luôn giới hạn số bản ghi (`TOP 50` hoặc `TOP 100`) để bảo vệ tài nguyên máy chủ.
- Thực thi thông qua CLI Hub: `.\gw.ps1 query "<SELECT_STATEMENT>"`.

## Các Truy Vấn Mẫu Thường Dùng:

### 1. Kiểm tra 10 văn bản gần nhất theo người soạn:
```sql
SELECT TOP 10 
    DOCUMENT_SAVE_CODE, 
    DOCUMENT_TYPE_ID, 
    DOCUMENT_SAVE_SUBJECT, 
    DOCUMENT_SAVE_STATE, 
    DOCUMENT_SAVE_REG_DATE
FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE WITH (NOLOCK)
WHERE NO_EMP_WRITER = 'MÃ_NHÂN_VIÊN'
ORDER BY DOCUMENT_SAVE_REG_DATE DESC;
```

### 2. Kiểm tra chi tiết dòng đơn mua hàng:
```sql
SELECT 
    H.NO_PO, 
    H.CD_PARTNER, 
    L.NO_LINE, 
    L.CD_ITEM, 
    L.QT_PO, 
    L.UM_EX_PO, 
    L.AM_EX_PO
FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_POH H WITH (NOLOCK)
INNER JOIN VINATECH_GROUP.dbo.VINA_DOCUMENT_POL L WITH (NOLOCK)
    ON H.DOCUMENT_SAVE_CODE = L.DOCUMENT_SAVE_CODE
WHERE H.NO_PO = 'MÃ_PO'
ORDER BY L.NO_LINE ASC;
```
