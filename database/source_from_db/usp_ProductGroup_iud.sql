
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2018-07-23
-- Browsable : true
-- Group : 공통
-- Description:	제품그룹 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductGroup_iud]
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
  DECLARE @OldProductGroupCode VARCHAR(20)
  DECLARE @ProductGroupCode VARCHAR(20)
  DECLARE @ProductGroupName NVARCHAR(50)
  DECLARE @ProductGroupNameL NVARCHAR(50)
  DECLARE @ProductGroupDesc NVARCHAR(MAX)
  DECLARE @ProductGroupDescL NVARCHAR(MAX)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ProductGroup',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ProductGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProductGroupCode IS NULL THEN ProductGroupCode
							    ELSE OldProductGroupCode
							END AS OldProductGroupCode,
							ProductGroupCode,
							ProductGroupName,
							ProductGroupNameL,
							ProductGroupDesc,
							ProductGroupDescL,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldProductGroupCode VARCHAR(20),
										ProductGroupCode VARCHAR(20),
										ProductGroupName NVARCHAR(50),
										ProductGroupNameL NVARCHAR(50),
										ProductGroupDesc NVARCHAR(MAX),
										ProductGroupDescL NVARCHAR(MAX),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProductGroupCode = SourceTable.ProductGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProductGroupCode = ISNULL(SourceTable.ProductGroupCode,TargetTable.ProductGroupCode),
					ProductGroupName = ISNULL(SourceTable.ProductGroupName,TargetTable.ProductGroupName),
					ProductGroupNameL = ISNULL(SourceTable.ProductGroupNameL,TargetTable.ProductGroupNameL),
					ProductGroupDesc = ISNULL(SourceTable.ProductGroupDesc,TargetTable.ProductGroupDesc),
					ProductGroupDescL = ISNULL(SourceTable.ProductGroupDescL,TargetTable.ProductGroupDescL),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProductGroupCode,
						ProductGroupName,
						ProductGroupNameL,
						ProductGroupDesc,
						ProductGroupDescL,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ProductGroupCode,
							SourceTable.ProductGroupName,
							SourceTable.ProductGroupNameL,
							SourceTable.ProductGroupDesc,
							SourceTable.ProductGroupDescL,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ProductGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProductGroupCode IS NULL THEN ProductGroupCode
							    ELSE OldProductGroupCode
							END AS OldProductGroupCode,
							ProductGroupCode,
							ProductGroupName,
							ProductGroupNameL,
							ProductGroupDesc,
							ProductGroupDescL,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldProductGroupCode VARCHAR(20),
										ProductGroupCode VARCHAR(20),
										ProductGroupName NVARCHAR(50),
										ProductGroupNameL NVARCHAR(50),
										ProductGroupDesc NVARCHAR(MAX),
										ProductGroupDescL NVARCHAR(MAX),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProductGroupCode = SourceTable.OldProductGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProductGroupCode = ISNULL(SourceTable.ProductGroupCode,TargetTable.ProductGroupCode),
					ProductGroupName = ISNULL(SourceTable.ProductGroupName,TargetTable.ProductGroupName),
					ProductGroupNameL = ISNULL(SourceTable.ProductGroupNameL,TargetTable.ProductGroupNameL),
					ProductGroupDesc = ISNULL(SourceTable.ProductGroupDesc,TargetTable.ProductGroupDesc),
					ProductGroupDescL = ISNULL(SourceTable.ProductGroupDescL,TargetTable.ProductGroupDescL),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProductGroupCode,
						ProductGroupName,
						ProductGroupNameL,
						ProductGroupDesc,
						ProductGroupDescL,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ProductGroupCode,
							SourceTable.ProductGroupName,
							SourceTable.ProductGroupNameL,
							SourceTable.ProductGroupDesc,
							SourceTable.ProductGroupDescL,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ProductGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProductGroupCode IS NULL THEN ProductGroupCode
							    ELSE OldProductGroupCode
							END AS OldProductGroupCode,
							ProductGroupCode,
							ProductGroupName,
							ProductGroupNameL,
							ProductGroupDesc,
							ProductGroupDescL,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldProductGroupCode VARCHAR(20),
										ProductGroupCode VARCHAR(20),
										ProductGroupName NVARCHAR(50),
										ProductGroupNameL NVARCHAR(50),
										ProductGroupDesc NVARCHAR(MAX),
										ProductGroupDescL NVARCHAR(MAX),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProductGroupCode = SourceTable.ProductGroupCode
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
									OldProductGroupCode,
									ProductGroupCode,
									ProductGroupName,
									ProductGroupNameL,
									ProductGroupDesc,
									ProductGroupDescL,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldProductGroupCode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 ProductGroupName NVARCHAR(50),
											 ProductGroupNameL NVARCHAR(50),
											 ProductGroupDesc NVARCHAR(MAX),
											 ProductGroupDescL NVARCHAR(MAX),
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
										WHEN OldProductGroupCode IS NULL THEN ProductGroupCode
										ELSE OldProductGroupCode
									END AS OldProductGroupCode,
									ProductGroupCode,
									ProductGroupName,
									ProductGroupNameL,
									ProductGroupDesc,
									ProductGroupDescL,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldProductGroupCode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 ProductGroupName NVARCHAR(50),
											 ProductGroupNameL NVARCHAR(50),
											 ProductGroupDesc NVARCHAR(MAX),
											 ProductGroupDescL NVARCHAR(MAX),
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
										WHEN OldProductGroupCode IS NULL THEN ProductGroupCode
										ELSE OldProductGroupCode
									END AS OldProductGroupCode,
									ProductGroupCode,
									ProductGroupName,
									ProductGroupNameL,
									ProductGroupDesc,
									ProductGroupDescL,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldProductGroupCode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 ProductGroupName NVARCHAR(50),
											 ProductGroupNameL NVARCHAR(50),
											 ProductGroupDesc NVARCHAR(MAX),
											 ProductGroupDescL NVARCHAR(MAX),
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
								 @OldProductGroupCode,
								 @ProductGroupCode,
								 @ProductGroupName,
								 @ProductGroupNameL,
								 @ProductGroupDesc,
								 @ProductGroupDescL,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ProductGroup WHERE ProductGroupCode = @ProductGroupCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ProductGroupCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProductGroup',@ProductGroupCode OUTPUT
                    END

                    INSERT INTO STB_ProductGroup
						(
						    ProductGroupCode,
						    ProductGroupName,
						    ProductGroupNameL,
						    ProductGroupDesc,
						    ProductGroupDescL,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ProductGroupCode,
						    @ProductGroupName,
						    @ProductGroupNameL,
						    @ProductGroupDesc,
						    @ProductGroupDescL,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ProductGroup
						SET
						    ProductGroupCode =   ISNULL(@ProductGroupCode,ProductGroupCode),
						    ProductGroupName =   ISNULL(@ProductGroupName,ProductGroupName),
						    ProductGroupNameL =   ISNULL(@ProductGroupNameL,ProductGroupNameL),
						    ProductGroupDesc =   ISNULL(@ProductGroupDesc,ProductGroupDesc),
						    ProductGroupDescL =   ISNULL(@ProductGroupDescL,ProductGroupDescL),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ProductGroupCode = @OldProductGroupCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ProductGroup
						WHERE
						    ProductGroupCode = @OldProductGroupCode
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
