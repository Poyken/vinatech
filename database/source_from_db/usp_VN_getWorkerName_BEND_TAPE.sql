
CREATE  PROC  [dbo].[usp_VN_getWorkerName_BEND_TAPE]

	@pWorkCenterCode varchar(20)


AS
BEGIN
	SET NOCOUNT ON;

	-------------------------------------- 2025-01-14 DinhManh update for Ha Nam Factory
	IF (@pWorkCenterCode = 'VVT_F3')
		BEGIN
			SELECT 
				WorkerCode AS CreateUserID, 
				workername
			FROM
				STB_ProdWorkerInfo
			WHERE
					WorkCenterCode = 'VVT_F3'
				AND IsUsed = 1
				AND WorkerGroupCode = 'VE-01'
				
		END
	-------------------------------------------------------

	ELSE
		BEGIN
			select
			workercode as CreateUserID, workername
			from 
			STB_ProdWorkerInfo
			where companycode='VVT' and workercode not like 'JA%' and createuserid<>'kilee' and empno is not null
			and workername not like 'Ms.%' and IsUsed=1
		END


	

END