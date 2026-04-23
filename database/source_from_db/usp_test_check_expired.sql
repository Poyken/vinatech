
-- =============================================
-- Author: Mr.Duy
-- Create date: 2023-12-05
-- Browsable : true
-- =============================================
--exec usp_test_check_expired 'VVNP0120001E02'
CREATE PROCEDURE [dbo].[usp_test_check_expired] 
	@pRawMaterialBarcode1 NVARCHAR(200) 
AS
BEGIN
	
	if(@pRawMaterialBarcode1 ='')
	begin
		DECLARE @errNullest_check_expired  nvarchar(200)
		set @errNullest_check_expired=N'Bị Null';
		RAISERROR(@errNullest_check_expired,16,1)
	end
	declare @OpenExpired bit = 0 
	 	;with data1 as (
			select LotID,max(createdatetime) as createdatetime
			from stb_vvt_OpenExpiredMaterial  with(nolock) 
			where (LotID=substring(@pRawMaterialBarcode1,1,14)  )
			group by lotid
		)
		select top 1 @OpenExpired = voem.OpenExpired 
		from stb_vvt_OpenExpiredMaterial voem with(nolock) 
		join data1 on voem.lotid=data1.lotid and voem.createdatetime = data1.createdatetime

		
		if(isnull(@OpenExpired,0)=0 or @OpenExpired=0 or convert(bit,@OpenExpired)=0)
			   begin
					if(@pRawMaterialBarcode1 like 'VV%' or @pRawMaterialBarcode1 like 'VJ%')
						begin
							DECLARE @time22 varchar(20)
							DECLARE @nDay int
							DECLARE @err22  nvarchar(200)
							SET @time22=dbo.fn_VVT_getdatebyVendorLot('SRFYPK0',@pRawMaterialBarcode1)
							SET @nDay = Cast(DATEDIFF(dd,@time22, GETDATE()) as int)
								if(@nDay>=90)
								begin
									set @err22=N'Mã Lot đã hết hạn.Vui lòng muốn mở liên hệ với QC :' +@pRawMaterialBarcode1;
									--print @err22
									RAISERROR(@err22,16,1)
								end
							
						end
				end

END
