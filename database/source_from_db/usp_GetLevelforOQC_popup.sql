
-- =============================================
-- Author:	kilee
-- Create date: 2020-01-03
-- Browsable : true
-- Group :
-- Description:	불량리스트 popup 조회용
-- EXEC [usp_BadList_popup]
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetLevelforOQC_popup]

WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
		
	SELECT  'A' as LevelBox, 'A' as ValueBox
	union
	SELECT  'B' as LevelBox, 'B' as ValueBox
	union
	SELECT  'C' as LevelBox, 'C'  as ValueBox
	union
	SELECT  'D' as LevelBox, 'D'  as ValueBox
	union
	SELECT  'R' as LevelBox, 'R'  as ValueBox
	union
	SELECT  'S' as LevelBox, 'S'  as ValueBox
	union
	SELECT  'X' as LevelBox, 'X'  as ValueBox
	union
	SELECT  'Y' as LevelBox, 'Y'  as ValueBox
	union
	SELECT  'W' as LevelBox, 'W'  as ValueBox
		union
	SELECT  'Z' as LevelBox, 'Z'  as ValueBox

END
