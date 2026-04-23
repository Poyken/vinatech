-- =============================================
-- Author:	Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-23
-- Browsable : true
-- Group : 자재창고/로케이션관리
-- Description: 자재창고/로케이션 보를 저장합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMaterialWarehouseLocation_iud]
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
	
	
	EXEC usp_MaterialWarehouse_iud @pProcessUserID, @pProcessLanguage, 'MaterialWarehouse', @pXml
	
	EXEC usp_MaterialLocation_iud @pProcessUserID, @pProcessLanguage, 'MaterialLocation', @pXml
	
	
	DROP TABLE #SEQUENCE_TABLE
	
END
