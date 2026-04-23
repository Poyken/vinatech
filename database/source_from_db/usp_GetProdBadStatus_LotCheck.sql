-- =============================================
-- Author:	   kilee
-- Create date: 2019-07-31
-- Browsable : true
-- Group : 조립불량현황
-- Description:	[B660] 조립불량현황
-- Modified: 2019-08-16, Jackaroe
--             2019-09-10, kilee 공정명 변경 및  불량코드 이상한것 확인 (품질-공정검사 불합격사유코드임) -> [C132 불량증상정보]
-- =============================================
-- [프로시저 실행문]      EXEC [usp_GetProdBadStatus_LotCheck]  '','','',''

-- SELECT * FROM STB_DefectRepairInfo WHERE FindLineCode = 'ASSYLINE-12' and FindJobdate Between '2019-09-09' and '2019-09-09' and DefectCode in ( 'E-26_4GE')                   -- 불량코드 등록자 확인
-- SELECT * FROM STB_Setinfo where ControlNo in ( '20190901000087', '20190902000065')                                                                                                                  -- 해당 바코드 정보 확인

CREATE PROCEDURE [dbo].[usp_GetProdBadStatus_LotCheck]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,	
	@pControlNo VARCHAR(20) = NULL
	--@pWorkCenterCode VARCHAR(20) = NULL,
 --   @pLineCode VARCHAR(20) = NULL,
	--@pRouteCode VARCHAR(20) = NULL,
	--@pMaterialCode VARCHAR(50) = NULL,
	--@pFromDate DATE = NULL,
	--@pToDate DATE = NULL,
	--@pIsOutputRoute BIT = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'')    = '' THEN 'VNT'     ELSE @pCompanyCode    END
	DECLARE @ControlNo  VARCHAR(20)      = CASE WHEN ISNULL(@pControlNo,'')    = '' THEN '%'       ELSE @pControlNo       END

	--DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN 'VNT_F1' ELSE @pWorkCenterCode END
	--DECLARE @LineCode VARCHAR(20)          = CASE WHEN ISNULL(@pLineCode,'')           = '' THEN '%'        ELSE @pLineCode          END
	--DECLARE @RouteCode VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '%'       ELSE @pRouteCode        END
	--DECLARE @MaterialCode VARCHAR(50)     = CASE WHEN ISNULL(@pMaterialCode,'')       = '' THEN '%'       ELSE @pMaterialCode     END
	--DECLARE @FromDate DATE                   = @pFromDate
	--DECLARE @ToDate DATE                      = @pToDate
	--DECLARE @IsOutputRoute BIT = @pIsOutputRoute

		-- Lot 추적 (노승한D 요청)
			 SELECT A.BarCode                                                                                           
			  FROM STB_Setinfo A
			 WHERE 1=1
			    AND A.ControlNo = @ControlNo	
				--and a.ControlNo = '20190909000034'

END