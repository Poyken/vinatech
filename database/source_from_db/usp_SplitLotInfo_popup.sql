-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-07-11
-- Browsable : true
-- Group : 지지체
-- Description:	소분원자재 목록 조회
-- =============================================
CREATE PROCEDURE usp_SplitLotInfo_popup 
	@pProductGroupCode VARCHAR(50)
AS
BEGIN
	Declare @ProductGroupCode VARCHAR(50) = @pProductGroupCode

	IF @ProductGroupCode = 'AB' BEGIN
		SELECT MLI.LotID
			  ,MLI.MaterialCode
			  ,MM.MaterialName
			  ,MLI.CurrentQty
		  FROM STB_MaterialLotInfo MLI
		  INNER JOIN STB_SupportRawMaterialSplitHist SRMSH
			ON MLI.LotID = SRMSH.SplitLotID
		  LEFT OUTER JOIN STB_MaterialMaster MM
			ON MM.MaterialCode = MLI.MaterialCode
	END ELSE BEGIN
		SELECT MLI.LotNo AS LotID
			  ,MLI.MaterialCode
			  ,MM.MaterialName
			  ,MLI.CurrentQty
		  FROM STB_MaterialLotInfo MLI
		  LEFT OUTER JOIN STB_MaterialMaster MM
			ON MM.MaterialCode = MLI.MaterialCode
		 WHERE MM.MaterialName = @ProductGroupCode
	END
END