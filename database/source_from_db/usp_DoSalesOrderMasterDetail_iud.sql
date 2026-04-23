

-- =============================================
-- Author:	Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-23
-- Browsable : true
-- Group : 영업오더관리
-- Description: 영업오더 마스터, 아이템 정로를 저장합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSalesOrderMasterDetail_iud]
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
	
	
	EXEC usp_SalesOrder_iud @pProcessUserID, @pProcessLanguage, 'SalesOrderList', @pXml
	
	EXEC usp_SalesOrderItem_iud @pProcessUserID, @pProcessLanguage, 'SalesOrderItemList', @pXml
	
	
	DROP TABLE #SEQUENCE_TABLE
	
END


