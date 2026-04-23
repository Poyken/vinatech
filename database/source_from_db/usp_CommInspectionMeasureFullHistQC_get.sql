-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 2020-08-31
-- Description : 
-- Modified : 
-- usp_CommInspectionMeasureFullHistQC_get 'VNT', '', '2020-09-01', '2020-12-31'
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommInspectionMeasureFullHistQC_get]
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pFromDate DATETIME,
						@pToDate DATETIME
AS

BEGIN
	Declare @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
			, @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
			, @CommInspTypeCode VARCHAR(100) = 'ROUTE_QUALITY,ROUTE_QUALITY2'
			, @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
			, @ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'


SELECT CASE WHEN CIDH.ComPanyCode = 'VNT' THEN '전주본사'
	             WHEN CIDH.ComPanyCode = 'VVT' THEN '베트남' ELSE '기타' END   AS 사업장
		 , SI.Barcode AS LotNo
	     , SI.MaterialCode AS 품목코드
		 , MM.MaterialName AS 품목명
		 , SI.InputLineCode AS 라인코드
		 , LI.LineDesc AS 라인명
		 , CII.CommInspItemName AS 검사항목
		 , CII.CommInspItemDesc AS 검사항목설명
		 , CIMH.MeasureSeq AS 검사일련번호
		 , CIDI.CommInspLower AS 스펙하한값
		 , CIDI.CommInspUpper AS 스펙상한값
		 , CASE WHEN CII.CommInspInputType = '2' 	AND CIMH.MeasureResult = '0' THEN 'NG' 
		        WHEN CII.CommInspInputType = '2' 	AND CIMH.MeasureResult = '1' THEN 'OK'    	
				ELSE CONVERT(VARCHAR(100), CIMH.NumericMeasure) END AS 검사결과
		 , CIMH.MeasureDateTime AS 검사일시
		 , RIGHT('0'+CONVERT(VARCHAR, FLOOR(MBISizeW)),2) + CONVERT(VARCHAR, FLOOR(MBISizeH)) AS 제품사이즈
	  FROM STB_CommInspMeasureHist CIMH
			  LEFT OUTER JOIN STB_CommInspDocItem CIDI		  ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo
			  LEFT OUTER JOIN STB_CommInspDocHistory CIDH	  ON CIDI.CommInspDocNo = CIDH.CommInspDocNo
			  LEFT OUTER JOIN STB_SetInfo SI		                  ON SI.ControlNo = CIDH.ProdNo
			  LEFT OUTER JOIN STB_CommInspItem CII		      ON CII.CommInspItemCode = CIDI.CommInspItemCode
			  LEFT OUTER JOIN STB_LineInfo LI	                      ON SI.InputLineCode = LI.LineCode
			  LEFT OUTER JOIN STB_MaterialMaster MM	          ON SI.MaterialCode = MM.MaterialCode
			  
			  LEFT OUTER JOIN VW_ModelBasicInfo VM              ON SI.MaterialCode = VM.ModelCode

	 WHERE 1=1
	   AND (@CompanyCode = '*' OR CIDH.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR CIDH.WorkCenterCode = @WorkCenterCode)
	   AND CIDH.CommInspTypeCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@CommInspTypeCode))
	   AND CIMH.MeasureDateTime BETWEEN @FromDate AND @ToDate
	 ORDER BY CIMH.CommInspDocItemNo, CIMH.MeasureSeq
END