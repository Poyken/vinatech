

-- =============================================
-- Author:	Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2019-05-10
-- Browsable : true
-- Group : 자재관리
-- Description:	피킹용 자재정보를 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialLotInfoForPicking]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialDocNo VARCHAR(20) = NULL,
	@pLotID VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaterialDocNo VARCHAR(20) = @pMaterialDocNo,
			@LotID VARCHAR(50) = @pLotID

	SELECT 
			MLI.MaterialLotNo,
			MDD.MaterialDocNo,
			MDD.MaterialDocDetailNo,
			MLI.LotID,
			MLI.CompanyCode,
			MLI.WorkCenterCode,
			MLI.MaterialWarehouseCode,
			MW.MaterialWarehouseName,
			MLI.MaterialLocationCode,
			ML.MaterialLocationName,
			MLI.MaterialCode,
			MM.MaterialName,
			MLI.StockAttrib1,
			MLI.StockAttrib2,
			MLI.StockAttrib3,
			MLI.CurrentQty,
			MLI.CurrentQty AS StockQty
	FROM 
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = MLI.MaterialCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)
				ON MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)
				ON ML.MaterialLocationCode = MLI.MaterialLocationCode
			LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)
				ON MDD.MaterialDocNo = @MaterialDocNo AND
				MDD.MaterialCode = MLI.MaterialCode
	WHERE
			MLI.LotID = @LotID
	
END