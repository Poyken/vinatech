-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2019-11-12
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE usp_PurchaseBOM_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProductClassCode VARCHAR(10) = NULL
AS
BEGIN
	Declare @ProductClassCode VARCHAR(10) = CASE WHEN ISNULL(@pProductClassCode, '') = '' THEN 'VEC' ELSE @pProductClassCode END
		   
	SELECT BOMIndex
          ,ProductClassCode
          ,Volt
          ,Farad
          ,SizeW
          ,SizeH
          ,SizeCode
          ,MaterialGroupName
          ,MaterialName
          ,UsedQty
          ,UnitCode
          ,PurchaseUnitCost
          ,UnitCost
          ,Remark
	  FROM STB_PurchaseBOM
	 WHERE ProductClassCode = @ProductClassCode
END