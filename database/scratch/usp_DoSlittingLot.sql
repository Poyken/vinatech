

-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : 재고관리
-- Browsable : true
-- Create date: 2016-09-26
-- Description: 재고를 Split 합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSlittingLot]
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
    DECLARE @InsertTableName VARCHAR(100) =   '/DataSet/' +@ProcessViewName + '_INSERT'
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
DECLARE @MaterialLotNo VARCHAR(50)
DECLARE @LotID VARCHAR(50)
DECLARE @CompanyCode VARCHAR(20)
DECLARE @WorkCenterCode VARCHAR(20)
DECLARE @MaterialWarehouseCode VARCHAR(20)
DECLARE @MaterialLocationCode VARCHAR(20)
DECLARE @MaterialCode VARCHAR(100)
DECLARE @MaterialStockAttribute VARCHAR(100)
DECLARE @StockAttrib1 VARCHAR(20)
DECLARE @StockAttrib2 VARCHAR(20)
DECLARE @StockAttrib3 VARCHAR(20)
DECLARE @PackingID VARCHAR(50)
DECLARE @GRDate VARCHAR(50)	
DECLARE @MaterialDeliveryNo VARCHAR(50)
DECLARE @MaterialDeliveryDetailNo VARCHAR(50)
DECLARE @InitialQty DECIMAL(18,2)
DECLARE @CurrentQty DECIMAL(18,2)
DECLARE @PickingQty DECIMAL(18,2)
DECLARE @VendorLotNo VARCHAR(50)
DECLARE @LifeBasicDate DATE
DECLARE @ProductionDate DATE
DECLARE @EndOfLifeDate DATE
DECLARE @LotNo VARCHAR(50)
DECLARE @IsSplitLot BIT
DECLARE @BefMaterialLotNo VARCHAR(50)
DECLARE @LotAttr01 VARCHAR(100)
DECLARE @LotAttr02 VARCHAR(100)
DECLARE @LotAttr03 VARCHAR(100)
DECLARE @LotAttr04 VARCHAR(100)
DECLARE @LotAttr05 VARCHAR(100)
DECLARE @LotAttr06 VARCHAR(100)
DECLARE @LotAttr07 VARCHAR(100)
DECLARE @LotAttr08 VARCHAR(100)
DECLARE @LotAttr09 VARCHAR(100)
DECLARE @LotAttr10 VARCHAR(100)
DECLARE @CreateDateTime DATETIME
DECLARE @CreateUserID VARCHAR(50)
DECLARE @ChangeDateTime DATETIME
DECLARE @ChangeUserID VARCHAR(50)
DECLARE @DateConfirmEx DATE
DECLARE @HoldError BIT
DECLARE @Holddate DATE
DECLARE @HoldPeriod INT
DECLARE @PackingIdParent VARCHAR(50)
DECLARE @IsSlitting BIT
DECLARE @CheckTime DATETIME
DECLARE @CheckUserID VARCHAR(50)
DECLARE @IsCheck BIT
DECLARE @LengthSlitting DECIMAL(18,2)
Declare @WidthSlitting NUMERIC(20,5)		
Declare @checkWidth int 
	
	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialLotInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT





--	---------------------------------------------------------------------------------------------------------------------------------
EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
			SELECT
					@LotID=	PackingIdParent
		FROM
				OPENXML(@idoc , @InsertTableName , 2)
				WITH  (
							
					 PackingIdParent VARCHAR(50)
							
		) 
		declare @isCheckSlitting int;
		select @isCheckSlitting=COUNT(LotID) from STB_MaterialLotInfo where LotID=@LotID and isSlitting=1
		if(@isCheckSlitting>0)
		begin
			RAISERROR( N'Lot này đã  chốt slitting không thể thay đổi nữa' ,16, 1)
			return
		end 
		

EXEC sp_xml_removedocument @idoc

--	---------------------------------------------------------------------------------------------------------------------------
       DECLARE @NewLotID VARCHAR(50)
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN

	print '123'


    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
               SELECT
									'INSERT' AS IUD_FLAG,
												OldMaterialLotNo,
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
												DateConfirmEx,
												HoldError,
												Holddate,
												HoldPeriod,
												PackingIdParent,
												LengthSlitting
				FROM
					OPENXML(@idoc, @InsertTableName, 2)
					WITH  (
								OldMaterialLotNo VARCHAR(20),
								MaterialLotNo VARCHAR(20),
								LotID VARCHAR(20),				   
								 CompanyCode VARCHAR(20),   
								 WorkCenterCode VARCHAR(20),
								 MaterialWarehouseCode VARCHAR(20),
								MaterialLocationCode VARCHAR(20),
								 MaterialCode VARCHAR(50)	  ,
								 MaterialStockAttribute VARCHAR(20),
								 StockAttrib1 VARCHAR(20)		,
								 StockAttrib2  VARCHAR(20)	,
								 StockAttrib3 VARCHAR(20),
								 PackingID VARCHAR(20)			,
								 GRDate VARCHAR(10)	 ,
								MaterialDeliveryNo VARCHAR(20),
								MaterialDeliveryDetailNo VARCHAR(20),
								 InitialQty DECIMAL(18,2),
								 CurrentQty DECIMAL(18,2) ,
								 PickingQty DECIMAL(18,2)		 ,
								 VendorLotNo VARCHAR(50)	 ,
								 LifeBasicDate DATE					 ,
								 ProductionDate DATE			   ,
								 EndOfLifeDate DATE					,
								 LotNo VARCHAR(50)				  ,
								 IsSplitLot BIT,							  
								 BefMaterialLotNo VARCHAR(50),
								 LotAttr01 VARCHAR(100)			 ,
								 LotAttr02 VARCHAR(100)			 ,
								 LotAttr03 VARCHAR(100)			 ,
								 LotAttr04 VARCHAR(100)			 ,
								 LotAttr05 VARCHAR(100)			 ,
								 LotAttr06 VARCHAR(100)			 ,
								 LotAttr07 VARCHAR(100)			 ,
								 LotAttr08 VARCHAR(100)			 ,
								 LotAttr09 VARCHAR(100)			 ,
								 LotAttr10 VARCHAR(100)			 ,
								 DateConfirmEx DATE				   ,
								 HoldError BIT							 ,
								 Holddate DATE						  ,
								 HoldPeriod INT						   ,
								 PackingIdParent VARCHAR(50) ,
								 LengthSlitting DECIMAL(18,2)	
					)

							UNION ALL
						SELECT
								'UPDATE' AS IUD_FLAG,
								CASE 
									WHEN OldMaterialLotNo IS NULL THEN MaterialLotNo
									ELSE OldMaterialLotNo
								END AS OldMaterialLotNo,
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
												DateConfirmEx,
												HoldError,
												Holddate,
												HoldPeriod,
												PackingIdParent,
												LengthSlitting
							FROM
								OPENXML(@idoc, @UpdateTableName, 2)
								WITH  (
									OldMaterialLotNo VARCHAR(20),
								MaterialLotNo VARCHAR(20),
								LotID VARCHAR(20),				   
								 CompanyCode VARCHAR(20),   
								 WorkCenterCode VARCHAR(20),
								 MaterialWarehouseCode VARCHAR(20),
								MaterialLocationCode VARCHAR(20),
								 MaterialCode VARCHAR(50)	  ,
								 MaterialStockAttribute VARCHAR(20),
								 StockAttrib1 VARCHAR(20)		,
								 StockAttrib2  VARCHAR(20)	,
								 StockAttrib3 VARCHAR(20),
								 PackingID VARCHAR(20)			,
								 GRDate VARCHAR(10)	 ,
								MaterialDeliveryNo VARCHAR(20),
								MaterialDeliveryDetailNo VARCHAR(20),
								 InitialQty DECIMAL(18,2),
								 CurrentQty DECIMAL(18,2) ,
								 PickingQty DECIMAL(18,2)		 ,
								 VendorLotNo VARCHAR(50)	 ,
								 LifeBasicDate DATE					 ,
								 ProductionDate DATE			   ,
								 EndOfLifeDate DATE					,
								 LotNo VARCHAR(50)				  ,
								 IsSplitLot BIT,							  
								 BefMaterialLotNo VARCHAR(50),
								 LotAttr01 VARCHAR(100)			 ,
								 LotAttr02 VARCHAR(100)			 ,
								 LotAttr03 VARCHAR(100)			 ,
								 LotAttr04 VARCHAR(100)			 ,
								 LotAttr05 VARCHAR(100)			 ,
								 LotAttr06 VARCHAR(100)			 ,
								 LotAttr07 VARCHAR(100)			 ,
								 LotAttr08 VARCHAR(100)			 ,
								 LotAttr09 VARCHAR(100)			 ,
								 LotAttr10 VARCHAR(100)			 ,
								 DateConfirmEx DATE				   ,
								 HoldError BIT							 ,
								 Holddate DATE						  ,
								 HoldPeriod INT						   ,
								 PackingIdParent VARCHAR(50) ,
								 LengthSlitting DECIMAL(18,2)	
								)

							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialLotNo IS NULL THEN MaterialLotNo
										ELSE OldMaterialLotNo
									END AS OldMaterialLotNo,
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
												DateConfirmEx,
												HoldError,
												Holddate,
												HoldPeriod,
												PackingIdParent,
												LengthSlitting
								FROM
									OPENXML(@idoc, @DeleteTableName, 2)
									WITH  (
									OldMaterialLotNo VARCHAR(20),
								MaterialLotNo VARCHAR(20),
								LotID VARCHAR(20),				   
								 CompanyCode VARCHAR(20),   
								 WorkCenterCode VARCHAR(20),
								 MaterialWarehouseCode VARCHAR(20),
								MaterialLocationCode VARCHAR(20),
								 MaterialCode VARCHAR(50)	  ,
								 MaterialStockAttribute VARCHAR(20),
								 StockAttrib1 VARCHAR(20)		,
								 StockAttrib2  VARCHAR(20)	,
								 StockAttrib3 VARCHAR(20),
								 PackingID VARCHAR(20)			,
								 GRDate VARCHAR(10)	 ,
								MaterialDeliveryNo VARCHAR(20),
								MaterialDeliveryDetailNo VARCHAR(20),
								 InitialQty DECIMAL(18,2),
								 CurrentQty DECIMAL(18,2) ,
								 PickingQty DECIMAL(18,2)		 ,
								 VendorLotNo VARCHAR(50)	 ,
								 LifeBasicDate DATE					 ,
								 ProductionDate DATE			   ,
								 EndOfLifeDate DATE					,
								 LotNo VARCHAR(50)				  ,
								 IsSplitLot BIT,							  
								 BefMaterialLotNo VARCHAR(50),
								 LotAttr01 VARCHAR(100)			 ,
								 LotAttr02 VARCHAR(100)			 ,
								 LotAttr03 VARCHAR(100)			 ,
								 LotAttr04 VARCHAR(100)			 ,
								 LotAttr05 VARCHAR(100)			 ,
								 LotAttr06 VARCHAR(100)			 ,
								 LotAttr07 VARCHAR(100)			 ,
								 LotAttr08 VARCHAR(100)			 ,
								 LotAttr09 VARCHAR(100)			 ,
								 LotAttr10 VARCHAR(100)			 ,
								 DateConfirmEx DATE				   ,
								 HoldError BIT							 ,
								 Holddate DATE						  ,
								 HoldPeriod INT						   ,
								 PackingIdParent VARCHAR(50) ,
								 LengthSlitting DECIMAL(18,2)	
									)



            OPEN SourceData

           WHILE 1 = 1
				BEGIN
					-- Fetch the next record into the variables
					FETCH NEXT FROM SourceData INTO
												@IUD_FLAG,
												@OldMaterialLotNo,
												@MaterialLotNo,
												@LotID,
												@CompanyCode,
												@WorkCenterCode,
												@MaterialWarehouseCode,
												@MaterialLocationCode,
												@MaterialCode,
												@MaterialStockAttribute,
												@StockAttrib1,
												@StockAttrib2,
												@StockAttrib3,
												@PackingID,
												@GRDate,
												@MaterialDeliveryNo,
												@MaterialDeliveryDetailNo,
												@InitialQty,
												@CurrentQty,
												@PickingQty,
												@VendorLotNo,
												@LifeBasicDate,
												@ProductionDate,
												@EndOfLifeDate,
												@LotNo,
												@IsSplitLot,
												@BefMaterialLotNo,
												@LotAttr01,
												@LotAttr02,
												@LotAttr03,
												@LotAttr04,
												@LotAttr05,
												@LotAttr06,
												@LotAttr07,
												@LotAttr08,
												@LotAttr09,
												@LotAttr10,
												@DateConfirmEx,
												@HoldError,
												@Holddate,
												@HoldPeriod,
												@PackingIdParent,
												@LengthSlitting
		
		

                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialLotInfo WHERE MaterialLotNo = @MaterialLotNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialLotNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialLotInfo',@MaterialLotNo OUTPUT
                    END
                    
					EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialDocLotInfo', @NewLotID OUTPUT
					set @LotID ='SL' + SUBSTRING(@NewLotID, 3, LEN(@NewLotID) - 2) 	

					select			@LotAttr01,
										@LotAttr02,
										@LotAttr03,
										@LotAttr04,
										@LotAttr05,
										@LotAttr06,
										@LotAttr07,
										@LotAttr08,
										@LotAttr09,
										@LotAttr10
					from STB_MaterialLotInfo where  LotID =  @PackingIdParent
					select @WidthSlitting= [width] from STB_WidthSlitting where MaterialCode =@MaterialCode
					
				set @checkWidth =0
				select  @checkWidth=count(MaterialCode)  from STB_WidthSlitting where MaterialCode =@MaterialCode
				set @WidthSlitting =CASE
												WHEN @checkWidth>0 THEN  (select top 1 [width] from STB_WidthSlitting  where MaterialCode =@MaterialCode order by CreateDateTime DESC)
												ELSE 0
											END;

								--declare @test varchar(20) =@WidthSlitting
								--raiserror(@test,16,1)
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
								VALUES
								(
								
									@MaterialLotNo,
									@LotID,
									@CompanyCode,
									@WorkCenterCode,
									@MaterialWarehouseCode,
									@MaterialLocationCode,
									@MaterialCode,
									@MaterialStockAttribute,
									@StockAttrib1,
									@StockAttrib2,
									@StockAttrib3,
									@PackingID,
									@GRDate,
									@MaterialDeliveryNo,
									@MaterialDeliveryDetailNo,
									@InitialQty,
									@LengthSlitting * (@WidthSlitting*(1.0)/1000),
									0,
									@VendorLotNo,
									@LifeBasicDate,
									@ProductionDate,
									@EndOfLifeDate,
									@LotNo,
									@IsSplitLot,
									@BefMaterialLotNo,
									@LotAttr01,
									@LotAttr02,
									@LotAttr03,
									@LotAttr04,
									@LotAttr05,
									@LotAttr06,
									@LotAttr07,
									@LotAttr08,
									@LotAttr09,
									@LotAttr10,
									GETDATE(),
									@ProcessUserID,
									@DateConfirmEx,
									@HoldError,
									@Holddate,
									@HoldPeriod,
									@PackingIdParent,
									@LengthSlitting

							
								)
								
							 --	select top 1* from STB_MaterialLotInfo where CreateDateTime<'2024-12-01'  order by CreateDateTime  desc
								--select * from stb_materialLotInfo where IsSlitting is not null

								--select top 1* from STB_MaterialLotInfo where CreateDateTime<'2024-12-01'  order by CreateDateTime  desc
								--select * from stb_materialLotInfo where MaterialWarehouseCode ='SLITTING_HN_WH'

			END
				 ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
		
			
				set @checkWidth =0
				select  @checkWidth=count(MaterialCode)  from STB_WidthSlitting where MaterialCode =@MaterialCode
				set @WidthSlitting =CASE
												WHEN @checkWidth>0 THEN  (select top 1 [width] from STB_WidthSlitting  where MaterialCode =@MaterialCode order by CreateDateTime DESC)
												ELSE 0
											END;
					--select @WidthSlitting=  [width] from STB_WidthSlitting where MaterialCode =@MaterialCode
					--declare @test varchar(20) =@WidthSlitting
					--			raiserror(@test,16,1)

                 UPDATE STB_MaterialLotInfo
						SET
					
							MaterialCode = @MaterialCode,
							LengthSlitting=@LengthSlitting,
							CurrentQty = @LengthSlitting * (@WidthSlitting*(1.0)/1000),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @ProcessUserID
												
						WHERE
							MaterialLotNo = @OldMaterialLotNo;

				
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialLotInfo
						WHERE
						    MaterialLotNo = @OldMaterialLotNo
                END
            END
        END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	
    END
END

   --select * from STB_MaterialLotInfo_test
-- select * from STB_MaterialdocLotInfo_test1  
--select * from STB_MaterialdocLotInfo  where LOTID like '%SP%'
--   --select * from STB_MaterialLotInfo order by CreateDateTime DESC

--   select * from  STB_MaterialLotInfo   where LOTID like '%SP%'
 --from STB_MaterialLotInfo where LotID ='SL20241216000124'

