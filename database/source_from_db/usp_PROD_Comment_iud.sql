
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2019-10-28
-- Browsable : true
-- Group : 생산실적
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_PROD_Comment_iud]
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
  DECLARE @Old사이즈 VARCHAR(20)
  DECLARE @OldCompanyCode VARCHAR(20)
  DECLARE @사이즈 VARCHAR(20)
  DECLARE @Comment VARCHAR(200)
  DECLARE @CompanyCode VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'PROD_Comment',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE PROD_Comment AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN Old사이즈 IS NULL THEN 사이즈
							    ELSE Old사이즈
							END AS Old사이즈,
							CASE
							    WHEN OldCompanyCode IS NULL THEN CompanyCode
							    ELSE OldCompanyCode
							END AS OldCompanyCode,
							사이즈,
							Comment,
							CompanyCode
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										Old사이즈 VARCHAR(20),
										OldCompanyCode VARCHAR(20),
										사이즈 VARCHAR(20),
										Comment VARCHAR(200),
										CompanyCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.사이즈 = SourceTable.사이즈 AND
					TargetTable.CompanyCode = SourceTable.CompanyCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					사이즈 = ISNULL(SourceTable.사이즈,TargetTable.사이즈),
					Comment = ISNULL(SourceTable.Comment,TargetTable.Comment),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						사이즈,
						Comment,
						CompanyCode
					)
				VALUES
					(
							SourceTable.사이즈,
							SourceTable.Comment,
							SourceTable.CompanyCode
					);


			-- Process Update Table
            MERGE PROD_Comment AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN Old사이즈 IS NULL THEN 사이즈
							    ELSE Old사이즈
							END AS Old사이즈,
							CASE
							    WHEN OldCompanyCode IS NULL THEN CompanyCode
							    ELSE OldCompanyCode
							END AS OldCompanyCode,
							사이즈,
							Comment,
							CompanyCode
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										Old사이즈 VARCHAR(20),
										OldCompanyCode VARCHAR(20),
										사이즈 VARCHAR(20),
										Comment VARCHAR(200),
										CompanyCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.사이즈 = SourceTable.Old사이즈 AND
					TargetTable.CompanyCode = SourceTable.OldCompanyCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					사이즈 = ISNULL(SourceTable.사이즈,TargetTable.사이즈),
					Comment = ISNULL(SourceTable.Comment,TargetTable.Comment),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						사이즈,
						Comment,
						CompanyCode
					)
				VALUES
					(
							SourceTable.사이즈,
							SourceTable.Comment,
							SourceTable.CompanyCode
					);


			-- Process Delete Table
            MERGE PROD_Comment AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN Old사이즈 IS NULL THEN 사이즈
							    ELSE Old사이즈
							END AS Old사이즈,
							CASE
							    WHEN OldCompanyCode IS NULL THEN CompanyCode
							    ELSE OldCompanyCode
							END AS OldCompanyCode,
							사이즈,
							Comment,
							CompanyCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										Old사이즈 VARCHAR(20),
										OldCompanyCode VARCHAR(20),
										사이즈 VARCHAR(20),
										Comment VARCHAR(200),
										CompanyCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.사이즈 = SourceTable.사이즈 AND
					TargetTable.CompanyCode = SourceTable.CompanyCode
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
									Old사이즈,
									OldCompanyCode,
									사이즈,
									Comment,
									CompanyCode
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 Old사이즈 VARCHAR(20),
											 OldCompanyCode VARCHAR(20),
											 사이즈 VARCHAR(20),
											 Comment VARCHAR(200),
											 CompanyCode VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN Old사이즈 IS NULL THEN 사이즈
										ELSE Old사이즈
									END AS Old사이즈,
									CASE 
										WHEN OldCompanyCode IS NULL THEN CompanyCode
										ELSE OldCompanyCode
									END AS OldCompanyCode,
									사이즈,
									Comment,
									CompanyCode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 Old사이즈 VARCHAR(20),
											 OldCompanyCode VARCHAR(20),
											 사이즈 VARCHAR(20),
											 Comment VARCHAR(200),
											 CompanyCode VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN Old사이즈 IS NULL THEN 사이즈
										ELSE Old사이즈
									END AS Old사이즈,
									CASE 
										WHEN OldCompanyCode IS NULL THEN CompanyCode
										ELSE OldCompanyCode
									END AS OldCompanyCode,
									사이즈,
									Comment,
									CompanyCode
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 Old사이즈 VARCHAR(20),
											 OldCompanyCode VARCHAR(20),
											 사이즈 VARCHAR(20),
											 Comment VARCHAR(200),
											 CompanyCode VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @Old사이즈,
								 @OldCompanyCode,
								 @사이즈,
								 @Comment,
								 @CompanyCode


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM PROD_Comment WHERE 사이즈 = @사이즈 AND CompanyCode = @CompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @사이즈)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'PROD_Comment',@사이즈 OUTPUT
                    END

                    INSERT INTO PROD_Comment
						(
						    사이즈,
						    Comment,
						    CompanyCode
						)
						VALUES
						(
						    @사이즈,
						    @Comment,
						    @CompanyCode
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE PROD_Comment
						SET
						    사이즈 =   ISNULL(@사이즈,사이즈),
						    Comment =   ISNULL(@Comment,Comment),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode)
						WHERE
						    사이즈 = @Old사이즈 AND
						    CompanyCode = @OldCompanyCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM PROD_Comment
						WHERE
						    사이즈 = @Old사이즈 AND
						    CompanyCode = @OldCompanyCode
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
