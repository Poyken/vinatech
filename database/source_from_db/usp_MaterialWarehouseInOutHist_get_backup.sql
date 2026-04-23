-- ================================================================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020.02.13
-- Browsable : true
-- Group : 자재관리
-- Description: 원자재창고불출이력
-- Modified:
--              2020.04.20 자재그룹코드, 명 추가 (주영진 부장 요청)
--              2020.04.21 단가,금액 등 추가      (주영진 부장 요청)
--              2020.04.22 From ~To 일자에 8시반 표기 (주영진 부장 요청)
--              2020.04.22 조회조건 바코드 추가
--              2020.04.27 단가 (ERP->자재정보)
--              2020.06.15 불출자들에게도 리스트 조회되도록 수정  (구보겸 요청)  * 해당날짜 백업본
--              2020.06.16 불출이력 5분전것만 나오게 수정 (구보겸)

--  usp_MaterialWarehouseInOutHist_get 'yjjoo','Korean','VNT','VNT_F1','2020-04-24 00:00:00','2020-04-25 00:00:00'
-- ==================================================================================

CREATE PROCEDURE [dbo].[usp_MaterialWarehouseInOutHist_get_Backup]
						@pProcessUserID     Varchar(20),
						@pProcessLanguage Varchar(20),
						@pCompanyCode    Varchar(20) = NULL,
						@pWorkCenterCode Varchar(20) = NULL,
						@pFromDate          DateTime,
						@pToDate             DateTime
AS
BEGIN
	
   DECLARE @FromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2020-04-22', 121) + ' 08:30:00' 
	         , @ToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:30:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2020-04-22 00:01:09')), 121) + ' 08:30:00'    
		     , @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
		     , @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
			 , @ProcessUserID     VARCHAR(20) = CASE WHEN ISNULL(@pProcessUserID, '') = '' THEN '*' ELSE @pProcessUserID END
	

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
						  ,ProcessedLotID
						  ,CASE WHEN ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END AS ProcessedResult
						  ,MWIOH.CreateDateTime   AS RequestDateTime				 
						 , MM.MaterialTypeCode    AS MaterialTypeCode                      -- 자재코드 2020.04.20 추가
						 , SPG.ProductGroupName  AS ProductGroupName                   -- 자재그룹명, 2020.04.20 추가		
						 , MM.MaterialUnit 		      AS MaterialUnit                            -- 수량단위, 2020.04.20 추가					  
 						 , MDLI.StockQty               AS OutQty                                 -- 불출수량							   						 						 
						 , MM.BasicCostPrice                      AS UnitPrice                   -- 공통정보>자재정보 표준원가로 변경 (2020.04.27)
						 , MDLI.StockQty * MM.BasicCostPrice AS ConvertPrice              -- 환산금액 (원 단위금액 * 불출수량)
						 , Case When Convert(char(8), MWIOH.CreateDateTime, 108)  < '08:30:00' then Convert(Varchar(10), DateAdd(Day, -1, Convert(Varchar(10), MWIOH.CreateDateTime)), 121)                          -- 8시반보다 작으면 전일
                                   Else                                                                                Convert(Varchar(10),                                               MWIOH.CreateDateTime,   121)  End  AS OutDate   -- 그렇지 않으면 당일    (주영진 부장 요청)
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
							  LEFT OUTER JOIN STB_ProductGroup  SPG WITH(NOLOCK) ON  SPG.ProductGroupCode = MM.ProductGroupCode                                                                         -- 2020.04.20 추가				   						
					 WHERE 1=1	   
					   AND (@CompanyCode = '*' OR MWIOH.CompanyCode = @CompanyCode)
					   AND (@WorkCenterCode = '*' OR MWIOH.WorkCenterCode = @WorkCenterCode)
					   AND MWIOH.LotID NOT IN ( 
															   SELECT LotID 
																FROM STB_MaterialDocLotInfo 
															   WHERE MaterialLocationCode LIKE 'ROUTE_%'
														    )
					   AND MWIOH.CreateDateTime BETWEEN @FromDate AND @ToDate		
					 ORDER BY MWIOH.CreateDateTime
			   End

	
END