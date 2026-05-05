-- Procedure: usp_DoValidateUserId




-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-06-13
-- Browsable: false
-- Description:	사용자 아이디의 유효성을 체크합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoValidateUserId]
	@pUserID VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (
				SELECT
						1
				FROM
						STB_UserInfo UI WITH(NOLOCK)
				WHERE
						UI.UserID = @pUserID
			  ) BEGIN
		RAISERROR('Duplicated',16,1)
		RETURN
	END
END





GO

