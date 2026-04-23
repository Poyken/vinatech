

-- =============================================
-- Author:	Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-23
-- Browsable : true
-- Group : 자재수불문서
-- Description: 자재수불문서, 아이템 저장 IUD
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMaterialDocMasterDetail_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX) = NULL	
WITH RECOMPILE
AS
BEGIN
	CREATE TABLE #SEQUENCE_TABLE
	(
		KeyValue VARCHAR(20),
		UID_KEY VARCHAR(50)
	)
	
	SET NOCOUNT ON;
	--RAISERROR(@pXml,16,1)
	
	EXEC usp_MaterialDocInfo_iud @pProcessUserID, @pProcessLanguage, 'MaterialDocInfo', @pXml
	
	EXEC usp_MaterialDocDetail_iud @pProcessUserID, @pProcessLanguage, 'MaterialDocDetail', @pXml
	
	
	DROP TABLE #SEQUENCE_TABLE
	
END



