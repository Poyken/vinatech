-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 
-- Description : 
-- Modified : 최근 6개월 조회에서 입력된 기간 전체를 조회하도록 수정 양규철 부장님 요청 2020.11.12 By Jackaroe
-- =============================================
CREATE PROCEDURE [dbo].[usp_QCProdInspectionDefectMonth_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pGroupCode VARCHAR(20) = NULL,
	@pFromDate DATETIME,
	@pToDate DATETIME
AS

BEGIN
	Declare @FromDate DATETIME = @pFromDate --CONVERT(CHAR(7), DATEADD(month, -6, @pToDate), 121) + '-26'
	       ,@ToDate DATETIME = @pToDate
		   ,@GroupCode VARCHAR(20) = CASE WHEN ISNULL(@pGroupCode, '') = '' THEN '*' ELSE @pGroupCode END
	
	SELECT CASE WHEN CONVERT(INT, RIGHT(WORK_DATE, 2)) >= 26
	            THEN CONVERT(CHAR(7), DATEADD(month, 1, CONVERT(DATE, WORK_DATE, 121)), 121)
				ELSE LEFT(WORK_DATE, 7) END  AS BaseYm
		  ,SUM(NCNFRMITY_LOT_SIZE) AS LotQty 
		  ,SUM(NCNFRMITY_ERROR_CNT) AS DefectQty
		  ,CONVERT(NUMERIC(20, 3), SUM(NCNFRMITY_ERROR_CNT)) 
		      / CONVERT(NUMERIC(20, 3), SUM(NCNFRMITY_LOT_SIZE)) * 1000000 AS DefectPPMRate
	  FROM ERPSVR.VINATECH.DBO.VECS_QC_RPT A
	  INNER JOIN ERPSVR.VINATECH.DBO.COMMON_CODE B
	    ON A.NCNFRMITY_CD = B.DTL_CD
	   AND B.GROUP_CD IN ('020', '021')
	   AND (@GroupCode = '*' OR B.GROUP_CD = @GroupCode)
	 WHERE WORK_DATE BETWEEN @FromDate AND @ToDate
	   AND A.NCNFRMITY_DIV_CD IN ('02', '03')
	 GROUP BY CASE WHEN CONVERT(INT, RIGHT(WORK_DATE, 2)) >= 26
	            THEN CONVERT(CHAR(7), DATEADD(month, 1, CONVERT(DATE, WORK_DATE, 121)), 121)
				ELSE LEFT(WORK_DATE, 7) END
	 ORDER BY CASE WHEN CONVERT(INT, RIGHT(WORK_DATE, 2)) >= 26
	            THEN CONVERT(CHAR(7), DATEADD(month, 1, CONVERT(DATE, WORK_DATE, 121)), 121)
				ELSE LEFT(WORK_DATE, 7) END
END