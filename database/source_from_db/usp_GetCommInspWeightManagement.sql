
--      EXEC [usp_GetCommInspWeightManagement] '','','VNT','VNT_F1','','','ECVT27-150','','','','','',''

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-24
-- Browsable : true
-- Group : 품질관리
-- Description:	공용검사 관리도
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCommInspWeightManagement] 
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pTargetDate DATE = NULL,
    @pShiftCode VARCHAR(1) = NULL,
	@pMoldNumber VARCHAR(50) = NULL,
	@pMaterialCode VARCHAR(50) = NULL,
	@pCommInspTypeCode VARCHAR(50) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pFacilityRouteCode VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pCategoryName NVARCHAR(50) = NULL
AS
BEGIN
	
	
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END	
	DECLARE @CompanyName NVARCHAR(100)
	DECLARE	@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @WorkCenterName NVARCHAR(50)
	DECLARE @TargetDate DATE = @pTargetDate
	DECLARE @ShiftCode VARCHAR(1) = CASE WHEN ISNULL(@pShiftCode,'') = '' THEN '*' ELSE @pShiftCode END
	
	DECLARE @MoldNumber VARCHAR(50) = CASE WHEN ISNULL(@pMoldNumber,'') = '' THEN '*' ELSE @pMoldNumber END
	
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END
	DECLARE @MaterialName NVARCHAR(100)
	
	DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END
	DECLARE @RouteName NVARCHAR(50) 
	
	DECLARE @FacilityRouteCode VARCHAR(20) = CASE WHEN ISNULL(@pFacilityRouteCode,'') = '' THEN '*' ELSE @pFacilityRouteCode END
	DECLARE @FacilityRouteName NVARCHAR(100)
	
	DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '*' ELSE @pMachineCode END
	DECLARE @MachineName NVARCHAR(100) 
	
	DECLARE @CategoryName NVARCHAR(50) = CASE WHEN ISNULL(@pCategoryName,'') = '' THEN '*' ELSE @pCategoryName END
	
	DECLARE @CommInspTypeCode VARCHAR(50) = CASE WHEN ISNULL(@pCommInspTypeCode,'') = '' THEN '' ELSE @pCommInspTypeCode END
	
	
	DECLARE @FromDate DATE
	DECLARE	@FromShiftCode VARCHAR(1)
    DECLARE	@ToDate DATE
	DECLARE	@ToShiftCode VARCHAR(1) 
	
	DECLARE @A2 NUMERIC(20,4)
	DECLARE	@D4 NUMERIC(20,4)
	DECLARE	@D2 NUMERIC(20,4)
	
	SET @A2 = 0.48
	SET @D4 = 2.00
	SET @D2 = 2.53
	
	
	DECLARE @JobDateInfo TABLE
	(
		RowNumber INT IDENTITY,
		JobDate DATE,
		ShiftCode VARCHAR(1)
	)
		
	DECLARE @WeightHist TABLE
	(
		SeqNo INT,
		JobDate DATE,
		ShiftCode VARCHAR(1),
		[Weight] NUMERIC(20,4)
	)
    
    
    INSERT @JobDateInfo
	SELECT
			Master.JobDate,
			Master.ShiftCode
	FROM
			(
				SELECT
						TOP 62
						CIDH.JobDate,
						CIDH.ShiftCode
				FROM
						STB_CommInspDocHistory CIDH WITH(NOLOCK)


						-- SELECT * FROM STB_CommInspDocHistory
				WHERE
						((CIDH.JobDate <= @TargetDate)) AND
						((@CompanyCode = '*') OR (CIDH.CompanyCode = @CompanyCode)) AND
						((@WorkCenterCode = '*') OR (CIDH.WorkCenterCode = @WorkCenterCode)) AND
						((@ShiftCode = '*') OR (CIDH.ShiftCode = @ShiftCode)) AND
						((@MoldNumber = '*') OR (CIDH.MoldNumber = @MoldNumber)) AND
						((@MaterialCode = '*') OR (CIDH.MaterialCode = @MaterialCode)) AND
						((@RouteCode  = '*') OR (CIDH.RouteCode = @RouteCode)) AND
						((@FacilityRouteCode = '*') OR (CIDH.FacilityRouteCode = @FacilityRouteCode)) AND
						((@MachineCode = '*') OR (CIDH.MachineCode = @MachineCode)) AND
						((@CategoryName = '*') OR (CIDH.CategoryName = @CategoryName)) AND
						((@CommInspTypeCode = '*') OR (CIDH.CommInspTypeCode = @CommInspTypeCode))
				ORDER BY
						CIDH.JobDate DESC,
						CIDH.ShiftCode DESC
			)Master
	
	--시작일자, 교대조		
	SELECT
			TOP 1
			@FromDate = JobDate,
			@FromShiftCode = ShiftCode
	FROM
			@JobDateInfo 
	ORDER BY
			JobDate,
			ShiftCode
			
	
	--마지막일자, 교대조
	SELECT
			TOP 1
			@ToDate = JobDate,
			@ToShiftCode = ShiftCode
	FROM
			@JobDateInfo
	ORDER BY
			JobDate DESC,
			ShiftCode DESC
	
	
	
	DECLARE  @RowNumber INT
	DECLARE	 @Index INT = 1
	DECLARE  @JobDate DATE
	DECLARE  @ShiftGroup VARCHAR(1)
	
	SET @RowNumber = (SELECT COUNT(*) FROM @JobDateInfo)
    
    WHILE(@Index < @RowNumber + 1) BEGIN
		SELECT
				@JobDate = PI.JobDate,
				@ShiftGroup = PI.ShiftCode
		FROM
				@JobDateInfo PI
		WHERE
				PI.RowNumber = @Index
		
		
		INSERT @WeightHist	
		SELECT
				CIMH.MeasureSeq,
				CIDH.JobDate,
				CIDH.ShiftCode,
				SUM(ISNULL(CIMH.NumericMeasure,0)) AS Weight
		FROM
				STB_CommInspDocHistory CIDH
				
				LEFT OUTER JOIN STB_CommInspDocItem CIDI 					ON CIDI.CommInspDocNo = CIDH.CommInspDocNo
				INNER JOIN STB_CommInspMeasureHist CIMH 					ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo
		WHERE
			
				((CIDH.JobDate = @JobDate)) AND
				((CIDH.ShiftCode = @ShiftGroup)) AND
				((@CompanyCode = '*') OR (CIDH.CompanyCode = @CompanyCode)) AND
				((@WorkCenterCode = '*') OR (CIDH.WorkCenterCode = @WorkCenterCode)) AND
				((@MoldNumber = '*') OR (CIDH.MoldNumber = @MoldNumber)) AND
				((@MaterialCode = '*') OR (CIDH.MaterialCode = @MaterialCode)) AND
				((@RouteCode  = '*') OR (CIDH.RouteCode = @RouteCode)) AND
				((@FacilityRouteCode = '*') OR (CIDH.FacilityRouteCode = @FacilityRouteCode)) AND
				((@MachineCode = '*') OR (CIDH.MachineCode = @MachineCode)) AND
				((@CategoryName = '*') OR (CIDH.CategoryName = @CategoryName)) AND
				((@CommInspTypeCode = '*') OR (CIDH.CommInspTypeCode = @CommInspTypeCode))
		GROUP BY
				CIMH.MeasureSeq,
				CIDH.JobDate,
				CIDH.ShiftCode
				
		SET @Index = @Index + 1 	
    END
    
	IF (SELECT COUNT(*) FROM @WeightHist) <= 0 BEGIN
			RAISERROR('데이터가 존재하지 않습니다',16,1)
			RETURN
	END
    
	DECLARE @xrCnt INT	
	DECLARE @MeasureTable table
	(
		JobDate DATE,
		ShiftCode VARCHAR(1),
		MeasureValue NUMERIC(20,4)
	)
	
	INSERT @MeasureTable
	SELECT
			WH.JobDate,
			WH.ShiftCode,
			AVG(NULLIF(WH.[Weight],0)) AS MeasureValue
	FROM
			@WeightHist WH
	GROUP BY
			WH.JobDate,
			WH.ShiftCode
    SET @xrCnt = (SELECT COUNT(*) FROM @MeasureTable)
    
    --X ,R 관리도 테이블 변수에 저장
	DECLARE @tb_XManagement TABLE
	(
		ShiftDate VARCHAR(20),
		JobDate DATE,
		ShiftCode VARCHAR(1),
		MeasureValue NUMERIC(20,5),
		UCL NUMERIC(20,5),
		LCL NUMERIC(20,5),
		X NUMERIC(20,5)
	)
	
	DECLARE @tb_RManagement TABLE
	(
		ShiftDate VARCHAR(20),
		JobDate DATE,
		ShiftCode VARCHAR(1),
		R NUMERIC(20,5),
		UCL NUMERIC(20,5),
		CL NUMERIC(20,5)
	)
	
	
	INSERT @tb_XManagement
	SELECT
			SUBSTRING(CONVERT(VARCHAR(10),Master.JobDate,120),6,5) + UPPER(Master.ShiftCode) AS ShiftDate,
			Master.JobDate,
			UPPER(Master.ShiftCode),
			ISNULL(Master.MeasureValue,0),
			ISNULL(Detail.UCL,0),
			ISNULL(Detail.LCL,0),
			ISNULL(Detail.X,0)
	FROM
			(
				SELECT
						WH.JobDate,
						WH.ShiftCode,
						AVG(NULLIF(WH.[Weight],0)) AS MeasureValue
				FROM
						@WeightHist WH
				GROUP BY
						WH.JobDate,
						WH.ShiftCode
			)Master
			CROSS JOIN
			(
				SELECT
						AVG(NULLIF(SUB.XBar,0)) + (0.48 * (SUM(SUB.R) / @xrCnt)) AS UCL,
						AVG(NULLIF(SUB.XBar,0)) - (0.48 * (SUM(SUB.R) / @xrCnt)) AS LCL,
						((AVG(NULLIF(SUB.XBar,0)) + (0.48 * (SUM(SUB.R) / @xrCnt))) + (AVG(NULLIF(SUB.XBar,0)) - (0.48 * (SUM(SUB.R) / @xrCnt)))) / 2 AS X
				FROM
						(
							SELECT
									WH.JobDate,
									WH.ShiftCode,
									AVG(NULLIF(WH.[Weight],0)) AS XBar,
									(MAX(WH.[Weight]) - MIN(NULLIF(WH.[Weight],0))) AS R
							FROM
									@WeightHist WH
							GROUP BY
									WH.JobDate,
									WH.ShiftCode

							)SUB
			)Detail
	WHERE
			Master.MeasureValue IS NOT NULL
	ORDER BY
			Master.JobDate,
			Master.ShiftCode
			
	
	
	INSERT @tb_RManagement
	SELECT
			SUBSTRING(CONVERT(VARCHAR(10),Master.JobDate,120),6,5) + UPPER(Master.ShiftCode) AS ShiftDate,
			Master.JobDate,
			Master.ShiftCode,
			ISNULL(Master.R,0),
			ISNULL(Detail.UCL,0),
			ISNULL(Detail.CL,0)
	FROM
			(
				SELECT
						WH.JobDate,
						WH.ShiftCode,
						(MAX(WH.[Weight]) - MIN(NULLIF(WH.[Weight],0))) AS R 
				FROM
						@WeightHist WH
				GROUP BY
						WH.JobDate,
						WH.ShiftCode
			)Master
			CROSS JOIN
			(
				SELECT
						(2.00 *(SUM(SUB.R) / 4)) AS UCL,
						(SUM(SUB.R) / @xrCnt) AS CL
				FROM
						(
							SELECT
									WH.JobDate,
									WH.ShiftCode,
									(MAX(WH.[Weight]) - MIN(NULLIF(WH.[Weight],0))) AS R
							FROM
									@WeightHist WH
							GROUP BY
									WH.JobDate,
									WH.ShiftCode
							)SUB
			)Detail
	WHERE
			Master.R IS NOT NULL
	ORDER BY
			Master.JobDate,
			Master.ShiftCode
	
	
	
	--개별스펙여부 확인 및 스펙가져오기
	
	DECLARE @CommInspItemCode VARCHAR(20)
	DECLARE @IsIndividualSpec BIT
	DECLARE @X_USL NUMERIC(20,5)
	DECLARE @X_LSL NUMERIC(20,5)
	--DECLARE @X_CL NUMERIC(20,5)
	
	SELECT
			TOP 1
			@CommInspItemCode = CIDI.CommInspItemCode,
			@IsIndividualSpec = CONVERT(BIT,ISNULL(CII.IsIndividualSpec,0)),
			@X_USL = CASE WHEN ISNULL(CII.CommInspUpper,'') = '' THEN 0 ELSE CII.CommInspUpper END,
			@X_LSL = CASE WHEN ISNULL(CII.CommInspLower,'') = '' THEN 0 ELSE CII.CommInspLower END
	FROM
			STB_CommInspDocHistory CIDH
			LEFT OUTER JOIN STB_CommInspDocItem CIDI 				ON CIDI.CommInspDocNo = CIDH.CommInspDocNo
			LEFT OUTER JOIN STB_CommInspItem CII				ON CII.CommInspItemCode = CIDI.CommInspItemCode
	WHERE





			((CIDH.JobDate = @ToDate)) AND
			((CIDH.ShiftCode = @ToShiftCode)) AND
			((@CompanyCode = '*') OR (CIDH.CompanyCode = @CompanyCode)) AND
			((@WorkCenterCode = '*') OR (CIDH.WorkCenterCode = @WorkCenterCode)) AND
			((@MoldNumber = '*') OR (CIDH.MoldNumber = @MoldNumber)) AND
			((@MaterialCode = '*') OR (CIDH.MaterialCode = @MaterialCode)) AND
			((@RouteCode  = '*') OR (CIDH.RouteCode = @RouteCode)) AND
			((@FacilityRouteCode = '*') OR (CIDH.FacilityRouteCode = @FacilityRouteCode)) AND
			((@MachineCode = '*') OR (CIDH.MachineCode = @MachineCode)) AND
			((@CategoryName = '*') OR (CIDH.CategoryName = @CategoryName)) AND
			((@CommInspTypeCode = '*') OR (CIDH.CommInspTypeCode = @CommInspTypeCode))
	
	IF @IsIndividualSpec = 1 BEGIN
	
		SELECT
				@X_USL = CIIS.CommInspUpper,
				@X_LSL = CIIS.CommInspLower
		FROM
				STB_CommInspIndividualSpec CIIS
				LEFT OUTER JOIN STB_CommInspItem CII 
					ON CII.CommInspItemCode = CIIS.CommInspItemCode
		WHERE
				((@CompanyCode = '*') OR (CIIS.CompanyCode = @CompanyCode)) AND
				((@WorkCenterCode = '*') OR (CIIS.WorkCenterCode = @WorkCenterCode)) AND
				(((@RouteCode = '*') OR (CIIS.RouteCode = @RouteCode)) OR (ISNULL(CIIS.RouteCode, '') = '')) AND
				(((@FacilityRouteCode = '*') OR (CIIS.FacilityRouteCode = @FacilityRouteCode)) OR (ISNULL(CIIS.FacilityRouteCode, '') = '')) AND
				(((@MachineCode = '*') OR (CIIS.MachineCode = @MachineCode)) OR (ISNULL(CIIS.MachineCode, '') = '')) AND
				(((@MoldNumber = '*') OR (CIIS.MoldNumber = @MoldNumber)) OR (ISNULL(CIIS.MoldNumber, '') = '')) AND
				(((@MaterialCode = '*') OR (CIIS.MaterialCode = @MaterialCode)) OR (ISNULL(CIIS.MaterialCode, '') = '')) AND 
				(((@CategoryName = '*') OR (CIIS.CategoryName = @CategoryName)) OR (ISNULL(CIIS.CategoryName, '') = '')) AND
				((@CommInspTypeCode = '*') OR (CII.CommInspTypeCode = @CommInspTypeCode))
		
	END
	
	
	--X,R 관리도 (첫번째테이블)
	SELECT
			X.ShiftDate,
			X.JobDate,
			X.ShiftCode,
			X.MeasureValue,
			X.UCL,
			X.LCL,
			X.X,
			@X_USL AS USL,
			@X_LSL AS LSL,
			R.R,
			R.UCL AS R_UCL,
			R.CL AS R_CL
	FROM
			@tb_XManagement X
			LEFT OUTER JOIN @tb_RManagement R
				ON X.JobDate = R.JobDate
				AND X.ShiftCode = R.ShiftCode
				AND X.ShiftDate = R.ShiftDate
	
	
	
	
	
	
	
	DECLARE @Real_Mean NUMERIC(20,5),
			@Real_Stdev NUMERIC(20,5),
			@Real_LSL NUMERIC(20,5),
			@Real_USL NUMERIC(20,5),
			@Real_MAX NUMERIC(20,5),
			@Real_MIN NUMERIC(20,5)
	
	DECLARE @DefectProbability NUMERIC(20,4),	--불량확률(%)	
			@Cpk NUMERIC(20,4),
			@Cpu NUMERIC(20,4),
			@Cpl NUMERIC(20,4),
			@Cp NUMERIC(20,4),
			
			@X_UCL NUMERIC(20,4),
			@X_LCL NUMERIC(20,4),
			@R_UCL NUMERIC(20,4),
			@R_CL NUMERIC(20,4),
			@X_CL NUMERIC(20,4)		
			
	
	SELECT
			@X_UCL = AVG(SUB.XBar) + (@A2 * AVG(Sub.R)),
			@X_LCL = AVG(SUB.XBar) - (@A2 * AVG(Sub.R))
	FROM
			(
				SELECT
						WH.JobDate,
						WH.ShiftCode,
						AVG(WH.[Weight]) AS XBar,
						(MAX(WH.[Weight]) - MIN(WH.[Weight])) AS R
				FROM
						@WeightHist WH
				WHERE
						WH.[Weight] IS NOT NULL
				GROUP BY
						WH.JobDate,
						WH.ShiftCode
			)SUB
			
			
	--2번째, 3번째 테이블(Histogram)
	exec usp_HistogramHelper	@pCompanyCode = @CompanyCode,
								@pWorkCenterCode = @WorkCenterCode,
								@pTargetDate = @TargetDate,
								@pShiftCode = @ShiftCode,
								@pMoldNumber = @MoldNumber,
								@pMaterialCode = @MaterialCode,
								@pCommInspTypeCode = @CommInspTypeCode,
								@pRouteCode = @RouteCode,
								@pFacilityRouteCode = @FacilityRouteCode,
								@pMachineCode = @MachineCode,
								@pCategoryName = @CategoryName,
								@pPreUCL = @X_UCL,
								@pPreLCL = @X_LCL,
								@pX_USL = @X_USL,
								@pX_LSL = @X_LSL,
								@Mean = @Real_Mean OUTPUT,
								@Stdev = @Real_Stdev OUTPUT,
								@LSL = @Real_LSL OUTPUT,
								@USL = @Real_USL OUTPUT,
								@Max_Measure = @Real_MAX OUTPUT,
								@Min_Measure = @Real_MIN OUTPUT
								
	
	--XBar UCL, XBar CL, XBar LCL, R UCL, R CL 구하기
					
	SELECT
			@R_UCL = @D4 * AVG(Sub.R),
			@R_CL = AVG(Sub.R),
			@X_CL = AVG(Sub.XBar)
	FROM
			(
				SELECT
						WH.JobDate,
						WH.ShiftCode,
						AVG(WH.[Weight]) AS XBar,
						(MAX(WH.[Weight]) - MIN(WH.[Weight])) AS R
				FROM
						@WeightHist WH
				GROUP BY
						WH.JobDate,
						WH.ShiftCode
			)SUB

			
	IF (@Real_Stdev > 0) OR (@Real_Stdev < 0) BEGIN
		--Cpu구하기
		
		SET @Cpu = (@Real_USL - @Real_Mean) / (3.0 * @Real_Stdev)
		
			
		--Cpl구하기
			
		SET @Cpl = (@Real_Mean - @Real_LSL) / (3.0 * @Real_Stdev)
		
		
			
		--Cp구하기
		SET @CP = ((@Real_USL-@Real_Mean) - (-(@Real_Mean-@Real_LSL)))/(6.0 * @Real_Stdev)
	END
	ELSE BEGIN
		SET @Cpu = 0
		SET @Cpl = 0
		SET @Cp = 0
	END
	
	
	--Cpk구하기
	SET @CPK = CASE WHEN @Cpu > @Cpl THEN @Cpl
				ELSE @Cpu END
				
	--불량확률(%)
	
	SET @DefectProbability =  (1-dbo.fnNORMDIST2(@Real_USL,@Real_Mean,@Real_Stdev,1)+dbo.fnNORMDIST2(@Real_LSL,@Real_Mean,@Real_Stdev,1) )
							
						
	--4번째 테이블
	SELECT
			'불량확률(%)' AS ITEM,
			@DefectProbability*100.0 AS VALUE
	UNION ALL

	SELECT
			'Cpk' AS ITEM,
			@CPK AS VALUE		
	UNION ALL

	SELECT
			'Cpu' AS ITEM,
			@Cpu AS VALUE
	UNION ALL

	SELECT
			'Cpl' AS ITEM,
			@Cpl AS VALUE
	UNION ALL

	SELECT
			'Cp' AS ITEM,
			@CP AS VALUE
	UNION ALL

	SELECT
			'최대값' AS ITEM,
			@Real_MAX AS VALUE
	UNION ALL

	SELECT
			'최소값' AS ITEM,
			@Real_MIN AS VALUE
	UNION ALL

	SELECT
			'평균(X)' AS ITEM,
			@Real_Mean AS VALUE
	UNION ALL

	SELECT
			'표준편차' AS ITEM,
			@Real_Stdev AS VALUE
	UNION ALL

	SELECT
			'X_UCL' AS ITEM,
			@X_UCL AS VALUE
	UNION ALL

	SELECT
			'X_CL' AS ITEM,
			@X_CL AS VALUE
	UNION ALL

	SELECT
			'X_LCL' AS ITEM,
			@X_LCL AS VALUE
	UNION ALL

	SELECT
			'X_USL' AS ITEM,
			@X_USL AS VALUE
	UNION ALL

	SELECT
			'X_LSL' AS ITEM,
			@X_LSL AS VALUE
	UNION ALL

	SELECT
			'R_UCL' AS ITEM,
			@R_UCL AS VALUE
	UNION ALL

	SELECT
			'R_CL' AS ITEM,
			@R_CL AS VALUE
			
			
	--5번째 테이블
	SELECT
			@DefectProbability * 100.0 AS '불량확률(%)',
			@CPK AS 'Cpk',
			@Cpu AS 'Cpu',
			@Cpl AS 'Cpl',
			@CP AS 'Cp',
			@Real_MAX AS '최대값',
			@Real_MIN AS '최소값',
			@Real_Mean AS '평균(X)',
			@Real_Stdev AS '표준편차',
			@X_UCL AS 'X_UCL',
			@X_CL AS 'X_CL',
			@X_LCL AS 'X_LCL',
			@X_USL AS 'X_USL',
			@X_LSL AS 'X_LSL',
			@R_UCL AS 'R_UCL',
			@R_CL AS 'R_CL'			
	
	
	--Report 출력
	DECLARE @JobDateShiftInfo TABLE
	(
		RowNumber INT IDENTITY,
		JobDate DATE,
		ShiftCode VARCHAR(20)	
	)
	
	DECLARE @rowCnt INT,
			@rowNumber2 INT,
			@Job_Date DATE,
			@Shift_Code VARCHAR(20)
			
	DECLARE @WeightHistInfo TABLE
	(
		SeqNo INT IDENTITY,
		DateShift VARCHAR(20),
		Weight1 NUMERIC(20,5),
		Weight2 NUMERIC(20,5),
		Weight3 NUMERIC(20,5),
		Weight4 NUMERIC(20,5),
		Weight5 NUMERIC(20,5),
		Weight6 NUMERIC(20,5),
		Weight7 NUMERIC(20,5),
		Weight8 NUMERIC(20,5),
		Weight9 NUMERIC(20,5),
		Weight10 NUMERIC(20,5),
		Weight11 NUMERIC(20,5),
		Weight12 NUMERIC(20,5)
	)
	

	
	DECLARE @Report TABLE
	(
		SeqNo INT,
		Title VARCHAR(20),
		Weight1 NUMERIC(20,5),
		Weight2 NUMERIC(20,5),
		Weight3 NUMERIC(20,5),
		Weight4 NUMERIC(20,5),
		Weight5 NUMERIC(20,5),
		Weight6 NUMERIC(20,5),
		Weight7 NUMERIC(20,5),
		Weight8 NUMERIC(20,5),
		Weight9 NUMERIC(20,5),
		Weight10 NUMERIC(20,5),
		Weight11 NUMERIC(20,5),
		Weight12 NUMERIC(20,5),
		Weight13 NUMERIC(20,5),
		Weight14 NUMERIC(20,5),
		Weight15 NUMERIC(20,5),
		Weight16 NUMERIC(20,5),
		Weight17 NUMERIC(20,5),
		Weight18 NUMERIC(20,5),
		Weight19 NUMERIC(20,5),
		Weight20 NUMERIC(20,5),
		Weight21 NUMERIC(20,5),
		Weight22 NUMERIC(20,5),
		Weight23 NUMERIC(20,5),
		Weight24 NUMERIC(20,5),
		Weight25 NUMERIC(20,5),
		Weight26 NUMERIC(20,5),
		Weight27 NUMERIC(20,5),
		Weight28 NUMERIC(20,5),
		Weight29 NUMERIC(20,5),
		Weight30 NUMERIC(20,5),
		Weight31 NUMERIC(20,5),
		Weight32 NUMERIC(20,5),
		Weight33 NUMERIC(20,5),
		Weight34 NUMERIC(20,5),
		Weight35 NUMERIC(20,5),
		Weight36 NUMERIC(20,5),
		Weight37 NUMERIC(20,5),
		Weight38 NUMERIC(20,5),
		Weight39 NUMERIC(20,5),
		Weight40 NUMERIC(20,5),
		Weight41 NUMERIC(20,5),
		Weight42 NUMERIC(20,5),
		Weight43 NUMERIC(20,5),
		Weight44 NUMERIC(20,5),
		Weight45 NUMERIC(20,5),
		Weight46 NUMERIC(20,5),
		Weight47 NUMERIC(20,5),
		Weight48 NUMERIC(20,5),
		Weight49 NUMERIC(20,5),
		Weight50 NUMERIC(20,5),
		Weight51 NUMERIC(20,5),
		Weight52 NUMERIC(20,5),
		Weight53 NUMERIC(20,5),
		Weight54 NUMERIC(20,5),
		Weight55 NUMERIC(20,5),
		Weight56 NUMERIC(20,5),
		Weight57 NUMERIC(20,5),
		Weight58 NUMERIC(20,5),
		Weight59 NUMERIC(20,5),
		Weight60 NUMERIC(20,5),
		Weight61 NUMERIC(20,5),
		Weight62 NUMERIC(20,5)
	)
	
	
	INSERT @JobDateShiftInfo
	SELECT
			Master.JobDate,
			Master.ShiftCode
	FROM
			(
				SELECT
						TOP 62
						CIDH.JobDate,
						CIDH.ShiftCode
				FROM
						STB_CommInspDocHistory CIDH            -- SELECT * FROM STB_CommInspDocHistory
				WHERE
						((CIDH.JobDate <= @TargetDate)) AND
						((@CompanyCode = '*') OR (CIDH.CompanyCode = @CompanyCode)) AND
						((@WorkCenterCode = '*') OR (CIDH.WorkCenterCode = @WorkCenterCode)) AND
						((@ShiftCode = '*') OR (CIDH.ShiftCode = @ShiftCode)) AND
						((@MoldNumber = '*') OR (CIDH.MoldNumber = @MoldNumber)) AND
						((@MaterialCode = '*') OR (CIDH.MaterialCode = @MaterialCode)) AND
						((@RouteCode  = '*') OR (CIDH.RouteCode = @RouteCode)) AND
						((@FacilityRouteCode = '*') OR (CIDH.FacilityRouteCode = @FacilityRouteCode)) AND
						((@MachineCode = '*') OR (CIDH.MachineCode = @MachineCode)) AND
						((@CategoryName = '*') OR (CIDH.CategoryName = @CategoryName)) AND
						((@CommInspTypeCode = '*') OR (CIDH.CommInspTypeCode = @CommInspTypeCode))
				ORDER BY
						CIDH.JobDate DESC,
						CIDH.ShiftCode DESC
			)Master
	
	ORDER BY
			Master.JobDate,
			Master.ShiftCode
	
	SET @rowCnt = (SELECT COUNT(*) FROM @JobDateShiftInfo)
	DECLARE @initNumber INT
	SET @initNumber = 1
	
	
	DECLARE @tbCommInspMeasureHist TABLE (SeqNo INT, MeasureWeight NUMERIC(20,5))
	
	WHILE(@initNumber <= @rowCnt) BEGIN
		
		DELETE FROM @tbCommInspMeasureHist
		
		SELECT
				@Job_Date = JobDate,
				@Shift_Code = ShiftCode
		FROM
				@JobDateShiftInfo 
		WHERE
				RowNumber = @initNumber
			
				
		INSERT @tbCommInspMeasureHist
		SELECT
				ROW_NUMBER() OVER (ORDER BY MeasureSeq) AS SeqNo,
				CIMH.NumericMeasure
		FROM
				STB_CommInspDocHistory CIDH 
				LEFT OUTER JOIN STB_CommInspDocItem CIDI 
					ON CIDI.CommInspDocNo = CIDH.CommInspDocNo
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH 
					ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo
		WHERE
				((CIDH.JobDate = @Job_Date)) AND
				((CIDH.ShiftCode = @Shift_Code)) AND
				((@CompanyCode = '*') OR (CIDH.CompanyCode = @CompanyCode)) AND
				((@WorkCenterCode = '*') OR (CIDH.WorkCenterCode = @WorkCenterCode)) AND
				((@MoldNumber = '*') OR (CIDH.MoldNumber = @MoldNumber)) AND
				((@MaterialCode = '*') OR (CIDH.MaterialCode = @MaterialCode)) AND
				((@RouteCode  = '*') OR (CIDH.RouteCode = @RouteCode)) AND
				((@FacilityRouteCode = '*') OR (CIDH.FacilityRouteCode = @FacilityRouteCode)) AND
				((@MachineCode = '*') OR (CIDH.MachineCode = @MachineCode)) AND
				((@CategoryName = '*') OR (CIDH.CategoryName = @CategoryName)) AND
				((@CommInspTypeCode = '*') OR (CIDH.CommInspTypeCode = @CommInspTypeCode))
				
		INSERT INTO @WeightHistInfo
		SELECT
				SUBSTRING(CONVERT(VARCHAR(10),@Job_Date,120),6,5) + UPPER(@Shift_Code),
				(SELECT ISNULL(MeasureWeight,0) FROM @tbCommInspMeasureHist WHERE SeqNo = 1),
				(SELECT ISNULL(MeasureWeight,0) FROM @tbCommInspMeasureHist WHERE SeqNo = 2),
				(SELECT ISNULL(MeasureWeight,0) FROM @tbCommInspMeasureHist WHERE SeqNo = 3),
				(SELECT ISNULL(MeasureWeight,0) FROM @tbCommInspMeasureHist WHERE SeqNo = 4),
				(SELECT ISNULL(MeasureWeight,0) FROM @tbCommInspMeasureHist WHERE SeqNo = 5),
				(SELECT ISNULL(MeasureWeight,0) FROM @tbCommInspMeasureHist WHERE SeqNo = 6),
				(SELECT ISNULL(MeasureWeight,0) FROM @tbCommInspMeasureHist WHERE SeqNo = 7),
				(SELECT ISNULL(MeasureWeight,0) FROM @tbCommInspMeasureHist WHERE SeqNo = 8),
				(SELECT ISNULL(MeasureWeight,0) FROM @tbCommInspMeasureHist WHERE SeqNo = 9),
				(SELECT ISNULL(MeasureWeight,0) FROM @tbCommInspMeasureHist WHERE SeqNo = 10),
				(SELECT ISNULL(MeasureWeight,0) FROM @tbCommInspMeasureHist WHERE SeqNo = 11),
				(SELECT ISNULL(MeasureWeight,0) FROM @tbCommInspMeasureHist WHERE SeqNo = 12)
				
		SET @initNumber = @initNumber + 1
	END
	
	DECLARE @Report2 TABLE
	(
		SeqNo INT,
		Title VARCHAR(20),
		[1] VARCHAR(20),
		[2] VARCHAR(20),
		[3] VARCHAR(20),
		[4] VARCHAR(20),
		[5] VARCHAR(20),
		[6] VARCHAR(20),
		[7] VARCHAR(20),
		[8] VARCHAR(20),
		[9] VARCHAR(20),
		[10] VARCHAR(20),
		[11] VARCHAR(20),
		[12] VARCHAR(20),
		[13] VARCHAR(20),
		[14] VARCHAR(20),
		[15] VARCHAR(20),
		[16] VARCHAR(20),
		[17] VARCHAR(20),
		[18] VARCHAR(20),
		[19] VARCHAR(20),
		[20] VARCHAR(20),
		[21] VARCHAR(20),
		[22] VARCHAR(20),
		[23] VARCHAR(20),
		[24] VARCHAR(20),
		[25] VARCHAR(20),
		[26] VARCHAR(20),
		[27] VARCHAR(20),
		[28] VARCHAR(20),
		[29] VARCHAR(20),
		[30] VARCHAR(20),
		[31] VARCHAR(20),
		[32] VARCHAR(20),
		[33] VARCHAR(20),
		[34] VARCHAR(20),
		[35] VARCHAR(20),
		[36] VARCHAR(20),
		[37] VARCHAR(20),
		[38] VARCHAR(20),
		[39] VARCHAR(20),
		[40] VARCHAR(20),
		[41] VARCHAR(20),
		[42] VARCHAR(20),
		[43] VARCHAR(20),
		[44] VARCHAR(20),
		[45] VARCHAR(20),
		[46] VARCHAR(20),
		[47] VARCHAR(20),
		[48] VARCHAR(20),
		[49] VARCHAR(20),
		[50] VARCHAR(20),
		[51] VARCHAR(20),
		[52] VARCHAR(20),
		[53] VARCHAR(20),
		[54] VARCHAR(20),
		[55] VARCHAR(20),
		[56] VARCHAR(20),
		[57] VARCHAR(20),
		[58] VARCHAR(20),
		[59] VARCHAR(20),
		[60] VARCHAR(20),
		[61] VARCHAR(20),
		[62] VARCHAR(20)
	)
	
	
	DECLARE @Report3 TABLE
	(
		SeqNo INT,
		Title VARCHAR(20),
		[1] VARCHAR(20),
		[2] VARCHAR(20),
		[3] VARCHAR(20),
		[4] VARCHAR(20),
		[5] VARCHAR(20),
		[6] VARCHAR(20),
		[7] VARCHAR(20),
		[8] VARCHAR(20),
		[9] VARCHAR(20),
		[10] VARCHAR(20),
		[11] VARCHAR(20),
		[12] VARCHAR(20),
		[13] VARCHAR(20),
		[14] VARCHAR(20),
		[15] VARCHAR(20),
		[16] VARCHAR(20),
		[17] VARCHAR(20),
		[18] VARCHAR(20),
		[19] VARCHAR(20),
		[20] VARCHAR(20),
		[21] VARCHAR(20),
		[22] VARCHAR(20),
		[23] VARCHAR(20),
		[24] VARCHAR(20),
		[25] VARCHAR(20),
		[26] VARCHAR(20),
		[27] VARCHAR(20),
		[28] VARCHAR(20),
		[29] VARCHAR(20),
		[30] VARCHAR(20),
		[31] VARCHAR(20),
		[32] VARCHAR(20),
		[33] VARCHAR(20),
		[34] VARCHAR(20),
		[35] VARCHAR(20),
		[36] VARCHAR(20),
		[37] VARCHAR(20),
		[38] VARCHAR(20),
		[39] VARCHAR(20),
		[40] VARCHAR(20),
		[41] VARCHAR(20),
		[42] VARCHAR(20),
		[43] VARCHAR(20),
		[44] VARCHAR(20),
		[45] VARCHAR(20),
		[46] VARCHAR(20),
		[47] VARCHAR(20),
		[48] VARCHAR(20),
		[49] VARCHAR(20),
		[50] VARCHAR(20),
		[51] VARCHAR(20),
		[52] VARCHAR(20),
		[53] VARCHAR(20),
		[54] VARCHAR(20),
		[55] VARCHAR(20),
		[56] VARCHAR(20),
		[57] VARCHAR(20),
		[58] VARCHAR(20),
		[59] VARCHAR(20),
		[60] VARCHAR(20),
		[61] VARCHAR(20),
		[62] VARCHAR(20)
	)
	
	INSERT @Report2
	SELECT
			*
	FROM	
	(
		SELECT
				1 AS SeqNo,
				'' AS Title,
				(SELECT SUBSTRING(DateShift,4,3) FROM @WeightHistInfo WHERE SeqNo = 1) AS [1],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 2) AS [2],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 3) AS [3],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 4) AS [4],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 5) AS [5],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 6) AS [6],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 7) AS [7],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 8) AS [8],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 9) AS [9],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 10) AS [10],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 11) AS [11],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 12) AS [12],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 13) AS [13],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 14) AS [14],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 15) AS [15],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 16) AS [16],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 17) AS [17],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 18) AS [18],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 19) AS [19],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 20) AS [20],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 21) AS [21],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 22) AS [22],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 23) AS [23],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 24) AS [24],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 25) AS [25],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 26) AS [26],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 27) AS [27],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 28) AS [28],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 29) AS [29],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 30) AS [30],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 31) AS [31],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 32) AS [32],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 33) AS [33],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 34) AS [34],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 35) AS [35],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 36) AS [36],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 37) AS [37],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 38) AS [38],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 39) AS [39],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 40) AS [40],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 41) AS [41],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 42) AS [42],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 43) AS [43],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 44) AS [44],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 45) AS [45],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 46) AS [46],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 47) AS [47],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 48) AS [48],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 49) AS [49],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 50) AS [50],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 51) AS [51],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 52) AS [52],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 53) AS [53],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 54) AS [54],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 55) AS [55],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 56) AS [56],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 57) AS [57],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 58) AS [58],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 59) AS [59],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 60) AS [60],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 61) AS [61],
				(SELECT SUBSTRING(DateShift,4,3)  FROM @WeightHistInfo WHERE SeqNo = 62) AS [62]
		UNION ALL  
		SELECT
				2 AS SeqNo,
				'Weight1' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight1
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight1)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		   
		UNION ALL
		SELECT
				3 AS SeqNo,
				'Weight2' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight2
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight2)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv

		UNION ALL
		SELECT
				4 AS SeqNo,
				'Weight3' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
				
		FROM
			  (SELECT
					SeqNo,
					Weight3
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight3)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
 
		UNION ALL
		SELECT
			  5 AS SeqNo,
			  'Weight4' AS Title,
			   CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight4
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight4)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv

		UNION ALL
		SELECT
				6 AS SeqNo,
				'Weight5' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight5
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight5)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv

		UNION ALL
		SELECT
				7 AS SeqNo,
				'Weight6' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight6
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight6)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		
		UNION ALL
		SELECT
				8 AS SeqNo,
				'Weight7' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight7
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight7)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		
		UNION ALL
		SELECT
				9 AS SeqNo,
				'Weight8' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight8
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight8)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		
		UNION ALL
		SELECT
				10 AS SeqNo,
				'Weight9' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight9
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight9)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		
		UNION ALL
		SELECT
				11 AS SeqNo,
				'Weight10' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight10
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight10)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		
		UNION ALL
		SELECT
				12 AS SeqNo,
				'Weight11' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight11
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight11)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		
		UNION ALL
		SELECT
				13 AS SeqNo,
				'Weight12' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight12
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight12)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		
	)Master


	
	--6번째 테이블
		SELECT
				SeqNo,
				Title,
				[1],
				[2],
				[3],
				[4],
				[5],
				[6],
				[7],
				[8],
				[9],
				[10],
				[11],
				[12],
				[13],
				[14],
				[15],
				[16],
				[17],
				[18],
				[19],
				[20],
				[21],
				[22],
				[23],
				[24],
				[25],
				[26],
				[27],
				[28],
				[29],
				[30],
				[31],
				[32],
				[33],
				[34],
				[35],
				[36],
				[37],
				[38],
				[39],
				[40],
				[41],
				[42],
				[43],
				[44],
				[45],
				[46],
				[47],
				[48],
				[49],
				[50],
				[51],
				[52],
				[53],
				[54],
				[55],
				[56],
				[57],
				[58],
				[59],
				[60],
				[61],
				[62]
		FROM	
				@Report2
				
			
		UNION	
		SELECT
				14 AS SeqNo,
				'평균(X)' AS Title,
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[1],'0') = '0' THEN '0.0' ELSE R.[1] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[2],'0') = '0' THEN '0.0' ELSE R.[2] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[3],'0') = '0' THEN '0.0' ELSE R.[3] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[4],'0') = '0' THEN '0.0' ELSE R.[4] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[5],'0') = '0' THEN '0.0' ELSE R.[5] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[6],'0') = '0' THEN '0.0' ELSE R.[6] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[7],'0') = '0' THEN '0.0' ELSE R.[7] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[8],'0') = '0' THEN '0.0' ELSE R.[8] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[9],'0') = '0' THEN '0.0' ELSE R.[9] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[10],'0') = '0' THEN '0.0' ELSE R.[10] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[11],'0') = '0' THEN '0.0' ELSE R.[11] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[12],'0') = '0' THEN '0.0' ELSE R.[12] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[13],'0') = '0' THEN '0.0' ELSE R.[13] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[14],'0') = '0' THEN '0.0' ELSE R.[14] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[15],'0') = '0' THEN '0.0' ELSE R.[15] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[16],'0') = '0' THEN '0.0' ELSE R.[16] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[17],'0') = '0' THEN '0.0' ELSE R.[17] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[18],'0') = '0' THEN '0.0' ELSE R.[18] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[19],'0') = '0' THEN '0.0' ELSE R.[19] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[20],'0') = '0' THEN '0.0' ELSE R.[20] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[21],'0') = '0' THEN '0.0' ELSE R.[21] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[22],'0') = '0' THEN '0.0' ELSE R.[22] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[23],'0') = '0' THEN '0.0' ELSE R.[23] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[24],'0') = '0' THEN '0.0' ELSE R.[24] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[25],'0') = '0' THEN '0.0' ELSE R.[25] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[26],'0') = '0' THEN '0.0' ELSE R.[26] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[27],'0') = '0' THEN '0.0' ELSE R.[27] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[28],'0') = '0' THEN '0.0' ELSE R.[28] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[29],'0') = '0' THEN '0.0' ELSE R.[29] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[30],'0') = '0' THEN '0.0' ELSE R.[30] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[31],'0') = '0' THEN '0.0' ELSE R.[31] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[32],'0') = '0' THEN '0.0' ELSE R.[32] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[33],'0') = '0' THEN '0.0' ELSE R.[33] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[34],'0') = '0' THEN '0.0' ELSE R.[34] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[35],'0') = '0' THEN '0.0' ELSE R.[35] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[36],'0') = '0' THEN '0.0' ELSE R.[36] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[37],'0') = '0' THEN '0.0' ELSE R.[37] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[38],'0') = '0' THEN '0.0' ELSE R.[38] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[39],'0') = '0' THEN '0.0' ELSE R.[39] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[40],'0') = '0' THEN '0.0' ELSE R.[40] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[41],'0') = '0' THEN '0.0' ELSE R.[41] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[42],'0') = '0' THEN '0.0' ELSE R.[42] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[43],'0') = '0' THEN '0.0' ELSE R.[43] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[44],'0') = '0' THEN '0.0' ELSE R.[44] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[45],'0') = '0' THEN '0.0' ELSE R.[45] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[46],'0') = '0' THEN '0.0' ELSE R.[46] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[47],'0') = '0' THEN '0.0' ELSE R.[47] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[48],'0') = '0' THEN '0.0' ELSE R.[48] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[49],'0') = '0' THEN '0.0' ELSE R.[49] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[50],'0') = '0' THEN '0.0' ELSE R.[50] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[51],'0') = '0' THEN '0.0' ELSE R.[51] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[52],'0') = '0' THEN '0.0' ELSE R.[52] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[53],'0') = '0' THEN '0.0' ELSE R.[53] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[54],'0') = '0' THEN '0.0' ELSE R.[54] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[55],'0') = '0' THEN '0.0' ELSE R.[55] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[56],'0') = '0' THEN '0.0' ELSE R.[56] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[57],'0') = '0' THEN '0.0' ELSE R.[57] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[58],'0') = '0' THEN '0.0' ELSE R.[58] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[59],'0') = '0' THEN '0.0' ELSE R.[59] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[60],'0') = '0' THEN '0.0' ELSE R.[60] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[61],'0') = '0' THEN '0.0' ELSE R.[61] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[62],'0') = '0' THEN '0.0' ELSE R.[62] END),0)),1),20,1)))
		FROM
				@Report2 R 
		WHERE
				R.SeqNo <> 1
		UNION	
		SELECT
				15 AS SeqNo,
				'범위(R)' AS Title,
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[1],'0') = '0' THEN '0.0' ELSE R.[1] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[1],'0') = '0' THEN '0.0' ELSE R.[1] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[2],'0') = '0' THEN '0.0' ELSE R.[2] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[2],'0') = '0' THEN '0.0' ELSE R.[2] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[3],'0') = '0' THEN '0.0' ELSE R.[3] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[3],'0') = '0' THEN '0.0' ELSE R.[3] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[4],'0') = '0' THEN '0.0' ELSE R.[4] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[4],'0') = '0' THEN '0.0' ELSE R.[4] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[5],'0') = '0' THEN '0.0' ELSE R.[5] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[5],'0') = '0' THEN '0.0' ELSE R.[5] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[6],'0') = '0' THEN '0.0' ELSE R.[6] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[6],'0') = '0' THEN '0.0' ELSE R.[6] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[7],'0') = '0' THEN '0.0' ELSE R.[7] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[7],'0') = '0' THEN '0.0' ELSE R.[7] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[8],'0') = '0' THEN '0.0' ELSE R.[8] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[8],'0') = '0' THEN '0.0' ELSE R.[8] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[9],'0') = '0' THEN '0.0' ELSE R.[9] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[9],'0') = '0' THEN '0.0' ELSE R.[9] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[10],'0') = '0' THEN '0.0' ELSE R.[10] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[10],'0') = '0' THEN '0.0' ELSE R.[10] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[11],'0') = '0' THEN '0.0' ELSE R.[11] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[11],'0') = '0' THEN '0.0' ELSE R.[11] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[12],'0') = '0' THEN '0.0' ELSE R.[12] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[12],'0') = '0' THEN '0.0' ELSE R.[12] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[13],'0') = '0' THEN '0.0' ELSE R.[13] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[13],'0') = '0' THEN '0.0' ELSE R.[13] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[14],'0') = '0' THEN '0.0' ELSE R.[14] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[14],'0') = '0' THEN '0.0' ELSE R.[14] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[15],'0') = '0' THEN '0.0' ELSE R.[15] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[15],'0') = '0' THEN '0.0' ELSE R.[15] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[16],'0') = '0' THEN '0.0' ELSE R.[16] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[16],'0') = '0' THEN '0.0' ELSE R.[16] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[17],'0') = '0' THEN '0.0' ELSE R.[17] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[17],'0') = '0' THEN '0.0' ELSE R.[17] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[18],'0') = '0' THEN '0.0' ELSE R.[18] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[18],'0') = '0' THEN '0.0' ELSE R.[18] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[19],'0') = '0' THEN '0.0' ELSE R.[19] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[19],'0') = '0' THEN '0.0' ELSE R.[19] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[20],'0') = '0' THEN '0.0' ELSE R.[20] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[20],'0') = '0' THEN '0.0' ELSE R.[20] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[21],'0') = '0' THEN '0.0' ELSE R.[21] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[21],'0') = '0' THEN '0.0' ELSE R.[21] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[22],'0') = '0' THEN '0.0' ELSE R.[22] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[22],'0') = '0' THEN '0.0' ELSE R.[22] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[23],'0') = '0' THEN '0.0' ELSE R.[23] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[23],'0') = '0' THEN '0.0' ELSE R.[23] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[24],'0') = '0' THEN '0.0' ELSE R.[24] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[24],'0') = '0' THEN '0.0' ELSE R.[24] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[25],'0') = '0' THEN '0.0' ELSE R.[25] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[25],'0') = '0' THEN '0.0' ELSE R.[25] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[26],'0') = '0' THEN '0.0' ELSE R.[26] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[26],'0') = '0' THEN '0.0' ELSE R.[26] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[27],'0') = '0' THEN '0.0' ELSE R.[27] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[27],'0') = '0' THEN '0.0' ELSE R.[27] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[28],'0') = '0' THEN '0.0' ELSE R.[28] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[28],'0') = '0' THEN '0.0' ELSE R.[28] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[29],'0') = '0' THEN '0.0' ELSE R.[29] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[29],'0') = '0' THEN '0.0' ELSE R.[29] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[30],'0') = '0' THEN '0.0' ELSE R.[30] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[30],'0') = '0' THEN '0.0' ELSE R.[30] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[31],'0') = '0' THEN '0.0' ELSE R.[31] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[31],'0') = '0' THEN '0.0' ELSE R.[31] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[32],'0') = '0' THEN '0.0' ELSE R.[32] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[32],'0') = '0' THEN '0.0' ELSE R.[32] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[33],'0') = '0' THEN '0.0' ELSE R.[33] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[33],'0') = '0' THEN '0.0' ELSE R.[33] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[34],'0') = '0' THEN '0.0' ELSE R.[34] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[34],'0') = '0' THEN '0.0' ELSE R.[34] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[35],'0') = '0' THEN '0.0' ELSE R.[35] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[35],'0') = '0' THEN '0.0' ELSE R.[35] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[36],'0') = '0' THEN '0.0' ELSE R.[36] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[36],'0') = '0' THEN '0.0' ELSE R.[36] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[37],'0') = '0' THEN '0.0' ELSE R.[37] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[37],'0') = '0' THEN '0.0' ELSE R.[37] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[38],'0') = '0' THEN '0.0' ELSE R.[38] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[38],'0') = '0' THEN '0.0' ELSE R.[38] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[39],'0') = '0' THEN '0.0' ELSE R.[39] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[39],'0') = '0' THEN '0.0' ELSE R.[39] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[40],'0') = '0' THEN '0.0' ELSE R.[40] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[40],'0') = '0' THEN '0.0' ELSE R.[40] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[41],'0') = '0' THEN '0.0' ELSE R.[41] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[41],'0') = '0' THEN '0.0' ELSE R.[41] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[42],'0') = '0' THEN '0.0' ELSE R.[42] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[42],'0') = '0' THEN '0.0' ELSE R.[42] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[43],'0') = '0' THEN '0.0' ELSE R.[43] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[43],'0') = '0' THEN '0.0' ELSE R.[43] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[44],'0') = '0' THEN '0.0' ELSE R.[44] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[44],'0') = '0' THEN '0.0' ELSE R.[44] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[45],'0') = '0' THEN '0.0' ELSE R.[45] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[45],'0') = '0' THEN '0.0' ELSE R.[45] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[46],'0') = '0' THEN '0.0' ELSE R.[46] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[46],'0') = '0' THEN '0.0' ELSE R.[46] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[47],'0') = '0' THEN '0.0' ELSE R.[47] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[47],'0') = '0' THEN '0.0' ELSE R.[47] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[48],'0') = '0' THEN '0.0' ELSE R.[48] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[48],'0') = '0' THEN '0.0' ELSE R.[48] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[49],'0') = '0' THEN '0.0' ELSE R.[49] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[49],'0') = '0' THEN '0.0' ELSE R.[49] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[50],'0') = '0' THEN '0.0' ELSE R.[50] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[50],'0') = '0' THEN '0.0' ELSE R.[50] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[51],'0') = '0' THEN '0.0' ELSE R.[51] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[51],'0') = '0' THEN '0.0' ELSE R.[51] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[52],'0') = '0' THEN '0.0' ELSE R.[52] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[52],'0') = '0' THEN '0.0' ELSE R.[52] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[53],'0') = '0' THEN '0.0' ELSE R.[53] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[53],'0') = '0' THEN '0.0' ELSE R.[53] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[54],'0') = '0' THEN '0.0' ELSE R.[54] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[54],'0') = '0' THEN '0.0' ELSE R.[54] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[55],'0') = '0' THEN '0.0' ELSE R.[55] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[55],'0') = '0' THEN '0.0' ELSE R.[55] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[56],'0') = '0' THEN '0.0' ELSE R.[56] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[56],'0') = '0' THEN '0.0' ELSE R.[56] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[57],'0') = '0' THEN '0.0' ELSE R.[57] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[57],'0') = '0' THEN '0.0' ELSE R.[57] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[58],'0') = '0' THEN '0.0' ELSE R.[58] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[58],'0') = '0' THEN '0.0' ELSE R.[58] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[59],'0') = '0' THEN '0.0' ELSE R.[59] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[59],'0') = '0' THEN '0.0' ELSE R.[59] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[60],'0') = '0' THEN '0.0' ELSE R.[60] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[60],'0') = '0' THEN '0.0' ELSE R.[60] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[61],'0') = '0' THEN '0.0' ELSE R.[61] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[61],'0') = '0' THEN '0.0' ELSE R.[61] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[62],'0') = '0' THEN '0.0' ELSE R.[62] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[62],'0') = '0' THEN '0.0' ELSE R.[62] END),0)),1),20,1)))
		FROM
				@Report2 R 
		WHERE
				R.SeqNo <> 1
		
	
			
		--Report 헤더 정보(검색조건정보)	
	
		SELECT
				@WorkCenterName = WCI.WorkCenterName
		FROM
				STB_WorkCenterInfo WCI 
		WHERE
				WCI.WorkCenterCode = @WorkCenterCode
				
		SELECT
				@MaterialName = MM.MaterialName
		FROM
				STB_MaterialMaster MM
		WHERE
				MM.MaterialCode = @MaterialCode
				
		--7번째	테이블	
		SELECT
				@WorkCenterName AS WorkCenterName,
				@FromDate AS FromDate,
				@ToDate AS ToDate,
				@MoldNumber AS MoldNumber,
				@MaterialCode AS MaterialCode,
				@MaterialName AS MaterialName
				
				
				
		
		
		
	INSERT @Report3
	SELECT
			*
	FROM	
	(
		SELECT
				1 AS SeqNo,
				'' AS Title,
				(SELECT DateShift FROM @WeightHistInfo WHERE SeqNo = 1) AS [1],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 2) AS [2],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 3) AS [3],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 4) AS [4],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 5) AS [5],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 6) AS [6],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 7) AS [7],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 8) AS [8],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 9) AS [9],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 10) AS [10],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 11) AS [11],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 12) AS [12],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 13) AS [13],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 14) AS [14],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 15) AS [15],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 16) AS [16],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 17) AS [17],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 18) AS [18],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 19) AS [19],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 20) AS [20],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 21) AS [21],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 22) AS [22],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 23) AS [23],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 24) AS [24],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 25) AS [25],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 26) AS [26],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 27) AS [27],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 28) AS [28],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 29) AS [29],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 30) AS [30],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 31) AS [31],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 32) AS [32],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 33) AS [33],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 34) AS [34],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 35) AS [35],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 36) AS [36],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 37) AS [37],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 38) AS [38],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 39) AS [39],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 40) AS [40],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 41) AS [41],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 42) AS [42],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 43) AS [43],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 44) AS [44],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 45) AS [45],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 46) AS [46],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 47) AS [47],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 48) AS [48],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 49) AS [49],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 50) AS [50],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 51) AS [51],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 52) AS [52],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 53) AS [53],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 54) AS [54],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 55) AS [55],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 56) AS [56],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 57) AS [57],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 58) AS [58],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 59) AS [59],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 60) AS [60],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 61) AS [61],
				(SELECT DateShift  FROM @WeightHistInfo WHERE SeqNo = 62) AS [62]
		UNION ALL  
		SELECT
				2 AS SeqNo,
				'Weight1' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight1
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight1)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		   
		UNION ALL
		SELECT
				3 AS SeqNo,
				'Weight2' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight2
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight2)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv

		UNION ALL
		SELECT
				4 AS SeqNo,
				'Weight3' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
				
		FROM
			  (SELECT
					SeqNo,
					Weight3
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight3)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
 
		UNION ALL
		SELECT
			  5 AS SeqNo,
			  'Weight4' AS Title,
			   CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight4
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight4)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv

		UNION ALL
		SELECT
				6 AS SeqNo,
				'Weight5' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight5
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight5)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv

		UNION ALL
		SELECT
				7 AS SeqNo,
				'Weight6' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight6
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight6)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		
		UNION ALL
		SELECT
				8 AS SeqNo,
				'Weight7' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight7
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight7)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		
		UNION ALL
		SELECT
				9 AS SeqNo,
				'Weight8' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight8
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight8)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		
		UNION ALL
		SELECT
				10 AS SeqNo,
				'Weight9' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight9
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight9)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		
		UNION ALL
		SELECT
				11 AS SeqNo,
				'Weight10' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight10
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight10)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		
		UNION ALL
		SELECT
				12 AS SeqNo,
				'Weight11' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight11
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight11)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		
		UNION ALL
		SELECT
				13 AS SeqNo,
				'Weight12' AS Title,
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([1],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([2],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([3],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([4],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([5],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([6],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([7],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([8],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([9],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([10],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([11],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([12],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([13],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([14],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([15],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([16],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([17],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([18],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([19],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([20],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([21],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([22],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([23],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([24],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([25],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([26],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([27],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([28],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([29],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([30],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([31],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([32],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([33],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([34],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([35],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([36],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([37],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([38],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([39],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([40],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([41],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([42],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([43],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([44],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([45],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([46],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([47],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([48],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([49],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([50],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([51],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([52],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([53],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([54],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([55],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([56],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([57],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([58],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([59],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([60],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([61],1),20,1))),
				CONVERT(VARCHAR(20), LTRIM(STR(ROUND([62],1),20,1)))
		FROM
			  (SELECT
					SeqNo,
					Weight12
			  FROM
					@WeightHistInfo) ds
		PIVOT
		(
		   SUM(Weight12)
		   FOR SeqNo IN ( [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39], [40], [41], [42], [43], [44], [45], [46], [47], [48], [49], [50], [51], [52], [53], [54], [55], [56], [57], [58], [59], [60], [61], [62])
		) AS pv
		
	)Master


		
		
		--8번째 테이블
		
		SELECT
				SeqNo,
				Title,
				[1],
				[2],
				[3],
				[4],
				[5],
				[6],
				[7],
				[8],
				[9],
				[10],
				[11],
				[12],
				[13],
				[14],
				[15],
				[16],
				[17],
				[18],
				[19],
				[20],
				[21],
				[22],
				[23],
				[24],
				[25],
				[26],
				[27],
				[28],
				[29],
				[30],
				[31],
				[32],
				[33],
				[34],
				[35],
				[36],
				[37],
				[38],
				[39],
				[40],
				[41],
				[42],
				[43],
				[44],
				[45],
				[46],
				[47],
				[48],
				[49],
				[50],
				[51],
				[52],
				[53],
				[54],
				[55],
				[56],
				[57],
				[58],
				[59],
				[60],
				[61],
				[62]
		FROM	
				@Report3
				
			
		UNION	
		SELECT
				14 AS SeqNo,
				'평균(X)' AS Title,
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[1],'0') = '0' THEN '0.0' ELSE R.[1] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[2],'0') = '0' THEN '0.0' ELSE R.[2] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[3],'0') = '0' THEN '0.0' ELSE R.[3] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[4],'0') = '0' THEN '0.0' ELSE R.[4] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[5],'0') = '0' THEN '0.0' ELSE R.[5] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[6],'0') = '0' THEN '0.0' ELSE R.[6] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[7],'0') = '0' THEN '0.0' ELSE R.[7] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[8],'0') = '0' THEN '0.0' ELSE R.[8] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[9],'0') = '0' THEN '0.0' ELSE R.[9] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[10],'0') = '0' THEN '0.0' ELSE R.[10] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[11],'0') = '0' THEN '0.0' ELSE R.[11] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[12],'0') = '0' THEN '0.0' ELSE R.[12] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[13],'0') = '0' THEN '0.0' ELSE R.[13] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[14],'0') = '0' THEN '0.0' ELSE R.[14] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[15],'0') = '0' THEN '0.0' ELSE R.[15] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[16],'0') = '0' THEN '0.0' ELSE R.[16] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[17],'0') = '0' THEN '0.0' ELSE R.[17] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[18],'0') = '0' THEN '0.0' ELSE R.[18] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[19],'0') = '0' THEN '0.0' ELSE R.[19] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[20],'0') = '0' THEN '0.0' ELSE R.[20] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[21],'0') = '0' THEN '0.0' ELSE R.[21] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[22],'0') = '0' THEN '0.0' ELSE R.[22] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[23],'0') = '0' THEN '0.0' ELSE R.[23] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[24],'0') = '0' THEN '0.0' ELSE R.[24] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[25],'0') = '0' THEN '0.0' ELSE R.[25] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[26],'0') = '0' THEN '0.0' ELSE R.[26] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[27],'0') = '0' THEN '0.0' ELSE R.[27] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[28],'0') = '0' THEN '0.0' ELSE R.[28] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[29],'0') = '0' THEN '0.0' ELSE R.[29] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[30],'0') = '0' THEN '0.0' ELSE R.[30] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[31],'0') = '0' THEN '0.0' ELSE R.[31] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[32],'0') = '0' THEN '0.0' ELSE R.[32] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[33],'0') = '0' THEN '0.0' ELSE R.[33] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[34],'0') = '0' THEN '0.0' ELSE R.[34] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[35],'0') = '0' THEN '0.0' ELSE R.[35] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[36],'0') = '0' THEN '0.0' ELSE R.[36] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[37],'0') = '0' THEN '0.0' ELSE R.[37] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[38],'0') = '0' THEN '0.0' ELSE R.[38] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[39],'0') = '0' THEN '0.0' ELSE R.[39] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[40],'0') = '0' THEN '0.0' ELSE R.[40] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[41],'0') = '0' THEN '0.0' ELSE R.[41] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[42],'0') = '0' THEN '0.0' ELSE R.[42] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[43],'0') = '0' THEN '0.0' ELSE R.[43] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[44],'0') = '0' THEN '0.0' ELSE R.[44] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[45],'0') = '0' THEN '0.0' ELSE R.[45] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[46],'0') = '0' THEN '0.0' ELSE R.[46] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[47],'0') = '0' THEN '0.0' ELSE R.[47] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[48],'0') = '0' THEN '0.0' ELSE R.[48] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[49],'0') = '0' THEN '0.0' ELSE R.[49] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[50],'0') = '0' THEN '0.0' ELSE R.[50] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[51],'0') = '0' THEN '0.0' ELSE R.[51] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[52],'0') = '0' THEN '0.0' ELSE R.[52] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[53],'0') = '0' THEN '0.0' ELSE R.[53] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[54],'0') = '0' THEN '0.0' ELSE R.[54] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[55],'0') = '0' THEN '0.0' ELSE R.[55] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[56],'0') = '0' THEN '0.0' ELSE R.[56] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[57],'0') = '0' THEN '0.0' ELSE R.[57] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[58],'0') = '0' THEN '0.0' ELSE R.[58] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[59],'0') = '0' THEN '0.0' ELSE R.[59] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[60],'0') = '0' THEN '0.0' ELSE R.[60] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[61],'0') = '0' THEN '0.0' ELSE R.[61] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(AVG(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[62],'0') = '0' THEN '0.0' ELSE R.[62] END),0)),1),20,1)))
		FROM
				@Report3 R 
		WHERE
				R.SeqNo <> 1
		UNION	
		SELECT
				15 AS SeqNo,
				'범위(R)' AS Title,
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[1],'0') = '0' THEN '0.0' ELSE R.[1] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[1],'0') = '0' THEN '0.0' ELSE R.[1] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[2],'0') = '0' THEN '0.0' ELSE R.[2] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[2],'0') = '0' THEN '0.0' ELSE R.[2] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[3],'0') = '0' THEN '0.0' ELSE R.[3] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[3],'0') = '0' THEN '0.0' ELSE R.[3] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[4],'0') = '0' THEN '0.0' ELSE R.[4] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[4],'0') = '0' THEN '0.0' ELSE R.[4] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[5],'0') = '0' THEN '0.0' ELSE R.[5] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[5],'0') = '0' THEN '0.0' ELSE R.[5] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[6],'0') = '0' THEN '0.0' ELSE R.[6] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[6],'0') = '0' THEN '0.0' ELSE R.[6] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[7],'0') = '0' THEN '0.0' ELSE R.[7] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[7],'0') = '0' THEN '0.0' ELSE R.[7] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[8],'0') = '0' THEN '0.0' ELSE R.[8] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[8],'0') = '0' THEN '0.0' ELSE R.[8] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[9],'0') = '0' THEN '0.0' ELSE R.[9] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[9],'0') = '0' THEN '0.0' ELSE R.[9] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[10],'0') = '0' THEN '0.0' ELSE R.[10] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[10],'0') = '0' THEN '0.0' ELSE R.[10] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[11],'0') = '0' THEN '0.0' ELSE R.[11] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[11],'0') = '0' THEN '0.0' ELSE R.[11] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[12],'0') = '0' THEN '0.0' ELSE R.[12] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[12],'0') = '0' THEN '0.0' ELSE R.[12] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[13],'0') = '0' THEN '0.0' ELSE R.[13] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[13],'0') = '0' THEN '0.0' ELSE R.[13] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[14],'0') = '0' THEN '0.0' ELSE R.[14] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[14],'0') = '0' THEN '0.0' ELSE R.[14] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[15],'0') = '0' THEN '0.0' ELSE R.[15] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[15],'0') = '0' THEN '0.0' ELSE R.[15] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[16],'0') = '0' THEN '0.0' ELSE R.[16] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[16],'0') = '0' THEN '0.0' ELSE R.[16] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[17],'0') = '0' THEN '0.0' ELSE R.[17] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[17],'0') = '0' THEN '0.0' ELSE R.[17] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[18],'0') = '0' THEN '0.0' ELSE R.[18] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[18],'0') = '0' THEN '0.0' ELSE R.[18] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[19],'0') = '0' THEN '0.0' ELSE R.[19] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[19],'0') = '0' THEN '0.0' ELSE R.[19] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[20],'0') = '0' THEN '0.0' ELSE R.[20] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[20],'0') = '0' THEN '0.0' ELSE R.[20] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[21],'0') = '0' THEN '0.0' ELSE R.[21] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[21],'0') = '0' THEN '0.0' ELSE R.[21] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[22],'0') = '0' THEN '0.0' ELSE R.[22] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[22],'0') = '0' THEN '0.0' ELSE R.[22] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[23],'0') = '0' THEN '0.0' ELSE R.[23] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[23],'0') = '0' THEN '0.0' ELSE R.[23] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[24],'0') = '0' THEN '0.0' ELSE R.[24] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[24],'0') = '0' THEN '0.0' ELSE R.[24] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[25],'0') = '0' THEN '0.0' ELSE R.[25] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[25],'0') = '0' THEN '0.0' ELSE R.[25] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[26],'0') = '0' THEN '0.0' ELSE R.[26] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[26],'0') = '0' THEN '0.0' ELSE R.[26] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[27],'0') = '0' THEN '0.0' ELSE R.[27] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[27],'0') = '0' THEN '0.0' ELSE R.[27] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[28],'0') = '0' THEN '0.0' ELSE R.[28] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[28],'0') = '0' THEN '0.0' ELSE R.[28] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[29],'0') = '0' THEN '0.0' ELSE R.[29] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[29],'0') = '0' THEN '0.0' ELSE R.[29] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[30],'0') = '0' THEN '0.0' ELSE R.[30] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[30],'0') = '0' THEN '0.0' ELSE R.[30] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[31],'0') = '0' THEN '0.0' ELSE R.[31] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[31],'0') = '0' THEN '0.0' ELSE R.[31] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[32],'0') = '0' THEN '0.0' ELSE R.[32] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[32],'0') = '0' THEN '0.0' ELSE R.[32] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[33],'0') = '0' THEN '0.0' ELSE R.[33] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[33],'0') = '0' THEN '0.0' ELSE R.[33] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[34],'0') = '0' THEN '0.0' ELSE R.[34] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[34],'0') = '0' THEN '0.0' ELSE R.[34] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[35],'0') = '0' THEN '0.0' ELSE R.[35] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[35],'0') = '0' THEN '0.0' ELSE R.[35] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[36],'0') = '0' THEN '0.0' ELSE R.[36] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[36],'0') = '0' THEN '0.0' ELSE R.[36] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[37],'0') = '0' THEN '0.0' ELSE R.[37] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[37],'0') = '0' THEN '0.0' ELSE R.[37] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[38],'0') = '0' THEN '0.0' ELSE R.[38] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[38],'0') = '0' THEN '0.0' ELSE R.[38] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[39],'0') = '0' THEN '0.0' ELSE R.[39] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[39],'0') = '0' THEN '0.0' ELSE R.[39] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[40],'0') = '0' THEN '0.0' ELSE R.[40] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[40],'0') = '0' THEN '0.0' ELSE R.[40] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[41],'0') = '0' THEN '0.0' ELSE R.[41] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[41],'0') = '0' THEN '0.0' ELSE R.[41] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[42],'0') = '0' THEN '0.0' ELSE R.[42] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[42],'0') = '0' THEN '0.0' ELSE R.[42] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[43],'0') = '0' THEN '0.0' ELSE R.[43] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[43],'0') = '0' THEN '0.0' ELSE R.[43] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[44],'0') = '0' THEN '0.0' ELSE R.[44] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[44],'0') = '0' THEN '0.0' ELSE R.[44] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[45],'0') = '0' THEN '0.0' ELSE R.[45] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[45],'0') = '0' THEN '0.0' ELSE R.[45] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[46],'0') = '0' THEN '0.0' ELSE R.[46] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[46],'0') = '0' THEN '0.0' ELSE R.[46] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[47],'0') = '0' THEN '0.0' ELSE R.[47] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[47],'0') = '0' THEN '0.0' ELSE R.[47] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[48],'0') = '0' THEN '0.0' ELSE R.[48] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[48],'0') = '0' THEN '0.0' ELSE R.[48] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[49],'0') = '0' THEN '0.0' ELSE R.[49] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[49],'0') = '0' THEN '0.0' ELSE R.[49] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[50],'0') = '0' THEN '0.0' ELSE R.[50] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[50],'0') = '0' THEN '0.0' ELSE R.[50] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[51],'0') = '0' THEN '0.0' ELSE R.[51] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[51],'0') = '0' THEN '0.0' ELSE R.[51] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[52],'0') = '0' THEN '0.0' ELSE R.[52] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[52],'0') = '0' THEN '0.0' ELSE R.[52] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[53],'0') = '0' THEN '0.0' ELSE R.[53] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[53],'0') = '0' THEN '0.0' ELSE R.[53] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[54],'0') = '0' THEN '0.0' ELSE R.[54] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[54],'0') = '0' THEN '0.0' ELSE R.[54] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[55],'0') = '0' THEN '0.0' ELSE R.[55] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[55],'0') = '0' THEN '0.0' ELSE R.[55] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[56],'0') = '0' THEN '0.0' ELSE R.[56] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[56],'0') = '0' THEN '0.0' ELSE R.[56] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[57],'0') = '0' THEN '0.0' ELSE R.[57] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[57],'0') = '0' THEN '0.0' ELSE R.[57] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[58],'0') = '0' THEN '0.0' ELSE R.[58] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[58],'0') = '0' THEN '0.0' ELSE R.[58] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[59],'0') = '0' THEN '0.0' ELSE R.[59] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[59],'0') = '0' THEN '0.0' ELSE R.[59] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[60],'0') = '0' THEN '0.0' ELSE R.[60] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[60],'0') = '0' THEN '0.0' ELSE R.[60] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[61],'0') = '0' THEN '0.0' ELSE R.[61] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[61],'0') = '0' THEN '0.0' ELSE R.[61] END),0)),1),20,1))),
				CONVERT(VARCHAR(20),LTRIM(STR(ROUND(MAX(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[62],'0') = '0' THEN '0.0' ELSE R.[62] END)) - MIN(NULLIF(CONVERT(NUMERIC(20,5),CASE WHEN ISNULL(R.[62],'0') = '0' THEN '0.0' ELSE R.[62] END),0)),1),20,1)))
		FROM
				@Report3 R 
		WHERE
				R.SeqNo <> 1	
			
END


	--SELECT * FROM STB_CommInspDocHistory WHERE CommInspDocNo = '20180912000001' 
	--SELECT CommInspDocNo, CommInspItemCode, * FROM STB_CommInspDocItem 
	--SELECT * FROM STB_CommInspItem WHERE CommInspItemCode = 'RQ_A'