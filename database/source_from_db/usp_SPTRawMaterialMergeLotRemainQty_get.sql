-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-09-08
-- Browsable : true
-- Group : 지지체
-- Description:	지지체 원자재 소분 잔량
-- Modified:
-- =============================================
CREATE PROCEDURE usp_SPTRawMaterialMergeLotRemainQty_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT MLI.MaterialLotNo
	      ,MLI.LotID
	      ,MLI.MaterialCode
		  ,MM.MaterialName
		  ,MLI.GRDate
		  ,MLI.MaterialWarehouseCode
		  ,MW.MaterialWarehouseName
		  ,MLI.MaterialLocationCode
		  ,ML.MaterialLocationName
		  ,MLI.CurrentQty
	  FROM STB_MaterialLotInfo MLI
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MLI.MaterialCode = MM.MaterialCode
	  LEFT OUTER JOIN STB_MaterialWarehouse MW
	    ON MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
	  LEFT OUTER JOIN STB_MaterialLocation ML
	    ON ML.MaterialLocationCode = MLI.MaterialLocationCode
	 WHERE LotID IN (SELECT MergeLotID FROM STB_SupportRawMaterialMergeHist)
	   AND MLI.CurrentQty > 0
END