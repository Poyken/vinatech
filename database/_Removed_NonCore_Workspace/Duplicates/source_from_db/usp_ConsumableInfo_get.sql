-- =============================================
-- Author: Jackarue(yjyu@vina.co.kr)
-- Create date: 2023-09-16
-- Browsable : true
-- Group : 기타
-- Description : 소모품 현황 조회
-- =============================================
CREATE PROC usp_ConsumableInfo_get
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pMaterialCode VARCHAR(20) = NULL
   ,@pMaterialName NVARCHAR(20) = NULL
AS
BEGIN
	Declare @MaterialCode NVARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode	END
	       ,@MaterialName NVARCHAR(20) = CASE WHEN ISNULL(@pMaterialName, '') = '' THEN '*' ELSE @pMaterialName END

	SELECT CI.ConsumableNo
          ,CI.Cateogry1
          ,CI.Category2
          ,CI.Category3
          ,CI.MaterialCode
          ,CI.MaterialName
          ,CI.Qty
          ,CI.Unit
		  ,CI.UnitPrice
		  ,CI.ComputedPrice
          ,CI.ProdDate
          ,CI.VendorLotRemark
          ,CI.CreateDateTime
	  FROM STB_ConsumableInfo CI
	 WHERE (@MaterialCode = '*' OR CI.MaterialCode LIKE '%' + @MaterialCode + '%')
	   AND (@MaterialName = '*' OR CI.MaterialName LIKE '%' + @MaterialName + '%')
END