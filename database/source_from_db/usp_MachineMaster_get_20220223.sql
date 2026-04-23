
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

--  usp_MachineMaster_get_20220223  '', '' , 'VNT', 'VNT_F1',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineMaster_get_20220223]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pMachineName NVARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @MachineName     NVARCHAR(100) = CASE WHEN ISNULL(@pMachineName,'') = '' THEN '%' ELSE @pMachineName END
    
	SELECT		
			MM.CreateUserID
		 -- , PWI.WorkerName
		  , UI.UserID 
		  , UI.UserName 
		 -- , EI2.EmployeeNo
		 -- , EI2.EmployeeName
	FROM
			STB_MachineMaster MM WITH(NOLOCK)
			LEFT OUTER JOIN VW_MachineType MT		              ON	MT.MachineTypeCode = MM.MachineTypeCode
			--LEFT OUTER JOIN STB_ProdWorkerInfo PWI	              ON MM.CreateUserID = PWI.WorkerCode
			LEFT OUTER JOIN SmartFramework.DBO.STB_UserInfo UI  ON UI.UserID = MM.CreateUserID
			--LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI2	    ON MM.CreateUserID = EI2.EmployeeNo   --and EI2.EmployeeNo = PWI.CreateUserID


			-- select UserID, UserName from SmartFramework.DBO.STB_UserInfo where  UserID = 'yjyu'

	WHERE 1=1
	   AND 			(MM.CompanyCode LIKE @CompanyCode) 
	   AND			(MM.WorkCenterCode LIKE @WorkCenterCode) 
	   AND			(MM.MachineName LIKE @MachineName) 

END
