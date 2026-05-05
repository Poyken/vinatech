-- Procedure: usp_CreateLotSlitting_NG_HN_uid
-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-02-07
-- Description:	Tạo tem NG với số lượng còn lại khi đã chia xong tem OK
-- =============================================
CREATE PROCEDURE [dbo].[usp_CreateLotSlitting_NG_HN_uid]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLotID VARCHAR(20)
AS
BEGIN

	--RAISERROR(@pLotID,16, 1)
	--		return;
	SET NOCOUNT ON;
	DECLARE @Error NVARCHAR(500)
	DECLARE @MaterialLotNo VARCHAR(50)
	DECLARE @NewLotID VARCHAR(50)
	DECLARE @LotID VARCHAR(50)
	DECLARE @StartNumber INT = 1
	Declare @WidthSlitting NUMERIC(20, 10)		
	Declare @checkWidth int

	Declare @SumCurrentQty NUMERIC(20, 10)	
	Declare @TemCurrentQtyNG NUMERIC(20, 10)	
	Declare @RemainingQty NUMERIC(20, 10)	
	DECLARE @count INT = 1
	DECLARE @IsSlitting bit
	DECLARE @materialUnitCheck VARCHAR(50)
	-- Tổng ban đầu -  tổng số đã chia = số lượng NG
	-- kiểm tra trường hợp = 0 thì k chia nữa
	select @materialUnitCheck=materialUnit from STB_MaterialMaster where materialcode = (select materialcode from stb_materiallotinfo where lotid=@pLotID) -- lấy ra đơn vị

	-- kiểm tra xem đơn vị là M2 và KG hay không Poil và giấy đang tính đơn vị như thế này
	if(@materialUnitCheck not in ('M2','KG'))
	begin
		 RAISERROR( N'Đơn vị đang bị sai không phải là "M2" và "KG" !' ,16, 1)
			return
	end 

	select @SumCurrentQty =SUM(InitialQty) from STB_MaterialLotInfo where PackingID=@pLotID and lotid <> PackingID -- lấy ra tổng số lượng đã chia
	
	select @IsSlitting= IsSlitting , @TemCurrentQtyNG = isnull(InitialQty,0)-isnull(@SumCurrentQty,0) from stb_materiallotinfo where lotid=@pLotID  -- tính ra số lượng tem NG
	
	--DECLARE @MaterialLotNo11 VARCHAR(50)=@TemCurrentQtyNG
	--RAISERROR(@MaterialLotNo11,16, 1)
	--return 
		
	if(@IsSlitting =1)
		begin
			RAISERROR( N'Lot này đã chốt rồi không thể chia tem nữa !' ,16, 1)
			return
		end

	if(@TemCurrentQtyNG <=0 ) --nếu lớn hơn 0 là chia tem đã bị quá 
		begin
			set @Error=N'Tem đã chia xong rồi không chia được nữa !'
			RAISERROR(@Error,16, 1)
			return;
		end
	--print @count
	--return 
	
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialLotInfo',@MaterialLotNo OUTPUT
			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialDocLotInfo', @NewLotID OUTPUT
		set @LotID ='SL' + SUBSTRING(@NewLotID, 3, LEN(@NewLotID) - 2) 
		
	
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
									case 
									when @materialUnitCheck ='M2'
									then 'NG_Poil'
									else 'NG_ConPaper'
									end,
									MaterialStockAttribute,
									StockAttrib1,
									StockAttrib2,
									StockAttrib3,
									@pLotID,
									GRDate,
									MaterialDeliveryNo,
									MaterialDeliveryDetailNo,
									@TemCurrentQtyNG, --InitialQty,
									@TemCurrentQtyNG,
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
									LotAttr07,
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
									NULL
								from stb_materiallotinfo 
								where Lotid=@pLotid
								
	
	
END

GO

