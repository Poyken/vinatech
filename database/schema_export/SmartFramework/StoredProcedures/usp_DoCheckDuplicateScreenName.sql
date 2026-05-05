-- Procedure: usp_DoCheckDuplicateScreenName






-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Browsable: false
-- Create date: 2016-03-19
-- Description:	Check screen name was duplicated
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCheckDuplicateScreenName]
	@pName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Name VARCHAR(50) = @pName

	IF EXISTS (
				SELECT
						SI.Name
				FROM
						STB_ScreenInfo SI
				WHERE
						SI.Name = @Name
			  ) BEGIN
		RAISERROR('Duplicate Name',16,1)
	END
END







GO

