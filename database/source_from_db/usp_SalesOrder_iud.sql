
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-03
-- Browsable : true
-- Group : 영업관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SalesOrder_iud]
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
  DECLARE @OldSalesOrderNo VARCHAR(20)
  DECLARE @SalesOrderNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @OrderType VARCHAR(20)
  DECLARE @CustomerCode VARCHAR(20)
  DECLARE @OrderDate DATE
  DECLARE @IsFixedOrder BIT
  DECLARE @RequestDeliveryDate DATE
  DECLARE @DeliveryDay INT
  DECLARE @DestInfomation NVARCHAR(100)
  DECLARE @IsCancel BIT
  DECLARE @CancelText NVARCHAR(100)
  DECLARE @AmountPrice NUMERIC(20,4)
  DECLARE @SOExtText01 NVARCHAR(200)
  DECLARE @SOExtText02 NVARCHAR(200)
  DECLARE @SOExtText03 NVARCHAR(200)
  DECLARE @SOExtText04 NVARCHAR(200)
  DECLARE @SOExtText05 NVARCHAR(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @AUTO_FIX VARCHAR(50)

  DECLARE @FixOrderDate DATE           --추가
  DECLARE @IsFix        VARCHAR(50)    --추가
  DECLARE @IsFlxedCheck BIT            --추가
  


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SalesOrder',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
	SET @AUTO_FIX = dbo.fnGetProcessRule('SALES_ORDER_FIX', 'N') 
 	SET @IsFix    = dbo.fnGetProcessRule('SALES_IS_FIX', 'N')   
	





    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 
	
	
	BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_SalesOrder AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldSalesOrderNo IS NULL THEN XMLData.SalesOrderNo
							    ELSE XMLData.OldSalesOrderNo
							END AS OldSalesOrderNo,
							XMLData.SalesOrderNo,
							XMLData.CompanyCode,
							XMLData.OrderType,
							XMLData.CustomerCode,
							XMLData.OrderDate,
							CASE WHEN @AUTO_FIX = 'Y' THEN 1 ELSE XMLData.IsFixedOrder	END AS IsFixedOrder,
							XMLData.RequestDeliveryDate,
							XMLData.DeliveryDay,
							XMLData.DestInfomation,
							XMLData.IsCancel,
							XMLData.CancelText,
							XMLData.AmountPrice,
							XMLData.SOExtText01,
							XMLData.SOExtText02,
							XMLData.SOExtText03,
							XMLData.SOExtText04,
							XMLData.SOExtText05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,

							--XMLData.FixOrderDate,
							GETDATE() AS FixOrderDate,
							CASE WHEN @IsFix = 'Y' THEN 1 ELSE XMLData.IsFlxedCheck	END AS IsFlxedCheck


					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldSalesOrderNo VARCHAR(20),
										SalesOrderNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										OrderType VARCHAR(20),
										CustomerCode VARCHAR(20),
										OrderDate  DATETIMEOFFSET,
										IsFixedOrder BIT,
										RequestDeliveryDate  DATETIMEOFFSET,
										DeliveryDay INT,
										DestInfomation NVARCHAR(100),
										IsCancel BIT,
										CancelText NVARCHAR(100),
										AmountPrice NUMERIC(20,4),
										SOExtText01 NVARCHAR(200),
										SOExtText02 NVARCHAR(200),
										SOExtText03 NVARCHAR(200),
										SOExtText04 NVARCHAR(200),
										SOExtText05 NVARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),

										FixOrderDate  DATETIMEOFFSET,
										IsFlxedCheck BIT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.SalesOrderNo = SourceTable.SalesOrderNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					SalesOrderNo = SourceTable.SalesOrderNo,
					CompanyCode = SourceTable.CompanyCode,
					OrderType = SourceTable.OrderType,
					CustomerCode = SourceTable.CustomerCode,
					OrderDate = SourceTable.OrderDate,
					IsFixedOrder = SourceTable.IsFixedOrder,
					RequestDeliveryDate = SourceTable.RequestDeliveryDate,
					DeliveryDay = SourceTable.DeliveryDay,
					DestInfomation = SourceTable.DestInfomation,
					IsCancel = SourceTable.IsCancel,
					CancelText = SourceTable.CancelText,
					AmountPrice = SourceTable.AmountPrice,
					SOExtText01 = SourceTable.SOExtText01,
					SOExtText02 = SourceTable.SOExtText02,
					SOExtText03 = SourceTable.SOExtText03,
					SOExtText04 = SourceTable.SOExtText04,
					SOExtText05 = SourceTable.SOExtText05,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,

					FixOrderDate = GETDATE(),
					IsFlxedCheck = SourceTable.IsFlxedCheck
					
			WHEN NOT MATCHED THEN
				INSERT
					(
						SalesOrderNo,
						CompanyCode,
						OrderType,
						CustomerCode,
						OrderDate,
						IsFixedOrder,
						RequestDeliveryDate,
						DeliveryDay,
						DestInfomation,
						IsCancel,
						CancelText,
						AmountPrice,
						SOExtText01,
						SOExtText02,
						SOExtText03,
						SOExtText04,
						SOExtText05,
						CreateDateTime,
						CreateUserID,	
										
						FixOrderDate,
						IsFlxedCheck
					)
				VALUES
					(
							SourceTable.SalesOrderNo,
							SourceTable.CompanyCode,
							SourceTable.OrderType,
							SourceTable.CustomerCode,
							SourceTable.OrderDate,
							SourceTable.IsFixedOrder,
							SourceTable.RequestDeliveryDate,
							SourceTable.DeliveryDay,
							SourceTable.DestInfomation,
							SourceTable.IsCancel,
							SourceTable.CancelText,
							SourceTable.AmountPrice,
							SourceTable.SOExtText01,
							SourceTable.SOExtText02,
							SourceTable.SOExtText03,
							SourceTable.SOExtText04,
							SourceTable.SOExtText05,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,

							CASE WHEN SourceTable.IsFlxedCheck = 1 THEN GETDATE() ELSE NULL END,          --SourceTable.FixOrderDate,
							SourceTable.IsFlxedCheck
					);


			-- Process Update Table
            MERGE STB_SalesOrder AS TargetTable
			USING
				(
					SELECT
							CASE  WHEN XMLData.OldSalesOrderNo IS NULL THEN XMLData.SalesOrderNo   ELSE XMLData.OldSalesOrderNo 	END AS OldSalesOrderNo,
							XMLData.SalesOrderNo,
							XMLData.CompanyCode,
							XMLData.OrderType,
							XMLData.CustomerCode,
							XMLData.OrderDate,
							CASE WHEN @AUTO_FIX = 'Y' THEN 1 ELSE XMLData.IsFixedOrder	END AS IsFixedOrder,
							XMLData.RequestDeliveryDate,
							XMLData.DeliveryDay,
							XMLData.DestInfomation,
							XMLData.IsCancel,
							XMLData.CancelText,
							XMLData.AmountPrice,
							XMLData.SOExtText01,
							XMLData.SOExtText02,
							XMLData.SOExtText03,
							XMLData.SOExtText04,
							XMLData.SOExtText05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,

							GETDATE() AS FixOrderDate,
							--CASE WHEN @IsFix = 'Y' THEN 1 ELSE XMLData.IsFlxedCheck	END AS IsFlxedCheck
							XMLData.IsFlxedCheck
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldSalesOrderNo VARCHAR(20),
										SalesOrderNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										OrderType VARCHAR(20),
										CustomerCode VARCHAR(20),
										OrderDate  DATETIMEOFFSET,
										IsFixedOrder BIT,
										RequestDeliveryDate  DATETIMEOFFSET,
										DeliveryDay INT,
										DestInfomation NVARCHAR(100),
										IsCancel BIT,
										CancelText NVARCHAR(100),
										AmountPrice NUMERIC(20,4),
										SOExtText01 NVARCHAR(200),
										SOExtText02 NVARCHAR(200),
										SOExtText03 NVARCHAR(200),
										SOExtText04 NVARCHAR(200),
										SOExtText05 NVARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),

										FixOrderDate  DATETIMEOFFSET,
										IsFlxedCheck  BIT

									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.SalesOrderNo = SourceTable.OldSalesOrderNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					SalesOrderNo = SourceTable.SalesOrderNo,
					CompanyCode = SourceTable.CompanyCode,
					OrderType = SourceTable.OrderType,
					CustomerCode = SourceTable.CustomerCode,
					OrderDate = SourceTable.OrderDate,
					IsFixedOrder = SourceTable.IsFixedOrder,
					RequestDeliveryDate = SourceTable.RequestDeliveryDate,
					DeliveryDay = SourceTable.DeliveryDay,
					DestInfomation = SourceTable.DestInfomation,
					IsCancel = SourceTable.IsCancel,
					CancelText = SourceTable.CancelText,
					AmountPrice = SourceTable.AmountPrice,
					SOExtText01 = SourceTable.SOExtText01,
					SOExtText02 = SourceTable.SOExtText02,
					SOExtText03 = SourceTable.SOExtText03,
					SOExtText04 = SourceTable.SOExtText04,
					SOExtText05 = SourceTable.SOExtText05,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,

					FixOrderDate = CASE WHEN SourceTable.IsFlxedCheck = 1 THEN GETDATE() ELSE NULL END ,
					IsFlxedCheck = SourceTable.IsFlxedCheck

			WHEN NOT MATCHED THEN
				INSERT
					(
						SalesOrderNo,
						CompanyCode,
						OrderType,
						CustomerCode,
						OrderDate,
						IsFixedOrder,
						RequestDeliveryDate,
						DeliveryDay,
						DestInfomation,
						IsCancel,
						CancelText,
						AmountPrice,
						SOExtText01,
						SOExtText02,
						SOExtText03,
						SOExtText04,
						SOExtText05,
						CreateDateTime,
						CreateUserID,

						FixOrderDate,
						IsFlxedCheck

					)
				VALUES
					(
							SourceTable.SalesOrderNo,
							SourceTable.CompanyCode,
							SourceTable.OrderType,
							SourceTable.CustomerCode,
							SourceTable.OrderDate,
							SourceTable.IsFixedOrder,
							SourceTable.RequestDeliveryDate,
							SourceTable.DeliveryDay,
							SourceTable.DestInfomation,
							SourceTable.IsCancel,
							SourceTable.CancelText,
							SourceTable.AmountPrice,
							SourceTable.SOExtText01,
							SourceTable.SOExtText02,
							SourceTable.SOExtText03,
							SourceTable.SOExtText04,
							SourceTable.SOExtText05,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,

							CASE WHEN SourceTable.IsFlxedCheck = 1 THEN GETDATE() ELSE NULL END,--SourceTable.FixOrderDate,
							SourceTable.IsFlxedCheck
					);
			

			-- Process Delete Table
            MERGE STB_SalesOrder AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldSalesOrderNo IS NULL THEN XMLData.SalesOrderNo
							    ELSE XMLData.OldSalesOrderNo
							END AS OldSalesOrderNo,
							XMLData.SalesOrderNo,
							XMLData.CompanyCode,
							XMLData.OrderType,
							XMLData.CustomerCode,
							XMLData.OrderDate,
							CASE	WHEN @AUTO_FIX = 'Y' THEN 1		ELSE XMLData.IsFixedOrder		END AS IsFixedOrder,
							XMLData.RequestDeliveryDate,
							XMLData.DeliveryDay,
							XMLData.DestInfomation,
							XMLData.IsCancel,
							XMLData.CancelText,
							XMLData.AmountPrice,
							XMLData.SOExtText01,
							XMLData.SOExtText02,
							XMLData.SOExtText03,
							XMLData.SOExtText04,
							XMLData.SOExtText05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,

							GETDATE() AS FixOrderDate,
							CASE	WHEN @IsFix = 'Y' THEN 1		ELSE XMLData.IsFlxedCheck		END AS IsFlxedCheck
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldSalesOrderNo VARCHAR(20),
										SalesOrderNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										OrderType VARCHAR(20),
										CustomerCode VARCHAR(20),
										OrderDate  DATETIMEOFFSET,
										IsFixedOrder BIT,
										RequestDeliveryDate  DATETIMEOFFSET,
										DeliveryDay INT,
										DestInfomation NVARCHAR(100),
										IsCancel BIT,
										CancelText NVARCHAR(100),
										AmountPrice NUMERIC(20,4),
										SOExtText01 NVARCHAR(200),
										SOExtText02 NVARCHAR(200),
										SOExtText03 NVARCHAR(200),
										SOExtText04 NVARCHAR(200),
										SOExtText05 NVARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),

										FixOrderDate  DATETIMEOFFSET,
										IsFlxedCheck BIT


									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.SalesOrderNo = SourceTable.SalesOrderNo
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY

	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									XMLData.OldSalesOrderNo,
									XMLData.SalesOrderNo,
									XMLData.CompanyCode,
									XMLData.OrderType,
									XMLData.CustomerCode,
									XMLData.OrderDate,
									CASE		WHEN @AUTO_FIX = 'Y' THEN 1		ELSE XMLData.IsFixedOrder									END AS IsFixedOrder,
									XMLData.RequestDeliveryDate,
									XMLData.DeliveryDay,
									XMLData.DestInfomation,
									XMLData.IsCancel,
									XMLData.CancelText,
									XMLData.AmountPrice,
									XMLData.SOExtText01,
									XMLData.SOExtText02,
									XMLData.SOExtText03,
									XMLData.SOExtText04,
									XMLData.SOExtText05,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,

									XMLData.FixOrderDate,
									CASE		WHEN @IsFix = 'Y' THEN 1 	ELSE XMLData.IsFlxedCheck									END AS IsFlxedCheck
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldSalesOrderNo VARCHAR(20),
											 SalesOrderNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 OrderType VARCHAR(20),
											 CustomerCode VARCHAR(20),
											 OrderDate  DATETIMEOFFSET,
											 IsFixedOrder BIT,
											 RequestDeliveryDate  DATETIMEOFFSET,
											 DeliveryDay INT,
											 DestInfomation NVARCHAR(100),
											 IsCancel BIT,
											 CancelText NVARCHAR(100),
											 AmountPrice NUMERIC(20,4),
											 SOExtText01 NVARCHAR(200),
											 SOExtText02 NVARCHAR(200),
											 SOExtText03 NVARCHAR(200),
											 SOExtText04 NVARCHAR(200),
											 SOExtText05 NVARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),

											 FixOrderDate  DATETIMEOFFSET,
											 IsFlxedCheck BIT

											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 		WHEN XMLData.OldSalesOrderNo IS NULL THEN XMLData.SalesOrderNo							ELSE XMLData.OldSalesOrderNo									END AS OldSalesOrderNo,
									XMLData.SalesOrderNo,
									XMLData.CompanyCode,
									XMLData.OrderType,
									XMLData.CustomerCode,
									XMLData.OrderDate,
									CASE	WHEN @AUTO_FIX = 'Y' THEN 1	ELSE XMLData.IsFixedOrder END AS IsFixedOrder,
									XMLData.RequestDeliveryDate,
									XMLData.DeliveryDay,
									XMLData.DestInfomation,
									XMLData.IsCancel,
									XMLData.CancelText,
									XMLData.AmountPrice,
									XMLData.SOExtText01,
									XMLData.SOExtText02,
									XMLData.SOExtText03,
									XMLData.SOExtText04,
									XMLData.SOExtText05,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,

									XMLData.FixOrderDate,
									CASE	WHEN @IsFix = 'Y' THEN 1	ELSE XMLData.IsFlxedCheck END AS IsFlxedCheck


							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldSalesOrderNo VARCHAR(20),
											 SalesOrderNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 OrderType VARCHAR(20),
											 CustomerCode VARCHAR(20),
											 OrderDate  DATETIMEOFFSET,
											 IsFixedOrder BIT,
											 RequestDeliveryDate  DATETIMEOFFSET,
											 DeliveryDay INT,
											 DestInfomation NVARCHAR(100),
											 IsCancel BIT,
											 CancelText NVARCHAR(100),
											 AmountPrice NUMERIC(20,4),
											 SOExtText01 NVARCHAR(200),
											 SOExtText02 NVARCHAR(200),
											 SOExtText03 NVARCHAR(200),
											 SOExtText04 NVARCHAR(200),
											 SOExtText05 NVARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),

											 FixOrderDate  DATETIMEOFFSET,
											 IsFlxedCheck BIT

											) XMLData
							UNION ALL

							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 				WHEN XMLData.OldSalesOrderNo IS NULL THEN XMLData.SalesOrderNo					ELSE XMLData.OldSalesOrderNo						END AS OldSalesOrderNo,
									XMLData.SalesOrderNo,
									XMLData.CompanyCode,
									XMLData.OrderType,
									XMLData.CustomerCode,
									XMLData.OrderDate,
									CASE WHEN @AUTO_FIX = 'Y' THEN 1 ELSE XMLData.IsFixedOrder	END AS IsFixedOrder,
									XMLData.RequestDeliveryDate,
									XMLData.DeliveryDay,
									XMLData.DestInfomation,
									XMLData.IsCancel,
									XMLData.CancelText,
									XMLData.AmountPrice,
									XMLData.SOExtText01,
									XMLData.SOExtText02,
									XMLData.SOExtText03,
									XMLData.SOExtText04,
									XMLData.SOExtText05,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,

									XMLData.FixOrderDate,
									CASE WHEN @IsFix = 'Y' THEN 1 ELSE XMLData.IsFlxedCheck	END AS IsFlxedCheck
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldSalesOrderNo VARCHAR(20),
											 SalesOrderNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 OrderType VARCHAR(20),
											 CustomerCode VARCHAR(20),
											 OrderDate  DATETIMEOFFSET,
											 IsFixedOrder BIT,
											 RequestDeliveryDate  DATETIMEOFFSET,
											 DeliveryDay INT,
											 DestInfomation NVARCHAR(100),
											 IsCancel BIT,
											 CancelText NVARCHAR(100),
											 AmountPrice NUMERIC(20,4),
											 SOExtText01 NVARCHAR(200),
											 SOExtText02 NVARCHAR(200),
											 SOExtText03 NVARCHAR(200),
											 SOExtText04 NVARCHAR(200),
											 SOExtText05 NVARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),

											 FixOrderDate  DATETIMEOFFSET,
											 IsFlxedCheck BIT

											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldSalesOrderNo,
								 @SalesOrderNo,
								 @CompanyCode,
								 @OrderType,
								 @CustomerCode,
								 @OrderDate,
								 @IsFixedOrder,
								 @RequestDeliveryDate,
								 @DeliveryDay,
								 @DestInfomation,
								 @IsCancel,
								 @CancelText,
								 @AmountPrice,
								 @SOExtText01,
								 @SOExtText02,
								 @SOExtText03,
								 @SOExtText04,
								 @SOExtText05,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,

								  @FixOrderDate,
								 @IsFlxedCheck

                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_SalesOrder WHERE SalesOrderNo = @SalesOrderNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @SalesOrderNo)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_SalesOrder', @SalesOrderNo OUTPUT

						-- 임시 SEQUENCE TABLE 사용 버젼
							INSERT INTO #SEQUENCE_TABLE
								(KeyValue, UID_KEY)
							VALUES
								(@SalesOrderNo, @OldSalesOrderNo)
						--   						
						
                    END


                    INSERT INTO STB_SalesOrder
						(
						    SalesOrderNo,
						    CompanyCode,
						    OrderType,
						    CustomerCode,
						    OrderDate,
						    IsFixedOrder,
						    RequestDeliveryDate,
						    DeliveryDay,
						    DestInfomation,
						    IsCancel,
						    CancelText,
						    AmountPrice,
						    SOExtText01,
						    SOExtText02,
						    SOExtText03,
						    SOExtText04,
						    SOExtText05,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,

							FixOrderDate,							
						    IsFlxedCheck
						)
						VALUES
						(
						    @SalesOrderNo,
						    @CompanyCode,
						    @OrderType,
						    @CustomerCode,
						    @OrderDate,
						    @IsFixedOrder,

						    @RequestDeliveryDate,
						    @DeliveryDay,
						    @DestInfomation,
						    @IsCancel,
						    @CancelText,
						    @AmountPrice,
						    @SOExtText01,
						    @SOExtText02,
						    @SOExtText03,
						    @SOExtText04,
						    @SOExtText05,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,

							--GETDATE(),
							@FixOrderDate,
						    @IsFlxedCheck
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_SalesOrder
						SET
						    SalesOrderNo =   CASE           WHEN @SalesOrderNo IS NOT NULL THEN @SalesOrderNo		    ELSE SalesOrderNo				            END,
						    CompanyCode =   CASE            WHEN @CompanyCode IS NOT NULL THEN @CompanyCode	            ELSE CompanyCode				            END,
						    OrderType =   CASE               WHEN @OrderType IS NOT NULL THEN @OrderType                ELSE OrderType					            END,
						    CustomerCode =   CASE    WHEN @CustomerCode IS NOT NULL THEN @CustomerCode			        ELSE CustomerCode              END,
						    OrderDate =   CASE           WHEN @OrderDate IS NOT NULL THEN @OrderDate	                ELSE OrderDate		            END,
						    IsFixedOrder =   CASE        WHEN @IsFixedOrder IS NOT NULL THEN @IsFixedOrder           ELSE IsFixedOrder		            END,
						    RequestDeliveryDate =   CASE               WHEN @RequestDeliveryDate IS NOT NULL THEN @RequestDeliveryDate		                ELSE RequestDeliveryDate						            END,
						    DeliveryDay =   CASE						                WHEN @DeliveryDay IS NOT NULL THEN @DeliveryDay						                ELSE DeliveryDay						            END,
						    DestInfomation =   CASE						                WHEN @DestInfomation IS NOT NULL THEN @DestInfomation						                ELSE DestInfomation						            END,
						    IsCancel =   CASE						                WHEN @IsCancel IS NOT NULL THEN @IsCancel
						                ELSE IsCancel
						            END,
						    CancelText =   CASE						                WHEN @CancelText IS NOT NULL THEN @CancelText						                ELSE CancelText						            END,
						    AmountPrice =   CASE						                WHEN @AmountPrice IS NOT NULL THEN @AmountPrice						                ELSE AmountPrice						            END,
						    SOExtText01 =   CASE						                WHEN @SOExtText01 IS NOT NULL THEN @SOExtText01						                ELSE SOExtText01						            END,
						    SOExtText02 =   CASE						                WHEN @SOExtText02 IS NOT NULL THEN @SOExtText02						                ELSE SOExtText02						            END,
						    SOExtText03 =   CASE						                WHEN @SOExtText03 IS NOT NULL THEN @SOExtText03						                ELSE SOExtText03						            END,
						    SOExtText04 =   CASE						                WHEN @SOExtText04 IS NOT NULL THEN @SOExtText04						                ELSE SOExtText04						            END,
						    SOExtText05 =   CASE						                WHEN @SOExtText05 IS NOT NULL THEN @SOExtText05						                ELSE SOExtText05						            END,
						    CreateDateTime =   CASE						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime						                ELSE CreateDateTime						            END,
						    CreateUserID =   CASE   WHEN @CreateUserID IS NOT NULL THEN @CreateUserID             ELSE CreateUserID			            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							FixOrderDate =   CASE WHEN @IsFlxedCheck = 1 THEN GETDATE() ELSE NULL END,--CASE    WHEN @FixOrderDate IS NOT NULL THEN @FixOrderDate           ELSE FixOrderDate		            END,
						    IsFlxedCheck =   @IsFlxedCheck

						WHERE
						    SalesOrderNo = @OldSalesOrderNo

                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					IF (
							SELECT
									COUNT(*)	
							FROM
									STB_SalesOrderItem SOI
							WHERE
									SOI.SalesOrderNo = @SalesOrderNo AND
									(
										(
											ISNULL(SOI.ProdPlanQty, 0) > 0 
										) OR
										(
											ISNULL(SOI.GIFixQty, 0) > 0 
										) OR
										(
											ISNULL(SOI.GIPlanQty, 0) > 0
										)
									)
						) > 0
					BEGIN
							RAISERROR('생산 지시가 진행되거나 출고지시가 진행중으로 삭제할 수 없습니다.', 16, 1)
							RETURN
					END


					ELSE IF (
							 SELECT
									COUNT(*)	
							 FROM
									STB_SalesOrder TargetTable
							 WHERE 
									TargetTable.SalesOrderNo = @SalesOrderNo AND
									(										
										(
											ISNULL(RTRIM(TargetTable.FixOrderDate),'') <> ''	
										)
									)		
						    ) > 0
					BEGIN
							RAISERROR('고정오더일자가 있으므로 삭제할 수 없습니다.', 16, 1)
							RETURN

					END



                    DELETE FROM STB_SalesOrderItem
						WHERE
						    SalesOrderNo = @SalesOrderNo                
                
                    DELETE FROM STB_SalesOrder
						WHERE
						    SalesOrderNo = @SalesOrderNo
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
