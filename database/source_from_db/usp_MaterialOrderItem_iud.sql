

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-04
-- Browsable : true
-- Group : 자재관리
-- Description:	자재발주상세정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialOrderItem_iud]
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
	DECLARE @OldMaterialOrderItemNo VARCHAR(20)
	DECLARE @MaterialOrderItemNo VARCHAR(20)
	DECLARE @MaterialOrderNo VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
  
	DECLARE @MaterialStockAttribute VARCHAR(20)
	DECLARE @MaterialAttribute VARCHAR(20)
	DECLARE @StockAttrib1 VARCHAR(20)
	DECLARE @StockAttrib2 VARCHAR(20)
	DECLARE @StockAttrib3 VARCHAR(20)
  
	DECLARE @MaterialOrderQty NUMERIC(20,5)
	DECLARE @MaterialOrderRemainQty NUMERIC(20,5)
	DECLARE @MaterialOrderUnitPriceQty NUMERIC(20,5)
	DECLARE @MaterialOrderUnitPrice NUMERIC(20,5)
	DECLARE @MaterialOrderTotalPrice NUMERIC(20,5)
	DECLARE @MaterialOrderItemDesc NVARCHAR(MAX)
	DECLARE @PlanGrDate DATE
	DECLARE @IsCancel BIT
	DECLARE @MOIExtText01 NVARCHAR(MAX)
	DECLARE @MOIExtText02 NVARCHAR(MAX)
	DECLARE @MOIExtText03 NVARCHAR(MAX)
	DECLARE @MrpTargetNo VARCHAR(20)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)

    DECLARE @UID_KEY VARCHAR(50)

	DECLARE @iDoc INT

	DECLARE @OrderStatus VARCHAR(10)

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialOrderItem',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialOrderItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialOrderItemNo IS NULL THEN XMLData.MaterialOrderItemNo
							    ELSE XMLData.OldMaterialOrderItemNo
							END AS OldMaterialOrderItemNo,
							XMLData.MaterialOrderItemNo,
							XMLData.MaterialOrderNo,
							XMLData.MaterialCode,
							XMLData.MaterialStockAttribute,
							XMLData.MaterialAttribute,
							XMLData.StockAttrib1,
							XMLData.StockAttrib2,
							XMLData.StockAttrib3,
							XMLData.MaterialOrderQty,
							XMLData.MaterialOrderRemainQty,
							XMLData.MaterialOrderUnitPriceQty,
							XMLData.MaterialOrderUnitPrice,
							XMLData.MaterialOrderTotalPrice,
							XMLData.MaterialOrderItemDesc,
							XMLData.PlanGrDate,
							XMLData.IsCancel,
							XMLData.MOIExtText01,
							XMLData.MOIExtText02,
							XMLData.MOIExtText03,
							XMLData.MrpTargetNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialOrderItemNo VARCHAR(20),
										MaterialOrderItemNo VARCHAR(20),
										MaterialOrderNo VARCHAR(20),
										MaterialCode VARCHAR(50),
										MaterialStockAttribute VARCHAR(20),
										MaterialAttribute VARCHAR(20),
										StockAttrib1 VARCHAR(20),
										StockAttrib2 VARCHAR(20),
										StockAttrib3 VARCHAR(20),
										MaterialOrderQty NUMERIC(20,5),
										MaterialOrderRemainQty NUMERIC(20,5),
										MaterialOrderUnitPriceQty NUMERIC(20,5),
										MaterialOrderUnitPrice NUMERIC(20,5),
										MaterialOrderTotalPrice NUMERIC(20,5),
										MaterialOrderItemDesc NVARCHAR(MAX),
										PlanGrDate DATE,
										IsCancel BIT,
										MOIExtText01 NVARCHAR(MAX),
										MOIExtText02 NVARCHAR(MAX),
										MOIExtText03 NVARCHAR(MAX),
										MrpTargetNo NVARCHAR(20),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialOrderItemNo = SourceTable.MaterialOrderItemNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialOrderItemNo = SourceTable.MaterialOrderItemNo,
					MaterialOrderNo = SourceTable.MaterialOrderNo,
					MaterialCode = SourceTable.MaterialCode,
					MaterialStockAttribute = SourceTable.MaterialStockAttribute,
					MaterialAttribute = SourceTable.MaterialAttribute,
					StockAttrib1 = SourceTable.StockAttrib1,
					StockAttrib2 = SourceTable.StockAttrib2,
					StockAttrib3 = SourceTable.StockAttrib3,
					MaterialOrderQty = SourceTable.MaterialOrderQty,
					MaterialOrderRemainQty = SourceTable.MaterialOrderRemainQty,
					MaterialOrderUnitPriceQty = SourceTable.MaterialOrderUnitPriceQty,
					MaterialOrderUnitPrice = SourceTable.MaterialOrderUnitPrice,
					MaterialOrderTotalPrice = SourceTable.MaterialOrderTotalPrice,
					MaterialOrderItemDesc = SourceTable.MaterialOrderItemDesc,
					PlanGrDate = SourceTable.PlanGrDate,
					IsCancel = SourceTable.IsCancel,
					MOIExtText01 = SourceTable.MOIExtText01,
					MOIExtText02 = SourceTable.MOIExtText02,
					MOIExtText03 = SourceTable.MOIExtText03,
					MrpTargetNo = SourceTable.MrpTargetNo,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialOrderItemNo,
						MaterialOrderNo,
						MaterialCode,
						MaterialStockAttribute,
						MaterialAttribute,
						StockAttrib1,
						StockAttrib2,
						StockAttrib3,
						MaterialOrderQty,
						MaterialOrderRemainQty,
						MaterialOrderUnitPriceQty,
						MaterialOrderUnitPrice,
						MaterialOrderTotalPrice,
						MaterialOrderItemDesc,
						PlanGrDate,
						IsCancel,
						MOIExtText01,
						MOIExtText02,
						MOIExtText03,
						MrpTargetNo,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialOrderItemNo,
							SourceTable.MaterialOrderNo,
							SourceTable.MaterialCode,
							SourceTable.MaterialStockAttribute,
							SourceTable.MaterialAttribute,
							SourceTable.StockAttrib1,
							SourceTable.StockAttrib2,
							SourceTable.StockAttrib3,
							SourceTable.MaterialOrderQty,
							SourceTable.MaterialOrderRemainQty,
							SourceTable.MaterialOrderUnitPriceQty,
							SourceTable.MaterialOrderUnitPrice,
							SourceTable.MaterialOrderTotalPrice,
							SourceTable.MaterialOrderItemDesc,
							SourceTable.PlanGrDate,
							SourceTable.IsCancel,
							SourceTable.MOIExtText01,
							SourceTable.MOIExtText02,
							SourceTable.MOIExtText03,
							SourceTable.MrpTargetNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MaterialOrderItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialOrderItemNo IS NULL THEN XMLData.MaterialOrderItemNo
							    ELSE XMLData.OldMaterialOrderItemNo
							END AS OldMaterialOrderItemNo,
							XMLData.MaterialOrderItemNo,
							XMLData.MaterialOrderNo,
							XMLData.MaterialCode,
							XMLData.MaterialStockAttribute,
							XMLData.MaterialAttribute,
							XMLData.StockAttrib1,
							XMLData.StockAttrib2,
							XMLData.StockAttrib3,
							XMLData.MaterialOrderQty,
							XMLData.MaterialOrderRemainQty,
							XMLData.MaterialOrderUnitPriceQty,
							XMLData.MaterialOrderUnitPrice,
							XMLData.MaterialOrderTotalPrice,
							XMLData.MaterialOrderItemDesc,
							XMLData.PlanGrDate,
							XMLData.IsCancel,
							XMLData.MOIExtText01,
							XMLData.MOIExtText02,
							XMLData.MOIExtText03,
							XMLData.MrpTargetNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialOrderItemNo VARCHAR(20),
										MaterialOrderItemNo VARCHAR(20),
										MaterialOrderNo VARCHAR(20),
										MaterialCode VARCHAR(50),
										MaterialStockAttribute VARCHAR(20),
										MaterialAttribute VARCHAR(20),
										StockAttrib1 VARCHAR(20),
										StockAttrib2 VARCHAR(20),
										StockAttrib3 VARCHAR(20), 
										MaterialOrderQty NUMERIC(20,5),
										MaterialOrderRemainQty NUMERIC(20,5),
										MaterialOrderUnitPriceQty NUMERIC(20,5),
										MaterialOrderUnitPrice NUMERIC(20,5),
										MaterialOrderTotalPrice NUMERIC(20,5),
										MaterialOrderItemDesc NVARCHAR(MAX),
										PlanGrDate DATETIMEOFFSET,
										IsCancel BIT,
										MOIExtText01 NVARCHAR(MAX),
										MOIExtText02 NVARCHAR(MAX),
										MOIExtText03 NVARCHAR(MAX),
										MrpTargetNo NVARCHAR(20),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialOrderItemNo = SourceTable.OldMaterialOrderItemNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialOrderItemNo = SourceTable.MaterialOrderItemNo,
					MaterialOrderNo = SourceTable.MaterialOrderNo,
					MaterialCode = SourceTable.MaterialCode,
					MaterialStockAttribute = SourceTable.MaterialStockAttribute,
					MaterialAttribute = SourceTable.MaterialAttribute,
					StockAttrib1 = SourceTable.StockAttrib1,
					StockAttrib2 = SourceTable.StockAttrib2,
					StockAttrib3 = SourceTable.StockAttrib3,
					MaterialOrderQty = SourceTable.MaterialOrderQty,
					MaterialOrderRemainQty = SourceTable.MaterialOrderRemainQty,
					MaterialOrderUnitPriceQty = SourceTable.MaterialOrderUnitPriceQty,
					MaterialOrderUnitPrice = SourceTable.MaterialOrderUnitPrice,
					MaterialOrderTotalPrice = SourceTable.MaterialOrderTotalPrice,
					MaterialOrderItemDesc = SourceTable.MaterialOrderItemDesc,
					PlanGrDate = SourceTable.PlanGrDate,
					IsCancel = SourceTable.IsCancel,
					MOIExtText01 = SourceTable.MOIExtText01,
					MOIExtText02 = SourceTable.MOIExtText02,
					MOIExtText03 = SourceTable.MOIExtText03,
					MrpTargetNo = SourceTable.MrpTargetNo,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialOrderItemNo,
						MaterialOrderNo,
						MaterialCode,
						MaterialStockAttribute,
						MaterialAttribute,
						StockAttrib1,
						StockAttrib2,
						StockAttrib3,
						MaterialOrderQty,
						MaterialOrderRemainQty,
						MaterialOrderUnitPriceQty,
						MaterialOrderUnitPrice,
						MaterialOrderTotalPrice,
						MaterialOrderItemDesc,
						PlanGrDate,
						IsCancel,
						MOIExtText01,
						MOIExtText02,
						MOIExtText03,
						MrpTargetNo,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialOrderItemNo,
							SourceTable.MaterialOrderNo,
							SourceTable.MaterialCode,
							SourceTable.MaterialStockAttribute,
							SourceTable.MaterialAttribute,
							SourceTable.StockAttrib1,
							SourceTable.StockAttrib2,
							SourceTable.StockAttrib3,
							SourceTable.MaterialOrderQty,
							SourceTable.MaterialOrderRemainQty,
							SourceTable.MaterialOrderUnitPriceQty,
							SourceTable.MaterialOrderUnitPrice,
							SourceTable.MaterialOrderTotalPrice,
							SourceTable.MaterialOrderItemDesc,
							SourceTable.PlanGrDate,
							SourceTable.IsCancel,
							SourceTable.MOIExtText01,
							SourceTable.MOIExtText02,
							SourceTable.MOIExtText03,
							SourceTable.MrpTargetNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MaterialOrderItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialOrderItemNo IS NULL THEN XMLData.MaterialOrderItemNo
							    ELSE XMLData.OldMaterialOrderItemNo
							END AS OldMaterialOrderItemNo,
							XMLData.MaterialOrderItemNo,
							XMLData.MaterialOrderNo,
							XMLData.MaterialCode,
							XMLData.MaterialStockAttribute,
							XMLData.MaterialAttribute,
							XMLData.StockAttrib1,
							XMLData.StockAttrib2,
							XMLData.StockAttrib3,
							XMLData.MaterialOrderQty,
							XMLData.MaterialOrderRemainQty,
							XMLData.MaterialOrderUnitPriceQty,
							XMLData.MaterialOrderUnitPrice,
							XMLData.MaterialOrderTotalPrice,
							XMLData.MaterialOrderItemDesc,
							XMLData.PlanGrDate,
							XMLData.IsCancel,
							XMLData.MOIExtText01,
							XMLData.MOIExtText02,
							XMLData.MOIExtText03,
							XMLData.MrpTargetNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialOrderItemNo VARCHAR(20),
										MaterialOrderItemNo VARCHAR(20),
										MaterialOrderNo VARCHAR(20),
										MaterialCode VARCHAR(50),
										MaterialStockAttribute VARCHAR(20),
										MaterialAttribute VARCHAR(20),
										StockAttrib1 VARCHAR(20),
										StockAttrib2 VARCHAR(20),
										StockAttrib3 VARCHAR(20), 
										MaterialOrderQty NUMERIC(20,5),
										MaterialOrderRemainQty NUMERIC(20,5),
										MaterialOrderUnitPriceQty NUMERIC(20,5),
										MaterialOrderUnitPrice NUMERIC(20,5),
										MaterialOrderTotalPrice NUMERIC(20,5),
										MaterialOrderItemDesc NVARCHAR(MAX),
										PlanGrDate DATETIMEOFFSET,
										IsCancel BIT,
										MOIExtText01 NVARCHAR(MAX),
										MOIExtText02 NVARCHAR(MAX),
										MOIExtText03 NVARCHAR(MAX),
										MrpTargetNo NVARCHAR(20),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialOrderItemNo = SourceTable.MaterialOrderItemNo
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
									XMLData.OldMaterialOrderItemNo,
									XMLData.MaterialOrderItemNo,
									XMLData.MaterialOrderNo,
									XMLData.MaterialCode,
									XMLData.MaterialStockAttribute,
									XMLData.MaterialAttribute,
									XMLData.StockAttrib1,
									XMLData.StockAttrib2,
									XMLData.StockAttrib3,
									XMLData.MaterialOrderQty,
									XMLData.MaterialOrderRemainQty,
									XMLData.MaterialOrderUnitPriceQty,
									XMLData.MaterialOrderUnitPrice,
									XMLData.MaterialOrderTotalPrice,
									XMLData.MaterialOrderItemDesc,
									XMLData.PlanGrDate,
									XMLData.IsCancel,
									XMLData.MOIExtText01,
									XMLData.MOIExtText02,
									XMLData.MOIExtText03,
									XMLData.MrpTargetNo,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialOrderItemNo VARCHAR(20),
											 MaterialOrderItemNo VARCHAR(20),
											 MaterialOrderNo VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 MaterialStockAttribute VARCHAR(20),
											 MaterialAttribute VARCHAR(20),
											 StockAttrib1 VARCHAR(20),
											 StockAttrib2 VARCHAR(20),
											 StockAttrib3 VARCHAR(20), 
											 MaterialOrderQty NUMERIC(20,5),
											 MaterialOrderRemainQty NUMERIC(20,5),
											 MaterialOrderUnitPriceQty NUMERIC(20,5),
											 MaterialOrderUnitPrice NUMERIC(20,5),
											 MaterialOrderTotalPrice NUMERIC(20,5),
											 MaterialOrderItemDesc NVARCHAR(MAX),
											 PlanGrDate DATETIMEOFFSET,
											 IsCancel BIT,
											 MOIExtText01 NVARCHAR(MAX),
											 MOIExtText02 NVARCHAR(MAX),
											 MOIExtText03 NVARCHAR(MAX),
											 MrpTargetNo NVARCHAR(20),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMaterialOrderItemNo IS NULL THEN XMLData.MaterialOrderItemNo
										ELSE XMLData.OldMaterialOrderItemNo
									END AS OldMaterialOrderItemNo,
									XMLData.MaterialOrderItemNo,
									XMLData.MaterialOrderNo,
									XMLData.MaterialCode,
									XMLData.MaterialStockAttribute,
									XMLData.MaterialAttribute,
									XMLData.StockAttrib1,
									XMLData.StockAttrib2,
									XMLData.StockAttrib3,
									XMLData.MaterialOrderQty,
									XMLData.MaterialOrderRemainQty,
									XMLData.MaterialOrderUnitPriceQty,
									XMLData.MaterialOrderUnitPrice,
									XMLData.MaterialOrderTotalPrice,
									XMLData.MaterialOrderItemDesc,
									XMLData.PlanGrDate,
									XMLData.IsCancel,
									XMLData.MOIExtText01,
									XMLData.MOIExtText02,
									XMLData.MOIExtText03,
									XMLData.MrpTargetNo,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialOrderItemNo VARCHAR(20),
											 MaterialOrderItemNo VARCHAR(20),
											 MaterialOrderNo VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 MaterialStockAttribute VARCHAR(20),
											 MaterialAttribute VARCHAR(20),
											 StockAttrib1 VARCHAR(20),
											 StockAttrib2 VARCHAR(20),
											 StockAttrib3 VARCHAR(20),
											 MaterialOrderQty NUMERIC(20,5),
											 MaterialOrderRemainQty NUMERIC(20,5),
											 MaterialOrderUnitPriceQty NUMERIC(20,5),
											 MaterialOrderUnitPrice NUMERIC(20,5),
											 MaterialOrderTotalPrice NUMERIC(20,5),
											 MaterialOrderItemDesc NVARCHAR(MAX),
											 PlanGrDate DATETIMEOFFSET,
											 IsCancel BIT,
											 MOIExtText01 NVARCHAR(MAX),
											 MOIExtText02 NVARCHAR(MAX),
											 MOIExtText03 NVARCHAR(MAX),
											 MrpTargetNo NVARCHAR(20),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMaterialOrderItemNo IS NULL THEN XMLData.MaterialOrderItemNo
										ELSE XMLData.OldMaterialOrderItemNo
									END AS OldMaterialOrderItemNo,
									XMLData.MaterialOrderItemNo,
									XMLData.MaterialOrderNo,
									XMLData.MaterialCode,
									XMLData.MaterialStockAttribute,
									XMLData.MaterialAttribute,
									XMLData.StockAttrib1,
									XMLData.StockAttrib2,
									XMLData.StockAttrib3,
									XMLData.MaterialOrderQty,
									XMLData.MaterialOrderRemainQty,
									XMLData.MaterialOrderUnitPriceQty,
									XMLData.MaterialOrderUnitPrice,
									XMLData.MaterialOrderTotalPrice,
									XMLData.MaterialOrderItemDesc,
									XMLData.PlanGrDate,
									XMLData.IsCancel,
									XMLData.MOIExtText01,
									XMLData.MOIExtText02,
									XMLData.MOIExtText03,
									XMLData.MrpTargetNo,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialOrderItemNo VARCHAR(20),
											 MaterialOrderItemNo VARCHAR(20),
											 MaterialOrderNo VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 MaterialStockAttribute VARCHAR(20),
											 MaterialAttribute VARCHAR(20),
											 StockAttrib1 VARCHAR(20),
											 StockAttrib2 VARCHAR(20),
											 StockAttrib3 VARCHAR(20),
											 MaterialOrderQty NUMERIC(20,5),
											 MaterialOrderRemainQty NUMERIC(20,5),
											 MaterialOrderUnitPriceQty NUMERIC(20,5),
											 MaterialOrderUnitPrice NUMERIC(20,5),
											 MaterialOrderTotalPrice NUMERIC(20,5),
											 MaterialOrderItemDesc NVARCHAR(MAX),
											 PlanGrDate DATETIMEOFFSET,
											 IsCancel BIT,
											 MOIExtText01 NVARCHAR(MAX),
											 MOIExtText02 NVARCHAR(MAX),
											 MOIExtText03 NVARCHAR(MAX),
											 MrpTargetNo NVARCHAR(20),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialOrderItemNo,
								 @MaterialOrderItemNo,
								 @MaterialOrderNo,
								 @MaterialCode,
								 @MaterialStockAttribute,
								 @MaterialAttribute,
								 @StockAttrib1,
								 @StockAttrib2,
								 @StockAttrib3,
								 @MaterialOrderQty,
								 @MaterialOrderRemainQty,
								 @MaterialOrderUnitPriceQty,
								 @MaterialOrderUnitPrice,
								 @MaterialOrderTotalPrice,
								 @MaterialOrderItemDesc,
								 @PlanGrDate,
								 @IsCancel,
								 @MOIExtText01,
								 @MOIExtText02,
								 @MOIExtText03,
								 @MrpTargetNo,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
			


				SELECT
						@OrderStatus = MO.OrderStatus
				FROM
						STB_MaterialOrder MO
				WHERE 
						MO.MaterialOrderNo = @MaterialOrderNo
				

				IF @OrderStatus <> 'REQUEST' BEGIN
					RAISERROR('CurrentOrderStatus  = %s', 16, 1, @OrderStatus)
				END			

				
                IF @IUD_FLAG = 'INSERT' BEGIN
					
					
					
                    IF EXISTS (SELECT 1 FROM STB_MaterialOrderItem WHERE MaterialOrderItemNo = @MaterialOrderItemNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialOrderItemNo)
					END
							

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialOrderItem', @MaterialOrderItemNo OUTPUT
                    END
                    
					-- 임시SEQUENCE TABLE 사용버젼 : DETAIL 사용
					

					SET @UID_KEY = @MaterialOrderNo

					SET @MaterialOrderNo = NULL
										
					SELECT 
						@MaterialOrderNo = KeyValue
					FROM 
						#SEQUENCE_TABLE
					WHERE
						UID_KEY = @UID_KEY
										
					IF @MaterialOrderNo IS NULL
					BEGIN
						SET @MaterialOrderNo = @UID_KEY
					END
					--
                    
                    
                    IF (SELECT OrderStatus FROM STB_MaterialOrder WHERE MaterialOrderNo = @MaterialOrderNo) <> 'REQUEST' BEGIN
						RAISERROR('OrderStatus IS NOT REQUEST' , 16, 1)
					END
                    


                    INSERT INTO STB_MaterialOrderItem
						(
						    MaterialOrderItemNo,
						    MaterialOrderNo,
						    MaterialCode,
						    MaterialStockAttribute,
						    MaterialAttribute,
						    StockAttrib1,
						    StockAttrib2,
						    StockAttrib3,
						    MaterialOrderQty,
						    MaterialOrderRemainQty,
						    MaterialOrderUnitPriceQty,
						    MaterialOrderUnitPrice,
						    MaterialOrderTotalPrice,
						    MaterialOrderItemDesc,
							PlanGrDate,
						    IsCancel,
						    MOIExtText01,
						    MOIExtText02,
						    MOIExtText03,
							MrpTargetNO,
						    CreateDateTime,
						    CreateUserID
						)
						VALUES
						(
						    @MaterialOrderItemNo,
						    @MaterialOrderNo,
						    @MaterialCode,
						    @MaterialStockAttribute,
						    @MaterialAttribute,
						    @StockAttrib1,
						    @StockAttrib2,
						    @StockAttrib3,
						    @MaterialOrderQty,
						    @MaterialOrderQty,  -- Remain Qty
						    @MaterialOrderUnitPriceQty,
						    @MaterialOrderUnitPrice,
						    --@MaterialOrderTotalPrice,
						    CASE WHEN @MaterialOrderUnitPriceQty < 1 THEN 0 ELSE
						    ((@MaterialOrderQty / @MaterialOrderUnitPriceQty) * @MaterialOrderUnitPrice) END,
						    @MaterialOrderItemDesc,
							@PlanGrDate,
						    @IsCancel,
						    @MOIExtText01,
						    @MOIExtText02,
						    @MOIExtText03,
							@MrpTargetNo,
						    GETDATE(),
						    @pProcessUserID
						)
						
						UPDATE STB_MaterialOrder 
						SET 
								TotalItemQty = (SELECT COUNT(1) FROM STB_MaterialOrderItem WHERE MaterialOrderNo = @MaterialOrderNo AND IsCancel = 0),
								TotalOrderPrice = (SELECT SUM(MaterialOrderTotalPrice) FROM STB_MaterialOrderItem WHERE MaterialOrderNo = @MaterialOrderNo AND IsCancel = 0)
						WHERE
								MaterialOrderNo = @MaterialOrderNo

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					
					IF (SELECT OrderStatus FROM STB_MaterialOrder WHERE MaterialOrderNo = @MaterialOrderNo) <> 'REQUEST' BEGIN
						RAISERROR('OrderStatus IS NOT REQUEST' , 16, 1)
					END
					
                    UPDATE STB_MaterialOrderItem
						SET
							
						    MaterialCode =   CASE
						                WHEN @MaterialCode IS NOT NULL THEN @MaterialCode
						                ELSE MaterialCode
						            END,
						    MaterialStockAttribute =   CASE
						                WHEN @MaterialStockAttribute IS NOT NULL THEN @MaterialStockAttribute
						                ELSE MaterialStockAttribute
						            END,
						    MaterialAttribute =   CASE
						                WHEN @MaterialAttribute IS NOT NULL THEN @MaterialAttribute
						                ELSE MaterialAttribute
						            END,
						    StockAttrib1 =   CASE
						                WHEN @StockAttrib1 IS NOT NULL THEN @StockAttrib1
						                ELSE StockAttrib1
						            END,
						    StockAttrib2 =   CASE
						                WHEN @StockAttrib2 IS NOT NULL THEN @StockAttrib2
						                ELSE StockAttrib2
						            END,
						    StockAttrib3 =   CASE
						                WHEN @StockAttrib3 IS NOT NULL THEN @StockAttrib3
						                ELSE StockAttrib3
						            END,
						    MaterialOrderQty =   CASE
						                WHEN @MaterialOrderQty IS NOT NULL THEN @MaterialOrderQty
						                ELSE MaterialOrderQty
						            END,
						    MaterialOrderRemainQty =   CASE
						                WHEN @MaterialOrderQty IS NOT NULL THEN @MaterialOrderQty
						                ELSE MaterialOrderQty
						            END,
						    MaterialOrderUnitPriceQty = CASE
										WHEN @MaterialOrderUnitPriceQty IS NOT NULL THEN @MaterialOrderUnitPriceQty
										ELSE MaterialOrderUnitPriceQty
									END, 
						    MaterialOrderUnitPrice =   CASE
						                WHEN @MaterialOrderUnitPrice IS NOT NULL THEN @MaterialOrderUnitPrice
						                ELSE MaterialOrderUnitPrice
						            END,
						    MaterialOrderTotalPrice =   CASE WHEN @MaterialOrderUnitPriceQty < 1 THEN 0 
						    ELSE ((@MaterialOrderQty / @MaterialOrderUnitPriceQty) * @MaterialOrderUnitPrice) END,
						    
						   
						    MaterialOrderItemDesc =   CASE
						                WHEN @MaterialOrderItemDesc IS NOT NULL THEN @MaterialOrderItemDesc
						                ELSE MaterialOrderItemDesc
						            END,
							PlanGrDate =   CASE
						                WHEN @PlanGrDate IS NOT NULL THEN @PlanGrDate
						                ELSE PlanGrDate
						            END,
						    IsCancel =   CASE
						                WHEN @IsCancel IS NOT NULL THEN @IsCancel
						                ELSE IsCancel
						            END,
						    MOIExtText01 =   CASE
						                WHEN @MOIExtText01 IS NOT NULL THEN @MOIExtText01
						                ELSE MOIExtText01
						            END,
						    MOIExtText02 =   CASE
						                WHEN @MOIExtText02 IS NOT NULL THEN @MOIExtText02
						                ELSE MOIExtText02
						            END,
						    MOIExtText03 =   CASE
						                WHEN @MOIExtText03 IS NOT NULL THEN @MOIExtText03
						                ELSE MOIExtText03
						            END,
						    MrpTargetNo =   CASE
						                WHEN @MrpTargetNo IS NOT NULL THEN @MrpTargetNo
						                ELSE MrpTargetNo
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialOrderItemNo = @OldMaterialOrderItemNo
						    
						
						
						

								
								
						UPDATE STB_MaterialOrder 
						SET 
								TotalItemQty = (SELECT COUNT(1) FROM STB_MaterialOrderItem WHERE MaterialOrderNo = @MaterialOrderNo AND IsCancel = 0),
								TotalOrderPrice = (SELECT SUM(MaterialOrderTotalPrice) FROM STB_MaterialOrderItem WHERE MaterialOrderNo = @MaterialOrderNo AND IsCancel = 0),
								IsAllCancel = CASE WHEN (SELECT COUNT(1) FROM STB_MaterialOrderItem WHERE MaterialOrderNo = @MaterialOrderNo AND IsCancel = 0) > 0 THEN 0
													ELSE 1 END,
								AllCencelUserID = CASE WHEN (SELECT COUNT(1) FROM STB_MaterialOrderItem WHERE MaterialOrderNo = @MaterialOrderNo AND IsCancel = 0) > 0 THEN NULL
													ELSE @pProcessUserID END
						WHERE
								MaterialOrderNo = @MaterialOrderNo    
						   
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                
						IF (SELECT OrderStatus FROM STB_MaterialOrder WHERE MaterialOrderNo = @MaterialOrderNo) <> 'REQUEST' BEGIN
							RAISERROR('OrderStatus IS NOT REQUEST' , 16, 1)
						END
					
						DELETE FROM STB_MaterialOrderItem
						WHERE
						    MaterialOrderItemNo = @MaterialOrderItemNo
						    
					
						UPDATE STB_MaterialOrder 
						SET 
								TotalItemQty = (SELECT COUNT(1) FROM STB_MaterialOrderItem WHERE MaterialOrderNo = @MaterialOrderNo AND IsCancel = 0),
								TotalOrderPrice = (SELECT SUM(MaterialOrderTotalPrice) FROM STB_MaterialOrderItem WHERE MaterialOrderNo = @MaterialOrderNo AND IsCancel = 0)
						WHERE
								MaterialOrderNo = @MaterialOrderNo

						IF	(
								SELECT 
										COUNT(*) 
								FROM 
										sys.tables  T
								WHERE
										T.name = 'STB_MrpTargetMaterial'
							) > 0
						BEGIN
								UPDATE STB_MrpTargetMaterial
								SET
										MaterialOrderNo = NULL,
										MaterialOrderItemNo = NULL
								WHERE
										MaterialOrderItemNo = @MaterialOrderItemNo
						END
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


