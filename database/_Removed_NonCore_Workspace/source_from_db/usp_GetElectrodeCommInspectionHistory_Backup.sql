
-- =============================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2020-09-18
-- Browsable : true
-- Group : 품질관리
-- Description:	[C425] 전극공정검사이력조회
-- Modified:  2019-11-09  바코드 추가

-- usp_GetElectrodeCommInspectionHistory_20200921   'kilee','','VNT','VNT_F1','2020-09-13 00:00:00','2020-09-17 00:00:00','ROUTE_ELECTRODE_QUALITY','', 'VJKR1212001E05'
-- usp_GetElectrodeCommInspectionHistory_20200921   'kilee','','VNT','VNT_F1','2020-09-13 00:00:00','2020-09-17 00:00:00','ROUTE_ELECTRODE_QUALITY','', ''
-- ===================================================================================================================
Create PROCEDURE [dbo].[usp_GetElectrodeCommInspectionHistory_Backup]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL,
						@pCommInspTypeCode VARCHAR(50) = NULL,
						@pIsFinished BIT = NULL,
						@pBarcode VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;
	
    DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
    DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate    DATE = @pToDate
	DECLARE @CommInspTypeCode VARCHAR(50) = CASE WHEN ISNULL(@pCommInspTypeCode,'') = '' THEN '%' ELSE @pCommInspTypeCode END
	DECLARE @IsFinished BIT = @pIsFinished
	DECLARE @Barcode   VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END                                                             -- 추가사항    



	SELECT
			CASE WHEN CIDH.ComPanyCode = 'VNT' THEN '전주본사'
	                WHEN CIDH.ComPanyCode = 'VVT' THEN '베트남'     ELSE '기타' END   AS 사업장,
			CIDH.CommInspDocNo AS OldCommInspDocNo,
			CIDH.CommInspDocNo,
			CIDH.CommInspTypeCode,
			CITI.CommInspTypeName,
			CITI.CommInspTypeDesc,
			CIDH.CompanyCode,
			CIDH.WorkCenterCode,
			CIDH.MaterialCode,
			M.MaterialName,
			M.MaterialTypeCode,
			M.ProductGroupCode,
			CIDH.RefDocNo,
			SI.Barcode,
			SI.PONo,
			CIDH.JobDate,
			CIDH.ShiftCode,
			CIDH.InspTimeCode,
			CIDH.CategoryName,
			CIDH.ProdNo,
			ISNULL(CIDH.IsFinished,0) AS IsFinished,
			ISNULL(SI.IsFinalInspection,0) AS IsFix,
			CIDH.DocDesc,
			CIDH.InspUserID,
			CIDH.CreateDateTime,
			CIDH.CreateUserID,
			CIDH.ChangeDateTime,
			CIDH.ChangeUserID,
			CIDH.CIDHExtText02                            -- 비고내용     
			, dbo.fnGetElectrodeDensity (MAX(CIDI.CommInspDocNo), 1)  AS Thickness_Left              
			, dbo.fnGetElectrodeDensity (MAX(CIDI.CommInspDocNo), 2)  AS  Thickness_Center         
			, dbo.fnGetElectrodeDensity (MAX(CIDI.CommInspDocNo), 3)  AS Thickness_Right         
			--, CIMH.InspWorkerCode                                                 AS WorkerCode                                                              -- 공정검사 작업자코드
			--, (Select WorkerName  from STB_ProdWorkerInfo SPW  where SPW.WorkerCode =CIMH.InspWorkerCode)  AS WorkerName  -- 공정검사 작업자명 (Barcode에 입력된 작업자)

			, Max(EC.RollingDensityMin) AS RollingDensityMin   --압연밀도하한
			, Max(EC.RollingDensityMax) AS RollingDensityMax  --압연밀도상한

    --         , CONVERT(NUMERIC(10, 5), AVG(CIMH1.Measure))
			 --, CONVERT(NUMERIC(10, 5), AVG(CIMH2.Measure))
			-- , CONVERT(NUMERIC(10, 5), AVG(CIMH3.Measure))
			, dbo.fnGetElectrodeThickness01(MAX(CIDI.CommInspDocNo)) AS ElectrodeThickness01
			, dbo.fnGetElectrodeThickness02(MAX(CIDI.CommInspDocNo)) AS ElectrodeThickness02
			, dbo.fnGetElectrodeThickness03(MAX(CIDI.CommInspDocNo)) AS ElectrodeThickness03

	FROM 

-- usp_GetElectrodeCommInspectionHistory_20200918   'kilee','','VNT','VNT_F1','2020-09-13 00:00:00','2020-09-17 00:00:00','ROUTE_ELECTRODE_QUALITY','', 'VJKR1212001E05'


			STB_CommInspDocHistory                     CIDH WITH(NOLOCK)
			LEFT OUTER JOIN STB_CommInspTypeInfo CITI  WITH(NOLOCK)			ON CITI.CommInspTypeCode = CIDH.CommInspTypeCode
			LEFT OUTER JOIN STB_MaterialMaster         M  WITH(NOLOCK)			ON M.MaterialCode = CIDH.MaterialCode
			LEFT OUTER JOIN STB_SetInfo                   SI  WITH(NOLOCK)			ON SI.ControlNo = CIDH.ProdNo			
	     
			LEFT OUTER JOIN  ( 
			                           SELECT CommInspDocNo, CommInspDocItemNo, CommInspInputType
			                                    , CommInspItemCode
			                             FROM STB_CommInspDocItem
                                         WHERE CommInspItemCode IN ('REQ_A01','REQ_A02','REQ_A03') 											  
			                          ) CIDI ON CIDH.CommInspDocNo = CIDI.CommInspDocNo


												--SELECT CommInspDocNo, CommInspDocItemNo, CommInspInputType, CommInspItemCode, *
												--FROM STB_CommInspDocItem
												--WHERE CommInspItemCode IN ('REQ_A01','REQ_A02','REQ_A03') 	
												--AND 		CommInspDocItemNo = '20200913004067'		


			--LEFT OUTER JOIN   ( SELECT CommInspItemCode
			--                             FROM  STB_CommInspItem    
			--							 WHERE 1=1
			--							 AND CommInspItemCode IN ('REQ_A01','REQ_A02','REQ_A03') --AND DisplayIndex ='1'										 
			--							 GROUP BY CommInspItemCode
			--						  ) CII  ON 	 CIDI.CommInspItemCode = CII.CommInspItemCode
					
		 --LEFT OUTER JOIN STB_CommInspMeasureHist CIMH   ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo           -- 작업자정보 가져오기 위함 JOIN함 					
		
		-- ******************
			--LEFT OUTER JOIN  (
			--                            SELECT SUM(NumericMeasure)   AS NumericMeasure											   
			--							         , SUM(NumericMeasure) / 3  AS Measure											   
			--								    , CommInspDocItemNo											 											
			--                            FROM STB_CommInspMeasureHist    
			--							WHERE 1=1
			--							  --AND CommInspDocItemNo = '20200913004067'        --주석부분@!!!!!!										   										   
			--						   GROUP BY CommInspDocItemNo		
									   											   									   
			--                          ) CIMH1        ON CIMH.CommInspDocItemNo = CIMH1.CommInspDocItemNo         --1번
			
			
				LEFT OUTER JOIN  (			                           
												SELECT  --SUM(A.NumericMeasure)      AS NumericMeasure			
												          MAX(NumericMeasure) / 3  AS Measure											   								   														 
														 , A.CommInspDocItemNo		  AS CommInspDocItemNo		
														, B.CommInspItemCode AS CommInspItemCode
												FROM 
																					STB_CommInspMeasureHist A
															LEFT OUTER JOIN STB_CommInspDocItem B ON A.CommInspDocItemNo = B.CommInspDocItemNo
												WHERE 1=1
													AND  B.CommInspItemCode IN ('REQ_A01') 	
													--AND A.CommInspDocItemNo = '20200913004067'        --주석부분@!!!!!!
													GROUP BY 	 A.CommInspDocItemNo, B.CommInspItemCode					   											   									   
			                             ) CIMH1        ON CIDI.CommInspDocItemNo = CIMH1.CommInspDocItemNo          --1번
 

				 LEFT OUTER JOIN  (			                           
												SELECT -- SUM(A.NumericMeasure)      AS NumericMeasure		
												         MIN(NumericMeasure) / 3  AS Measure											   								   													
														 , A.CommInspDocItemNo		  AS CommInspDocItemNo		
														, B.CommInspItemCode AS CommInspItemCode
												FROM 
																					STB_CommInspMeasureHist A
															LEFT OUTER JOIN STB_CommInspDocItem B ON A.CommInspDocItemNo = B.CommInspDocItemNo
												WHERE 1=1
													AND  B.CommInspItemCode IN ('REQ_A02') 	
											  -- AND A.CommInspDocItemNo = '20200913004068'        --주석부분@!!!!!!
													GROUP BY 	 A.CommInspDocItemNo, B.CommInspItemCode					   											   									   
			                               ) CIMH2        ON   CIDI.CommInspDocItemNo = CIMH1.CommInspDocItemNo      --2번

				 --LEFT OUTER JOIN  (			                           
					--							SELECT  SUM(A.NumericMeasure)      AS NumericMeasure		
					--							         , SUM(NumericMeasure) / 3  AS Measure											   									   													
					--									 , A.CommInspDocItemNo		  AS CommInspDocItemNo		
					--									 , B.CommInspItemCode AS CommInspItemCode
					--							FROM 
					--																STB_CommInspMeasureHist A
					--										LEFT OUTER JOIN STB_CommInspDocItem B ON A.CommInspDocItemNo = B.CommInspDocItemNo
					--							WHERE 1=1
					--								AND  B.CommInspItemCode IN ('REQ_A03') 	
					--								-- AND A.CommInspDocItemNo = '20200913004069'        --주석부분@!!!!!!		
					--								GROUP BY 	 A.CommInspDocItemNo, B.CommInspItemCode					   											   									   
			  --                             ) CIMH3        ON  CIDI.CommInspDocItemNo = CIMH1.CommInspDocItemNo     --3번

		
				
			LEFT OUTER JOIN STB_ElectrodeCommon EC             ON CIDH.MaterialCode = EC.ProdCode

			LEFT OUTER JOIN VW_CommInspInputType VIEW_CIIT 	ON VIEW_CIIT.CommInspInputType = CIDI.CommInspInputType

	WHERE 1=1
	   AND ((@CompanyCode = '*') OR (CIDH.CompanyCode = @CompanyCode))
	   AND (CIDH.WorkCenterCode = @WorkCenterCode) 
	   AND (CIDH.CommInspTypeCode = @CommInspTypeCode) 
	   AND (CIDH.JobDate BETWEEN @FromDate AND @ToDate) 
	   AND (CIDH.IsFinished = @IsFinished) 
	   AND (@Barcode = '*' OR SI.Barcode LIKE @Barcode)		
	   AND CITI.CommInspTypeCode = 'ROUTE_ELECTRODE_QUALITY'                    -- 전극공정검사를 아예 박음!		
	  
	GROUP BY CIDH.ComPanyCode ,
					CIDH.CommInspDocNo,			
					CIDH.CommInspTypeCode,
					CITI.CommInspTypeName,
					CITI.CommInspTypeDesc,
					CIDH.CompanyCode,
					CIDH.WorkCenterCode,
					CIDH.MaterialCode,
					M.MaterialName,
					M.MaterialTypeCode,
					M.ProductGroupCode,
					CIDH.RefDocNo,
					SI.Barcode,
					SI.PONo,
					CIDH.JobDate,
					CIDH.ShiftCode,
					CIDH.InspTimeCode,
					CIDH.CategoryName,
					CIDH.ProdNo,
					CIDH.IsFinished,
					SI.IsFinalInspection,
					CIDH.DocDesc,
					CIDH.InspUserID,
					CIDH.CreateDateTime,
					CIDH.CreateUserID,
					CIDH.ChangeDateTime,
					CIDH.ChangeUserID,
					CIDH.CIDHExtText02     
--					, CIMH.InspWorkerCode                       


				--   ,CIMH.NumericMeasure                  -- 두께산술부분
                  ,VIEW_CIIT.CommInspInputTypeName -- 두께산술부분 
--	             , CIMH.MeasureResult 
				-- , CIMH.MeasureSeq                  -- 두께산술부분



				
END