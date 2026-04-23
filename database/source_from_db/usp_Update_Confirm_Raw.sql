CREATE PROC [dbo].[usp_Update_Confirm_Raw]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pID NVARCHAR(30),
	@pWorkCenterCode NVARCHAR(30)
AS
BEGIN
		SET NOCOUNT ON;


    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ID VARCHAR(20) = @pID,
			@WorkCenterCode NVARCHAR(30) = @pWorkCenterCode

IF @WorkCenterCode = 'VVT_F1'
	BEGIN
			UPDATE STB_VN_ORDER_MATERIALS

			SET
					STATUS_MATERIALS = N'Đã duyệt',
					APPROVEREDBY = @ProcessUserID,
					CREATEDATE_APPROVERBY = DATEADD(HH, -2, GETDATE())
			WHERE
					ID = @ID AND WorkCenterCode = @WorkCenterCode
	END

ELSE IF @WorkCenterCode = 'VVT_F2'

		BEGIN
			UPDATE STB_VN_ORDER_MATERIALS

			SET
					STATUS_MATERIALS = N'Đã duyệt',
					APPROVEREDBY = @ProcessUserID,
					CREATEDATE_APPROVERBY = DATEADD(HH, -2, GETDATE())
			WHERE
					ID = @ID AND WorkCenterCode = @WorkCenterCode
	END
END

--SELECT * FROM STB_VN_ORDER_MATERIALS