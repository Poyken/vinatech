create PROCEDURE usp_getWarehouseStationery_popup
as	
begin
	select	WarehouseCode,
			WarehouseName
	from stb_warehouseStationery
end

