
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2018-07-24
-- Browsable : true
-- Group : 공통
-- Description:	설비정보 조회
-- Modified:
--                2021.12.17 사용자id 추가
--                2021.12.27 WorkCenter코드 추가
--                2022.02.23 사용자명으로 변경

--  usp_MachineMaster_get '','','VNT','VNT_F1',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineMaster_get]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pCompanyCode VARCHAR(20) = NULL,
					@pWorkCenterCode VARCHAR(20) = NULL,
					@pMachineName NVARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @MachineName NVARCHAR(100) = CASE WHEN ISNULL(@pMachineName,'') = '' THEN '%' ELSE @pMachineName END

    
	SELECT
			MM.MachineCode AS OldMachineCode,
			MM.MachineCode,
			MM.CompanyCode,
			MM.WorkCenterCode ,
			MM.MachineName,
			MM.MachineNumber,         -- DinhManh update 2025-01-14
			MM.IsProdMachine,
			MM.MachineTypeCode,
			MT.MachineTypeName,
			MM.IsUsed,
			MM.IsMonitoring,
			MM.MonitoringGroup,
			MM.MachineRunStatus,
			MM.LossCode,
			MM.LossStartDateTime,
			MM.LossHistNo,
			MM.IsAlarm,
			MM.RunStartDateTime,
			MM.CreateDateTime,
			MM.CreateUserID	
		  , UI.UserName	  	      As CreateUserName
		  , MM.ChangeDateTime
		  , MM.ChangeUserID		  	   
		  , UL.UserName	  	  As ChangeUserName
		  ,isnull(dv.CODELOCATIONMACHINES,dv.CODESTOREMACHINES) as CODELOCATIONMACHINES

	FROM
			STB_MachineMaster MM WITH(NOLOCK)
			LEFT OUTER JOIN VW_MachineType MT		 WITH(NOLOCK)ON	MT.MachineTypeCode = MM.MachineTypeCode			
			LEFT OUTER JOIN SmartFramework.dbo.STB_UserInfo UI WITH(NOLOCK) ON UI.UserID = MM.CreateUserID 
			LEFT OUTER JOIN SmartFramework.dbo.STB_UserInfo UL WITH(NOLOCK) ON UL.UserID = MM.ChangeUserID 
			left outer join STB_VN_DEVICEMACHINES dv WITH(NOLOCK) on mm.MachineCode=dv.CodeB250
	WHERE 1=1
	   AND 			(MM.CompanyCode LIKE @CompanyCode) 
	   AND			(MM.WorkCenterCode LIKE @WorkCenterCode) 
	   AND			(MM.MachineName LIKE @MachineName) 

END
