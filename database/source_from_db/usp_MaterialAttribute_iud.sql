
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-31
-- Browsable : true
-- Group : 공통
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialAttribute_iud]
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
  DECLARE @OldMaterialCode VARCHAR(50)
  DECLARE @OldAttribType VARCHAR(1)
  DECLARE @OldStockAttrib VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @AttribType VARCHAR(1)
  DECLARE @StockAttrib VARCHAR(20)
  DECLARE @StockAttribDesc NVARCHAR(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTIme DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialAttribute',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialAttribute AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN OldAttribType IS NULL THEN AttribType
							    ELSE OldAttribType
							END AS OldAttribType,
							CASE
							    WHEN OldStockAttrib IS NULL THEN StockAttrib
							    ELSE OldStockAttrib
							END AS OldStockAttrib,
							MaterialCode,
							AttribType,
							StockAttrib,
							StockAttribDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							ChangeDateTIme,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldAttribType VARCHAR(1),
										OldStockAttrib VARCHAR(20),
										MaterialCode VARCHAR(50),
										AttribType VARCHAR(1),
										StockAttrib VARCHAR(20),
										StockAttribDesc NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTIme DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.AttribType = SourceTable.AttribType AND
					TargetTable.StockAttrib = SourceTable.StockAttrib
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					AttribType = ISNULL(SourceTable.AttribType,TargetTable.AttribType),
					StockAttrib = ISNULL(SourceTable.StockAttrib,TargetTable.StockAttrib),
					StockAttribDesc = ISNULL(SourceTable.StockAttribDesc,TargetTable.StockAttribDesc),
					ChangeDateTIme = ISNULL(SourceTable.ChangeDateTIme,TargetTable.ChangeDateTIme),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						AttribType,
						StockAttrib,
						StockAttribDesc,
						CreateDateTime,
						CreateUserID,
						ChangeDateTIme
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.AttribType,
							SourceTable.StockAttrib,
							SourceTable.StockAttribDesc,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ChangeDateTIme
					);


			-- Process Update Table
            MERGE STB_MaterialAttribute AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN OldAttribType IS NULL THEN AttribType
							    ELSE OldAttribType
							END AS OldAttribType,
							CASE
							    WHEN OldStockAttrib IS NULL THEN StockAttrib
							    ELSE OldStockAttrib
							END AS OldStockAttrib,
							MaterialCode,
							AttribType,
							StockAttrib,
							StockAttribDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							ChangeDateTIme,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldAttribType VARCHAR(1),
										OldStockAttrib VARCHAR(20),
										MaterialCode VARCHAR(50),
										AttribType VARCHAR(1),
										StockAttrib VARCHAR(20),
										StockAttribDesc NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTIme DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.OldMaterialCode AND
					TargetTable.AttribType = SourceTable.OldAttribType AND
					TargetTable.StockAttrib = SourceTable.OldStockAttrib
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					AttribType = ISNULL(SourceTable.AttribType,TargetTable.AttribType),
					StockAttrib = ISNULL(SourceTable.StockAttrib,TargetTable.StockAttrib),
					StockAttribDesc = ISNULL(SourceTable.StockAttribDesc,TargetTable.StockAttribDesc),
					ChangeDateTIme = ISNULL(SourceTable.ChangeDateTIme,TargetTable.ChangeDateTIme),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						AttribType,
						StockAttrib,
						StockAttribDesc,
						CreateDateTime,
						CreateUserID,
						ChangeDateTIme
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.AttribType,
							SourceTable.StockAttrib,
							SourceTable.StockAttribDesc,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ChangeDateTIme
					);


			-- Process Delete Table
            MERGE STB_MaterialAttribute AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN OldAttribType IS NULL THEN AttribType
							    ELSE OldAttribType
							END AS OldAttribType,
							CASE
							    WHEN OldStockAttrib IS NULL THEN StockAttrib
							    ELSE OldStockAttrib
							END AS OldStockAttrib,
							MaterialCode,
							AttribType,
							StockAttrib,
							StockAttribDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							ChangeDateTIme,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldAttribType VARCHAR(1),
										OldStockAttrib VARCHAR(20),
										MaterialCode VARCHAR(50),
										AttribType VARCHAR(1),
										StockAttrib VARCHAR(20),
										StockAttribDesc NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTIme DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.AttribType = SourceTable.AttribType AND
					TargetTable.StockAttrib = SourceTable.StockAttrib
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
									OldMaterialCode,
									OldAttribType,
									OldStockAttrib,
									MaterialCode,
									AttribType,
									StockAttrib,
									StockAttribDesc,
									CreateDateTime,
									CreateUserID,
									ChangeDateTIme,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldAttribType VARCHAR(1),
											 OldStockAttrib VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 AttribType VARCHAR(1),
											 StockAttrib VARCHAR(20),
											 StockAttribDesc NVARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTIme DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,
									CASE 
										WHEN OldAttribType IS NULL THEN AttribType
										ELSE OldAttribType
									END AS OldAttribType,
									CASE 
										WHEN OldStockAttrib IS NULL THEN StockAttrib
										ELSE OldStockAttrib
									END AS OldStockAttrib,
									MaterialCode,
									AttribType,
									StockAttrib,
									StockAttribDesc,
									CreateDateTime,
									CreateUserID,
									ChangeDateTIme,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldAttribType VARCHAR(1),
											 OldStockAttrib VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 AttribType VARCHAR(1),
											 StockAttrib VARCHAR(20),
											 StockAttribDesc NVARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTIme DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,
									CASE 
										WHEN OldAttribType IS NULL THEN AttribType
										ELSE OldAttribType
									END AS OldAttribType,
									CASE 
										WHEN OldStockAttrib IS NULL THEN StockAttrib
										ELSE OldStockAttrib
									END AS OldStockAttrib,
									MaterialCode,
									AttribType,
									StockAttrib,
									StockAttribDesc,
									CreateDateTime,
									CreateUserID,
									ChangeDateTIme,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldAttribType VARCHAR(1),
											 OldStockAttrib VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 AttribType VARCHAR(1),
											 StockAttrib VARCHAR(20),
											 StockAttribDesc NVARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTIme DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialCode,
								 @OldAttribType,
								 @OldStockAttrib,
								 @MaterialCode,
								 @AttribType,
								 @StockAttrib,
								 @StockAttribDesc,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTIme,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialAttribute WHERE MaterialCode = @MaterialCode AND AttribType = @AttribType AND StockAttrib = @StockAttrib) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialAttribute',@MaterialCode OUTPUT
                    END

                    INSERT INTO STB_MaterialAttribute
						(
						    MaterialCode,
						    AttribType,
						    StockAttrib,
						    StockAttribDesc,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTIme,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialCode,
						    @AttribType,
						    @StockAttrib,
						    @StockAttribDesc,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTIme,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MaterialAttribute
						SET
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    AttribType =   ISNULL(@AttribType,AttribType),
						    StockAttrib =   ISNULL(@StockAttrib,StockAttrib),
						    StockAttribDesc =   ISNULL(@StockAttribDesc,StockAttribDesc),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTIme =   ISNULL(@ChangeDateTIme,ChangeDateTIme),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialCode = @OldMaterialCode AND
						    AttribType = @OldAttribType AND
						    StockAttrib = @OldStockAttrib
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialAttribute
						WHERE
						    MaterialCode = @OldMaterialCode AND
						    AttribType = @OldAttribType AND
						    StockAttrib = @OldStockAttrib
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
