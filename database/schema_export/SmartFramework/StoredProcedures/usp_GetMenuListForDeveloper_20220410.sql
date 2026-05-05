-- Procedure: usp_GetMenuListForDeveloper_20220410






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Get Menu List
-- =============================================
Create PROCEDURE [dbo].[usp_GetMenuListForDeveloper_20220410]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			S.*
	FROM
			(
				SELECT 
						SI.Name AS ID,
						SI.Name,
						SI.TCode,
						SI.IsFolder,	
						SI.IsNeverClose,		
						SI.ShowAfterStart,
						SI.ShowInMenu,
						SI.ParentName,			
						SI.Caption,
						CASE SI.IsFolder
							WHEN 1 THEN 0
							ELSE SI.CurrentVersion
						END AS CurrentVersion,
						CASE SI.IsFolder
							WHEN 1 THEN 0
							ELSE
								(
									SELECT
											MAX(SLI.Version)
									FROM
											STB_ScreenLayoutInfo SLI WITH(NOLOCK)
									WHERE
											SLI.Name = SI.Name
								)
						END AS MaxVersion,
						SI.CreateDateTime,
						SI.CreateUserID,
						SI.AccessType,
						CASE
							WHEN ISNULL(SI.TCode,'') = '' THEN 'ZZZZ'
							ELSE SI.TCode
						END AS VirtualTCode
				FROM
						SmartFramework_220409.dbo.STB_ScreenInfo SI WITH(NOLOCK)
				WHERE
						SI.IsDelete = 0
			) S
	ORDER BY
			S.IsFolder DESC,
			S.VirtualTCode,
			S.Caption
END







GO

