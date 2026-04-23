-- ===========================================================================================================================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2019-07-31
-- Browsable : True
-- Group : 조립불량현황 > Grid2.불량코드별 조립현황
-- Description:	[B660] 조립불량현황
-- Modified: 2019-08-16, Jackaroe
--             2019-09-10, kilee 공정명 변경 및  불량코드 이상한것 확인 (품질-공정검사 불합격사유코드임) -> [C132 불량증상정보]
--             2020-07-13, 데이터 형식 varchar을(를) int(으)로 변환하는 중 오류가 발생했습니다  @pUtcOffset추가이후 변수추가
--             2022-01-04 LotNo 조회조건 추가 (채민수 요청)
--             2022-01-05 STB_ProdRouteHist 테이블 조인 - 투입수량 추가 (유영종)
--             2022-01-07 설비코드(명) 추가 (채민수 요청)

-- [프로시저 실행문]   usp_GetProdBadStatus  '','','','VNT','VNT_F1','','','','2022-01-02','2022-01-06',''
                             --  usp_GetProdBadStatus  '','','','VNT','VNT_F1','ASSYLINE-09','','','2022-03-01','2022-03-23','','',''
 --usp_GetProdBadStatus  '','','','VNT','VNT_F1','VPCLINE-01','','','2022-03-01','2022-03-23','','',''
-- SELECT * FROM STB_DefectRepairInfo WHERE FindLineCode = 'ASSYLINE-05' and FindJobdate Between '2019-09-01' and '2019-09-10' and DefectCode in ( '015', '082')            -- 불량코드 등록자 확인
-- SELECT * FROM STB_Setinfo where ControlNo in ( '20190903000090', '20190904000116')                                                                                                              -- 해당 바코드 정보 확인
-- ============================================================================================================================================
CREATE PROCEDURE [dbo].[usp_GetProdBadStatus]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pUtcOffset INT,
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pRouteCode VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(50) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL,
						@pIsOutputRoute BIT = NULL,
						@pLotNo VARCHAR(20) = NULL,   -- 2022.01.04 추가
						@pIsNormalLot BIT = 0
AS

BEGIN
	SET NOCOUNT ON;
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'')    = '' THEN '*'      ELSE @pCompanyCode    END      --2019.12.16 수정
	DECLARE @WorkCenterCode   VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*'      ELSE @pWorkCenterCode END      --2019.12.16 수정	
	DECLARE @LineCode VARCHAR(20)          = CASE WHEN ISNULL(@pLineCode,'')           = '' THEN '*'        ELSE @pLineCode          END
	DECLARE @RouteCode VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '*'       ELSE @pRouteCode        END
	DECLARE @MaterialCode VARCHAR(50)     = CASE WHEN ISNULL(@pMaterialCode,'')       = '' THEN '*'       ELSE @pMaterialCode     END
	DECLARE @FromDate DATE                   = CONVERT(CHAR(10), @pFromDate, 121) + ' 08:30:59'
	DECLARE @ToDate DATE                      = CONVERT(CHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'
	DECLARE @IsOutputRoute BIT = @pIsOutputRoute
	DECLARE @LotNo      VARCHAR(20) = CASE WHEN ISNULL(@pLotNo,'')    = '' THEN '*'      ELSE @pLotNo   END      -- 2022.01.04 추가 (채민수 요청)
	Declare @IsNormalLot BIT = @pIsNormalLot

	--   SELECT dbo.fnGetWastePriceByMaterial( 'VNT' , 'VNT_F1',  'ASSYLINE-09'	 , 'LIVT38-007' , 'PC',  'E-22'  , 3) 


	SELECT ROW_NUMBER() OVER(ORDER BY X.DefectQty DESC) AS ROWNUM
			,  X.JobDate    AS 작업일자
			,  X.LineCode   AS  라인코드		  
			,  X.RouteCode AS 공정코드
			,  X.RouteName AS 공정명
			,  X.MaterialCode  AS 품목코드
			,  X.MaterialName  AS 품목명
			,  X.DefectCode AS  불량코드
			,  X.DefectName  AS 불량명
			 , X.InputQty AS 투입수량
			,  X.DefectQty AS 불량수량		
			, CASE WHEN X.InputQty = 0 THEN 0 ELSE (X.DefectQty / X.InputQty) * 100 END AS 불량률
			,  X.ControlNo                       AS ControlNo
			, X.Barcode
	     -- , dbo.fnGetWastePrice(X.LineCode, X.RouteCode, X.MaterialCode, X.DefectQty) AS DefectWastePrice   -- 원본백업
			, Isnull(dbo.fnGetWastePriceByMaterial(@CompanyCode
			                              , @WorkCenterCode
										  , X.LineCode
										  , X.MaterialCode
										  , 'PC'
										  , X.RouteCode
										  , X.DefectQty), 0) AS DefectWastePrice
				, X.MachineCode  --2022.01.06 추가
				, X.MachineName
				, X.DRIExtText02
    INTO #STB_Defect
    FROM 
		(
			SELECT A.FindJobDate    AS JobDate
				   , A.FindLineCode   AS LineCode
				   , A.FindRouteCode AS RouteCode
                   , RI.RouteName	
				   , A.MaterialCode
				   , MM.MaterialName
				   , A.DefectCode
				   , DI.BasicDefectName                 AS DefectName
				   , MAX(PRH.ProdQty) AS InputQty
				   , SUM(A.DefectQty - A.RepairQty) AS DefectQty
				   , 0  AS TotalQty		
				   , A.ControlNo                          AS ControlNo
				   , SI.Barcode
				   , PRH.MachineCode  AS MachineCode
				   , SMM.MachineName AS MachineName
				   , A.DRIExtText02
			  FROM STB_DefectRepairInfo A
			  LEFT OUTER JOIN STB_MaterialMaster MM	
			    ON A.MaterialCode = MM.MaterialCode
			  LEFT OUTER JOIN STB_DefectInfo DI
			    ON A.DefectCode = DI.DefectCode
			  LEFT OUTER JOIN STB_SetInfo SI 
			    ON SI.ControlNo = A.ControlNo
			  LEFT OUTER JOIN STB_RouteInfo RI
			    ON RI.RouteCode = A.FindRouteCode
			  LEFT OUTER JOIN STB_ProdRouteHist PRH
			    ON PRH.ControlNo = SI.ControlNo
			   AND PRH.RouteCode = A.FindRouteCode
			    LEFT OUTER JOIN STB_MachineMaster SMM
			    ON SMM.MachineCode = PRH.MachineCode
			 WHERE 1=1
			   AND (A.FindJobDate BETWEEN @FromDate AND @ToDate) 
			   AND (@LineCode = '*' OR A.FindLineCode = @LineCode)
			   AND (@RouteCode = '*' OR A.FindRouteCode = @RouteCode)
			   AND (@MaterialCode = '*' OR A.MaterialCode = @MaterialCode)
               AND ((@CompanyCode = '*') OR (A.CompanyCode = @CompanyCode))   	                     -- 2019.12.16 추가		   		 
			   AND ((@LotNo = '*') OR (SI.Barcode = @LotNo))   	                                                 -- 2022.01.04 추가		   		 
			Group by A.FindJobDate, A.FindRouteCode, RI.RouteName, A.MaterialCode, MM.MaterialName
			       , A.DefectCode, DI.BasicDefectName, A.FindLineCode, A.ControlNo, SI.Barcode
				   , PRH.MachineCode
				   , SMM.MachineName, A.DRIExtText02
		) X

	  -- #220216 불량등록이 되지 않은 일반 Lot을 포함함.
	  -- To-Do

	  SELECT dbo.fnGetLocalTime(A.작업일자,@pUtcOffset) AS 작업일자
				,A.라인코드
				,A.공정코드
				,A.공정명
				,A.품목코드
				,A.품목명
				,A.불량코드
				,A.불량명
				,A.투입수량
				,A.불량수량
				,A.불량률
				,A.ControlNo
				,A.DefectWastePrice
				,A.Barcode
				, A.MachineCode
				, A.MachineName
				, A.DRIExtText02
	    FROM #STB_Defect A
	   --GROUP BY A.작업일자
	   --            , A.라인코드 
				--   , A.공정코드
				--   , A.공정명 
				--   , A.품목코드
			 --      , A.품목명
				--   , A.불량코드
				--   , A.불량명
				--   , A.투입수량
				--   , A.불량수량
				--   , A.불량률
				--   , A.ControlNo
				--   , A.DefectWastePrice
				--   , A.Barcode
				--   , A.MachineCode
				--   , A.MachineName
	     Order By A.작업일자


END