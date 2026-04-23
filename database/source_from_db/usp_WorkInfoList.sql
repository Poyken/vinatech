

-- =============================================
-- Author:		Lee kang-il
-- Create date: 2018-12-18
-- Browsable : false
-- Description:	Get Database Tables
-- =============================================
CREATE PROCEDURE [dbo].[usp_WorkInfoList]
AS


BEGIN
	SET NOCOUNT ON;

	DELETE FROM STB_ProdWorkerInfo WHERE CompanyCode = 'VNT' ;


	INSERT INTO STB_ProdWorkerInfo (CompanyCode, WorkCenterCode, WorkerCode , WorkerName, EmpNo, IsUsed, CreateDateTime, CreateUserID)
	SELECT 'VNT' 
		, 'VNT_F1'
		, EMPCD
		, EMPNM
		, EMPCD
		, '1'
		, Replace(CONVERT(varchar(30), GetDate(),120),'-','/')
		, 'lki'
	FROM erpsvr.erpdb.DBO.EMPMST
	WHERE 1=1
	  AND ENDYMD = ''                              -- 퇴사하지 않은 인원
    ; 


	DELETE FROM STB_ProdWorkerInfo 
	FROM erpsvr.erpdb.DBO.EMPMST ER  INNER JOIN STB_ProdWorkerInfo   NA ON ER.EMPCD = NA.WorkerCode
	WHERE 1=1
	  AND ER.ENDYMD <> ''                        -- 퇴사자(퇴사일이 있는 사람)
	 ;


END







