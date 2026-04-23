-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2018-09-06
-- Browsable : true
-- Group : 생산관리 > [B530] 제품생산실적입력 - 팝업
-- Description:	공정에 해당하는 생산설비를 가져옵니다
-- Modified:

-- exec [usp_ProductMachineForRoute_popup] '','','','','V-02'
-- exec [usp_ProductMachineForRoute_popup] '','','','','M-03'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductMachineForRoute_popup]
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
	set @RouteCode = Case  -- Mr.Duy thêm cho nhà máy hà nam
		when @RouteCode='VELINE-01' then 'VE01'
		when @RouteCode='VELINE-02' then 'VE02'
		when @RouteCode='VELINE-03' then 'VE03'
		when @RouteCode='VELINE-04' then 'VE04'
		when @RouteCode='VELINE-05' then 'VE05'
		when @RouteCode='VELINE-06' then 'VE06'
		when @RouteCode='VELINE-07' then 'VE07'
		when @RouteCode='VELINE-08' then 'VE08'
		when @RouteCode='VELINE-09' then 'VE09'
		when @RouteCode='VELINE-10' then 'VE10'
	else
		@RouteCode
	end
	SELECT
			MCM.MachineCode,
			MCM.MachineName,
			MCM.MachineTypeCode,
			MCM.MachineNumber,
			
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

--SELECT * FROM STB_MachineMaster WHERE MachineCode = 'VVEP385'

--SELECT * FROM STB_ProductMachine WHERE MachineCode = 'VVEP385'

--INSERT INTO STB_ProductMachine  (MachineCode,LineCode,RouteCode,CreateDatetime,CreateUserID) VALUES ('VVEP385','ELECTRODE LINE','V-02',GETDATE(),'nguyennha')
