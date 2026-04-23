
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2019-03-26
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_HelaBarcode_iud]
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
  DECLARE @OldPackageID VARCHAR(20)
  DECLARE @PackageID VARCHAR(20)
  DECLARE @PartNo VARCHAR(20)
  DECLARE @Quantity INT
  DECLARE @ManPartNo VARCHAR(20)
  DECLARE @SupplierID VARCHAR(20)
  DECLARE @BatchID VARCHAR(20)
  DECLARE @ManDate VARCHAR(20)
  DECLARE @PrintYn BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_HelaBarcode',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_HelaBarcode AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldPackageID IS NULL THEN PackageID
							    ELSE OldPackageID
							END AS OldPackageID,
							PackageID,
							PartNo,
							Quantity,
							ManPartNo,
							SupplierID,
							BatchID,
							ManDate,
							PrintYn,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldPackageID VARCHAR(20),
										PackageID VARCHAR(20),
										PartNo VARCHAR(20),
										Quantity INT,
										ManPartNo VARCHAR(20),
										SupplierID VARCHAR(20),
										BatchID VARCHAR(20),
										ManDate VARCHAR(20),
										PrintYn BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.PackageID = SourceTable.PackageID
				)

			WHEN MATCHED THEN
				UPDATE SET
					PackageID = ISNULL(SourceTable.PackageID,TargetTable.PackageID),
					BatchID = ISNULL(SourceTable.BatchID,TargetTable.BatchID),
					PrintYn = ISNULL(SourceTable.PrintYn,TargetTable.PrintYn),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						PackageID,
						BatchID,
						PrintYn,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.PackageID,
							SourceTable.BatchID,
							SourceTable.PrintYn,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_HelaBarcode AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldPackageID IS NULL THEN PackageID
							    ELSE OldPackageID
							END AS OldPackageID,
							PackageID,
							PartNo,
							Quantity,
							ManPartNo,
							SupplierID,
							BatchID,
							ManDate,
							PrintYn,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldPackageID VARCHAR(20),
										PackageID VARCHAR(20),
										PartNo VARCHAR(20),
										Quantity INT,
										ManPartNo VARCHAR(20),
										SupplierID VARCHAR(20),
										BatchID VARCHAR(20),
										ManDate VARCHAR(20),
										PrintYn BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.PackageID = SourceTable.OldPackageID
				)

			WHEN MATCHED THEN
				UPDATE SET
					PackageID = ISNULL(SourceTable.PackageID,TargetTable.PackageID),
					BatchID = ISNULL(SourceTable.BatchID,TargetTable.BatchID),
					PrintYn = ISNULL(SourceTable.PrintYn,TargetTable.PrintYn),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						PackageID,
						BatchID,
						PrintYn,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.PackageID,
							SourceTable.BatchID,
							SourceTable.PrintYn,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_HelaBarcode AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldPackageID IS NULL THEN PackageID
							    ELSE OldPackageID
							END AS OldPackageID,
							PackageID,
							PartNo,
							Quantity,
							ManPartNo,
							SupplierID,
							BatchID,
							ManDate,
							PrintYn,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldPackageID VARCHAR(20),
										PackageID VARCHAR(20),
										PartNo VARCHAR(20),
										Quantity INT,
										ManPartNo VARCHAR(20),
										SupplierID VARCHAR(20),
										BatchID VARCHAR(20),
										ManDate VARCHAR(20),
										PrintYn BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.PackageID = SourceTable.PackageID
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
									OldPackageID,
									PackageID,
									PartNo,
									Quantity,
									ManPartNo,
									SupplierID,
									BatchID,
									ManDate,
									PrintYn,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldPackageID VARCHAR(20),
											 PackageID VARCHAR(20),
											 PartNo VARCHAR(20),
											 Quantity INT,
											 ManPartNo VARCHAR(20),
											 SupplierID VARCHAR(20),
											 BatchID VARCHAR(20),
											 ManDate VARCHAR(20),
											 PrintYn BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldPackageID IS NULL THEN PackageID
										ELSE OldPackageID
									END AS OldPackageID,
									PackageID,
									PartNo,
									Quantity,
									ManPartNo,
									SupplierID,
									BatchID,
									ManDate,
									PrintYn,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldPackageID VARCHAR(20),
											 PackageID VARCHAR(20),
											 PartNo VARCHAR(20),
											 Quantity INT,
											 ManPartNo VARCHAR(20),
											 SupplierID VARCHAR(20),
											 BatchID VARCHAR(20),
											 ManDate VARCHAR(20),
											 PrintYn BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldPackageID IS NULL THEN PackageID
										ELSE OldPackageID
									END AS OldPackageID,
									PackageID,
									PartNo,
									Quantity,
									ManPartNo,
									SupplierID,
									BatchID,
									ManDate,
									PrintYn,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldPackageID VARCHAR(20),
											 PackageID VARCHAR(20),
											 PartNo VARCHAR(20),
											 Quantity INT,
											 ManPartNo VARCHAR(20),
											 SupplierID VARCHAR(20),
											 BatchID VARCHAR(20),
											 ManDate VARCHAR(20),
											 PrintYn BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldPackageID,
								 @PackageID,
								 @PartNo,
								 @Quantity,
								 @ManPartNo,
								 @SupplierID,
								 @BatchID,
								 @ManDate,
								 @PrintYn,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_HelaBarcode WHERE PackageID = @PackageID) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @PackageID)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_HelaBarcode',@PackageID OUTPUT
                    END

                    INSERT INTO STB_HelaBarcode
						(
						    PackageID,
						    BatchID,
						    PrintYn,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @PackageID,
						    @BatchID,
						    @PrintYn,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_HelaBarcode
						SET
						    PackageID =   ISNULL(@PackageID,PackageID),
						    BatchID =   ISNULL(@BatchID,BatchID),
						    PrintYn =   ISNULL(@PrintYn,PrintYn),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    PackageID = @OldPackageID
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_HelaBarcode
						WHERE
						    PackageID = @OldPackageID
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
