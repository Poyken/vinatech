
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-01-27
-- Browsable : true
-- Group : 영업관리
-- Description:	전역설정 사용 수정(jspark)
-- =============================================
CREATE PROCEDURE [dbo].[usp_SalesOrderItem_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  DECLARE @OldSOISequence BIGINT
  DECLARE @SOISequence BIGINT
  DECLARE @SalesOrderNo VARCHAR(20)
  DECLARE @ModelCode VARCHAR(50)
  DECLARE @BomVersion VARCHAR(20)
  DECLARE @OrderQty NUMERIC(20,4)
  DECLARE @FixedQty NUMERIC(20,4)
  DECLARE @ProdPlanQty NUMERIC(20,4)
  DECLARE @IsMainAssemblePlan BIT
  DECLARE @IsOutboundInspection BIT
  DECLARE @StockReservationQty NUMERIC(20,4)
  DECLARE @UnitPrice NUMERIC(20,4)
  DECLARE @OptionText NVARCHAR(MAX)
  DECLARE @RequestDeliveryDate DATE
  DECLARE @DeliveryDate INT
  DECLARE @DestInformation NVARCHAR(100)
  
  DECLARE @RouteCode VARCHAR(20)
  
  DECLARE @SOIExtText01 NVARCHAR(200)
  DECLARE @SOIExtText02 NVARCHAR(200)
  DECLARE @SOIExtText03 NVARCHAR(200)
  DECLARE @SOIExtText04 NVARCHAR(200)
  DECLARE @SOIExtText05 NVARCHAR(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  DECLARE @BefMaterialCode VARCHAR(50)
  DECLARE @BefOrderQty NUMERIC(20,4)
  DECLARE @BefProdPlanQty NUMERIC(20,4)
  DECLARE @BefDeliveryPlanQty NUMERIC(20,4)
  DECLARE @BefDeliveryFixQty NUMERIC(20,4)

  DECLARE @FIXOrderDate DATE

  


  DECLARE @UID_KEY VARCHAR(50)

	DECLARE @AUTO_FIX VARCHAR(50)
	
	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SalesOrderItem',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
	SET @AUTO_FIX = dbo.fnGetProcessRule('SALES_ORDER_ITEM_FIXQTY', 'N')
	
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									XMLData.OldSOISequence,
									XMLData.SOISequence,
									XMLData.SalesOrderNo,
									XMLData.ModelCode,
									XMLData.BomVersion,
									XMLData.RouteCode,
									XMLData.OrderQty,
									CASE WHEN @AUTO_FIX = 'Y' THEN OrderQty	ELSE XMLData.FixedQty	END AS FixedQty,							
									XMLData.ProdPlanQty,
									XMLData.IsMainAssemblePlan,
									XMLData.IsOutboundInspection,
									XMLData.StockReservationQty,
									XMLData.UnitPrice,
									XMLData.OptionText,
									XMLData.RequestDeliveryDate,
									XMLData.DeliveryDate,
									XMLData.DestInformation,
									XMLData.SOIExtText01,
									XMLData.SOIExtText02,
									XMLData.SOIExtText03,
									XMLData.SOIExtText04,
									XMLData.SOIExtText05,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									--XMLData.FixOrderDate
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldSOISequence BIGINT,
											 SOISequence BIGINT,
											 SalesOrderNo VARCHAR(20),
											 ModelCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 RouteCode VARCHAR(20),
											 OrderQty NUMERIC(20,4),
											 FixedQty NUMERIC(20,4),
											 ProdPlanQty NUMERIC(20,4),
											 IsMainAssemblePlan BIT,
											 IsOutboundInspection BIT,
											 StockReservationQty NUMERIC(20,4),
											 UnitPrice NUMERIC(20,4),
											 OptionText NVARCHAR(MAX),
											 RequestDeliveryDate  DATETIMEOFFSET,
											 DeliveryDate INT,
											 DestInformation NVARCHAR(100),
											 SOIExtText01 NVARCHAR(200),
											 SOIExtText02 NVARCHAR(200),
											 SOIExtText03 NVARCHAR(200),
											 SOIExtText04 NVARCHAR(200),
											 SOIExtText05 NVARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											 --FixOrderDate Date
											) XMLData
							UNION ALL

							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldSOISequence IS NULL THEN XMLData.SOISequence
										ELSE XMLData.OldSOISequence
									END AS OldSOISequence,
									XMLData.SOISequence,
									XMLData.SalesOrderNo,
									XMLData.ModelCode,
									XMLData.BomVersion,
									XMLData.RouteCode,
									XMLData.OrderQty,
									CASE
										WHEN @AUTO_FIX = 'Y' THEN OrderQty
										ELSE XMLData.FixedQty
									END AS FixedQty,							
									XMLData.ProdPlanQty,
									XMLData.IsMainAssemblePlan,
									XMLData.IsOutboundInspection,
									XMLData.StockReservationQty,
									XMLData.UnitPrice,
									XMLData.OptionText,
									XMLData.RequestDeliveryDate,
									XMLData.DeliveryDate,
									XMLData.DestInformation,
									XMLData.SOIExtText01,
									XMLData.SOIExtText02,
									XMLData.SOIExtText03,
									XMLData.SOIExtText04,
									XMLData.SOIExtText05,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									--XMLData.FixOrderDate
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldSOISequence BIGINT,
											 SOISequence BIGINT,
											 SalesOrderNo VARCHAR(20),
											 ModelCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 RouteCode VARCHAR(20),
											 OrderQty NUMERIC(20,4),
											 FixedQty NUMERIC(20,4),
											 ProdPlanQty NUMERIC(20,4),
											 IsMainAssemblePlan BIT,
											 IsOutboundInspection BIT,
											 StockReservationQty NUMERIC(20,4),
											 UnitPrice NUMERIC(20,4),
											 OptionText NVARCHAR(MAX),
											 RequestDeliveryDate  DATETIMEOFFSET,
											 DeliveryDate INT,
											 DestInformation NVARCHAR(100),
											 SOIExtText01 NVARCHAR(200),
											 SOIExtText02 NVARCHAR(200),
											 SOIExtText03 NVARCHAR(200),
											 SOIExtText04 NVARCHAR(200),
											 SOIExtText05 NVARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											-- FixOrderDate Date
											) XMLData
							UNION ALL

							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldSOISequence IS NULL THEN XMLData.SOISequence
										ELSE XMLData.OldSOISequence
									END AS OldSOISequence,
									XMLData.SOISequence,
									XMLData.SalesOrderNo,
									XMLData.ModelCode,
									XMLData.BomVersion,
									XMLData.RouteCode,
									XMLData.OrderQty,
									CASE
										WHEN @AUTO_FIX = 'Y' THEN OrderQty
										ELSE XMLData.FixedQty
									END AS FixedQty,		
									XMLData.ProdPlanQty,
									XMLData.IsMainAssemblePlan,
									XMLData.IsOutboundInspection,
									XMLData.StockReservationQty,
									XMLData.UnitPrice,
									XMLData.OptionText,
									XMLData.RequestDeliveryDate,
									XMLData.DeliveryDate,
									XMLData.DestInformation,
									XMLData.SOIExtText01,
									XMLData.SOIExtText02,
									XMLData.SOIExtText03,
									XMLData.SOIExtText04,
									XMLData.SOIExtText05,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									--XMLData.FixOrderDate
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldSOISequence BIGINT,
											 SOISequence BIGINT,
											 SalesOrderNo VARCHAR(20),
											 ModelCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 RouteCode VARCHAR(20),
											 OrderQty NUMERIC(20,4),
											 FixedQty NUMERIC(20,4),
											 ProdPlanQty NUMERIC(20,4),
											 IsMainAssemblePlan BIT,
											 IsOutboundInspection BIT,
											 StockReservationQty NUMERIC(20,4),
											 UnitPrice NUMERIC(20,4),
											 OptionText NVARCHAR(MAX),
											 RequestDeliveryDate  DATETIMEOFFSET,
											 DeliveryDate INT,
											 DestInformation NVARCHAR(100),
											 SOIExtText01 NVARCHAR(200),
											 SOIExtText02 NVARCHAR(200),
											 SOIExtText03 NVARCHAR(200),
											 SOIExtText04 NVARCHAR(200),
											 SOIExtText05 NVARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											-- FixOrderDate Date
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
					FETCH NEXT FROM SourceData INTO
									 @IUD_FLAG,
									 @OldSOISequence,
									 @SOISequence,
									 @SalesOrderNo,
									 @ModelCode,
									 @BomVersion,
									 @RouteCode,
									 @OrderQty,
									 @FixedQty,
									 @ProdPlanQty,
									 @IsMainAssemblePlan,
								 	 @IsOutboundInspection,
									 @StockReservationQty,
									 @UnitPrice,
									 @OptionText,
									 @RequestDeliveryDate,
									 @DeliveryDate,
									 @DestInformation,
									 @SOIExtText01,
									 @SOIExtText02,
									 @SOIExtText03,
									 @SOIExtText04,
									 @SOIExtText05,
									 @CreateDateTime,
									 @CreateUserID,
									 @ChangeDateTime,
									 @ChangeUserID


					IF @@FETCH_STATUS <> 0 BEGIN
						BREAK
					END
				
					IF @IUD_FLAG = 'INSERT' BEGIN

						IF EXISTS (SELECT 1 FROM STB_SalesOrderItem WHERE SOISequence = @SOISequence) BEGIN
							RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @SOISequence)
						END

						IF @IsAutoKey = 1 BEGIN
							EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_SalesOrderItem', @SOISequence OUTPUT
						END
						
						-- 임시 SEQUENCE TABLE 사용 버젼
						SET @UID_KEY = @SalesOrderNo

						SET @SalesOrderNo = NULL
						
						SELECT 
								@SalesOrderNo = KeyValue
						FROM 
								#SEQUENCE_TABLE
						WHERE
								UID_KEY = @UID_KEY
						
						IF @SalesOrderNo IS NULL

						BEGIN
							SET @SalesOrderNo = @UID_KEY
						END
						--
						

                        INSERT INTO STB_SalesOrderItem
						(
						    --SOISequence,
						    SalesOrderNo,
						    ModelCode,
						    BomVersion,
						    OrderQty,
						    FixedQty,
						    ProdPlanQty,
							GIPlanQty,
							GIFixQty,
						    IsMainAssemblePlan,
						    IsOutboundInspection,
						    StockReservationQty,
						    UnitPrice,
						    OptionText,
						    RequestDeliveryDate,
						    DeliveryDate,
						    DestInformation,
						    SOIExtText01,
						    SOIExtText02,
						    SOIExtText03,
						    SOIExtText04,
						    SOIExtText05,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
							
						)
						VALUES
						(
						    --@SOISequence,
						    @SalesOrderNo,
						    @ModelCode,
						    @BomVersion,
						    @OrderQty,
						    @FixedQty,
						    @ProdPlanQty,
							0,	-- GIPlanQty
							0,	-- GIFixQty
						    @IsMainAssemblePlan,
						    @IsOutboundInspection,
						    @StockReservationQty,
						    @UnitPrice,
						    @OptionText,
						    @RequestDeliveryDate,
						    @DeliveryDate,
						    @DestInformation,
						    @SOIExtText01,
						    @SOIExtText02,
						    @SOIExtText03,
						    @SOIExtText04,
						    @SOIExtText05,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						
						)

					END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

						SELECT
								@BefMaterialCode = SOI.ModelCode,
								@BefOrderQty = SOI.OrderQty,
								@BefProdPlanQty = ISNULL(SOI.ProdPlanQty, 0),
								@BefDeliveryPlanQty = ISNULL(SOI.GIPlanQty, 0),
								@BefDeliveryFixQty = ISNULL(SOI.GIFixQty, 0)
						FROM
								STB_SalesOrderItem SOI
						WHERE
								SOI.SOISequence = @OldSOISequence

						
						IF (@BefMaterialCode <> @ModelCode) AND (@BefProdPlanQty > 0)
						BEGIN
								RAISERROR('생산 지시가 진행되어 품목을 수정할 수 없습니다', 16, 1)
								RETURN
						END

						IF (@BefMaterialCode <> @ModelCode) AND (( @BefDeliveryPlanQty > 0) OR (@BefDeliveryFixQty > 0) )
						BEGIN
								RAISERROR('출고 지시가 진행되어 품목을 수정할 수 없습니다', 16, 1)
								RETURN
						END


						-- 2019.01.11 kilee추가사항
						--IF (@FIXOrderDate <> @FIXOrderDate) AND (( @FIXOrderDate > '') OR (@FIXOrderDate is null) )
						--BEGIN
						--		RAISERROR('고정된 오더날짜가 있어서 수정할 수 없습니다', 16, 1)
						--		RETURN
						--END


                        UPDATE STB_SalesOrderItem
						SET
						    SalesOrderNo =   CASE
						                WHEN @SalesOrderNo IS NOT NULL THEN @SalesOrderNo
						                ELSE SalesOrderNo
						            END,
						    ModelCode =   CASE
						                WHEN @ModelCode IS NOT NULL THEN @ModelCode
						                ELSE ModelCode
						            END,
						    BomVersion =   CASE
						                WHEN @BomVersion IS NOT NULL THEN @BomVersion
						                ELSE BomVersion
						            END,							
						    OrderQty =   CASE
						                WHEN @OrderQty IS NOT NULL THEN @OrderQty
						                ELSE OrderQty
						            END,
						    FixedQty =   CASE
						                WHEN @FixedQty IS NOT NULL THEN @FixedQty
						                ELSE FixedQty
						            END,
						    ProdPlanQty =   CASE
						                WHEN @ProdPlanQty IS NOT NULL THEN @ProdPlanQty
						                ELSE ProdPlanQty
						            END,
						    IsMainAssemblePlan =   CASE
						                WHEN @IsMainAssemblePlan IS NOT NULL THEN @IsMainAssemblePlan
						                ELSE IsMainAssemblePlan
						            END,
						    IsOutboundInspection =   CASE
						                WHEN @IsOutboundInspection IS NOT NULL THEN @IsOutboundInspection
						                ELSE IsOutboundInspection
						            END,
						    StockReservationQty =   CASE
						                WHEN @StockReservationQty IS NOT NULL THEN @StockReservationQty
						                ELSE StockReservationQty
						            END,
						    UnitPrice =   CASE
						                WHEN @UnitPrice IS NOT NULL THEN @UnitPrice
						                ELSE UnitPrice
						            END,
						    OptionText =   CASE
						                WHEN @OptionText IS NOT NULL THEN @OptionText
						                ELSE OptionText
						            END,
						    RequestDeliveryDate =   CASE
						                WHEN @RequestDeliveryDate IS NOT NULL THEN @RequestDeliveryDate
						                ELSE RequestDeliveryDate
						            END,
						    DeliveryDate =   CASE
						                WHEN @DeliveryDate IS NOT NULL THEN @DeliveryDate
						                ELSE DeliveryDate
						            END,
						    DestInformation =   CASE
						                WHEN @DestInformation IS NOT NULL THEN @DestInformation
						                ELSE DestInformation
						            END,
						    SOIExtText01 =   CASE
						                WHEN @SOIExtText01 IS NOT NULL THEN @SOIExtText01
						                ELSE SOIExtText01
						            END,
						    SOIExtText02 =   CASE
						                WHEN @SOIExtText02 IS NOT NULL THEN @SOIExtText02
						                ELSE SOIExtText02
						            END,
						    SOIExtText03 =   CASE
						                WHEN @SOIExtText03 IS NOT NULL THEN @SOIExtText03
						                ELSE SOIExtText03
						            END,
						    SOIExtText04 =   CASE
						                WHEN @SOIExtText04 IS NOT NULL THEN @SOIExtText04
						                ELSE SOIExtText04
						            END,
						    SOIExtText05 =   CASE
						                WHEN @SOIExtText05 IS NOT NULL THEN @SOIExtText05
						                ELSE SOIExtText05
						            END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    SOISequence = @OldSOISequence
                    END ELSE IF @IUD_FLAG = 'DELETE' BEGIN

						SELECT
								@BefMaterialCode = SOI.ModelCode,
								@BefOrderQty = SOI.OrderQty,
								@BefProdPlanQty = ISNULL(SOI.ProdPlanQty, 0),
								@BefDeliveryPlanQty = ISNULL(SOI.GIPlanQty, 0),
								@BefDeliveryFixQty = ISNULL(SOI.GIFixQty, 0)
						FROM
								STB_SalesOrderItem SOI
						WHERE
								SOI.SOISequence = @OldSOISequence

						
						IF (@BefProdPlanQty > 0)
						BEGIN
								RAISERROR('생산 지시가 진행되어 품목을 삭제할 수 없습니다.', 16, 1)
								RETURN
						END

						IF (( @BefDeliveryPlanQty > 0) OR (@BefDeliveryFixQty > 0) )
						BEGIN
								RAISERROR('출고 지시가 진행되어 품목을 삭제할 수 없습니다', 16, 1)
								RETURN
						END


				   -- kilee 추가 2019.01.11
						--IF (( @FIXOrderDate <> '') OR (@FIXOrderDate is not null) )
						--BEGIN
						--		RAISERROR('고정된 오더날짜가 입력되어 있어서 삭제할 수 없습니다', 16, 1)
						--		RETURN
						--END



                        DELETE FROM STB_SalesOrderItem
						WHERE
						    SOISequence = @SOISequence
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

