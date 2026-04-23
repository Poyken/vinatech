

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-03
-- Browsable : true
-- Group : 자재관리
-- Description:	자재별 업체지정 정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetCustomerMappingByMaterial]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '' ELSE @pMaterialCode END;
	
	--SET @MaterialCode = REPLACE(@MaterialCode,'''''','''');
	
	
	WITH CTE(MaterialCode, MaterialName, MaterialNameL, CustomerCode, CustomerName, CustomerNameL)
	AS(
		SELECT
				MM.MaterialCode,
				MM.MaterialName,
				MM.MaterialNameL,
				CI.CustomerCode,
				CI.CustomerName,
				CI.CustomerNameL
		FROM
				STB_MaterialMaster MM WITH(NOLOCK)
				CROSS JOIN STB_CustomerInfo CI WITH(NOLOCK)
		WHERE
				((@MaterialCode = '*') OR (MM.MaterialCode = @MaterialCode))
				AND ((MM.IsPurchase = 1))
				AND ((CI.IsVendor = 1))
	)
			
    
    SELECT
			MVM.CustomerCode AS OldCustomerCode,
			MVM.MaterialCode AS OldMaterialCode,
			C.MaterialCode,
			C.MaterialName,
			C.MaterialNameL,
			C.CustomerCode,
			C.CustomerName,
			C.CustomerNameL,
			
			MVM.InspectionType,
			MVM.InspectionLevel,
			ISNULL(MVM.AQL,0) AS AQL,
			ISNULL(MVM.UnitPriceQty,0) AS UnitPriceQty,
			ISNULL(MVM.UnitPrice,0) AS UnitPrice,
			ISNULL(MVM.BasicDeliveryDay,0) AS BasicDeliveryDay,
			ISNULL(MVM.IsUsed,0) AS IsUsed,
			MVM.CreateDateTime,
			MVM.CreateUserID,
			MVM.ChangeDateTime,
			MVM.ChangeUserID
	FROM
			CTE C
			LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)
				ON C.CustomerCode = MVM.CustomerCode
				AND C.MaterialCode = MVM.MaterialCode

	
	

END



