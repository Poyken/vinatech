

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-04
-- Browsable : true
-- Group : 자재관리
-- Description:	자재발주전표 Fix
-- Modified: 
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoChangeFixMaterialOrder]
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
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
	DECLARE @OldMaterialOrderNo VARCHAR(20)
	DECLARE @MaterialOrderNo VARCHAR(20)
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @MOCreateType VARCHAR(10)
	DECLARE @CustomerCode VARCHAR(20)
	DECLARE @OrderFromUserID VARCHAR(20)
	DECLARE @OrderToName NVARCHAR(50)
	DECLARE @MaterialWarehouseCode VARCHAR(20)
	DECLARE @OrderDate DATE
	DECLARE @DeliveryPlanDate DATE
	DECLARE @TotalItemQty INT
	DECLARE @TotalOrderPrice NUMERIC(20,5)
	DECLARE @OrderStatus VARCHAR(10)
	DECLARE @IsAllCancel BIT
	DECLARE @AllCencelUserID VARCHAR(20)
	DECLARE @IsFinished BIT
	DECLARE @FinishedUserID VARCHAR(20)
	DECLARE @MOExtText01 NVARCHAR(MAX)
	DECLARE @MOExtText02 NVARCHAR(MAX)
	DECLARE @MOExtText03 NVARCHAR(MAX)
	DECLARE @MOExtText04 NVARCHAR(MAX)
	DECLARE @MOExtText05 NVARCHAR(MAX)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

   -- EXEC SmartFramework.dbo.usp_GetSerialRule 
			--@pTableName = 'STB_MaterialOrder',
			--@pIsAutoKey = @IsAutoKey OUTPUT,
			--@pIsLoopIUD = @IsLoopIUD OUTPUT,
			--@pPrefixData = @PrefixString OUTPUT,
			--@pSerialLen = @SerialLen OUTPUT
	SET @IsLoopIUD = 1
	SET @IsAutoKey = 0
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialOrder AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialOrderNo IS NULL THEN XMLData.MaterialOrderNo
							    ELSE XMLData.OldMaterialOrderNo
							END AS OldMaterialOrderNo,
							XMLData.MaterialOrderNo,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.MOCreateType,
							XMLData.CustomerCode,
							XMLData.OrderFromUserID,
							XMLData.OrderToName,
							XMLData.MaterialWarehouseCode,
							XMLData.OrderDate,
							XMLData.DeliveryPlanDate,
							XMLData.TotalItemQty,
							XMLData.TotalOrderPrice,
							XMLData.OrderStatus,
							XMLData.IsAllCancel,
							XMLData.AllCencelUserID,
							XMLData.IsFinished,
							XMLData.FinishedUserID,
							XMLData.MOExtText01,
							XMLData.MOExtText02,
							XMLData.MOExtText03,
							XMLData.MOExtText04,
							XMLData.MOExtText05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialOrderNo VARCHAR(20),
										MaterialOrderNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MOCreateType VARCHAR(10),
										CustomerCode VARCHAR(20),
										OrderFromUserID VARCHAR(20),
										OrderToName NVARCHAR(50),
										MaterialWarehouseCode VARCHAR(20),
										OrderDate  DATETIMEOFFSET,
										DeliveryPlanDate  DATETIMEOFFSET,
										TotalItemQty INT,
										TotalOrderPrice NUMERIC(20,5),
										OrderStatus VARCHAR(10),
										IsAllCancel BIT,
										AllCencelUserID VARCHAR(20),
										IsFinished BIT,
										FinishedUserID VARCHAR(20),
										MOExtText01 NVARCHAR(MAX),
										MOExtText02 NVARCHAR(MAX),
										MOExtText03 NVARCHAR(MAX),
										MOExtText04 NVARCHAR(MAX),
										MOExtText05 NVARCHAR(MAX),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialOrderNo = SourceTable.MaterialOrderNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialOrderNo = SourceTable.MaterialOrderNo,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					MOCreateType = SourceTable.MOCreateType,
					CustomerCode = SourceTable.CustomerCode,
					OrderFromUserID = SourceTable.OrderFromUserID,
					OrderToName = SourceTable.OrderToName,
					MaterialWarehouseCode = SourceTable.MaterialWarehouseCode,
					OrderDate = SourceTable.OrderDate,
					DeliveryPlanDate = SourceTable.DeliveryPlanDate,
					TotalItemQty = SourceTable.TotalItemQty,
					TotalOrderPrice = SourceTable.TotalOrderPrice,
					OrderStatus = SourceTable.OrderStatus,
					IsAllCancel = SourceTable.IsAllCancel,
					AllCencelUserID = SourceTable.AllCencelUserID,
					IsFinished = SourceTable.IsFinished,
					FinishedUserID = SourceTable.FinishedUserID,
					MOExtText01 = SourceTable.MOExtText01,
					MOExtText02 = SourceTable.MOExtText02,
					MOExtText03 = SourceTable.MOExtText03,
					MOExtText04 = SourceTable.MOExtText04,
					MOExtText05 = SourceTable.MOExtText05,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialOrderNo,
						CompanyCode,
						WorkCenterCode,
						MOCreateType,
						CustomerCode,
						OrderFromUserID,
						OrderToName,
						MaterialWarehouseCode,
						OrderDate,
						DeliveryPlanDate,
						TotalItemQty,
						TotalOrderPrice,
						OrderStatus,
						IsAllCancel,
						AllCencelUserID,
						IsFinished,
						FinishedUserID,
						MOExtText01,
						MOExtText02,
						MOExtText03,
						MOExtText04,
						MOExtText05,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialOrderNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MOCreateType,
							SourceTable.CustomerCode,
							SourceTable.OrderFromUserID,
							SourceTable.OrderToName,
							SourceTable.MaterialWarehouseCode,
							SourceTable.OrderDate,
							SourceTable.DeliveryPlanDate,
							SourceTable.TotalItemQty,
							SourceTable.TotalOrderPrice,
							SourceTable.OrderStatus,
							SourceTable.IsAllCancel,
							SourceTable.AllCencelUserID,
							SourceTable.IsFinished,
							SourceTable.FinishedUserID,
							SourceTable.MOExtText01,
							SourceTable.MOExtText02,
							SourceTable.MOExtText03,
							SourceTable.MOExtText04,
							SourceTable.MOExtText05,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MaterialOrder AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialOrderNo IS NULL THEN XMLData.MaterialOrderNo
							    ELSE XMLData.OldMaterialOrderNo
							END AS OldMaterialOrderNo,
							XMLData.MaterialOrderNo,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.MOCreateType,
							XMLData.CustomerCode,
							XMLData.OrderFromUserID,
							XMLData.OrderToName,
							XMLData.MaterialWarehouseCode,
							XMLData.OrderDate,
							XMLData.DeliveryPlanDate,
							XMLData.TotalItemQty,
							XMLData.TotalOrderPrice,
							XMLData.OrderStatus,
							XMLData.IsAllCancel,
							XMLData.AllCencelUserID,
							XMLData.IsFinished,
							XMLData.FinishedUserID,
							XMLData.MOExtText01,
							XMLData.MOExtText02,
							XMLData.MOExtText03,
							XMLData.MOExtText04,
							XMLData.MOExtText05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialOrderNo VARCHAR(20),
										MaterialOrderNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MOCreateType VARCHAR(10),
										CustomerCode VARCHAR(20),
										OrderFromUserID VARCHAR(20),
										OrderToName NVARCHAR(50),
										MaterialWarehouseCode VARCHAR(20),
										OrderDate  DATETIMEOFFSET,
										DeliveryPlanDate  DATETIMEOFFSET,
										TotalItemQty INT,
										TotalOrderPrice NUMERIC(20,5),
										OrderStatus VARCHAR(10),
										IsAllCancel BIT,
										AllCencelUserID VARCHAR(20),
										IsFinished BIT,
										FinishedUserID VARCHAR(20),
										MOExtText01 NVARCHAR(MAX),
										MOExtText02 NVARCHAR(MAX),
										MOExtText03 NVARCHAR(MAX),
										MOExtText04 NVARCHAR(MAX),
										MOExtText05 NVARCHAR(MAX),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialOrderNo = SourceTable.OldMaterialOrderNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialOrderNo = SourceTable.MaterialOrderNo,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					MOCreateType = SourceTable.MOCreateType,
					CustomerCode = SourceTable.CustomerCode,
					OrderFromUserID = SourceTable.OrderFromUserID,
					OrderToName = SourceTable.OrderToName,
					MaterialWarehouseCode = SourceTable.MaterialWarehouseCode,
					OrderDate = SourceTable.OrderDate,
					DeliveryPlanDate = SourceTable.DeliveryPlanDate,
					TotalItemQty = SourceTable.TotalItemQty,
					TotalOrderPrice = SourceTable.TotalOrderPrice,
					OrderStatus = SourceTable.OrderStatus,
					IsAllCancel = SourceTable.IsAllCancel,
					AllCencelUserID = SourceTable.AllCencelUserID,
					IsFinished = SourceTable.IsFinished,
					FinishedUserID = SourceTable.FinishedUserID,
					MOExtText01 = SourceTable.MOExtText01,
					MOExtText02 = SourceTable.MOExtText02,
					MOExtText03 = SourceTable.MOExtText03,
					MOExtText04 = SourceTable.MOExtText04,
					MOExtText05 = SourceTable.MOExtText05,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialOrderNo,
						CompanyCode,
						WorkCenterCode,
						MOCreateType,
						CustomerCode,
						OrderFromUserID,
						OrderToName,
						MaterialWarehouseCode,
						OrderDate,
						DeliveryPlanDate,
						TotalItemQty,
						TotalOrderPrice,
						OrderStatus,
						IsAllCancel,
						AllCencelUserID,
						IsFinished,
						FinishedUserID,
						MOExtText01,
						MOExtText02,
						MOExtText03,
						MOExtText04,
						MOExtText05,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialOrderNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MOCreateType,
							SourceTable.CustomerCode,
							SourceTable.OrderFromUserID,
							SourceTable.OrderToName,
							SourceTable.MaterialWarehouseCode,
							SourceTable.OrderDate,
							SourceTable.DeliveryPlanDate,
							SourceTable.TotalItemQty,
							SourceTable.TotalOrderPrice,
							SourceTable.OrderStatus,
							SourceTable.IsAllCancel,
							SourceTable.AllCencelUserID,
							SourceTable.IsFinished,
							SourceTable.FinishedUserID,
							SourceTable.MOExtText01,
							SourceTable.MOExtText02,
							SourceTable.MOExtText03,
							SourceTable.MOExtText04,
							SourceTable.MOExtText05,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MaterialOrder AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialOrderNo IS NULL THEN XMLData.MaterialOrderNo
							    ELSE XMLData.OldMaterialOrderNo
							END AS OldMaterialOrderNo,
							XMLData.MaterialOrderNo,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.MOCreateType,
							XMLData.CustomerCode,
							XMLData.OrderFromUserID,
							XMLData.OrderToName,
							XMLData.MaterialWarehouseCode,
							XMLData.OrderDate,
							XMLData.DeliveryPlanDate,
							XMLData.TotalItemQty,
							XMLData.TotalOrderPrice,
							XMLData.OrderStatus,
							XMLData.IsAllCancel,
							XMLData.AllCencelUserID,
							XMLData.IsFinished,
							XMLData.FinishedUserID,
							XMLData.MOExtText01,
							XMLData.MOExtText02,
							XMLData.MOExtText03,
							XMLData.MOExtText04,
							XMLData.MOExtText05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialOrderNo VARCHAR(20),
										MaterialOrderNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MOCreateType VARCHAR(10),
										CustomerCode VARCHAR(20),
										OrderFromUserID VARCHAR(20),
										OrderToName NVARCHAR(50),
										MaterialWarehouseCode VARCHAR(20),
										OrderDate  DATETIMEOFFSET,
										DeliveryPlanDate  DATETIMEOFFSET,
										TotalItemQty INT,
										TotalOrderPrice NUMERIC(20,5),
										OrderStatus VARCHAR(10),
										IsAllCancel BIT,
										AllCencelUserID VARCHAR(20),
										IsFinished BIT,
										FinishedUserID VARCHAR(20),
										MOExtText01 NVARCHAR(MAX),
										MOExtText02 NVARCHAR(MAX),
										MOExtText03 NVARCHAR(MAX),
										MOExtText04 NVARCHAR(MAX),
										MOExtText05 NVARCHAR(MAX),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialOrderNo = SourceTable.MaterialOrderNo
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
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMaterialOrderNo IS NULL THEN XMLData.MaterialOrderNo
										ELSE XMLData.OldMaterialOrderNo
									END AS OldMaterialOrderNo,
									XMLData.MaterialOrderNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.MOCreateType,
									XMLData.CustomerCode,
									XMLData.OrderFromUserID,
									XMLData.OrderToName,
									XMLData.MaterialWarehouseCode,
									XMLData.OrderDate,
									XMLData.DeliveryPlanDate,
									XMLData.TotalItemQty,
									XMLData.TotalOrderPrice,
									XMLData.OrderStatus,
									XMLData.IsAllCancel,
									XMLData.AllCencelUserID,
									XMLData.IsFinished,
									XMLData.FinishedUserID,
									XMLData.MOExtText01,
									XMLData.MOExtText02,
									XMLData.MOExtText03,
									XMLData.MOExtText04,
									XMLData.MOExtText05,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialOrderNo VARCHAR(20),
											 MaterialOrderNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MOCreateType VARCHAR(10),
											 CustomerCode VARCHAR(20),
											 OrderFromUserID VARCHAR(20),
											 OrderToName NVARCHAR(50),
											 MaterialWarehouseCode VARCHAR(20),
											 OrderDate  DATETIMEOFFSET,
											 DeliveryPlanDate  DATETIMEOFFSET,
											 TotalItemQty INT,
											 TotalOrderPrice NUMERIC(20,5),
											 OrderStatus VARCHAR(10),
											 IsAllCancel BIT,
											 AllCencelUserID VARCHAR(20),
											 IsFinished BIT,
											 FinishedUserID VARCHAR(20),
											 MOExtText01 NVARCHAR(MAX),
											 MOExtText02 NVARCHAR(MAX),
											 MOExtText03 NVARCHAR(MAX),
											 MOExtText04 NVARCHAR(MAX),
											 MOExtText05 NVARCHAR(MAX),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialOrderNo,
								 @MaterialOrderNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @MOCreateType,
								 @CustomerCode,
								 @OrderFromUserID,
								 @OrderToName,
								 @MaterialWarehouseCode,
								 @OrderDate,
								 @DeliveryPlanDate,
								 @TotalItemQty,
								 @TotalOrderPrice,
								 @OrderStatus,
								 @IsAllCancel,
								 @AllCencelUserID,
								 @IsFinished,
								 @FinishedUserID,
								 @MOExtText01,
								 @MOExtText02,
								 @MOExtText03,
								 @MOExtText04,
								 @MOExtText05,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'UPDATE' BEGIN
					
					
					IF @OrderStatus <> 'REQUEST' BEGIN
						RAISERROR('Can not Change FIX,Current OrderStatus  = %s', 16, 1, @OrderStatus)
					END
					
			
                    UPDATE STB_MaterialOrder
					SET
						  
						    OrderStatus =  'FIX',
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
					WHERE
						    MaterialOrderNo = @OldMaterialOrderNo
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


