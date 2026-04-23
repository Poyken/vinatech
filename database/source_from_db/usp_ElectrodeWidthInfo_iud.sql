
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2020-02-27
-- Browsable : true
-- Group : a
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeWidthInfo_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pElectrodeWidthLength INT = 0
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
	DECLARE @ElectrodeWidthLength INT = @pElectrodeWidthLength

    -- Declare Columns Variable
  DECLARE @OldElectrodeWidth NUMERIC(20,10)
  DECLARE @ElectrodeWidth NUMERIC(20,10)
  DECLARE @ElectrodeCnt INT
  DECLARE @IsUsed BIT
  DECLARE @ElectrodeTotalWidth numeric(20,10)

  

  UPDATE  STB_ElectrodeWidthInfo
       SET
          ElectrodeWidthLength = @ElectrodeWidthLength

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeWidthInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeWidthInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeWidth IS NULL THEN ElectrodeWidth
							    ELSE OldElectrodeWidth
							END AS OldElectrodeWidth,
							ElectrodeWidth,
							ElectrodeCnt,
							IsUsed,
							ElectrodeWidthLength
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldElectrodeWidth NUMERIC(20,10),
										ElectrodeWidth NUMERIC(20,10),
										ElectrodeCnt INT,
										IsUsed BIT,
										ElectrodeWidthLength INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeWidth = SourceTable.ElectrodeWidth
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeWidth = ISNULL(SourceTable.ElectrodeWidth,TargetTable.ElectrodeWidth),
					ElectrodeCnt = ISNULL(SourceTable.ElectrodeCnt,TargetTable.ElectrodeCnt),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeWidth,
						ElectrodeCnt,
						IsUsed,
						ElectrodeWidthLength
					)
				VALUES
					(
							SourceTable.ElectrodeWidth,
							SourceTable.ElectrodeCnt,
							SourceTable.IsUsed,
							@ElectrodeWidthLength
					);


			-- Process Update Table
            MERGE STB_ElectrodeWidthInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeWidth IS NULL THEN ElectrodeWidth
							    ELSE OldElectrodeWidth
							END AS OldElectrodeWidth,
							ElectrodeWidth,
							ElectrodeCnt,
							IsUsed
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldElectrodeWidth NUMERIC(20,10),
										ElectrodeWidth NUMERIC(20,10),
										ElectrodeCnt INT,
										IsUsed BIT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeWidth = SourceTable.OldElectrodeWidth
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeWidth = ISNULL(SourceTable.ElectrodeWidth,TargetTable.ElectrodeWidth),
					ElectrodeCnt = ISNULL(SourceTable.ElectrodeCnt,TargetTable.ElectrodeCnt),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeWidth,
						ElectrodeCnt,
						IsUsed,
						ElectrodeWidthLength
					)
				VALUES
					(
							SourceTable.ElectrodeWidth,
							SourceTable.ElectrodeCnt,
							SourceTable.IsUsed,
							@ElectrodeWidthLength
					);


			-- Process Delete Table
            MERGE STB_ElectrodeWidthInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeWidth IS NULL THEN ElectrodeWidth
							    ELSE OldElectrodeWidth
							END AS OldElectrodeWidth,
							ElectrodeWidth,
							ElectrodeCnt,
							IsUsed,
							ElectrodeWidthLength
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldElectrodeWidth NUMERIC(20,10),
										ElectrodeWidth NUMERIC(20,10),
										ElectrodeCnt INT,
										IsUsed BIT,
										ElectrodeWidthLength INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeWidth = SourceTable.ElectrodeWidth
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
									OldElectrodeWidth,
									ElectrodeWidth,
									ElectrodeCnt,
									IsUsed,
									ElectrodeWidthLength
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldElectrodeWidth NUMERIC(20,10),
											 ElectrodeWidth NUMERIC(20,10),
											 ElectrodeCnt INT,
											 IsUsed BIT,
											 ElectrodeWidthLength INT
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeWidth IS NULL THEN ElectrodeWidth
										ELSE OldElectrodeWidth
									END AS OldElectrodeWidth,
									ElectrodeWidth,
									ElectrodeCnt,
									IsUsed,
									ElectrodeWidthLength
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldElectrodeWidth NUMERIC(20,10),
											 ElectrodeWidth NUMERIC(20,10),
											 ElectrodeCnt INT,
											 IsUsed BIT,
											 ElectrodeWidthLength INT 
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeWidth IS NULL THEN ElectrodeWidth
										ELSE OldElectrodeWidth
									END AS OldElectrodeWidth,
									ElectrodeWidth,
									ElectrodeCnt,
									IsUsed,
									ElectrodeWidthLength
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldElectrodeWidth NUMERIC(20,10),
											 ElectrodeWidth NUMERIC(20,10),
											 ElectrodeCnt INT,
											 IsUsed BIT,
											 ElectrodeWidthLength INT
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldElectrodeWidth,
								 @ElectrodeWidth,
								 @ElectrodeCnt,
								 @IsUsed


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeWidthInfo WHERE ElectrodeWidth = @ElectrodeWidth) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeWidth)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeWidthInfo',@ElectrodeWidth OUTPUT
                    END

                    INSERT INTO STB_ElectrodeWidthInfo
						(
						    ElectrodeWidth,
						    ElectrodeCnt,
						    IsUsed,
							ElectrodeWidthLength
						)
						VALUES
						(
						    @ElectrodeWidth,
						    @ElectrodeCnt,
						    @IsUsed,
							@ElectrodeWidthLength
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeWidthInfo
						SET
						    ElectrodeWidth =   ISNULL(@ElectrodeWidth,ElectrodeWidth),
						    ElectrodeCnt =   ISNULL(@ElectrodeCnt,ElectrodeCnt),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
							ElectrodeWidthLength = ISNULL(@ElectrodeWidthLength,ElectrodeWidthLength)
						WHERE
						    ElectrodeWidth = @OldElectrodeWidth
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeWidthInfo
						WHERE
						    ElectrodeWidth = @OldElectrodeWidth
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
