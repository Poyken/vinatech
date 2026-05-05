-- =============================================
-- Author:	   kilee
-- Create date: 2020-12-17
-- Browsable : true
-- Group : 조립불량현황
-- Description:	최덕렬차장 엑셀문서로 요청
-- Modified: 2019-08-16, Jackaroe
--             2019-09-10, kilee 공정명 변경 및  불량코드 이상한것 확인 (품질-공정검사 불합격사유코드임) -> [C132 불량증상정보]
--             2020-07-13, 데이터 형식 varchar을(를) int(으)로 변환하는 중 오류가 발생했습니다  @pUtcOffset추가이후 변수추가

-- [프로시저 실행문]    EXEC usp_GetProdBadStatus_20201220  '','','','VNT','','    ','','','2020-01-01','2020-11-25',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProdBadStatus_20201220]
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
			, (X.DefectQty / Z.TotalQty) * 100 AS 불량률
			,  X.ControlNo                       AS ControlNo
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
			SELECT FindJobDate    AS JobDate
				   , FindLineCode   AS LineCode
				   , FindRouteCode AS RouteCode
                   ,  (SELECT SR.RouteName FROM STB_RouteInfo SR WHERE  SR.RouteCode = A.FindRouteCode)                        AS RouteName		
				   , A.MaterialCode
				   , MM.MaterialName
				   , A.DefectCode
				   , DI.BasicDefectName                                                                                                                 AS DefectName
				   , SUM(DefectQty - RepairQty)                                  AS DefectQty
				   , 0                                                                                                                                       AS TotalQty		
				   , A.ControlNo AS ControlNo
			  FROM STB_DefectRepairInfo A
					  LEFT JOIN STB_MaterialMaster MM			    ON A.MaterialCode = MM.MaterialCode
					  LEFT JOIN STB_DefectInfo DI 			            ON A.DefectCode = DI.DefectCode
			 WHERE 1=1
			   AND (A.FindJobDate BETWEEN @FromDate AND @ToDate) 
			   AND	(@LineCode = '*' OR A.FindLineCode = @LineCode )
			   AND	(@RouteCode = '*' OR A.FindRouteCode = @RouteCode )
			   AND	(@MaterialCode = '*' OR A.MaterialCode = @MaterialCode 	)
               AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))   	                            
			   and not A.FindRouteCode in ( 'E-28' , 'V-28')              	   		 
			Group by A.FindJobDate, A.FindRouteCode, A.MaterialCode, MM.MaterialName, A.DefectCode, DI.BasicDefectName, A.FindLineCode
			          , A.ControlNo   
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



SELECT     ( SELECT  Replace(BaseMonth, '-', '')	 FROM STB_AggregationPeriod		WHERE FromDate  <= A.작업일자 	AND  ToDate  >= A.작업일자				) AS 월
					, A.라인코드
					,A.공정코드
					,A.공정명
					,A.품목코드
					,A.품목명
					,A.불량코드
					,A.불량명
					,A.불량수량  as 불량수량
					,A.불량률
FROM (
		   SELECT  ConVert(VARCHAR(10), dbo.fnGetLocalTime(A.작업일자,@pUtcOffset), 121) AS 작업일자
					, A.라인코드
					,A.공정코드
					,A.공정명
					,A.품목코드
					,A.품목명
					,A.불량코드
					,A.불량명
					,A.불량수량  as 불량수량
					,A.불량률
			FROM #STB_Defect A
					 INNER JOIN #STB_Defect B   ON B.ROWNUM <= A.ROWNUM
		   GROUP BY A.작업일자
					   , A.라인코드 
					   , A.공정코드
					   , A.공정명 
					   , A.품목코드
					   , A.품목명
					   , A.불량코드
					   , A.불량명
					   , A.불량수량
					   , A.불량률
					   --, A.ControlNo
					   --, A.DefectWastePrice
		 --  ORDER BY SUM(B.불량률)
) A

END