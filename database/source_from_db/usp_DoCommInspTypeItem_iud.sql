

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-01
-- Browsable : true
-- Group : 공용검사관리
-- Description:	공용검사유형항목정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCommInspTypeItem_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX) = NULL	
AS
BEGIN

	CREATE TABLE #SEQUENCE_TABLE
	(
		KeyValue VARCHAR(50),
		UID_KEY VARCHAR(50)
	)
	
	SET NOCOUNT ON;
	
	
	EXEC usp_CommInspTypeInfo_iud @pProcessUserID, @pProcessLanguage, 'CommInspTypeInfo', @pXml
	
	EXEC usp_CommInspItem_iud @pProcessUserID, @pProcessLanguage, 'CommInspItem', @pXml
	
	
	DROP TABLE #SEQUENCE_TABLE
END



