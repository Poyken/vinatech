-- =============================================
-- Author:	    Anonymous()
-- Create date: 2017-06-29
-- Browsable : true
-- Group : SmartCTQ
-- Description:	샘플검사수준정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_InspectionLevel_iud]
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
  DECLARE @OldInspectionLevelSeq VARCHAR(20)
  DECLARE @InspectionLevelSeq VARCHAR(20)
  DECLARE @InspectionLevel VARCHAR(20)
  DECLARE @MinGrQty BIGINT
  DECLARE @MaxGrQty BIGINT
  DECLARE @SampleChar VARCHAR(1)
  DECLARE @SampleQty BIGINT
  DECLARE @CreateDateTime VARCHAR(19)
  DECLARE @CreateUserID VARCHAR(50)
  DECLARE @ChangeDateTime VARCHAR(19)
  DECLARE @ChangeUserID VARCHAR(50)


	DECLARE @NowDate VARCHAR(10) = CONVERT(VARCHAR,  DATEADD(MINUTE,@pUtcOffset,GETDATE()), 120)
	DECLARE @NowDateTime VARCHAR(19) = CONVERT(VARCHAR,  DATEADD(MINUTE,@pUtcOffset,GETDATE()), 120)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_InspectionLevel',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_InspectionLevel AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldInspectionLevelSeq IS NULL THEN InspectionLevelSeq
							    ELSE OldInspectionLevelSeq
							END AS OldInspectionLevelSeq,
							InspectionLevelSeq,
							InspectionLevel,
							MinGrQty,
							MaxGrQty,
							SampleChar,
							SampleQty,
							@NowDateTime AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							@NowDateTime AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldInspectionLevelSeq VARCHAR(20),
										InspectionLevelSeq VARCHAR(20),
										InspectionLevel VARCHAR(20),
										MinGrQty BIGINT,
										MaxGrQty BIGINT,
										SampleChar VARCHAR(1),
										SampleQty BIGINT,
										CreateDateTime VARCHAR(19),
										CreateUserID VARCHAR(50),
										ChangeDateTime VARCHAR(19),
										ChangeUserID VARCHAR(50)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.InspectionLevelSeq = SourceTable.InspectionLevelSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					InspectionLevelSeq = ISNULL(SourceTable.InspectionLevelSeq,TargetTable.InspectionLevelSeq),
					InspectionLevel = ISNULL(SourceTable.InspectionLevel,TargetTable.InspectionLevel),
					MinGrQty = ISNULL(SourceTable.MinGrQty,TargetTable.MinGrQty),
					MaxGrQty = ISNULL(SourceTable.MaxGrQty,TargetTable.MaxGrQty),
					SampleChar = ISNULL(SourceTable.SampleChar,TargetTable.SampleChar),
					SampleQty = ISNULL(SourceTable.SampleQty,TargetTable.SampleQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						InspectionLevelSeq,
						InspectionLevel,
						MinGrQty,
						MaxGrQty,
						SampleChar,
						SampleQty,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.InspectionLevelSeq,
							SourceTable.InspectionLevel,
							SourceTable.MinGrQty,
							SourceTable.MaxGrQty,
							SourceTable.SampleChar,
							SourceTable.SampleQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_InspectionLevel AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldInspectionLevelSeq IS NULL THEN InspectionLevelSeq
							    ELSE OldInspectionLevelSeq
							END AS OldInspectionLevelSeq,
							InspectionLevelSeq,
							InspectionLevel,
							MinGrQty,
							MaxGrQty,
							SampleChar,
							SampleQty,
							@NowDateTime AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							@NowDateTime AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldInspectionLevelSeq VARCHAR(20),
										InspectionLevelSeq VARCHAR(20),
										InspectionLevel VARCHAR(20),
										MinGrQty BIGINT,
										MaxGrQty BIGINT,
										SampleChar VARCHAR(1),
										SampleQty BIGINT,
										CreateDateTime VARCHAR(19),
										CreateUserID VARCHAR(50),
										ChangeDateTime VARCHAR(19),
										ChangeUserID VARCHAR(50)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.InspectionLevelSeq = SourceTable.OldInspectionLevelSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					InspectionLevelSeq = ISNULL(SourceTable.InspectionLevelSeq,TargetTable.InspectionLevelSeq),
					InspectionLevel = ISNULL(SourceTable.InspectionLevel,TargetTable.InspectionLevel),
					MinGrQty = ISNULL(SourceTable.MinGrQty,TargetTable.MinGrQty),
					MaxGrQty = ISNULL(SourceTable.MaxGrQty,TargetTable.MaxGrQty),
					SampleChar = ISNULL(SourceTable.SampleChar,TargetTable.SampleChar),
					SampleQty = ISNULL(SourceTable.SampleQty,TargetTable.SampleQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						InspectionLevelSeq,
						InspectionLevel,
						MinGrQty,
						MaxGrQty,
						SampleChar,
						SampleQty,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.InspectionLevelSeq,
							SourceTable.InspectionLevel,
							SourceTable.MinGrQty,
							SourceTable.MaxGrQty,
							SourceTable.SampleChar,
							SourceTable.SampleQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_InspectionLevel AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldInspectionLevelSeq IS NULL THEN InspectionLevelSeq
							    ELSE OldInspectionLevelSeq
							END AS OldInspectionLevelSeq,
							InspectionLevelSeq,
							InspectionLevel,
							MinGrQty,
							MaxGrQty,
							SampleChar,
							SampleQty,
							@NowDateTime AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							@NowDateTime AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldInspectionLevelSeq VARCHAR(20),
										InspectionLevelSeq VARCHAR(20),
										InspectionLevel VARCHAR(20),
										MinGrQty BIGINT,
										MaxGrQty BIGINT,
										SampleChar VARCHAR(1),
										SampleQty BIGINT,
										CreateDateTime VARCHAR(19),
										CreateUserID VARCHAR(50),
										ChangeDateTime VARCHAR(19),
										ChangeUserID VARCHAR(50)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.InspectionLevelSeq = SourceTable.InspectionLevelSeq
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
									OldInspectionLevelSeq,
									InspectionLevelSeq,
									InspectionLevel,
									MinGrQty,
									MaxGrQty,
									SampleChar,
									SampleQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldInspectionLevelSeq VARCHAR(20),
											 InspectionLevelSeq VARCHAR(20),
											 InspectionLevel VARCHAR(20),
											 MinGrQty BIGINT,
											 MaxGrQty BIGINT,
											 SampleChar VARCHAR(1),
											 SampleQty BIGINT,
											 CreateDateTime VARCHAR(19),
											 CreateUserID VARCHAR(50),
											 ChangeDateTime VARCHAR(19),
											 ChangeUserID VARCHAR(50)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldInspectionLevelSeq IS NULL THEN InspectionLevelSeq
										ELSE OldInspectionLevelSeq
									END AS OldInspectionLevelSeq,
									InspectionLevelSeq,
									InspectionLevel,
									MinGrQty,
									MaxGrQty,
									SampleChar,
									SampleQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldInspectionLevelSeq VARCHAR(20),
											 InspectionLevelSeq VARCHAR(20),
											 InspectionLevel VARCHAR(20),
											 MinGrQty BIGINT,
											 MaxGrQty BIGINT,
											 SampleChar VARCHAR(1),
											 SampleQty BIGINT,
											 CreateDateTime VARCHAR(19),
											 CreateUserID VARCHAR(50),
											 ChangeDateTime VARCHAR(19),
											 ChangeUserID VARCHAR(50)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldInspectionLevelSeq IS NULL THEN InspectionLevelSeq
										ELSE OldInspectionLevelSeq
									END AS OldInspectionLevelSeq,
									InspectionLevelSeq,
									InspectionLevel,
									MinGrQty,
									MaxGrQty,
									SampleChar,
									SampleQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldInspectionLevelSeq VARCHAR(20),
											 InspectionLevelSeq VARCHAR(20),
											 InspectionLevel VARCHAR(20),
											 MinGrQty BIGINT,
											 MaxGrQty BIGINT,
											 SampleChar VARCHAR(1),
											 SampleQty BIGINT,
											 CreateDateTime VARCHAR(19),
											 CreateUserID VARCHAR(50),
											 ChangeDateTime VARCHAR(19),
											 ChangeUserID VARCHAR(50)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldInspectionLevelSeq,
								 @InspectionLevelSeq,
								 @InspectionLevel,
								 @MinGrQty,
								 @MaxGrQty,
								 @SampleChar,
								 @SampleQty,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_InspectionLevel WHERE InspectionLevelSeq = @InspectionLevelSeq) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @InspectionLevelSeq)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_InspectionLevel', @InspectionLevelSeq OUTPUT
                    END

                    INSERT INTO STB_InspectionLevel
						(
						    InspectionLevelSeq,
						    InspectionLevel,
						    MinGrQty,
						    MaxGrQty,
						    SampleChar,
						    SampleQty,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @InspectionLevelSeq,
						    @InspectionLevel,
						    @MinGrQty,
						    @MaxGrQty,
						    @SampleChar,
						    @SampleQty,
						    @NowDateTime,
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_InspectionLevel
						SET
						    InspectionLevelSeq =   ISNULL(@InspectionLevelSeq,InspectionLevelSeq),
						    InspectionLevel =   ISNULL(@InspectionLevel,InspectionLevel),
						    MinGrQty =   ISNULL(@MinGrQty,MinGrQty),
						    MaxGrQty =   ISNULL(@MaxGrQty,MaxGrQty),
						    SampleChar =   ISNULL(@SampleChar,SampleChar),
						    SampleQty =   ISNULL(@SampleQty,SampleQty),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = @NowDateTime,
						    ChangeUserID = @pProcessUserID
						WHERE
						    InspectionLevelSeq = @OldInspectionLevelSeq
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_InspectionLevel
						WHERE
						    InspectionLevelSeq = @InspectionLevelSeq
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
