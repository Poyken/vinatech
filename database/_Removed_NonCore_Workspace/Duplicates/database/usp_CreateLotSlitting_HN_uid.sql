Text
----
-- =============================================

-- Author:		Mr.Duy

-- Create date: 2025-01-17

-- Description:	Chia tem theo s? lu?ng dã ch?n

-- =============================================

CREATE PROCEDURE [dbo].[usp_CreateLotSlitting_HN_uid]

	@pProcessUserID VARCHAR(20),

	@pProcessLanguage VARCHAR(20),

	@pLotID VARCHAR(20),

	@pChildmaterialcodeUse varchar(20),

	@pChildmaterialcode varchar(20),

	@psumTem INT ,

	@pSlitingLength NUMERIC(20, 10)

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

		--declare @aa varchar(20) = @psumTem

	

	SET NOCOUNT ON;

	DECLARE @Error NVARCHAR(500)

	DECLARE @MaterialLotNo VARCHAR(50)

	DECLARE @NewLotID VARCHAR(50)

	DECLARE @LotID VARCHAR(50)

	DECLARE @MaterialUnitCheck VARCHAR(50)

	DECLARE @MaterialUnitLotidCheck VARCHAR(50)

	DECLARE @ChildmaterialcodeView VARCHAR(50) = @pChildmaterialcode

	DECLARE @StartNumber INT = 1

	Declare @WidthSlitting NUMERIC(20, 10)		

	Declare @checkWidth int



	Declare @SumCurrentQty NUMERIC(20, 10)	

	Declare @sumTemCurrentQtyPoil NUMERIC(20, 10)	

	Declare @sumTemCurrentQtyPaper NUMERIC(20, 10)	

	Declare @RemainingQty NUMERIC(20, 10)	

	DECLARE @count INT = 1

  -- select @Materialcode=MaterialCode from stb_materiallotinfo where lotid= @pLotID

  -- if(@Materialcode is null or @Materialcode ='')

	--	 select @Materialcode=MaterialCode from stb_materialdoclotinfo where lotid= @pLotID

	



	select @MaterialUnitLotidCheck= isnull(mm.MaterialUnit,ws.MaterialUnit) from STB_WidthSlitting  ws

	full join STB_MaterialMaster mm on ws.materialcode = mm.materialcode

	 where isnull(mm.materialcode,ws.materialcode)=(select materialcode from stb_materiallotinfo where lotid=@pLotID )



	--ki?m tra n?u mà thu?c lo?i POil m?i c?n di?n chi?u dài

	select @MaterialUnitCheck = MaterialUnit from STB_WidthSlitting 

	 where materialcode=@pChildmaterialcode

	 -- RAISERROR(@MaterialUnitLotidCheck,16, 1)

		--	return;

	 -- ki?m tra xem don v? có gi?ng nhau không

	 if(@MaterialUnitCheck <> @MaterialUnitLotidCheck)

	 begin

		RAISERROR(N'Ðon v? dang sai b?n c?n ki?m tra l?i xem dã ch?n dúng nguyên li?u ho?c c?u hình don v? dúng chua !',16, 1)

			return;

	 end 



	

	if(@pSlitingLength <1 and @MaterialUnitCheck='M2') --n?u l?n hon 0 là chia tem dã b? quá 

		begin

			RAISERROR(N'B?n chua nh?p chi?u dài c?a cu?n !',16, 1)

			return;

		end



	select @SumCurrentQty =SUM(CurrentQty) from STB_MaterialLotInfo where PackingID=@pLotID and lotid <> PackingID -- l?y ra t?ng s? lu?ng dã chia

	

	-- n?u là POIL thì s? x?t di?u ki?n d? tính s? lu?ng

	if(@MaterialUnitCheck='M2')

	 begin

	 -- 1*275*(500

		select @sumTemCurrentQtyPoil= @psumTem*@pSlitingLength * (Width*(1.0)/1000)  from STB_WidthSlitting where MaterialCode=@pChildmaterialcode --tính ra s? lu?ng c?a khi mu?n tách tem poil

	 end

	-- n?u là gi?y thì s? x?t di?u ki?n d? tính s? lu?ng

	if(@MaterialUnitCheck='KG')

	 begin

		select @sumTemCurrentQtyPaper= @psumTem*Width  from STB_WidthSlitting where MaterialCode=@pChildmaterialcode --tính ra s? lu?ng c?a khi mu?n tách tem gi?y

	 end

	 --13.5



	select @count=COUNT(*) from stb_materiallotinfo where lotid=@pLotID  and lotid <> 'ML20250528000212'

	and ( (isnull(@SumCurrentQty,0)+isnull(@sumTemCurrentQtyPoil,0))>CurrentQty or (isnull(@SumCurrentQty,0)+isnull(@sumTemCurrentQtyPaper,0))>CurrentQty ) 



	--exec usp_CreateLotSlitting_HN_uid 'anhduy157','vi','SP20250308005690','10140760000','10140760000',14,199

	--print @count

	--return 

	if(@count >0) --n?u l?n hon 0 là chia tem dã b? quá 

		begin

			set @Error=N'Ðã vu?t quá s? lu?ng cho phép !'

			RAISERROR(@Error,16, 1)

			return;

		end



	WHILE @StartNumber <= @psumTem 

	BEGIN

		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialLotInfo',@MaterialLotNo OUTPUT

		EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialDocLotInfo', @NewLotID OUTPUT

		set @LotID ='SL' + SUBSTRING(@NewLotID, 3, LEN(@NewLotID) - 2) 

		

		select @WidthSlitting = Width from STB_WidthSlitting where MaterialCode=@pChildmaterialcode -- l?y ra chi?u r?ng ho?c cân n?ng c?a mã mu?n c?t



		Declare @checkMaterialCode int -- ki?m tra mã A230



		select @checkMaterialCode=count(*) from STB_MaterialMaster where materialcode=@pChildmaterialcode -- ki?m tra xem mã có thêm trên A230 hay không



		--declare @a varchar(50)=@pChildmaterialcode

		--	print @a +'----'

		--return 



		IF(@checkMaterialCode=0 and @pChildmaterialcode <>'NG') -- n?u không thêm trên A230 và không ph?i mã NG thì s? l?y theo mã nguyên li?u ban d?u c?t

		 BEGIN

			SELECT @pChildmaterialcode=MATERIALCODE FROM STB_MATERIALLOTINFO WHERE LOTID=@pLotID

		 END

		-- INSERT DATA

		 INSERT INTO STB_MaterialLotInfo

								(

									MaterialLotNo,

									LotID,

									CompanyCode,

									WorkCenterCode,

									MaterialWarehouseCode,

									MaterialLocationCode,

									MaterialCode,

									MaterialStockAttribute,

									StockAttrib1,

									StockAttrib2,

									StockAttrib3,

									PackingID,

									GRDate,

									MaterialDeliveryNo,

									MaterialDeliveryDetailNo,

									InitialQty,

									CurrentQty,

									PickingQty,

									VendorLotNo,

									LifeBasicDate,

									ProductionDate,

									EndOfLifeDate,

									LotNo,

									IsSplitLot,

									BefMaterialLotNo,

									LotAttr01,

									LotAttr02,

									LotAttr03,

									LotAttr04,

									LotAttr05,

									LotAttr06,

									LotAttr07,

									LotAttr08,

									LotAttr09,

									LotAttr10,

									CreateDateTime,

									CreateUserID,

									DateConfirmEx,

									HoldError,

									Holddate,

									HoldPeriod,

									PackingIdParent,

									LengthSlitting

							

								)

							select 

								

									@MaterialLotNo,

									@LotID,

									CompanyCode,

									WorkCenterCode,

									MaterialWarehouseCode,

									MaterialLocationCode,

									@pChildmaterialcodeUse,

									MaterialStockAttribute,

									StockAttrib1,

									StockAttrib2,

									StockAttrib3,

									@pLotID,

									GRDate,

									MaterialDeliveryNo,

									MaterialDeliveryDetailNo,

									case

									when @MaterialUnitCheck ='M2'

									then @pSlitingLength * ((@WidthSlitting*1.0)/1000)

									else @WidthSlitting

									end

									,

									case

									when @MaterialUnitCheck ='M2'

									then @pSlitingLength * ((@WidthSlitting*1.0)/1000)

									else @WidthSlitting

									end

									,

									0,

									VendorLotNo,

									LifeBasicDate,

									ProductionDate,

									EndOfLifeDate,

									LotNo,

									IsSplitLot,

									BefMaterialLotNo,

									LotAttr01,

									LotAttr02,

									LotAttr03,

									LotAttr04,

									LotAttr05,

									LotAttr06,

									@ChildmaterialcodeView, -- n?u các lot ? hà nam thì d?c tính 7 s? là mã code bé d? có th? d? nhìn

									LotAttr08,

									LotAttr09,

									LotAttr10,

									GETDATE(),

									@pProcessUserID,

									DateConfirmEx,

									HoldError,

									Holddate,

									HoldPeriod,

									@pLotID,

									case

									when @MaterialUnitCheck ='M2'

									then @pSlitingLength

									else 0

									end

								from stb_materiallotinfo 

								where Lotid=@pLotid

		set 		@pChildmaterialcode = 		@ChildmaterialcodeView		 -- set l?i d? không b? l?i t? tem 2 b? nh?n s? lu?ng th?ng cha

		SET @StartNumber = @StartNumber + 1	

	END

END





