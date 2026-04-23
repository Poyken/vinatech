CREATE PROC usp_GETProdRouteSummaryPython
	AS
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
	--    INTO #STB_Defect
		FROM 
			(
				SELECT FindJobDate    AS JobDate
					   , FindLineCode   AS LineCode
					   , FindRouteCode AS RouteCode

					   ,  (SELECT SR.RouteName FROM STB_RouteInfo SR WHERE  SR.RouteCode = A.FindRouteCode)                        AS RouteName		
					   , A.MaterialCode
					   , MM.MaterialName
					   , A.DefectCode
					   , DI.BasicDefectName                                                                                                                 AS DefectName
					   , SUM(DefectQty - RepairQty)                                                                                                                      AS DefectQty
					   , 0                                                                                                                                       AS TotalQty		
					   , A.ControlNo                                                                                                                          AS ControlNo
				  FROM STB_DefectRepairInfo A
						  LEFT JOIN STB_MaterialMaster MM			    ON A.MaterialCode = MM.MaterialCode
						  LEFT JOIN STB_DefectInfo DI 			            ON A.DefectCode = DI.DefectCode
				 WHERE 1=1
				   AND (A.FindJobDate BETWEEN '20190101' AND '20200201')   		 


				group by A.FindJobDate, A.FindRouteCode, A.MaterialCode, MM.MaterialName, A.DefectCode, DI.BasicDefectName, A.FindLineCode
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
					  --, ''  AS DefectName 
					  , ''  AS DefectDesc 
					  , 0 AS DefectQty
					  , SUM(DefectQty - RepairQty) AS TotalQty
			 FROM STB_DefectRepairInfo A
			WHERE 1=1
			  AND (A.FindJobDate BETWEEN '20190101' AND '20200201')   
			 )  Z