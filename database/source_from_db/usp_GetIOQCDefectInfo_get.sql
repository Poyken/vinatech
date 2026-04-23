-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-02-07
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetIOQCDefectInfo_get]
	-- Add the parameters for the stored procedure here
	    @pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pDefectCode VARCHAR(20) = NULL,
		@pInspectionDocType VARCHAR(10) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DefectCode VARCHAR(20) = CASE WHEN ISNULL(@pDefectCode,'') = '' THEN '%' ELSE @pDefectCode END
	DECLARE @InspectionDocType VARCHAR(10) = CASE WHEN ISNULL(@pInspectionDocType,'') = '' THEN '%' ELSE @pInspectionDocType END
    -- select * from STB_IOQCDefectInfo

		SELECT 
		    DI.DefectCode, 
			DI.BasicDefectName,
			DI.DefectDesc,
			DI.InspectionDocType,
			DI.IsUsed,
			DI.CreateDateTime,
			DI.CreateUserID,
			DI.ChangeDateTime,
			DI.ChangeUserID

		FROM STB_IOQCDefectInfo DI WITH (NOLOCK)
		WHERE DI.DefectCode LIKE @DefectCode
		AND DI.InspectionDocType = @InspectionDocType
END
