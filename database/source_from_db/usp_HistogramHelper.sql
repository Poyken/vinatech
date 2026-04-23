
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-25
-- Description:	히스토그램
-- =============================================
CREATE PROCEDURE [dbo].[usp_HistogramHelper]
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pTargetDate DATE,
	@pShiftCode VARCHAR(1),
	@pMoldNumber VARCHAR(50),
	@pMaterialCode VARCHAR(50),
	@pCommInspTypeCode VARCHAR(50),
	@pCommInspItemCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20),
	@pFacilityRouteCode VARCHAR(20),
	@pMachineCode VARCHAR(20),
	@pCategoryName NVARCHAR(50),
	@pPreUCL NUMERIC(20,5),
	@pPreLCL NUMERIC(20,5),
	@pX_USL NUMERIC(20,5),
	@pX_LSL NUMERIC(20,5),
	@Mean NUMERIC(20,5) OUTPUT,
	@Stdev NUMERIC(20,5) OUTPUT,
	@LSL NUMERIC(20,5) OUTPUT,
	@USL NUMERIC(20,5) OUTPUT,
	@Max_Measure NUMERIC(20,5) OUTPUT,
	@Min_Measure NUMERIC(20,5) OUTPUT
	
	
AS
BEGIN
	SET NOCOUNT ON;
	
	----- 파라미터 처리
	/*
	DECLARE @FromDate DATE = CASE WHEN @pFromDate IS NULL THEN GETDATE() ELSE @pFromDate END,
			@ToDate DATE = CASE WHEN @pToDate IS NULL THEN GETDATE() ELSE @pToDate END,
			@ProductCode VARCHAR(20) = '58P3131BB10'
	*/
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE	@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @TargetDate DATE = @pTargetDate
	DECLARE @ShiftCode VARCHAR(1) = CASE WHEN ISNULL(@pShiftCode,'') = '' THEN '*' ELSE @pShiftCode END
	DECLARE @MoldNumber VARCHAR(50) = CASE WHEN ISNULL(@pMoldNumber,'') = '' THEN '*' ELSE @pMoldNumber END
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END
	DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END
	DECLARE @FacilityRouteCode VARCHAR(20) = CASE WHEN ISNULL(@pFacilityRouteCode,'') = '' THEN '*' ELSE @pFacilityRouteCode END
	DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '*' ELSE @pMachineCode END
	DECLARE @CategoryName NVARCHAR(50) = CASE WHEN ISNULL(@pCategoryName,'') = '' THEN '' ELSE @pCategoryName END
	DECLARE @CommInspTypeCode VARCHAR(50) = CASE WHEN ISNULL(@pCommInspTypeCode,'') = '' THEN '' ELSE @pCommInspTypeCode END
	DECLARE @CommInspItemCode VARCHAR(50) = CASE WHEN ISNULL(@pCommInspItemCode, '') = '' THEN '*' ELSE @pCommInspItemCode END
	
	
	---- 주 데이터 임시테이블
	DECLARE @DATA TABLE (
		WeightNo INT,
		MoldProdPlanNo VARCHAR(50),
		MaterialCode VARCHAR(50),
		MeasureValue NUMERIC(20, 5)
		)
	
	------------- 아래 부분에 실제 데이터 Select
	
	DECLARE @Histogram_JobDateInfo TABLE
	(
		RowNumber INT IDENTITY,
		JobDate DATE,
		ShiftCode VARCHAR(1)
	)
	
	INSERT @Histogram_JobDateInfo
	SELECT
			TOP 62
			CIDH.JobDate,
			CIDH.ShiftCode
	FROM
			STB_CommInspDocHistory CIDH WITH(NOLOCK)
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

	DECLARE  @Histogram_RowNumber INT,
			 @Histogram_Index INT = 1,
			 @Histogram_JobDate DATE,
			 @Hisgogram_ShiftCode VARCHAR(1)
	
	SET @Histogram_RowNumber = (SELECT COUNT(*) FROM @Histogram_JobDateInfo)
	
	WHILE(@Histogram_Index < @Histogram_RowNumber + 1) BEGIN
		SELECT
				@Histogram_JobDate = PI.JobDate,
				@Hisgogram_ShiftCode = PI.ShiftCode
		FROM
				@Histogram_JobDateInfo PI
		WHERE
				PI.RowNumber = @Histogram_Index
		
				
		INSERT @DATA
		SELECT
				CIMH.MeasureSeq AS SeqNo,
				CIDH.RefDocNo AS MoldProdPlanNo,
				CIDH.MaterialCode,
				ISNULL(CIMH.NumericMeasure,0) AS Weight
		FROM
				STB_CommInspDocHistory CIDH
				LEFT OUTER JOIN STB_CommInspDocItem CIDI 
					ON CIDI.CommInspDocNo = CIDH.CommInspDocNo
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH 
					ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo
		WHERE
				(CIDH.JobDate = @Histogram_JobDate) AND
				(CIDH.ShiftCode = @Hisgogram_ShiftCode) AND
				((@CompanyCode = '*') OR (CIDH.CompanyCode = @CompanyCode)) AND
				((@WorkCenterCode = '*') OR (CIDH.WorkCenterCode = @WorkCenterCode)) AND
				((@MoldNumber = '*') OR (CIDH.MoldNumber = @MoldNumber)) AND
				((@MaterialCode = '*') OR (CIDH.MaterialCode = @MaterialCode)) AND
				((@RouteCode  = '*') OR (CIDH.RouteCode = @RouteCode)) AND
				((@FacilityRouteCode = '*') OR (CIDH.FacilityRouteCode = @FacilityRouteCode)) AND
				((@MachineCode = '*') OR (CIDH.MachineCode = @MachineCode)) AND
				((@CategoryName = '*') OR (CIDH.CategoryName = @CategoryName)) AND
				((@CommInspTypeCode = '*') OR (CIDH.CommInspTypeCode = @CommInspTypeCode)) AND
				((@CommInspItemCode = '*') OR (CIDI.CommInspItemCode = @CommInspItemCode)) AND
				CIMH.NumericMeasure IS NOT NULL
			
		SET @Histogram_Index = @Histogram_Index + 1
		
	END		
					
	---- Mean, Stdev, USL, LSL
	--DECLARE @LSL_1 NUMERIC(20,5),
	--		@USL_1 NUMERIC(20,5)
			
	
	
	SELECT
			@Mean = AVG(NULLIF(MeasureValue,0)),
			@Stdev = STDEV(NULLIF(MeasureValue,0))
	FROM
			@DATA
	WHERE
			MeasureValue IS NOT NULL
	
	-- LSL, USL 구할때는 MaterialCode가 필요함. 수정필요		
	--SELECT
	--		@LSL_1 = CONVERT(NUMERIC(20,4),PSW.LowerSpec),
	--		@USL_1 = CONVERT(NUMERIC(20,4),PSW.UpperSpec)
	--FROM
	--		STB_ProductSpecWeight PSW WITH(NOLOCK)
	--WHERE
	--		PSW.ProductCode = @pProductCode
	
	--IF @LSL_1 IS NULL
	IF @pX_LSL IS NULL
	BEGIN
		SET @LSL = ISNULL(@pPreLCL,0)
	END ELSE BEGIN
		SET @LSL = ISNULL(@pX_LSL,0)
	END
	
	--IF @USL_1 IS NULL
	IF @pX_USL IS NULL
	BEGIN
		SET @USL = ISNULL(@pPreUCL,0)	
	END ELSE BEGIN
		SET @USL = ISNULL(@pX_USL,0)	
	END
	
	-- 여기까지 기준 정보
	------------------------------------------------------------------
	
	--DECLARE @Max NUMERIC(20, 5),
	--		@Min NUMERIC(20, 5)
			
	DECLARE @PointCnt INT,
			@Count INT
	
	DECLARE @SegmentIntervalNumber INT = 16
	DECLARE @SegmentIntervalWidth NUMERIC(20, 5) = 0.01
	DECLARE @ExtArea NUMERIC(20, 5)
	
	DECLARE @Max NUMERIC(20,5),
			@Min NUMERIC(20,5)
	
	SET @PointCnt = (SELECT COUNT(1) FROM @DATA WHERE MeasureValue IS NOT NULL)
	SET @Max = (SELECT MAX(MeasureValue) AS MeasureValue FROM @DATA) ------ 수정
	SET @Min = (SELECT MIN(MeasureValue) AS MeasureValue FROM @DATA)  ------ 수정
	
	
	SET @Max_Measure = @Max
	SET @Min_Measure = @Min
	
	SET @ExtArea = (@Max - @Min) * 0.01
	
	--IF (@USL < @Max)
		SET @Max = @Max + @ExtArea
	--ELSE
	--	SET @Max = @USL + @ExtArea
		
	--IF (@LSL > @Min)
		SET @Min = @Min - @ExtArea
	--ELSE
	--	SET @Min = @LSL - @ExtArea

	SET @SegmentIntervalWidth = (@Max - @Min) / 1.0
	SET @SegmentIntervalWidth = dbo.fnHistogramGetRoundInterval((@Max - @Min)/@SegmentIntervalNumber)			
	
	
	SET @Min = FLOOR((@Min/@SegmentIntervalWidth)*@SegmentIntervalWidth)
	SET @Max = CEILING((@Max/@SegmentIntervalWidth)*@SegmentIntervalWidth)
	
	
	
	-- Get Count
	
	DECLARE @HistTable TABLE (
		Position NUMERIC(20, 5),
		HistCnt NUMERIC(20, 5)
	)
	
	DECLARE @NormalTable TABLE (
		Position NUMERIC(20, 5),
		NormalDistCnt NUMERIC(20, 5)
	)
	
	DECLARE @CurrentPosition NUMERIC(20, 5) = @Min 
	DECLARE	@EndPosition NUMERIC(20, 5)
	
	DECLARE @MeasureValue NUMERIC(20, 5)
			
	DECLARE @X1 NUMERIC(20, 5),
			@X2 NUMERIC(20, 5),
			@pgap NUMERIC(20, 5)
	
	DECLARE CntCursor CURSOR FOR 
	SELECT
			MeasureValue
	FROM
			@DATA
			
	OPEN CntCursor
	
	FETCH NEXT FROM CntCursor INTO @MeasureValue
	
	WHILE @CurrentPosition <= @Max AND @@FETCH_STATUS = 0
	BEGIN		
		SET @EndPosition = @CurrentPosition + @SegmentIntervalWidth
	
		SET @Count = ISNULL(
					(SELECT COUNT(MeasureValue)
					FROM @DATA  
					WHERE
							((@CurrentPosition <= MeasureValue) AND 
							(MeasureValue < @EndPosition)) 
							OR
							(@Max <= @EndPosition AND 
							(@CurrentPosition <= MeasureValue AND
							MeasureValue <= @EndPosition))
					), 0)
				
		-- Histogram
		INSERT INTO @HistTable
		SELECT
				(@CurrentPosition + (@SegmentIntervalWidth / 2.0)) AS Position,
				--@CurrentPosition AS Position,
				@Count
		-- ~Histogram
		
		-- NormalDistance
		SET @X1 = @CurrentPosition
		SET @X2 = @CurrentPosition + @SegmentIntervalWidth
		SET @pgap = dbo.fnHistogramGetTermPercentage(@X1, @X2, @Mean, @Stdev)
		
		INSERT INTO @NormalTable
		SELECT
				(@X1 + ((@X2 - @X1) / 2)) AS Position,
				@pgap * @PointCnt
		-- ~ NormalDistance

		SET @CurrentPosition = @CurrentPosition + @SegmentIntervalWidth
		FETCH NEXT FROM CntCursor INTO @MeasureValue
	END
	
	CLOSE CntCursor
	
	DEALLOCATE CntCursor	
	
	
	SELECT
			A.Position,
			SUM(A.HistCnt) AS HistCnt,
			SUM(A.NormalDistCnt) AS NormalDistCnt
	FROM
			(				
				SELECT
						H.Position AS Position,
						H.HistCnt AS HistCnt,
						0 AS NormalDistCnt
				FROM
						@HistTable H
				UNION ALL
				SELECT
						N.Position AS Position,
						0 AS HistCnt,
						N.NormalDistCnt
				FROM
						@NormalTable N
			)A
	GROUP BY
			A.Position
	ORDER BY
			A.Position
			
	
	-- Spline Series
	SELECT
			*
	FROM
			@NormalTable
	
END


