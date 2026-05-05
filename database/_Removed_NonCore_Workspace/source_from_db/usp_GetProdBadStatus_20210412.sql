-- =============================================
-- Author:	   kilee
-- Create date: 2019-07-31
-- Browsable : true
-- Group : 조립불량현황
-- Description:	[B660] 조립불량현황
-- Modified: 2019-08-16, Jackaroe
--             2019-09-10, kilee 공정명 변경 및  불량코드 이상한것 확인 (품질-공정검사 불합격사유코드임) -> [C132 불량증상정보]
--             2020-07-13, 데이터 형식 varchar을(를) int(으)로 변환하는 중 오류가 발생했습니다  @pUtcOffset추가이후 변수추가
-- =============================================
 
-- [프로시저 실행문]   EXEC usp_GetProdBadStatus_20210412  '','','','VVT','','VVC-17','','','2021-01-01','2021-03-25',''
-- Functiom 실행 :   Select   dbo.fnGetWastePriceByMaterial ('VNT' , 'VNT_F1' , 'ASSYLINE-07'  , 'LIVT38-008'	, 'PC'  , 'E-24'  , 153.00000 )                                                                                         
-- Functiom 실행 :   Select   dbo.fnGetWastePriceByMaterial ('VVT' , 'VVT_F1' , 'VVC-17'  , 'ECVT27-344'	, 'PC'  , 'V-24'  , 521.00000 ) 

/*
SELECT   CostPrice * 521.00000
           , *
	  FROM STB_ManufacturingCostByRoute MCR
	  WHERE 1=1
	  AND ROUTECODE =  'V-24'
	  AND MaterialCode =  'ECVT27-344'
	  AND COSTTYPECODE = 'PC'
	  
*/
CREATE PROCEDURE [dbo].[usp_GetProdBadStatus_20210412]
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
						@pIsOutputRoute BIT = NULL
AS

BEGIN
	SET NOCOUNT ON;

 --DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'')    = '' THEN 'VNT'     ELSE @pCompanyCode    END   -- 원본 백업
 --DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN 'VNT_F1' ELSE @pWorkCenterCode END  -- 원본 백업
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'')    = '' THEN '*'      ELSE @pCompanyCode    END      --2019.12.16 수정
	DECLARE @WorkCenterCode   VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*'      ELSE @pWorkCenterCode END      --2019.12.16 수정	
	DECLARE @LineCode VARCHAR(20)          = CASE WHEN ISNULL(@pLineCode,'')           = '' THEN '*'        ELSE @pLineCode          END
	DECLARE @RouteCode VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '*'       ELSE @pRouteCode        END
	DECLARE @MaterialCode VARCHAR(50)     = CASE WHEN ISNULL(@pMaterialCode,'')       = '' THEN '*'       ELSE @pMaterialCode     END
	DECLARE @FromDate DATE                   = @pFromDate
	DECLARE @ToDate DATE                      = @pToDate
	DECLARE @IsOutputRoute BIT = @pIsOutputRoute




	SELECT ROW_NUMBER() OVER(ORDER BY X.DefectQty DESC) AS ROWNUM
			,  X.JobDate    AS 작업일자
			,  X.LineCode   AS  라인코드		  
			,  X.RouteCode AS 공정코드
			,  X.RouteName AS 공정명
			,  X.MaterialCode  AS 품목코드
			,  X.MaterialName  AS 품목명
			,  X.DefectCode AS  불량코드
			,  X.DefectName  AS 불량명 
			,  X.DefectQty AS 불량수량		
		--	, (X.DefectQty / Z.TotalQty) * 100 AS 불량률
			,  X.ControlNo                       AS ControlNo
			--, dbo.fnGetWastePrice(X.LineCode, X.RouteCode, X.MaterialCode, X.DefectQty) AS DefectWastePrice
		, dbo.fnGetWastePriceByMaterial ( @CompanyCode
													, @WorkCenterCode
													, X.LineCode
													, X.MaterialCode
													, 'PC'
													, X.RouteCode
													, X.DefectQty) AS DefectWastePrice
    FROM 
		(

		-- X부문 : 불량항목별 (노승한)
			SELECT FindJobDate    AS JobDate
				    , FindLineCode   AS LineCode
				    , FindRouteCode AS RouteCode
                   ,  (SELECT SR.RouteName FROM STB_RouteInfo SR WHERE  SR.RouteCode = A.FindRouteCode)   AS RouteName		
				   , A.MaterialCode
				   , MM.MaterialName
				   , A.DefectCode
				   , DI.BasicDefectName                                                                                                   AS DefectName
			   --  , DI.DefectDesc                                                                                                         AS DefectDesc     --2019.12.16 추가
				   , SUM(DefectQty - RepairQty)                                  AS DefectQty
				   , 0                                                                     AS TotalQty		
				   , A.ControlNo                                                       AS ControlNo
			  -- , dbo.fnGetWastePrice(A.FindLineCode, A.FindRouteCode, A.MaterialCode, SUM(DefectQty - RepairQty)) AS DefectPrice   -- 원본백업
			  FROM STB_DefectRepairInfo A
					  LEFT JOIN STB_MaterialMaster MM			    ON A.MaterialCode = MM.MaterialCode
					  LEFT JOIN STB_DefectInfo DI 			            ON A.DefectCode = DI.DefectCode
			 WHERE 1=1
			   AND (A.FindJobDate BETWEEN @FromDate AND @ToDate) 
			   AND	(@LineCode = '*' OR A.FindLineCode = @LineCode )
			   AND	(@RouteCode = '*' OR A.FindRouteCode = @RouteCode )
			   AND	(@MaterialCode = '*' OR A.MaterialCode = @MaterialCode 	)
               AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))   	                                                 -- 2019.12.16 추가		   		 
			Group by A.FindJobDate, A.FindRouteCode, A.MaterialCode, MM.MaterialName, A.DefectCode, DI.BasicDefectName, A.FindLineCode
			          , A.ControlNo   
					-- , DI.DefectDesc    --2019.12.16 추가
		)  X

	 --, 
	 -- -- Z 부분
		--(
		-- SELECT ''   as JobDate
		--		   , ''  as  LineCode		  
		--		   , '' as RouteCode
		--		   , '' AS RouteName
		--		  , ''  AS MaterialCode
		--		  , ''  AS MaterialName
		--		  , ''  AS DefectCode
		--		  --, ''  AS DefectName 
		--		  , ''  AS DefectDesc 
		--		  , 0 AS DefectQty
		--		  , SUM(DefectQty - RepairQty) AS TotalQty
		-- FROM STB_DefectRepairInfo A
		--WHERE 1=1
		--  AND (A.FindJobDate BETWEEN @FromDate AND @ToDate) 
		--  AND	(@LineCode = '*' OR A.FindLineCode = @LineCode )
		--  AND	(@RouteCode = '*' OR A.FindRouteCode = @RouteCode )
		--  AND	(@MaterialCode = '*' OR A.MaterialCode = @MaterialCode 	)
		--  AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))   	                     -- 2019.12.16 추가		  
		-- )  Z

  --          ORDER BY (X.DefectQty / Z.TotalQty) DESC


   -- -- 마지막 조회문 (위에 into절로 받은값)
	  --SELECT dbo.fnGetLocalTime(A.작업일자,@pUtcOffset) AS 작업일자
			--	,A.라인코드
			--	,A.공정코드
			--	,A.공정명
			--	,A.품목코드
			--	,A.품목명
			--	,A.불량코드
			--	,A.불량명
			--	--,A.불량내용
			--	,A.불량수량
			--	,A.불량률
			--	,SUM(B.불량률) AS 누적불량률
			--	,A.ControlNo
			--	,A.DefectWastePrice
	  --  FROM #STB_Defect A
	  --           INNER JOIN #STB_Defect B   ON B.ROWNUM <= A.ROWNUM
	  -- GROUP BY A.작업일자
	  --             , A.라인코드 
			--	   , A.공정코드
			--	   , A.공정명 
			--	   , A.품목코드
			--       , A.품목명
			--	   , A.불량코드
			--	   , A.불량명
			--	   , A.불량수량
			--	   , A.불량률
			--	   , A.ControlNo
			--	   , A.DefectWastePrice
	  -- ORDER BY SUM(B.불량률)

END