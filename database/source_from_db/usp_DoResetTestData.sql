-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 공통
-- Browsable : false
-- Create date : 2018-07-30
-- Description : 테스트 데이터 초기화
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoResetTestData]
AS
BEGIN
	SET NOCOUNT ON;

	SET CONTEXT_INFO 0X999999	-- STB_MaterialDocInfo 트리거 무력화
	DELETE FROM STB_MaterialDocInfo
	SET CONTEXT_INFO 0x999998	-- STB_MaterialDocDetail 트리거 무력화
	DELETE FROM STB_MaterialDocDetail
	SET CONTEXT_INFO 0x999997	-- STB_MaterialDocLotInfo 트리거 무력화
	DELETE FROM STB_MaterialDocLotInfo
	SET CONTEXT_INFO 0X0
	DELETE FROM STB_MaterialLotInfo
	DELETE FROM STB_MaterialLotSnapshot
	DELETE FROM STB_MaterialDocPickingPlan
	DELETE FROM STB_MaterialStock
	DELETE FROM STB_MaterialOrder
	DELETE FROM STB_MaterialOrderItem
	DELETE FROM STB_MrpMaster
	DELETE FROM STB_MrpSourceMaterial
	DELETE FROM STB_MrpTargetMaterial
	DELETE FROM STB_MaterialQcInfo
	DELETE FROM STB_MaterialQcDetail	
	DELETE FROM STB_MaterialQcSampleResult	
	DELETE FROM STB_ProductionOrderInfo
	DELETE FROM STB_ProductionOrderBom
	DELETE FROM STB_MaterialQcInspectionGroup
	DELETE FROM STB_MaterialQcInspectionItem
	DELETE FROM STB_SalesOrder
	DELETE FROM STB_SalesOrderItem
	DELETE FROM STB_SalesPlan
END
