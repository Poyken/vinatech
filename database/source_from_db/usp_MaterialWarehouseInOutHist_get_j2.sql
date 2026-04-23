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
--  usp_MaterialWarehouseInOutHist_get_j2 'yjjoo','Korean','VNT','VNT_F1','2020-04-24 00:00:00','2020-04-25 00:00:00'
-- ==================================================================================

CREATE PROCEDURE [dbo].[usp_MaterialWarehouseInOutHist_get_j2]
						@pProcessUserID     Varchar(20),
						@pProcessLanguage Varchar(20),
						@pCompanyCode    Varchar(20) = NULL,
						@pWorkCenterCode Varchar(20) = NULL,
						@pFromDate          DateTime,
						@pToDate             DateTime
AS
BEGIN

	--Declare @FromDate          DATETIME     = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'           -- 원본백업
	--        , @ToDate             DATETIME     = CONVERT(VARCHAR(10), @pToDate, 121)    + ' 23:59:59'
   DECLARE @FromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2020-04-22', 121) + ' 08:30:00' 
	         , @ToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:30:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2020-04-22 00:01:09')), 121) + ' 08:30:00'    
		     , @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
		     , @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
			 , @ProcessUserID     VARCHAR(20) = CASE WHEN ISNULL(@pProcessUserID, '') = '' THEN '*' ELSE @pProcessUserID END

	IF @pProcessUserID in ( 'bgkoos', 'kilee', 'kilee2', 'yjjoo')                      -- 2020.04.03 추가 (구보겸, 이강일, 주영진부장 조회가능)

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
						 -- , Case When MM.MaterialCode IS NULL THEN 'GBCP00-001' ELSE  MM.MaterialCode   END AS MaterialCode              -- 품목코드
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
						 , ERPUN.ConvertPrice                     AS UnitPrice                   -- 원 단위금액 (2020.04.21)
					  -- , ERPUN.CurrencyType                    AS CurrencyType             -- 화폐종류(원표기)  2020.04.20 추가				 
					  -- , SUBSTRING(CONVERT(VARCHAR(10), CreateDateTime, 121), 0, 11)                                                                                                                                 AS  OutDate           -- 원본백업 (기존)	                     
						 , Case When Convert(char(8), MWIOH.CreateDateTime, 108)  < '08:30:00' then Convert(Varchar(10), DateAdd(Day, -1, Convert(Varchar(10), MWIOH.CreateDateTime)), 121)                        -- 8시반보다 작으면 전일
                                   Else                                                                                        Convert(Varchar(10),                                                   MWIOH.CreateDateTime, 121)  End  AS OutDate -- 그렇지 않으면 당일
					  FROM                       STB_MaterialWarehouseInOutHist MWIOH
							  LEFT OUTER JOIN STB_MaterialWarehouse MW1		         ON SourceMaterialWarehouseCode = MW1.MaterialWarehouseCode
							  LEFT OUTER JOIN STB_MaterialWarehouse MW2		         ON TargetMaterialWarehouseCode = MW2.MaterialWarehouseCode
							  LEFT OUTER JOIN STB_ProdWorkerInfo PWI		                 ON MWIOH.WorkerCode = PWI.WorkerCode
							  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	 ON BC.ItemCode = WarehouseInOutCode	   AND BC.CodeGroup = 'WarehouseInOutCode'								  	  
							  LEFT OUTER JOIN ( 
														 SELECT LotID
															  , MaterialCode
														   FROM STB_MaterialDocLotInfo
														  GROUP BY LotID, MaterialCode
														 UNION ALL
														 SELECT LotNo
															  , MAX(MaterialCode) AS MaterialCode
														   FROM STB_MaterialDocLotInfo
														  WHERE LotNo IS NOT NULL 
														    AND LotNo <> ''
														  GROUP BY LotNo
													 ) MDLI	                                      ON MWIOH.LotID = MDLI.LotID
							  LEFT OUTER JOIN STB_MaterialMaster MM	                  ON MM.MaterialCode = MDLI.MaterialCode                                                                                      					  
							  LEFT OUTER JOIN STB_LineInfo         LI	                      ON LI.LineCode = MWIOH.LineCode
							  LEFT OUTER JOIN STB_ProductGroup  SPG WITH(NOLOCK) ON  SPG.ProductGroupCode = MM.ProductGroupCode                                                                         -- 2020.04.20 추가				   
							  LEFT OUTER JOIN (
														SELECT A.품목코드   AS 품목코드
																, A.단가        AS 단가
																, A.화폐단위   AS 화폐단위
																, A.변경일자
																,  CASE WHEN A.화폐단위 = '＄' THEN A.단가 * (SELECT TOP 1 금액 FROM ERPSVR.ERPDB.DBO.환율 WHERE 코드 = '$'  ORDER BY 일자 DESC)                                                                    
																		  WHEN A.화폐단위 = '￥' THEN A.단가 * (SELECT TOP 1 금액 FROM ERPSVR.ERPDB.DBO.환율 WHERE 코드 = '￥' ORDER BY 일자 DESC)  ELSE  A.단가   END AS ConvertPrice     -- 함수부분 
															FROM ERPSVR.ERPDB.DBO.업체단가 A
																	INNER JOIN (
																						SELECT 품목코드
																								,MAX(변경일자) AS 변경일자
																							FROM ERPSVR.ERPDB.DBO.업체단가
																							WHERE 1=1
																							  AND 단가구분 = '20'            -- 2020.04.22 추가
																							GROUP BY 품목코드
																					) B                                             ON A.품목코드 = B.품목코드	AND A.변경일자 = B.변경일자
															WHERE 1=1
															   AND A.단가구분 = '20'			
														) ERPUN  ON  ERPUN.품목코드 = MM.MaterialCode  AND ERPUN.품목코드 = MDLI.MaterialCode
					 WHERE 1=1	   
					   AND (@CompanyCode = '*' OR MWIOH.CompanyCode = @CompanyCode)
					   AND (@WorkCenterCode = '*' OR MWIOH.WorkCenterCode = @WorkCenterCode)
					   AND MWIOH.CreateDateTime BETWEEN @FromDate AND @ToDate		
					 ORDER BY MWIOH.CreateDateTime
			   End

	Else   ------------------ 아래는 신경쓰지 마세요!

			   Begin 
			    ;WITH Dummy AS (
			     SELECT NULL AS MaterialWarehouseInOutHistNo
						  ,NULL AS WarehouseInOutCode
						  ,NULL AS WarehouseInOutName
						  ,NULL AS SourceMaterialWarehouseCode
						  ,NULL AS SourceMaterialWarehouseName
						  ,NULL AS TargetMaterialWarehouseCode
						  ,NULL AS TargetMaterialWarehouseName
						  ,NULL AS LotID
						  ,NULL AS MaterialCode
						  ,NULL AS MaterialName
						  ,NULL AS WorkerCode
						  ,NULL AS WorkerName
						  ,NULL AS LineCode
						  ,NULL AS LineName
						  ,NULL AS ProcessedLotID
						  ,NULL AS ProcessedResult
						  ,NULL AS RequestDateTime				 
						 , NULL AS MaterialTypeCode        
						 , NULL AS ProductGroupName      	
						 , NULL AS MaterialUnit               			  
 						 , NULL AS OutQty               
						 , NULL AS UnitPrice             
						 , NULL AS ConvertPrice         
						 , NULL AS OutDate   
					)
					SELECT *
					  FROM Dummy
					 WHERE 1=2	
			   End
END
