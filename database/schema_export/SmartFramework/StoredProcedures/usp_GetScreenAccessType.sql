-- Procedure: usp_GetScreenAccessType






-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-05-16
-- Browsable: true
-- Description:	Screen 접속방법 유형을 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetScreenAccessType]
	
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT	'PC' AS AccessType
	UNION
	SELECT	'Web' AS AccessType
	UNION
	SELECT	'Mobile' AS AccessType
END







GO

