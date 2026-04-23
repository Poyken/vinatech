-- =============================================
-- Author:		DinhManh
-- Create date: 2025-04-14
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_ShowAllFinishGoodMES_forQCAudit_ExportFG]
	-- Add the parameters for the stored procedure here
		@pProcessUserID varchar(20),
		@pProcessLanguage varchar(20),
		@pIDCODE VARCHAR(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--RAISERROR(@pIDCODE,16,1)
	--Return;


	DECLARE @StatusCheck	NVARCHAR(20)
	DECLARE @FGLocation		NVARCHAR(30)
	DECLARE @StatusOut		NVARCHAR(30)
    -- Insert statements for procedure here
	SELECT	@StatusCheck = StatusCheck from STB_VN_FINISHGOODS_forQCAudit where IDCODE = @pIDCODE
	SELECT	@FGLocation = FGLocation	from STB_VN_FINISHGOODS_forQCAudit where IDCODE = @pIDCODE
	SELECT	@StatusOut = Statusout	from STB_VN_FINISHGOODS_forQCAudit where IDCODE = @pIDCODE
	

	--DECLARE @err NVARCHAR(100) = @StatusCheck + ' ' + @FGLocation + ' ' + @StatusOut
	--RAISERROR(@StatusCheck,16,1)
	--Return;
	
	IF (@StatusOut IS NULL)
		BEGIN 
			DECLARE @errIsExported nvarchar(200)
			set @errIsExported = N'Packing này chưa được xuất';
			RAISERROR(@errIsExported,16,1)
		END
	ELSE IF (@StatusCheck <> 'Pass' OR @StatusCheck IS NULL)
		BEGIN 
			DECLARE @errIsNotPass nvarchar(200)
			set @errIsNotPass = N'Packing này chưa được đánh giá PASS';
			RAISERROR(@errIsNotPass,16,1)
		END
	ELSE IF (@FGLocation = N'Bắc Ninh' OR @FGLocation IS NULL)
		BEGIN 
			DECLARE @errFGLocation  nvarchar(200)
			set @errFGLocation = N'Chỉ được xuất kho với hàng của Bắc Giang';
			RAISERROR(@errFGLocation,16,1)
		END
	ELSE IF (@FGLocation = N'Bắc Giang' )
		BEGIN 
			UPDATE STB_VN_FINISHGOODS_forQCAudit
			SET Statusout = N'Xuất',
				DateExport = GETDATE(),
				PersonExport = @pProcessUserID
			WHERE IDCODE = @pIDCODE
		END

END
