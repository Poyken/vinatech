
-- =============================================
-- Author:	kilee
-- Create date: 2020-02-03
-- Browsable : true
-- Group :
-- Description:	NG체크 popup 조회용
-- EXEC [usp_NG_Check_popup]
-- =============================================
CREATE PROCEDURE [dbo].[usp_NG_Check_popup] 

WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	
	SELECT  'OK' AS 'TYPE'

	UNION 

	SELECT  'NG'  AS 'TYPE'
	         

END

