
-- ==============================================================================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2022-03-07
-- Browsable : True
-- Group : 생산관리 > 생산현황관리 > 생산현황 > [B667] VPC일별공정별 생산현황
-- Description: [B667] 일별공정별설비별_생산현황!! (두번째 화면)
-- Modified: Dynamic Grid용 (온정민)

-- 프로시저 실행 :                 usp_ProductionByFacility  'kilee2','Korean', 'E-22', '2022-03-02' ,'2022-03-07'
-- ===============================================================================================
Create PROCEDURE [dbo].[usp_ProductionByFacility_Backup]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pRouteCode VARCHAR(20) = Null,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL
AS

BEGIN

	SET NOCOUNT ON;

	Declare @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	Declare @RouteCode VARCHAR(50) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END
	Declare @RouteName VARCHAR(50)

	Declare @TotInputQty NUMERIC(20,2)
	Declare @TotProdQty NUMERIC(20,2)
	Declare @TotProdRate NUMERIC(20,2)
	
	DECLARE @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	DECLARE @ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'
	DECLARE @DiffDate INT = DATEDIFF(DAY,@FromDate,@ToDate)
	DECLARE @PlanQtyName NVARCHAR(100)
	DECLARE @ProdPriorName NVARCHAR(100)
	DECLARE @PlanCTName NVARCHAR(100)
	Declare @First_Table TABLE (
								RouteName VARCHAR(20)
								,MachineNAme VARCHAR(20)
								,QtyCode VARCHAR(20)
								,NumericField INT
								,Qty NUMERIC(20,1)
							    );

	--#220222
	IF @RouteCode = '*' 

	BEGIN
		SET @RouteName = '*'
	END ELSE 
	            BEGIN
						SELECT @RouteName = CASE WHEN RouteName = '커링' THEN '조립(커링)' ELSE RouteName END
						  FROM STB_RouteInfo
						 WHERE RouteCode = @RouteCode
	           END
	

	-- 공통조회부분 --------------------------------------------------------------
   SELECT CONVERT(CHAR(10), FIN.ProdDateTime, 120) AS ProdDateTime
         , RouteCode 
         , CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END AS RouteName
        , FIN.MachineName
        , CONVERT(NUMERIC(20,1), SUM(FIN.InputProdQty)) AS 투입수량
        , CONVERT(NUMERIC(20,1), SUM(FIN.ProdQty)) AS 생산수량
        , CONVERT(NUMERIC(20,1), SUM(FIN.ProdQty) / SUM(FIN.InputProdQty) * 100) AS '진행률(%)'
   INTO #ProdReportInfo
   FROM (
      SELECT   TOP 100000
                 PRH.RouteCode
               , RI.RouteName
               , PRH.ProdDateTime
               , LAG(PRH.ProdDateTime) 
                     OVER(ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28' 
                                       THEN 'E-99' ELSE PRH.RouteCode END) AS PrevProdDateTime
               , ISNULL(PRH.MachineCode, PM.MachineCode) AS MachineCode
               --, ISNULL(MM.MachineName, MM3.MachineName) AS MachineName
			   , CASE WHEN RI.RouteCode = 'E-22' AND (MM.MachineName IS NULL OR MM.MachineName = '' OR MM.MachineName = '권취1호기' OR MM.MachineName = '셀#5 권취기' OR MM.MachineName = '셀#1 커링&슬리브기') THEN '셀#1 권취기'
			            WHEN RI.RouteCode = 'E-24' AND (MM.MachineName IS NULL OR MM.MachineName = '' OR MM.MachineName = '셀#1 커링&슬리브기' OR MM.MachineName = '셀2 조립기' OR MM.MachineName = '소형고무전삽입 1호기') THEN '셀#1 조립기'
					    WHEN RI.RouteCode = 'E-29' AND (MM.MachineName IS NULL OR MM.MachineName = '' OR MM.MachineName = '자동절곡#1' OR MM.MachineName = '자동절곡#2') THEN '소형VPC도핑&선별1호'
					    WHEN RI.RouteCode = 'E-33' AND (MM.MachineName IS NULL OR MM.MachineName = '' OR MM.MachineName = '소형VPC도핑&선별1호' OR MM.MachineName = '소형VPC도핑&선별2호') THEN '자동절곡#1'
					    ELSE ISNULL(MM.MachineName, MM3.MachineName) END AS MachineName
               , PRH.ProdQty AS InputProdQty
               --, ISNULL(DRI.DefectQty, 0) AS DefectQty 
               , (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty
         FROM STB_SetInfo SI WITH(NOLOCK) 
               LEFT OUTER JOIN STB_ProdRouteHist  PRH	WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
               LEFT OUTER JOIN STB_RouteInfo      RI	WITH(NOLOCK)    ON PRH.RouteCode = RI.RouteCode
               LEFT OUTER JOIN STB_MachineMaster  MM    WITH(NOLOCK)	ON PRH.MachineCode = MM.MachineCode
               LEFT OUTER JOIN STB_ProdWorkerInfo PWI   WITH(NOLOCK)    ON PRH.WorkerCode = PWI.WorkerCode
               LEFT OUTER JOIN STB_MaterialMaster MM2   WITH(NOLOCK)    ON SI.MaterialCode = MM2.MaterialCode
               LEFT OUTER JOIN STB_LineInfo       LI	WITH(NOLOCK)    ON SI.InputLineCode = LI.LineCode
               LEFT OUTER JOIN ( SELECT DRI2.ControlNo
											   ,DRI2.FindRouteCode
											   ,MAX(PRH2.MachineCode) AS MachineCode
											   ,SUM(DRI2.DefectQty) AS DefectQty 
										   FROM STB_DefectRepairInfo DRI2  WITH(NOLOCK) 
										   LEFT OUTER JOIN STB_ProdRouteHist PRH2
											 ON DRI2.ControlNo = PRH2.ControlNo
											AND DRI2.FindRouteCode = PRH2.RouteCode
										  WHERE RepairType = 'NONE'
											AND DefectCode NOT IN ('E-22_X03','E-22_X12','E-24_X03','E-24_X12')
											AND PRH2.ProdDateTime BETWEEN @FromDate AND @ToDate
										  GROUP BY DRI2.ControlNo, DRI2.FindRouteCode
										) DRI                 ON PRH.ControlNo = DRI.ControlNo                AND PRH.RouteCode = DRI.FindRouteCode                AND PRH.MachineCode = DRI.MachineCode
               LEFT OUTER JOIN (
								SELECT RouteCode, MIN(MachineCode) AS MachineCode
								  FROM STB_ProductMachine
								 GROUP BY RouteCode
								) PM                 ON PM.RouteCode = PRH.RouteCode
               LEFT OUTER JOIN STB_MachineMaster MM3                 ON MM3.MachineCode = PM.MachineCode
         WHERE 1=1
           AND PRH.CompanyCode = 'VNT'
           AND PRH.WorkCenterCode = 'VNT_F1'
           AND PRH.ProdDateTime BETWEEN @FromDate AND @ToDate
           AND PRH.MaterialCode = 'LIVT38-018'
         ORDER BY SI.Barcode
            , CASE WHEN PRH.RouteCode = 'E-28' THEN 'E-99' ELSE PRH.RouteCode END
   ) FIN
   WHERE (ABS(DATEDIFF(day, FIN.PrevProdDateTime, FIN.ProdDateTime)) < 20 OR FIN.PrevProdDateTime IS NULL)
     AND (ABS(DATEDIFF(ms, FIN.PrevProdDateTime, FIN.ProdDateTime)) > 10000 OR FIN.PrevProdDateTime IS NULL)
     AND FIN.RouteCode IN ('E-22', 'E-24', 'E-28', 'E-29', 'E-33', 'E-34')
   GROUP BY CONVERT(CHAR(10), FIN.ProdDateTime, 120)
           ,RouteCode 
           ,CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END
           ,FIN.MachineName 
           --WITH ROLLUP
   HAVING CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END IS NOT NULL
   ORDER BY CONVERT(CHAR(10), FIN.ProdDateTime, 120)
           ,CASE CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END 
                 WHEN '권취' THEN '01'
                 WHEN '조립(커링)' THEN '02'
                 WHEN '도핑' THEN '03' 
                 WHEN '절곡' THEN '04'
                 WHEN '재검' THEN '05'
				 WHEN '포장' THEN '06'
                 ELSE '99' END
           ,CASE WHEN FIN.MachineName IS NULL THEN '핳' ELSE FIN.MachineName END


		   
		   INSERT INTO @First_Table
			SELECT    RouteName
					, ISNULL(MachineName, '') MachineName
					, QtyCode
					, 0  AS NumericField
					, Qty						
			 FROM #ProdReportInfo 
		   UNPIVOT (
					 Qty FOR QtyCode IN (투입수량, 생산수량, [진행률(%)])
					) AS unpvt
           WHERE 1=1
		     --AND  RouteCode = @RouteCode
			 And (@RouteCode = '*' OR RouteCode = @RouteCode)



		--- 1. 틀고정부분

		--#220222 누계 데이터 입력
		SELECT @TotInputQty = SUM(Qty) 
		  FROM @First_Table
		 WHERE QtyCode = '투입수량'

		 SELECT @TotProdQty = SUM(Qty) 
		  FROM @First_Table
		 WHERE QtyCode = '생산수량'


		SET @TotProdRate = @TotProdQty / @TotInputQty * 100    -- 누계 진행률

		INSERT INTO @First_Table VALUES ('', '소계', '투입수량', 0, @TotInputQty)
		INSERT INTO @First_Table VALUES ('', '소계', '생산수량', 0, @TotProdQty)
		INSERT INTO @First_Table VALUES ('', '소계', '진행률(%)', 0, @TotProdRate)

		SELECT RouteName
		      , MachineName
			  , QtyCode
			  , MAX(NumericField) AS NumericField
			  , CASE WHEN QtyCode = '진행률(%)' THEN LAG(SUM(Qty), 1, NULL) OVER (ORDER BY RouteName, MachineName, CASE WHEN QtyCode = '투입수량'  THEN '01'
																											            WHEN QtyCode = '생산수량'  THEN '03'
																											            WHEN QtyCode = '진행률(%)'  THEN '99'   ELSE '04' END)
											/ LAG(SUM(Qty), 2, NULL) OVER (ORDER BY RouteName, MachineName, CASE WHEN QtyCode = '투입수량'  THEN '01'
																											     WHEN QtyCode = '생산수량'  THEN '03'
																											     WHEN QtyCode = '진행률(%)'  THEN '99'   ELSE '04' END) * 100
				     ELSE SUM(Qty) END AS Total_Qty
		  FROM @First_Table
		 GROUP BY RouteName
		      ,MachineName
			  ,QtyCode
	     ORDER BY RouteName
				 ,MachineName
				 ,CASE WHEN QtyCode = '투입수량'  THEN '01'
				       WHEN QtyCode = '생산수량'  THEN '03'
					   WHEN QtyCode = '진행률(%)' THEN '99'
					   ELSE '04' END
      


		; WITH Items AS
			(
				SELECT
								(
									SELECT
											SR.Value
									FROM 
											SmartFramework.dbo.STB_StringResources SR
									WHERE 1=1
										AND Language = @ProcessLanguage   
										AND SR.Name = '^Qty ^'    
								) AS PlanItem

				,'NumericFIeld' AS RefField
				,'NUMERIC(20,1)' AS DataType
				,'Qty' AS DataField
			)

   
	      -- [두번째] 1과 3의 테이블 조인관계
            SELECT 
                  dbo.fnConvertDateTimeToVarchar('yyyy-MM-dd',DateAdd(DAY,MSV.number,@FromDate)) AS BandName,
                  Convert(Varchar(5), DateAdd(DAY,MSV.number,@FromDate), 101) AS PlanDate,
                  Items.PlanItem,
                  Items.RefField,
                  Items.DataType,
                  Items.DataField
            FROM
                  master..spt_values MSV WITH (NOLOCK)
                  CROSS JOIN Items
            WHERE 1=1
                  AND MSV.[type] = 'P' 
                  AND MSV.number <= @DiffDate
   


	
	 -- [3번째] 수량으로 펼칠 데이터부분
	    SELECT Convert(Varchar(5), convert(date, ProdDateTime, 121), 101) As PlanDate
		     , Qty
			 , RouteName
			 , ISNULL(MachineName, '') MachineName
			 , QtyCode
		 INTO #Third_Table 
         FROM #ProdReportInfo 	
   UNPIVOT (
                          Qty FOR QtyCode IN (투입수량, 생산수량, [진행률(%)])
                      )  AS unpvt

	-- 일자별 합계 
	-- 1. 투입수량
	--#220222
	INSERT INTO #Third_Table (PlanDate, Qty, RouteName, MachineName, QtyCode)
		SELECT PlanDate
		      ,SUM(Qty)
			  ,''
			  ,'소계'
			  ,'투입수량'
		  FROM #Third_Table
		 WHERE QtyCode = '투입수량'
		   AND (@RouteName = '*' OR RouteName = @RouteName)
		 GROUP BY PlanDate
		UNION ALL

		SELECT PlanDate
		      ,SUM(Qty)
			  ,''
			  ,'소계'
			  ,'생산수량'
		  FROM #Third_Table
		 WHERE QtyCode = '생산수량'
		   AND (@RouteName = '*' OR RouteName = @RouteName)
		 GROUP BY PlanDate
		UNION ALL

		SELECT PlanDate
		      ,CONVERT(NUMERIC(20,2), SUM(CASE WHEN QtyCode = '생산수량' THEN Qty ELSE 0 END)) 
				/ SUM(CASE WHEN QtyCode = '투입수량' THEN Qty ELSE 0 END) * 100
			  ,''
			  ,'소계'
			  ,'진행률(%)'
		  FROM #Third_Table
		 WHERE QtyCode IN ('투입수량', '생산수량')
		   AND (@RouteName = '*' OR RouteName = @RouteName)
		 GROUP BY PlanDate


;WITH Items AS
	(
		SELECT
			--'PlanQty',
			(
				SELECT
						SR.Value
				FROM 
						SmartFramework.dbo.STB_StringResources SR
				WHERE 1=1
						AND Language = @ProcessLanguage 
						AND SR.Name = '^Qty ^'
			) AS  PlanItem,
			'NumericFIeld' AS RefField,
			'NUMERIC(20,1)'             AS DataType,
			'Qty'        AS DataField		
	)

	-- 3. Main
	SELECT  ISNULL(New.MachineName, '') MachineName
	      , New.PlanDate AS PlanDate
		  , New.Qty
		  , New.QtyCode
		  , New.RouteName
	     --       , dbo.fnConvertDateTimeToVarchar('yyyy-MM-dd',New.PlanDate) AS BandName
		  , Items.PlanItem
		  , Items.DataField
	FROM #Third_Table  New
		 CROSS JOIN Items 

    Drop Table #ProdReportInfo     -- TEMP TABLE 삭제

END