
-- =============================================
-- Author: kilee@vina.co.kr
-- Create date: 2019-05-20
-- Browsable : true
-- Group : 생산관리 > [B155] 사이즈별 생산목표 > Execute Function
-- Description:	
-- Modified: CompanyCode추가 (사업자코드 추가)
--              KEY설정변경 LineCode추가
-- 2020.03.17 Target_Defect_Price 항목 추가 (목표 부적합금액)
-- =============================================

CREATE PROCEDURE [dbo].[usp_MEDIUM_PLAN_iud]
	@pProcessUserID     VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml				NVARCHAR(MAX) = null,
	@pToMonth DATE = NULL
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
	--DECLARE @ToMonth DATE                   = @pToMonth
	DECLARE @ToMonth             VARCHAR(8) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), @pToMonth, 121), 1, 7), '-', '')         -- SELECT  REPLACE(SUBSTRING(CONVERT(VARCHAR(10), '2019-08-26 15:07:17', 121), 1, 7), '-', '')     : 201908

   -- Declare Columns Variable
  DECLARE @Old기준년월    VARCHAR(12)
  DECLARE @Old사이즈      VARCHAR(20)
  DECLARE @Old공정코드    VARCHAR(10)
  DECLARE @OldCompanyCode    VARCHAR(3)
  DECLARE @OldLineCode    VARCHAR(20)

  --DECLARE @OldRouteCode VARCHAR(20)

 -- DECLARE @기준년월 VARCHAR(12)
  DECLARE @사이즈 VARCHAR(20)
  DECLARE @공정코드 VARCHAR(10)
  DECLARE @월간계획 INT
  DECLARE @Day01 INT
  DECLARE @Day02 INT
  DECLARE @Day03 INT
  DECLARE @Day04 INT
  DECLARE @Day05 INT
  DECLARE @Day06 INT
  DECLARE @Day07 INT
  DECLARE @Day08 INT
  DECLARE @Day09 INT
  DECLARE @Day10 INT
  DECLARE @Day11 INT
  DECLARE @Day12 INT
  DECLARE @Day13 INT
  DECLARE @Day14 INT
  DECLARE @Day15 INT
  DECLARE @Day16 INT
  DECLARE @Day17 INT
  DECLARE @Day18 INT
  DECLARE @Day19 INT
  DECLARE @Day20 INT
  DECLARE @Day21 INT
  DECLARE @Day22 INT
  DECLARE @Day23 INT
  DECLARE @Day24 INT
  DECLARE @Day25 INT
  DECLARE @Day26 INT
  DECLARE @Day27 INT
  DECLARE @Day28 INT
  DECLARE @Day29 INT
  DECLARE @Day30 INT
  DECLARE @Day31 INT
  DECLARE @특이사항 VARCHAR(200)
  DECLARE @CompanyCode VARCHAR(3)
  DECLARE @LineCode       VARCHAR(20)
  DECLARE @Target_Defect_Price INT                          -- 2020.03.17 추가
  DECLARE @PlanQty                INT                          -- 2020.05.26 추가

  DECLARE @iDoc INT

  EXEC SmartFramework.dbo.usp_GetSerialRule 
		@pTableName = 'MEDIUM_PLAN',
		@pIsAutoKey = @IsAutoKey OUTPUT,
		@pIsLoopIUD = @IsLoopIUD OUTPUT,
		@pPrefixData = @PrefixString OUTPUT,
		@pSerialLen = @SerialLen OUTPUT
    

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY


			-- Process Insert Table
            MERGE MEDIUM_PLAN AS TargetTable
			USING
				(
					SELECT
							CASE WHEN Old기준년월 IS NULL THEN 기준년월			        ELSE Old기준년월					END AS Old기준년월,					   
							CASE WHEN Old사이즈 IS NULL THEN 사이즈						ELSE Old사이즈						END AS Old사이즈,
							CASE WHEN Old공정코드 IS NULL THEN 공정코드				    ELSE Old공정코드					END AS Old공정코드,
							CASE WHEN OldCompanyCode IS NULL THEN CompanyCode	ELSE OldCompanyCode			END AS OldCompanyCode,
					        CASE WHEN OldLineCode IS NULL THEN LineCode				ELSE OldLineCode					END AS OldLineCode,
							--기준년월,
							@ToMonth AS 기준년월,
							사이즈,
							공정코드,
							CompanyCode,
							LineCode,

							--월간계획,
							Day01,
							Day02,
							Day03,
							Day04,
							Day05,
							Day06,
							Day07,
							Day08,
							Day09,
							Day10,
							Day11,
							Day12,
							Day13,
							Day14,
							Day15,
							Day16,
							Day17,
							Day18,
							Day19,
							Day20,
							Day21,
							Day22,
							Day23,
							Day24,
							Day25,
							Day26,
							Day27,
							Day28,
							Day29,
							Day30,
							Day31,
							특이사항, 
							Target_Defect_Price,
							PlanQty  
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										Old기준년월 VARCHAR(12),
										Old사이즈 VARCHAR(20),
										Old공정코드 VARCHAR(10),
										OldCompanyCode VARCHAR(3),      
										OldLineCode VARCHAR(20),      

										기준년월 VARCHAR(12),
										사이즈 VARCHAR(20),
										공정코드 VARCHAR(10),
										CompanyCode VARCHAR(3),
										LineCode VARCHAR(20),  

										--월간계획 INT,
										Day01 INT,
										Day02 INT,
										Day03 INT,
										Day04 INT,
										Day05 INT,
										Day06 INT,
										Day07 INT,
										Day08 INT,
										Day09 INT,
										Day10 INT,
										Day11 INT,
										Day12 INT,
										Day13 INT,
										Day14 INT,
										Day15 INT,
										Day16 INT,
										Day17 INT,
										Day18 INT,
										Day19 INT,
										Day20 INT,
										Day21 INT,
										Day22 INT,
										Day23 INT,
										Day24 INT,
										Day25 INT,
										Day26 INT,
										Day27 INT,
										Day28 INT,
										Day29 INT,
										Day30 INT,
										Day31 INT,
										특이사항 VARCHAR(200),
										Target_Defect_Price INT,
										PlanQty INT
									)
									 
				) AS SourceTable
			ON
				(
					        TargetTable.기준년월 = SourceTable.기준년월 						   
				    AND	TargetTable.사이즈    = SourceTable.사이즈 
 					AND	TargetTable.공정코드 = SourceTable.공정코드
 					AND	TargetTable.CompanyCode = SourceTable.CompanyCode					
					AND	TargetTable.LineCode = SourceTable.LineCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					기준년월 = ISNULL(SourceTable.기준년월,TargetTable.기준년월),
					--기준년월 = @ToMonth,
					사이즈 = ISNULL(SourceTable.사이즈,TargetTable.사이즈),
					공정코드 = ISNULL(SourceTable.공정코드,TargetTable.공정코드),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),

					--월간계획 = ISNULL(SourceTable.월간계획,TargetTable.월간계획),        -- 원본백업
					----월간계획 = CASE WHEN TargetTable.월간계획 = NULL or TargetTable.월간계획 = 0 or TargetTable.월간계획 = '' THEN 
					----                 (Day01+Day02+Day03+Day04+Day05+Day06+Day07+Day08+Day09+Day10+Day11+Day12+Day13+Day14+Day15+Day16+Day17+Day18+Day19+Day20+Day21+Day22+Day23+Day24+Day25+Day26+Day27+Day28+Day29+Day30+Day31) 
		   ----                      ELSE ISNULL(SourceTable.월간계획,TargetTable.월간계획) END 월간계획,
					--월간계획 = ISNULL(ISNULL(SourceTable.월간계획,TargetTable.월간계획), (SourceTable.Day01+SourceTable.Day02+SourceTable.Day03+SourceTable.Day04+SourceTable.Day05+SourceTable.Day06+SourceTable.Day07+SourceTable.Day08+SourceTable.Day09+SourceTable.Day10
					--                                                                                     +SourceTable.Day11+SourceTable.Day12+SourceTable.Day13+SourceTable.Day14+SourceTable.Day15+SourceTable.Day16+SourceTable.Day17+SourceTable.Day18+SourceTable.Day19+SourceTable.Day20
					--																					 +SourceTable.Day21+SourceTable.Day22+SourceTable.Day23+SourceTable.Day24+SourceTable.Day25+SourceTable.Day26+SourceTable.Day27+SourceTable.Day28+SourceTable.Day29+SourceTable.Day30+SourceTable.Day31	)),

					Day01 = ISNULL(SourceTable.Day01,TargetTable.Day01),
					Day02 = ISNULL(SourceTable.Day02,TargetTable.Day02),
					Day03 = ISNULL(SourceTable.Day03,TargetTable.Day03),
					Day04 = ISNULL(SourceTable.Day04,TargetTable.Day04),
					Day05 = ISNULL(SourceTable.Day05,TargetTable.Day05),
					Day06 = ISNULL(SourceTable.Day06,TargetTable.Day06),
					Day07 = ISNULL(SourceTable.Day07,TargetTable.Day07),
					Day08 = ISNULL(SourceTable.Day08,TargetTable.Day08),
					Day09 = ISNULL(SourceTable.Day09,TargetTable.Day09),
					Day10 = ISNULL(SourceTable.Day10,TargetTable.Day10),
					Day11 = ISNULL(SourceTable.Day11,TargetTable.Day11),
					Day12 = ISNULL(SourceTable.Day12,TargetTable.Day12),
					Day13 = ISNULL(SourceTable.Day13,TargetTable.Day13),
					Day14 = ISNULL(SourceTable.Day14,TargetTable.Day14),
					Day15 = ISNULL(SourceTable.Day15,TargetTable.Day15),
					Day16 = ISNULL(SourceTable.Day16,TargetTable.Day16),
					Day17 = ISNULL(SourceTable.Day17,TargetTable.Day17),
					Day18 = ISNULL(SourceTable.Day18,TargetTable.Day18),
					Day19 = ISNULL(SourceTable.Day19,TargetTable.Day19),
					Day20 = ISNULL(SourceTable.Day20,TargetTable.Day20),
					Day21 = ISNULL(SourceTable.Day21,TargetTable.Day21),
					Day22 = ISNULL(SourceTable.Day22,TargetTable.Day22),
					Day23 = ISNULL(SourceTable.Day23,TargetTable.Day23),
					Day24 = ISNULL(SourceTable.Day24,TargetTable.Day24),
					Day25 = ISNULL(SourceTable.Day25,TargetTable.Day25),
					Day26 = ISNULL(SourceTable.Day26,TargetTable.Day26),
					Day27 = ISNULL(SourceTable.Day27,TargetTable.Day27),
					Day28 = ISNULL(SourceTable.Day28,TargetTable.Day28),
					Day29 = ISNULL(SourceTable.Day29,TargetTable.Day29),
					Day30 = ISNULL(SourceTable.Day30,TargetTable.Day30),
					Day31 = ISNULL(SourceTable.Day31,TargetTable.Day31),
					특이사항 = ISNULL(SourceTable.특이사항,TargetTable.특이사항),
					Target_Defect_Price = ISNULL(SourceTable.Target_Defect_Price,TargetTable.Target_Defect_Price)
			
			WHEN NOT MATCHED THEN

				INSERT
					(
						기준년월,
						사이즈,
						공정코드,
						CompanyCode,						
						LineCode,
					--	월간계획,
						Day01,
						Day02,
						Day03,
						Day04,
						Day05,
						Day06,
						Day07,
						Day08,
						Day09,
						Day10,
						Day11,
						Day12,
						Day13,
						Day14,
						Day15,
						Day16,
						Day17,
						Day18,
						Day19,
						Day20,
						Day21,
						Day22,
						Day23,
						Day24,
						Day25,
						Day26,
						Day27,
						Day28,
						Day29,
						Day30,
						Day31,
						특이사항,
						Target_Defect_Price
					)
				VALUES
					(
							SourceTable.기준년월,
							--@ToMonth,
							SourceTable.사이즈,
							SourceTable.공정코드,
							SourceTable.CompanyCode,
							SourceTable.LineCode,

						--	SourceTable.월간계획,

							--ISNULL(SourceTable.월간계획, (SourceTable.Day01+SourceTable.Day02+SourceTable.Day03+SourceTable.Day04+SourceTable.Day05+SourceTable.Day06+SourceTable.Day07+SourceTable.Day08+SourceTable.Day09+SourceTable.Day10
							--                                   +SourceTable.Day11+SourceTable.Day12+SourceTable.Day13+SourceTable.Day14+SourceTable.Day15+SourceTable.Day16+SourceTable.Day17+SourceTable.Day18+SourceTable.Day19+SourceTable.Day20
							--								   +SourceTable.Day21+SourceTable.Day22+SourceTable.Day23+SourceTable.Day24+SourceTable.Day25+SourceTable.Day26+SourceTable.Day27+SourceTable.Day28+SourceTable.Day29+SourceTable.Day30+SourceTable.Day31)),
							SourceTable.Day01,
							SourceTable.Day02,
							SourceTable.Day03,
							SourceTable.Day04,
							SourceTable.Day05,
							SourceTable.Day06,
							SourceTable.Day07,
							SourceTable.Day08,
							SourceTable.Day09,
							SourceTable.Day10,
							SourceTable.Day11,
							SourceTable.Day12,
							SourceTable.Day13,
							SourceTable.Day14,
							SourceTable.Day15,
							SourceTable.Day16,
							SourceTable.Day17,
							SourceTable.Day18,
							SourceTable.Day19,
							SourceTable.Day20,
							SourceTable.Day21,
							SourceTable.Day22,
							SourceTable.Day23,
							SourceTable.Day24,
							SourceTable.Day25,
							SourceTable.Day26,
							SourceTable.Day27,
							SourceTable.Day28,
							SourceTable.Day29,
							SourceTable.Day30,
							SourceTable.Day31,
							SourceTable.특이사항,
							SourceTable.Target_Defect_Price
					);


			-- Process Update Table
            MERGE MEDIUM_PLAN AS TargetTable
			USING
				(
					SELECT
							CASE WHEN Old기준년월 IS NULL THEN 기준년월			        ELSE Old기준년월					END AS Old기준년월,
					   --  CASE WHEN Old기준년월 IS NULL THEN 기준년월			        ELSE @ToMonth					END AS Old기준년월,							
							CASE WHEN Old사이즈 IS NULL THEN 사이즈						ELSE Old사이즈						END AS Old사이즈,
							CASE WHEN Old공정코드 IS NULL THEN 공정코드				    ELSE Old공정코드					END AS Old공정코드,
							CASE WHEN OldCompanyCode IS NULL THEN CompanyCode	ELSE OldCompanyCode			END AS OldCompanyCode,
					        CASE WHEN OldLineCode IS NULL THEN LineCode				ELSE OldLineCode					END AS OldLineCode,
							--기준년월,
							@ToMonth AS 기준년월,
							사이즈,
							공정코드,
							CompanyCode,							
							LineCode,
							--월간계획,
							Day01,
							Day02,
							Day03,
							Day04,
							Day05,
							Day06,
							Day07,
							Day08,
							Day09,
							Day10,
							Day11,
							Day12,
							Day13,
							Day14,
							Day15,
							Day16,
							Day17,
							Day18,
							Day19,
							Day20,
							Day21,
							Day22,
							Day23,
							Day24,
							Day25,
							Day26,
							Day27,
							Day28,
							Day29,
							Day30,
							Day31,
							특이사항,
							Target_Defect_Price,
							PlanQty
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										Old기준년월 VARCHAR(12),
										Old사이즈 VARCHAR(20),
										Old공정코드 VARCHAR(10),
										OldCompanyCode VARCHAR(3),
										OldLineCode VARCHAR(20),  

										기준년월 VARCHAR(12),
										사이즈 VARCHAR(20),
										공정코드 VARCHAR(10),
										CompanyCode VARCHAR(3),
										LineCode VARCHAR(20),

										--월간계획 INT,
										Day01 INT,
										Day02 INT,
										Day03 INT,
										Day04 INT,
										Day05 INT,
										Day06 INT,
										Day07 INT,
										Day08 INT,
										Day09 INT,
										Day10 INT,
										Day11 INT,
										Day12 INT,
										Day13 INT,
										Day14 INT,
										Day15 INT,
										Day16 INT,
										Day17 INT,
										Day18 INT,
										Day19 INT,
										Day20 INT,
										Day21 INT,
										Day22 INT,
										Day23 INT,
										Day24 INT,
										Day25 INT,
										Day26 INT,
										Day27 INT,
										Day28 INT,
										Day29 INT,
										Day30 INT,
										Day31 INT,
										특이사항 VARCHAR(200),
										Target_Defect_Price INT,
										PlanQty INT									
									) 
				) AS SourceTable
			ON
				(
					TargetTable.기준년월 = SourceTable.Old기준년월 AND
					TargetTable.사이즈 = SourceTable.Old사이즈 AND
					TargetTable.공정코드 = SourceTable.Old공정코드 AND	
					TargetTable.CompanyCode = SourceTable.OldCompanyCode AND
					TargetTable.LineCode = SourceTable.OldLineCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					--기준년월 = ISNULL(SourceTable.기준년월,TargetTable.기준년월),
					기준년월 = ISNULL(SourceTable.기준년월,TargetTable.기준년월),
					--기준년월 = @ToMonth,
					사이즈   = ISNULL(SourceTable.사이즈,TargetTable.사이즈),
					공정코드 = ISNULL(SourceTable.공정코드,TargetTable.공정코드),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),

					--월간계획 = ISNULL(SourceTable.월간계획,TargetTable.월간계획),
					Day01 = ISNULL(SourceTable.Day01,TargetTable.Day01),
					Day02 = ISNULL(SourceTable.Day02,TargetTable.Day02),
					Day03 = ISNULL(SourceTable.Day03,TargetTable.Day03),
					Day04 = ISNULL(SourceTable.Day04,TargetTable.Day04),
					Day05 = ISNULL(SourceTable.Day05,TargetTable.Day05),
					Day06 = ISNULL(SourceTable.Day06,TargetTable.Day06),
					Day07 = ISNULL(SourceTable.Day07,TargetTable.Day07),
					Day08 = ISNULL(SourceTable.Day08,TargetTable.Day08),
					Day09 = ISNULL(SourceTable.Day09,TargetTable.Day09),
					Day10 = ISNULL(SourceTable.Day10,TargetTable.Day10),
					Day11 = ISNULL(SourceTable.Day11,TargetTable.Day11),
					Day12 = ISNULL(SourceTable.Day12,TargetTable.Day12),
					Day13 = ISNULL(SourceTable.Day13,TargetTable.Day13),
					Day14 = ISNULL(SourceTable.Day14,TargetTable.Day14),
					Day15 = ISNULL(SourceTable.Day15,TargetTable.Day15),
					Day16 = ISNULL(SourceTable.Day16,TargetTable.Day16),
					Day17 = ISNULL(SourceTable.Day17,TargetTable.Day17),
					Day18 = ISNULL(SourceTable.Day18,TargetTable.Day18),
					Day19 = ISNULL(SourceTable.Day19,TargetTable.Day19),
					Day20 = ISNULL(SourceTable.Day20,TargetTable.Day20),
					Day21 = ISNULL(SourceTable.Day21,TargetTable.Day21),
					Day22 = ISNULL(SourceTable.Day22,TargetTable.Day22),
					Day23 = ISNULL(SourceTable.Day23,TargetTable.Day23),
					Day24 = ISNULL(SourceTable.Day24,TargetTable.Day24),
					Day25 = ISNULL(SourceTable.Day25,TargetTable.Day25),
					Day26 = ISNULL(SourceTable.Day26,TargetTable.Day26),
					Day27 = ISNULL(SourceTable.Day27,TargetTable.Day27),
					Day28 = ISNULL(SourceTable.Day28,TargetTable.Day28),
					Day29 = ISNULL(SourceTable.Day29,TargetTable.Day29),
					Day30 = ISNULL(SourceTable.Day30,TargetTable.Day30),
					Day31 = ISNULL(SourceTable.Day31,TargetTable.Day31),
					특이사항 = ISNULL(SourceTable.특이사항,TargetTable.특이사항),
					Target_Defect_Price = ISNULL(SourceTable.Target_Defect_Price,TargetTable.Target_Defect_Price),
					PlanQty =  ISNULL(SourceTable.PlanQty,TargetTable.PlanQty)					
			WHEN NOT MATCHED THEN
				INSERT
					(
						기준년월,						
						사이즈,
						공정코드,
						CompanyCode,
						LineCode, 
						--월간계획,
						Day01,
						Day02,
						Day03,
						Day04,
						Day05,
						Day06,
						Day07,
						Day08,
						Day09,
						Day10,
						Day11,
						Day12,
						Day13,
						Day14,
						Day15,
						Day16,
						Day17,
						Day18,
						Day19,
						Day20,
						Day21,
						Day22,
						Day23,
						Day24,
						Day25,
						Day26,
						Day27,
						Day28,
						Day29,
						Day30,
						Day31,
						특이사항,
						Target_Defect_Price,
						PlanQty
					)
				VALUES
					(
					       --@ToMonth,
							SourceTable.기준년월,
							SourceTable.사이즈,
							SourceTable.공정코드,
							SourceTable.CompanyCode,
							SourceTable.LineCode,
							--SourceTable.월간계획,
							SourceTable.Day01,
							SourceTable.Day02,
							SourceTable.Day03,
							SourceTable.Day04,
							SourceTable.Day05,
							SourceTable.Day06,
							SourceTable.Day07,
							SourceTable.Day08,
							SourceTable.Day09,
							SourceTable.Day10,
							SourceTable.Day11,
							SourceTable.Day12,
							SourceTable.Day13,
							SourceTable.Day14,
							SourceTable.Day15,
							SourceTable.Day16,
							SourceTable.Day17,
							SourceTable.Day18,
							SourceTable.Day19,
							SourceTable.Day20,
							SourceTable.Day21,
							SourceTable.Day22,
							SourceTable.Day23,
							SourceTable.Day24,
							SourceTable.Day25,
							SourceTable.Day26,
							SourceTable.Day27,
							SourceTable.Day28,
							SourceTable.Day29,
							SourceTable.Day30,
							SourceTable.Day31,
							SourceTable.특이사항,
							SourceTable.Target_Defect_Price,
							SourceTable.PlanQty
					);


			-- Process Delete Table
            MERGE MEDIUM_PLAN AS TargetTable
			USING
				(
					SELECT
							CASE WHEN Old기준년월 IS NULL THEN 기준년월			        ELSE Old기준년월					END AS Old기준년월,
						--  CASE WHEN Old기준년월 IS NULL THEN 기준년월			        ELSE @ToMonth					END AS Old기준년월,							
							CASE WHEN Old사이즈 IS NULL THEN 사이즈						ELSE Old사이즈						END AS Old사이즈,
							CASE WHEN Old공정코드 IS NULL THEN 공정코드				    ELSE Old공정코드					END AS Old공정코드,
							CASE WHEN OldCompanyCode IS NULL THEN CompanyCode	ELSE OldCompanyCode			END AS OldCompanyCode,
					        CASE WHEN OldLineCode       IS NULL THEN LineCode			ELSE OldLineCode					END AS OldLineCode,
							--기준년월,
							@ToMonth AS 기준년월,
							사이즈,
							공정코드,
							CompanyCode,
							LineCode,
							--월간계획,
							Day01,
							Day02,
							Day03,
							Day04,
							Day05,
							Day06,
							Day07,
							Day08,
							Day09,
							Day10,
							Day11,
							Day12,
							Day13,
							Day14,
							Day15,
							Day16,
							Day17,
							Day18,
							Day19,
							Day20,
							Day21,
							Day22,
							Day23,
							Day24,
							Day25,
							Day26,
							Day27,
							Day28,
							Day29,
							Day30,
							Day31,
							특이사항,
							Target_Defect_Price														
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										Old기준년월 VARCHAR(12),
										Old사이즈 VARCHAR(20),
										Old공정코드 VARCHAR(10),
										OldCompanyCode VARCHAR(3),
										OldLineCode VARCHAR(20),

										기준년월 VARCHAR(12),
										사이즈 VARCHAR(20),
										공정코드 VARCHAR(10),
										CompanyCode VARCHAR(3),
										LineCode VARCHAR(20),

										--월간계획 INT,
										Day01 INT,
										Day02 INT,
										Day03 INT,
										Day04 INT,
										Day05 INT,
										Day06 INT,
										Day07 INT,
										Day08 INT,
										Day09 INT,
										Day10 INT,
										Day11 INT,
										Day12 INT,
										Day13 INT,
										Day14 INT,
										Day15 INT,
										Day16 INT,
										Day17 INT,
										Day18 INT,
										Day19 INT,
										Day20 INT,
										Day21 INT,
										Day22 INT,
										Day23 INT,
										Day24 INT,
										Day25 INT,
										Day26 INT,
										Day27 INT,
										Day28 INT,
										Day29 INT,
										Day30 INT,
										Day31 INT,
										특이사항 VARCHAR(200),
										Target_Defect_Price INT										
									) 
				) AS SourceTable
			ON
				(
					--TargetTable.기준년월 = SourceTable.기준년월 
					TargetTable.기준년월 = @ToMonth
					AND					TargetTable.사이즈 = SourceTable.사이즈 
					AND					TargetTable.공정코드 = SourceTable.공정코드
					AND					TargetTable.CompanyCode = SourceTable.CompanyCode
				   AND					TargetTable.LineCode = SourceTable.LineCode
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
									--Old기준년월,
									@ToMonth,
									Old사이즈,
									Old공정코드,
									OldCompanyCode ,
									OldLineCode,

									기준년월,
									사이즈,
									공정코드,
									CompanyCode,
									LineCode,

								--월간계획,
									Day01,
									Day02,
									Day03,
									Day04,
									Day05,
									Day06,
									Day07,
									Day08,
									Day09,
									Day10,
									Day11,
									Day12,
									Day13,
									Day14,
									Day15,
									Day16,
									Day17,
									Day18,
									Day19,
									Day20,
									Day21,
									Day22,
									Day23,
									Day24,
									Day25,
									Day26,
									Day27,
									Day28,
									Day29,
									Day30,
									Day31,
									특이사항,
									Target_Defect_Price
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 Old기준년월 VARCHAR(12),
											 Old사이즈 VARCHAR(20),
											 Old공정코드 VARCHAR(10),
											 OldCompanyCode VARCHAR(3),
											 OldLineCode VARCHAR(20),

											 기준년월 VARCHAR(12),
											 사이즈 VARCHAR(20),
											 공정코드 VARCHAR(10),
											 CompanyCode VARCHAR(3),
											 LineCode VARCHAR(20),
											 
											--월간계획 INT,
											 Day01 INT,
											 Day02 INT,
											 Day03 INT,
											 Day04 INT,
											 Day05 INT,
											 Day06 INT,
											 Day07 INT,
											 Day08 INT,
											 Day09 INT,
											 Day10 INT,
											 Day11 INT,
											 Day12 INT,
											 Day13 INT,
											 Day14 INT,
											 Day15 INT,
											 Day16 INT,
											 Day17 INT,
											 Day18 INT,
											 Day19 INT,
											 Day20 INT,
											 Day21 INT,
											 Day22 INT,
											 Day23 INT,
											 Day24 INT,
											 Day25 INT,
											 Day26 INT,
											 Day27 INT,
											 Day28 INT,
											 Day29 INT,
											 Day30 INT,
											 Day31 INT,
											 특이사항 VARCHAR(200),
											 Target_Defect_Price INT											 
											)
							UNION ALL

							SELECT
									'UPDATE' AS IUD_FLAG,
							CASE WHEN Old기준년월 IS NULL THEN 기준년월			  ELSE Old기준년월					END AS Old기준년월,
					    --  CASE WHEN Old기준년월 IS NULL THEN 기준년월			  ELSE @ToMonth							END AS Old기준년월,							
							CASE WHEN Old사이즈 IS NULL   THEN 사이즈						ELSE Old사이즈						END AS Old사이즈,
							CASE WHEN Old공정코드 IS NULL THEN 공정코드				ELSE Old공정코드					END AS Old공정코드,
							CASE WHEN OldCompanyCode IS NULL THEN CompanyCode	ELSE OldCompanyCode				END AS OldCompanyCode,
					       CASE WHEN OldLineCode IS NULL THEN LineCode				ELSE OldLineCode					END AS OldLineCode,
							--기준년월,
							@ToMonth AS 기준년월,
							사이즈,
							공정코드,
							CompanyCode,
							LineCode,

								--	월간계획,
									Day01,
									Day02,
									Day03,
									Day04,
									Day05,
									Day06,
									Day07,
									Day08,
									Day09,
									Day10,
									Day11,
									Day12,
									Day13,
									Day14,
									Day15,
									Day16,
									Day17,
									Day18,
									Day19,
									Day20,
									Day21,
									Day22,
									Day23,
									Day24,
									Day25,
									Day26,
									Day27,
									Day28,
									Day29,
									Day30,
									Day31,
									특이사항,
									Target_Defect_Price							
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 Old기준년월 VARCHAR(12),
											 Old사이즈 VARCHAR(20),
											 Old공정코드 VARCHAR(10),
											 OldCompanyCode VARCHAR(3),
											 OldLineCode VARCHAR(20),

											 --@ToMonth,
											 기준년월 VARCHAR(12),
											 사이즈 VARCHAR(20),
											 공정코드 VARCHAR(10),
											 CompanyCode VARCHAR(3),
											 LineCode VARCHAR(20),

										--	 월간계획 INT,
											 Day01 INT,
											 Day02 INT,
											 Day03 INT,
											 Day04 INT,
											 Day05 INT,
											 Day06 INT,
											 Day07 INT,
											 Day08 INT,
											 Day09 INT,
											 Day10 INT,
											 Day11 INT,
											 Day12 INT,
											 Day13 INT,
											 Day14 INT,
											 Day15 INT,
											 Day16 INT,
											 Day17 INT,
											 Day18 INT,
											 Day19 INT,
											 Day20 INT,
											 Day21 INT,
											 Day22 INT,
											 Day23 INT,
											 Day24 INT,
											 Day25 INT,
											 Day26 INT,
											 Day27 INT,
											 Day28 INT,
											 Day29 INT,
											 Day30 INT,
											 Day31 INT,
											 특이사항 VARCHAR(200),
											 Target_Defect_Price INT
											)
							UNION ALL

							SELECT
									'DELETE' AS IUD_FLAG,
							CASE WHEN Old기준년월 IS NULL THEN 기준년월			  ELSE Old기준년월					END AS Old기준년월,
					    --  CASE WHEN Old기준년월 IS NULL THEN 기준년월			  ELSE @ToMonth							END AS Old기준년월,							
							CASE WHEN Old사이즈 IS NULL THEN 사이즈						ELSE Old사이즈						END AS Old사이즈,
							CASE WHEN Old공정코드 IS NULL THEN 공정코드				    ELSE Old공정코드					END AS Old공정코드,
							CASE WHEN OldCompanyCode IS NULL THEN CompanyCode	ELSE OldCompanyCode				END AS OldCompanyCode,
					        CASE WHEN OldLineCode IS NULL THEN LineCode				ELSE OldLineCode					END AS OldLineCode,
							--기준년월,
							@ToMonth AS 기준년월,
							사이즈,
							공정코드,
							CompanyCode,
							LineCode,
									--월간계획,
									Day01,
									Day02,
									Day03,
									Day04,
									Day05,
									Day06,
									Day07,
									Day08,
									Day09,
									Day10,
									Day11,
									Day12,
									Day13,
									Day14,
									Day15,
									Day16,
									Day17,
									Day18,
									Day19,
									Day20,
									Day21,
									Day22,
									Day23,
									Day24,
									Day25,
									Day26,
									Day27,
									Day28,
									Day29,
									Day30,
									Day31,
									특이사항,
									Target_Defect_Price
									
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 Old기준년월 VARCHAR(12),
											 Old사이즈 VARCHAR(20),
											 Old공정코드 VARCHAR(10),
											 OldCompanyCode VARCHAR(3),
											 OldLineCode VARCHAR(20),
											 
											 기준년월 VARCHAR(12),
											-- @ToMonth,
											 사이즈 VARCHAR(20),
											 공정코드 VARCHAR(10),
											 CompanyCode VARCHAR(3),
											 LineCode VARCHAR(20),
											 --월간계획 INT,
											 Day01 INT,
											 Day02 INT,
											 Day03 INT,
											 Day04 INT,
											 Day05 INT,
											 Day06 INT,
											 Day07 INT,
											 Day08 INT,
											 Day09 INT,
											 Day10 INT,
											 Day11 INT,
											 Day12 INT,
											 Day13 INT,
											 Day14 INT,
											 Day15 INT,
											 Day16 INT,
											 Day17 INT,
											 Day18 INT,
											 Day19 INT,
											 Day20 INT,
											 Day21 INT,
											 Day22 INT,
											 Day23 INT,
											 Day24 INT,
											 Day25 INT,
											 Day26 INT,
											 Day27 INT,
											 Day28 INT,
											 Day29 INT,
											 Day30 INT,
											 Day31 INT,
											 특이사항 VARCHAR(200),
											 Target_Defect_Price INT																					 
											) 


            OPEN SourceData

            WHILE 1 = 1 

			
			BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,

								 @Old기준년월,
								 @Old사이즈,
								 @Old공정코드,
								  @OldCompanyCode,
								 @OldLineCode,

								 --@기준년월,
								  @ToMonth,
								 @사이즈,
								 @공정코드,
								 @CompanyCode,
								 @LineCode,

								--@월간계획,
								 @Day01,
								 @Day02,
								 @Day03,
								 @Day04,
								 @Day05,
								 @Day06,
								 @Day07,
								 @Day08,
								 @Day09,
								 @Day10,
								 @Day11,
								 @Day12,
								 @Day13,
								 @Day14,
								 @Day15,
								 @Day16,
								 @Day17,
								 @Day18,
								 @Day19,
								 @Day20,
								 @Day21,
								 @Day22,
								 @Day23,
								 @Day24,
								 @Day25,
								 @Day26,
								 @Day27,
								 @Day28,
								 @Day29,
								 @Day30,
								 @Day31,
								 @특이사항,
								 @Target_Defect_Price


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (
					              SELECT 1 FROM MEDIUM_PLAN 
					                         WHERE 1=1
										      --AND 기준년월 = @기준년월 
											  AND 기준년월 = @ToMonth
										      AND 사이즈 = @사이즈 
											  AND 공정코드 = @공정코드
											  AND CompanyCode = @CompanyCode
											  AND LineCode = @LineCode
											  ) 
					BEGIN
						--RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @기준년월)
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ToMonth)
					END

                    IF @IsAutoKey = 1 BEGIN
                        --EXEC SmartFramework.dbo.usp_DoCreateSerial 'MEDIUM_PLAN',@기준년월 OUTPUT
					    EXEC SmartFramework.dbo.usp_DoCreateSerial 'MEDIUM_PLAN',@ToMonth OUTPUT
                    END

                    INSERT INTO MEDIUM_PLAN
						(
						    기준년월,
						    사이즈,
						    공정코드,
						    CompanyCode,
							LineCode, 

						   -- 월간계획,
						    Day01,
						    Day02,
						    Day03,
						    Day04,
						    Day05,
						    Day06,
						    Day07,
						    Day08,
						    Day09,
						    Day10,
						    Day11,
						    Day12,
						    Day13,
						    Day14,
						    Day15,
						    Day16,
						    Day17,
						    Day18,
						    Day19,
						    Day20,
						    Day21,
						    Day22,
						    Day23,
						    Day24,
						    Day25,
						    Day26,
						    Day27,
						    Day28,
						    Day29,
						    Day30,
						    Day31,
						    특이사항,
							Target_Defect_Price
						)
						VALUES
						(
						   -- @기준년월,
						   @ToMonth,
						    @사이즈,
						    @공정코드,
						    @CompanyCode,
							@LineCode,
						  --  @월간계획,
						    @Day01,
						    @Day02,
						    @Day03,
						    @Day04,
						    @Day05,
						    @Day06,
						    @Day07,
						    @Day08,
						    @Day09,
						    @Day10,
						    @Day11,
						    @Day12,
						    @Day13,
						    @Day14,
						    @Day15,
						    @Day16,
						    @Day17,
						    @Day18,
						    @Day19,
						    @Day20,
						    @Day21,
						    @Day22,
						    @Day23,
						    @Day24,
						    @Day25,
						    @Day26,
						    @Day27,
						    @Day28,
						    @Day29,
						    @Day30,
						    @Day31,
						    @특이사항,
							@Target_Defect_Price
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' 
				
				BEGIN
                    UPDATE MEDIUM_PLAN
						SET
						    --기준년월 =   ISNULL(@기준년월,기준년월),
							--기준년월 =   ISNULL(@기준년월,@ToMonth),							
							기준년월 = @ToMonth,
						    사이즈           =   ISNULL(@사이즈,사이즈),
						    공정코드        =   ISNULL(@공정코드,공정코드),
 						    CompanyCode  =   ISNULL(@CompanyCode,CompanyCode),
							LineCode        =   ISNULL(@LineCode,LineCode),
						    --월간계획 =   ISNULL(@월간계획,월간계획),
							--월간계획 =   ISNULL(ISNULL(@월간계획,월간계획), (Day01+Day02+Day03+Day04+Day05+Day06+Day07+Day08+Day09+Day10
							--                                                            +Day11+Day12+Day13+Day14+Day15+Day16+Day17+Day18+Day19+Day20
							--															+Day21+Day22+Day23+Day24+Day25+Day26+Day27+Day28+Day29+Day30+Day31	)),							
						    Day01 =   ISNULL(@Day01,Day01),
						    Day02 =   ISNULL(@Day02,Day02),
						    Day03 =   ISNULL(@Day03,Day03),
						    Day04 =   ISNULL(@Day04,Day04),
						    Day05 =   ISNULL(@Day05,Day05),
						    Day06 =   ISNULL(@Day06,Day06),
						    Day07 =   ISNULL(@Day07,Day07),
						    Day08 =   ISNULL(@Day08,Day08),
						    Day09 =   ISNULL(@Day09,Day09),
						    Day10 =   ISNULL(@Day10,Day10),
						    Day11 =   ISNULL(@Day11,Day11),
						    Day12 =   ISNULL(@Day12,Day12),
						    Day13 =   ISNULL(@Day13,Day13),
						    Day14 =   ISNULL(@Day14,Day14),
						    Day15 =   ISNULL(@Day15,Day15),
						    Day16 =   ISNULL(@Day16,Day16),
						    Day17 =   ISNULL(@Day17,Day17),
						    Day18 =   ISNULL(@Day18,Day18),
						    Day19 =   ISNULL(@Day19,Day19),
						    Day20 =   ISNULL(@Day20,Day20),
						    Day21 =   ISNULL(@Day21,Day21),
						    Day22 =   ISNULL(@Day22,Day22),
						    Day23 =   ISNULL(@Day23,Day23),
						    Day24 =   ISNULL(@Day24,Day24),
						    Day25 =   ISNULL(@Day25,Day25),
						    Day26 =   ISNULL(@Day26,Day26),
						    Day27 =   ISNULL(@Day27,Day27),
						    Day28 =   ISNULL(@Day28,Day28),
						    Day29 =   ISNULL(@Day29,Day29),
						    Day30 =   ISNULL(@Day30,Day30),
						    Day31 =   ISNULL(@Day31,Day31),
						    특이사항 =   ISNULL(@특이사항,특이사항),
							Target_Defect_Price =  ISNULL(@Target_Defect_Price,Target_Defect_Price)
						WHERE
						    기준년월 = @Old기준년월 AND
						    사이즈 = @Old사이즈 AND
						    공정코드 = @Old공정코드 AND 							
							LineCode =  @OldLineCode
                END ELSE IF @IUD_FLAG = 'DELETE'
				
				 BEGIN
                    DELETE FROM MEDIUM_PLAN
						WHERE
						    기준년월        = @Old기준년월 AND
						    사이즈          = @Old사이즈 AND 
						    공정코드        = @Old공정코드 AND 
						    CompanyCode = @OldCompanyCode  AND
							LineCode       = @OldLineCode
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