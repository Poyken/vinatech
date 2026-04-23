-- =============================================
-- Author:	   kilee
-- Create date: 2019-07-31
-- Browsable : true
-- Group : 조립불량현황 > 불량코드별 조립현황
-- Description:	[B660] 조립불량현황
-- Modified: 2019-08-16, Jackaroe
--             2019-09-10, kilee 공정명 변경 및  불량코드 이상한것 확인 (품질-공정검사 불합격사유코드임) -> [C132 불량증상정보]
--             2020-07-13, 데이터 형식 varchar을(를) int(으)로 변환하는 중 오류가 발생했습니다  @pUtcOffset추가이후 변수추가
--             2022-01-04 LotNo 조회조건 추가 (채민수 요청)
--             2022-01-04 LotNo 조회조건 추가 (채민수 요청)
-- ==================================================================================================
-- [프로시저 실행문]      EXEC usp_GetProdBadStatus  '','','VVT','','','','','2019-12-15','2019-12-15',''
-- [프로시저 실행문]      EXEC usp_GetProdBadStatus  '','','','VNT','','ASSYLINE-13','','','2020-07-12','2020-07-13','', 'VJKO222R750601'

-- SELECT * FROM STB_DefectRepairInfo WHERE FindLineCode = 'ASSYLINE-05' and FindJobdate Between '2019-09-01' and '2019-09-10' and DefectCode in ( '015', '082')            -- 불량코드 등록자 확인
-- SELECT * FROM STB_Setinfo where ControlNo in ( '20190903000090', '20190904000116')                                                                                                                  -- 해당 바코드 정보 확인

CREATE PROCEDURE usp_GetProdBadStatus_20210105
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
						@pLotNo VARCHAR(20) = NULL   -- 2022.01.04 추가
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

	DECLARE @LotNo      VARCHAR(20) = CASE WHEN ISNULL(@pLotNo,'')    = '' THEN '*'      ELSE @pLotNo   END      -- 2022.01.04 추가

	SELECT ROW_NUMBER() OVER(ORDER BY X.DefectQty DESC) AS ROWNUM
			,  X.JobDate    AS 작업일자
			,  X.LineCode   AS  라인코드		  
			,  X.RouteCode AS 공정코드
			,  X.RouteName AS 공정명
			,  X.MaterialCode  AS 품목코드
			,  X.MaterialName  AS 품목명
			,  X.DefectCode AS  불량코드
			,  X.DefectName  AS 불량명
			 , Z.TotalQty AS 투입수량
			,  X.DefectQty AS 불량수량		
			, (X.DefectQty / Z.TotalQty) * 100 AS 불량률
			,  X.ControlNo                       AS ControlNo
			, X.Barcode
			--, dbo.fnGetWastePrice(X.LineCode, X.RouteCode, X.MaterialCode, X.DefectQty) AS DefectWastePrice
			, dbo.fnGetWastePriceByMaterial(@CompanyCode
			                              , @WorkCenterCode
										  , X.LineCode
										  , X.MaterialCode
										  , 'PC'
										  , X.RouteCode
										  , X.DefectQty) AS DefectWastePrice
    INTO #STB_Defect
    FROM 
		(
		-- 불량항목별 (노승한)
			SELECT A.FindJobDate    AS JobDate
				   , A.FindLineCode   AS LineCode
				   , A.FindRouteCode AS RouteCode

				   --, CASE WHEN FindRouteCode = 'E-22' THEN '권취'
						 --   WHEN FindRouteCode = 'E-24' THEN '커링'
						 --   WHEN FindRouteCode = 'E-25' THEN '슬리빙'
						 --   WHEN FindRouteCode = 'E-26' THEN '에이징'
						 --   WHEN FindRouteCode = 'E-27' THEN '외관' 
						 --   WHEN FindRouteCode = 'E-28' THEN '포장'  ELSE '기타' END AS RouteName
                   , (SELECT SR.RouteName FROM STB_RouteInfo SR WHERE  SR.RouteCode = A.FindRouteCode)  AS RouteName		
				   , A.MaterialCode
				   , MM.MaterialName
				   , A.DefectCode
				   , DI.BasicDefectName                 AS DefectName
				 --  , DI.DefectDesc                      AS DefectDesc     --2019.12.16 추가
				   , SUM(A.DefectQty)                   AS InputQty
				   , SUM(A.DefectQty - A.RepairQty) AS DefectQty
				   , 0                                        AS TotalQty		
				   , A.ControlNo                          AS ControlNo
				   , SI.Barcode
				   --, dbo.fnGetWastePrice(A.FindLineCode, A.FindRouteCode, A.MaterialCode, SUM(DefectQty - RepairQty)) AS DefectPrice
			  FROM STB_DefectRepairInfo A
					  LEFT OUTER JOIN STB_MaterialMaster MM			    ON A.MaterialCode = MM.MaterialCode
					  LEFT OUTER JOIN STB_DefectInfo DI 			            ON A.DefectCode = DI.DefectCode
					  LEFT OUTER JOIN STB_SetInfo SI ON SI.ControlNo = A.ControlNo
			 WHERE 1=1
			   AND (A.FindJobDate BETWEEN @FromDate AND @ToDate) 
			   AND (@LineCode = '*' OR A.FindLineCode = @LineCode)
			   AND (@RouteCode = '*' OR A.FindRouteCode = @RouteCode)
			   AND (@MaterialCode = '*' OR A.MaterialCode = @MaterialCode)
               AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))   	                     -- 2019.12.16 추가		   		 
			   AND ((@LotNo = '*') OR (SI.Barcode = @LotNo))   	                                                 -- 2022.01.04 추가		   		 
			Group by A.FindJobDate, A.FindRouteCode, A.MaterialCode, MM.MaterialName, A.DefectCode, DI.BasicDefectName, A.FindLineCode
			          , A.ControlNo, SI.Barcode					
		) X
	 , 
		(
		 SELECT ''   as JobDate
				   , ''  as  LineCode		  
				   , '' as RouteCode
				   , '' AS RouteName
				  , ''  AS MaterialCode
				  , ''  AS MaterialName
				  , ''  AS DefectCode
				  --, ''  AS DefectName 
				  , ''  AS DefectDesc 
				  , 0 AS DefectQty
				  , SUM(DefectQty - RepairQty) AS TotalQty
		 FROM STB_DefectRepairInfo A
		WHERE 1=1
		  AND (A.FindJobDate BETWEEN @FromDate AND @ToDate) 
		  AND	(@LineCode = '*' OR A.FindLineCode = @LineCode )
		  AND	(@RouteCode = '*' OR A.FindRouteCode = @RouteCode )
		  AND	(@MaterialCode = '*' OR A.MaterialCode = @MaterialCode 	)
		  AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))   	                     -- 2019.12.16 추가		  
		 )  Z

            ORDER BY (X.DefectQty / Z.TotalQty) DESC


	  SELECT dbo.fnGetLocalTime(A.작업일자,@pUtcOffset) AS 작업일자
				,A.라인코드
				,A.공정코드
				,A.공정명
				,A.품목코드
				,A.품목명
				,A.불량코드
				,A.불량명
				--,A.불량내용
				,A.투입수량
				,A.불량수량
				,A.불량률
				--,SUM(B.불량률) AS 누적불량률     -- 2021-01-04 채민수 제외
				,A.ControlNo
				,A.DefectWastePrice
				,A.Barcode
	    FROM #STB_Defect A
	            -- INNER JOIN #STB_Defect B   ON B.ROWNUM <= A.ROWNUM  -- 2021-01-04 채민수 제외
	   GROUP BY A.작업일자
	               , A.라인코드 
				   , A.공정코드
				   , A.공정명 
				   , A.품목코드
			       , A.품목명
				   , A.불량코드
				   , A.불량명
				   , A.투입수량
				   , A.불량수량
				   , A.불량률
				   , A.ControlNo
				   , A.DefectWastePrice
				   , A.Barcode
	     Order By A.작업일자
	  -- ORDER BY SUM(B.불량률)  -- 2021-01-04 채민수 제외

END