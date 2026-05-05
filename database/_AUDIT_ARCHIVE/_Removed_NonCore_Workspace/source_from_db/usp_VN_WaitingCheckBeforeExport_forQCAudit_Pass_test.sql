-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_WaitingCheckBeforeExport_forQCAudit_Pass_test]
	-- Add the parameters for the stored procedure here
			@pProcessUserID varchar(20),
			@pProcessLanguage varchar(20),
			@pIDCODE varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	RAISERROR(@pIDCODE,16,1)
	--Return;

	--DECLARE @StatusCheck NVARCHAR(30)
	--SELECT @StatusCheck = StatusCheck FROM STB_VN_FINISHGOODS_forQCAudit WHERE ID = @pID
	


	--IF @StatusCheck = 'Pass'
	--	BEGIN
	--		DECLARE @errIsPassed nvarchar(200)
	--		set @errIsPassed = N'Packing này đã được đánh giá pass';
	--		RAISERROR(@errIsPassed,16,1)
	--	END
	--ELSE 
	--	BEGIN
	--		UPDATE STB_VN_FINISHGOODS_forQCAudit
	--		SET Statusout = 'Pass'
	--		WHERE ID = @pID
	--	END
	
END
