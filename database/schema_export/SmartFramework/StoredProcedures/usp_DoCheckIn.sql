-- Procedure: usp_DoCheckIn




-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-24
-- Description:	Developer 에서 화면을 닫으면 체크인합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCheckIn]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@Name VARCHAR(50) = @pName

    UPDATE
			STB_ScreenInfo
	SET
			CheckOutUserID = NULL
	WHERE
			Name = @Name --AND
			--CheckOutUserID = @ProcessUserID
END





GO

