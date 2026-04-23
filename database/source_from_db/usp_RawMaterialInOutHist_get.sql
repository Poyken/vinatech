-- ================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023.09.18
-- Browsable : true
-- Group : 자재관리
-- Description: 원자재창고불출이력
-- ==================================================================================
CREATE PROC usp_RawMaterialInOutHist_get
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pFromDate DATE
   ,@pToDate DATE
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(CHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'

	SELECT MWIOH.CompanyCode
		  ,CI.CompanyName
		  ,MWIOH.WorkCenterCode
		  ,WI.WorkCenterName
		  ,MWIOH.SourceMaterialWarehouseCode
		  ,MW.MaterialWarehouseName AS SourceMaterialWarehouseName
		  ,MWIOH.TargetMaterialWarehouseCode
		  ,MW2.MaterialWarehouseName AS TargetMaterialWarehouseName
		  ,MWIOH.CreateDateTime AS RequestDateTime
		  ,CASE WHEN MWIOH.WarehouseInOutCode = 'I' THEN '반품입고' ELSE '출고' END AS WarehouseInOut
		  ,MM.MaterialCode
		  ,MM.MaterialName
		  ,MM.MaterialSpec
		  ,MM.MaterialUnit
		  ,MS.CurrentQty AS CurrentQty
		  ,MDLI.CurrentQty AS ProcessQty
		  ,MS.CurrentQty - MDLI.CurrentQty AS StockQty
		  ,MS.VendorName
		  ,MWIOH.WorkerCode
		  ,EI.EmployeeName AS WorkerName
	  FROM STB_MaterialWarehouseInOutHist MWIOH
	  LEFT OUTER JOIN STB_CompanyInfo CI
		ON CI.CompanyCode = MWIOH.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WI
		ON WI.WorkCenterCode = MWIOH.WorkCenterCode
	  LEFT OUTER JOIN STB_MaterialWarehouse MW
		ON MW.MaterialWarehouseCode = MWIOH.SourceMaterialWarehouseCode
	  LEFT OUTER JOIN STB_MaterialWarehouse MW2
		ON MW2.MaterialWarehouseCode = MWIOH.TargetMaterialWarehouseCode
	  LEFT OUTER JOIN (
						SELECT LotID
								,MaterialCode
								,MAX(CurrentQty) AS CurrentQty
							FROM STB_MaterialLotInfo with(nolock)  
							GROUP BY LotID, MaterialCode
							UNION ALL
							SELECT LotNo
								,MaterialCode
								,MAX(CurrentQty) AS CurrentQty
							FROM STB_MaterialLotInfo with(nolock)  
							WHERE LotNo IS NOT NULL AND LotNo <> ''
							GROUP BY LotNo, MaterialCode
		) MDLI ON MWIOH.LotID = MDLI.LotID
		LEFT OUTER JOIN STB_MaterialMaster MM
		  ON MM.MaterialCode = MDLI.MaterialCode
		LEFT OUTER JOIN (
			SELECT MaterialCode
				,SUM(CurrentQty) AS CurrentQty
				,MAX(LotAttr03) AS VendorName
			FROM STB_MaterialLotInfo with(nolock)  
			GROUP BY LotID, MaterialCode
			UNION ALL
			SELECT MaterialCode
				,SUM(CurrentQty) AS CurrentQty
				,MAX(LotAttr03) AS VendorName
			FROM STB_MaterialLotInfo with(nolock)  
			WHERE LotNo IS NOT NULL AND LotNo <> ''
			GROUP BY MaterialCode
		) MS
		ON MS.MaterialCode = MM.MaterialCode
	  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI
		ON EI.EmployeeNo = MWIOH.WorkerCode
	 WHERE MWIOH.CreateDateTime BETWEEN @FromDate AND @ToDate
END