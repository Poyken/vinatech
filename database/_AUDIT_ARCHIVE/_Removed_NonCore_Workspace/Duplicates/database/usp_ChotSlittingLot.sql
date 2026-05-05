Text
----




-- =============================================

-- Author: Kim Han Young(hykim@awoo.co.kr)

-- Group : ????

-- Browsable : true

-- Create date: 2016-09-26

-- Description: ??? Split ???.

-- =============================================

CREATE PROCEDURE [dbo].[usp_ChotSlittingLot]

	@pProcessUserID VARCHAR(20),

	@pProcessLanguage VARCHAR(20),

    @pProcessViewName VARCHAR(50),

	@pXml NVARCHAR(MAX) = null

AS





BEGIN

	SET NOCOUNT ON;





	--raiserror(@pProcessViewName,16,1) return

	--set  @pProcessViewName  ='STB_MaterialLotInfo_test'

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID

    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage

    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName

    DECLARE @InsertTableName VARCHAR(100) =   '/DataSet/' +@ProcessViewName --+ '_INSERT'

    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'

    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'

    DECLARE @ERROR_MSG NVARCHAR(MAX)

    DECLARE @IUD_FLAG VARCHAR(10)

    DECLARE @IsAutoKey BIT

    DECLARE @IsLoopIUD BIT

    DECLARE @PrefixString VARCHAR(20)

    DECLARE @SerialLen INT







     --Declare Columns Variable

DECLARE @OldMaterialLotNo VARCHAR(20)

DECLARE @MaterialLotNo VARCHAR(20)

DECLARE @LotID VARCHAR(50)

DECLARE @CompanyCode VARCHAR(20)

DECLARE @WorkCenterCode VARCHAR(20)

DECLARE @MaterialWarehouseCode VARCHAR(20)

DECLARE @MaterialWarehouseName VARCHAR(100)

DECLARE @MaterialLocationCode VARCHAR(20)

DECLARE @MaterialLocationName VARCHAR(100)

DECLARE @MaterialCode VARCHAR(50)

DECLARE @MaterialName VARCHAR(100)

DECLARE @MaterialTypeCode VARCHAR(20)

DECLARE @MaterialTypeName VARCHAR(100)

DECLARE @ProductGroupCode VARCHAR(20)

DECLARE @ProductGroupName VARCHAR(100)

DECLARE @MaterialSpec VARCHAR(100)

DECLARE @MaterialStockAttribute VARCHAR(20)

DECLARE @StockAttrib1 VARCHAR(20)

DECLARE @StockAttrib2 VARCHAR(20)

DECLARE @StockAttrib3 VARCHAR(20)

DECLARE @PackingID VARCHAR(50)

DECLARE @GRDate VARCHAR(10)

DECLARE @MaterialDeliveryNo VARCHAR(20)

DECLARE @MaterialDeliveryDetailNo VARCHAR(20)

DECLARE @InitialQty NUMERIC(20,5)

DECLARE @CurrentQty NUMERIC(20,5)

DECLARE @StockQty NUMERIC(20,5)

DECLARE @PickingQty NUMERIC(20,5)

DECLARE @AvailableQty NUMERIC(20,5)

DECLARE @VendorLotNo VARCHAR(100)

DECLARE @LifeBasicDate DATE

DECLARE @ProductionDate DATE

DECLARE @EndOfLifeDate DATE

DECLARE @LotNo VARCHAR(500)

DECLARE @IsSplitLot BIT

DECLARE @SplitQty NUMERIC(20,5)

DECLARE @BefMaterialLotNo VARCHAR(20)

DECLARE @CreateDateTime DATETIME

DECLARE @CreateUserID VARCHAR(20)

DECLARE @ChangeDateTime DATETIME

DECLARE @ChangeUserID VARCHAR(20)

DECLARE @LabelType VARCHAR(50)

DECLARE @LabelFormatName VARCHAR(100)

DECLARE @CommandType VARCHAR(50)

DECLARE @MaterialUnit VARCHAR(20)

DECLARE @MMExtText02 VARCHAR(255)

DECLARE @MMExtText03 VARCHAR(255)

DECLARE @LotAttr10 NVARCHAR(100)

DECLARE @PackDate DATE

DECLARE @PackingIdParent VARCHAR(50)

		



  

	

	DECLARE @iDoc INT



    EXEC SmartFramework.dbo.usp_GetSerialRule 

			@pTableName = 'STB_MaterialLotInfo',

			@pIsAutoKey = @IsAutoKey OUTPUT,

			@pIsLoopIUD = @IsLoopIUD OUTPUT,

			@pPrefixData = @PrefixString OUTPUT,

			@pSerialLen = @SerialLen OUTPUT











--	---------------------------------------------------------------------------------------------------------------------------------

	 EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		

		DECLARE @IsSlitting bit

		SELECT

					@LotID=	PackingIdParent

					

		FROM

				OPENXML(@idoc , @InsertTableName , 2)

				WITH  (

							

					 PackingIdParent VARCHAR(50)

							

						) -- select * from STB_MaterialLotInfo where isSlitting is not null

						

		DECLARE @InitialQtyPar NUMERIC(20,5)		

		DECLARE @SlittingQty NUMERIC(20,5)		

		select @IsSlitting= IsSlitting 

		from STB_MaterialLotInfo Where LotID=@LotID

		

		select @SlittingQty= SUM(InitialQty) from STB_MaterialLotInfo where PackingIdParent=@LotID

		

		select @InitialQtyPar = ActualExportQuantity from STB_MaterialWarehouseInOutHist Where LotID=@LotID 



		if(@IsSlitting =1)

		begin

			RAISERROR( N'Lot này dã ch?t r?i không th? ch?t n?a' ,16, 1)

			return

		end

		if(@SlittingQty>@InitialQtyPar or @SlittingQty < @InitialQtyPar)

		begin

			RAISERROR( N'T?ng s? lu?ng lot slitting l?n hon ho?c nh? hon s? lu?ng lot cha' ,16, 1)

			return

		end



		update STB_MaterialLotInfo set CurrentQty=0 ,IsParrent='1', isSlitting = 1 ,CreateDateSlittingTime=getdate() where LotID=@LotID

		update STB_MaterialLotInfo set isSlitting = 1 where PackingIdParent=@LotID



EXEC sp_xml_removedocument @idoc



END



