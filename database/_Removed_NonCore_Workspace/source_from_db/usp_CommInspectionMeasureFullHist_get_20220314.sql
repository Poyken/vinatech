-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리/생산관리
-- Browsable : true
-- Create date : 2019-11-06
-- Description : 
-- Modified :

--  usp_CommInspectionMeasureFullHist_get_20220314  'kilee',  'Korean', 'VNT' , 'VNT_F1',  'ROUTE_TEST_VPC'     ,'2022-03-10 00:00:00','2022-03-14 00:00:00', 'LIVT38-018', default ,'', '', '0825'
-- =======================================================================================================================================
CREATE PROCEDURE [dbo].[usp_CommInspectionMeasureFullHist_get_20220314]
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
			, @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
			, @ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'
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
		          WHEN CII.CommInspInputType = '2' 	AND CIMH.MeasureResult = '1' THEN 'OK'    	ELSE CONVERT(VARCHAR(100), CIMH.NumericMeasure) END AS MeasureResult           -- 원본수정(kilee, 2020-03-16)
		 , CIDH.CreateDateTime AS MeasureDateTime
		 , RIGHT('0'+CONVERT(VARCHAR, FLOOR(MBISizeW)),2) + CONVERT(VARCHAR, FLOOR(MBISizeH)) AS SizeCode	
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
	   AND CIDH.CommInspTypeCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@CommInspTypeCode))
	   AND CIDH.CreateDateTime BETWEEN @FromDate AND @ToDate
	   AND (@CompanyCode = '*' OR CIDH.CompanyCode = @CompanyCode)										-- 추가 용은재 (2020.01.23)
	   AND (@Barcode = '*' OR SI.Barcode LIKE @Barcode)
	   AND (@MaterialCode = '*' OR CIDH.MaterialCode LIKE @MaterialCode)
	   AND (@CommInspItemCode = '*' OR CII.CommInspItemCode LIKE @CommInspItemCode)
	   AND (@LineCode = '*' OR SI.InputLineCode LIKE @LineCode)

	   AND (@SizeCode = '*' Or  RIGHT('0'+CONVERT(VARCHAR, FLOOR(MBISizeW)),2) + CONVERT(VARCHAR, FLOOR(MBISizeH))  LIKE @SizeCode)       
	   AND CIDI.CommInspItemCode <> 'RQV_V'

	 ORDER BY CIMH.CommInspDocItemNo, CIMH.MeasureSeq
END