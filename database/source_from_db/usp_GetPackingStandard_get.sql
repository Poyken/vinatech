
-- ===============================================================================================
-- Author:	    Kangs (kilee@vina.co.kr)
-- Create date: 2020-11-02
-- Browsable : True
-- Group : 생산관리
-- Description:	품목별 포장갯수 기준정보
-- Modified:
-- 프로시저 실행 : usp_GetPackingStandard_get '','','','','','','0813'
--                      usp_GetPackingStandard_get '','','','','','',''
-- ===============================================================================================
CREATE PROCEDURE [dbo].[usp_GetPackingStandard_get]
							@pProcessUserID VARCHAR(20),
							@pProcessLanguage VARCHAR(20),
							@pCompanyCode VARCHAR(20) = NULL,
							@pWorkCenterCode VARCHAR(20) = NULL,
							@pLineCode VARCHAR(200) = NULL,														
							@pMaterialCode VARCHAR(50) = NULL,
							@pSize VARCHAR(5) = NULL,
							@pMaterialTypeCode VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode    VARCHAR(20) = CASE  WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE  WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END	
	DECLARE @LineCode           VARCHAR(200) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '*' ELSE @pLineCode END	
	DECLARE @MaterialCode      VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = ''    THEN '*' ELSE @pMaterialCode   END
	--DECLARE @FromDate DATE = @pFromDate
	--DECLARE @ToDate    DATE = @pToDate
	DECLARE @Size                     VARCHAR(50) = CASE WHEN ISNULL(@pSize,'') = ''    THEN '*' ELSE @pSize   END
	DECLARE @MaterialTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = ''    THEN '*' ELSE @pMaterialTypeCode   END

    SELECT SPS.MaterialTypeCode
	        , Case When SPS.MaterialTypeCode = 'FERT'  Then '제품' 
			        When SPS.MaterialTypeCode = 'MDL'  Then '모듈' 
					   else '' End AS MaterialTypeName
			, SPS.Size
			, SPS.Voltage
			, SPS.Farad
			, SPS.VinylBagQty
			, SPS.InnerBoxQty 
			, SPS.OutBoxQty
			, CONVERT(VARCHAR(10), SPS.CreateDateTime, 121)  as CreateDateTime  
			, SPS.CreateUserID
			, CONVERT(VARCHAR(10), SPS.ChangeDateTime, 121)  as ChangeDateTime
			, SPS.ChangeUserID
	FROM STB_PackingStandard SPS WITH(NOLOCK) 
			--LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)						ON MM.MaterialCode = DRI.MaterialCode		
	WHERE 1=1
			AND (@Size = '*' OR SPS.Size = @Size) 
			AND	(@MaterialTypeCode = '*' OR SPS.MaterialTypeCode = @MaterialTypeCode) 			
			--AND	(@MaterialCode = '*' OR DRI.MaterialCode = @MaterialCode)
			--AND	(@LineCode = '*' OR DRI.FindLineCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@LineCode))) 
			--AND	DRI.FindJobdate BETWEEN @FromDate AND @ToDate
			--AND	DRI.RepairType NOT IN ('MISSING')						
	--GROUP BY				
	--		CASE WHEN DRI.FindRouteCode IN ('E-27', 'V-27') THEN MQI.DecisionResult ELSE NULL END

END