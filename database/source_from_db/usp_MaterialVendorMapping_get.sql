

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-03
-- Browsable : true
-- Group : 자재관리
-- Description:	업체별자재공급정보 조회(Import용)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialVendorMapping_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL,
    @pCustomerCode VARCHAR(20) = NULL,
	@pMaterialTypeCode VARCHAR(20) = NULL,
	@pProductGroupCode VARCHAR(20) = NULL,
	@pIsAllMaterial BIT = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END
      DECLARE @CustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '*' ELSE @pCustomerCode END
	  DECLARE @MaterialTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '*' ELSE @pMaterialTypeCode END
	  DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '*' ELSE @pProductGroupCode END
	  DECLARE @IsAllMaterial VARCHAR(20) = ISNULL(@pIsAllMaterial,CONVERT(BIT, 0))

    
	SELECT
	        MM.MaterialCode AS OldMaterialCode,
	        MVM.CustomerCode AS OldCustomerCode,
	        
	        MM.MaterialCode,
	        MM.MaterialName,
			MM.MaterialNameL,
			MM.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MT.MaterialTypeNameL,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			PG.ProductGroupNameL,
			PG.ProductGroupDesc,
			PG.ProductGroupDescL,
			MM.MaterialUnit,
			MM.BasicGrQty,
			MM.MaterialSpec,
			MM.MaterialSpecL,
			MM.MaterialSource,
			MM.AvgGrDay,
			MM.IsPurchase,
			MM.IsOrder,
			MM.IsClosed,
			MM.BeforeMaterialCode,
			MM.MMExtText01,
			MM.MMExtText02,
			MM.MMExtText03,
			MM.MMExtText04,
			MM.MMExtText05,
			MM.MMExtText06,
			MM.MMExtText07,
			MM.MMExtText08,
			MM.MMExtText09,
			MM.MMExtText10,
			MM.MMExtInt01,
			MM.MMExtInt02,
			MM.MMExtInt03,
			MM.MMExtInt04,
			MM.MMExtInt05,
			MM.MMExtReal01,
			MM.MMExtReal02,
			MM.MMExtReal03,
			MM.MMExtReal04,
			MM.MMExtReal05,
			MM.MMExtLongText01,
			MM.MMExtLongText02,
			MM.MMExtLongText03,
			MM.MMExtLongText04,
			MM.MMExtLongText05,
			MM.MMExtImage01,
			MM.MMExtImage02,
			MM.MMExtImage03,
			MM.MMExtImage04,
			MM.MMExtImage05,
			
	        MVM.CustomerCode,
	        CI.CustomerName,
	        CI.CustomerNameL,
	        CI.IsCustomer,
			CI.IsVendor,
			CI.IsSourcing,
			CI.BusinessCondition,
			CI.BusinessType,
			CI.BusinessNo,
			CI.ZipCode,
			CI.AddressText,
			CI.CeoName,
			CI.TelNo,
			CI.FaxNo,
			CI.ContactName1,
			CI.ContactTel1,
			CI.ContactName2,
			CI.ContactTel2,
			CI.ContactName3,
			CI.ContactTel3,
			CI.OrderToName,
			CI.OrderToTel,
			CI.OrderToEmail,
			CI.CustomerDesc,
			CI.CIExtText01,
			CI.CIExtText02,
			CI.CIExtText03,
			
			MVM.InspectionType,
			MVM.InspectionLevel,
			MVM.AQL,
	        MVM.UnitPriceQty,
	        MVM.UnitPrice,
	        MVM.BasicDeliveryDay,
			MVM.MVMExtText01,
			MVM.MVMExtText02,
			MVM.MVMExtText03,
			MVM.MVMExtText04,
			MVM.MVMExtText05,
	        MVM.IsUsed,
	        MVM.CreateDateTime,
	        MVM.CreateUserID,
	        MVM.ChangeDateTime,
	        MVM.ChangeUserID
	FROM
			STB_MaterialMaster MM WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)
			LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)
				ON MVM.CustomerCode = CI.CustomerCode
				ON MVM.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON MM.ProductGroupCode = PG.ProductGroupCode
	WHERE
	        ((@MaterialCode = '*') OR (MVM.MaterialCode = @MaterialCode)) AND
	        ((@CustomerCode = '*') OR (MVM.CustomerCode = @CustomerCode)) AND
			((@MaterialTypeCode = '*') OR (MM.MaterialTypeCode = @MaterialTypeCode)) AND
			((@ProductGroupCode = '*') OR (MM.ProductGroupCode = @ProductGroupCode)) AND
			((@IsAllMaterial = 1) OR (MVM.MaterialCode IS NOT NULL))
		

END


