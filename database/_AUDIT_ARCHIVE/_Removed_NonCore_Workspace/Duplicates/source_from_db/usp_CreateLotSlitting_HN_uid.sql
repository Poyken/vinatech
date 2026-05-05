-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-01-17
-- Description:	Chia tem theo số lượng đã chọn
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

	--kiểm tra nếu mà thuộc loại POil mới cần điền chiều dài
	select @MaterialUnitCheck = MaterialUnit from STB_WidthSlitting 
	 where materialcode=@pChildmaterialcode
	 -- RAISERROR(@MaterialUnitLotidCheck,16, 1)
		--	return;
	 -- kiểm tra xem đơn vị có giống nhau không
	 if(@MaterialUnitCheck <> @MaterialUnitLotidCheck)
	 begin
		RAISERROR(N'Đơn vị đang sai bạn cần kiểm tra lại xem đã chọn đúng nguyên liệu hoặc cấu hình đơn vị đúng chưa !',16, 1)
			return;
	 end 

	
	if(@pSlitingLength <1 and @MaterialUnitCheck='M2') --nếu lớn hơn 0 là chia tem đã bị quá 
		begin
			RAISERROR(N'Bạn chưa nhập chiều dài của cuộn !',16, 1)
			return;
		end

	select @SumCurrentQty =SUM(CurrentQty) from STB_MaterialLotInfo where PackingID=@pLotID and lotid <> PackingID -- lấy ra tổng số lượng đã chia
	
	-- nếu là POIL thì sẽ xết điều kiện để tính số lượng
	if(@MaterialUnitCheck='M2')
	 begin
	 -- 1*275*(500
		select @sumTemCurrentQtyPoil= @psumTem*@pSlitingLength * (Width*(1.0)/1000)  from STB_WidthSlitting where MaterialCode=@pChildmaterialcode --tính ra số lượng của khi muốn tách tem poil
	 end
	-- nếu là giấy thì sẽ xết điều kiện để tính số lượng
	if(@MaterialUnitCheck='KG')
	 begin
		select @sumTemCurrentQtyPaper= @psumTem*Width  from STB_WidthSlitting where MaterialCode=@pChildmaterialcode --tính ra số lượng của khi muốn tách tem giấy
	 end
	 --13.5

	select @count=COUNT(*) from stb_materiallotinfo where lotid=@pLotID  and lotid <> 'ML20250528000212'
	and ( (isnull(@SumCurrentQty,0)+isnull(@sumTemCurrentQtyPoil,0))>CurrentQty or (isnull(@SumCurrentQty,0)+isnull(@sumTemCurrentQtyPaper,0))>CurrentQty ) 

	--exec usp_CreateLotSlitting_HN_uid 'anhduy157','vi','SP20250308005690','10140760000','10140760000',14,199
	--print @count
	--return 
	if(@count >0) --nếu lớn hơn 0 là chia tem đã bị quá 
		begin
			set @Error=N'Đã vượt quá số lượng cho phép !'
			RAISERROR(@Error,16, 1)
			return;
		end

	WHILE @StartNumber <= @psumTem 
	BEGIN
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialLotInfo',@MaterialLotNo OUTPUT
		EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialDocLotInfo', @NewLotID OUTPUT
		set @LotID ='SL' + SUBSTRING(@NewLotID, 3, LEN(@NewLotID) - 2) 
		
		select @WidthSlitting = Width from STB_WidthSlitting where MaterialCode=@pChildmaterialcode -- lấy ra chiều rộng hoặc cân nặng của mã muốn cắt

		Declare @checkMaterialCode int -- kiểm tra mã A230

		select @checkMaterialCode=count(*) from STB_MaterialMaster where materialcode=@pChildmaterialcode -- kiểm tra xem mã có thêm trên A230 hay không

		--declare @a varchar(50)=@pChildmaterialcode
		--	print @a +'----'
		--return 

		IF(@checkMaterialCode=0 and @pChildmaterialcode <>'NG') -- nếu không thêm trên A230 và không phải mã NG thì sẽ lấy theo mã nguyên liệu ban đầu cắt
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
									@ChildmaterialcodeView, -- nếu các lot ở hà nam thì đặc tính 7 sẽ là mã code bé để có thể dễ nhìn
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
		set 		@pChildmaterialcode = 		@ChildmaterialcodeView		 -- set lại để không bị lỗi từ tem 2 bị nhận số lượng thằng cha
		SET @StartNumber = @StartNumber + 1	
	END
END


