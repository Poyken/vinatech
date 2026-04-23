-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2018-09-06
-- Browsable : true
-- Group : 팝업
-- Description:	공정에 해당하는 생산설비를 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE usp_ProductMachineForRoute_electron
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL  
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '%' ELSE @pRouteCode END
	
	SELECT
			MCM.MachineCode,
			MCM.MachineName,
			MCM.MachineTypeCode,
			
			-- 2020.04.16 추가부분
			PatIndex('%[0-9]%', MCM.MachineName)  AS OrderCode,
			 CASE WHEN MCM.MachineName LIKE '권취%'                                                    THEN 0			        
					WHEN MCM.MachineName LIKE '셀%'     And MCM.MachineCode NOT IN  ('VNEP02106', 'VNEP03084', 'VNEP05510') THEN 1
					WHEN MCM.MachineName LIKE '셀10%'  And MCM.MachineCode        IN ('VNEP02106', 'VNEP03084', 'VNEP05510','VVEP291')  THEN 2 
					WHEN MCM.MachineName LIKE '중형%'                                                    THEN 3  
					ELSE 9 END AS Orderno
	FROM
			STB_ProductMachine PM
	        INNER JOIN			STB_MachineMaster MCM	   ON PM.MachineCode = MCM.MachineCode 
	WHERE 1=1
		AND MCM.CompanyCode LIKE @CompanyCode 
		AND MCM.WorkCenterCode LIKE @WorkCenterCode 
		AND MCM.IsProdMachine = 1 
		AND PM.RouteCode = @RouteCode
	ORDER BY Orderno, OrderCode, MCM.MachineName     
  --ORDER BY MCM.MachineName                                                                         -- 정렬추가 (2019.07.17, kilee) -> 변경 (2020.04.16, 조현준 요청)
  --ORDER BY MCM.MachineName, MCM.MachineCode                                              -- 정렬추가 (2019.07.17, kilee) -> 변경 (2020.04.16, 조현준 요청)
	 
	 			
END

--select * from STB_ProductMachine

--select * from STB_MachineMaster