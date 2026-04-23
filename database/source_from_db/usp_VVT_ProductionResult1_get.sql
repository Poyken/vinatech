
/* exec usp_VVT_ProductionResult1_get '','','VVT','2020-05-15','','','','ECVT27-247'    */

CREATE  PROCEDURE [dbo].[usp_VVT_ProductionResult1_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pMonth DATETIME = NULL,
	--@pToDate DATETIME = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(30) = NULL
AS	
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN 'VVT' ELSE @pCompanyCode END

	DECLARE @FromDate    VARCHAR(10) = CONVERT(VARCHAR(7), DATEADD(MONTH, 0, CONVERT(smalldatetime, @pMonth)), 120) +'-01'    
	DECLARE @ToDate      VARCHAR(10) = CONVERT(VARCHAR(7), DATEADD(MONTH,  1, CONVERT(smalldatetime, @pMonth)), 120) +'-01' 

	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN

--DECLARE @baoloi  VARCHAR(30) = @FromDate+'---'+@ToDate

--				RAISERROR(@baoloi,16,1,'K123')
--				RETURN


	;WITH /*NextProd AS
	(
		SELECT
				SI.ControlNo,
				MAX(PRH.RouteCode) AS AftRouteCode,
				SUM(PRH.ProdQty) AS AftProdQty
		FROM
									   STB_SetInfo SI WITH(NOLOCK)
				INNER JOIN        STB_ProductionOrderRouting POR WITH(NOLOCK)			 ON POR.PONo = SI.PONo             AND	POR.RouteCode = @RouteCode
				LEFT OUTER JOIN STB_ProductionOrderRouting NPOR WITH(NOLOCK)	     ON NPOR.PONo = SI.PONo           AND	NPOR.RouteIndex = POR.RouteIndex + 1
				INNER JOIN        STB_ProdRouteHist PRH WITH(NOLOCK)					     ON PRH.ControlNo = SI.ControlNo  AND	PRH.RouteCode = NPOR.RouteCode
				--INNER JOIN        STB_BasicRoutingDetail         BRD WITH(NOLOCK)	         ON BRD.RouteCode = PRH.RouteCode 
        WHERE 1=1
		   --AND BRD.IsOutputRoute <> '1'    -- 포장공정 조회안되는 이유
		GROUP BY
				SI.ControlNo
	),*/
		dataVVT2 as(
				SELECT ControlNo, FindRouteCode, FindLineCode, CompanyCode,  FindDateTime, SUM(DefectQty) AS DefectQty 
				FROM STB_DefectRepairInfo 
				WHERE FindDateTime >=@FromDate and FindDateTime < @ToDate and RepairType = 'NONE' 
				GROUP BY ControlNo, FindRouteCode, FindLineCode, CompanyCode,FindDateTime
				union
				SELECT ControlNo, RouteCode as FindRouteCode, LineCode as FindLineCode, CompanyCode,  ProdDateTime as FindDateTime, 0 as DefectQty 
				FROM STB_ProdRouteHist where  ProdDateTime >=@FromDate and ProdDateTime < @ToDate
			),
			/*
			datavvt1 as(
			 SELECT dataVVT2.ControlNo, dataVVT2.FindRouteCode, dataVVT2.FindLineCode, CompanyCode,  FindDateTime, SUM(DefectQty) AS DefectQty 
			 from dataVVT2 left outer join STB_ProdRouteHist on dataVVT2.ControlNo = STB_ProdRouteHist.ControlNo
			 
			),*/
		datatong as(  SELECT ControlNo, FindRouteCode, FindLineCode, CompanyCode, max( FindDateTime) as FindDateTime,  sum(DefectQty ) as DefectQty
								  from dataVVT2								  
								  GROUP BY ControlNo, FindRouteCode, FindLineCode, CompanyCode
								)
								,
	deptrai as(
	SELECT --CASE WHEN DRI.ComPanyCode = 'VNT' THEN '전주본사'
	       --WHEN DRI.ComPanyCode = 'VVT' THEN '베트남' ELSE '기타' END   AS 사업장
		  --,SI.ControlNo
	      --,SI.Barcode
		  DRI.ComPanyCode
		  ,SI.MaterialCode
		  ,MM2.MaterialName
		  ,SI.InputLineCode
		  ,LI.LineName
		  ,DRI.FindRouteCode as RouteCode
		  ,RI.RouteName
		  ,DRI.FindDateTime

		  ,sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  as "total"	
		  /*, (case when DATEPART(DAY, FindDateTime)=1 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "1"	
		  --, sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  as "k1"
		  , (case when DATEPART(DAY, FindDateTime)=2 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "2"
		  , (case when DATEPART(DAY, FindDateTime)=3 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "3"
		  , (case when DATEPART(DAY, FindDateTime)=4 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "4"
		  , (case when DATEPART(DAY, FindDateTime)=5 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "5"
		  , (case when DATEPART(DAY, FindDateTime)=6 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "6"
		  , (case when DATEPART(DAY, FindDateTime)=7 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "7"
		  , (case when DATEPART(DAY, FindDateTime)=8 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "8"
		  , (case when DATEPART(DAY, FindDateTime)=9 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "9"
		  , (case when DATEPART(DAY, FindDateTime)=10 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "10"
		  , (case when DATEPART(DAY, FindDateTime)=11 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "11"
		  , (case when DATEPART(DAY, FindDateTime)=12 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "12"
		  , (case when DATEPART(DAY, FindDateTime)=13 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "13"
		  , (case when DATEPART(DAY, FindDateTime)=14 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "14"
		  , (case when DATEPART(DAY, FindDateTime)=15 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "15"
		  , (case when DATEPART(DAY, FindDateTime)=16 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "16"
		  , (case when DATEPART(DAY, FindDateTime)=17 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "17"
		  , (case when DATEPART(DAY, FindDateTime)=18 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "18"
		  , (case when DATEPART(DAY, FindDateTime)=19 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "19"
		  , (case when DATEPART(DAY, FindDateTime)=20 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "20"
		  , (case when DATEPART(DAY, FindDateTime)=21 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "21"
		  , (case when DATEPART(DAY, FindDateTime)=22 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "22"
		  , (case when DATEPART(DAY, FindDateTime)=23 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "23"
		  , (case when DATEPART(DAY, FindDateTime)=24 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "24"
		  , (case when DATEPART(DAY, FindDateTime)=25 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "25"
		  , (case when DATEPART(DAY, FindDateTime)=26 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "26"
		  , (case when DATEPART(DAY, FindDateTime)=27 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "27"
		  , (case when DATEPART(DAY, FindDateTime)=28 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "28"
		  , (case when DATEPART(DAY, FindDateTime)=29 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "29"
		  , (case when DATEPART(DAY, FindDateTime)=30 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "30"
		  , (case when DATEPART(DAY, FindDateTime)=31 then sum(PRH.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "31"
		  */
		  ,sum(DRI.DefectQty) as DefectQty
		   /*, (case when DATEPART(DAY, FindDateTime)=1 then sum(DRI.DefectQty)  end) as "1_Defect"	
		   , (case when DATEPART(DAY, FindDateTime)=2 then sum(DRI.DefectQty)  end) as "2_Defect"
		   , (case when DATEPART(DAY, FindDateTime)=3 then sum(DRI.DefectQty)  end) as "3_Defect"
		   , (case when DATEPART(DAY, FindDateTime)=4 then sum(DRI.DefectQty)  end) as "4_Defect"
		   , (case when DATEPART(DAY, FindDateTime)=5 then sum(DRI.DefectQty)  end) as "5_Defect"
		   , (case when DATEPART(DAY, FindDateTime)=6 then sum(DRI.DefectQty)  end) as "6_Defect"
		   , (case when DATEPART(DAY, FindDateTime)=7 then sum(DRI.DefectQty)  end) as "7_Defect"
		   , (case when DATEPART(DAY, FindDateTime)=8 then sum(DRI.DefectQty)  end) as "8_Defect"
		   , (case when DATEPART(DAY, FindDateTime)=9 then sum(DRI.DefectQty)  end) as "9_Defect"
		   ,(case when DATEPART(DAY, FindDateTime)=10 then sum(DRI.DefectQty)  end) as "10_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=11 then sum(DRI.DefectQty)  end) as "11_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=12 then sum(DRI.DefectQty)  end) as "12_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=13 then sum(DRI.DefectQty)  end) as "13_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=14 then sum(DRI.DefectQty)  end) as "14_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=15 then sum(DRI.DefectQty)  end) as "15_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=16 then sum(DRI.DefectQty)  end) as "16_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=17 then sum(DRI.DefectQty)  end) as "17_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=18 then sum(DRI.DefectQty)  end) as "18_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=19 then sum(DRI.DefectQty)  end) as "19_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=20 then sum(DRI.DefectQty)  end) as "20_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=21 then sum(DRI.DefectQty)  end) as "21_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=22 then sum(DRI.DefectQty)  end) as "22_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=23 then sum(DRI.DefectQty)  end) as "23_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=24 then sum(DRI.DefectQty)  end) as "24_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=25 then sum(DRI.DefectQty)  end) as "25_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=26 then sum(DRI.DefectQty)  end) as "26_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=27 then sum(DRI.DefectQty)  end) as "27_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=28 then sum(DRI.DefectQty)  end) as "28_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=29 then sum(DRI.DefectQty)  end) as "29_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=30 then sum(DRI.DefectQty)  end) as "30_Defect"
		  , (case when DATEPART(DAY, FindDateTime)=31 then sum(DRI.DefectQty)  end) as "31_Defect"
		  */

		  --,DRI.FindDateTime as ProdDateTime			  
		  --,PRH.MachineCode
		  --,MM.MachineName
		  --,PRH.WorkerCode
		  --,PWI.WorkerName
		  --,CASE WHEN SI.SIExtInt01 IS NULL THEN ''
		  --        WHEN SI.SIExtInt01 = 1      THEN '검사불합격'
	      --	    WHEN SI.SIExtInt01 = 0       THEN '검사불합격이력'    END                    AS RouteInspectionResult
		 --,CONVERT(BIT,CASE WHEN ISNULL(NP.AftProdQty,0) > 0 THEN 1	ELSE 0 	END)   AS IsHasNextProd
		 --, PRH.ProdQty 
		  --, sum(PRH.ProdQty)                                   AS InputProdQty   
		  --, ISNULL(DRI.DefectQty, 0)                    AS DefectQty          -- 불량수량 		  
		  --, 'No data' as DefectQty
		  --, (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty           -- 생산수량
		  --, SIExtText07 AS MarkingLetter                                       -- 마킹문자
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
			  --LEFT OUTER JOIN NextProd                 NP	    ON NP.ControlNo = SI.ControlNo			 
			  --LEFT OUTER JOIN STB_MachineMaster  MM	    ON PRH.MachineCode = MM.MachineCode
			  --LEFT OUTER JOIN STB_ProdWorkerInfo PWI	    ON PRH.WorkerCode = PWI.WorkerCode
			  			  
	 WHERE 1=1
	   --and si.barcode='VVKL122R740606'
	   --AND SI.InputJobDate BETWEEN @FromDate AND @ToDate
	   AND ((@CompanyCode = '*') OR (DRI.CompanyCode = @CompanyCode)) -- 추가 용은재 (2020.01.23)
	   AND DRI.FindDateTime BETWEEN @FromDate AND @ToDate
	   AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
	   AND (@LineCode = '*' OR DRI.FindLineCode   = @LineCode)
	   AND (@LotNo = '*' OR SI.Barcode       = @LotNo)
	   AND (@MaterialCode = '*' OR SI.MaterialCode = @MaterialCode)
	   --AND ISNULL(NP.AftProdQty,0) > CASE WHEN @RouteCode = '%' THEN -1   
		--                                   WHEN (dbo.fnGetNextRouteCode(SI.PONo, @RouteCode) IS NULL 
			--							            OR dbo.fnGetNextRouteCode(SI.PONo, @RouteCode) = 'V-28') THEN -1
				--						   ELSE 0 END    --추가
     group by DRI.ComPanyCode,SI.MaterialCode	,MM2.MaterialName	,SI.InputLineCode	,LI.LineName ,DRI.FindRouteCode 	,RI.RouteName,DRI.FindDateTime, DRI.DefectQty
	 --ORDER BY DRI.FindDateTime, SI.Barcode, DRI.FindRouteCode
	
	 ),
	  deptrai1 as (
	 select 	 ComPanyCode
		  ,MaterialCode
		  ,MaterialName
		  ,InputLineCode
		  ,LineName
		  ,RouteCode
		  ,RouteName,

		  sum(total) as total,
		  /* sum("1") as "1" ,

		   sum("2") as "2" ,
		   sum("3") as "3" ,
		   sum("4") as "4" ,
		   sum("5") as "5" ,
		   sum("6") as "6" ,
		   sum("7") as "7" ,
		   sum("8") as "8" ,
		   sum("9") as "9" ,
		  sum("10") as "10" ,
		  sum("11") as "11" ,
		  sum("12") as "12" ,
		  sum("13") as "13" ,
		  sum("14") as "14" ,
		  sum("15") as "15" ,
		  sum("16") as "16" ,
		  sum("17") as "17" ,
		  sum("18") as "18" ,
		  sum("19") as "19" ,
		  sum("20") as "20" ,
		  sum("21") as "21" ,
		  sum("22") as "22" ,
		  sum("23") as "23" ,
		  sum("24") as "24" ,
		  sum("25") as "25" ,
		  sum("26") as "26" ,
		  sum("27") as "27" ,
		  sum("28") as "28" ,
		  sum("29") as "29" ,
		  sum("30") as "30" ,
		  sum("31") as "31" ,*/
		  
		  sum(DefectQty) as DefectQty/*,
		  sum("1_Defect"	) as  "1_Defect"	  ,
		  sum("2_Defect"	) as 	"2_Defect"	  ,
		  sum("3_Defect"	) as 	"3_Defect"	  ,
		  sum("4_Defect"	) as 	"4_Defect"	  ,
		  sum("5_Defect"	) as 	"5_Defect"	  ,
		  sum("6_Defect"	) as 	"6_Defect"	  ,
		  sum("7_Defect"	) as 	"7_Defect"	  ,
		  sum("8_Defect"	) as 	"8_Defect"	  ,
		  sum("9_Defect"	) as 	"9_Defect"	  ,
		  sum("10_Defect"	)  as	"10_Defect"	   ,
		  sum( "11_Defect"	)  as	 "11_Defect"   ,
		  sum( "12_Defect"	)  as	 "12_Defect"   ,
		  sum( "13_Defect"	)  as	 "13_Defect"   ,
		  sum( "14_Defect"	)  as	 "14_Defect"   ,
		  sum( "15_Defect"	)  as	 "15_Defect"   ,
		  sum( "16_Defect"	)  as	 "16_Defect"   ,
		  sum( "17_Defect"	)  as	 "17_Defect"   ,
		  sum( "18_Defect"	)  as	 "18_Defect"   ,
		  sum( "19_Defect"	)  as	 "19_Defect"   ,
		  sum( "20_Defect"	)  as	 "20_Defect"   ,
		  sum( "21_Defect"	)  as	 "21_Defect"   ,
		  sum( "22_Defect"	)  as	 "22_Defect"   ,
		  sum( "23_Defect"	)  as	 "23_Defect"   ,
		  sum( "24_Defect"	)  as	 "24_Defect"   ,
		  sum( "25_Defect"	)  as	 "25_Defect"   ,
		  sum( "26_Defect"	)  as	 "26_Defect"   ,
		  sum( "27_Defect"	)  as	 "27_Defect"   ,
		  sum( "28_Defect"	)  as	 "28_Defect"   ,
		  sum( "29_Defect"	)  as	 "29_Defect"   ,
		  sum( "30_Defect"	)  as	 "30_Defect"   ,
		  sum( "31_Defect"	)  as	 "31_Defect"   */
		  from deptrai
		 group by  ComPanyCode		  ,MaterialCode		  ,MaterialName		  ,InputLineCode		  ,LineName		  ,RouteCode		  ,RouteName
		 )
		  -- exec usp_VVT_ProductionResult1_get '','','VVT','2020-05-15','','','',''    
		 	 select 	 ComPanyCode
		  ,MaterialCode
		  ,MaterialName
		  ,InputLineCode
		  ,LineName
		  ,RouteCode
		  ,RouteName,

		  sum(total) as total,
		   
		(case when deptrai1.RouteCode='V-24' then 
		   (select sum("total") from deptrai where RouteCode='V-22' and MaterialCode=deptrai1.MaterialCode and InputLineCode=deptrai1.InputLineCode
		     group by  MaterialCode,InputLineCode) -  (select sum(DefectQty) from deptrai where RouteCode='V-24' and MaterialCode=deptrai1.MaterialCode and InputLineCode=deptrai1.InputLineCode
		     group by  MaterialCode,InputLineCode) 
			  when deptrai1.RouteCode='V-25' then 
		   (select sum("total")-sum(DefectQty) from deptrai where RouteCode='V-24' and MaterialCode=deptrai1.MaterialCode and InputLineCode=deptrai1.InputLineCode
		     group by  MaterialCode,InputLineCode)  -  (select sum(DefectQty) from deptrai where RouteCode='V-25' and MaterialCode=deptrai1.MaterialCode and InputLineCode=deptrai1.InputLineCode
		     group by  MaterialCode,InputLineCode) 
			  when deptrai1.RouteCode='V-27' then 
		   (select sum("total")-sum(DefectQty) from deptrai where RouteCode='V-25' and MaterialCode=deptrai1.MaterialCode and InputLineCode=deptrai1.InputLineCode
		     group by  MaterialCode,InputLineCode)  -  (select sum(DefectQty) from deptrai where RouteCode='V-27' and MaterialCode=deptrai1.MaterialCode and InputLineCode=deptrai1.InputLineCode
		     group by  MaterialCode,InputLineCode) 
			  when deptrai1.RouteCode='V-28' then 
		   (select sum("total")-sum(DefectQty) from deptrai where RouteCode='V-27' and MaterialCode=deptrai1.MaterialCode and InputLineCode=deptrai1.InputLineCode
		     group by  MaterialCode,InputLineCode)  -  (select sum(DefectQty) from deptrai where RouteCode='V-28' and MaterialCode=deptrai1.MaterialCode and InputLineCode=deptrai1.InputLineCode
		     group by  MaterialCode,InputLineCode) 
		else 
		   (select sum("total") from deptrai where RouteCode='V-22' and MaterialCode=deptrai1.MaterialCode and InputLineCode=deptrai1.InputLineCode
		     group by  MaterialCode,InputLineCode)  
		end )  as "k1",
			/*
			sum("1") as "1" ,
		   sum("2") as "2" ,
		   sum("3") as "3" ,
		   sum("4") as "4" ,
		   sum("5") as "5" ,
		   sum("6") as "6" ,
		   sum("7") as "7" ,
		   sum("8") as "8" ,
		   sum("9") as "9" ,
		  sum("10") as "10" ,
		  sum("11") as "11" ,
		  sum("12") as "12" ,
		  sum("13") as "13" ,
		  sum("14") as "14" ,
		  sum("15") as "15" ,
		  sum("16") as "16" ,
		  sum("17") as "17" ,
		  sum("18") as "18" ,
		  sum("19") as "19" ,
		  sum("20") as "20" ,
		  sum("21") as "21" ,
		  sum("22") as "22" ,
		  sum("23") as "23" ,
		  sum("24") as "24" ,
		  sum("25") as "25" ,
		  sum("26") as "26" ,
		  sum("27") as "27" ,
		  sum("28") as "28" ,
		  sum("29") as "29" ,
		  sum("30") as "30" ,
		  sum("31") as "31" ,*/
		  
		  sum(DefectQty) as DefectQty/*,
		  sum("1_Defect"	) as  "1_Defect"	  ,
		  sum("2_Defect"	) as 	"2_Defect"	  ,
		  sum("3_Defect"	) as 	"3_Defect"	  ,
		  sum("4_Defect"	) as 	"4_Defect"	  ,
		  sum("5_Defect"	) as 	"5_Defect"	  ,
		  sum("6_Defect"	) as 	"6_Defect"	  ,
		  sum("7_Defect"	) as 	"7_Defect"	  ,
		  sum("8_Defect"	) as 	"8_Defect"	  ,
		  sum("9_Defect"	) as 	"9_Defect"	  ,
		  sum("10_Defect"	)  as	"10_Defect"	   ,
		  sum( "11_Defect"	)  as	 "11_Defect"   ,
		  sum( "12_Defect"	)  as	 "12_Defect"   ,
		  sum( "13_Defect"	)  as	 "13_Defect"   ,
		  sum( "14_Defect"	)  as	 "14_Defect"   ,
		  sum( "15_Defect"	)  as	 "15_Defect"   ,
		  sum( "16_Defect"	)  as	 "16_Defect"   ,
		  sum( "17_Defect"	)  as	 "17_Defect"   ,
		  sum( "18_Defect"	)  as	 "18_Defect"   ,
		  sum( "19_Defect"	)  as	 "19_Defect"   ,
		  sum( "20_Defect"	)  as	 "20_Defect"   ,
		  sum( "21_Defect"	)  as	 "21_Defect"   ,
		  sum( "22_Defect"	)  as	 "22_Defect"   ,
		  sum( "23_Defect"	)  as	 "23_Defect"   ,
		  sum( "24_Defect"	)  as	 "24_Defect"   ,
		  sum( "25_Defect"	)  as	 "25_Defect"   ,
		  sum( "26_Defect"	)  as	 "26_Defect"   ,
		  sum( "27_Defect"	)  as	 "27_Defect"   ,
		  sum( "28_Defect"	)  as	 "28_Defect"   ,
		  sum( "29_Defect"	)  as	 "29_Defect"   ,
		  sum( "30_Defect"	)  as	 "30_Defect"   ,
		  sum( "31_Defect"	)  as	 "31_Defect"   */
		  from deptrai1
		 group by  ComPanyCode		  ,MaterialCode		  ,MaterialName		  ,InputLineCode		  ,LineName		  ,RouteCode		  ,RouteName
		 	order by MaterialCode,InputLineCode,RouteCode	
END
