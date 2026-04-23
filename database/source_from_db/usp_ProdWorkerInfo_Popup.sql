-- =============================================
-- Author: Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17
-- Browsable : true
-- Group : 팝업
-- Description:	팝업 작업자코드
-- Modified: 생산 작업자를 가져옵니다  
-- 원가그룹매핑 기준에서 생산작업자그룹의 작업그룹 기준으로 변경 #210719

-- TEST :  exec usp_ProdWorkerInfo_Popup 'kilee','Korean','', '', 'C-08,C-09,C-10,C-19'
--          EXEC usp_ProdWorkerInfo_Popup 'kilee','Korean','', '', '' ,NULL
--          EXEC usp_ProdWorkerInfo_Popup 'kilee','Korean','', '', 'C-21,V-21' ,NULL                            -- 품질관련
--          EXEC usp_ProdWorkerInfo_Popup 'kilee','Korean','', '', 'C-20, V-20' ,NULL 
--          EXEC usp_ProdWorkerInfo_Popup 'kilee','Korean', '', '', '' ,'EM-01'
--      EXEC usp_ProdWorkerInfo_Popup 'anhduy157','VI', 'VVT', 'VVT_F3', 'C-21,V-21' ,'' 
-- ===================================================================================

CREATE PROCEDURE [dbo].[usp_ProdWorkerInfo_Popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
	@pCostGroupString VARCHAR(MAX) = NULL,
	@pRouteCode VARCHAR(20) = NULL                            -- 2019.12.12 추가 (kilee)

AS
BEGIN
	SET NOCOUNT ON;
	--raiserror (@pCostGroupString,16,1)
  --DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END               -- 원본 백업

 	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' AND @pRouteCode = ''      THEN '%' 
	                                                            WHEN ISNULL(@pCompanyCode,'') = '' AND @pRouteCode = NULL THEN '%' 
																WHEN ISNULL(@pCompanyCode,'') = '' AND @pRouteCode IS NULL THEN '%' 
	                                                            WHEN @pRouteCode LIKE 'V%' THEN 'VVT'
																WHEN @pRouteCode LIKE 'MV%' THEN 'VVT'  -- add by Mr.Tung on 2022-April-12 because B530 not show Vietnam Emp 
																WHEN @pRouteCode LIKE 'ND%' THEN 'VVT'  -- add by Mr.Manh
																WHEN @pRouteCode LIKE 'E%' THEN 'VNT'	
																WHEN @pRouteCode LIKE 'M%' THEN 'VNT'		
																WHEN @pRouteCode LIKE 'S%' THEN 'VNT'		
																WHEN @pRouteCode LIKE 'VE%' THEN 'VVT'
																WHEN @pRouteCode LIKE 'T%' THEN 'VNT'
																WHEN @pRouteCode LIKE 'GM%' THEN 'VNT'
																ELSE @pCompanyCode END                   -- 2019.12.12 추가 (kilee)


	--DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' AND @pRouteCode = ''      THEN '%' 	                                                           
	--                                                            WHEN @pRouteCode LIKE 'V-%' THEN 'VVT'
	--															WHEN @pRouteCode LIKE 'E-%' THEN 'VNT'	ELSE @pCompanyCode END                   -- 2019.12.12 추가 (kilee)


	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @WorkCenterCodeGetVVTF3 VARCHAR(20) 
	DECLARE @CostGroupString VARCHAR(MAX) = ISNULL(@pCostGroupString, '')

	-- kiểm tra nếu là người của nhà máy hà nam sẽ lấy người chỉ ở hà nam
	SELECT @WorkCenterCodeGetVVTF3 = WorkCenterCode 
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID

	-- raiserror (@WorkCenterCodeGetVVTF3,16,1)
	IF @WorkCenterCodeGetVVTF3 = 'VVT_F3' BEGIN
		SET @WorkCenterCode = 'VVT_F3'
	END
    

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
														FROM STB_ProdWorkerInfo --#210719 
													   WHERE IsUsed = 1 
														AND WorkerGroupCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @CostGroupString))
										)            
	END

END

