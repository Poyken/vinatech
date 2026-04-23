-- =============================================
-- Author:		DinhManh
-- Create date: 2025-04-14
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_WaitingCheckBeforeExport_forQCAudit_Pass]
	-- Add the parameters for the stored procedure here
			@pProcessUserID varchar(20),
			@pProcessLanguage varchar(20),
			@pID varchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		--declare @fd varchar(10)=@pID
		--RAISERROR(@fd,16,1)
		--Return;

	--DECLARE @tmpID VARCHAR(10)
	--SELECT @tmpID = ID FROM STB_VN_FINISHGOODS_forQCAudit where ID = @pID
	--RAISERROR(@tmpID,16,1)
	--Return;
	--RAISERROR(@pID,16,1)
	--Return;

	DECLARE @getStatusCheck NVARCHAR(30)
	SELECT @getStatusCheck = StatusCheck FROM STB_VN_FINISHGOODS_forQCAudit WHERE ID = @pID

	--RAISERROR(@getStatusCheck,16,1)
	--Return;

	IF (@getStatusCheck = 'Pass')
		BEGIN
			DECLARE @errIsPassed nvarchar(200)
			set @errIsPassed = N'Packing này đã được đánh giá pass';
			RAISERROR(@errIsPassed,16,1)
		END
	ELSE IF (@getStatusCheck IS NULL)
		BEGIN
			UPDATE STB_VN_FINISHGOODS_forQCAudit
			SET StatusCheck = 'Pass'
			WHERE ID = @pID
		END

END
