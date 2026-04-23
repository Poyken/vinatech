-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-22
-- Browsable : true
-- Group : 설비관리
-- Description:	설비수리자재정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineRepairMaterialHist_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMachineRepairHistoryNo VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MachineRepairHistoryNo VARCHAR(20) = CASE WHEN ISNULL(@pMachineRepairHistoryNo,'') = '' THEN '' ELSE @pMachineRepairHistoryNo END

    
	SELECT
			MRMH.MachineRepairHistoryNo AS OldMachineRepairHistoryNo,
			MRMH.MachineRepairHistoryNo,
			
			MRMH.MachineRepairMaterialSeq AS OldMachineRepairMaterialSeq,
			MRMH.MachineRepairMaterialSeq,
			
			MRH.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			
			MRH.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			
			MRH.MachineCode,
		    
			MRMH.SparePartChangeHistoryNo,
			
			SPCH.SparePartCode,
			SPI.SparePartName,
			MSPI.ChangePlanType,
			MSPI.ChangePlan,
			MSPI.LastChangeDate,
			
			SPI.SparePartSpec01,
			SPI.SparePartSpec02,
			SPI.SparePartSpec03,
			SPI.SparePartSpec04,
			SPI.SparePartSpec05,
			SPI.SparePartImage,
			SPI.BasicDeliveryDay,
			SPI.BasicUnit,
			SPI.SafeQty,
			SPI.LastDeliveryVendor,
			SPI.CompatibilityGroup,
			SPCH.ChangeQty,
			SPCH.BasicUnitPrice,
			SPCH.SpareChangeDate,
			SPCH.SpareChangeDateTime,
			SPCH.IsMachineRepair,
			
			SPCH.SparePartIOHistoryNo,
			SPIOH.SPWarehouseCode,
			SPWI.SPWarehouseName,
			
			SPIOH.SPLocationCode,
			SPLI.SPLocationGroup,
			SPLI.SPLocationName,
			
			SPSI.CurrentStockQty,
			
			SPIOH.SparePartIOTypeCode,
			SPIOTC.IOType,
			SPIOTC.SparePartIOTypeName,
			
			SPIOH.VendorCode,
			SPIOH.UnitPrice,
			SPIOH.ProcessQty,
			SPIOH.HistoryText
			
		
	FROM
			STB_MachineRepairMaterialHist MRMH WITH(NOLOCK)
			LEFT OUTER JOIN STB_MachineRepairHistory MRH WITH(NOLOCK)
				ON MRMH.MachineRepairHistoryNo = MRH.MachineRepairHistoryNo 
			LEFT OUTER JOIN STB_SparePartChangeHistory SPCH WITH(NOLOCK)
				ON MRMH.SparePartChangeHistoryNo = SPCH.SparePartChangeHistoryNo
			LEFT OUTER JOIN STB_SparePartIOHistory SPIOH WITH(NOLOCK)
				ON SPCH.SparePartIOHistoryNo = SPIOH.SparePartIOHistoryNo
			LEFT OUTER JOIN STB_MachineSparePartInfo MSPI WITH(NOLOCK)
				ON MRH.MachineCode = MSPI.MachineCode
				AND SPCH.SparePartCode = MSPI.MachineCode
			LEFT OUTER JOIN STB_SparePartStockInfo SPSI WITH(NOLOCK)
				ON SPIOH.SPWarehouseCode = SPSI.SPWarehouseCode
				AND SPIOH.SPLocationCode = SPSI.SPLocationCode
				AND SPCH.SparePartCode = SPSI.SparePartCode
			LEFT OUTER JOIN STB_SparePartLocationInfo SPLI WITH(NOLOCK)
				ON SPIOH.SPLocationCode = SPLI.SPLocationCode
				AND SPIOH.SPWarehouseCode = SPLI.SPWarehouseCode
			LEFT OUTER JOIN STB_SparePartInfo SPI WITH(NOLOCK)
				ON SPCH.SparePartCode = SPI.SparePartCode
			LEFT OUTER JOIN STB_SparePartWarehouseInfo SPWI WITH(NOLOCK)
				ON SPIOH.SPWarehouseCode = SPWI.SPWarehouseCode
			LEFT OUTER JOIN STB_SparePartIOTypeCode SPIOTC WITH(NOLOCK)
				ON SPIOH.SparePartIOTypeCode = SPIOTC.SparePartIOTypeCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MRH.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON MRH.CompanyCode = CI.CompanyCode
	WHERE
			((@MachineRepairHistoryNo = '*') OR (MRMH.MachineRepairHistoryNo = @MachineRepairHistoryNo)) 

END


