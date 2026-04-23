-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-02-12
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDefectInfoForC590_popup]	--	usp_GetDefectInfoForC590_popup '' ,''
	-- Add the parameters for the stored procedure here
	    @pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

			SELECT
					DI.DefectCode,
					--DI.BasicDefectName,
					(case when DI.DefectDesc is null Then DI.BasicDefectName Else DI.BasicDefectName+'_'+DI.DefectDesc End) AS BasicDefectName,
					DI.DefectDesc,
					DI.DefectGroupCode,
					DG.BasicDefectGroupName,
					DI.DisplayIndex,
					DI.IsRealDefect,
					DI.DefectImage			
			FROM
					STB_DefectInfo DI WITH(NOLOCK)
					LEFT OUTER JOIN STB_DefectGroup DG WITH(NOLOCK)				ON DI.DefectGroupCode = DG.DefectGroupCode
				
			WHERE 1=1
				AND DI.DefectGroupCode = 'ProductInsp'
				
				--AND ((@DefectGroupCode = '*') OR (DI.DefectGroupCode =  @DefectGroupCode))
				AND DI.IsUsed = 1
			ORDER BY
					DG.BasicDefectGroupName, DI.DisplayIndex


		-- select * from STB_DefectInfo
END
