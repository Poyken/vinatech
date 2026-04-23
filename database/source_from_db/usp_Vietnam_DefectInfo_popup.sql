-- =============================================
-- Author: Mr.Tung
-- Create date: 2021.10.07
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_DefectInfo_popup]
						@pDefectGroupCode [varchar](50) = NULL
WITH RECOMPILE, EXECUTE AS CALLER

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @DefectGroupCode VARCHAR(50) = CASE WHEN ISNULL(@pDefectGroupCode,'') = '' THEN '*' ELSE @pDefectGroupCode END

	--if(replace(@DefectGroupCode,'V-','') <= '11') select @DefectGroupCode = replace(@DefectGroupCode,'V-','E-')

	if(@pDefectGroupCode is null or @pDefectGroupCode='') begin
		SELECT
			'' as DefectCode,
			--DI.BasicDefectName,
			N'Chưa chọn mã Route' as  BasicDefectName,
			N'Chưa chọn mã Route' as DefectDesc,
			'' as DefectGroupCode,
			'' as BasicDefectGroupName,
			'' as DisplayIndex,
			'' as IsRealDefect,
			'' as DefectImage			
		return;
	end
	
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
		--AND ((@DefectGroupCode = '*') OR (DI.DefectGroupCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @DefectGroupCode)))) 
		AND ((@DefectGroupCode = '*') OR (DI.DefectGroupCode =  @DefectGroupCode))
		AND DI.IsUsed = 1
		--and DI.DefectCode not like 'E-%'
		and DI.DefectCode not in (
			'E-02_W01',
			'E-02_W05',
			'E-02_W06',
			'E-02_W15',
			'E-03_W01',
			'E-03_W03',
			'E-03_W15',
			'E-11_W15'		
			)
	ORDER BY
			DG.BasicDefectGroupName, DI.DisplayIndex

END

select*from STB_DefectInfo