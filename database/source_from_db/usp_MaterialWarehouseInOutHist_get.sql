-- ED-VJPMTR000000011
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

--  usp_MaterialWarehouseInOutHist_get 'DinhManh','VI','VVT','VVT_F1','2025-11-01 00:00:00','2025-12-01 00:00:00', '',''
-- ==================================================================================
 CREATE PROCEDURE [dbo].[usp_MaterialWarehouseInOutHist_get]
						@pProcessUserID     Varchar(20) = NULL,
						@pProcessLanguage Varchar(20) = NULL,
						@pCompanyCode    Varchar(20) = NULL,
						@pWorkCenterCode Varchar(20) = NULL,
						@pFromDate          DateTime = NULL,
						@pToDate             DateTime = NULL,
						@pLotID                varchar(50) = Null,                                         -- 2021.01.08 추가
						@pLotNo               varchar(80) = Null                                         -- 2021.01.08 추가
AS

BEGIN

	--Declare @FromDate          DATETIME     = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'           -- 원본백업
	--        , @ToDate             DATETIME     = CONVERT(VARCHAR(10), @pToDate, 121)    + ' 23:59:59'

   DECLARE	   @FromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2020-04-22', 121) + ' 08:30:00' 
	             , @ToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:30:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2020-04-22 00:01:09')), 121) + ' 08:30:00'    
		    
			
	        --  ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'
			
			
			 , @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
		     , @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
			 , @ProcessUserID     VARCHAR(20) = CASE WHEN ISNULL(@pProcessUserID, '') = '' THEN '*' ELSE @pProcessUserID END

			 , @LotID varchar(50) =CASE WHEN ISNULL(@pLotID,'') = '' THEN '*' ELSE @pLotID END  -- 2021.01.08 추가
	        , @LotNo varchar(50) =CASE WHEN ISNULL(@pLotNo,'') = '' THEN '*' ELSE @pLotNo END  -- 2021.01.08 추가

			 print @pProcessUserID

	IF @FromDate = '1900-01-01 08:30:00' OR @ToDate = '1900-01-01 08:30:00' 
	
	BEGIN
		SET @FromDate = dbo.fnGetAggregationPeriod(1)
		SET @ToDate = dbo.fnGetAggregationPeriod(2)
	END

	PRINT @FromDate
	PRINT @ToDate

	IF EXISTS (SELECT 1 
	             FROM SmartFramework.dbo.STB_UserPermissionGroup 
				WHERE UserType IN ('MaterialManagement', 'Admin')
	              AND HasPermission = CONVERT(BIT, 1)
				  AND UserID = @pProcessUserID
				  and @pProcessUserID not in ('anhduy157')
	)
	--IF @pProcessUserID in ( 'bgkoos', 'kilee', 'kilee2', 'yjjoo','koyeon','ecrkim', 'hjjo', 'kjsoo','16030203','knkim', 'jcsong', 'jcsong2', 'ucJo','nguyennha', 'hrwoo', 'dyseo', 'mklee', 'yjyu')                      -- 2020.04.03 추가 (구보겸, 이강일, 주영진, 고연, 김은초롱 조회가능)

			Begin

				print ('a')

				 SELECT MaterialWarehouseInOutHistNo
						  ,WarehouseInOutCode
						  ,BC.Description                               AS WarehouseInOutName
						  ,SourceMaterialWarehouseCode
						  ,MW1.MaterialWarehouseName           AS SourceMaterialWarehouseName
						  ,TargetMaterialWarehouseCode
						  ,MW2.MaterialWarehouseName           AS TargetMaterialWarehouseName
						  ,MLI.LotNo  as LotID3
						  , MM.MaterialCode						 
						  ,MM.MaterialName
						  ,MWIOH.WorkerCode
						  ,PWI.WorkerName
						  ,MWIOH.LineCode
						  ,LI.LineName
						  ,MWIOH.CreateUserID AS [Người xuất]
						  ,MWIOH.CreateDateTime AS [Thời gian xuất]
						 --, LI.LineDesc As LineName
						  ,ProcessedLotID as ProcessedLotID3

						  ,CASE WHEN ProcessedLotID IS NULL or ProcessedLotID='' THEN N'미출고/Lỗi' ELSE N'정상출고/Bình thường' END AS ProcessedResult
						  ,MWIOH.CreateDateTime   AS RequestDateTime				 
						 , MM.MaterialTypeCode    AS MaterialTypeCode                      -- 자재코드 2020.04.20 추가
						 , SPG.ProductGroupName  AS ProductGroupName                   -- 자재그룹명, 2020.04.20 추가		
						 , MM.MaterialUnit 		      AS MaterialUnit                            -- 수량단위, 2020.04.20 추가					  
 						  , CASE
							WHEN MWIOH.ProcessQty IS NOT NULL THEN MWIOH.ProcessQty
							ELSE MDLI.StockQty
						   END AS OutQty                                 -- 불출수량		                                -- 불출수량							   
					--, ERPUN.ConvertPrice                     AS UnitPrice                   -- 원 단위금액 (2020.04.21)
					--, MDLI.StockQty * ERPUN.ConvertPrice AS ConvertPrice              -- 환산금액 (원 단위금액 * 불출수량)
						 , MM.BasicCostPrice                      AS UnitPrice                   -- 공통정보>자재정보 표준원가로 변경 (2020.04.27)
						 , MDLI.StockQty * MM.BasicCostPrice AS ConvertPrice              -- 환산금액 (원 단위금액 * 불출수량)
					  -- , ERPUN.CurrencyType                    AS CurrencyType             -- 화폐종류(원표기)  2020.04.20 추가				 
					  -- , SUBSTRING(CONVERT(VARCHAR(10), CreateDateTime, 121), 0, 11)                                                                                                                                   AS  OutDate   -- 원본백업 (기존)	                     
						 , Case When Convert(char(8), MWIOH.CreateDateTime, 108)  < '08:30:00' then Convert(Varchar(10), DateAdd(Day, -1, Convert(Varchar(10), MWIOH.CreateDateTime)), 121)                          -- 8시반보다 작으면 전일
                                   Else                                                                                        Convert(Varchar(10),                                               MWIOH.CreateDateTime,   121)  End  AS OutDate   -- 그렇지 않으면 당일    (주영진 부장 요청)

						 , MM.BasicCostPrice AS BasicCostPrice                                  -- 표준원가 ( 2021.03.29, 김은초롱 추가)
					  FROM    STB_MaterialWarehouseInOutHist MWIOH with(nolock)  
							  LEFT OUTER JOIN STB_MaterialWarehouse MW1		      with(nolock)      ON SourceMaterialWarehouseCode = MW1.MaterialWarehouseCode
							  LEFT OUTER JOIN STB_MaterialWarehouse MW2		      with(nolock)      ON TargetMaterialWarehouseCode = MW2.MaterialWarehouseCode
							  LEFT OUTER JOIN STB_ProdWorkerInfo PWI		       with(nolock)             ON MWIOH.WorkerCode = PWI.WorkerCode
							  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	 with(nolock)   ON BC.ItemCode = WarehouseInOutCode	   AND BC.CodeGroup = 'WarehouseInOutCode'								  	  
							  LEFT OUTER JOIN ( 
														SELECT LotID
														 	  ,MAX(MaterialCode) AS MaterialCode
															  ,MAX(StockQty) AS StockQty
														  FROM STB_MaterialDocLotInfo with(nolock)  
														 GROUP BY LotID
														 UNION ALL

														 SELECT LotNo
														 	   ,MAX(MaterialCode) AS MaterialCode
															   ,MAX(StockQty) AS StockQty
														 FROM STB_MaterialDocLotInfo with(nolock)  
														 WHERE LotNo IS NOT NULL 
														 AND LotNo <> ''
														 GROUP BY LotNo
													 ) MDLI ON MWIOH.LotID = MDLI.LotID
							  LEFT OUTER JOIN STB_MaterialMaster MM  with(nolock)  ON MM.MaterialCode = MDLI.MaterialCode                                                                                      					  
							  LEFT OUTER JOIN STB_LineInfo LI  with(nolock)  ON LI.LineCode = MWIOH.LineCode
							  LEFT OUTER JOIN STB_ProductGroup  SPG WITH(NOLOCK) ON  SPG.ProductGroupCode = MM.ProductGroupCode                                                                         -- 2020.04.20 추가				   
							  --LEFT OUTER JOIN (
									--					SELECT A.품목코드   AS 품목코드
									--							, A.단가        AS 단가
									--							, A.화폐단위   AS 화폐단위
									--							, A.변경일자
									--							,  CASE WHEN A.화폐단위 = '＄' THEN A.단가 * (SELECT TOP 1 금액 FROM ERPSVR.ERPDB.DBO.환율 WHERE 코드 = '$'  ORDER BY 일자 DESC)                                                                    
									--									  WHEN A.화폐단위 = '￥' THEN A.단가 * (SELECT TOP 1 금액 FROM ERPSVR.ERPDB.DBO.환율 WHERE 코드 = '￥' ORDER BY 일자 DESC)  ELSE  A.단가   END AS ConvertPrice     -- 함수부분 
									--						FROM ERPSVR.ERPDB.DBO.업체단가 A
									--								INNER JOIN (
									--													SELECT 품목코드
									--															,MAX(변경일자) AS 변경일자
									--														FROM ERPSVR.ERPDB.DBO.업체단가
									--														WHERE 1=1
									--														  AND 단가구분 = '20'            -- 2020.04.22 추가
									--														GROUP BY 품목코드
									--												) B                                             ON A.품목코드 = B.품목코드	AND A.변경일자 = B.변경일자
									--						WHERE 1=1
									--						   AND A.단가구분 = '20'			
									--					) ERPUN  ON  ERPUN.품목코드 = MM.MaterialCode  AND ERPUN.품목코드 = MDLI.MaterialCode
							  LEFT OUTER JOIN STB_MaterialLotInfo MLI
							    ON MLI.LotID = MWIOH.LotID AND MLI.IsSplitLot = 0
					 WHERE 1=1	   
					   AND (@CompanyCode = '*' OR MWIOH.CompanyCode = @CompanyCode)
					   AND (@WorkCenterCode = '*' OR MWIOH.WorkCenterCode = @WorkCenterCode)
					   --AND MWIOH.LotID NOT IN ( 
								--							   SELECT LotID 
								--								FROM STB_MaterialDocLotInfo  with(nolock)  
								--							   WHERE MaterialLocationCode LIKE 'ROUTE_%'
								--							     AND CreateDateTime BETWEEN @FromDate AND @ToDate
								--						    )
						 and MWIOH.SourceMaterialWarehouseCode not in ('ELEC_VN_WH')
					   AND MWIOH.CreateDateTime BETWEEN @FromDate AND @ToDate		
					    AND (@LotID = '*' OR MWIOH.LotID = @LotID)              -- 2021.01.08 추가
					   AND (@LotNo = '*' OR ProcessedLotID = @LotNo  )        --OR ProcessedLotID = @LotNo )
					   --AND MWIOH.LineCode NOT IN ('UNSETTING-01', 'LINESETUP') -- 23. 01. 27 구보겸 요청 오딧 후 삭제
					   --AND MW1.MaterialWarehouseCode NOT IN ('ROH_DEFECT_WH')-- 23. 01. 27 구보겸 요청 오딧 후 삭제
					   --AND MW2.MaterialWarehouseCode NOT IN ('ROH_DEFECT_WH')-- 23. 01. 27 구보겸 요청 오딧 후 삭제

					 ORDER BY MWIOH.CreateDateTime
			   End

	Else   ------------------ 불출자들도 조회되도록 수정 (2020.06.16 반영)

				Begin

				print ('b')

				 SELECT MaterialWarehouseInOutHistNo
						  ,WarehouseInOutCode
						  ,BC.Description                               AS WarehouseInOutName
						  ,SourceMaterialWarehouseCode
						  ,MW1.MaterialWarehouseName           AS SourceMaterialWarehouseName
						  ,TargetMaterialWarehouseCode
						  ,MW2.MaterialWarehouseName           AS TargetMaterialWarehouseName
						  ,MLI.LotNo  as LotID3
						  ,mli.LotID
						  , MM.MaterialCode						 
						  ,MM.MaterialName
						  ,MWIOH.WorkerCode
						  ,PWI.WorkerName
						  ,MWIOH.LineCode
						  ,LI.LineName
						 --, LI.LineDesc As LineName
						  ,ProcessedLotID as ProcessedLotID3

						  ,CASE WHEN ProcessedLotID IS NULL or ProcessedLotID='' THEN N'미출고/Lỗi' ELSE N'정상출고/Bình thường' END AS ProcessedResult
						  ,MWIOH.CreateDateTime   AS RequestDateTime				 

						 , MM.MaterialTypeCode    AS MaterialTypeCode                      -- 자재코드 2020.04.20 추가
						 , SPG.ProductGroupName  AS ProductGroupName                   -- 자재그룹명, 2020.04.20 추가		
						 , MM.MaterialUnit 		      AS MaterialUnit                            -- 수량단위, 2020.04.20 추가					  
 						 ,coalesce(MWIOH.ActualExportQuantity, MDLI.StockQty)                AS OutQty                                 -- 불출수량							   
					--, ERPUN.ConvertPrice                     AS UnitPrice                   -- 원 단위금액 (2020.04.21)
					--, MDLI.StockQty * ERPUN.ConvertPrice AS ConvertPrice              -- 환산금액 (원 단위금액 * 불출수량)
						 , MM.BasicCostPrice                      AS UnitPrice                   -- 공통정보>자재정보 표준원가로 변경 (2020.04.27)
						 , coalesce(MWIOH.ActualExportQuantity, MDLI.StockQty) * MM.BasicCostPrice AS ConvertPrice              -- 환산금액 (원 단위금액 * 불출수량)
					  -- , ERPUN.CurrencyType                    AS CurrencyType             -- 화폐종류(원표기)  2020.04.20 추가				 
					  -- , SUBSTRING(CONVERT(VARCHAR(10), CreateDateTime, 121), 0, 11)                                                                                                                                   AS  OutDate   -- 원본백업 (기존)	                     
						 , Case When Convert(char(8), MWIOH.CreateDateTime, 108)  < '08:30:00' then Convert(Varchar(10), DateAdd(Day, -1, Convert(Varchar(10), MWIOH.CreateDateTime)), 121)                          -- 8시반보다 작으면 전일
                                   Else                                                                                        Convert(Varchar(10),                                               MWIOH.CreateDateTime,   121)  End  AS OutDate   -- 그렇지 않으면 당일    (주영진 부장 요청)

						 , MM.BasicCostPrice AS BasicCostPrice                                  -- 표준원가 ( 2021.03.29, 김은초롱 추가)				 
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
														  /*where  lotid not in (
																	  SELECT LotID  
																	FROM STB_MaterialLotInfo  with(nolock)  
																	where  MaterialWarehouseCode='HOLDING_VN_WH' 
														  )	*/
														  GROUP BY LotID, MaterialCode

														 --UNION ALL

														 --SELECT LotNo
														 --	   ,MAX(smdli.MaterialCode) AS MaterialCode
															--   ,isnull((select MAX(CurrentQty) from STB_MaterialLotInfo with(nolock)   where LotID=smdli.LotID),MAX(smdli.StockQty)) StockQty  --add by Mr.Tung for QTY of Splited Lot on 2022-July-12  
														 --FROM STB_MaterialDocLotInfo  smdli with(nolock)  
														 --where LotNo IS NOT NULL  AND LotNo <> ''
														 --GROUP BY LotNo,LotID
														 
														/*UNION ALL  

														SELECT LotID                    --add by Mr.Tung for Virtual HOLDING Warehouse on 2022-March-24 
															,MaterialCode 
															,sum(CurrentQty )CurrentQty
														FROM STB_MaterialLotInfo  with(nolock)  
														where  MaterialWarehouseCode='HOLDING_VN_WH' 														
														GROUP BY LotID, MaterialCode 
														*/
														UNION ALL

															SELECT LotID                    --2022.05.26 add lot detach
															,MaterialCode 
															,sum(CurrentQty )CurrentQty 
														FROM STB_MaterialLotInfo  with(nolock)  
														where (LotID like 'SP%'	or LotID like 'SL%')										
														GROUP BY LotID, MaterialCode--, CurrentQty 

													 ) MDLI ON MWIOH.LotID = MDLI.LotID
							  LEFT OUTER JOIN STB_MaterialMaster MM  with(nolock)  ON MM.MaterialCode = MDLI.MaterialCode                                                                                      					  
							  LEFT OUTER JOIN STB_LineInfo LI  with(nolock)  ON LI.LineCode = MWIOH.LineCode
							  LEFT OUTER JOIN STB_ProductGroup  SPG WITH(NOLOCK) ON  SPG.ProductGroupCode = MM.ProductGroupCode   
							  LEFT OUTER JOIN STB_MaterialLotInfo MLI
							    ON MLI.LotID = MWIOH.LotID AND MLI.IsSplitLot = 0
					 WHERE 1=1	   
					   And (@CompanyCode = '*' OR MWIOH.CompanyCode = @CompanyCode)
					   And (@WorkCenterCode = '*' OR MWIOH.WorkCenterCode = @WorkCenterCode)
					   --And MWIOH.LotID NOT IN ( 
								--							   SELECT LotID 
								--								FROM STB_MaterialDocLotInfo  with(nolock)  
								--							   WHERE MaterialLocationCode LIKE 'ROUTE_%'
								--							     AND CreateDateTime BETWEEN @FromDate AND @ToDate
								--						    )
					   and (isnull(MWIOH.ProcessedLotID,'') <> '' )  --không lấy ProcessedLotID bị rỗng hoặc null có thể xem lại store xuất nhập để hiểu hơn 
					   and MWIOH.SourceMaterialWarehouseCode not in ('ELEC_VN_WH')
					   And MWIOH.CreateDateTime BETWEEN @FromDate AND @ToDate		
					   --And MWIOH.CreateDateTime > Dateadd(MINUTE, -5, getdate())			                              -- 5분전 것까지만 필터링 (2020.06.16 추가)  -> 우선제외해달라 (2020.07.02)
					   --AND MWIOH.LineCode NOT IN ('UNSETTING-01', 'LINESETUP') -- 23. 01. 27 구보겸 요청 오딧 후 삭제
					   --AND MW1.MaterialWarehouseCode NOT IN ('ROH_DEFECT_WH')-- 23. 01. 27 구보겸 요청 오딧 후 삭제
					   --AND MW2.MaterialWarehouseCode NOT IN ('ROH_DEFECT_WH')-- 23. 01. 27 구보겸 요청 오딧 후 삭제

					 ORDER BY MWIOH.CreateDateTime
			   End

END

--select * from STB_MaterialWarehouseInOutHist where lotid='ML20241105000242' CreateDateTime >= '2024-12-'

