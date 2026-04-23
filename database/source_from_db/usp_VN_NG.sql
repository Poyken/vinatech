CREATE PROC [dbo].[usp_VN_NG]
@pProcessLanguage VARCHAR(20),
@pProcessUserID VARCHAR(20),
@pWorkCenterCode VARCHAR(10) -- DinhManh update 2025-04-04
AS
BEGIN
SET NOCOUNT ON;
		--SELECT 
		--		CodeNG,
		--		NG
		--FROM    STB_VN_NG
		--WHERE IsUsed=1

		IF @pWorkCenterCode = 'VVT_F3' 
			BEGIN
				SELECT 
						CodeNG,
						NG
				FROM    STB_VN_NG
				WHERE
						IsUsed=1
					AND WorkCenterCode LIKE 'VVT_F3'
			END 
		
		ELSE 
			BEGIN
				SELECT 
						CodeNG,
						NG
				FROM    STB_VN_NG
				WHERE
						IsUsed=1
					AND (WorkCenterCode LIKE 'VVT_F1' OR WorkCenterCode LIKE 'VVT_F2')
			END 
END