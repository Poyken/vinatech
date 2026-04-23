
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-01
-- Browsable : true
-- Group : 공용검사관리
-- Description:	공용검사선택 분류,항목 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCommInspSelect_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX) = NULL	
AS
BEGIN

	CREATE TABLE #SEQUENCE_TABLE
	(
		KeyValue VARCHAR(20),
		UID_KEY VARCHAR(50)
	)
	
	SET NOCOUNT ON;
	
	
	EXEC usp_CommInspSelectGroup_iud @pProcessUserID, @pProcessLanguage, 'CommInspSelectGroup', @pXml
	
	EXEC usp_CommInspSelectItem_iud @pProcessUserID, @pProcessLanguage, 'CommInspSelectItem', @pXml
	
	
	DROP TABLE #SEQUENCE_TABLE
END


