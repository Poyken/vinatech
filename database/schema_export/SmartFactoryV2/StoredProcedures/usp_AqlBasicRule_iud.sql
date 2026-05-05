-- Procedure: usp_AqlBasicRule_iud
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2017-06-29
-- Browsable : true
-- Group : SmartCTQ
-- Description:	샘플합격품질수준을 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_AqlBasicRule_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pUtcOffset INT
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
  DECLARE @OldAQL VARCHAR(10)
  DECLARE @OldSampleChar VARCHAR(1)
  DECLARE @AQL VARCHAR(10)
  DECLARE @SampleChar VARCHAR(1)
  DECLARE @MaxAllowDefectQty INT
  DECLARE @IsBasicRule BIT
  DECLARE @CreateDateTime VARCHAR(19)
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime VARCHAR(19)
  DECLARE @ChangeUserID VARCHAR(20)

	DECLARE @NowDate VARCHAR(10) = CONVERT(VARCHAR,  DATEADD(MINUTE,@pUtcOffset,GETDATE()), 120)
	DECLARE @NowDateTime VARCHAR(19) = CONVERT(VARCHAR,  DATEADD(MINUTE,@pUtcOffset,GETDATE()), 120)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_AqlBasicRule',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_AqlBasicRule AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldAQL IS NULL THEN AQL
							    ELSE OldAQL
							END AS OldAQL,
							CASE
							    WHEN OldSampleChar IS NULL THEN SampleChar
							    ELSE OldSampleChar
							END AS OldSampleChar,
							AQL,
							SampleChar,
							MaxAllowDefectQty,
							IsBasicRule,
							@NowDateTime AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							@NowDateTime AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldAQL VARCHAR(10),
										OldSampleChar VARCHAR(1),
										AQL VARCHAR(10),
										SampleChar VARCHAR(1),
										MaxAllowDefectQty INT,
										IsBasicRule BIT,
										CreateDateTime VARCHAR(19),
										CreateUserID VARCHAR(20),
										ChangeDateTime VARCHAR(19),
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.AQL = SourceTable.AQL AND
					TargetTable.SampleChar = SourceTable.SampleChar
				)

			WHEN MATCHED THEN
				UPDATE SET
					AQL = ISNULL(SourceTable.AQL,TargetTable.AQL),
					SampleChar = ISNULL(SourceTable.SampleChar,TargetTable.SampleChar),
					MaxAllowDefectQty = ISNULL(SourceTable.MaxAllowDefectQty,TargetTable.MaxAllowDefectQty),
					IsBasicRule = ISNULL(SourceTable.IsBasicRule,TargetTable.IsBasicRule),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						AQL,
						SampleChar,
						MaxAllowDefectQty,
						IsBasicRule,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.AQL,
							SourceTable.SampleChar,
							SourceTable.MaxAllowDefectQty,
							SourceTable.IsBasicRule,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_AqlBasicRule AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldAQL IS NULL THEN AQL
							    ELSE OldAQL
							END AS OldAQL,
							CASE
							    WHEN OldSampleChar IS NULL THEN SampleChar
							    ELSE OldSampleChar
							END AS OldSampleChar,
							AQL,
							SampleChar,
							MaxAllowDefectQty,
							IsBasicRule,
							@NowDateTime AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							@NowDateTime AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldAQL VARCHAR(10),
										OldSampleChar VARCHAR(1),
										AQL VARCHAR(10),
										SampleChar VARCHAR(1),
										MaxAllowDefectQty INT,
										IsBasicRule BIT,
										CreateDateTime VARCHAR(19),
										CreateUserID VARCHAR(20),
										ChangeDateTime VARCHAR(19),
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.AQL = SourceTable.OldAQL AND
					TargetTable.SampleChar = SourceTable.OldSampleChar
				)

			WHEN MATCHED THEN
				UPDATE SET
					AQL = ISNULL(SourceTable.AQL,TargetTable.AQL),
					SampleChar = ISNULL(SourceTable.SampleChar,TargetTable.SampleChar),
					MaxAllowDefectQty = ISNULL(SourceTable.MaxAllowDefectQty,TargetTable.MaxAllowDefectQty),
					IsBasicRule = ISNULL(SourceTable.IsBasicRule,TargetTable.IsBasicRule),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						AQL,
						SampleChar,
						MaxAllowDefectQty,
						IsBasicRule,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.AQL,
							SourceTable.SampleChar,
							SourceTable.MaxAllowDefectQty,
							SourceTable.IsBasicRule,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_AqlBasicRule AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldAQL IS NULL THEN AQL
							    ELSE OldAQL
							END AS OldAQL,
							CASE
							    WHEN OldSampleChar IS NULL THEN SampleChar
							    ELSE OldSampleChar
							END AS OldSampleChar,
							AQL,
							SampleChar,
							MaxAllowDefectQty,
							IsBasicRule,
							@NowDateTime AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							@NowDateTime AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldAQL VARCHAR(10),
										OldSampleChar VARCHAR(1),
										AQL VARCHAR(10),
										SampleChar VARCHAR(1),
										MaxAllowDefectQty INT,
										IsBasicRule BIT,
										CreateDateTime VARCHAR(19),
										CreateUserID VARCHAR(20),
										ChangeDateTime VARCHAR(19),
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.AQL = SourceTable.AQL AND
					TargetTable.SampleChar = SourceTable.SampleChar
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
									OldAQL,
									OldSampleChar,
									AQL,
									SampleChar,
									MaxAllowDefectQty,
									IsBasicRule,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldAQL VARCHAR(10),
											 OldSampleChar VARCHAR(1),
											 AQL VARCHAR(10),
											 SampleChar VARCHAR(1),
											 MaxAllowDefectQty INT,
											 IsBasicRule BIT,
											 CreateDateTime VARCHAR(19),
											 CreateUserID VARCHAR(20),
											 ChangeDateTime VARCHAR(19),
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldAQL IS NULL THEN AQL
										ELSE OldAQL
									END AS OldAQL,
									CASE 
										WHEN OldSampleChar IS NULL THEN SampleChar
										ELSE OldSampleChar
									END AS OldSampleChar,
									AQL,
									SampleChar,
									MaxAllowDefectQty,
									IsBasicRule,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldAQL VARCHAR(10),
											 OldSampleChar VARCHAR(1),
											 AQL VARCHAR(10),
											 SampleChar VARCHAR(1),
											 MaxAllowDefectQty INT,
											 IsBasicRule BIT,
											 CreateDateTime VARCHAR(19),
											 CreateUserID VARCHAR(20),
											 ChangeDateTime VARCHAR(19),
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldAQL IS NULL THEN AQL
										ELSE OldAQL
									END AS OldAQL,
									CASE 
										WHEN OldSampleChar IS NULL THEN SampleChar
										ELSE OldSampleChar
									END AS OldSampleChar,
									AQL,
									SampleChar,
									MaxAllowDefectQty,
									IsBasicRule,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldAQL VARCHAR(10),
											 OldSampleChar VARCHAR(1),
											 AQL VARCHAR(10),
											 SampleChar VARCHAR(1),
											 MaxAllowDefectQty INT,
											 IsBasicRule BIT,
											 CreateDateTime VARCHAR(19),
											 CreateUserID VARCHAR(20),
											 ChangeDateTime VARCHAR(19),
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldAQL,
								 @OldSampleChar,
								 @AQL,
								 @SampleChar,
								 @MaxAllowDefectQty,
								 @IsBasicRule,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_AqlBasicRule WHERE AQL = @AQL AND SampleChar = @SampleChar) BEGIN
						--RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @AQL)

						 UPDATE STB_AqlBasicRule
						SET
						    AQL =   ISNULL(@AQL,AQL),
						    SampleChar =   ISNULL(@SampleChar,SampleChar),
						    MaxAllowDefectQty =   ISNULL(@MaxAllowDefectQty,MaxAllowDefectQty),
						    IsBasicRule =   ISNULL(@IsBasicRule,IsBasicRule),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = @NowDateTime,
						    ChangeUserID = @pProcessUserID
						WHERE
						    AQL = @OldAQL AND
						    SampleChar = @OldSampleChar

					END ELSE BEGIN

						IF @IsAutoKey = 1 BEGIN
							EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_AqlBasicRule', @AQL OUTPUT
						END

						INSERT INTO STB_AqlBasicRule
							(
								AQL,
								SampleChar,
								MaxAllowDefectQty,
								IsBasicRule,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID
							)
							VALUES
							(
								@AQL,
								@SampleChar,
								@MaxAllowDefectQty,
								@IsBasicRule,
								@NowDateTime, 
								@pProcessUserID,
								@ChangeDateTime,
								@ChangeUserID
							)
						END

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_AqlBasicRule
						SET
						    AQL =   ISNULL(@AQL,AQL),
						    SampleChar =   ISNULL(@SampleChar,SampleChar),
						    MaxAllowDefectQty =   ISNULL(@MaxAllowDefectQty,MaxAllowDefectQty),
						    IsBasicRule =   ISNULL(@IsBasicRule,IsBasicRule),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = @NowDateTime,
						    ChangeUserID = @pProcessUserID
						WHERE
						    AQL = @OldAQL AND
						    SampleChar = @OldSampleChar
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_AqlBasicRule
						WHERE
						    AQL = @AQL AND
						    SampleChar = @SampleChar
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

