

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-03
-- Browsable : true
-- Group : 자재관리
-- Description:	업체별 자재지정 정보 조회
-- Modified:
-- =============================================
-- exec usp_GetMaterialMappingByCustomer '','',''


CREATE PROCEDURE [dbo].[usp_GetMaterialMappingByCustomer]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCustomerCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '' ELSE @pCustomerCode END;
	
	
	
	
	WITH CTE  (CustomerCode, CustomerName, CustomerNameL, MaterialCode, MaterialName, MaterialNameL)
	AS(
		SELECT
				CI.CustomerCode,
				CI.CustomerName,
				CI.CustomerNameL,
				MM.MaterialCode,
				MM.MaterialName,
				MM.MaterialNameL
		FROM
				STB_CustomerInfo CI WITH(NOLOCK)
				CROSS JOIN STB_MaterialMaster MM WITH(NOLOCK)
		WHERE 1=1
		-- AND MM.MaterialCode = 'SREYPB6'
			and 	((@CustomerCode = '*') OR (CI.CustomerCode = @CustomerCode))
				AND ((MM.IsPurchase = 1))
				AND ((CI.IsVendor = 1))
	)
			
    
    SELECT
			MVM.CustomerCode AS OldCustomerCode,
			MVM.MaterialCode AS OldMaterialCode,
			C.CustomerCode,
			C.CustomerName,
			C.CustomerNameL,
			C.MaterialCode,
			C.MaterialName,
			C.MaterialNameL,
			
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



