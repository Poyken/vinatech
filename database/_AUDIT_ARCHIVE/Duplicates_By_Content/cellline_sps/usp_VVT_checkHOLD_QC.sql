


CREATE PROCEDURE [dbo].[usp_VVT_checkHOLD_QC]
				@pLotNo VARCHAR(20) = NULL--,
				--@pPackingID VARCHAR(20) = NULL,
				--@pPartNo VARCHAR(20) = NULL
AS
BEGIN

return;

	SET NOCOUNT ON;

		if(isnull(@pLotNo,'')='') return;
	
	declare @ccount INT=0;

			DECLARE @LotNonew1 VARCHAR(20) = ''
					DECLARE @LotNonew2 VARCHAR(20) = ''
					DECLARE @LotNonew3 VARCHAR(20) = ''
					DECLARE @LotNonew4 VARCHAR(20) = ''
					DECLARE @LotNonew5 VARCHAR(20) = ''
					DECLARE @LotNonew6 VARCHAR(20) = ''

					
					select @LotNonew1 = NewBarcode
					from STB_LotChangeMaterialHistory  WITH(NOLOCK)
					where OldBarcode=@pLotNo 
	
					select @LotNonew2 = NewBarcode
					from STB_LotChangeMaterialHistory  WITH(NOLOCK)
					where OldBarcode=@LotNonew1 

					select @LotNonew3 = NewBarcode
					from STB_LotChangeMaterialHistory  WITH(NOLOCK)
					where OldBarcode=@LotNonew2 

	select @LotNonew4 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew3 ;

	select @LotNonew5 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew4 ;

	select @LotNonew6 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew5 ;
	

	
		select @ccount=count(*) 
		from [STB_hodl_situationVVT]
		where [type]='Hold' 
		and LotNo in (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)


		if(@ccount=0)begin
				select @ccount=count(*) 	 
				FROM [SmartFactoryV2].[dbo].[STB_MaterialQcInfo]
				where inspectiondoctype='OQC' and DecisionResult='Hold' 
				and materialqcno in (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)
		end


		if(@ccount>0) begin
			raiserror (N'Mã Lot %s đang bị HOLD. Liên hệ QC để hỗ trợ giải HOLD  C535',16,1,@pLotNo)
			return;
		end

		
		select count(*)  from stb_setinfo WITH(NOLOCK) where isnull(SIExtInt01,0)=1 and
		Barcode in (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)
		if(@ccount>0) begin
			raiserror (N'Mã Lot %s đang bị chặn hoặc Hủy bỏ. Liên hệ SX & EA hỗ trợ kiểm tra kế hoạch  B450 (stb_setinfo where SIExtInt01)',16,1,@pLotNo)
			return;
		end


		select @ccount=count(*) 	 
		FROM [SmartFactoryV2].[dbo].[STB_MaterialQcInfo]
		where inspectiondoctype='OQC' and DecisionResult='Pass' 
		and materialqcno in (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)


		if(@ccount=0) begin
			raiserror (N'Mã Lot %s chưa Pass tại OQC. Liên hệ OQC hỗ trợ kiểm tra C530 ',16,1,@pLotNo)
			return;
		end

END





































