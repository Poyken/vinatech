-- =============================================
-- Author:		DinhManh
-- Create date: 2025-12-02
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_getCommInspectionHistoryPerBarcode_VVT
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),		
			@pWorkCenterCode VARCHAR(10) = NULL,
			@pCommInspDocNo VARCHAR(50) = NULL,
			@pBarcode VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CommInspDocNo VARCHAR(50)    = CASE WHEN ISNULL(@pCommInspDocNo,'') = '' THEN '%' ELSE @pCommInspDocNo END
	DECLARE @WorkCenterCode VARCHAR(50)    = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @Barcode VARCHAR(50)    = CASE WHEN ISNULL(@pBarcode,'') = '' THEN '%' ELSE @pBarcode END


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


		INSERT INTO @MeasureTableMAX
		SELECT
				CIMH.CommInspMeasureNo,
				CIMH.CommInspDocItemNo,
				CIMH.MeasureResult,
				CIMH.NumericMeasure,
				CIMH.TextMeasure,
				MAXMS.MeasureSeq				
		FROM
				(
					SELECT
							CMH.CommInspDocItemNo,
							MAX(CMH.MeasureSeq)      AS MeasureSeq							
					FROM               STB_CommInspDocItem     CIDI
							INNER JOIN STB_CommInspMeasureHist CMH   ON	CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
					WHERE 1=1
					  AND CIDI.CommInspDocNo = @CommInspDocNo
					GROUP BY	CMH.CommInspDocItemNo							
				)  MAXMS
				   LEFT OUTER JOIN STB_CommInspMeasureHist CIMH  ON CIMH.CommInspDocItemNo = MAXMS.CommInspDocItemNo	 AND CIMH.MeasureSeq = MAXMS.MeasureSeq


		
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
						WHERE   CIDI.CommInspDocNo = @CommInspDocNo
						  AND   CMH.MeasureSeq = @cnt
					) MAXMS2
					LEFT OUTER JOIN STB_CommInspMeasureHist CIMH2	  ON CIMH2.CommInspDocItemNo = MAXMS2.CommInspDocItemNo		 AND CIMH2.MeasureSeq = MAXMS2.MeasureSeq
			) A

		SET @cnt = @cnt + 1
	
	END

	CREATE NONCLUSTERED INDEX XS_TEMPINDEX ON #MeasureTable (CommInspDocItemNo)
	CREATE NONCLUSTERED INDEX XS_TEMPINDEX2 ON #MeasureTable (MeasureSeq)


	SELECT
				@Barcode    AS Barcode,
				--@ControlNo AS ControlNo,
				--@IsLoss      AS IsLoss,
				--ISNULL(@IsFinished,0) AS IsFinished,
				CIDI.CommInspDocItemNo,  --공용검사항목이력
				CIDI.CommInspDocNo,   --검사문서번호
				CIDI.CommInspItemCode,  
				CII.CommInspItemName,                               -- 점검항목명 VPC 일부품목의 경우 점검항목명을 변경적용.
				CIDI.CommInspUnit,
				CIDI.CommInspItemDesc,                                -- 한국어 항목설명 
				CIDI.CommInspInputType,
				VIEW_CIIT.CommInspInputTypeName,
				CIDI.CommInspItemSpec,                                -- LSE 스펙하한값
				TRY_CAST(CIDI.CommInspUpper AS NUMERIC(10,2)) as CommInspUpper,   --chhuyển đổi sang dạng NUMERIC để có thể so sánh trong màn hình B597
				TRY_CAST(CIDI.CommInspLower as NUMERIC(10,2)) as CommInspLower,	--chhuyển đổi sang dạng NUMERIC để có thể so sánh trong màn hình B597
				CIDI.ItemTargetQty,                                       -- 검사시료수
				CASE WHEN ISNULL(CIDI.ItemQty,0)	>= CIDI.ItemTargetQty     THEN CIDI.ItemTargetQty 
					 when CIDI.CommInspItemCode in ('v_DryColor','v_SleveWrongD') and CIDI.ItemTargetQty=3  AND CIDI.ItemQty <> 3 then 3 --ad by Mr.Tung on 19-09-2022
					 WHEN CIDI.ItemTargetQty = '20' AND CIDI.ItemQty <> '0' THEN '20'
					 WHEN @CommInspTypeCode = 'ROUTE_QUALITY' AND VIEW_CIIT.CommInspInputTypeName <> 'NUMERIC' AND CIDI.ItemQty <> '0' THEN CIDI.ItemTargetQty -- 본사 공정검사이고, 검사항목유형이 수치가 아니면서 검사한 수량이 존재하면 현재검사 수에 검사시료수와 동일한 수량을 표시함. 2023.06.15 서동훈 프로 요청 By Jackaroe
					 ELSE ISNULL(CIDI.ItemQty,0) END   AS ItemQty,  -- 2020.01.31 수정 - 현재검사수
				--ISNULL(CIDI.ImageFileID,0) AS ImageFileID,
				AFM.[FileName],
				AFM.FileSize,
				CONVERT(VARBINARY(MAX),NULL)                                              AS FileData,
			 -- CIDI.CommInspRemark														     AS CommInspRemark ,  -- 원본백업
				CASE WHEN CII.DisplayIndex = 1 THEN SCH.CIDHExtText02 ELSE '' END AS CIDHExtText02,             -- 2020.01.13 비고정보 수정 (kilee)
				CII.CommInspSelectGroupCode,
				''                                       AS MeasureResult,
				0.0 AS NumericMeasure,
				CIMH.TextMeasure AS TextMeasure,
				CISI.CommInspSelectItemCode,
				CISI.CommInspSelectItemValue,
				CISI.CommInspSelectResult,
				CASE WHEN ISNULL(CIMH.MeasureResult,'NG') = 'OK'   THEN CONVERT(BIT,1)	  ELSE CONVERT(BIT,0)		   END AS CheckDisplay,			
			  --SCH.CIDHExtText03                                                                                                                     AS NG_Check,             -- 2020.01.31  검사결과 추가 (원본백업)
				CIDI.CommInspRemark  AS  CommInspRemark,  -- 2020.01.31  검사결과 추가
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH1.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH1.MeasureResult = '1' THEN 'OK' ELSE CIMH1.MeasureResult END  END AS FirstMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH2.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH2.MeasureResult = '1' THEN 'OK' ELSE CIMH2.MeasureResult END  END AS SecondMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH3.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH3.MeasureResult = '1' THEN 'OK' ELSE CIMH3.MeasureResult END  END AS ThirdMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH4.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH4.MeasureResult = '1' THEN 'OK' ELSE CIMH4.MeasureResult END  END AS FourthMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH5.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH5.MeasureResult = '1' THEN 'OK' ELSE CIMH5.MeasureResult END  END AS FifthMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH6.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH6.MeasureResult = '1' THEN 'OK' ELSE CIMH6.MeasureResult END  END AS SixthMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH7.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH7.MeasureResult = '1' THEN 'OK' ELSE CIMH7.MeasureResult END  END AS SeventhMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH8.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH8.MeasureResult = '1' THEN 'OK' ELSE CIMH8.MeasureResult END  END AS EightMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH9.NumericMeasure)	ELSE CASE WHEN @CommInspTypeCode = 'ROUTE_TEST_PS' AND CIMH9.MeasureResult = '1' THEN 'OK' ELSE CIMH9.MeasureResult END  END AS NineMeasureValue,
				CASE	WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH.NumericMeasure )	ELSE CIMH.MeasureResult   END AS LastMeasureValue,            -- 최종측정값
					CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH11.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=11 then CIMH.MeasureResult end as Value11,
				CASE
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH12.NumericMeasure)
				 WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=12 then CIMH.MeasureResult end as Value12,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH13.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=13 then CIMH.MeasureResult end as Value13,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH14.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=14 then CIMH.MeasureResult end as Value14,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH15.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=15 then CIMH.MeasureResult end as Value15,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH16.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=16 then CIMH.MeasureResult end as Value16,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH17.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=17 then CIMH.MeasureResult end as Value17,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH18.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=18 then CIMH.MeasureResult end as Value18,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH19.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=19 then CIMH.MeasureResult end as Value19,
				CASE 
				WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH20.NumericMeasure)
				WHEN CIDI.CommInspInputType = '2' and CIDI.ItemTargetQty>=20 then CIMH.MeasureResult end as Value20,

				CASE WHEN VIEW_CIIT.CommInspInputTypeName = 'NUMERIC' THEN  CONVERT(NUMERIC(10,2), CIMH.NumericMeasure)	ELSE CIMH.MeasureResult   END AS OldLastMeasureValue,
				--CASE WHEN CIMH1.MeasureResult = 0                THEN 'OK'  
				--       WHEN CIMH1.MeasureResult = 0                THEN 'NG'           ELSE SCH.CIDHExtText03  END                                                                                               AS CIDHExtText03,             -- 2020.01.20 OK/NG유무추가
				CIMH.CommInspMeasureNo,
				CIMH.MeasureSeq,
				''                                     AS DefectCode,
				CONVERT(BIT,0)                   AS IsHolding,
				CII.DisplayIndex
			--	, SCH.CIDHExtInt03   AS ProcessSteps   --2021.10.20 추가사항
				, CIDI.ProcessSteps   AS ProcessSteps   --2021.10.25 추가사항
				, SCH.VPCMachineCode    -- VPC치수 측정 화면용으로 추가 #211207
				, MM.MachineName AS VPCMachineName
				, SCH.TrayNo
				, SCH.InspWorkerCode
				, PWI.WorkerName     AS InspWorkerName
				, CIMH1.MeasureDateTime AS InspDateTime
				, CASE WHEN CII.CommInspItemGroup1 = 'E-22' THEN '권취'
					   WHEN CII.CommInspItemGroup1 = 'E-24' THEN '조립'
					   WHEN CII.CommInspItemGroup1 = 'E-33' THEN '절곡' END AS RouteName
				,CIDI.RouteCode
				,RI.RouteName AS N'Công đoạn'
		FROM	STB_CommInspDocItem CIDI
				LEFT OUTER JOIN STB_CommInspItem CII ON CII.CommInspItemCode = CIDI.CommInspItemCode
				LEFT OUTER JOIN VW_CommInspInputType VIEW_CIIT ON VIEW_CIIT.CommInspInputType = CIDI.CommInspInputType
				LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	ON (AFM.FileID = CIDI.ImageFileID)
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
				LEFT OUTER JOIN @MeasureTableMAX CIMH                                                 ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo			
				LEFT OUTER JOIN STB_CommInspSelectItem CISI WITH(NOLOCK)				             ON CISI.CommInspSelectResult = CIMH.MeasureResult				AND CISI.CommInspSelectGroupCode = CII.CommInspSelectGroupCode
				LEFT OUTER JOIN STB_CommInspDocHistory SCH WITH(NOLOCK)				         ON SCH.CommInspDocNo = CIDI.CommInspDocNo
				LEFT OUTER JOIN STB_MachineMaster MM  WITH(NOLOCK)	                             ON MM.MachineCode = SCH.VPCMachineCode
				LEFT OUTER JOIN STB_ProdWorkerInfo PWI  WITH(NOLOCK)	                             ON PWI.WorkerCode = SCH.InspWorkerCode
				LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)	ON RI.RouteCode = CIDI.RouteCode
		WHERE 1=1
		  AND CIDI.CommInspDocNo = @CommInspDocNo
		  --AND (CII.CommInspItemGroup3 IS NULL OR CII.CommInspItemGroup3 LIKE '%' + @Size + '%')
		  AND (ISNULL(CII.DisplayIndex, 1) < 100)
		  --AND (@IsExceptDestInsp = CONVERT(BIT, 0) OR (CII.CommInspItemCode NOT IN ('STRIPPING', 'LENGTHP', 'LENGTHM', 'THICKP', 'THICKM', 'tP', 'tM', 'WDecapInsp', 'RQV_V')))	  
		  --AND (@RouteCode = '*' OR CII.RouteCode = @RouteCode)    -- 2022.02.10 추가사항

		ORDER BY CII.DisplayIndex




END
