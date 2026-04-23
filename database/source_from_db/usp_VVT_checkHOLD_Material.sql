

CREATE PROCEDURE [dbo].[usp_VVT_checkHOLD_Material]
	@lotid VARCHAR(20) = null,
	@output nvarchar(500)=null output
AS

BEGIN
	SET NOCOUNT ON;
	
	if( ltrim(rtrim(isnull(@lotid,''))) like 'ML%' or ltrim(rtrim(isnull(@lotid,''))) like 'SP%') begin

		--if( ltrim(rtrim(upper(@lotid))) not like 'ML%' 
		--   and ltrim(rtrim(upper(@lotid))) not like 'SP%') begin
		--		raiserror (N'Mã Lot Nguyên liệu sai định dạng. Vui lòng dùng Lót liệu khác!!   dbo.usp_VVT_checkHOLD_Material ' ,16,1) ; 
		--		return;
		--end
		
		declare @count int=0
		select @count = count(*) 
		from STB_MaterialLotInfo
		where lotid like '%' +ltrim(rtrim(@lotid))+ '%' 
		and (MaterialWarehouseCode like '%NG%' or MaterialWarehouseCode like '%HOLD%');
		
		if(@count>0) 
		begin
				declare  @err nvarchar(500)= @lotid + N' Mã Lot Nguyên liệu đang bị HOLD, nên không thể sử dụng cho Sản xuất. Vui lòng dùng Lót liệu khác!!    dbo.usp_VVT_checkHOLD_Material '
				
				if(@output is not null) 
					set @output =  @err;
				else
					raiserror ( @err ,16,1) ; 

				return;
		end
	end
		
END