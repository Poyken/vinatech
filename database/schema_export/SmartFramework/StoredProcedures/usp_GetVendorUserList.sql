-- Procedure: usp_GetVendorUserList






-- =============================================
-- Author:		Kim Han Young
-- Group: System
-- Browsable: false
-- Create date: 2018-08-29
-- Description:	Get User List
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetVendorUserList]
	@pProcessUserID VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@SystemCode VARCHAR(20)
    
	SELECT
			@SystemCode = UI.SystemCode
	FROM
			STB_UserInfo UI WITH(NOLOCK)
	WHERE
			UI.UserID = @ProcessUserID

	IF @SystemCode = 'Nexen.Mate' BEGIN
		SELECT
				UI.*,
				(
					SELECT
							CCI.ConstValue
					FROM
							STB_ConstCodeInfo CCI
					WHERE
							CCI.ConstName = 'ProgramTitle'
				) AS Title
		FROM
				Nexen_Solid_Mate.dbo.VW_UserInfo UI WITH(NOLOCK)
		WHERE
				UI.SystemCode = @SystemCode AND
				UI.UserID <> 'admin'

	END ELSE IF @SystemCode = 'LOB' BEGIN
		SELECT
				UI.*,
				Appendix1 AS CompanyCode,
				Appendix2 AS WorkCenterCode
		FROM
				STB_UserInfo UI WITH(NOLOCK)
		WHERE
				UI.SystemCode = @SystemCode AND
				UI.UserID <> 'admin'

	END ELSE BEGIN
		SELECT
				UI.*,
				(
					SELECT
							CCI.ConstValue
					FROM
							STB_ConstCodeInfo CCI
					WHERE
							CCI.ConstName = 'ProgramTitle'
				) AS Title
		FROM
				STB_UserInfo UI WITH(NOLOCK)
		WHERE
				UI.SystemCode = @SystemCode AND
				UI.UserID <> 'admin'
	END
END







GO

