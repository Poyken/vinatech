CREATE PROCEDURE usp_getWarehouse_popup
as	
begin
	select	WarehouseCode,
			WarehouseName
	from stb_warehouseStationery
end