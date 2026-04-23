-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020.02.13
-- Browsable : true
-- Group : 자재관리
-- Description: 원자재창고불출이력
-- Modified:
--              2020.04.20 자재그룹코드, 명 추가 (주영진 부장 요청)
--              2020.04.21 단가,금액 등 추가      (주영진 부장 요청)
--  usp_MaterialWarehouseInOutHist_get 'kilee','Korean','VNT','VNT_F1','2020-04-21 00:00:00','2020-04-21 00:00:00'
-- =============================================

Create PROCEDURE [dbo].[usp_MaterialWarehouseInOutHist_get_20200421]
						@pProcessUserID     Varchar(20),
						@pProcessLanguage Varchar(20),
						@pCompanyCode    Varchar(20) = NULL,
						@pWorkCenterCode Varchar(20) = NULL,
						@pFromDate          DateTime,
						@pToDate             DateTime
AS
BEGIN

	Declare @FromDate          DATETIME     = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'
	        , @ToDate             DATETIME     = CONVERT(VARCHAR(10), @pToDate, 121)    + ' 23:59:59'
		    , @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
		    , @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
			, @ProcessUserID     VARCHAR(20) = CASE WHEN ISNULL(@pProcessUserID, '') = '' THEN '*' ELSE @pProcessUserID END


	--	SELECT     품목코드 AS 품목코드
	--				  , 단가 AS 단가
	--				  , 화폐단위   AS 화폐단위
	--	 INTO #TEMP_TABLE0421 
	--FROM ERPSVR.ERPDB.DBO.업체단가 
	--WHERE 1=1
	--	AND 단가구분 = '20'
	--	--AND 품목코드 = 'GBHNAC-041'		
	--GROUP BY 품목코드, 화폐단위
	--ORDER BY  MAX(변경일자) DESC





	IF @pProcessUserID in ( 'bgkoos', 'kilee', 'kilee2', 'yjjoo')                      -- 2020.04.03 추가 (구보겸만 조회되도록인데, 저도 조회되도록 넣었다가.. 주영진부장 요청)

	Begin

		 SELECT MWIOH.MaterialWarehouseInOutHistNo
				  ,MWIOH.WarehouseInOutCode
				  ,BC.Description                               AS WarehouseInOutName
				  ,MWIOH.SourceMaterialWarehouseCode

				  ,MW1.MaterialWarehouseName           AS SourceMaterialWarehouseName
				  ,MWIOH.TargetMaterialWarehouseCode
				  ,MW2.MaterialWarehouseName           AS TargetMaterialWarehouseName
				  ,MWIOH.LotID
				  ,MM.MaterialCode
				  ,MM.MaterialName
				  ,MWIOH.WorkerCode
				  ,PWI.WorkerName
				  ,MWIOH.LineCode
				  ,LI.LineName
				  ,MWIOH.ProcessedLotID
				  ,CASE WHEN MWIOH.ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END AS ProcessedResult
				  ,MWIOH.CreateDateTime   AS RequestDateTime
				 , MM.MaterialTypeCode    AS MaterialTypeCode                      -- 자재코드, 2020.04.20 추가
				 , SPG.ProductGroupName  AS ProductGroupName                   -- 자재그룹명, 2020.04.20 추가		
				 , MM.MaterialUnit 		      AS MaterialUnit                            -- 수량단위, 2020.04.20 추가					  
 				 , MDLI.StockQty               AS OutQty                                 -- 불출수량			
				   
				 , ERPUN.ConvertPrice        AS UnitPrice                                -- 원 단위금액 (2020.04.21)
				 , MDLI.StockQty * ERPUN.ConvertPrice AS ConvertPrice              -- 환산금액 (원 단위금액 * 불출수량)
				-- , ERPUN.CurrencyType       AS CurrencyType                          -- 화폐종류(원표기)  2020.04.20 추가				 
				  
			  FROM                       STB_MaterialWarehouseInOutHist MWIOH
					  LEFT OUTER JOIN STB_MaterialWarehouse MW1		        ON MWIOH.SourceMaterialWarehouseCode = MW1.MaterialWarehouseCode
					  LEFT OUTER JOIN STB_MaterialWarehouse MW2		        ON MWIOH.TargetMaterialWarehouseCode = MW2.MaterialWarehouseCode
					  LEFT OUTER JOIN STB_ProdWorkerInfo PWI		                ON MWIOH.WorkerCode = PWI.WorkerCode
					  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC		ON BC.ItemCode = MWIOH.WarehouseInOutCode	   AND BC.CodeGroup = 'WarehouseInOutCode'					  

  				   -- LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI	                ON MDLI.LotID = MWIOH.LotID --or MDLI.LotNo = MWIOH.LotID                                                                                                                        -- 원본백업  				   
					--LEFT OUTER JOIN (
					--                          SELECT Max(MaterialDocDetailNo) AS MaterialDocDetailNo  
					--						          , MaterialCode
					--								  , LotNo                         AS LotNo 
					--								  , Max(LotID)                   AS  LotID
					--								  , Sum(StockQty)               AS StockQty
					--                          FROM STB_MaterialDocLotInfo 
					--						 GROUP BY MaterialCode, LotNo 
					--						 )  MDLI                                             ON MDLI.LotID = MWIOH.LotID                  Or MDLI.LotNo = MWIOH.LotID 

					  LEFT OUTER JOIN ( SELECT MAX(LotID)                                                   AS LotID
					                                  , CASE WHEN LotNo = '' THEN LotID ELSE LotNo END AS LotNo
													  , MAX(MaterialCode)                                         AS MaterialCode
													  , Sum(StockQty)                                               AS StockQty					
										       FROM STB_MaterialDocLotInfo
										      GROUP BY CASE WHEN LotNo = '' THEN LotID ELSE LotNo END
                                             ) MDLI	                                                                 ON MWIOH.LotID = MDLI.LotID OR MWIOH.LotID = MDLI.LotNo

					  LEFT OUTER JOIN STB_MaterialMaster MM	                      ON MM.MaterialCode = MDLI.MaterialCode                                                                                      					  
					  LEFT OUTER JOIN STB_LineInfo LI	                                  ON LI.LineCode = MWIOH.LineCode
					  LEFT OUTER JOIN STB_ProductGroup     SPG WITH(NOLOCK)  ON  SPG.ProductGroupCode = MM.ProductGroupCode                                                                         -- 2020.04.20 추가
				   -- LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK) ON  MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo                                                                   -- 2020.04.20 추가					  					
                   -- LEFT OUTER JOIN (
												--SELECT ROW_NUMBER() OVER (ORDER BY Max(변경일자), 품목코드 DESC) AS SEQ
												--		, Max(변경일자)                                                               AS ChangeDate
												--		, Max(화폐단위)                                                               AS CurrencyType
												--		, Max(단가)                                                                    AS UnitPrice
												--		, CASE WHEN Max(화폐단위) = '원' THEN Max(단가) ELSE Max(단가) * dbo.fnGetERPExchangeRate(Max(화폐단위)) END AS ConvertPrice	
												--		, 품목코드			
												--FROM ERPSVR.ERPDB.DBO.업체단가
												--WHERE 단가구분 = '20'
											 -- -- AND 품목코드 = 'GBHNAC-041'													  
												--Group by 품목코드 
											 -- --Order By Max(변경일자), 품목코드 DESC												 
										  --  ) ERPUN  ON  ERPUN.품목코드 = MM.MaterialCode

             --           LEFT OUTER JOIN (
												 -- SELECT TOP 1 CASE WHEN 화폐단위 = '＄' THEN 단가 * (SELECT TOP 1 금액 FROM ERPSVR.ERPDB.DBO.환율 WHERE 코드 = '$' ORDER BY 일자 DESC) 
													--					   WHEN 화폐단위 = '￥' THEN 단가 * (SELECT TOP 1 금액 FROM ERPSVR.ERPDB.DBO.환율 WHERE 코드 = '￥' ORDER BY 일자 DESC) 
													--						WHEN 화폐단위 = '원' THEN 단가   ELSE  단가  END AS ConvertPrice 
													--		, 품목코드
													--FROM ERPSVR.ERPDB.DBO.업체단가
													--WHERE 1=1
													--	AND 단가구분 = '20'
													--	--AND 품목코드 = 'GCMDPT-382'		
													--ORDER BY 변경일자 DESC																						 
										   --  ) ERPUN  ON  ERPUN.품목코드 = MM.MaterialCode
							LEFT OUTER JOIN (
														SELECT A.품목코드 AS 품목코드
																, A.단가 AS 단가
																, A.화폐단위   AS 화폐단위
																, A.변경일자
																,  CASE WHEN A.화폐단위 = '＄' THEN A.단가 * (SELECT TOP 1 금액 FROM ERPSVR.ERPDB.DBO.환율 WHERE 코드 = '$' ORDER BY 일자 DESC) 
																																	  WHEN A.화폐단위 = '￥' THEN A.단가 * (SELECT TOP 1 금액 FROM ERPSVR.ERPDB.DBO.환율 WHERE 코드 = '￥' ORDER BY 일자 DESC) 
																																	  WHEN A.화폐단위 = '원' THEN A.단가   ELSE  단가  END AS ConvertPrice 
															FROM ERPSVR.ERPDB.DBO.업체단가 A
															INNER JOIN (
																SELECT 품목코드
																		,MAX(변경일자) AS 변경일자
																  FROM ERPSVR.ERPDB.DBO.업체단가
																  GROUP BY 품목코드
															) B
															 ON A.품목코드 = B.품목코드
															AND A.변경일자 = B.변경일자
															WHERE 1=1
															AND A.단가구분 = '20'																								
								                ) ERPUN  ON  ERPUN.품목코드 = MM.MaterialCode
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


    -- 조회안되는 부분임 (신경쓰지마셈) -----------------------------------------------------------------------------------------------------
	 ELSE        

	        BEGIN

				 SELECT MWIOH.MaterialWarehouseInOutHistNo
						  ,MWIOH.WarehouseInOutCode
						  ,BC.Description AS WarehouseInOutName
						  ,MWIOH.SourceMaterialWarehouseCode
						  ,MW1.MaterialWarehouseName AS SourceMaterialWarehouseName
						  ,MWIOH.TargetMaterialWarehouseCode
						  ,MW2.MaterialWarehouseName AS TargetMaterialWarehouseName
						  ,MWIOH.LotID
						  ,MM.MaterialCode
						  ,MM.MaterialName
						  ,MWIOH.WorkerCode
						  ,PWI.WorkerName
						  ,MWIOH.LineCode
						  ,LI.LineName
						  ,MWIOH.ProcessedLotID
						  ,CASE WHEN MWIOH.ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END AS ProcessedResult
						  ,MWIOH.CreateDateTime                                                                     AS RequestDateTime
					  FROM STB_MaterialWarehouseInOutHist MWIOH
							  LEFT OUTER JOIN STB_MaterialWarehouse MW1		        ON MWIOH.SourceMaterialWarehouseCode = MW1.MaterialWarehouseCode
							  LEFT OUTER JOIN STB_MaterialWarehouse MW2		        ON MWIOH.TargetMaterialWarehouseCode = MW2.MaterialWarehouseCode
							  LEFT OUTER JOIN STB_ProdWorkerInfo PWI		                ON MWIOH.WorkerCode = PWI.WorkerCode
							  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC		ON BC.ItemCode = MWIOH.WarehouseInOutCode	   AND BC.CodeGroup = 'WarehouseInOutCode'
							  LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI	                ON MDLI.LotID = MWIOH.LotID
							  LEFT OUTER JOIN STB_MaterialMaster MM	                    ON MM.MaterialCode = MDLI.MaterialCode
							  LEFT OUTER JOIN STB_LineInfo LI	                                ON LI.LineCode = MWIOH.LineCode
					 WHERE 1=2	   
					  
         	End	
	--------------

	-- TEMP TABLE삭제
    --DELETE FROM  #TEMP_TABLE0421


END