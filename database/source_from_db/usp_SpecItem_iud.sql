
-- =============================================
-- Author:KimGiGeun(ggkim@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 사양항목정보
-- Description:	사양항목정보IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SpecItem_iud]
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
  DECLARE @OldSpecItemCode VARCHAR(20)
  DECLARE @SpecItemCode VARCHAR(20)
  DECLARE @ProductGroupCode VARCHAR(20)
  DECLARE @SpecGroupCode VARCHAR(20)
  DECLARE @SpecItemName NVARCHAR(100)
  DECLARE @SpecItemNameL NVARCHAR(100)
  DECLARE @SpecItemCheckType VARCHAR(1)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @Remark NVARCHAR(500)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SpecItem',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_SpecItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSpecItemCode IS NULL THEN SpecItemCode
							    ELSE OldSpecItemCode
							END AS OldSpecItemCode,
							SpecItemCode,
							ProductGroupCode,
							SpecGroupCode,
							SpecItemName,
							SpecItemNameL,
							SpecItemCheckType,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Remark
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldSpecItemCode VARCHAR(20),
										SpecItemCode VARCHAR(20),
										ProductGroupCode VARCHAR(20),
										SpecGroupCode VARCHAR(20),
										SpecItemName NVARCHAR(100),
										SpecItemNameL NVARCHAR(100),
										SpecItemCheckType VARCHAR(1),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Remark NVARCHAR(500)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SpecItemCode = SourceTable.SpecItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					SpecItemCode = ISNULL(SourceTable.SpecItemCode,TargetTable.SpecItemCode),
					ProductGroupCode = ISNULL(SourceTable.ProductGroupCode,TargetTable.ProductGroupCode),
					SpecGroupCode = ISNULL(SourceTable.SpecGroupCode,TargetTable.SpecGroupCode),
					SpecItemName = ISNULL(SourceTable.SpecItemName,TargetTable.SpecItemName),
					SpecItemNameL = ISNULL(SourceTable.SpecItemNameL,TargetTable.SpecItemNameL),
					SpecItemCheckType = ISNULL(SourceTable.SpecItemCheckType,TargetTable.SpecItemCheckType),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark)
			WHEN NOT MATCHED THEN
				INSERT
					(
						SpecItemCode,
						ProductGroupCode,
						SpecGroupCode,
						SpecItemName,
						SpecItemNameL,
						SpecItemCheckType,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						Remark
					)
				VALUES
					(
							SourceTable.SpecItemCode,
							SourceTable.ProductGroupCode,
							SourceTable.SpecGroupCode,
							SourceTable.SpecItemName,
							SourceTable.SpecItemNameL,
							SourceTable.SpecItemCheckType,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.Remark
					);


			-- Process Update Table
            MERGE STB_SpecItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSpecItemCode IS NULL THEN SpecItemCode
							    ELSE OldSpecItemCode
							END AS OldSpecItemCode,
							SpecItemCode,
							ProductGroupCode,
							SpecGroupCode,
							SpecItemName,
							SpecItemNameL,
							SpecItemCheckType,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Remark
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldSpecItemCode VARCHAR(20),
										SpecItemCode VARCHAR(20),
										ProductGroupCode VARCHAR(20),
										SpecGroupCode VARCHAR(20),
										SpecItemName NVARCHAR(100),
										SpecItemNameL NVARCHAR(100),
										SpecItemCheckType VARCHAR(1),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Remark NVARCHAR(500)

									) 
				) AS SourceTable
			ON
				(
					TargetTable.SpecItemCode = SourceTable.OldSpecItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					SpecItemCode = ISNULL(SourceTable.SpecItemCode,TargetTable.SpecItemCode),
					ProductGroupCode = ISNULL(SourceTable.ProductGroupCode,TargetTable.ProductGroupCode),
					SpecGroupCode = ISNULL(SourceTable.SpecGroupCode,TargetTable.SpecGroupCode),
					SpecItemName = ISNULL(SourceTable.SpecItemName,TargetTable.SpecItemName),
					SpecItemNameL = ISNULL(SourceTable.SpecItemNameL,TargetTable.SpecItemNameL),
					SpecItemCheckType = ISNULL(SourceTable.SpecItemCheckType,TargetTable.SpecItemCheckType),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark)
			WHEN NOT MATCHED THEN
				INSERT
					(
						SpecItemCode,
						ProductGroupCode,
						SpecGroupCode,
						SpecItemName,
						SpecItemNameL,
						SpecItemCheckType,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						Remark
					)
				VALUES
					(
							SourceTable.SpecItemCode,
							SourceTable.ProductGroupCode,
							SourceTable.SpecGroupCode,
							SourceTable.SpecItemName,
							SourceTable.SpecItemNameL,
							SourceTable.SpecItemCheckType,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.Remark
					);


			-- Process Delete Table
            MERGE STB_SpecItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSpecItemCode IS NULL THEN SpecItemCode
							    ELSE OldSpecItemCode
							END AS OldSpecItemCode,
							SpecItemCode,
							ProductGroupCode,
							SpecGroupCode,
							SpecItemName,
							SpecItemNameL,
							SpecItemCheckType,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Remark
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldSpecItemCode VARCHAR(20),
										SpecItemCode VARCHAR(20),
										ProductGroupCode VARCHAR(20),
										SpecGroupCode VARCHAR(20),
										SpecItemName NVARCHAR(100),
										SpecItemNameL NVARCHAR(100),
										SpecItemCheckType VARCHAR(1),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Remark NVARCHAR(500)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SpecItemCode = SourceTable.SpecItemCode
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
									OldSpecItemCode,
									SpecItemCode,
									ProductGroupCode,
									SpecGroupCode,
									SpecItemName,
									SpecItemNameL,
									SpecItemCheckType,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Remark
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldSpecItemCode VARCHAR(20),
											 SpecItemCode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 SpecGroupCode VARCHAR(20),
											 SpecItemName NVARCHAR(100),
											 SpecItemNameL NVARCHAR(100),
											 SpecItemCheckType VARCHAR(1),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark NVARCHAR(500)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldSpecItemCode IS NULL THEN SpecItemCode
										ELSE OldSpecItemCode
									END AS OldSpecItemCode,
									SpecItemCode,
									ProductGroupCode,
									SpecGroupCode,
									SpecItemName,
									SpecItemNameL,
									SpecItemCheckType,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Remark
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldSpecItemCode VARCHAR(20),
											 SpecItemCode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 SpecGroupCode VARCHAR(20),
											 SpecItemName NVARCHAR(100),
											 SpecItemNameL NVARCHAR(100),
											 SpecItemCheckType VARCHAR(1),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark NVARCHAR(500)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldSpecItemCode IS NULL THEN SpecItemCode
										ELSE OldSpecItemCode
									END AS OldSpecItemCode,
									SpecItemCode,
									ProductGroupCode,
									SpecGroupCode,
									SpecItemName,
									SpecItemNameL,
									SpecItemCheckType,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Remark
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldSpecItemCode VARCHAR(20),
											 SpecItemCode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 SpecGroupCode VARCHAR(20),
											 SpecItemName NVARCHAR(100),
											 SpecItemNameL NVARCHAR(100),
											 SpecItemCheckType VARCHAR(1),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark NVARCHAR(500)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldSpecItemCode,
								 @SpecItemCode,
								 @ProductGroupCode,
								 @SpecGroupCode,
								 @SpecItemName,
								 @SpecItemNameL,
								 @SpecItemCheckType,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @Remark


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_SpecItem WHERE SpecItemCode = @SpecItemCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @SpecItemCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_SpecItem',@SpecItemCode OUTPUT
                    END

                    INSERT INTO STB_SpecItem
						(
						    SpecItemCode,
						    ProductGroupCode,
						    SpecGroupCode,
						    SpecItemName,
						    SpecItemNameL,
						    SpecItemCheckType,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							Remark
						)
						VALUES
						(
						    @SpecItemCode,
						    @ProductGroupCode,
						    @SpecGroupCode,
						    @SpecItemName,
						    @SpecItemNameL,
						    @SpecItemCheckType,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@Remark
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_SpecItem
						SET
						    SpecItemCode =   ISNULL(@SpecItemCode,SpecItemCode),
						    ProductGroupCode =   ISNULL(@ProductGroupCode,ProductGroupCode),
						    SpecGroupCode =   ISNULL(@SpecGroupCode,SpecGroupCode),
						    SpecItemName =   ISNULL(@SpecItemName,SpecItemName),
						    SpecItemNameL =   ISNULL(@SpecItemNameL,SpecItemNameL),
						    SpecItemCheckType =   ISNULL(@SpecItemCheckType,SpecItemCheckType),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							Remark = ISNULL(@Remark,Remark)
						WHERE
						    SpecItemCode = @OldSpecItemCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_SpecItem
						WHERE
						    SpecItemCode = @OldSpecItemCode
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
