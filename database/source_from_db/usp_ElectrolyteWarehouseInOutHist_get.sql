-- ================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021.03.05
-- Browsable : true
-- Group : 자재관리
-- Description: 전해액 창고불출이력
-- ==================================================================================
CREATE PROCEDURE usp_ElectrolyteWarehouseInOutHist_get
	@pProcessUserID   VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE,
	@pToDate DATE
AS
BEGIN

   DECLARE @FromDate DATETIME  = CONVERT(CHAR(10), @pFromDate, 121) + ' 08:30:00'
          ,@ToDate DATETIME =  CONVERT(CHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'

		SELECT MaterialWarehouseInOutHistNo
			  ,WarehouseInOutCode
			  ,BC.Description AS WarehouseInOutName
			  ,SourceMaterialWarehouseCode
			  ,MW1.MaterialWarehouseName AS SourceMaterialWarehouseName
			  ,TargetMaterialWarehouseCode
			  ,MW2.MaterialWarehouseName AS TargetMaterialWarehouseName
			  ,MWIOH.LotID
			  ,MM.MaterialCode						 
			  ,MM.MaterialName
			  ,MWIOH.LineCode
			  ,LI.LineName
			FROM    STB_MaterialWarehouseInOutHist MWIOH
					LEFT OUTER JOIN STB_MaterialWarehouse MW1		         ON SourceMaterialWarehouseCode = MW1.MaterialWarehouseCode
					LEFT OUTER JOIN STB_MaterialWarehouse MW2		         ON TargetMaterialWarehouseCode = MW2.MaterialWarehouseCode
					LEFT OUTER JOIN STB_ProdWorkerInfo PWI		                 ON MWIOH.WorkerCode = PWI.WorkerCode
					LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	 ON BC.ItemCode = WarehouseInOutCode	   AND BC.CodeGroup = 'WarehouseInOutCode'								  	  
					LEFT OUTER JOIN ( 
											SELECT LotID
													,MaterialCode
													,StockQty
												FROM STB_MaterialDocLotInfo
												GROUP BY LotID, MaterialCode, StockQty
												UNION ALL

												SELECT LotNo
													,MAX(MaterialCode) AS MaterialCode
													,MAX(StockQty) AS StockQty
												FROM STB_MaterialDocLotInfo
												WHERE LotNo IS NOT NULL 
												AND LotNo <> ''
												GROUP BY LotNo
											) MDLI ON MWIOH.LotID = MDLI.LotID
					LEFT OUTER JOIN STB_MaterialMaster MM ON MM.MaterialCode = MDLI.MaterialCode                                                                                      					  
					LEFT OUTER JOIN STB_LineInfo LI ON LI.LineCode = MWIOH.LineCode
					LEFT OUTER JOIN STB_ProductGroup  SPG WITH(NOLOCK) ON  SPG.ProductGroupCode = MM.ProductGroupCode
			WHERE 1=1	   
			AND MWIOH.LotID NOT IN ( 
									SELECT LotID 
									FROM STB_MaterialDocLotInfo 
									WHERE MaterialLocationCode LIKE 'ROUTE_%'
									)
			AND MWIOH.CreateDateTime BETWEEN @FromDate AND @ToDate
			AND SPG.ProductGroupCode = 'ELECTROLYTE'
			ORDER BY MWIOH.CreateDateTime

END