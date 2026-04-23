-- =============================================
-- Author:		DinhManh
-- Create date: 2025-12-02
-- Description:	<Description,,>
-- =============================================

-- exec usp_GetCommInspectionHist_VVT_F2 '' ,'' ,'VVT' ,'VVT_F2' ,'2025-11-30' ,'2025-12-02' ,'VVBGC-13', ''

CREATE PROCEDURE [dbo].[usp_GetCommInspectionHist_VVT_F2]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pCompanyCode VARCHAR(20) = NULL,
		@pWorkCenterCode VARCHAR(20) = NULL,
		@pFromDate DATETIME = NULL,
		@pToDate DATETIME = NULL,
		@pLineCode VARCHAR(20) = NULL,
		@pBarcode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
 --   DECLARE @FromDate DATEtime = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00' 
	--DECLARE @ToDate DATEtime = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 00:00:00' 

	DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00'
	DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00'

	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '%' ELSE @pLineCode END     

	--DECLARE @Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '%' ELSE @pBarcode END                                                             -- 추가사항

	
	DECLARE @CommInspDocNo VARCHAR(20)
	--DECLARE @CompanyCode VARCHAR(20)
	--DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @PONo VARCHAR(20)
	DECLARE @ControlNo VARCHAR(20)
	DECLARE @IsFinished BIT
	DECLARE @ProductGroupCode VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @IsLoss BIT
	DECLARE @IsHolding BIT
	DECLARE @ErrorMessage NVARCHAR(500)
	DECLARE @ProductType INT
	DECLARE @NewBarcode VARCHAR(50)


	DECLARE @CommInspTypeCode VARCHAR(30)
	
		if(@WorkCenterCode='VVT_F1')
			begin
				set @CommInspTypeCode='ROUTE_TEST2'
			end
		else if(@WorkCenterCode='VVT_F2')
			begin
				set @CommInspTypeCode='ROUTE_TEST2_BG'
			end
		else
			begin
				set @CommInspTypeCode='VE_ROUTE_TEST'
			end

	


	    -- Insert statements for procedure here
		Declare @MeasureTableMAX TABLE (
			CommInspMeasureNo VARCHAR(20),
			CommInspDocItemNo VARCHAR(20),
			MeasureResult VARCHAR(20),
			NumericMeasure NUMERIC(20,5),
			TextMeasure VARCHAR(50),
			MeasureSeq INT
		);


		CREATE TABLE #MeasureTable (
			CommInspMeasureNo VARCHAR(20),
			CommInspDocItemNo VARCHAR(20),
			MeasureResult VARCHAR(20),
			NumericMeasure NUMERIC(20,5),
			TextMeasure VARCHAR(50),
			MeasureSeq INT,
			MeasureDateTime DATETIME
		);



			Declare @cnt INT = 1

	WHILE @cnt <= 9 
	
	BEGIN

		INSERT INTO #MeasureTable
			SELECT
					A.CommInspMeasureNo,
					A.CommInspDocItemNo,
					A.MeasureResult,
					A.NumericMeasure,
					A.TextMeasure,
					A.MeasureSeq,
					A.MeasureDateTime
			FROM
					(
				 SELECT
					CIMH2.CommInspMeasureNo,
					CIMH2.CommInspDocItemNo,
					CIMH2.MeasureResult,
					CIMH2.NumericMeasure,
					CIMH2.TextMeasure,
					MAXMS2.MeasureSeq,
					CIMH2.MeasureDateTime
			FROM
					(
						SELECT
								CMH.CommInspDocItemNo,
								CMH.MeasureSeq							
						FROM
								STB_CommInspDocItem CIDI
								INNER JOIN STB_CommInspMeasureHist CMH   ON CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
						WHERE   CIDI.CommInspDocNo = (SELECT 
															CIDH.CommInspDocNo
															FROM STB_CommInspDocHistory CIDH WITH(NOLOCK)
															LEFT OUTER JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
															WHERE CIDH.CreateDateTime BETWEEN @FromDate AND @ToDate
															and SI.InputLineCode LIKE @LineCode
															and CIDH.CommInspTypeCode = @CommInspTypeCode
								
						
						)
						  AND   CMH.MeasureSeq = @cnt
					) MAXMS2
					LEFT OUTER JOIN STB_CommInspMeasureHist CIMH2	  ON CIMH2.CommInspDocItemNo = MAXMS2.CommInspDocItemNo		 AND CIMH2.MeasureSeq = MAXMS2.MeasureSeq
			) A

		SET @cnt = @cnt + 1
	
	END

	CREATE NONCLUSTERED INDEX XS_TEMPINDEX ON #MeasureTable (CommInspDocItemNo)
	CREATE NONCLUSTERED INDEX XS_TEMPINDEX2 ON #MeasureTable (MeasureSeq)


	SELECT
				SI.Barcode ,
				--@ControlNo AS ControlNo,
				--@IsLoss      AS IsLoss,
				--ISNULL(@IsFinished,0) AS IsFinished,
				CIDI.CommInspDocItemNo,
				CIDI.CommInspDocNo,
				CIDI.CommInspItemCode, 
				CII.CommInspItemName,
				CIDI.RouteCode,
				RI.RouteName,
				CIDI.CommInspUnit,
				CIDI.CommInspItemDesc,                                -- 한국어 항목설명 
				CIDI.CommInspInputType,
				VIEW_CIIT.CommInspInputTypeName,
				CIDI.CommInspItemSpec,    
				CIDI.CommInspUpper,
				CIDI.CommInspLower,
				CIDI.ItemTargetQty,  
				CASE WHEN ISNULL(CIDI.ItemQty,0)	>= CIDI.ItemTargetQty     THEN CIDI.ItemTargetQty 
					 when CIDI.CommInspItemCode in ('v_DryColor','v_SleveWrongD') and CIDI.ItemTargetQty=3  AND CIDI.ItemQty <> 3 then 3 --ad by Mr.Tung on 19-09-2022
					 WHEN CIDI.ItemTargetQty = '20' AND CIDI.ItemQty <> '0' THEN '20'
					 ELSE ISNULL(CIDI.ItemQty,0) END   AS ItemQty, 

				CII.CommInspSelectGroupCode,
				''                                       AS MeasureResult,
				0.0 AS NumericMeasure,
				CIMH1.NumericMeasure AS FirstMeasureValue,
				CIMH2.NumericMeasure AS SecondMeasureValue,
				CIMH3.NumericMeasure AS ThirdMeasureValue,
				CIMH4.NumericMeasure AS FourthMeasureValue,
				CIMH5.NumericMeasure AS FifthMeasureValue,
				CIMH6.NumericMeasure AS SixthMeasureValue,
				CIMH7.NumericMeasure AS SeventhMeasureValue,
				CIMH8.NumericMeasure AS EightMeasureValue,
				CIMH9.NumericMeasure AS NineMeasureValue,

				

				CIDI.CreateDateTime




		FROM	STB_CommInspDocItem CIDI
				LEFT OUTER JOIN STB_CommInspItem CII ON CII.CommInspItemCode = CIDI.CommInspItemCode
				LEFT OUTER JOIN VW_CommInspInputType VIEW_CIIT ON VIEW_CIIT.CommInspInputType = CIDI.CommInspInputType
				--LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	ON (AFM.FileID = CIDI.ImageFileID)
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 1 ) CIMH1 ON CIMH1.CommInspDocItemNo = CIDI.CommInspDocItemNo  
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 2 ) CIMH2 ON CIMH2.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 3 ) CIMH3 ON CIMH3.CommInspDocItemNo = CIDI.CommInspDocItemNo       -- 2020.01.13 추가
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 4 ) CIMH4 ON CIMH4.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 5 ) CIMH5 ON CIMH5.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 6 ) CIMH6 ON CIMH6.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 7 ) CIMH7 ON CIMH7.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 8 ) CIMH8 ON CIMH8.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 9 ) CIMH9 ON CIMH9.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 10 ) CIMH10 ON CIMH10.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 11 ) CIMH11 ON CIMH11.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 12 ) CIMH12 ON CIMH12.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 13 ) CIMH13 ON CIMH13.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 14 ) CIMH14 ON CIMH14.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 15 ) CIMH15 ON CIMH15.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 16 ) CIMH16 ON CIMH16.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 17 ) CIMH17 ON CIMH17.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 18 ) CIMH18 ON CIMH18.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 19 ) CIMH19 ON CIMH19.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN (SELECT * FROM #MeasureTable WHERE MeasureSeq = 20 ) CIMH20 ON CIMH20.CommInspDocItemNo = CIDI.CommInspDocItemNo
				--LEFT OUTER JOIN @MeasureTableMAX CIMH                                                 ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo			
				--LEFT OUTER JOIN STB_CommInspSelectItem CISI WITH(NOLOCK)				             ON CISI.CommInspSelectResult = CIMH.MeasureResult				AND CISI.CommInspSelectGroupCode = CII.CommInspSelectGroupCode
				LEFT OUTER JOIN STB_CommInspDocHistory SCH WITH(NOLOCK)				         ON SCH.CommInspDocNo = CIDI.CommInspDocNo
				LEFT OUTER JOIN STB_MachineMaster MM  WITH(NOLOCK)	                             ON MM.MachineCode = SCH.VPCMachineCode
				LEFT OUTER JOIN STB_ProdWorkerInfo PWI  WITH(NOLOCK)	                             ON PWI.WorkerCode = SCH.InspWorkerCode
				LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)	ON RI.RouteCode = CIDI.RouteCode

				LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK) ON SCH.CommInspTypeCode = @CommInspTypeCode AND				SCH.ProdNo = SI.ControlNo
		WHERE 1=1
		  --AND CIDI.CommInspDocNo = @CommInspDocNo
		  --AND (CII.CommInspItemGroup3 IS NULL OR CII.CommInspItemGroup3 LIKE '%' + @Size + '%')
		  AND (ISNULL(CII.DisplayIndex, 1) < 100)
		  --AND (@IsExceptDestInsp = CONVERT(BIT, 0) OR (CII.CommInspItemCode NOT IN ('STRIPPING', 'LENGTHP', 'LENGTHM', 'THICKP', 'THICKM', 'tP', 'tM', 'WDecapInsp', 'RQV_V')))	  
		  --AND (@RouteCode = '*' OR CII.RouteCode = @RouteCode)    -- 2022.02.10 추가사항
		  AND SCH.CreateDateTime  BETWEEN @FromDate AND @ToDate


		ORDER BY SCH.CreateDateTime,
				
		      CII.DisplayIndex



END
