-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-08-21
-- Browsable : true
-- Group : 공통
-- Description:	BOM Batch 정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_BomBatchInfo_iud]
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
  DECLARE @OldMaterialCode VARCHAR(50)
  DECLARE @OldChildMaterialCode VARCHAR(50)
  DECLARE @OldBomVersion VARCHAR(20)
  DECLARE @OldChildBomVersion VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @BomVersion VARCHAR(20)
  DECLARE @ChildMaterialCode VARCHAR(50)
  DECLARE @ChildBomVersion VARCHAR(20)
  DECLARE @BomUnit VARCHAR(10)
  DECLARE @UsedQty NUMERIC(20,5)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_BomBatchInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    SET @IsAutoKey = 0
	SET @IsLoopIUD = 0

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_BomBatchInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN OldChildMaterialCode IS NULL THEN ChildMaterialCode
							    ELSE OldChildMaterialCode
							END AS OldChildMaterialCode,
							CASE
							    WHEN OldBomVersion IS NULL THEN ISNULL(BomVersion,'')
							    ELSE OldBomVersion
							END AS OldBomVersion,
							CASE
							    WHEN OldChildBomVersion IS NULL THEN ISNULL(ChildBomVersion,'')
							    ELSE OldChildBomVersion
							END AS OldChildBomVersion,
							MaterialCode,
							ChildMaterialCode,
							ISNULL(BomVersion,'') AS BomVersion,
							ISNULL(ChildBomVersion,'') AS ChildBomVersion,
							BomUnit,
							ChildBomUnit,
							UsedQty,
							RouteCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldChildMaterialCode VARCHAR(50),
										OldBomVersion VARCHAR(20),
										OldChildBomVersion VARCHAR(20),
										MaterialCode VARCHAR(50),
										ChildMaterialCode VARCHAR(50),
										BomVersion VARCHAR(20),
										ChildBomVersion VARCHAR(20),
										BomUnit VARCHAR(10),
										ChildBomUnit VARCHAR(10),
										UsedQty NUMERIC(20,5),
										RouteCode VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.ChildMaterialCode = SourceTable.ChildMaterialCode AND
					TargetTable.BomVersion = SourceTable.BomVersion AND
					TargetTable.ChildBomVersion = SourceTable.ChildBomVersion
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					ChildMaterialCode = ISNULL(SourceTable.ChildMaterialCode,TargetTable.ChildMaterialCode),
					BomVersion = ISNULL(SourceTable.BomVersion,TargetTable.BomVersion),
					ChildBomVersion = ISNULL(SourceTable.ChildBomVersion,TargetTable.ChildBomVersion),
					BomUnit = ISNULL(SourceTable.BomUnit, TargetTable.BomUnit),
					ChildBomUnit = ISNULL(SourceTable.ChildBomUnit, TargetTable.ChildBomUnit),
					UsedQty = ISNULL(SourceTable.UsedQty,TargetTable.UsedQty),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						BomVersion,
						ChildMaterialCode,
						ChildBomVersion,
						BomUnit,
						ChildBomUnit,
						UsedQty,
						RouteCode,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.BomVersion,
							SourceTable.ChildMaterialCode,
							SourceTable.ChildBomVersion,
							SourceTable.BomUnit,
							SourceTable.ChildBomUnit,
							SourceTable.UsedQty,
							SourceTable.RouteCode,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_BomBatchInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN OldChildMaterialCode IS NULL THEN ChildMaterialCode
							    ELSE OldChildMaterialCode
							END AS OldChildMaterialCode,
							CASE 
								WHEN OldBomVersion IS NULL THEN BomVersion
								ELSE OldBomVersion
							END AS OldBomVersion,
							CASE
								WHEN OldChildBomVersion IS NULL THEN ChildBomVersion
								ELSE OldChildBomVersion
							END AS OldChildBomVersion,
							MaterialCode,
							ChildMaterialCode,
							BomVersion,
							ChildBomVersion,
							BomUnit,
							ChildBomUnit,
							UsedQty,
							RouteCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldChildMaterialCode VARCHAR(50),
										OldBomVersion VARCHAR(20),
										OldChildBomVersion VARCHAR(20),
										MaterialCode VARCHAR(50),
										ChildMaterialCode VARCHAR(50),
										BomVersion VARCHAR(20),
										ChildBomVersion VARCHAR(20),
										BomUnit VARCHAR(10),
										ChildBomUnit VARCHAR(10),
										UsedQty NUMERIC(20,5),
										RouteCode VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.OldMaterialCode AND
					TargetTable.ChildMaterialCode = SourceTable.OldChildMaterialCode AND
					TargetTable.BomVersion = SourceTable.OldBomVersion AND
					TargetTable.ChildBomVersion = SourceTable.OldChildBomVersion
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					ChildMaterialCode = ISNULL(SourceTable.ChildMaterialCode,TargetTable.ChildMaterialCode),
					BomVersion = ISNULL(SourceTable.BomVersion,TargetTable.BomVersion),
					ChildBomVersion = ISNULL(SourceTable.ChildBomVersion,TargetTable.ChildBomVersion),
					BomUnit = ISNULL(SourceTable.BomUnit, TargetTable.BomUnit),
					ChildBomUnit = ISNULL(SourceTable.ChildBomUnit, TargetTable.ChildBomUnit),
					UsedQty = ISNULL(SourceTable.UsedQty,TargetTable.UsedQty),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						BomVersion,
						ChildMaterialCode,
						ChildBomVersion,
						BomUnit,
						ChildBomUnit,
						UsedQty,
						RouteCode,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.BomVersion,
							SourceTable.ChildMaterialCode,
							SourceTable.ChildBomVersion,
							SourceTable.BomUnit,
							SourceTable.ChildBomUnit,
							SourceTable.UsedQty,
							SourceTable.RouteCode,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_BomBatchInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN OldChildMaterialCode IS NULL THEN ChildMaterialCode
							    ELSE OldChildMaterialCode
							END AS OldChildMaterialCode,
							CASE 
								WHEN OldBomVersion IS NULL THEN BomVersion
								ELSE OldBomVersion
							END AS OldBomVersion,
							CASE
								WHEN OldChildBomVersion IS NULL THEN ChildBomVersion
								ELSE OldChildBomVersion
							END AS OldChildBomVersion,
							MaterialCode,
							ChildMaterialCode,
							BomVersion,
							ChildBomVersion,
							BomUnit,
							ChildBomUnit,
							UsedQty,
							RouteCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldChildMaterialCode VARCHAR(50),
										OldBomVersion VARCHAR(20),
										OldChildBomVersion VARCHAR(20),
										MaterialCode VARCHAR(50),
										ChildMaterialCode VARCHAR(50),
										BomVersion VARCHAR(20),
										ChildBomVersion VARCHAR(20),
										BomUnit VARCHAR(10),
										ChildBomUnit VARCHAR(10),
										UsedQty NUMERIC(20,5),
										RouteCode VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.ChildMaterialCode = SourceTable.ChildMaterialCode AND
					TargetTable.BomVersion = SourceTable.BomVersion AND
					TargetTable.ChildBomVersion = SourceTable.ChildBomVersion
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
									OldChildMaterialCode,
									OldBomVersion,
									OldChildBomVersion,
									MaterialCode,
									ChildMaterialCode,
									BomVersion,
									ChildBomVersion,
									BomUnit,
									UsedQty,
									RouteCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldChildMaterialCode VARCHAR(50),
											 OldBomVersion VARCHAR(20),
											 OldChildBomVersion VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 ChildMaterialCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 ChildBomVersion VARCHAR(20),
											 BomUnit VARCHAR(10),
											 UsedQty NUMERIC(20,5),
											 RouteCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
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
										WHEN OldChildMaterialCode IS NULL THEN ChildMaterialCode
										ELSE OldChildMaterialCode
									END AS OldChildMaterialCode,
									CASE 
										WHEN OldBomVersion IS NULL THEN BomVersion
										ELSE OldBomVersion
									END AS OldBomVersion,
									CASE
										WHEN OldChildBomVersion IS NULL THEN ChildBomVersion
										ELSE OldChildBomVersion
									END AS OldChildBomVersion,
									MaterialCode,
									ChildMaterialCode,
									BomVersion,
									ChildBomVersion,
									BomUnit,
									UsedQty,
									RouteCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldChildMaterialCode VARCHAR(50),
											 OldBomVersion VARCHAR(20),
											 OldChildBomVersion VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 ChildMaterialCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 ChildBomVersion VARCHAR(20),
											 BomUnit VARCHAR(10),
											 UsedQty NUMERIC(20,5),
											 RouteCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
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
										WHEN OldChildMaterialCode IS NULL THEN ChildMaterialCode
										ELSE OldChildMaterialCode
									END AS OldChildMaterialCode,
									CASE 
										WHEN OldBomVersion IS NULL THEN BomVersion
										ELSE OldBomVersion
									END AS OldBomVersion,
									CASE
										WHEN OldChildBomVersion IS NULL THEN ChildBomVersion
										ELSE OldChildBomVersion
									END AS OldChildBomVersion,
									MaterialCode,
									ChildMaterialCode,
									BomVersion,
									ChildBomVersion,
									BomUnit,
									UsedQty,
									RouteCode,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldChildMaterialCode VARCHAR(50),
											 OldBomVersion VARCHAR(20),
											 OldChildBomVersion VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 ChildMaterialCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 ChildBomVersion VARCHAR(20),
											 BomUnit VARCHAR(10),
											 UsedQty NUMERIC(20,5),
											 RouteCode VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialCode,
								 @OldChildMaterialCode,
								 @OldBomVersion,
								 @OldChildBomVersion,
								 @MaterialCode,
								 @ChildMaterialCode,
								 @BomVersion,
								 @ChildBomVersion,
								 @BomUnit,
								 @UsedQty,
								 @RouteCode,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_BomBatchInfo WHERE MaterialCode = @MaterialCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_BomBatchInfo', @MaterialCode OUTPUT
                    END

                    INSERT INTO STB_BomBatchInfo
						(
						    MaterialCode,
						    ChildMaterialCode,
							BomUnit,
						    UsedQty,
						    RouteCode,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialCode,
						    @ChildMaterialCode,
							@BomUnit,
						    @UsedQty,
						    @RouteCode,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_BomBatchInfo
						SET
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    ChildMaterialCode =   ISNULL(@ChildMaterialCode,ChildMaterialCode),
							BomUnit = ISNULL(@BomUnit, BomUnit),
						    UsedQty =   ISNULL(@UsedQty,UsedQty),
						    RouteCode =   ISNULL(@RouteCode,RouteCode),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialCode = @OldMaterialCode AND
						    ChildMaterialCode = @OldChildMaterialCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_BomBatchInfo
						WHERE
						    MaterialCode = @MaterialCode AND
						    ChildMaterialCode = @ChildMaterialCode
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
