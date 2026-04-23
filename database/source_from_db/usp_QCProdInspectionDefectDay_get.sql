-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_QCProdInspectionDefectDay_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pGroupCode VARCHAR(20) = NULL,
	@pFromDate DATETIME,
	@pToDate DATETIME
AS

BEGIN
	Declare @FromDate DATETIME = @pFromDate
	       ,@ToDate DATETIME = @pToDate
		   ,@GroupCode VARCHAR(20) = CASE WHEN @pGroupCode IS NULL THEN '%' ELSE @pGroupCode END

	SELECT WORK_DATE AS BaseYmd
		  ,SUM(NCNFRMITY_LOT_SIZE) AS LotQty 
		  ,SUM(NCNFRMITY_ERROR_CNT) AS DefectQty
		  ,CASE WHEN SUM(NCNFRMITY_LOT_SIZE) = 0 THEN 0
		        ELSE CONVERT(NUMERIC(20, 3), SUM(NCNFRMITY_ERROR_CNT)) 
		      / CONVERT(NUMERIC(20, 3), SUM(NCNFRMITY_LOT_SIZE)) * 1000000 END AS DefectPPMRate
	  FROM ERPSVR.VINATECH.DBO.VECS_QC_RPT A
	  INNER JOIN ERPSVR.VINATECH.DBO.COMMON_CODE B
	    ON A.NCNFRMITY_CD = B.DTL_CD
	   AND B.GROUP_CD IN ('020', '021')
	   AND B.GROUP_CD LIKE @GroupCode
	 WHERE WORK_DATE BETWEEN @FromDate AND @ToDate
	   AND A.NCNFRMITY_DIV_CD IN ('02', '03')
	 GROUP BY WORK_DATE
	 ORDER BY WORK_DATE
END