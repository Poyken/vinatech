-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-01-28
-- Browsable : true
-- Group : 생산관리
-- Description:	라인별 담당자 정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE usp_LineManagerEmailInfo_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL
AS
BEGIN
	Declare @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
	       ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
	       ,@LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '*' ELSE @pLineCode END

	SELECT LMEI.LineCode
	      ,LI.LineName
          ,LMEI.ManagerID
		  ,PWI.WorkerName AS ManagerName
          ,LMEI.ManagerEmail
          ,LMEI.IsUsed
          ,LMEI.CreateDateTime
          ,LMEI.CreateUserID
          ,LMEI.ChangeDateTime
          ,LMEI.ChangeUserID
	  FROM STB_LineManagerEmailInfo LMEI
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI
	    ON LMEI.ManagerID = PWI.WorkerCode
	  LEFT OUTER JOIN STB_LineInfo LI
	    ON LMEI.LineCode = LI.LineCode
	 WHERE (@LineCode = '*' OR LMEI.LineCode = @LineCode)
	 ORDER BY LMEI.LineCode
END
