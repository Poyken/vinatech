-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리/생산관리
-- Browsable : true
-- Create date : 2019-11-06
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommInspectionMeasureFullHistForDashboard_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pCommInspTypeCode VARCHAR(20) = NULL,
	@pFromDate DATETIME,
	@pToDate DATETIME,
	@pMaterialCode VARCHAR(20) = NULL,
	@pCommInspItemCode VARCHAR(20) = NULL,
	@pBarcode VARCHAR(20) = NULL, 
	@pLineCode VARCHAR(20) = NULL
AS

BEGIN
	Declare @CompanyCode VARCHAR(20) = @pCompanyCode
		   ,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode
		   ,@CommInspTypeCode VARCHAR(20) = @pCommInspTypeCode
		   ,@FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
		   ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'
		   ,@MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
		   ,@CommInspItemCode VARCHAR(20) = CASE WHEN ISNULL(@pCommInspItemCode, '') = '' THEN '*' ELSE @pCommInspItemCode END
		   ,@Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END
		   ,@LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '*' ELSE @pLineCode END

	SELECT SI.Barcode
	      ,SI.MaterialCode
		  ,MM.MaterialName
		  ,SI.InputLineCode AS LineCode
		  ,LI.LineName
		  ,CII.CommInspItemName
		  ,CIMH.MeasureSeq
		  ,CASE WHEN ISNUMERIC(CIDI.CommInspLower) = 1 AND CIDI.CommInspLower <> '-' THEN CONVERT(NUMERIC(38,5), CIDI.CommInspLower) ELSE NULL END AS CommInspLower
		  ,CASE WHEN ISNUMERIC(CIDI.CommInspUpper) = 1 AND CIDI.CommInspUpper <> '-' THEN CONVERT(NUMERIC(38,5), CIDI.CommInspUpper) ELSE NULL END AS CommInspUpper
		  ,CASE WHEN CII.CommInspInputType = '2' 
				THEN NULL --CIMH.MeasureResult 
				ELSE CONVERT(NUMERIC(38,5), CIMH.NumericMeasure) END AS MeasureResult
		  ,CIMH.MeasureDateTime
		  ,CONVERT(VARCHAR(10), CIMH.MeasureDateTime, 121) AS MeasureDate
		  ,CIMH.CommInspMeasureNo
		  ,CASE WHEN CII.CommInspItemGroup1 = 'E-22' THEN '권취'
		        WHEN CII.CommInspItemGroup1 = 'E-24' THEN '조립'
				ELSE CII.CommInspItemGroup1 END AS CommInspItemGroup 
	  FROM STB_CommInspMeasureHist CIMH
	  LEFT OUTER JOIN STB_CommInspDocItem CIDI
		ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo
	  LEFT OUTER JOIN STB_CommInspDocHistory CIDH
		ON CIDI.CommInspDocNo = CIDH.CommInspDocNo
	  LEFT OUTER JOIN STB_SetInfo SI
		ON SI.ControlNo = CIDH.ProdNo
	  LEFT OUTER JOIN STB_CommInspItem CII
		ON CII.CommInspItemCode = CIDI.CommInspItemCode
      LEFT OUTER JOIN STB_LineInfo LI
	    ON SI.InputLineCode = LI.LineCode
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON SI.MaterialCode = MM.MaterialCode
	 WHERE CIDH.CompanyCode LIKE @CompanyCode
	   AND CIDH.WorkCenterCode LIKE @WorkCenterCode
	   AND CIDH.CommInspTypeCode = @CommInspTypeCode
	   AND CIMH.MeasureDateTime BETWEEN @FromDate AND @ToDate
	   AND (@Barcode = '*' OR SI.Barcode LIKE @Barcode)
	   AND (@MaterialCode = '*' OR CIDH.MaterialCode LIKE @MaterialCode)
	   AND (@CommInspItemCode = '*' OR CII.CommInspItemCode LIKE @CommInspItemCode)
	   AND (@LineCode = '*' OR SI.InputLineCode LIKE @LineCode)
	 ORDER BY CIMH.CommInspDocItemNo, CIMH.MeasureSeq
END