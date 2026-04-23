-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018.08.06
-- Browsable : true
-- Group : 품질관리 > 부적합보고서등록 > 불량증상코드 팝업
-- Description:	불량유형정보를 가져옵니다(popup용)
-- Modified:

-- EXEC usp_DefectInfo_popup 'ProductInsp'
-- EXEC usp_DefectInfo_popup '03'
-- ============================================= exec [usp_DefectInfo_popup] 'dinhmanh','','9000',''
CREATE PROCEDURE [dbo].[usp_DefectInfo_popup]
						@pProcessUserID [varchar](20),
						@pProcessLanguage [varchar](20),
						@pDefectGroupCode [varchar](50) = NULL,
						@pType [varchar](50) = NULL
WITH RECOMPILE, EXECUTE AS CALLER

AS
BEGIN

	SET NOCOUNT ON;
	--RAISERROR(@pDefectGroupCode,16,1)
	DECLARE @DefectGroupCode VARCHAR(50) = CASE WHEN ISNULL(@pDefectGroupCode,'') = '' THEN '*' ELSE @pDefectGroupCode END

	DECLARE @CheckWorkcenterCode VARCHAR(50) 


	select @CheckWorkcenterCode=Workcentercode from stb_userinfo where userid=@pProcessUserID


	IF @pDefectGroupCode in ( '02', '08') 

	BEGIN
		SET @DefectGroupCode = 'RouteInsp'
	END 

	IF @pDefectGroupCode IN  ('03', '05', '06', '07', '10') 
	BEGIN
		SET @DefectGroupCode = 'ProductInsp'
	END
	 IF(@pType='QC')
	BEGIN	
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
					LEFT OUTER JOIN STB_TypeErrorGroupOfFactory TEG      WITH(NOLOCK)	ON DI.DirectlyUnder = TEG.TypeErrorCode
			WHERE 1=1
				AND ((@DefectGroupCode = '*') OR (DI.DefectGroupCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @DefectGroupCode)))) 

				AND DI.DirectlyUnder  IN ('PQC') --Mr.Duy add
				--AND ((@DefectGroupCode = '*') OR (DI.DefectGroupCode =  @DefectGroupCode))
				AND DI.IsUsed = 1
			ORDER BY
					DG.BasicDefectGroupName, DI.DisplayIndex
	END
	ELSE if(@CheckWorkcenterCode<>'VVT_F3')
	BEGIN
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
				AND ((@DefectGroupCode = '*') OR (DI.DefectGroupCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @DefectGroupCode)))) 
				
				--AND ((@DefectGroupCode = '*') OR (DI.DefectGroupCode =  @DefectGroupCode))
				AND DI.IsUsed = 1
			ORDER BY
					DG.BasicDefectGroupName, DI.DisplayIndex
	END
	
	ELSE
	BEGIN
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
					LEFT OUTER JOIN STB_TypeErrorGroupOfFactory TEG      WITH(NOLOCK)	ON DI.DirectlyUnder = TEG.TypeErrorCode
			WHERE 1=1
				--AND ((@DefectGroupCode = '*') OR (DI.DefectGroupCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @DefectGroupCode)))) 
				AND DI.DefectGroupCode like '%VE%' 
				AND DI.DirectlyUnder NOT IN ('PQC') --Mr.Duy add
				--AND ((@DefectGroupCode = '*') OR (DI.DefectGroupCode =  @DefectGroupCode))
				AND DI.IsUsed = 1
			ORDER BY
					DG.BasicDefectGroupName, DI.DisplayIndex
	END
END

