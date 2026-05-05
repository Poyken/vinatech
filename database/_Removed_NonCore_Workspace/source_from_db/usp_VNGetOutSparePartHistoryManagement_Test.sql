-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-20
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트 출고이력 관리(스페어파트교체이력정보포함)
-- Modified: usp_VNGetOutSparePartHistoryManagement_Test '','','VVT','VVT_F1','Kho1','2024-01-01','2024-06-01',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_VNGetOutSparePartHistoryManagement_Test]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pSPWarehouseCode VARCHAR(20) = NULL,
	@pFromDate Date,
	@pToDate Date,
	@pSparePartSpec02 nvarchar(200) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @SPWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pSPWarehouseCode,'') = '' THEN '*' ELSE @pSPWarehouseCode END
	DECLARE @SparePartSpec02 NVARCHAR(200) = CASE WHEN ISNULL(@pSparePartSpec02,'') = '' THEN '*' ELSE @pSparePartSpec02 END
	

	;with table1 as
	(
		--select SparePartCode,sum(CurrentStockQtyKho1) as CurrentStockQtyKho1, sum(CurrentStockQtyKho2) as CurrentStockQtyKho2, sum(CurrentStockQty) as CurrentStockQty
		--from 
		--(select SparePartCode,case when SPWarehouseCode='Kho1' then sum(CurrentStockQty) else 0 end as CurrentStockQtyKho1,
		--	  case when SPWarehouseCode='Kho2' then sum(CurrentStockQty) else 0 end as CurrentStockQtyKho2,
		--	  sum(CurrentStockQty) as CurrentStockQty
		-- from STB_VNSparePartStockInfo 
		-- group by SparePartCode,SPWarehouseCode) aa
		-- group by SparePartCode
		--------------------------------------------------------- Ha them 07/05/24
		select SparePartCode,sum(CurrentStockQtyKho1) as CurrentStockQtyKho1, sum(CurrentStockQtyKho2) as CurrentStockQtyKho2, sum(CurrentStockQty) as CurrentStockQty
		from 
		(select SparePartCode,case when SPWarehouseCode='Kho1' then sum(CurrentStockQty) else 0 end as CurrentStockQtyKho1,
			  case when SPWarehouseCode='Kho2' then sum(CurrentStockQty) else 0 end as CurrentStockQtyKho2,
			  sum(CurrentStockQty) as CurrentStockQty
		 from STB_VNSparePartStockInfo_TEST where WorkCenterCode =@pWorkCenterCode
		 group by SparePartCode,SPWarehouseCode) aa
		 group by SparePartCode
		 ---------------------------------------------------------------

	)

	 
	SELECT
			SPIOH.SparePartIOHistoryNo AS OldSparePartIOHistoryNo,
	        SPIOH.SparePartIOHistoryNo,
	        
	        SPIOH.SparePartIOTypeCode,
	        --SPIOTC.SparePartIOTypeName,
	        --SPIOTC.IOType,
	        --SPIOTC.SparePartIOTypeDesc,
	        
	        SPIOH.CompanyCode,
			
	  --      CI.CompanyName,
	  --      CI.CompanyNameL,
	        
	        SPIOH.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        
	        SPIOH.SPWarehouseCode
				--SPWI.SPWarehouseName
	        
	  --      SPCH.MachineCode,
	  --      MM.MachineName,
	  --      MM.IsProdMachine,
	  --      MM.MachineTypeCode,
	  --      MT.MachineTypeName,
			
			--SPIOH.SparePartCode,
	  --      SPI.SparePartName,
	  --      SPI.SparePartSpec01,
	  --      SPI.SparePartSpec02,
	  --      SPI.SparePartSpec03,
	  --      SPI.SparePartSpec04,
	  --      SPI.SparePartSpec05,
			--TSP.TYPECODE,
			--TSP.TYPENAME,
	  --      SPI.SparePartImage,
	  --      SPI.BasicUnitPrice,
	  --      SPI.BasicDeliveryDay,
	  --      SPI.BasicUnit,
	  --      SPI.SafeQty,
	  --      SPI.LastDeliveryVendor,
	  --      SPI.CompatibilityGroup,
			--SPI.Position,
	  --      SPIOH.SPLocationCode,
	  --      SPLI.SPLocationGroup,
	  --      SPLI.SPLocationName,
	        
	  --      SPIOH.VendorCode,
	        
	  --      SPIOH.UnitPrice,
	  --      SPIOH.ProcessQty,
	  --      --SPSI.CurrentStockQty,
			--t1.CurrentStockQtyKho1,
			--t1.CurrentStockQtyKho2,
			--t1.CurrentStockQty,
	  --      SPIOH.HistoryText,
	        
	        
	  --      SPIOH.CreateDateTime,
	  --      SPIOH.CreateUserID,
	  --      SPIOH.ChangeDateTime,
	  --      SPIOH.ChangeUserID,
			--SPIOH.LineCode,
			--LI.LineName,
			--SPIOH.CurlingGomaUniqueNo,
			--SPIOH.CodeEmp,
			--ED.Name,
			--ED.PartName,
		 --   convert(varchar, SPIOH.BasicDate, 111) as BasicDate
	FROM
			STB_VNSparePartIOHistory SPIOH WITH(NOLOCK)
	        LEFT OUTER JOIN STB_SparePartWarehouseInfo SPWI WITH(NOLOCK)
				ON SPIOH.SPWarehouseCode = SPWI.SPWarehouseCode and SPIOH.WorkCenterCode =SPWI.WorkCenterCode
			--LEFT OUTER JOIN STB_SparePartLocationInfo SPLI WITH(NOLOCK)
			--	ON SPIOH.SPLocationCode = SPLI.SPLocationCode
			--	AND SPIOH.SPWarehouseCode = SPLI.SPWarehouseCode
			--LEFT OUTER JOIN STB_VNSparePartInfo SPI WITH(NOLOCK)
			--	ON SPIOH.SparePartCode = SPI.SparePartCode 
			--LEFT OUTER JOIN STB_SparePartIOTypeCode SPIOTC WITH(NOLOCK)
			--	ON SPIOH.SparePartIOTypeCode = SPIOTC.SparePartIOTypeCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON SPIOH.WorkCenterCode = WCI.WorkCenterCode
			--LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
			--	ON SPIOH.CompanyCode = CI.CompanyCode
			----LEFT OUTER JOIN STB_VNSparePartStockInfo SPSI WITH(NOLOCK)
			----	ON SPIOH.SPWarehouseCode = SPSI.SPWarehouseCode
			----	AND SPIOH.SPLocationCode = SPSI.SPLocationCode
			----	AND SPIOH.SparePartCode = SPSI.SparePartCode
			--LEFT OUTER JOIN STB_VNSparePartChangeHistory SPCH WITH(NOLOCK)
			--	ON SPIOH.SparePartIOHistoryNo = SPCH.SparePartIOHistoryNo
			--LEFT OUTER JOIN STB_MachineMaster MM WITH(NOLOCK)
			--	ON SPCH.MachineCode = MM.MachineCode
			--LEFT OUTER JOIN VW_MachineType MT WITH(NOLOCK)
			--	ON MM.MachineTypeCode = MT.MachineTypeCode
			--LEFT OUTER JOIN STB_LineInfo LI
			--    ON LI.LineCode = SPIOH.LineCode
			--LEFT JOIN Stb_EmployeeDepartment ED
			--  ON SPIOH.CODEEMP = ED.CODEEMP
			--LEFT JOIN STB_TYPESPAREPART TSP
			--	ON SPI.TypeCode = TSP.TYPECODE
			--left join table1 t1 on  SPIOH.SparePartCode = t1.SparePartCode
	--WHERE
			--((@CompanyCode = '*') OR (SPIOH.CompanyCode = @CompanyCode)) AND
	  --      ((@WorkCenterCode = '*') OR (SPIOH.WorkCenterCode = @WorkCenterCode)) AND
	  --      ((@SPWarehouseCode = '*') OR (SPIOH.SPWarehouseCode = @SPWarehouseCode)) AND
			--((@SparePartSpec02 = '*') OR (SPI.SparePartSpec02 like '%'+@SparePartSpec02+'%')) AND
	  --      (SPIOTC.IOType = 'O')  AND SPIOH.Attribute1 IS NULL AND 
			--SPIOH.BasicDate between @pFromDate and @pToDate
END


