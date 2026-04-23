-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-07-14
-- Browsable : true
-- Group : 비가동관리
-- Description: 라인비가동이력저장
-- Modified: 
-- =============================================
CREATE PROCEDURE [dbo].[usp_InsertLineNonOperationConfirm]
		@lineNonOperationCode VARCHAR(20),
		@dashboardRouteCode VARCHAR(20),
		@lineCode VARCHAR(20),
		@remark NVARCHAR(MAX) = NULL
AS
BEGIN
	Declare @CompanyCode VARCHAR(20)
	       ,@WorkCenterCode VARCHAR(20)
		   ,@LineNonOperationHistNo VARCHAR(20)

	SELECT @CompanyCode = CompanyCode
	      ,@WorkCenterCode = WorkCenterCode
	  FROM STB_LineInfo
	 WHERE LineCode = @lineCode

	-- If Exist Stop Line
	IF EXISTS (SELECT 1 FROM STB_LineNonOperationHist WHERE LineCode = @lineCode AND LineRestartDateTime IS NULL) BEGIN
		UPDATE STB_LineNonOperationHist
		   SET LineRestartDateTime = GETDATE()
		      ,LineRestartRemark = @remark
			  ,ChangeDateTime = GETDATE()
		 WHERE LineCode = @lineCode
		   AND LineRestartDateTime IS NULL
	END ELSE BEGIN
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_LineNonOperationHist',@LineNonOperationHistNo OUTPUT

		INSERT INTO STB_LineNonOperationHist (LineNonOperationHistNo, DashboardRouteCode, CompanyCode, WorkCenterCode, LineCode
		                                    , LineStopDateTime, LineStopRemark, LineNonOperationCode)
			SELECT @LineNonOperationHistNo, @dashboardRouteCode, @CompanyCode, @WorkCenterCode, @lineCode
			                                , GETDATE(), @remark, @lineNonOperationCode
	END
END