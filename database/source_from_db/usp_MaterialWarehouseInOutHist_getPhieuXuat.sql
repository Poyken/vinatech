
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
--              2021.01.08  LotID, LotNo추가
--              2021.03.29 김은초롱 표준단가 요청

--  usp_MaterialWarehouseInOutHist_get 'yjjoo','Korean','VNT','VNT_F1','2021-01-08 00:00:00','2021-01-08 00:00:00', '1004214772012210130',''
-- ==================================================================================
 CREATE PROCEDURE [dbo].[usp_MaterialWarehouseInOutHist_getPhieuXuat]
						@pProcessUserID     Varchar(20) = NULL,
						@pFromDate          DateTime = NULL,
						@pToDate             DateTime = NULL
						
AS

BEGIN

	--Declare @FromDate          DATETIME     = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'           -- 원본백업
	--        , @ToDate             DATETIME     = CONVERT(VARCHAR(10), @pToDate, 121)    + ' 23:59:59'

   DECLARE	   @FromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2020-04-22', 121) + ' 08:30:00' 
	             , @ToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:30:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2020-04-22 00:01:09')), 121) + ' 08:30:00'    
		    
	IF @FromDate = '1900-01-01 08:30:00' OR @ToDate = '1900-01-01 08:30:00' 
	
	BEGIN
		SET @FromDate = dbo.fnGetAggregationPeriod(1)
		SET @ToDate = dbo.fnGetAggregationPeriod(2)
	END


	------------------ 불출자들도 조회되도록 수정 (2020.06.16 반영)

				Begin

				 SELECT 
							--MaterialWarehouseInOutHistNo
						  --WarehouseInOutCode
						  --,BC.Description                               AS WarehouseInOutName
						  --,SourceMaterialWarehouseCode
						  --,MW1.MaterialWarehouseName           AS SourceMaterialWarehouseName
						  --,TargetMaterialWarehouseCode
						  --,MW2.MaterialWarehouseName           AS TargetMaterialWarehouseName
						  --,MLI.LotNo  as LotID3
						  --,mli.LotID
						   MM.MaterialCode						 
						  ,MM.MaterialName
						  --,MWIOH.WorkerCode
						  --,PWI.WorkerName
						  --,MWIOH.LineCode
						  --,LI.LineName
						  --,ProcessedLotID as ProcessedLotID3

						  --,CASE WHEN ProcessedLotID IS NULL or ProcessedLotID='' THEN N'미출고/Lỗi' ELSE N'정상출고/Bình thường' END AS ProcessedResult
						  --,MWIOH.CreateDateTime   AS RequestDateTime				 

						 --, MM.MaterialTypeCode    AS MaterialTypeCode                   
						 --, SPG.ProductGroupName  AS ProductGroupName                
						 , MM.MaterialUnit 		      AS MaterialUnit                       		  
 						 , MDLI.StockQty               AS OutQty                               				   
					
						 --, MM.BasicCostPrice                      AS UnitPrice                  
						 --, MDLI.StockQty * MM.BasicCostPrice AS ConvertPrice             
						 --, Case When Convert(char(8), MWIOH.CreateDateTime, 108)  < '08:30:00' then Convert(Varchar(10), DateAdd(Day, -1, Convert(Varchar(10), MWIOH.CreateDateTime)), 121)                          -- 8시반보다 작으면 전일
       --                            Else                                                                                        Convert(Varchar(10),                                               MWIOH.CreateDateTime,   121)  End  AS OutDate   -- 그렇지 않으면 당일    (주영진 부장 요청)

						 --, MM.BasicCostPrice AS BasicCostPrice                                  -- 표준원가 ( 2021.03.29, 김은초롱 추가)				 
					  FROM                       STB_MaterialWarehouseInOutHist MWIOH with(nolock)  
							  LEFT OUTER JOIN STB_MaterialWarehouse MW1		       with(nolock)     ON SourceMaterialWarehouseCode = MW1.MaterialWarehouseCode
							  LEFT OUTER JOIN STB_MaterialWarehouse MW2		        with(nolock)    ON TargetMaterialWarehouseCode = MW2.MaterialWarehouseCode
							  LEFT OUTER JOIN STB_ProdWorkerInfo PWI		        with(nolock)            ON MWIOH.WorkerCode = PWI.WorkerCode
							  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	 with(nolock)   ON BC.ItemCode = WarehouseInOutCode	   AND BC.CodeGroup = 'WarehouseInOutCode'								  	  
							  LEFT OUTER JOIN ( 
														SELECT LotID
														 	  ,MaterialCode
															  ,isnull((select sum(isnull(CurrentQty,0)) from STB_MaterialLotInfo  with(nolock)  where LotID=smdli.LotID),MAX(smdli.StockQty)) StockQty   --add by Mr.Tung for QTY of Splited Lot on 2022-July-12  
														  FROM STB_MaterialDocLotInfo  smdli with(nolock) 
														  where  lotid not in (
																	  SELECT LotID  
																	FROM STB_MaterialLotInfo  with(nolock)  
																	where  MaterialWarehouseCode='HOLDING_VN_WH' 
														  )	
														  GROUP BY LotID, MaterialCode
														 
														UNION ALL  

														SELECT LotID                    --add by Mr.Tung for Virtual HOLDING Warehouse on 2022-March-24 
															,MaterialCode 
															,sum(CurrentQty )CurrentQty
														FROM STB_MaterialLotInfo  with(nolock)  
														where  MaterialWarehouseCode='HOLDING_VN_WH' 														
														GROUP BY LotID, MaterialCode 

														UNION ALL

															SELECT LotID                    --2022.05.26 add lot detach
															,MaterialCode 
															,sum(CurrentQty )CurrentQty 
														FROM STB_MaterialLotInfo  with(nolock)  
														where LotID like 'SP%'											
														GROUP BY LotID, MaterialCode--, CurrentQty 

													 ) MDLI ON MWIOH.LotID = MDLI.LotID
							  LEFT OUTER JOIN STB_MaterialMaster MM  with(nolock)  ON MM.MaterialCode = MDLI.MaterialCode                                                                                      					  
							  LEFT OUTER JOIN STB_LineInfo LI  with(nolock)  ON LI.LineCode = MWIOH.LineCode
							  LEFT OUTER JOIN STB_ProductGroup  SPG WITH(NOLOCK) ON  SPG.ProductGroupCode = MM.ProductGroupCode   
							  LEFT OUTER JOIN STB_MaterialLotInfo MLI
							    ON MLI.LotID = MWIOH.LotID
					 WHERE    
					  MWIOH.CompanyCode = 'VVT'
					   And  MWIOH.WorkCenterCode = 'VVT_F1'
					   And MWIOH.LotID NOT IN ( 
															   SELECT LotID 
																FROM STB_MaterialDocLotInfo  with(nolock)  
															   WHERE MaterialLocationCode LIKE 'ROUTE_%'
															     AND CreateDateTime BETWEEN @FromDate AND @ToDate
												)
					   And MWIOH.CreateDateTime BETWEEN @FromDate AND @ToDate		
					

					 ORDER BY MWIOH.CreateDateTime
			   End

END
