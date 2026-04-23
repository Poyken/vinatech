-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 설비관리
-- Description:	설비별스페어파트정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineSparePartInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '*' ELSE @pMachineCode END
    
	SELECT
	        MSPI.MachineCode AS OldMachineCode,
	        MSPI.MachineCode,
	        MM.MachineName,
	        MM.CompanyCode,
	        CI.CompanyName,
	        CI.CompanyNameL,
	        MM.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        
	        MSPI.SparePartCode AS OldSparePartCode,
	        MSPI.SparePartCode,
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
	        
	        MSPI.ChangePlanType,
	        MSPI.ChangePlan,
	        MSPI.LastChangeDate,
	        
	        Stock.CurrentStockQty,
	        
	        MSPI.CreateDateTime,
	        MSPI.CreateUserID,
	        MSPI.ChangeDateTime,
	        MSPI.ChangeUserID,
			ISNULL(AFM.FileContents, CONVERT(VARBINARY(MAX), NULL)) AS FileData,
			AFM.FileName,
			AFM.FileSize
	FROM
	        STB_MachineSparePartInfo MSPI WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MachineBasicInfo MBI WITH(NOLOCK)
				ON MSPI.MachineCode = MBI.MachineCode
			LEFT OUTER JOIN STB_MachineMaster MM WITH(NOLOCK)
				ON MSPI.MachineCode = MM.MachineCode
			LEFT OUTER JOIN STB_SparePartInfo SPI WITH(NOLOCK)
				ON MSPI.SparePartCode = SPI.SparePartCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MM.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON MM.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN VW_MachineType MT WITH(NOLOCk)
				ON MM.MachineTypeCode = MT.MachineTypeCode
			LEFT OUTER JOIN
			(
				SELECT
						SPSI.SparePartCode,
						ISNULL(SUM(SPSI.CurrentStockQty),0) AS CurrentStockQty
				FROM
						STB_SparePartStockInfo SPSI WITH(NOLOCK)
						LEFT OUTER JOIN STB_SparePartWarehouseInfo SPWI WITH(NOLOCK)
							ON SPSI.SPWarehouseCode = SPWI.SPWarehouseCode
				WHERE
						((@CompanyCode = '*') OR (SPWI.CompanyCode = @CompanyCode)) 
						AND ((@WorkCenterCode = '*') OR (SPWI.WorkCenterCode = @WorkCenterCode)) 
						AND (SPWI.IsUsed = 1)	
				GROUP BY
						SPSI.SparePartCode
			)Stock
				ON MSPI.SparePartCode = Stock.SparePartCode
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM
			  ON AFM.FileID = SPI.SparePartImage
			
	WHERE
			((@CompanyCode = '*') OR (MM.CompanyCode = @CompanyCode)) 
			AND ((@WorkCenterCode = '*') OR (MM.WorkCenterCode = @WorkCenterCode)) 			
	        AND ((@MachineCode = '*') OR (MSPI.MachineCode = @MachineCode)) 
			AND SPI.IsUsed = CONVERT(BIT, 1)
			

END


