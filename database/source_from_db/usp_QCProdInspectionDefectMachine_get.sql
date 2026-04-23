-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_QCProdInspectionDefectMachine_get]
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

	SELECT A.IDX
		  ,A.MachineCode
		  ,A.MachineName
		  ,A.DefectQty
		  ,SUM(B.DefectQty) AS DefectQtySum
		  ,CONVERT(INT, CONVERT(NUMERIC(20, 3), SUM(B.DefectQty)) 
				/ CONVERT(NUMERIC(20, 3), MAX(C.DefectQty)) * 1000000) AS DefectRatePPMSum
	  FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY SUM(NCNFRMITY_ERROR_CNT) DESC) AS IDX
				  ,EQPMNT_CD AS MachineCode
				  ,MM.MachineName 
				  ,SUM(NCNFRMITY_ERROR_CNT) AS DefectQty
				  FROM ERPSVR.VINATECH.DBO.VECS_QC_RPT A
				  INNER JOIN ERPSVR.VINATECH.DBO.COMMON_CODE B
					ON A.NCNFRMITY_CD = B.DTL_CD
				  LEFT OUTER JOIN STB_MachineMaster MM
				    ON A.EQPMNT_CD = MM.MachineCode
				   AND B.GROUP_CD IN ('020', '021')
				   AND B.GROUP_CD LIKE @GroupCode
				 WHERE WORK_DATE BETWEEN @FromDate AND @ToDate
				   AND A.NCNFRMITY_DIV_CD IN ('02', '03')
				 GROUP BY EQPMNT_CD, MM.MachineName 
			) A
		   INNER JOIN (
			SELECT ROW_NUMBER() OVER(ORDER BY SUM(NCNFRMITY_ERROR_CNT) DESC) AS IDX
				  ,EQPMNT_CD AS MachineCode
				  ,MM.MachineName 
				  ,SUM(NCNFRMITY_ERROR_CNT) AS DefectQty
				  FROM ERPSVR.VINATECH.DBO.VECS_QC_RPT A
				  INNER JOIN ERPSVR.VINATECH.DBO.COMMON_CODE B
					ON A.NCNFRMITY_CD = B.DTL_CD
				  LEFT OUTER JOIN STB_MachineMaster MM
				    ON A.EQPMNT_CD = MM.MachineCode
				   AND B.GROUP_CD IN ('020', '021')
				   AND B.GROUP_CD LIKE @GroupCode
				 WHERE WORK_DATE BETWEEN @FromDate AND @ToDate
				   AND A.NCNFRMITY_DIV_CD IN ('02', '03')
				 GROUP BY EQPMNT_CD, MM.MachineName 
			) B
			ON A.IDX >= B.IDX
		   INNER JOIN (
			SELECT SUM(NCNFRMITY_ERROR_CNT) AS DefectQty
				  FROM ERPSVR.VINATECH.DBO.VECS_QC_RPT A
				  INNER JOIN ERPSVR.VINATECH.DBO.COMMON_CODE B
					ON A.NCNFRMITY_CD = B.DTL_CD
				   AND B.GROUP_CD IN ('020', '021')
				   AND B.GROUP_CD LIKE @GroupCode
				 WHERE WORK_DATE BETWEEN @FromDate AND @ToDate
				   AND A.NCNFRMITY_DIV_CD IN ('02', '03')
		   ) C
		   ON 1=1
	 WHERE A.DefectQty <> 0
	   AND A.MachineCode <> ''
	 GROUP BY A.IDX, A.MachineCode, A.MachineName, A.DefectQty
	 ORDER BY A.DefectQty DESC
END
