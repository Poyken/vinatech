-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-17
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트창고정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SparePartWarehouseInfo_iud]
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
  DECLARE @OldSPWarehouseCode VARCHAR(20)
  DECLARE @SPWarehouseCode VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @SPWarehouseName NVARCHAR(100)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SparePartWarehouseInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_SparePartWarehouseInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldSPWarehouseCode IS NULL THEN XMLData.SPWarehouseCode
							    ELSE XMLData.OldSPWarehouseCode
							END AS OldSPWarehouseCode,
							XMLData.SPWarehouseCode,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.SPWarehouseName,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldSPWarehouseCode VARCHAR(20),
										SPWarehouseCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										SPWarehouseName NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.SPWarehouseCode = SourceTable.SPWarehouseCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					SPWarehouseCode = SourceTable.SPWarehouseCode,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					SPWarehouseName = SourceTable.SPWarehouseName,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						SPWarehouseCode,
						CompanyCode,
						WorkCenterCode,
						SPWarehouseName,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.SPWarehouseCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.SPWarehouseName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_SparePartWarehouseInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldSPWarehouseCode IS NULL THEN XMLData.SPWarehouseCode
							    ELSE XMLData.OldSPWarehouseCode
							END AS OldSPWarehouseCode,
							XMLData.SPWarehouseCode,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.SPWarehouseName,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldSPWarehouseCode VARCHAR(20),
										SPWarehouseCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										SPWarehouseName NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.SPWarehouseCode = SourceTable.OldSPWarehouseCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					SPWarehouseCode = SourceTable.SPWarehouseCode,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					SPWarehouseName = SourceTable.SPWarehouseName,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						SPWarehouseCode,
						CompanyCode,
						WorkCenterCode,
						SPWarehouseName,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.SPWarehouseCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.SPWarehouseName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_SparePartWarehouseInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldSPWarehouseCode IS NULL THEN XMLData.SPWarehouseCode
							    ELSE XMLData.OldSPWarehouseCode
							END AS OldSPWarehouseCode,
							XMLData.SPWarehouseCode,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.SPWarehouseName,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldSPWarehouseCode VARCHAR(20),
										SPWarehouseCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										SPWarehouseName NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.SPWarehouseCode = SourceTable.SPWarehouseCode
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
									XMLData.OldSPWarehouseCode,
									XMLData.SPWarehouseCode,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.SPWarehouseName,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldSPWarehouseCode VARCHAR(20),
											 SPWarehouseCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 SPWarehouseName NVARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldSPWarehouseCode IS NULL THEN XMLData.SPWarehouseCode
										ELSE XMLData.OldSPWarehouseCode
									END AS OldSPWarehouseCode,
									XMLData.SPWarehouseCode,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.SPWarehouseName,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldSPWarehouseCode VARCHAR(20),
											 SPWarehouseCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 SPWarehouseName NVARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldSPWarehouseCode IS NULL THEN XMLData.SPWarehouseCode
										ELSE XMLData.OldSPWarehouseCode
									END AS OldSPWarehouseCode,
									XMLData.SPWarehouseCode,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.SPWarehouseName,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldSPWarehouseCode VARCHAR(20),
											 SPWarehouseCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 SPWarehouseName NVARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldSPWarehouseCode,
								 @SPWarehouseCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @SPWarehouseName,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_SparePartWarehouseInfo WHERE SPWarehouseCode = @SPWarehouseCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @SPWarehouseCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_SparePartWarehouseInfo', @SPWarehouseCode OUTPUT
                    END

                    INSERT INTO STB_SparePartWarehouseInfo
						(
						    SPWarehouseCode,
						    CompanyCode,
						    WorkCenterCode,
						    SPWarehouseName,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @SPWarehouseCode,
						    @CompanyCode,
						    @WorkCenterCode,
						    @SPWarehouseName,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_SparePartWarehouseInfo
						SET
						    SPWarehouseCode =   CASE
						                WHEN @SPWarehouseCode IS NOT NULL THEN @SPWarehouseCode
						                ELSE SPWarehouseCode
						            END,
						    CompanyCode =   CASE
						                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						                ELSE CompanyCode
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						    SPWarehouseName =   CASE
						                WHEN @SPWarehouseName IS NOT NULL THEN @SPWarehouseName
						                ELSE SPWarehouseName
						            END,
						    IsUsed =   CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
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
						    SPWarehouseCode = @OldSPWarehouseCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_SparePartWarehouseInfo
						WHERE
						    SPWarehouseCode = @SPWarehouseCode
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

