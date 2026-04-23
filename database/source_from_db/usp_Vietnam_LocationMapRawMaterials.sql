

CREATE PROCEDURE [dbo].[usp_Vietnam_LocationMapRawMaterials] 
	@pProcessLanguage VARCHAR(20), 
	@pProcessUserID VARCHAR(20), 
	@pCompanyCode VARCHAR(20) = NULL, 
	@pLocation VARCHAR(20) = NULL, 
	@pLotID VARCHAR(20) = NULL ,
	@pMaterialCode VARCHAR(20) = NULL
AS 
BEGIN 

	SET NOCOUNT ON; 

	declare @cout INT=0;

	select '' as LotAttr09 ;

	if(@pLocation is null   or   rtrim(ltrim(@pLocation)) = '' ) begin 
		raiserror (N'Chưa nhập Mã Vị trí, vui lòng nhập Mã Vị trí',16,1); 
		return; 
	end 


	if(upper(@pLocation)='CANCELLINK') begin 
		
		select @cout= count(*) from  
		( 
 		select LotAttr09 from STB_MaterialDocLotInfo where LotID=@pLotID union all  
		select LotAttr09 from STB_MaterialLotInfo where LotID=@pLotID 
		)  tbn ; 		
		
		if(@pLotID is not null   and   rtrim(ltrim(@pLotID)) <> '' ) begin 			
	
				if(@cout=0  ) begin 
					raiserror (N'Mã Lót không tồn tại trong hệ thống nên không Hủy Link được',16,1); 
					return; 
				end 
				-- Hải Triều(Dev) thêm đẻ huỷ vị trí cho nhà máy Hà Nam
			update STB_MaterialDocLotInfo set LotAttr09='' where LotID=@pLotID and (MaterialLocationCode like 'ROH_VN_WH%' or MaterialLocationCode like 'ROH_BG_WH%' or MaterialLocationCode like 'MODULE_BG2_WH%' or MaterialLocationCode like 'ROH_HN_WH%');		
			update STB_MaterialLotInfo set LotAttr09='' where LotID=@pLotID and MaterialWarehouseCode in ('ROH_VN_WH','ROH_BG_WH', 'MODULE_BG2_WH','ROH_HN_WH');

			select N'Hủy Link thành công: '+@pLocation as MaterialLotNo,@pLotID as LotID

		end 
		else  
		begin 
				if(@pMaterialCode is  null or rtrim(ltrim(@pMaterialCode)) = '') begin 								
						raiserror (N'Vui lòng chọn Mã Nguyên liệu, hoặc Scan mã Lót , Lựa chọn mã Lót',16,1);  
						return;  			
				end 
							
					select * from STB_MaterialLotInfo 
					where MaterialWarehouseCode in ('ROH_VN_WH','ROH_BG_WH','MODULE_BG2_WH') 
					and (LotAttr09 is not null and rtrim(ltrim(LotAttr09))<>'') 
					and MaterialCode=@pMaterialCode; 				
		end  
			
		return; 

	end 

	

	--;with lstposition as ( 
	--	select 'A1-1' as WarehouseLocation union all  
	--	select 'A1-2'  union all 
	--	select 'A1-3'  union all 
	--	select 'A1-4'  union all 
	--	select 'A1-5'  union all 
	--	select 'A1-6'  union all 
	--	select 'A1-7'  union all 
	--	select 'A1-8'  union all 
	--	select 'A2-1'  union all 
	--	select 'A2-2'  union all 
	--	select 'A2-3'  union all 
	--	select 'A2-4'  union all 
	--	select 'A2-5'  union all 
	--	select 'A2-6'  union all 
	--	select 'A2-7'  union all 
	--	select 'A2-8'  union all 
	--	select 'B1'  union all 
	--	select 'B2'  union all 
	--	select 'B3'  union all 
	--	select 'B4'  union all 
	--	select 'B5'  union all 
	--	select 'B6'  union all 
	--	select 'B7'  union all 
	--	select 'B8'  union all 
	--	select 'B9'  union all 
	--	select 'C1-1'  union all 
	--	select 'C1-2'  union all 
	--	select 'C1-3'  union all 
	--	select 'C1-4'  union all 
	--	select 'C1-5'  union all 
	--	select 'C1-6'  union all 
	--	select 'C1-7'  union all 
	--	select 'C1-8'  union all 
	--	select 'C2-1'  union all 
	--	select 'C2-2'  union all 
	--	select 'C2-3'  union all 
	--	select 'C2-4'  union all 
	--	select 'C2-5'  union all 
	--	select 'C2-6'  union all 
	--	select 'C2-7'  union all 
	--	select 'C2-8'  union all 
	--	select 'D1-1'  union all 
	--	select 'D1-2'  union all 
	--	select 'D1-3'  union all 
	--	select 'D1-4'  union all 
	--	select 'D1-5'  union all 
	--	select 'D1-6'  union all 
	--	select 'D1-7'  union all 
	--	select 'D1-8'  union all 
	--	select 'D2-1'  union all 
	--	select 'D2-2'  union all 
	--	select 'D2-3'  union all 
	--	select 'D2-4'  union all 
	--	select 'D2-5'  union all 
	--	select 'D2-6'  union all 
	--	select 'D2-7'  union all 
	--	select 'D2-8'  union all 
	--	select 'E1-1'  union all 
	--	select 'E1-2'  union all 
	--	select 'E2-1'  union all 
	--	select 'E2-2' 
	--	)
	--	select @cout=count(*) from lstposition where WarehouseLocation=@pLocation; 



		--if(@cout=0) begin 
		--	raiserror (N'Mã Vị trí không đúng, hoặc thiếu (thừa) kí tự',16,1); 
		--	return; 
		--end 



		if(@pMaterialCode is  null or rtrim(ltrim(@pMaterialCode)) = '') begin
			set @pMaterialCode='';
			if(@pLotID is null   or   rtrim(ltrim(@pLotID)) = '' ) begin 	
			raiserror (N'Mã Vị trí Hợp lệ, vui lòng Scan mã Lót hoặc Lựa chọn mã Lót',16,1); 
			return; 
			end 
		end
		else
		begin
			select * from STB_MaterialLotInfo
			where MaterialWarehouseCode in ('ROH_VN_WH','ROH_BG_WH', 'MODULE_BG2_WH','ROH_HN_WH') 
			and (LotAttr09 is null or LotAttr09='')
			and MaterialCode=@pMaterialCode;
			if(@pLotID is null   or   rtrim(ltrim(@pLotID)) = '' ) begin 	
				return; 
			end 
		end
		


		declare @lotattr9 varchar(50) = '';
		select @lotattr9=LotAttr09,@cout=count(*) from STB_MaterialDocLotInfo where LotID=@pLotID group by LotAttr09;

		if(@cout=0) begin 
			declare @WarehouseCode varchar(50)=''; 
			select @WarehouseCode=MaterialWarehouseCode,@cout=count(*) from STB_MaterialLotInfo where LotID=@pLotID group by MaterialWarehouseCode; 
			if(@cout=0) begin 
				raiserror (N'Sai Mã Lót, mã Lót không tồn tại trong hệ thống',16,1); 
				return; 
			end 

			select @cout=count(*) from STB_MaterialLotInfo where LotID=@pLotID and (MaterialWarehouseCode='ROH_VN_WH' OR MaterialWarehouseCode='MODULE_BG2_WH' OR MaterialWarehouseCode='ROH_HN_WH');
			if(@cout=0) begin 
				declare @errr nvarchar(100) = N'Mã Lót đã chuyển Kho: '+@WarehouseCode+N', không thể Link với vị trí trong kho NVL thô';
				raiserror (@errr,16,1); 
				return; 
			end 
		end 

		if(@lotattr9 is not null and rtrim(ltrim(@lotattr9)) <> '' )begin 
				declare @errr1 nvarchar(100) = N'Mã Lót đã Link với kho: '+ @lotattr9 +N'. Vui lòng sử dụng chức năng Hủy Link mã Vị trí trước!';
				raiserror (@errr1,16,1); 
				return; 
		end 
		--  Hải Triều(Dev) thêm đẻ huỷ vị trí cho nhà máy Hà Nam

		update STB_MaterialDocLotInfo set LotAttr09=@pLocation where LotID=@pLotID and (MaterialLocationCode like 'ROH_VN_WH%' or MaterialLocationCode like 'ROH_BG_WH%' or MaterialLocationCode like 'MODULE_BG2_WH%' OR MaterialLocationCode LIKE 'ROH_HN_WH%');	
		update STB_MaterialLotInfo set LotAttr09=@pLocation where LotID=@pLotID and MaterialWarehouseCode in ('ROH_VN_WH','ROH_BG_WH', 'MODULE_BG2_WH','ROH_HN_WH'); 

		select N'Lót được link thành công với Vị trí: '+@pLocation as MaterialLotNo,@pLotID as LotID

END
