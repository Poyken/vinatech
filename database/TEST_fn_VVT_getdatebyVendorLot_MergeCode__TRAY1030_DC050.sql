/*
Test nhanh sau khi deploy patch cho fn_VVT_getdatebyVendorLot_MergeCode:
Kỳ vọng: VendorLot '20260507' => '2026-05-07'
*/

SELECT dbo.fn_VVT_getdatebyVendorLot_MergeCode('TRAY1030-DC050', '20260507', '') AS ParsedDate;
-- Expected: 2026-05-07

