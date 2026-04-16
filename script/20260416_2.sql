BEGIN TRAN;

-- 1. Xóa đích danh mã có dấu X cho Lot NM35335C1261500006
delete FROM STB_RawMaterialInputHist
WHERE Barcode = 'NM35335C1261500011' 
  AND RawMaterialBarcode = 'URL:VEM_090S00P_270R0665_Nordex_QK03019';

-- Sau khi chạy thành công và F5 kiểm tra thấy đúng trên phần mềm
COMMIT TRAN;

--rollback tran
