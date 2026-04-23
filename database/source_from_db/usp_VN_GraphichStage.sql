CREATE  PROCEDURE [dbo].[usp_VN_GraphichStage] 
@pCompanyCode VARCHAR(20) = NULL,
	@pMonth DATETIME = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL
AS	
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN 'VVT' ELSE @pCompanyCode END
	DECLARE @FromDate    VARCHAR(10) = CONVERT(VARCHAR(7), DATEADD(MONTH, 0, CONVERT(smalldatetime, @pMonth)), 120) +'-01'    
	DECLARE @ToDate      VARCHAR(10) = CONVERT(VARCHAR(7), DATEADD(MONTH,  1, CONVERT(smalldatetime, @pMonth)), 120) +'-01' 
	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END

BEGIN
 CREATE TABLE #Tbl01
		(
		   ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY(ID),
	       LineName NVARCHAR(50) NULL,
		   RouteCode NVARCHAR(50) NULL,
		   RouteName NVARCHAR(50) NULL,
		   MaterialCode NVARCHAR(50) NULL,
		   Total INT NULL,
		   DefectQty INT NULL
		)

	;WITH
		dataVVT2 as(
				SELECT ControlNo, FindRouteCode, FindLineCode, CompanyCode,  FindDateTime, SUM(DefectQty) AS DefectQty 
				FROM STB_DefectRepairInfo 
				WHERE FindDateTime >=@FromDate and FindDateTime < @ToDate and RepairType = 'NONE' 
				GROUP BY ControlNo, FindRouteCode, FindLineCode, CompanyCode,FindDateTime
				union
				SELECT ControlNo, RouteCode as FindRouteCode, LineCode as FindLineCode, CompanyCode,  ProdDateTime as FindDateTime, 0 as DefectQty 
				FROM STB_ProdRouteHist where  ProdDateTime >=@FromDate and ProdDateTime < @ToDate
			),
		
		datatong as(  SELECT ControlNo, FindRouteCode, FindLineCode, CompanyCode, max( FindDateTime) as FindDateTime,  sum(DefectQty ) as DefectQty
								  from dataVVT2								  
								  GROUP BY ControlNo, FindRouteCode, FindLineCode, CompanyCode
								)
								,
	deptrai as(
	SELECT 
		  DRI.ComPanyCode
		  ,SI.MaterialCode
		  ,MM2.MaterialName
		  ,SI.InputLineCode
		  ,LI.LineName
		  ,DRI.FindRouteCode as RouteCode
		  ,RI.RouteName
		  ,DRI.FindDateTime
		  ,sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  as "total"	
		  ,sum(DRI.DefectQty) as DefectQty
	  FROM STB_SetInfo SI
			  LEFT OUTER JOIN( 
							  select    ControlNo, FindRouteCode, FindLineCode, CompanyCode,   
									  (case  when   (DATEPART(HOUR, FindDateTime)>10)     or    (DATEPART(HOUR, FindDateTime)=10 and DATEPART(MINUTE, FindDateTime)>30)     
									  then     convert(varchar(10),FindDateTime,120)    
									  else    convert(varchar(10),DATEADD(DAY, -1,  FindDateTime),120)       
									  end )   as FindDateTime,     (case when FindRouteCode='V-28' then 0 else DefectQty  end) as "DefectQty"	
							  from datatong
							 ) DRI   ON si.ControlNo = DRI.ControlNo   								 
			  LEFT OUTER JOIN STB_ProdRouteHist    PRH	    ON DRI.ControlNo = PRH.ControlNo     AND PRH.RouteCode = DRI.FindRouteCode			 
			  LEFT OUTER JOIN STB_RouteInfo           RI	    ON DRI.FindRouteCode = RI.RouteCode
			  LEFT OUTER JOIN STB_MaterialMaster  MM2	    ON SI.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo              LI	    ON SI.InputLineCode = LI.LineCode
			
	 WHERE 1=1
	   AND ((@CompanyCode = '*') OR (DRI.CompanyCode = @CompanyCode)) 
	   AND DRI.FindDateTime BETWEEN @FromDate AND @ToDate
	   AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
	   AND (@LineCode = '*' OR DRI.FindLineCode   = @LineCode)
     group by DRI.ComPanyCode,SI.MaterialCode	,MM2.MaterialName	,SI.InputLineCode	,LI.LineName ,DRI.FindRouteCode 	,RI.RouteName,DRI.FindDateTime, DRI.DefectQty
	 )
	

	INSERT INTO #Tbl01(LineName,RouteCode,RouteName,MaterialCode,Total,DefectQty)

	select 
		   LineName
		  ,RouteCode 
		  ,RouteName,
		   MaterialCode,
		   SUM(total) OVER (PARTITION BY RouteName ORDER BY RouteName) AS totals,
		   SUM(DefectQty) OVER (PARTITION BY RouteName ORDER BY RouteName) AS DefectQtys
		  from deptrai

		SELECT *
			
		FROM 
				#Tbl01

		ORDER BY RouteCode ASC

	DROP TABLE #Tbl01

END