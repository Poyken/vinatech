

-- =============================================
-- Author:	Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-23
-- Browsable : true
-- Group : 자재발주관리
-- Description: 자재발주오더/아이템 정보를 저장합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMaterialOrderMasterDetail_iud]
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
	
	
	EXEC usp_MaterialOrder_iud @pProcessUserID, @pProcessLanguage, 'MaterialOrderMasterView', @pXml
	
	EXEC usp_MaterialOrderItem_iud @pProcessUserID, @pProcessLanguage, 'MaterialOrderDetailView', @pXml
	
	
	DROP TABLE #SEQUENCE_TABLE
	
END


