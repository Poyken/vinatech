
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2019-04-12
-- Browsable : true
-- Group : 생산관리 > 공정달력 >  [B150] 셀라인목표값설정
-- Description:	
-- Modified:
-- =============================================


Create PROCEDURE [dbo].[usp_Cell_Line_Plan_iud_20190826]
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
  DECLARE @Old기준년월 VARCHAR(12)
  DECLARE @Old라인코드 VARCHAR(14)
  DECLARE @기준년월 VARCHAR(12)
  DECLARE @라인코드 VARCHAR(14)
  DECLARE @라인명 VARCHAR(20)
  DECLARE @사이즈 VARCHAR(20)
  DECLARE @규격 VARCHAR(30)
  DECLARE @월간계획 INT
  DECLARE @라인별칭 VARCHAR(20)
  DECLARE @특이사항 VARCHAR(200)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'CURLING_PLAN',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE CURLING_PLAN AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN Old기준년월 IS NULL THEN 기준년월
							    ELSE Old기준년월
							END AS Old기준년월,

							CASE
							    WHEN Old라인코드 IS NULL THEN 라인코드
							    ELSE Old라인코드
							END AS Old라인코드,
							기준년월,
							라인코드,
							라인명,
							사이즈,
							규격,
							월간계획,
							라인별칭,
							특이사항
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										Old기준년월 VARCHAR(12),
										Old라인코드 VARCHAR(14),
										기준년월 VARCHAR(12),
										라인코드 VARCHAR(14),
										라인명 VARCHAR(20),
										사이즈 VARCHAR(20),
										규격 VARCHAR(30),
										월간계획 INT,
										라인별칭 VARCHAR(20),
										특이사항 VARCHAR(200)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.기준년월 = SourceTable.기준년월 AND
					TargetTable.라인코드 = SourceTable.라인코드
				)

			WHEN MATCHED THEN
				UPDATE SET
					기준년월 = ISNULL(SourceTable.기준년월,TargetTable.기준년월),
					라인코드 = ISNULL(SourceTable.라인코드,TargetTable.라인코드),
					라인명 = ISNULL(SourceTable.라인명,TargetTable.라인명),
					사이즈 = ISNULL(SourceTable.사이즈,TargetTable.사이즈),
					규격 = ISNULL(SourceTable.규격,TargetTable.규격),
					월간계획 = ISNULL(SourceTable.월간계획,TargetTable.월간계획),
					특이사항 = ISNULL(SourceTable.특이사항,TargetTable.특이사항)
			WHEN NOT MATCHED THEN

			-- INSERT부분
				INSERT
					(
						기준년월,
						라인코드,
						라인명,
						사이즈,
						규격,
						월간계획,
						특이사항
					)
				VALUES
					(
							SourceTable.기준년월,
							SourceTable.라인코드,
							SourceTable.라인명,
							SourceTable.사이즈,
							SourceTable.규격,
							SourceTable.월간계획,
							SourceTable.특이사항
					);


			-- Process Update Table
            MERGE CURLING_PLAN AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN Old기준년월 IS NULL THEN 기준년월
							    ELSE Old기준년월
							END AS Old기준년월,
							CASE
							    WHEN Old라인코드 IS NULL THEN 라인코드
							    ELSE Old라인코드
							END AS Old라인코드,
							기준년월,
							라인코드,
							라인명,
							사이즈,
							규격,
							월간계획,
							라인별칭,
							특이사항
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										Old기준년월 VARCHAR(12),
										Old라인코드 VARCHAR(14),
										기준년월 VARCHAR(12),
										라인코드 VARCHAR(14),
										라인명 VARCHAR(20),
										사이즈 VARCHAR(20),
										규격 VARCHAR(30),
										월간계획 INT,
										라인별칭 VARCHAR(20),
										특이사항 VARCHAR(200)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.기준년월 = SourceTable.Old기준년월 AND
					TargetTable.라인코드 = SourceTable.Old라인코드
				)

			WHEN MATCHED THEN
				UPDATE SET
					기준년월 = ISNULL(SourceTable.기준년월,TargetTable.기준년월),
					라인코드 = ISNULL(SourceTable.라인코드,TargetTable.라인코드),
					라인명 = ISNULL(SourceTable.라인명,TargetTable.라인명),
					사이즈 = ISNULL(SourceTable.사이즈,TargetTable.사이즈),
					규격 = ISNULL(SourceTable.규격,TargetTable.규격),
					월간계획 = ISNULL(SourceTable.월간계획,TargetTable.월간계획),
					특이사항 = ISNULL(SourceTable.특이사항,TargetTable.특이사항)
			WHEN NOT MATCHED THEN
				INSERT
					(
						기준년월,
						라인코드,
						라인명,
						사이즈,
						규격,
						월간계획,
						특이사항
					)
				VALUES
					(
							SourceTable.기준년월,
							SourceTable.라인코드,
							SourceTable.라인명,
							SourceTable.사이즈,
							SourceTable.규격,
							SourceTable.월간계획,
							SourceTable.특이사항
					);


			-- Process Delete Table
            MERGE CURLING_PLAN AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN Old기준년월 IS NULL THEN 기준년월
							    ELSE Old기준년월
							END AS Old기준년월,
							CASE
							    WHEN Old라인코드 IS NULL THEN 라인코드
							    ELSE Old라인코드
							END AS Old라인코드,
							기준년월,
							라인코드,
							라인명,
							사이즈,
							규격,
							월간계획,
							라인별칭,
							특이사항
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										Old기준년월 VARCHAR(12),
										Old라인코드 VARCHAR(14),
										기준년월 VARCHAR(12),
										라인코드 VARCHAR(14),
										라인명 VARCHAR(20),
										사이즈 VARCHAR(20),
										규격 VARCHAR(30),
										월간계획 INT,
										라인별칭 VARCHAR(20),
										특이사항 VARCHAR(200)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.기준년월 = SourceTable.기준년월 AND
					TargetTable.라인코드 = SourceTable.라인코드
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
									Old기준년월,
									Old라인코드,
									기준년월,
									라인코드,
									라인명,
									사이즈,
									규격,
									월간계획,
									라인별칭,
									특이사항
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 Old기준년월 VARCHAR(12),
											 Old라인코드 VARCHAR(14),
											 기준년월 VARCHAR(12),
											 라인코드 VARCHAR(14),
											 라인명 VARCHAR(20),
											 사이즈 VARCHAR(20),
											 규격 VARCHAR(30),
											 월간계획 INT,
											 라인별칭 VARCHAR(20),
											 특이사항 VARCHAR(200)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN Old기준년월 IS NULL THEN 기준년월
										ELSE Old기준년월
									END AS Old기준년월,
									CASE 
										WHEN Old라인코드 IS NULL THEN 라인코드
										ELSE Old라인코드
									END AS Old라인코드,
									기준년월,
									라인코드,
									라인명,
									사이즈,
									규격,
									월간계획,
									라인별칭,
									특이사항
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 Old기준년월 VARCHAR(12),
											 Old라인코드 VARCHAR(14),
											 기준년월 VARCHAR(12),
											 라인코드 VARCHAR(14),
											 라인명 VARCHAR(20),
											 사이즈 VARCHAR(20),
											 규격 VARCHAR(30),
											 월간계획 INT,
											 라인별칭 VARCHAR(20),
											 특이사항 VARCHAR(200)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN Old기준년월 IS NULL THEN 기준년월
										ELSE Old기준년월
									END AS Old기준년월,
									CASE 
										WHEN Old라인코드 IS NULL THEN 라인코드
										ELSE Old라인코드
									END AS Old라인코드,
									기준년월,
									라인코드,
									라인명,
									사이즈,
									규격,
									월간계획,
									라인별칭,
									특이사항
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 Old기준년월 VARCHAR(12),
											 Old라인코드 VARCHAR(14),
											 기준년월 VARCHAR(12),
											 라인코드 VARCHAR(14),
											 라인명 VARCHAR(20),
											 사이즈 VARCHAR(20),
											 규격 VARCHAR(30),
											 월간계획 INT,
											 라인별칭 VARCHAR(20),
											 특이사항 VARCHAR(200)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @Old기준년월,
								 @Old라인코드,
								 @기준년월,
								 @라인코드,
								 @라인명,
								 @사이즈,
								 @규격,
								 @월간계획,
								 @라인별칭,
								 @특이사항


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM CURLING_PLAN WHERE 기준년월 = @기준년월 AND 라인코드 = @라인코드) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @기준년월)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'CURLING_PLAN',@기준년월 OUTPUT
                    END

                    INSERT INTO CURLING_PLAN
						(
						    기준년월,
						    라인코드,
						    라인명,
						    사이즈,
						    규격,
						    월간계획,
						    특이사항
						)
						VALUES
						(
						    @기준년월,
						    @라인코드,
						    @라인명,
						    @사이즈,
						    @규격,
						    @월간계획,
						    @특이사항
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE CURLING_PLAN
						SET
						    기준년월 =   ISNULL(@기준년월,기준년월),
						    라인코드 =   ISNULL(@라인코드,라인코드),
						    라인명 =   ISNULL(@라인명,라인명),
						    사이즈 =   ISNULL(@사이즈,사이즈),
						    규격 =   ISNULL(@규격,규격),
						    월간계획 =   ISNULL(@월간계획,월간계획),
						    특이사항 =   ISNULL(@특이사항,특이사항)
						WHERE
						    기준년월 = @Old기준년월 AND
						    라인코드 = @Old라인코드
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM CURLING_PLAN
						WHERE
						    기준년월 = @Old기준년월 AND
						    라인코드 = @Old라인코드
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
