CREATE PROCEDURE [dbo].[usp_getWarehouseStationeryTo_popup]
as	
begin
	select	WarehouseCode as ToSWarehouse,
			WarehouseName as ToWarehouseName
	from stb_warehouseStationery where WarehouseCode !='KNVL'
end
