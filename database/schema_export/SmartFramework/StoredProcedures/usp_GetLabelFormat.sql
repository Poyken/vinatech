-- Procedure: usp_GetLabelFormat




-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : 
-- Browsable : true
-- Create date: 2016
-- Description: 
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetLabelFormat]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pLabelType NVARCHAR(30),
	@pFormatName NVARCHAR(30)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@LabelType NVARCHAR(30) = @pLabelType,
			@FormatName NVARCHAR(30) = @pFormatName
	
	SELECT
			LI.*
	FROM
			STB_LabelInfo LI WITH(NOLOCK)
	WHERE
			LI.LabelType = @LabelType AND
			LI.FormatName = @FormatName
END





GO

