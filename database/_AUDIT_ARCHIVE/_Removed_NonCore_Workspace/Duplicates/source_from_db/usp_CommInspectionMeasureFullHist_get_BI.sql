-- =============================================
-- Author : Mr.Duy
-- Create date : 2024-03-19
-- Description : Power BI

--        usp_CommInspectionMeasureFullHist_get_BI '', '', 'VVT' , '', '','2024-03-01','2024-03-19','','','',''
-- ===================================================================================================================
CREATE PROCEDURE [dbo].[usp_CommInspectionMeasureFullHist_get_BI]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pCommInspTypeCode VARCHAR(100) = NULL,
						@pFromDate DATETIME,
						@pToDate DATETIME,
						@pMaterialCode VARCHAR(20) = NULL,
						@pCommInspItemCode VARCHAR(20) = NULL,
						@pBarcode VARCHAR(20) = NULL, 
						@pLineCode VARCHAR(20) = NULL,
						@pSizeCode VARCHAR(20) = NULL

		
AS

BEGIN
	Declare @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
			, @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
			, @CommInspTypeCode VARCHAR(100) = @pCommInspTypeCode
			, @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 10:00:00'
			, @ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 10:00:00'
			, @MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
			, @CommInspItemCode VARCHAR(20) = CASE WHEN ISNULL(@pCommInspItemCode, '') = '' THEN '*' ELSE @pCommInspItemCode END
			, @Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END
			, @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '*' ELSE @pLineCode END
 DECLARE  @SizeCode          VARCHAR(8)   = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '*' ELSE @pSizeCode END                                               -- 2020.05.06 추가 (kilee)                             


SELECT CASE WHEN CIDH.ComPanyCode = 'VNT' THEN '전주본사'
	               WHEN CIDH.ComPanyCode = 'VVT' THEN '베트남' ELSE '기타' END   AS 사업장
		 , SI.Barcode
	     , SI.MaterialCode
		 , MM.MaterialName
		 , SI.InputLineCode AS LineCode
		 , LI.LineName
		 , CII.CommInspItemCode
		 , CII.CommInspItemName
		 , CIMH.MeasureSeq
		 , CIDI.CommInspLower
		 , CIDI.CommInspUpper
	   --, CASE WHEN CII.CommInspInputType = '2' 	THEN CIMH.MeasureResult 	ELSE CONVERT(VARCHAR(100), CIMH.NumericMeasure) END AS MeasureResult                           -- 원본백업
		 , CASE WHEN CII.CommInspInputType = '2' 	AND CIMH.MeasureResult = '0' THEN 'NG' 
		        WHEN CII.CommInspInputType = '2' 	AND (CIMH.MeasureResult = '1' or CIMH.MeasureResult='OK') THEN 'OK'    	
				ELSE CONVERT(VARCHAR(15), CIMH.NumericMeasure) END AS MeasureResult           -- 원본수정(kilee, 2020-03-16)
		 , CIMH.MeasureDateTime
		 , RIGHT('0'+CONVERT(VARCHAR(15), convert(INT,MBISizeW)),2) + CONVERT(VARCHAR(15), convert(INT,MBISizeH)) AS SizeCode	
	  FROM STB_CommInspMeasureHist CIMH
			  LEFT OUTER JOIN STB_CommInspDocItem CIDI		  ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo
			  LEFT OUTER JOIN STB_CommInspDocHistory CIDH	  ON CIDI.CommInspDocNo = CIDH.CommInspDocNo
			  LEFT OUTER JOIN STB_SetInfo SI		                  ON SI.ControlNo = CIDH.ProdNo
			  LEFT OUTER JOIN STB_CommInspItem CII		      ON CII.CommInspItemCode = CIDI.CommInspItemCode
			  LEFT OUTER JOIN STB_LineInfo LI	                      ON SI.InputLineCode = LI.LineCode
			  LEFT OUTER JOIN STB_MaterialMaster MM	          ON SI.MaterialCode = MM.MaterialCode
			  LEFT OUTER JOIN VW_ModelBasicInfo VM              ON SI.MaterialCode = VM.ModelCode		                                       -- 2020.05.06 추가 (kilee)


			  
	 WHERE 1=1
	   AND (@WorkCenterCode = '*' OR CIDH.WorkCenterCode = @WorkCenterCode)								-- 추가 용은재 (2020.01.23)
	   --AND  (@CommInspTypeCode = '*' OR CIDH.CommInspTypeCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@CommInspTypeCode)))
	   AND case when @CompanyCode='VVT' then CIMH.MeasureDateTime else CIDH.CreateDateTime end BETWEEN @FromDate AND @ToDate
	   AND (@CompanyCode = '*' OR CIDH.CompanyCode = @CompanyCode)										-- 추가 용은재 (2020.01.23)
	   AND (@Barcode = '*' OR SI.Barcode LIKE @Barcode)
	   AND (@MaterialCode = '*' OR CIDH.MaterialCode LIKE @MaterialCode)
	   AND (@CommInspItemCode = '*' OR CII.CommInspItemCode LIKE @CommInspItemCode)
	   AND (@LineCode = '*' OR SI.InputLineCode LIKE @LineCode)

	   AND (@SizeCode = '*' Or  RIGHT('0'+CONVERT(VARCHAR(15), convert(INT,MBISizeW)),2) + CONVERT(VARCHAR(15), convert(INT,MBISizeH))  LIKE @SizeCode)       
	   AND CIDI.CommInspItemCode <> 'RQV_V'

	 ORDER BY CIMH.CommInspDocItemNo, CIMH.MeasureSeq
END