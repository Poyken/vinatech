-- Procedure: usp_GetUpgradeFile






-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Browsable: false
-- Create date: 2016-07-07
-- Description:	Get Upgrade File
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetUpgradeFile]
	@pProgramName NVARCHAR(50) = 'GUI',
	@pFileName NVARCHAR(255) = NULL,
	@pPlatform VARCHAR(10) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProgramName NVARCHAR(50) = @pProgramName,
			@FileName NVARCHAR(255) = @pFileName,
			@Platform VARCHAR(10) = @pPlatform

	SELECT
			UF.FileName,
			UF.Platform,
			UF.FileData,
			UF.TargetPath,
			UF.ExtractZip
	FROM
			STB_UpgradeFiles UF WITH(NOLOCK)
	WHERE
			UF.ProgramName = @ProgramName AND
			UF.FileName = @FileName AND
			(UF.Platform = 'Any' OR UF.Platform = @Platform)
END







GO

