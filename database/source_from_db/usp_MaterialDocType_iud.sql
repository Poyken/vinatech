
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2018-08-25
-- Browsable : true
-- Group : 공통
-- Description:	수불유형 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialDocType_iud]
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
  DECLARE @OldMaterialDocTypeCode VARCHAR(20)
  DECLARE @MaterialDocTypeCode VARCHAR(20)
  DECLARE @MaterialDocType VARCHAR(10)
  DECLARE @MaterialDocTypeName NVARCHAR(50)
  DECLARE @MaterialDocTypeNameL NVARCHAR(50)
  DECLARE @MaterialDocTypeDesc NVARCHAR(200)
  DECLARE @MaterialDocTypeDescL NVARCHAR(200)
  DECLARE @MaterialDocTypeGroup NVARCHAR(50)
  DECLARE @IsProcessBom BIT
  DECLARE @IsProcessModelBom BIT
  DECLARE @IsAutoCreate BIT
  DECLARE @AutoCreateMoveType VARCHAR(20)
  DECLARE @IsDecSource BIT
  DECLARE @IsIncTarget BIT
  DECLARE @IsChangeStockAttribute BIT
  DECLARE @IsRequireQC BIT
  DECLARE @IsRequireApproval BIT
  DECLARE @IsProcessRefDoc BIT
  DECLARE @IsDisplay BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialDocType',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialDocType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialDocTypeCode IS NULL THEN MaterialDocTypeCode
							    ELSE OldMaterialDocTypeCode
							END AS OldMaterialDocTypeCode,
							MaterialDocTypeCode,
							MaterialDocType,
							MaterialDocTypeName,
							MaterialDocTypeNameL,
							MaterialDocTypeDesc,
							MaterialDocTypeDescL,
							MaterialDocTypeGroup,
							IsProcessBom,
							IsProcessModelBom,
							IsAutoCreate,
							AutoCreateMoveType,
							IsDecSource,
							IsIncTarget,
							IsChangeStockAttribute,
							IsRequireQC,
							IsRequireApproval,
							IsProcessRefDoc,
							IsDisplay,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialDocTypeCode VARCHAR(20),
										MaterialDocTypeCode VARCHAR(20),
										MaterialDocType VARCHAR(10),
										MaterialDocTypeName NVARCHAR(50),
										MaterialDocTypeNameL NVARCHAR(50),
										MaterialDocTypeDesc NVARCHAR(200),
										MaterialDocTypeDescL NVARCHAR(200),
										MaterialDocTypeGroup NVARCHAR(50),
										IsProcessBom BIT,
										IsProcessModelBom BIT,
										IsAutoCreate BIT,
										AutoCreateMoveType VARCHAR(20),
										IsDecSource BIT,
										IsIncTarget BIT,
										IsChangeStockAttribute BIT,
										IsRequireQC BIT,
										IsRequireApproval BIT,
										IsProcessRefDoc BIT,
										IsDisplay BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialDocTypeCode = SourceTable.MaterialDocTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialDocTypeCode = ISNULL(SourceTable.MaterialDocTypeCode,TargetTable.MaterialDocTypeCode),
					MaterialDocType = ISNULL(SourceTable.MaterialDocType,TargetTable.MaterialDocType),
					MaterialDocTypeName = ISNULL(SourceTable.MaterialDocTypeName,TargetTable.MaterialDocTypeName),
					MaterialDocTypeNameL = ISNULL(SourceTable.MaterialDocTypeNameL,TargetTable.MaterialDocTypeNameL),
					MaterialDocTypeDesc = ISNULL(SourceTable.MaterialDocTypeDesc,TargetTable.MaterialDocTypeDesc),
					MaterialDocTypeDescL = ISNULL(SourceTable.MaterialDocTypeDescL,TargetTable.MaterialDocTypeDescL),
					MaterialDocTypeGroup = ISNULL(SourceTable.MaterialDocTypeGroup,TargetTable.MaterialDocTypeGroup),
					IsProcessBom = ISNULL(SourceTable.IsProcessBom,TargetTable.IsProcessBom),
					IsProcessModelBom = ISNULL(SourceTable.IsProcessModelBom,TargetTable.IsProcessModelBom),
					IsAutoCreate = ISNULL(SourceTable.IsAutoCreate,TargetTable.IsAutoCreate),
					AutoCreateMoveType = ISNULL(SourceTable.AutoCreateMoveType,TargetTable.AutoCreateMoveType),
					IsDecSource = ISNULL(SourceTable.IsDecSource,TargetTable.IsDecSource),
					IsIncTarget = ISNULL(SourceTable.IsIncTarget,TargetTable.IsIncTarget),
					IsChangeStockAttribute = ISNULL(SourceTable.IsChangeStockAttribute,TargetTable.IsChangeStockAttribute),
					IsRequireQC = ISNULL(SourceTable.IsRequireQC,TargetTable.IsRequireQC),
					IsRequireApproval = ISNULL(SourceTable.IsRequireApproval,TargetTable.IsRequireApproval),
					IsProcessRefDoc = ISNULL(SourceTable.IsProcessRefDoc,TargetTable.IsProcessRefDoc),
					IsDisplay = ISNULL(SourceTable.IsDisplay,TargetTable.IsDisplay),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialDocTypeCode,
						MaterialDocType,
						MaterialDocTypeName,
						MaterialDocTypeNameL,
						MaterialDocTypeDesc,
						MaterialDocTypeDescL,
						MaterialDocTypeGroup,
						IsProcessBom,
						IsProcessModelBom,
						IsAutoCreate,
						AutoCreateMoveType,
						IsDecSource,
						IsIncTarget,
						IsChangeStockAttribute,
						IsRequireQC,
						IsRequireApproval,
						IsProcessRefDoc,
						IsDisplay,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialDocTypeCode,
							SourceTable.MaterialDocType,
							SourceTable.MaterialDocTypeName,
							SourceTable.MaterialDocTypeNameL,
							SourceTable.MaterialDocTypeDesc,
							SourceTable.MaterialDocTypeDescL,
							SourceTable.MaterialDocTypeGroup,
							SourceTable.IsProcessBom,
							SourceTable.IsProcessModelBom,
							SourceTable.IsAutoCreate,
							SourceTable.AutoCreateMoveType,
							SourceTable.IsDecSource,
							SourceTable.IsIncTarget,
							SourceTable.IsChangeStockAttribute,
							SourceTable.IsRequireQC,
							SourceTable.IsRequireApproval,
							SourceTable.IsProcessRefDoc,
							SourceTable.IsDisplay,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MaterialDocType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialDocTypeCode IS NULL THEN MaterialDocTypeCode
							    ELSE OldMaterialDocTypeCode
							END AS OldMaterialDocTypeCode,
							MaterialDocTypeCode,
							MaterialDocType,
							MaterialDocTypeName,
							MaterialDocTypeNameL,
							MaterialDocTypeDesc,
							MaterialDocTypeDescL,
							MaterialDocTypeGroup,
							IsProcessBom,
							IsProcessModelBom,
							IsAutoCreate,
							AutoCreateMoveType,
							IsDecSource,
							IsIncTarget,
							IsChangeStockAttribute,
							IsRequireQC,
							IsRequireApproval,
							IsProcessRefDoc,
							IsDisplay,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialDocTypeCode VARCHAR(20),
										MaterialDocTypeCode VARCHAR(20),
										MaterialDocType VARCHAR(10),
										MaterialDocTypeName NVARCHAR(50),
										MaterialDocTypeNameL NVARCHAR(50),
										MaterialDocTypeDesc NVARCHAR(200),
										MaterialDocTypeDescL NVARCHAR(200),
										MaterialDocTypeGroup NVARCHAR(50),
										IsProcessBom BIT,
										IsProcessModelBom BIT,
										IsAutoCreate BIT,
										AutoCreateMoveType VARCHAR(20),
										IsDecSource BIT,
										IsIncTarget BIT,
										IsChangeStockAttribute BIT,
										IsRequireQC BIT,
										IsRequireApproval BIT,
										IsProcessRefDoc BIT,
										IsDisplay BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialDocTypeCode = SourceTable.OldMaterialDocTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialDocTypeCode = ISNULL(SourceTable.MaterialDocTypeCode,TargetTable.MaterialDocTypeCode),
					MaterialDocType = ISNULL(SourceTable.MaterialDocType,TargetTable.MaterialDocType),
					MaterialDocTypeName = ISNULL(SourceTable.MaterialDocTypeName,TargetTable.MaterialDocTypeName),
					MaterialDocTypeNameL = ISNULL(SourceTable.MaterialDocTypeNameL,TargetTable.MaterialDocTypeNameL),
					MaterialDocTypeDesc = ISNULL(SourceTable.MaterialDocTypeDesc,TargetTable.MaterialDocTypeDesc),
					MaterialDocTypeDescL = ISNULL(SourceTable.MaterialDocTypeDescL,TargetTable.MaterialDocTypeDescL),
					MaterialDocTypeGroup = ISNULL(SourceTable.MaterialDocTypeGroup,TargetTable.MaterialDocTypeGroup),
					IsProcessBom = ISNULL(SourceTable.IsProcessBom,TargetTable.IsProcessBom),
					IsProcessModelBom = ISNULL(SourceTable.IsProcessModelBom,TargetTable.IsProcessModelBom),
					IsAutoCreate = ISNULL(SourceTable.IsAutoCreate,TargetTable.IsAutoCreate),
					AutoCreateMoveType = ISNULL(SourceTable.AutoCreateMoveType,TargetTable.AutoCreateMoveType),
					IsDecSource = ISNULL(SourceTable.IsDecSource,TargetTable.IsDecSource),
					IsIncTarget = ISNULL(SourceTable.IsIncTarget,TargetTable.IsIncTarget),
					IsChangeStockAttribute = ISNULL(SourceTable.IsChangeStockAttribute,TargetTable.IsChangeStockAttribute),
					IsRequireQC = ISNULL(SourceTable.IsRequireQC,TargetTable.IsRequireQC),
					IsRequireApproval = ISNULL(SourceTable.IsRequireApproval,TargetTable.IsRequireApproval),
					IsProcessRefDoc = ISNULL(SourceTable.IsProcessRefDoc,TargetTable.IsProcessRefDoc),
					IsDisplay = ISNULL(SourceTable.IsDisplay,TargetTable.IsDisplay),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialDocTypeCode,
						MaterialDocType,
						MaterialDocTypeName,
						MaterialDocTypeNameL,
						MaterialDocTypeDesc,
						MaterialDocTypeDescL,
						MaterialDocTypeGroup,
						IsProcessBom,
						IsProcessModelBom,
						IsAutoCreate,
						AutoCreateMoveType,
						IsDecSource,
						IsIncTarget,
						IsChangeStockAttribute,
						IsRequireQC,
						IsRequireApproval,
						IsProcessRefDoc,
						IsDisplay,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialDocTypeCode,
							SourceTable.MaterialDocType,
							SourceTable.MaterialDocTypeName,
							SourceTable.MaterialDocTypeNameL,
							SourceTable.MaterialDocTypeDesc,
							SourceTable.MaterialDocTypeDescL,
							SourceTable.MaterialDocTypeGroup,
							SourceTable.IsProcessBom,
							SourceTable.IsProcessModelBom,
							SourceTable.IsAutoCreate,
							SourceTable.AutoCreateMoveType,
							SourceTable.IsDecSource,
							SourceTable.IsIncTarget,
							SourceTable.IsChangeStockAttribute,
							SourceTable.IsRequireQC,
							SourceTable.IsRequireApproval,
							SourceTable.IsProcessRefDoc,
							SourceTable.IsDisplay,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MaterialDocType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialDocTypeCode IS NULL THEN MaterialDocTypeCode
							    ELSE OldMaterialDocTypeCode
							END AS OldMaterialDocTypeCode,
							MaterialDocTypeCode,
							MaterialDocType,
							MaterialDocTypeName,
							MaterialDocTypeNameL,
							MaterialDocTypeDesc,
							MaterialDocTypeDescL,
							MaterialDocTypeGroup,
							IsProcessBom,
							IsProcessModelBom,
							IsAutoCreate,
							AutoCreateMoveType,
							IsDecSource,
							IsIncTarget,
							IsChangeStockAttribute,
							IsRequireQC,
							IsRequireApproval,
							IsProcessRefDoc,
							IsDisplay,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialDocTypeCode VARCHAR(20),
										MaterialDocTypeCode VARCHAR(20),
										MaterialDocType VARCHAR(10),
										MaterialDocTypeName NVARCHAR(50),
										MaterialDocTypeNameL NVARCHAR(50),
										MaterialDocTypeDesc NVARCHAR(200),
										MaterialDocTypeDescL NVARCHAR(200),
										MaterialDocTypeGroup NVARCHAR(50),
										IsProcessBom BIT,
										IsProcessModelBom BIT,
										IsAutoCreate BIT,
										AutoCreateMoveType VARCHAR(20),
										IsDecSource BIT,
										IsIncTarget BIT,
										IsChangeStockAttribute BIT,
										IsRequireQC BIT,
										IsRequireApproval BIT,
										IsProcessRefDoc BIT,
										IsDisplay BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialDocTypeCode = SourceTable.MaterialDocTypeCode
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
									OldMaterialDocTypeCode,
									MaterialDocTypeCode,
									MaterialDocType,
									MaterialDocTypeName,
									MaterialDocTypeNameL,
									MaterialDocTypeDesc,
									MaterialDocTypeDescL,
									MaterialDocTypeGroup,
									IsProcessBom,
									IsProcessModelBom,
									IsAutoCreate,
									AutoCreateMoveType,
									IsDecSource,
									IsIncTarget,
									IsChangeStockAttribute,
									IsRequireQC,
									IsRequireApproval,
									IsProcessRefDoc,
									IsDisplay,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialDocTypeCode VARCHAR(20),
											 MaterialDocTypeCode VARCHAR(20),
											 MaterialDocType VARCHAR(10),
											 MaterialDocTypeName NVARCHAR(50),
											 MaterialDocTypeNameL NVARCHAR(50),
											 MaterialDocTypeDesc NVARCHAR(200),
											 MaterialDocTypeDescL NVARCHAR(200),
											 MaterialDocTypeGroup NVARCHAR(50),
											 IsProcessBom BIT,
											 IsProcessModelBom BIT,
											 IsAutoCreate BIT,
											 AutoCreateMoveType VARCHAR(20),
											 IsDecSource BIT,
											 IsIncTarget BIT,
											 IsChangeStockAttribute BIT,
											 IsRequireQC BIT,
											 IsRequireApproval BIT,
											 IsProcessRefDoc BIT,
											 IsDisplay BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialDocTypeCode IS NULL THEN MaterialDocTypeCode
										ELSE OldMaterialDocTypeCode
									END AS OldMaterialDocTypeCode,
									MaterialDocTypeCode,
									MaterialDocType,
									MaterialDocTypeName,
									MaterialDocTypeNameL,
									MaterialDocTypeDesc,
									MaterialDocTypeDescL,
									MaterialDocTypeGroup,
									IsProcessBom,
									IsProcessModelBom,
									IsAutoCreate,
									AutoCreateMoveType,
									IsDecSource,
									IsIncTarget,
									IsChangeStockAttribute,
									IsRequireQC,
									IsRequireApproval,
									IsProcessRefDoc,
									IsDisplay,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialDocTypeCode VARCHAR(20),
											 MaterialDocTypeCode VARCHAR(20),
											 MaterialDocType VARCHAR(10),
											 MaterialDocTypeName NVARCHAR(50),
											 MaterialDocTypeNameL NVARCHAR(50),
											 MaterialDocTypeDesc NVARCHAR(200),
											 MaterialDocTypeDescL NVARCHAR(200),
											 MaterialDocTypeGroup NVARCHAR(50),
											 IsProcessBom BIT,
											 IsProcessModelBom BIT,
											 IsAutoCreate BIT,
											 AutoCreateMoveType VARCHAR(20),
											 IsDecSource BIT,
											 IsIncTarget BIT,
											 IsChangeStockAttribute BIT,
											 IsRequireQC BIT,
											 IsRequireApproval BIT,
											 IsProcessRefDoc BIT,
											 IsDisplay BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialDocTypeCode IS NULL THEN MaterialDocTypeCode
										ELSE OldMaterialDocTypeCode
									END AS OldMaterialDocTypeCode,
									MaterialDocTypeCode,
									MaterialDocType,
									MaterialDocTypeName,
									MaterialDocTypeNameL,
									MaterialDocTypeDesc,
									MaterialDocTypeDescL,
									MaterialDocTypeGroup,
									IsProcessBom,
									IsProcessModelBom,
									IsAutoCreate,
									AutoCreateMoveType,
									IsDecSource,
									IsIncTarget,
									IsChangeStockAttribute,
									IsRequireQC,
									IsRequireApproval,
									IsProcessRefDoc,
									IsDisplay,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialDocTypeCode VARCHAR(20),
											 MaterialDocTypeCode VARCHAR(20),
											 MaterialDocType VARCHAR(10),
											 MaterialDocTypeName NVARCHAR(50),
											 MaterialDocTypeNameL NVARCHAR(50),
											 MaterialDocTypeDesc NVARCHAR(200),
											 MaterialDocTypeDescL NVARCHAR(200),
											 MaterialDocTypeGroup NVARCHAR(50),
											 IsProcessBom BIT,
											 IsProcessModelBom BIT,
											 IsAutoCreate BIT,
											 AutoCreateMoveType VARCHAR(20),
											 IsDecSource BIT,
											 IsIncTarget BIT,
											 IsChangeStockAttribute BIT,
											 IsRequireQC BIT,
											 IsRequireApproval BIT,
											 IsProcessRefDoc BIT,
											 IsDisplay BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialDocTypeCode,
								 @MaterialDocTypeCode,
								 @MaterialDocType,
								 @MaterialDocTypeName,
								 @MaterialDocTypeNameL,
								 @MaterialDocTypeDesc,
								 @MaterialDocTypeDescL,
								 @MaterialDocTypeGroup,
								 @IsProcessBom,
								 @IsProcessModelBom,
								 @IsAutoCreate,
								 @AutoCreateMoveType,
								 @IsDecSource,
								 @IsIncTarget,
								 @IsChangeStockAttribute,
								 @IsRequireQC,
								 @IsRequireApproval,
								 @IsProcessRefDoc,
								 @IsDisplay,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialDocType WHERE MaterialDocTypeCode = @MaterialDocTypeCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialDocTypeCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocType',@MaterialDocTypeCode OUTPUT
                    END

                    INSERT INTO STB_MaterialDocType
						(
						    MaterialDocTypeCode,
						    MaterialDocType,
						    MaterialDocTypeName,
						    MaterialDocTypeNameL,
						    MaterialDocTypeDesc,
						    MaterialDocTypeDescL,
						    MaterialDocTypeGroup,
						    IsProcessBom,
						    IsProcessModelBom,
						    IsAutoCreate,
						    AutoCreateMoveType,
						    IsDecSource,
						    IsIncTarget,
						    IsChangeStockAttribute,
						    IsRequireQC,
						    IsRequireApproval,
						    IsProcessRefDoc,
						    IsDisplay,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialDocTypeCode,
						    @MaterialDocType,
						    @MaterialDocTypeName,
						    @MaterialDocTypeNameL,
						    @MaterialDocTypeDesc,
						    @MaterialDocTypeDescL,
						    @MaterialDocTypeGroup,
						    @IsProcessBom,
						    @IsProcessModelBom,
						    @IsAutoCreate,
						    @AutoCreateMoveType,
						    @IsDecSource,
						    @IsIncTarget,
						    @IsChangeStockAttribute,
						    @IsRequireQC,
						    @IsRequireApproval,
						    @IsProcessRefDoc,
						    @IsDisplay,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MaterialDocType
						SET
						    MaterialDocTypeCode =   ISNULL(@MaterialDocTypeCode,MaterialDocTypeCode),
						    MaterialDocType =   ISNULL(@MaterialDocType,MaterialDocType),
						    MaterialDocTypeName =   ISNULL(@MaterialDocTypeName,MaterialDocTypeName),
						    MaterialDocTypeNameL =   ISNULL(@MaterialDocTypeNameL,MaterialDocTypeNameL),
						    MaterialDocTypeDesc =   ISNULL(@MaterialDocTypeDesc,MaterialDocTypeDesc),
						    MaterialDocTypeDescL =   ISNULL(@MaterialDocTypeDescL,MaterialDocTypeDescL),
						    MaterialDocTypeGroup =   ISNULL(@MaterialDocTypeGroup,MaterialDocTypeGroup),
						    IsProcessBom =   ISNULL(@IsProcessBom,IsProcessBom),
						    IsProcessModelBom =   ISNULL(@IsProcessModelBom,IsProcessModelBom),
						    IsAutoCreate =   ISNULL(@IsAutoCreate,IsAutoCreate),
						    AutoCreateMoveType =   ISNULL(@AutoCreateMoveType,AutoCreateMoveType),
						    IsDecSource =   ISNULL(@IsDecSource,IsDecSource),
						    IsIncTarget =   ISNULL(@IsIncTarget,IsIncTarget),
						    IsChangeStockAttribute =   ISNULL(@IsChangeStockAttribute,IsChangeStockAttribute),
						    IsRequireQC =   ISNULL(@IsRequireQC,IsRequireQC),
						    IsRequireApproval =   ISNULL(@IsRequireApproval,IsRequireApproval),
						    IsProcessRefDoc =   ISNULL(@IsProcessRefDoc,IsProcessRefDoc),
						    IsDisplay =   ISNULL(@IsDisplay,IsDisplay),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialDocTypeCode = @OldMaterialDocTypeCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialDocType
						WHERE
						    MaterialDocTypeCode = @OldMaterialDocTypeCode
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
