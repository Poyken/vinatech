-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2021-03-26
-- Browsable : true
-- Group : 팝업
-- Description:	팝업 작업자코드
-- Modified: 생산 승인자 가져옵니다  - 셀장님들만

-- TEST :  
--          EXEC [usp_ProdIInspectionWorkerInfo_Popup] 'kilee','Korean','', '', '' ,NULL 
-- =============================================

CREATE PROCEDURE [dbo].[usp_ProdIInspectionWorkerInfo_Popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
	@pCostGroupString VARCHAR(MAX) = NULL,
	@pRouteCode VARCHAR(20) = NULL                        

AS
BEGIN
	SET NOCOUNT ON;



  DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' AND @pRouteCode = ''      THEN '%' 
																   WHEN ISNULL(@pCompanyCode,'') = '' AND @pRouteCode = NULL THEN '%' 
																   WHEN ISNULL(@pCompanyCode,'') = '' AND @pRouteCode IS NULL THEN '%' 
																   WHEN @pRouteCode LIKE 'V%' THEN 'VVT'
																   WHEN @pRouteCode LIKE 'E%' THEN 'VNT'	ELSE @pCompanyCode END                   


	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @CostGroupString VARCHAR(MAX) = ISNULL(@pCostGroupString, '')
    
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
					LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON CI.CompanyCode      = PWI.CompanyCode
					LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)		ON WCI.WorkCenterCode = PWI.WorkCenterCode
			WHERE 1=1
			   AND PWI.CompanyCode    LIKE @CompanyCode 
			   AND PWI.WorkCenterCode LIKE @WorkCenterCode 
			   AND PWI.IsUsed = 1
			   AND PWI.IsProdWorker = 1
			   AND PWI.EMPNO IN ('18121003','20030111','21111001','23050102','19120109','20092301')       -- 채민수대리 고정

	END

END