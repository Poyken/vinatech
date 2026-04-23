
 CREATE PROCEDURE usp_VN_MaterialRawVCM --exec usp_VN_MaterialRawVCM '',''

						@pFromDate          DateTime = NULL,
						@pToDate             DateTime = NULL
					
AS

BEGIN

   DECLARE	   @FromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2020-04-22', 121) + ' 08:30:00' 
	         , @ToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:30:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2020-04-22 00:01:09')), 121) + ' 08:30:00'    
		    
			
			 , @CompanyCode    VARCHAR(20) = 'VVT'
		     , @WorkCenterCode VARCHAR(20) = 'VVT_F1'

	IF @FromDate = '1900-01-01 08:30:00' OR @ToDate = '1900-01-01 08:30:00' 
	
	BEGIN
		SET @FromDate = dbo.fnGetAggregationPeriod(1)
		SET @ToDate = dbo.fnGetAggregationPeriod(2)
	END

 ------------------ 불출자들도 조회되도록 수정 (2020.06-16 반영)

				Begin

				 SELECT MaterialWarehouseInOutHistNo
						  ,WarehouseInOutCode
						  ,BC.Description                               AS WarehouseInOutName
						  ,SourceMaterialWarehouseCode
						  ,MW1.MaterialWarehouseName           AS SourceMaterialWarehouseName
						  ,TargetMaterialWarehouseCode
						  ,MW2.MaterialWarehouseName           AS TargetMaterialWarehouseName
						  ,MWIOH.LotID
						  , MM.MaterialCode						 
						  ,MM.MaterialName
						  ,MWIOH.WorkerCode
						  ,PWI.WorkerName
						  ,MWIOH.LineCode
						   ,LI.LineName
						 --, LI.LineDesc As LineName
						  ,ProcessedLotID
						  ,CASE WHEN ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END AS ProcessedResult
						  ,MWIOH.CreateDateTime  AS RequestDateTime				 
						 , MM.MaterialTypeCode    AS MaterialTypeCode                      -- 자재코드 2020.04.20 추가
						 , SPG.ProductGroupName  AS ProductGroupName                   -- 자재그룹명, 2020.04.20 추가		
						 , MM.MaterialUnit 		    AS MaterialUnit                            -- 수량단위, 2020.04.20 추가					  
 						 , MDLI.StockQty              AS OutQty                                 -- 불출수량							   					
						 , MM.BasicCostPrice                      AS UnitPrice                   -- 공통정보>자재정보 표준원가로 변경 (2020.04.27)
						 , MDLI.StockQty * MM.BasicCostPrice AS ConvertPrice              -- 환산금액 (원 단위금액 * 불출수량)					  
						 , Case When Convert(char(8), MWIOH.CreateDateTime, 108)  < '08:30:00' then Convert(Varchar(10), DateAdd(Day, -1, Convert(Varchar(10), MWIOH.CreateDateTime)), 121)                
                                   Else                                                                                Convert(Varchar(10),                                               MWIOH.CreateDateTime,   121)  End  AS OutDate   
						, MM.BasicCostPrice AS BasicCostPrice                                  -- 표준원가
					  FROM                       STB_MaterialWarehouseInOutHist MWIOH
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
					   And (@CompanyCode = '*' OR MWIOH.CompanyCode = @CompanyCode)
					   And (@WorkCenterCode = '*' OR MWIOH.WorkCenterCode = @WorkCenterCode)
					   And MWIOH.LotID NOT IN ( 
															   SELECT LotID 
																FROM STB_MaterialDocLotInfo 
															   WHERE MaterialLocationCode LIKE 'ROUTE_%'
														    )
					   And MWIOH.CreateDateTime BETWEEN @FromDate AND @ToDate		
					 ORDER BY MWIOH.CreateDateTime
			   End

END
