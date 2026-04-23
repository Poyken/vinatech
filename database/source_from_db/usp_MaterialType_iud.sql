
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2018-07-23
-- Browsable : true
-- Group : 공통
-- Description:	자재유형 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialType_iud]
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

    -- Declare Columns Variable
  DECLARE @OldMaterialTypeCode VARCHAR(20)
  DECLARE @MaterialTypeCode VARCHAR(20)
  DECLARE @BasicMaterialType VARCHAR(20)
  DECLARE @MaterialTypeName NVARCHAR(100)
  DECLARE @MaterialTypeNameL NVARCHAR(100)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialType',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialTypeCode IS NULL THEN MaterialTypeCode
							    ELSE OldMaterialTypeCode
							END AS OldMaterialTypeCode,
							MaterialTypeCode,
							BasicMaterialType,
							MaterialTypeName,
							MaterialTypeNameL,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialTypeCode VARCHAR(20),
										MaterialTypeCode VARCHAR(20),
										BasicMaterialType VARCHAR(20),
										MaterialTypeName NVARCHAR(100),
										MaterialTypeNameL NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialTypeCode = SourceTable.MaterialTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialTypeCode = ISNULL(SourceTable.MaterialTypeCode,TargetTable.MaterialTypeCode),
					BasicMaterialType = ISNULL(SourceTable.BasicMaterialType,TargetTable.BasicMaterialType),
					MaterialTypeName = ISNULL(SourceTable.MaterialTypeName,TargetTable.MaterialTypeName),
					MaterialTypeNameL = ISNULL(SourceTable.MaterialTypeNameL,TargetTable.MaterialTypeNameL),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialTypeCode,
						BasicMaterialType,
						MaterialTypeName,
						MaterialTypeNameL,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						ChangeUserID
					)
				VALUES
					(
							SourceTable.MaterialTypeCode,
							SourceTable.BasicMaterialType,
							SourceTable.MaterialTypeName,
							SourceTable.MaterialTypeNameL,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ChangeUserID
					);


			-- Process Update Table
            MERGE STB_MaterialType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialTypeCode IS NULL THEN MaterialTypeCode
							    ELSE OldMaterialTypeCode
							END AS OldMaterialTypeCode,
							MaterialTypeCode,
							BasicMaterialType,
							MaterialTypeName,
							MaterialTypeNameL,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialTypeCode VARCHAR(20),
										MaterialTypeCode VARCHAR(20),
										BasicMaterialType VARCHAR(20),
										MaterialTypeName NVARCHAR(100),
										MaterialTypeNameL NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialTypeCode = SourceTable.OldMaterialTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialTypeCode = ISNULL(SourceTable.MaterialTypeCode,TargetTable.MaterialTypeCode),
					BasicMaterialType = ISNULL(SourceTable.BasicMaterialType,TargetTable.BasicMaterialType),
					MaterialTypeName = ISNULL(SourceTable.MaterialTypeName,TargetTable.MaterialTypeName),
					MaterialTypeNameL = ISNULL(SourceTable.MaterialTypeNameL,TargetTable.MaterialTypeNameL),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialTypeCode,
						BasicMaterialType,
						MaterialTypeName,
						MaterialTypeNameL,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						ChangeUserID
					)
				VALUES
					(
							SourceTable.MaterialTypeCode,
							SourceTable.BasicMaterialType,
							SourceTable.MaterialTypeName,
							SourceTable.MaterialTypeNameL,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ChangeUserID
					);


			-- Process Delete Table
            MERGE STB_MaterialType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialTypeCode IS NULL THEN MaterialTypeCode
							    ELSE OldMaterialTypeCode
							END AS OldMaterialTypeCode,
							MaterialTypeCode,
							BasicMaterialType,
							MaterialTypeName,
							MaterialTypeNameL,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialTypeCode VARCHAR(20),
										MaterialTypeCode VARCHAR(20),
										BasicMaterialType VARCHAR(20),
										MaterialTypeName NVARCHAR(100),
										MaterialTypeNameL NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialTypeCode = SourceTable.MaterialTypeCode
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
									OldMaterialTypeCode,
									MaterialTypeCode,
									BasicMaterialType,
									MaterialTypeName,
									MaterialTypeNameL,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialTypeCode VARCHAR(20),
											 MaterialTypeCode VARCHAR(20),
											 BasicMaterialType VARCHAR(20),
											 MaterialTypeName NVARCHAR(100),
											 MaterialTypeNameL NVARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialTypeCode IS NULL THEN MaterialTypeCode
										ELSE OldMaterialTypeCode
									END AS OldMaterialTypeCode,
									MaterialTypeCode,
									BasicMaterialType,
									MaterialTypeName,
									MaterialTypeNameL,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialTypeCode VARCHAR(20),
											 MaterialTypeCode VARCHAR(20),
											 BasicMaterialType VARCHAR(20),
											 MaterialTypeName NVARCHAR(100),
											 MaterialTypeNameL NVARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialTypeCode IS NULL THEN MaterialTypeCode
										ELSE OldMaterialTypeCode
									END AS OldMaterialTypeCode,
									MaterialTypeCode,
									BasicMaterialType,
									MaterialTypeName,
									MaterialTypeNameL,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialTypeCode VARCHAR(20),
											 MaterialTypeCode VARCHAR(20),
											 BasicMaterialType VARCHAR(20),
											 MaterialTypeName NVARCHAR(100),
											 MaterialTypeNameL NVARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialTypeCode,
								 @MaterialTypeCode,
								 @BasicMaterialType,
								 @MaterialTypeName,
								 @MaterialTypeNameL,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialType WHERE MaterialTypeCode = @MaterialTypeCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialTypeCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialType',@MaterialTypeCode OUTPUT
                    END

                    INSERT INTO STB_MaterialType
						(
						    MaterialTypeCode,
						    BasicMaterialType,
						    MaterialTypeName,
						    MaterialTypeNameL,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialTypeCode,
						    @BasicMaterialType,
						    @MaterialTypeName,
						    @MaterialTypeNameL,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MaterialType
						SET
						    MaterialTypeCode =   ISNULL(@MaterialTypeCode,MaterialTypeCode),
						    BasicMaterialType =   ISNULL(@BasicMaterialType,BasicMaterialType),
						    MaterialTypeName =   ISNULL(@MaterialTypeName,MaterialTypeName),
						    MaterialTypeNameL =   ISNULL(@MaterialTypeNameL,MaterialTypeNameL),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID =   ISNULL(@ChangeUserID,ChangeUserID)
						WHERE
						    MaterialTypeCode = @OldMaterialTypeCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialType
						WHERE
						    MaterialTypeCode = @OldMaterialTypeCode
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
