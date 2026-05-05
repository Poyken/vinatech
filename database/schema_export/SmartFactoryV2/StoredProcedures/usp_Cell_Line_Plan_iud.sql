-- Procedure: usp_Cell_Line_Plan_iud

-- =============================================
-- Author:	    Anonymous()
-- Create date: 2019-04-12
-- Browsable : true
-- Group : 생산관리 > 공정달력 >  [B150] 셀라인목표값설정
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_Cell_Line_Plan_iud]
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
  DECLARE @OldIdx BIGINT
  DECLARE @기준년월 VARCHAR(12)
  DECLARE @라인코드 VARCHAR(14)
  DECLARE @라인명 VARCHAR(20)
  DECLARE @사이즈 VARCHAR(20)
  DECLARE @규격 VARCHAR(30)
  DECLARE @월간계획 INT
  DECLARE @라인별칭 VARCHAR(20)
  DECLARE @특이사항 VARCHAR(200)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(20)
  Declare @Idx BIGINT


	DECLARE @iDoc INT
    
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldIdx,
									기준년월,
									LineCode,
									LineName,
									사이즈,
									규격,
									월간계획,
									라인별칭,
									특이사항,
									RouteCode,
									CompanyCode,
									MaterialCode,
									Idx
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldIdx BIGINT,
											 기준년월 VARCHAR(12),
											 LineCode VARCHAR(14),
											 LineName VARCHAR(20),
											 사이즈 VARCHAR(20),
											 규격 VARCHAR(30),
											 월간계획 INT,
											 라인별칭 VARCHAR(20),
											 특이사항 VARCHAR(200),
											 RouteCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 Idx BIGINT
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldIdx IS NULL THEN Idx
										ELSE OldIdx
									END AS OldIdx,
									기준년월,
									LineCode,
									LineName,
									사이즈,
									규격,
									월간계획,
									라인별칭,
									특이사항,
									RouteCode,
									CompanyCode,
									MaterialCode,
									Idx
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldIdx BIGINT,
											 기준년월 VARCHAR(12),
											 LineCode VARCHAR(14),
											 LineName VARCHAR(20),
											 사이즈 VARCHAR(20),
											 규격 VARCHAR(30),
											 월간계획 INT,
											 라인별칭 VARCHAR(20),
											 특이사항 VARCHAR(200),
											 RouteCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 Idx BIGINT
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldIdx IS NULL THEN Idx
										ELSE OldIdx
									END AS OldIdx,
									기준년월,
									LineCode,
									LineName,
									사이즈,
									규격,
									월간계획,
									라인별칭,
									특이사항,
									RouteCode,
									CompanyCode,
									MaterialCode,
									Idx
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldIdx BIGINT,
											 기준년월 VARCHAR(12),
											 LineCode VARCHAR(14),
											 LineName VARCHAR(20),
											 사이즈 VARCHAR(20),
											 규격 VARCHAR(30),
											 월간계획 INT,
											 라인별칭 VARCHAR(20),
											 특이사항 VARCHAR(200),
											 RouteCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 Idx BIGINT
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldIdx,
								 @기준년월,
								 @라인코드,
								 @라인명,
								 @사이즈,
								 @규격,
								 @월간계획,
								 @라인별칭,
								 @특이사항,
								 @RouteCode,
								 @CompanyCode,
								 @MaterialCode,
								 @Idx


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    INSERT INTO CURLING_PLAN
						(
						    기준년월,
						    라인코드,
						    라인명,
						    사이즈,
						    규격,
						    월간계획,
						    라인별칭,
						    특이사항,
						    RouteCode,
						    CompanyCode,
						    MaterialCode
						)
						VALUES
						(
						    REPLACE(LEFT(@기준년월, 7), '-', ''),
						    @라인코드,
						    @라인명,
						    @사이즈,
						    @규격,
						    @월간계획,
						    @라인별칭,
						    @특이사항,
						    @RouteCode,
						    @CompanyCode,
						    @MaterialCode
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE CURLING_PLAN
						SET
						    기준년월 =   ISNULL(REPLACE(LEFT(@기준년월, 7), '-', ''),기준년월),
						    라인코드 =   ISNULL(@라인코드,라인코드),
						    라인명 =   ISNULL(@라인명,라인명),
						    사이즈 =   ISNULL(@사이즈,사이즈),
						    규격 =   ISNULL(@규격,규격),
						    월간계획 =   ISNULL(@월간계획,월간계획),
						    라인별칭 =   ISNULL(@라인별칭,라인별칭),
						    특이사항 =   ISNULL(@특이사항,특이사항),
						    RouteCode =   ISNULL(@RouteCode,RouteCode),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode)
						WHERE
						    Idx = @OldIdx
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM CURLING_PLAN
						WHERE
						    Idx = @OldIdx
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
GO

