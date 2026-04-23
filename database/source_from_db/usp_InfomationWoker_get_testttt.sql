CREATE PROCEDURE [dbo].[usp_InfomationWoker_get_testttt] 
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pWokerCode varchar(10) = NULL,
		@pCompanyCode VARCHAR(20) = NULL,
		@pWorkCenterCode VARCHAR(20) = NULL
		
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @WokerCode VARCHAR(10) = CASE WHEN ISNULL(@pWokerCode,'') = '' THEN '%' ELSE @pWokerCode END
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END


    -- Insert statements for procedure here

	SELECT 
			CompanyCode,
			CompanyName,
			WorkCenterCode,
			WorkCenterName,
			WorkerCode AS OldWorkerCode,
			WorkerCode,
			WorkerName,
			LanguageCode,
			OrgWorkerName,
			Nationality,
			EmpNo,
			WorkerImage,
			IsUsed,
			CreateDateTime,
			CreateUserID,
			ChangeDateTime,
			ChangeUserID,
			IsProdWorker,
			WorkerGroupCode,
			DATEJOIN,
			LineCode,
			LineName


	from STB_ProdWorkerInfo_Test_forLap
	where
		WorkerCode like @WokerCode
		AND CompanyCode like @CompanyCode
		AND WorkCenterCode LIKE @WorkCenterCode
END