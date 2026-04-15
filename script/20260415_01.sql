BEGIN TRAN;

-- 1. Xóa đích danh mã có dấu X cho Lot NM35335C1261500006
delete FROM STB_RawMaterialInputHist
WHERE Barcode = 'NM35335C1261500006' 
  AND RawMaterialBarcode = 'URL:VEM_090S00P_270R0665_Nordex_QK03022';

-- 2. Xóa đích danh mã có dấu X cho Lot NM35335C1261900007
delete  FROM STB_RawMaterialInputHist
WHERE Barcode = 'NM35335C1261500007' 
  AND RawMaterialBarcode = 'URL:VEM_090S00P_270R0665_Nordex_QK03009';

-- 3. Xóa đích danh mã có dấu X cho Lot NM35335C1261500008
delete  FROM STB_RawMaterialInputHist
WHERE Barcode = 'NM35335C1261500008' 
  AND RawMaterialBarcode = 'URL:VEM_090S00P_270R0665_Nordex_QK03001';

-- Sau khi chạy thành công và F5 kiểm tra thấy đúng trên phần mềm
--COMMIT TRAN;
