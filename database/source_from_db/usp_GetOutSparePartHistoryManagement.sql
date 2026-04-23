-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-20
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트 출고이력 관리(스페어파트교체이력정보포함)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetOutSparePartHistoryManagement]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pSPWarehouseCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @SPWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pSPWarehouseCode,'') = '' THEN '*' ELSE @pSPWarehouseCode END
	
	

	 
	SELECT
			SPIOH.SparePartIOHistoryNo AS OldSparePartIOHistoryNo,
	        SPIOH.SparePartIOHistoryNo,
	        
	        SPIOH.SparePartIOTypeCode,
	        SPIOTC.SparePartIOTypeName,
	        SPIOTC.IOType,
	        SPIOTC.SparePartIOTypeDesc,
	        
	        SPIOH.CompanyCode,
	        CI.CompanyName,
	        CI.CompanyNameL,
	        
	        SPIOH.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        
	        SPIOH.SPWarehouseCode,
	        SPWI.SPWarehouseName,
	        
	        SPCH.MachineCode,
	        MM.MachineName,
	        MM.IsProdMachine,
	        MM.MachineTypeCode,
	        MT.MachineTypeName,
			
			SPIOH.SparePartCode,
	        SPI.SparePartName,
	        SPI.SparePartSpec01,
	        SPI.SparePartSpec02,
	        SPI.SparePartSpec03,
	        SPI.SparePartSpec04,
	        SPI.SparePartSpec05,
	        SPI.SparePartImage,
	        SPI.BasicUnitPrice,
	        SPI.BasicDeliveryDay,
	        SPI.BasicUnit,
	        SPI.SafeQty,
	        SPI.LastDeliveryVendor,
	        SPI.CompatibilityGroup,
			
	        SPIOH.SPLocationCode,
	        SPLI.SPLocationGroup,
	        SPLI.SPLocationName,
	        
	        SPIOH.VendorCode,
	        
	        SPIOH.UnitPrice,
	        SPIOH.ProcessQty,
	        SPSI.CurrentStockQty,
	        SPIOH.HistoryText,
	        
	        
	        SPIOH.CreateDateTime,
	        SPIOH.CreateUserID,
	        SPIOH.ChangeDateTime,
	        SPIOH.ChangeUserID,
			SPIOH.LineCode,
			LI.LineName,
			SPIOH.CurlingGomaUniqueNo,
			SPIOH.GIDate,
			SPIOH.IssueExecWorkerCode,
			EI.EmployeeName AS IssueExecWorkerName
	FROM
			STB_SparePartIOHistory SPIOH WITH(NOLOCK)
	        LEFT OUTER JOIN STB_SparePartWarehouseInfo SPWI WITH(NOLOCK)
				ON SPIOH.SPWarehouseCode = SPWI.SPWarehouseCode
			LEFT OUTER JOIN STB_SparePartLocationInfo SPLI WITH(NOLOCK)
				ON SPIOH.SPLocationCode = SPLI.SPLocationCode
				AND SPIOH.SPWarehouseCode = SPLI.SPWarehouseCode
			LEFT OUTER JOIN STB_SparePartInfo SPI WITH(NOLOCK)
				ON SPIOH.SparePartCode = SPI.SparePartCode 
			LEFT OUTER JOIN STB_SparePartIOTypeCode SPIOTC WITH(NOLOCK)
				ON SPIOH.SparePartIOTypeCode = SPIOTC.SparePartIOTypeCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON SPIOH.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON SPIOH.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_SparePartStockInfo SPSI WITH(NOLOCK)
				ON SPIOH.SPWarehouseCode = SPSI.SPWarehouseCode
				AND SPIOH.SPLocationCode = SPSI.SPLocationCode
				AND SPIOH.SparePartCode = SPSI.SparePartCode
			LEFT OUTER JOIN STB_SparePartChangeHistory SPCH WITH(NOLOCK)
				ON SPIOH.SparePartIOHistoryNo = SPCH.SparePartIOHistoryNo
			LEFT OUTER JOIN STB_MachineMaster MM WITH(NOLOCK)
				ON SPCH.MachineCode = MM.MachineCode
			LEFT OUTER JOIN VW_MachineType MT WITH(NOLOCK)
				ON MM.MachineTypeCode = MT.MachineTypeCode
			LEFT OUTER JOIN STB_LineInfo LI
			    ON LI.LineCode = SPIOH.LineCode
			LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI
			  ON EI.EmployeeNo = SPIOH.IssueExecWorkerCode
	WHERE
			((@CompanyCode = '*') OR (SPIOH.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (SPIOH.WorkCenterCode = @WorkCenterCode)) AND
	        ((@SPWarehouseCode = '*') OR (SPIOH.SPWarehouseCode = @SPWarehouseCode)) AND
	        (SPIOTC.IOType = 'O')

END