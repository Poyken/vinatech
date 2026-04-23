-- =============================================
-- Author: Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17
-- Browsable : true
-- Group : 팝업
-- Description:	팝업 작업자코드
-- Modified: 생산 작업자를 가져옵니다  

-- TEST :    exec usp_ProdWorkerInfo_Popup 'kilee','Korean','', '', 'C-08,C-09,C-10,C-19'
--            EXEC usp_ProdWorkerInfo_Popup_20191212 'kilee','Korean','VVT', '', '','V-20'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProdWorkerInfo_Popup_20191212]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
	@pCostGroupString VARCHAR(MAX) = NULL,
	@pRouteCode VARCHAR(20) = NULL  

AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' 
	                                                            WHEN @pRouteCode LIKE 'V%' THEN 'VVT'
																WHEN @pRouteCode LIKE 'E%' THEN 'VNT'	ELSE @pCompanyCode END

	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @CostGroupString VARCHAR(MAX) = ISNULL(@pCostGroupString, '')

	-- DECLARE @CostGroupString VARCHAR(MAX) = ISNULL(@pCostGroupString, '')
    
	IF @CostGroupString = '' 
	
	
	BEGIN
		SELECT
				PWI.WorkerCode,
				PWI.WorkerName,
				PWI.OrgWorkerName,
				PWI.Nationality,
				PWI.EmpNo
		FROM
				STB_ProdWorkerInfo PWI WITH(NOLOCK)
				LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON CI.CompanyCode = PWI.CompanyCode
				LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)		ON WCI.WorkCenterCode = PWI.WorkCenterCode
		WHERE 1=1
		   AND PWI.CompanyCode    LIKE @CompanyCode 
		   AND PWI.WorkCenterCode LIKE @WorkCenterCode 
		   AND PWI.IsUsed = 1
		   AND PWI.IsProdWorker = 1
		   --AND PWI.EMPNO IN ('16030206','16101002','18013101','12060501','18040203','18121002','15090101','19040406','17092402', '18052104','14122202','18070901','19032509', '19012101','15031604', '17081601', '19012101', '19040401')       -- 임시적용 kilee (2019-07-11)
		   -- 원가그룹과 상관없이 모든 현장 작업자를 리스트에 표시함. 2019.09.03 김전식 반장님 요청 By Jackaroe
			--AND PWI.WorkerCode  IN (
			--                                       SELECT WorkerCode
			--										FROM STB_CostGroupWorkerMapping 
			--									   WHERE IsAssigned = 1 
			--										AND CostGroupCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @CostGroupString))
			--										) 
	END ELSE 
	
	BEGIN
		SELECT
				PWI.WorkerCode,
				PWI.WorkerName,
				PWI.OrgWorkerName,
				PWI.Nationality,
				PWI.EmpNo
		FROM
				STB_ProdWorkerInfo PWI WITH(NOLOCK)
				LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON CI.CompanyCode = PWI.CompanyCode
				LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)		ON WCI.WorkCenterCode = PWI.WorkCenterCode
		WHERE 1=1
		   AND PWI.CompanyCode    LIKE @CompanyCode 
		   AND PWI.WorkCenterCode LIKE @WorkCenterCode 
		   AND PWI.IsUsed = 1
		   AND PWI.IsProdWorker = 1
			AND PWI.WorkerCode  IN (
			                                       SELECT WorkerCode
													FROM STB_CostGroupWorkerMapping 
												   WHERE IsAssigned = 1 
													AND CostGroupCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @CostGroupString))
									)            

			--AND ((@CompanyCode = '*') OR (PWI.CompanyCode = @CompanyCode))                                                               -- 2019.11.07 추가

	END

END