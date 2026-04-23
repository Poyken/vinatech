
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2019-12-27
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_BAD_LIST2_iud]
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
  DECLARE @OldstandardDate VARCHAR(10)
  DECLARE @OldBAD_KIND VARCHAR(20)
  DECLARE @OldQty INT
  --DECLARE @Day VARCHAR(10) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GETDATE(), 121), 1, 10), '-', '')                 -- select REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 1, 7), '-', '')  

  DECLARE @standardDate VARCHAR(10) 

  DECLARE @BAD_KIND VARCHAR(20)
  DECLARE @Qty INT
  DECLARE @CreateDateTime DATETIME


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_BAD_LIST2',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_BAD_LIST2 AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldstandardDate IS NULL THEN standardDate
							    ELSE OldstandardDate
							END AS OldstandardDate,
							CASE
							    WHEN OldBAD_KIND IS NULL THEN BAD_KIND
							    ELSE OldBAD_KIND
							END AS OldBAD_KIND,
							CASE
							    WHEN OldQty IS NULL THEN Qty
							    ELSE OldQty
							END AS OldQty,
							standardDate,
							BAD_KIND,
							Qty,
							GETDATE() AS CreateDateTime
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldstandardDate VARCHAR(10),
										OldBAD_KIND VARCHAR(20),
										OldQty INT,
										standardDate VARCHAR(10),
										BAD_KIND VARCHAR(20),
										Qty INT,
										CreateDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.standardDate =  SourceTable.standardDate
					AND	TargetTable.BAD_KIND = SourceTable.BAD_KIND 
					AND	TargetTable.Qty = SourceTable.Qty
				)

			WHEN MATCHED THEN
				UPDATE SET					
					standardDate = ISNULL(SourceTable.standardDate,TargetTable.standardDate),
					BAD_KIND = ISNULL(SourceTable.BAD_KIND,TargetTable.BAD_KIND),
					Qty = ISNULL(SourceTable.Qty,TargetTable.Qty)
			WHEN NOT MATCHED THEN
				INSERT
					(
						standardDate,
						BAD_KIND,
						Qty,
						CreateDateTime
					)
				VALUES
					(
							--'20191230',
							SourceTable.standardDate,
							SourceTable.BAD_KIND,
							SourceTable.Qty,
							SourceTable.CreateDateTime
					);


			-- Process Update Table
            MERGE STB_BAD_LIST2 AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldstandardDate IS NULL THEN standardDate
							    ELSE OldstandardDate
							END AS OldstandardDate,
							CASE
							    WHEN OldBAD_KIND IS NULL THEN BAD_KIND
							    ELSE OldBAD_KIND
							END AS OldBAD_KIND,
							CASE
							    WHEN OldQty IS NULL THEN Qty
							    ELSE OldQty
							END AS OldQty,
							standardDate,
							BAD_KIND,
							Qty,
							GETDATE() AS CreateDateTime
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldstandardDate VARCHAR(10),
										OldBAD_KIND VARCHAR(20),
										OldQty INT,
										standardDate VARCHAR(10),
										BAD_KIND VARCHAR(20),
										Qty INT,
										CreateDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.standardDate = SourceTable.OldstandardDate AND
					TargetTable.BAD_KIND = SourceTable.OldBAD_KIND AND
					TargetTable.Qty = SourceTable.OldQty
				)

			WHEN MATCHED THEN
				UPDATE SET
					standardDate = ISNULL(SourceTable.standardDate,TargetTable.standardDate),
					BAD_KIND = ISNULL(SourceTable.BAD_KIND,TargetTable.BAD_KIND),
					Qty = ISNULL(SourceTable.Qty,TargetTable.Qty)
			WHEN NOT MATCHED THEN
				INSERT
					(
						standardDate,
						BAD_KIND,
						Qty,
						CreateDateTime
					)
				VALUES
					(
							--'20191230',
							SourceTable.standardDate,
							SourceTable.BAD_KIND,
							SourceTable.Qty,
							SourceTable.CreateDateTime
					);


			-- Process Delete Table
            MERGE STB_BAD_LIST2 AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldstandardDate IS NULL THEN standardDate
							    ELSE OldstandardDate
							END AS OldstandardDate,
							CASE
							    WHEN OldBAD_KIND IS NULL THEN BAD_KIND
							    ELSE OldBAD_KIND
							END AS OldBAD_KIND,
							CASE
							    WHEN OldQty IS NULL THEN Qty
							    ELSE OldQty
							END AS OldQty,
							standardDate,
							BAD_KIND,
							Qty,
							GETDATE() AS CreateDateTime
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldstandardDate VARCHAR(10),
										OldBAD_KIND VARCHAR(20),
										OldQty INT,
										standardDate VARCHAR(10),
										BAD_KIND VARCHAR(20),
										Qty INT,
										CreateDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.standardDate = SourceTable.standardDate AND
					TargetTable.BAD_KIND = SourceTable.BAD_KIND AND
					TargetTable.Qty = SourceTable.Qty
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
									OldstandardDate,
									OldBAD_KIND,
									OldQty,
									standardDate,
									BAD_KIND,
									Qty,
									CreateDateTime
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldstandardDate VARCHAR(10),
											 OldBAD_KIND VARCHAR(20),
											 OldQty INT,
											 standardDate VARCHAR(10),
											 BAD_KIND VARCHAR(20),
											 Qty INT,
											 CreateDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldstandardDate IS NULL THEN standardDate
										ELSE OldstandardDate
									END AS OldstandardDate,
									CASE 
										WHEN OldBAD_KIND IS NULL THEN BAD_KIND
										ELSE OldBAD_KIND
									END AS OldBAD_KIND,
									CASE 
										WHEN OldQty IS NULL THEN Qty
										ELSE OldQty
									END AS OldQty,
									standardDate,
									BAD_KIND,
									Qty,
									CreateDateTime
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldstandardDate VARCHAR(10),
											 OldBAD_KIND VARCHAR(20),
											 OldQty INT,
											 standardDate VARCHAR(10),
											 BAD_KIND VARCHAR(20),
											 Qty INT,
											 CreateDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldstandardDate IS NULL THEN standardDate
										ELSE OldstandardDate
									END AS OldstandardDate,
									CASE 
										WHEN OldBAD_KIND IS NULL THEN BAD_KIND
										ELSE OldBAD_KIND
									END AS OldBAD_KIND,
									CASE 
										WHEN OldQty IS NULL THEN Qty
										ELSE OldQty
									END AS OldQty,
									standardDate,
									BAD_KIND,
									Qty,
									CreateDateTime
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldstandardDate VARCHAR(10),
											 OldBAD_KIND VARCHAR(20),
											 OldQty INT,
											 standardDate VARCHAR(10),
											 BAD_KIND VARCHAR(20),
											 Qty INT,
											 CreateDateTime DATETIMEOFFSET
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldstandardDate,
								 @OldBAD_KIND,
								 @OldQty,
								 @standardDate,
								 @BAD_KIND,
								 @Qty,
								 @CreateDateTime


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_BAD_LIST2 WHERE standardDate = @standardDate AND BAD_KIND = @BAD_KIND AND Qty = @Qty) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @standardDate)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_BAD_LIST2',@standardDate OUTPUT
                    END

                    INSERT INTO STB_BAD_LIST2
						(
						    standardDate,
						    BAD_KIND,
						    Qty,
						    CreateDateTime
						)
						VALUES
						(
						    --'20191230',
							@standardDate,
						    @BAD_KIND,
						    @Qty,
						    GETDATE()
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_BAD_LIST2
						SET
						    standardDate =   ISNULL(@standardDate,standardDate),
						    BAD_KIND =   ISNULL(@BAD_KIND,BAD_KIND),
						    Qty =   ISNULL(@Qty,Qty),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime)
						WHERE
						    standardDate = @OldstandardDate AND
						    BAD_KIND = @OldBAD_KIND AND
						    Qty = @OldQty
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_BAD_LIST2
						WHERE
						    standardDate = @OldstandardDate AND
						    BAD_KIND = @OldBAD_KIND AND
						    Qty = @OldQty
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