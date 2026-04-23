-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2020-03-11
-- Description : ESR 상세
-- Modified :

-- exec usp_ESRMeasureHist_get '','','2020-06-01','2020-06-07'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ESRMeasureHist_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE,
	@pToDate DATE
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'

	SELECT A.LineCode AS LineCode
	      ,A.InspectionDateTime AS InspectionDateTime
		  ,A.InspectionValue AS ESR_Value
		  ,NULL AS OCV_Value
		  ,CONVERT(NUMERIC(20,3),
			  CASE WHEN ISNUMERIC(B.LowerSpec) = 1 THEN B.LowerSpec 
					ELSE SUBSTRING(B.LowerSpec, 1, CHARINDEX('~',B.LowerSpec, 0) - 1) 
				END) AS LSL
		  ,CONVERT(NUMERIC(20,3),
			  CASE WHEN ISNUMERIC(B.UpperSpec) = 1 THEN B.UpperSpec 
					ELSE CASE WHEN CHARINDEX('(',B.UpperSpec, 0) = 0 
          					  THEN SUBSTRING(B.UpperSpec, CHARINDEX('~',B.UpperSpec, 0) + 1, 100) 
          					  ELSE SUBSTRING(B.UpperSpec, CHARINDEX('~',B.UpperSpec, 0) + 1, CHARINDEX('(',B.UpperSpec, 0) - CHARINDEX('~',B.UpperSpec, 0) - 1)  
								   END
			END) AS USL

	  FROM STB_ESRInspectionData A
	  LEFT OUTER JOIN STB_ModelSpec B	    ON A.MaterialCode = B.ModelCode
	   AND B.SpecItemCode IN ('SM0041', 'L0042')
	 WHERE A.InspectionDateTime BETWEEN @FromDate AND @ToDate
END