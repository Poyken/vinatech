-- =============================================
-- Author:		Mr.Duy	
-- Create date: 2025-04-18
-- Description:	Pop
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectInfo_popup_B530]				--  usp_DefectInfo_popup_B530 'DinhManh' , '', 'MV-04', ''
						@pProcessUserID [varchar](20),
						@pProcessLanguage [varchar](20),
						@pDefectGroupCode [varchar](50) = NULL,
						@pType [varchar](50) = NULL
AS
BEGIN

	SET NOCOUNT ON;
	--RAISERROR(@pDefectGroupCode,16,1)
	--return;
	DECLARE @DefectGroupCode VARCHAR(50) = CASE WHEN ISNULL(@pDefectGroupCode,'') = '' THEN '*' ELSE @pDefectGroupCode END

	DECLARE @CheckWorkcenterCode VARCHAR(50) 


	select @CheckWorkcenterCode=Workcentercode from stb_userinfo where userid=@pProcessUserID

	--RAISERROR(@CheckWorkcenterCode,16,1)
	--return;
	IF @pDefectGroupCode in ( '02', '08') 

	BEGIN
		SET @DefectGroupCode = 'RouteInsp'
	END 

	IF @pDefectGroupCode IN  ('03', '05', '06', '07', '10') 
	BEGIN
		SET @DefectGroupCode = 'ProductInsp'
	END

	--RAISERROR(@pDefectGroupCode,16,1)
	--return;


	 IF(@pType='QC')
	BEGIN	
		print('1')
		SELECT
					DI.DefectCode,
					--DI.BasicDefectName,
					(case when DI.DefectDesc is null Then DI.BasicDefectName Else DI.BasicDefectName+'_'+DI.DefectDesc End) AS BasicDefectName,
					DI.DefectDesc,
					DI.DefectGroupCode,
					DG.BasicDefectGroupName,
					DI.DisplayIndex,
					DI.IsRealDefect,
					DI.DefectImage,
					DI.DefectCause
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
		print('2')
			SELECT
					DI.DefectCode,
					--DI.BasicDefectName,
					(case when DI.DefectDesc is null Then DI.BasicDefectName Else DI.BasicDefectName+'_'+DI.DefectDesc End) AS BasicDefectName,
					DI.DefectDesc,
					DI.DefectGroupCode,
					DG.BasicDefectGroupName,
					DI.DisplayIndex,
					DI.IsRealDefect,
					DI.DefectImage,
					DI.DefectCause
			FROM
					STB_DefectInfo DI WITH(NOLOCK)
					LEFT OUTER JOIN STB_DefectGroup DG WITH(NOLOCK)				ON DI.DefectGroupCode = DG.DefectGroupCode
				
			WHERE 1=1
				AND ((@DefectGroupCode = '*') OR (DI.DefectGroupCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @DefectGroupCode)))) 
				
				AND ((@DefectGroupCode = '*') OR (DI.DefectGroupCode =  @DefectGroupCode))
				AND (DI.DirectlyUnder NOT IN ('PQC', 'Reliability', 'PQC _Defect', 'IQC')  OR DI.DirectlyUnder NOT LIKE '%QC%'  OR DI.DirectlyUnder IS NULL)
					--Mr.Manh add 2026-03-20 following Mr.Bach and Mr.Lee (QC)


				AND DI.IsUsed = 1
			ORDER BY
					DG.BasicDefectGroupName, DI.DisplayIndex
	END
	
	ELSE
	BEGIN
		print('3')
		SELECT
					DI.DefectCode,
					--DI.BasicDefectName,
					(case when DI.DefectDesc is null Then DI.BasicDefectName Else DI.BasicDefectName+'_'+DI.DefectDesc End) AS BasicDefectName,
					DI.DefectDesc,
					DI.DefectGroupCode,
					DG.BasicDefectGroupName,
					DI.DisplayIndex,
					DI.IsRealDefect,
					DI.DefectImage		,
					DI.DefectCause
			FROM
					STB_DefectInfo DI WITH(NOLOCK)
					LEFT OUTER JOIN STB_DefectGroup DG WITH(NOLOCK)				ON DI.DefectGroupCode = DG.DefectGroupCode
					LEFT OUTER JOIN STB_TypeErrorGroupOfFactory TEG      WITH(NOLOCK)	ON DI.DirectlyUnder = TEG.TypeErrorCode
			WHERE 1=1
				AND ((@DefectGroupCode = '*') OR (DI.DefectGroupCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @DefectGroupCode)))) 
				--AND DI.DefectGroupCode like '%VE%' 
				AND DI.DirectlyUnder NOT IN ('PQC', 'Reliability', 'PQC _Defect', 'IQC') --Mr.Duy add
				AND ((@DefectGroupCode = '*') OR (DI.DefectGroupCode =  @DefectGroupCode))
				AND DI.IsUsed = 1
			ORDER BY
					DG.BasicDefectGroupName, DI.DisplayIndex
	END
END
