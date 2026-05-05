-- Procedure: usp_BasicStatisticsConst_iud
-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018-02-23
-- Browsable : true
-- Group : Statistics
-- Description:	Sample에 따른 통계상수정보를 저장합니다..
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_BasicStatisticsConst_iud]
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
  DECLARE @OldSampleSize INT
  DECLARE @SampleSize INT
  DECLARE @A2 NUMERIC(10,4)
  DECLARE @A3 NUMERIC(10,4)
  DECLARE @D2 NUMERIC(10,4)
  DECLARE @D3 NUMERIC(10,4)
  DECLARE @D4 NUMERIC(10,4)
  DECLARE @B3 NUMERIC(10,4)
  DECLARE @B4 NUMERIC(10,4)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_BasicStatisticsConst',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_BasicStatisticsConst AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSampleSize IS NULL THEN SampleSize
							    ELSE OldSampleSize
							END AS OldSampleSize,
							SampleSize,
							A2,
							A3,
							D2,
							D3,
							D4,
							B3,
							B4
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldSampleSize INT,
										SampleSize INT,
										A2 NUMERIC(10,4),
										A3 NUMERIC(10,4),
										D2 NUMERIC(10,4),
										D3 NUMERIC(10,4),
										D4 NUMERIC(10,4),
										B3 NUMERIC(10,4),
										B4 NUMERIC(10,4)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SampleSize = SourceTable.SampleSize
				)

			WHEN MATCHED THEN
				UPDATE SET
					SampleSize = ISNULL(SourceTable.SampleSize,TargetTable.SampleSize),
					A2 = ISNULL(SourceTable.A2,TargetTable.A2),
					A3 = ISNULL(SourceTable.A3,TargetTable.A3),
					D2 = ISNULL(SourceTable.D2,TargetTable.D2),
					D3 = ISNULL(SourceTable.D3,TargetTable.D3),
					D4 = ISNULL(SourceTable.D4,TargetTable.D4),
					B3 = ISNULL(SourceTable.B3,TargetTable.B3),
					B4 = ISNULL(SourceTable.B4,TargetTable.B4)
			WHEN NOT MATCHED THEN
				INSERT
					(
						SampleSize,
						A2,
						A3,
						D2,
						D3,
						D4,
						B3,
						B4
					)
				VALUES
					(
							SourceTable.SampleSize,
							SourceTable.A2,
							SourceTable.A3,
							SourceTable.D2,
							SourceTable.D3,
							SourceTable.D4,
							SourceTable.B3,
							SourceTable.B4
					);


			-- Process Update Table
            MERGE STB_BasicStatisticsConst AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSampleSize IS NULL THEN SampleSize
							    ELSE OldSampleSize
							END AS OldSampleSize,
							SampleSize,
							A2,
							A3,
							D2,
							D3,
							D4,
							B3,
							B4
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldSampleSize INT,
										SampleSize INT,
										A2 NUMERIC(10,4),
										A3 NUMERIC(10,4),
										D2 NUMERIC(10,4),
										D3 NUMERIC(10,4),
										D4 NUMERIC(10,4),
										B3 NUMERIC(10,4),
										B4 NUMERIC(10,4)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SampleSize = SourceTable.OldSampleSize
				)

			WHEN MATCHED THEN
				UPDATE SET
					SampleSize = ISNULL(SourceTable.SampleSize,TargetTable.SampleSize),
					A2 = ISNULL(SourceTable.A2,TargetTable.A2),
					A3 = ISNULL(SourceTable.A3,TargetTable.A3),
					D2 = ISNULL(SourceTable.D2,TargetTable.D2),
					D3 = ISNULL(SourceTable.D3,TargetTable.D3),
					D4 = ISNULL(SourceTable.D4,TargetTable.D4),
					B3 = ISNULL(SourceTable.B3,TargetTable.B3),
					B4 = ISNULL(SourceTable.B4,TargetTable.B4)
			WHEN NOT MATCHED THEN
				INSERT
					(
						SampleSize,
						A2,
						A3,
						D2,
						D3,
						D4,
						B3,
						B4
					)
				VALUES
					(
							SourceTable.SampleSize,
							SourceTable.A2,
							SourceTable.A3,
							SourceTable.D2,
							SourceTable.D3,
							SourceTable.D4,
							SourceTable.B3,
							SourceTable.B4
					);


			-- Process Delete Table
            MERGE STB_BasicStatisticsConst AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSampleSize IS NULL THEN SampleSize
							    ELSE OldSampleSize
							END AS OldSampleSize,
							SampleSize,
							A2,
							A3,
							D2,
							D3,
							D4,
							B3,
							B4
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldSampleSize INT,
										SampleSize INT,
										A2 NUMERIC(10,4),
										A3 NUMERIC(10,4),
										D2 NUMERIC(10,4),
										D3 NUMERIC(10,4),
										D4 NUMERIC(10,4),
										B3 NUMERIC(10,4),
										B4 NUMERIC(10,4)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SampleSize = SourceTable.SampleSize
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
									OldSampleSize,
									SampleSize,
									A2,
									A3,
									D2,
									D3,
									D4,
									B3,
									B4
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldSampleSize INT,
											 SampleSize INT,
											 A2 NUMERIC(10,4),
											 A3 NUMERIC(10,4),
											 D2 NUMERIC(10,4),
											 D3 NUMERIC(10,4),
											 D4 NUMERIC(10,4),
											 B3 NUMERIC(10,4),
											 B4 NUMERIC(10,4)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldSampleSize IS NULL THEN SampleSize
										ELSE OldSampleSize
									END AS OldSampleSize,
									SampleSize,
									A2,
									A3,
									D2,
									D3,
									D4,
									B3,
									B4
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldSampleSize INT,
											 SampleSize INT,
											 A2 NUMERIC(10,4),
											 A3 NUMERIC(10,4),
											 D2 NUMERIC(10,4),
											 D3 NUMERIC(10,4),
											 D4 NUMERIC(10,4),
											 B3 NUMERIC(10,4),
											 B4 NUMERIC(10,4)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldSampleSize IS NULL THEN SampleSize
										ELSE OldSampleSize
									END AS OldSampleSize,
									SampleSize,
									A2,
									A3,
									D2,
									D3,
									D4,
									B3,
									B4
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldSampleSize INT,
											 SampleSize INT,
											 A2 NUMERIC(10,4),
											 A3 NUMERIC(10,4),
											 D2 NUMERIC(10,4),
											 D3 NUMERIC(10,4),
											 D4 NUMERIC(10,4),
											 B3 NUMERIC(10,4),
											 B4 NUMERIC(10,4)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldSampleSize,
								 @SampleSize,
								 @A2,
								 @A3,
								 @D2,
								 @D3,
								 @D4,
								 @B3,
								 @B4


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_BasicStatisticsConst WHERE SampleSize = @SampleSize) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @SampleSize)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_BasicStatisticsConst', @SampleSize OUTPUT
                    END

                    INSERT INTO STB_BasicStatisticsConst
						(
						    SampleSize,
						    A2,
						    A3,
						    D2,
						    D3,
						    D4,
						    B3,
						    B4
						)
						VALUES
						(
						    @SampleSize,
						    @A2,
						    @A3,
						    @D2,
						    @D3,
						    @D4,
						    @B3,
						    @B4
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_BasicStatisticsConst
						SET
						    SampleSize =   ISNULL(@SampleSize,SampleSize),
						    A2 =   ISNULL(@A2,A2),
						    A3 =   ISNULL(@A3,A3),
						    D2 =   ISNULL(@D2,D2),
						    D3 =   ISNULL(@D3,D3),
						    D4 =   ISNULL(@D4,D4),
						    B3 =   ISNULL(@B3,B3),
						    B4 =   ISNULL(@B4,B4)
						WHERE
						    SampleSize = @OldSampleSize
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_BasicStatisticsConst
						WHERE
						    SampleSize = @OldSampleSize
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

GO

