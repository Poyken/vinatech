-- Procedure: usp_UnitConverter_iud


-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 공통
-- Description:	단위변환정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_UnitConverter_iud]
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
  DECLARE @OldTargetUnit VARCHAR(20)
  DECLARE @TargetUnit VARCHAR(20)
  DECLARE @BaseUnit VARCHAR(20)
  DECLARE @ConvertRate NUMERIC(38,19)
  DECLARE @UnitType VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_UnitConverter',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_UnitConverter AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldTargetUnit IS NULL THEN TargetUnit
							    ELSE OldTargetUnit
							END AS OldTargetUnit,
							TargetUnit,
							BaseUnit,
							ConvertRate,
							UnitType
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldTargetUnit VARCHAR(20),
										TargetUnit VARCHAR(20),
										BaseUnit VARCHAR(20),
										ConvertRate NUMERIC(38,19),
										UnitType VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.TargetUnit = SourceTable.TargetUnit
				)

			WHEN MATCHED THEN
				UPDATE SET
					TargetUnit = ISNULL(SourceTable.TargetUnit,TargetTable.TargetUnit),
					BaseUnit = ISNULL(SourceTable.BaseUnit,TargetTable.BaseUnit),
					ConvertRate = ISNULL(SourceTable.ConvertRate,TargetTable.ConvertRate),
					UnitType = ISNULL(SourceTable.UnitType,TargetTable.UnitType)
			WHEN NOT MATCHED THEN
				INSERT
					(
						TargetUnit,
						BaseUnit,
						ConvertRate,
						UnitType
					)
				VALUES
					(
							SourceTable.TargetUnit,
							SourceTable.BaseUnit,
							SourceTable.ConvertRate,
							SourceTable.UnitType
					);


			-- Process Update Table
            MERGE STB_UnitConverter AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldTargetUnit IS NULL THEN TargetUnit
							    ELSE OldTargetUnit
							END AS OldTargetUnit,
							TargetUnit,
							BaseUnit,
							ConvertRate,
							UnitType
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldTargetUnit VARCHAR(20),
										TargetUnit VARCHAR(20),
										BaseUnit VARCHAR(20),
										ConvertRate NUMERIC(38,19),
										UnitType VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.TargetUnit = SourceTable.OldTargetUnit
				)

			WHEN MATCHED THEN
				UPDATE SET
					TargetUnit = ISNULL(SourceTable.TargetUnit,TargetTable.TargetUnit),
					BaseUnit = ISNULL(SourceTable.BaseUnit,TargetTable.BaseUnit),
					ConvertRate = ISNULL(SourceTable.ConvertRate,TargetTable.ConvertRate),
					UnitType = ISNULL(SourceTable.UnitType,TargetTable.UnitType)
			WHEN NOT MATCHED THEN
				INSERT
					(
						TargetUnit,
						BaseUnit,
						ConvertRate,
						UnitType
					)
				VALUES
					(
							SourceTable.TargetUnit,
							SourceTable.BaseUnit,
							SourceTable.ConvertRate,
							SourceTable.UnitType
					);


			-- Process Delete Table
            MERGE STB_UnitConverter AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldTargetUnit IS NULL THEN TargetUnit
							    ELSE OldTargetUnit
							END AS OldTargetUnit,
							TargetUnit,
							BaseUnit,
							ConvertRate,
							UnitType
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldTargetUnit VARCHAR(20),
										TargetUnit VARCHAR(20),
										BaseUnit VARCHAR(20),
										ConvertRate NUMERIC(38,19),
										UnitType VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.TargetUnit = SourceTable.TargetUnit
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
									OldTargetUnit,
									TargetUnit,
									BaseUnit,
									ConvertRate,
									UnitType
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldTargetUnit VARCHAR(20),
											 TargetUnit VARCHAR(20),
											 BaseUnit VARCHAR(20),
											 ConvertRate NUMERIC(38,19),
											 UnitType VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldTargetUnit IS NULL THEN TargetUnit
										ELSE OldTargetUnit
									END AS OldTargetUnit,
									TargetUnit,
									BaseUnit,
									ConvertRate,
									UnitType
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldTargetUnit VARCHAR(20),
											 TargetUnit VARCHAR(20),
											 BaseUnit VARCHAR(20),
											 ConvertRate NUMERIC(38,19),
											 UnitType VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldTargetUnit IS NULL THEN TargetUnit
										ELSE OldTargetUnit
									END AS OldTargetUnit,
									TargetUnit,
									BaseUnit,
									ConvertRate,
									UnitType
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldTargetUnit VARCHAR(20),
											 TargetUnit VARCHAR(20),
											 BaseUnit VARCHAR(20),
											 ConvertRate NUMERIC(38,19),
											 UnitType VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldTargetUnit,
								 @TargetUnit,
								 @BaseUnit,
								 @ConvertRate,
								 @UnitType


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_UnitConverter WHERE TargetUnit = @TargetUnit) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @TargetUnit)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_UnitConverter',@TargetUnit OUTPUT
                    END

                    INSERT INTO STB_UnitConverter
						(
						    TargetUnit,
						    BaseUnit,
						    ConvertRate,
						    UnitType
						)
						VALUES
						(
						    @TargetUnit,
						    @BaseUnit,
						    @ConvertRate,
						    @UnitType
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_UnitConverter
						SET
						    TargetUnit =   ISNULL(@TargetUnit,TargetUnit),
						    BaseUnit =   ISNULL(@BaseUnit,BaseUnit),
						    ConvertRate =   ISNULL(@ConvertRate,ConvertRate),
						    UnitType =   ISNULL(@UnitType,UnitType)
						WHERE
						    TargetUnit = @OldTargetUnit
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_UnitConverter
						WHERE
						    TargetUnit = @OldTargetUnit
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

