-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 자재관리
-- Description:	자재창고로케이션정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialLocation_iud]
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
  DECLARE @OldMaterialLocationCode VARCHAR(20)
  DECLARE @MaterialLocationCode VARCHAR(20)
  DECLARE @MaterialWarehouseCode VARCHAR(20)
  DECLARE @MaterialLocationName NVARCHAR(50)
  DECLARE @MaterialLocationNameL NVARCHAR(50)
  DECLARE @MLExtText01 NVARCHAR(MAX)
  DECLARE @MLExtText02 NVARCHAR(MAX)
  DECLARE @MLExtText03 NVARCHAR(MAX)
  DECLARE @MLExtText04 NVARCHAR(MAX)
  DECLARE @MLExtText05 NVARCHAR(MAX)
  DECLARE @IsUseLotID BIT
  DECLARE @IsCanPicking BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  
  DECLARE @UID_KEY VARCHAR(50)  


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialLocation',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialLocation AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialLocationCode IS NULL THEN XMLData.MaterialLocationCode
							    ELSE XMLData.OldMaterialLocationCode
							END AS OldMaterialLocationCode,
							XMLData.MaterialLocationCode,
							XMLData.MaterialWarehouseCode,
							XMLData.MaterialLocationName,
							XMLData.MaterialLocationNameL,
							XMLData.MLExtText01,
							XMLData.MLExtText02,
							XMLData.MLExtText03,
							XMLData.MLExtText04,
							XMLData.MLExtText05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialLocationCode VARCHAR(20),
										MaterialLocationCode VARCHAR(20),
										MaterialWarehouseCode VARCHAR(20),
										MaterialLocationName NVARCHAR(50),
										MaterialLocationNameL NVARCHAR(50),
										MLExtText01 NVARCHAR(MAX),
										MLExtText02 NVARCHAR(MAX),
										MLExtText03 NVARCHAR(MAX),
										MLExtText04 NVARCHAR(MAX),
										MLExtText05 NVARCHAR(MAX),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialLocationCode = SourceTable.MaterialLocationCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialLocationCode = SourceTable.MaterialLocationCode,
					MaterialWarehouseCode = SourceTable.MaterialWarehouseCode,
					MaterialLocationName = SourceTable.MaterialLocationName,
					MaterialLocationNameL = SourceTable.MaterialLocationNameL,
					MLExtText01 = SourceTable.MLExtText01,
					MLExtText02 = SourceTable.MLExtText02,
					MLExtText03 = SourceTable.MLExtText03,
					MLExtText04 = SourceTable.MLExtText04,
					MLExtText05 = SourceTable.MLExtText05,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialLocationCode,
						MaterialWarehouseCode,
						MaterialLocationName,
						MaterialLocationNameL,
						MLExtText01,
						MLExtText02,
						MLExtText03,
						MLExtText04,
						MLExtText05,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialLocationCode,
							SourceTable.MaterialWarehouseCode,
							SourceTable.MaterialLocationName,
							SourceTable.MaterialLocationNameL,
							SourceTable.MLExtText01,
							SourceTable.MLExtText02,
							SourceTable.MLExtText03,
							SourceTable.MLExtText04,
							SourceTable.MLExtText05,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MaterialLocation AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialLocationCode IS NULL THEN XMLData.MaterialLocationCode
							    ELSE XMLData.OldMaterialLocationCode
							END AS OldMaterialLocationCode,
							XMLData.MaterialLocationCode,
							XMLData.MaterialWarehouseCode,
							XMLData.MaterialLocationName,
							XMLData.MaterialLocationNameL,
							XMLData.MLExtText01,
							XMLData.MLExtText02,
							XMLData.MLExtText03,
							XMLData.MLExtText04,
							XMLData.MLExtText05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialLocationCode VARCHAR(20),
										MaterialLocationCode VARCHAR(20),
										MaterialWarehouseCode VARCHAR(20),
										MaterialLocationName NVARCHAR(50),
										MaterialLocationNameL NVARCHAR(50),
										MLExtText01 NVARCHAR(MAX),
										MLExtText02 NVARCHAR(MAX),
										MLExtText03 NVARCHAR(MAX),
										MLExtText04 NVARCHAR(MAX),
										MLExtText05 NVARCHAR(MAX),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialLocationCode = SourceTable.OldMaterialLocationCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialLocationCode = SourceTable.MaterialLocationCode,
					MaterialWarehouseCode = SourceTable.MaterialWarehouseCode,
					MaterialLocationName = SourceTable.MaterialLocationName,
					MaterialLocationNameL = SourceTable.MaterialLocationNameL,
					MLExtText01 = SourceTable.MLExtText01,
					MLExtText02 = SourceTable.MLExtText02,
					MLExtText03 = SourceTable.MLExtText03,
					MLExtText04 = SourceTable.MLExtText04,
					MLExtText05 = SourceTable.MLExtText05,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialLocationCode,
						MaterialWarehouseCode,
						MaterialLocationName,
						MaterialLocationNameL,
						MLExtText01,
						MLExtText02,
						MLExtText03,
						MLExtText04,
						MLExtText05,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialLocationCode,
							SourceTable.MaterialWarehouseCode,
							SourceTable.MaterialLocationName,
							SourceTable.MaterialLocationNameL,
							SourceTable.MLExtText01,
							SourceTable.MLExtText02,
							SourceTable.MLExtText03,
							SourceTable.MLExtText04,
							SourceTable.MLExtText05,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MaterialLocation AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialLocationCode IS NULL THEN XMLData.MaterialLocationCode
							    ELSE XMLData.OldMaterialLocationCode
							END AS OldMaterialLocationCode,
							XMLData.MaterialLocationCode,
							XMLData.MaterialWarehouseCode,
							XMLData.MaterialLocationName,
							XMLData.MaterialLocationNameL,
							XMLData.MLExtText01,
							XMLData.MLExtText02,
							XMLData.MLExtText03,
							XMLData.MLExtText04,
							XMLData.MLExtText05,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialLocationCode VARCHAR(20),
										MaterialLocationCode VARCHAR(20),
										MaterialWarehouseCode VARCHAR(20),
										MaterialLocationName NVARCHAR(50),
										MaterialLocationNameL NVARCHAR(50),
										MLExtText01 NVARCHAR(MAX),
										MLExtText02 NVARCHAR(MAX),
										MLExtText03 NVARCHAR(MAX),
										MLExtText04 NVARCHAR(MAX),
										MLExtText05 NVARCHAR(MAX),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialLocationCode = SourceTable.MaterialLocationCode
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
									XMLData.OldMaterialLocationCode,
									XMLData.MaterialLocationCode,
									XMLData.MaterialWarehouseCode,
									XMLData.MaterialLocationName,
									XMLData.MaterialLocationNameL,
									XMLData.MLExtText01,
									XMLData.MLExtText02,
									XMLData.MLExtText03,
									XMLData.MLExtText04,
									XMLData.MLExtText05,
									XMLData.IsUseLotID,
									XMLData.IsCanPicking,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialLocationCode VARCHAR(20),
											 MaterialLocationCode VARCHAR(20),
											 MaterialWarehouseCode VARCHAR(20),
											 MaterialLocationName NVARCHAR(50),
											 MaterialLocationNameL NVARCHAR(50),
											 MLExtText01 NVARCHAR(MAX),
											 MLExtText02 NVARCHAR(MAX),
											 MLExtText03 NVARCHAR(MAX),
											 MLExtText04 NVARCHAR(MAX),
											 MLExtText05 NVARCHAR(MAX),
											 IsUseLotID BIT,
											 IsCanPicking BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMaterialLocationCode IS NULL THEN XMLData.MaterialLocationCode
										ELSE XMLData.OldMaterialLocationCode
									END AS OldMaterialLocationCode,
									XMLData.MaterialLocationCode,
									XMLData.MaterialWarehouseCode,
									XMLData.MaterialLocationName,
									XMLData.MaterialLocationNameL,
									XMLData.MLExtText01,
									XMLData.MLExtText02,
									XMLData.MLExtText03,
									XMLData.MLExtText04,
									XMLData.MLExtText05,
									XMLData.IsUseLotID,
									XMLData.IsCanPicking,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialLocationCode VARCHAR(20),
											 MaterialLocationCode VARCHAR(20),
											 MaterialWarehouseCode VARCHAR(20),
											 MaterialLocationName NVARCHAR(50),
											 MaterialLocationNameL NVARCHAR(50),
											 MLExtText01 NVARCHAR(MAX),
											 MLExtText02 NVARCHAR(MAX),
											 MLExtText03 NVARCHAR(MAX),
											 MLExtText04 NVARCHAR(MAX),
											 MLExtText05 NVARCHAR(MAX),
											 IsUseLotID BIT,
											 IsCanPicking BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMaterialLocationCode IS NULL THEN XMLData.MaterialLocationCode
										ELSE XMLData.OldMaterialLocationCode
									END AS OldMaterialLocationCode,
									XMLData.MaterialLocationCode,
									XMLData.MaterialWarehouseCode,
									XMLData.MaterialLocationName,
									XMLData.MaterialLocationNameL,
									XMLData.MLExtText01,
									XMLData.MLExtText02,
									XMLData.MLExtText03,
									XMLData.MLExtText04,
									XMLData.MLExtText05,
									XMLData.IsUseLotID,
									XMLData.IsCanPicking,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialLocationCode VARCHAR(20),
											 MaterialLocationCode VARCHAR(20),
											 MaterialWarehouseCode VARCHAR(20),
											 MaterialLocationName NVARCHAR(50),
											 MaterialLocationNameL NVARCHAR(50),
											 MLExtText01 NVARCHAR(MAX),
											 MLExtText02 NVARCHAR(MAX),
											 MLExtText03 NVARCHAR(MAX),
											 MLExtText04 NVARCHAR(MAX),
											 MLExtText05 NVARCHAR(MAX),
											 IsUseLotID BIT,
											 IsCanPicking BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialLocationCode,
								 @MaterialLocationCode,
								 @MaterialWarehouseCode,
								 @MaterialLocationName,
								 @MaterialLocationNameL,
								 @MLExtText01,
								 @MLExtText02,
								 @MLExtText03,
								 @MLExtText04,
								 @MLExtText05,
								 @IsUseLotID,
								 @IsCanPicking,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialLocation WHERE MaterialLocationCode = @MaterialLocationCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialLocationCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialLocation', @MaterialLocationCode OUTPUT
                    END
                    
					-- 임시SEQUENCE TABLE 사용버젼 : DETAIL 사용
					SET @UID_KEY = @MaterialWarehouseCode

					SET @MaterialWarehouseCode = NULL
										
					SELECT 
						@MaterialWarehouseCode = KeyValue
					FROM 
						#SEQUENCE_TABLE
					WHERE
						UID_KEY = @UID_KEY
										
					IF @MaterialWarehouseCode IS NULL
					BEGIN
						SET @MaterialWarehouseCode = @UID_KEY
					END
					--                    

                    INSERT INTO STB_MaterialLocation
						(
						    MaterialLocationCode,
						    MaterialWarehouseCode,
						    MaterialLocationName,
						    MaterialLocationNameL,
						    MLExtText01,
						    MLExtText02,
						    MLExtText03,
						    MLExtText04,
						    MLExtText05,
							IsUseLotID,
							IsCanPicking,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialLocationCode,
						    @MaterialWarehouseCode,
						    @MaterialLocationName,
						    @MaterialLocationNameL,
						    ISNULL(@MLExtText01,''),
						    @MLExtText02,
						    @MLExtText03,
						    @MLExtText04,
						    @MLExtText05,
							@IsUseLotID,
							@IsCanPicking,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MaterialLocation
						SET
						    MaterialLocationCode =   CASE
						                WHEN @MaterialLocationCode IS NOT NULL THEN @MaterialLocationCode
						                ELSE MaterialLocationCode
						            END,
						    MaterialWarehouseCode =   CASE
						                WHEN @MaterialWarehouseCode IS NOT NULL THEN @MaterialWarehouseCode
						                ELSE MaterialWarehouseCode
						            END,
						    MaterialLocationName =   CASE
						                WHEN @MaterialLocationName IS NOT NULL THEN @MaterialLocationName
						                ELSE MaterialLocationName
						            END,
						    MaterialLocationNameL =   CASE
						                WHEN @MaterialLocationNameL IS NOT NULL THEN @MaterialLocationNameL
						                ELSE MaterialLocationNameL
						            END,
						    MLExtText01 =   CASE
						                WHEN @MLExtText01 IS NOT NULL THEN @MLExtText01
						                ELSE MLExtText01
						            END,
						    MLExtText02 =   CASE
						                WHEN @MLExtText02 IS NOT NULL THEN @MLExtText02
						                ELSE MLExtText02
						            END,
						    MLExtText03 =   CASE
						                WHEN @MLExtText03 IS NOT NULL THEN @MLExtText03
						                ELSE MLExtText03
						            END,
						    MLExtText04 =   CASE
						                WHEN @MLExtText04 IS NOT NULL THEN @MLExtText04
						                ELSE MLExtText04
						            END,
						    MLExtText05 =   CASE
						                WHEN @MLExtText05 IS NOT NULL THEN @MLExtText05
						                ELSE MLExtText05
						            END,
						    IsUseLotID =   CASE
						                WHEN @IsUseLotID IS NOT NULL THEN @IsUseLotID
						                ELSE IsUseLotID
						            END,
							IsCanPicking = CASE
										WHEN @IsCanPicking IS NOT NULL THEN @IsCanPicking
										ELSE IsCanPicking
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
						    MaterialLocationCode = @OldMaterialLocationCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialLocation
						WHERE
						    MaterialLocationCode = @MaterialLocationCode
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

