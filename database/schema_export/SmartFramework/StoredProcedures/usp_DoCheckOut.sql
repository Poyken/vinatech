-- Procedure: usp_DoCheckOut




-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Browsable: false
-- Create date: 2016-07-24
-- Description:	디벨로퍼에서 화면을 열면 화면을 체크아웃합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCheckOut]
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
			CheckOutUserID = @ProcessUserID
	WHERE
			Name = @Name AND
			CheckOutUserID IS NULL
END





GO

