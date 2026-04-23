-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-17
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트입출고유형정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SparePartIOTypeCode_iud]
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
  DECLARE @OldSparePartIOTypeCode VARCHAR(20)
  DECLARE @SparePartIOTypeCode VARCHAR(20)
  DECLARE @IOType VARCHAR(1)
  DECLARE @SparePartIOTypeName NVARCHAR(100)
  DECLARE @SparePartIOTypeDesc NVARCHAR(100)
  DECLARE @IsDefaultRepairGI BIT
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SparePartIOTypeCode',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_SparePartIOTypeCode AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldSparePartIOTypeCode IS NULL THEN XMLData.SparePartIOTypeCode
							    ELSE XMLData.OldSparePartIOTypeCode
							END AS OldSparePartIOTypeCode,
							XMLData.SparePartIOTypeCode,
							XMLData.IOType,
							XMLData.SparePartIOTypeName,
							XMLData.SparePartIOTypeDesc,
							XMLData.IsDefaultRepairGI,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldSparePartIOTypeCode VARCHAR(20),
										SparePartIOTypeCode VARCHAR(20),
										IOType VARCHAR(1),
										SparePartIOTypeName NVARCHAR(100),
										SparePartIOTypeDesc NVARCHAR(100),
										IsDefaultRepairGI BIT,
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.SparePartIOTypeCode = SourceTable.SparePartIOTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					SparePartIOTypeCode = SourceTable.SparePartIOTypeCode,
					IOType = SourceTable.IOType,
					SparePartIOTypeName = SourceTable.SparePartIOTypeName,
					SparePartIOTypeDesc = SourceTable.SparePartIOTypeDesc,
					IsDefaultRepairGI = SourceTable.IsDefaultRepairGI,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						SparePartIOTypeCode,
						IOType,
						SparePartIOTypeName,
						SparePartIOTypeDesc,
						IsDefaultRepairGI,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.SparePartIOTypeCode,
							SourceTable.IOType,
							SourceTable.SparePartIOTypeName,
							SourceTable.SparePartIOTypeDesc,
							SourceTable.IsDefaultRepairGI,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_SparePartIOTypeCode AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldSparePartIOTypeCode IS NULL THEN XMLData.SparePartIOTypeCode
							    ELSE XMLData.OldSparePartIOTypeCode
							END AS OldSparePartIOTypeCode,
							XMLData.SparePartIOTypeCode,
							XMLData.IOType,
							XMLData.SparePartIOTypeName,
							XMLData.SparePartIOTypeDesc,
							XMLData.IsDefaultRepairGI,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldSparePartIOTypeCode VARCHAR(20),
										SparePartIOTypeCode VARCHAR(20),
										IOType VARCHAR(1),
										SparePartIOTypeName NVARCHAR(100),
										SparePartIOTypeDesc NVARCHAR(100),
										IsDefaultRepairGI BIT,
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.SparePartIOTypeCode = SourceTable.OldSparePartIOTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					SparePartIOTypeCode = SourceTable.SparePartIOTypeCode,
					IOType = SourceTable.IOType,
					SparePartIOTypeName = SourceTable.SparePartIOTypeName,
					SparePartIOTypeDesc = SourceTable.SparePartIOTypeDesc,
					IsDefaultRepairGI = SourceTable.IsDefaultRepairGI,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						SparePartIOTypeCode,
						IOType,
						SparePartIOTypeName,
						SparePartIOTypeDesc,
						IsDefaultRepairGI,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.SparePartIOTypeCode,
							SourceTable.IOType,
							SourceTable.SparePartIOTypeName,
							SourceTable.SparePartIOTypeDesc,
							SourceTable.IsDefaultRepairGI,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_SparePartIOTypeCode AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldSparePartIOTypeCode IS NULL THEN XMLData.SparePartIOTypeCode
							    ELSE XMLData.OldSparePartIOTypeCode
							END AS OldSparePartIOTypeCode,
							XMLData.SparePartIOTypeCode,
							XMLData.IOType,
							XMLData.SparePartIOTypeName,
							XMLData.SparePartIOTypeDesc,
							XMLData.IsDefaultRepairGI,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldSparePartIOTypeCode VARCHAR(20),
										SparePartIOTypeCode VARCHAR(20),
										IOType VARCHAR(1),
										SparePartIOTypeName NVARCHAR(100),
										SparePartIOTypeDesc NVARCHAR(100),
										IsDefaultRepairGI BIT,
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.SparePartIOTypeCode = SourceTable.SparePartIOTypeCode
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
									XMLData.OldSparePartIOTypeCode,
									XMLData.SparePartIOTypeCode,
									XMLData.IOType,
									XMLData.SparePartIOTypeName,
									XMLData.SparePartIOTypeDesc,
									XMLData.IsDefaultRepairGI,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldSparePartIOTypeCode VARCHAR(20),
											 SparePartIOTypeCode VARCHAR(20),
											 IOType VARCHAR(1),
											 SparePartIOTypeName NVARCHAR(100),
											 SparePartIOTypeDesc NVARCHAR(100),
											 IsDefaultRepairGI BIT,
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
										WHEN XMLData.OldSparePartIOTypeCode IS NULL THEN XMLData.SparePartIOTypeCode
										ELSE XMLData.OldSparePartIOTypeCode
									END AS OldSparePartIOTypeCode,
									XMLData.SparePartIOTypeCode,
									XMLData.IOType,
									XMLData.SparePartIOTypeName,
									XMLData.SparePartIOTypeDesc,
									XMLData.IsDefaultRepairGI,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldSparePartIOTypeCode VARCHAR(20),
											 SparePartIOTypeCode VARCHAR(20),
											 IOType VARCHAR(1),
											 SparePartIOTypeName NVARCHAR(100),
											 SparePartIOTypeDesc NVARCHAR(100),
											 IsDefaultRepairGI BIT,
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
										WHEN XMLData.OldSparePartIOTypeCode IS NULL THEN XMLData.SparePartIOTypeCode
										ELSE XMLData.OldSparePartIOTypeCode
									END AS OldSparePartIOTypeCode,
									XMLData.SparePartIOTypeCode,
									XMLData.IOType,
									XMLData.SparePartIOTypeName,
									XMLData.SparePartIOTypeDesc,
									XMLData.IsDefaultRepairGI,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldSparePartIOTypeCode VARCHAR(20),
											 SparePartIOTypeCode VARCHAR(20),
											 IOType VARCHAR(1),
											 SparePartIOTypeName NVARCHAR(100),
											 SparePartIOTypeDesc NVARCHAR(100),
											 IsDefaultRepairGI BIT,
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
								 @OldSparePartIOTypeCode,
								 @SparePartIOTypeCode,
								 @IOType,
								 @SparePartIOTypeName,
								 @SparePartIOTypeDesc,
								 @IsDefaultRepairGI,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_SparePartIOTypeCode WHERE SparePartIOTypeCode = @SparePartIOTypeCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @SparePartIOTypeCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_SparePartIOTypeCode', @SparePartIOTypeCode OUTPUT
                    END

                    INSERT INTO STB_SparePartIOTypeCode
						(
						    SparePartIOTypeCode,
						    IOType,
						    SparePartIOTypeName,
						    SparePartIOTypeDesc,
						    IsDefaultRepairGI,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @SparePartIOTypeCode,
						    @IOType,
						    @SparePartIOTypeName,
						    @SparePartIOTypeDesc,
						    @IsDefaultRepairGI,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_SparePartIOTypeCode
						SET
						    SparePartIOTypeCode =   CASE
						                WHEN @SparePartIOTypeCode IS NOT NULL THEN @SparePartIOTypeCode
						                ELSE SparePartIOTypeCode
						            END,
						    IOType =   CASE
						                WHEN @IOType IS NOT NULL THEN @IOType
						                ELSE IOType
						            END,
						    SparePartIOTypeName =   CASE
						                WHEN @SparePartIOTypeName IS NOT NULL THEN @SparePartIOTypeName
						                ELSE SparePartIOTypeName
						            END,
						    SparePartIOTypeDesc =   CASE
						                WHEN @SparePartIOTypeDesc IS NOT NULL THEN @SparePartIOTypeDesc
						                ELSE SparePartIOTypeDesc
						            END,
						    IsDefaultRepairGI = CASE
									WHEN @IsDefaultRepairGI IS NOT NULL THEN @IsDefaultRepairGI
									ELSE IsDefaultRepairGI
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
						    SparePartIOTypeCode = @OldSparePartIOTypeCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_SparePartIOTypeCode
						WHERE
						    SparePartIOTypeCode = @SparePartIOTypeCode
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

