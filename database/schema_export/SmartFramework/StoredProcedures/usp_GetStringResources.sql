-- Procedure: usp_GetStringResources






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Get String Resource
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetStringResources]
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Language VARCHAR(20) = @pProcessLanguage

    SELECT
			@Language AS Language,
			SRD.Type,
			SRD.Name,
			ISNULL(SR.Value,SRD.Value) AS Value,
			ISNULL(SR.Description, SRD.Description) AS Description,
			ISNULL(CONVERT(VARCHAR,
			CASE 
				WHEN SR.ChangeDateTime IS NULL THEN SRD.ChangeDateTime
				ELSE SR.ChangeDateTime
			END, 120),'2000-01-01 00:00:00') AS ChangeDateTime
    FROM
			STB_StringResources SRD WITH(NOLOCK)
			LEFT OUTER JOIN STB_StringResources SR WITH(NOLOCK)
				ON	SR.Language = @Language AND
					SR.Type = SRD.Type AND
					SR.Name = SRD.Name
	WHERE
			SRD.Language = 'Default'
END







GO

