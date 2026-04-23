
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-04
-- Browsable : true
-- Group : 자재관리
-- Description:	자재발주전표 IUD
-- Modified:
-- =============================================
Create PROCEDURE [dbo].[usp_DayMaterialOrder_iud_Test]
	@pProcessUserID VARCHAR(20) = null,
	@pProcessLanguage VARCHAR(20) = null,
    @pProcessViewName VARCHAR(50) = null,
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
	DECLARE @OldMaterialOrderNo VARCHAR(20)
	DECLARE @MaterialOrderNo VARCHAR(20)
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @Linecode NVARCHAR(50)            -- Mã dòng sản xuất
	DECLARE @Materialcode NVARCHAR(50)        -- Mã vật liệu
	DECLARE @OrderQty INT                     -- Số lượng đơn hàng
	DECLARE @OrderStatus NVARCHAR(20)         -- Trạng thái đơn hàng
	DECLARE @OrderDate DATETIME               -- Ngày tạo đơn hàng
	DECLARE @IsFinish BIT                     -- Trạng thái hoàn thành
	DECLARE @CreateDateTime DATETIME         -- Thời gian tạo bản ghi
	DECLARE @CreateUserID NVARCHAR(50)       -- Người tạo bản ghi
	DECLARE @ChangeDateTime DATETIME         -- Thời gian thay đổi bản ghi
	DECLARE @ChangeUserID NVARCHAR(50)      -- Người thay đổi bản ghi


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_DayMaterialOrder',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    --raiserror ('check',16,1)
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY


			-- Process Insert Table
            MERGE STB_DayMaterialOrder  AS TargetTable
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
							XMLData.Linecode,
							XMLData.Materialcode,
							XMLData.OrderQty,
							XMLData.OrderStatus,
							XMLData.OrderDate,
							XMLData.IsFinish,
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
										 Linecode NVARCHAR(50),            -- Mã dòng sản xuất
										 Materialcode NVARCHAR(50),        -- Mã vật liệu
										 OrderQty INT,                     -- Số lượng đơn hàng
										 OrderStatus NVARCHAR(20),         -- Trạng thái đơn hàng
										 OrderDate DATETIME,               -- Ngày tạo đơn hàng
										 IsFinish BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(50),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(50)
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
					Linecode = SourceTable.Linecode,
					Materialcode = SourceTable.Materialcode,
					OrderQty = SourceTable.OrderQty,
					OrderStatus = SourceTable.OrderStatus,
					OrderDate = SourceTable.OrderDate,
					IsFinish = SourceTable.IsFinish,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialOrderNo,
						CompanyCode,
						WorkCenterCode,
						Linecode ,
						Materialcode ,
						OrderQty,
						OrderStatus ,
						OrderDate ,
						IsFinish,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialOrderNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.Linecode,
							SourceTable.Materialcode,
							SourceTable.OrderQty,
							SourceTable.OrderStatus,
							SourceTable.OrderDate,
							SourceTable.IsFinish,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_DayMaterialOrder  AS TargetTable
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
							XMLData.Linecode,
							XMLData.Materialcode,
							XMLData.OrderQty,
							XMLData.OrderStatus,
							XMLData.OrderDate,
							XMLData.IsFinish,
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
										 Linecode NVARCHAR(50),            -- Mã dòng sản xuất
										 Materialcode NVARCHAR(50),        -- Mã vật liệu
										 OrderQty INT,                     -- Số lượng đơn hàng
										 OrderStatus NVARCHAR(20),         -- Trạng thái đơn hàng
										 OrderDate DATETIME,               -- Ngày tạo đơn hàng
										 IsFinish BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(50),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(50)
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
					Linecode = SourceTable.Linecode,
					Materialcode = SourceTable.Materialcode,
					OrderQty = SourceTable.OrderQty,
					OrderStatus = SourceTable.OrderStatus,
					OrderDate = SourceTable.OrderDate,
					IsFinish = SourceTable.IsFinish,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						 MaterialOrderNo,
						CompanyCode,
						WorkCenterCode,
						Linecode ,
						Materialcode ,
						OrderQty,
						OrderStatus ,
						OrderDate ,
						IsFinish,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialOrderNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.Linecode,
							SourceTable.Materialcode,
							SourceTable.OrderQty,
							SourceTable.OrderStatus,
							SourceTable.OrderDate,
							SourceTable.IsFinish,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_DayMaterialOrder  AS TargetTable
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
							XMLData.Linecode,
							XMLData.Materialcode,
							XMLData.OrderQty,
							XMLData.OrderStatus,
							XMLData.OrderDate,
							XMLData.IsFinish,
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
										 Linecode NVARCHAR(50),            -- Mã dòng sản xuất
										 Materialcode NVARCHAR(50),        -- Mã vật liệu
										 OrderQty INT,                     -- Số lượng đơn hàng
										 OrderStatus NVARCHAR(20),         -- Trạng thái đơn hàng
										 OrderDate DATETIME,               -- Ngày tạo đơn hàng
										 IsFinish BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(50),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(50)
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
                        'INSERT' AS IUD_FLAG,
									XMLData.OldMaterialOrderNo,
									XMLData.MaterialOrderNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.Linecode,
									XMLData.Materialcode,
									XMLData.OrderQty,
									XMLData.OrderStatus,
									XMLData.OrderDate,
									XMLData.IsFinish,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
										 OldMaterialOrderNo VARCHAR(20),
										 MaterialOrderNo VARCHAR(20),
										 CompanyCode VARCHAR(20),
										 WorkCenterCode VARCHAR(20),
										 Linecode NVARCHAR(50),            -- Mã dòng sản xuất
										 Materialcode NVARCHAR(50),        -- Mã vật liệu
										 OrderQty INT,                     -- Số lượng đơn hàng
										 OrderStatus NVARCHAR(20),         -- Trạng thái đơn hàng
										 OrderDate DATETIME,               -- Ngày tạo đơn hàng
										 IsFinish BIT,
										 CreateDateTime  DATETIMEOFFSET,
										 CreateUserID VARCHAR(50),
										 ChangeDateTime  DATETIMEOFFSET,
										 ChangeUserID VARCHAR(50)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMaterialOrderNo IS NULL THEN XMLData.MaterialOrderNo
										ELSE XMLData.OldMaterialOrderNo
									END AS OldMaterialOrderNo,
									XMLData.MaterialOrderNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.Linecode,
									XMLData.Materialcode,
									XMLData.OrderQty,
									XMLData.OrderStatus,
									XMLData.OrderDate,
									XMLData.IsFinish,
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
										 Linecode NVARCHAR(50),            -- Mã dòng sản xuất
										 Materialcode NVARCHAR(50),        -- Mã vật liệu
										 OrderQty INT,                     -- Số lượng đơn hàng
										 OrderStatus NVARCHAR(20),         -- Trạng thái đơn hàng
										 OrderDate DATETIME,               -- Ngày tạo đơn hàng
										 IsFinish BIT,
										 CreateDateTime  DATETIMEOFFSET,
										 CreateUserID VARCHAR(50),
										 ChangeDateTime  DATETIMEOFFSET,
										 ChangeUserID VARCHAR(50)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMaterialOrderNo IS NULL THEN XMLData.MaterialOrderNo
										ELSE XMLData.OldMaterialOrderNo
									END AS OldMaterialOrderNo,
									XMLData.MaterialOrderNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.Linecode,
									XMLData.Materialcode,
									XMLData.OrderQty,
									XMLData.OrderStatus,
									XMLData.OrderDate,
									XMLData.IsFinish,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
										 OldMaterialOrderNo VARCHAR(20),
										 MaterialOrderNo VARCHAR(20),
										 CompanyCode VARCHAR(20),
										 WorkCenterCode VARCHAR(20),
										 Linecode NVARCHAR(50),            -- Mã dòng sản xuất
										 Materialcode NVARCHAR(50),        -- Mã vật liệu
										 OrderQty INT,                     -- Số lượng đơn hàng
										 OrderStatus NVARCHAR(20),         -- Trạng thái đơn hàng
										 OrderDate DATETIME,               -- Ngày tạo đơn hàng
										 IsFinish BIT,
										 CreateDateTime  DATETIMEOFFSET,
										 CreateUserID VARCHAR(50),
										 ChangeDateTime  DATETIMEOFFSET,
										 ChangeUserID VARCHAR(50)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialOrderNo,
								 @MaterialOrderNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @Linecode,
								 @Materialcode,
								 @OrderQty,
								 @OrderStatus,
								 @OrderDate,
								 @IsFinish,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_DayMaterialOrder  WHERE MaterialOrderNo = @MaterialOrderNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialOrderNo)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DayMaterialOrder', @MaterialOrderNo OUTPUT
                    END
                    
					---- 임시SEQUENCE TABLE 사용버젼 : MASTER 처리
					--INSERT INTO #SEQUENCE_TABLE
					--	(KeyValue, UID_KEY)
					--VALUES
					--	(@MaterialOrderNo, @OldMaterialOrderNo)
					--                      

                    INSERT INTO STB_DayMaterialOrder 
						(
						 MaterialOrderNo,
						CompanyCode,
						WorkCenterCode,
						Linecode ,
						Materialcode ,
						OrderQty,
						OrderStatus ,
						OrderDate ,
						IsFinish,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
						)
						VALUES
						(
						    
							@MaterialOrderNo,
							@CompanyCode,
							@WorkCenterCode,
							@Linecode,
							@Materialcode,
							@OrderQty,
							@OrderStatus,
							@OrderDate,
							@IsFinish,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					
					
					
					IF @OrderStatus <> 'REQUEST' BEGIN
						RAISERROR('CurrentOrderStatus  = %s', 16, 1, @OrderStatus)
					END
					
                    UPDATE STB_DayMaterialOrder
					SET
						    CompanyCode =   CASE
						                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						                ELSE CompanyCode
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						    Linecode =   CASE
						                WHEN @Linecode IS NOT NULL THEN @Linecode
						                ELSE Linecode
						            END,
						    Materialcode =   CASE
						                WHEN @Materialcode IS NOT NULL THEN @Materialcode
						                ELSE Materialcode
						            END,
						    OrderQty =   CASE
						                WHEN @OrderQty IS NOT NULL THEN @OrderQty
						                ELSE OrderQty
						            END,
						    OrderStatus =   CASE
						                WHEN @OrderStatus IS NOT NULL THEN @OrderStatus
						                ELSE OrderStatus
						            END,
						    OrderDate =   CASE
						                WHEN @OrderDate IS NOT NULL THEN @OrderDate
						                ELSE OrderDate
						            END,
						    IsFinish =   CASE
						                WHEN @IsFinish IS NOT NULL THEN @IsFinish
						                ELSE IsFinish
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
						    MaterialOrderNo = @OldMaterialOrderNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					
					IF @OrderStatus <> 'REQUEST' BEGIN
						RAISERROR('CurrentOrderStatus  = %s', 16, 1, @OrderStatus)
					END
					
                    DELETE FROM STB_DayMaterialOrder
						WHERE
						    MaterialOrderNo = @MaterialOrderNo
					
					--DELETE FROM STB_MaterialOrderItem
					--WHERE
					--		MaterialOrderNo = @MaterialOrderNo
							
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
