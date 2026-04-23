

/* exec  usp_VVT_LotCompareStage_get  '','','VVT','2020-05-15','','','',''    */

CREATE  PROCEDURE [dbo].[usp_VVT_LotCompareStage_get]
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

	DECLARE @FromDate    VARCHAR(10) = CONVERT(VARCHAR(7), DATEADD(MONTH, -1, CONVERT(smalldatetime, @pMonth)), 120) +'-26'    
	DECLARE @ToDate      VARCHAR(10) = CONVERT(VARCHAR(7), DATEADD(MONTH,  0, CONVERT(smalldatetime, @pMonth)), 120) +'-26' 

	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN


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
	dataV22 as(
				SELECT ControlNo, RouteCode as FindRouteCode, LineCode as FindLineCode, CompanyCode,  ProdDateTime as FindDateTime--, 0 as DefectQty 
				FROM STB_ProdRouteHist histv22 where  ProdDateTime >=@FromDate and ProdDateTime < @ToDate and RouteCode='V-22'
			),
	dataV24 as(
				SELECT ControlNo, RouteCode as FindRouteCode, LineCode as FindLineCode, CompanyCode,  ProdDateTime as FindDateTime--, 0 as DefectQty 
				FROM STB_ProdRouteHist where  ProdDateTime >=@FromDate and ProdDateTime < @ToDate and RouteCode='V-24'
			),
	dataV25 as(
				SELECT ControlNo, RouteCode as FindRouteCode, LineCode as FindLineCode, CompanyCode,  ProdDateTime as FindDateTime--, 0 as DefectQty 
				FROM STB_ProdRouteHist where  ProdDateTime >=@FromDate and ProdDateTime < @ToDate and RouteCode='V-25'
			),
	dataV27 as(
				SELECT ControlNo, RouteCode as FindRouteCode, LineCode as FindLineCode, CompanyCode,  ProdDateTime as FindDateTime--, 0 as DefectQty 
				FROM STB_ProdRouteHist where  ProdDateTime >=@FromDate and ProdDateTime < @ToDate and RouteCode='V-27'
			),
	dataV28 as(
				SELECT ControlNo, RouteCode as FindRouteCode, LineCode as FindLineCode, CompanyCode,  ProdDateTime as FindDateTime--, 0 as DefectQty 
				FROM STB_ProdRouteHist where  ProdDateTime >=@FromDate and ProdDateTime < @ToDate and RouteCode='V-28'
			),
    datatong as (
	SELECT DRI.ComPanyCode
		  ,SI.ControlNo
	      --,SI.Barcode
		  ,SI.MaterialCode
		  ,MM2.MaterialName
		  ,SI.InputLineCode
		  ,LI.LineName
		  --,DRI.FindRouteCode as RouteCode
		  , (case when DRI.FindRouteCode='V-22' then DRI.FindDateTime end) as "V22-Winding-Date"	

		  , (case when DRI.FindRouteCode='V-22' then SI.Barcode  end) as "V-22-Winding-Cuon"	
		  , (case when DRI.FindRouteCode='V-24' then SI.Barcode  end) as "V-24-Curling-UonVien"	
		  , (case when DRI.FindRouteCode='V-25' then SI.Barcode  end) as "V-25-Sleeve-BocVo"	
		  , (case when DRI.FindRouteCode='V-27' then SI.Barcode  end) as "V-27-Visual-Ngoaiquan"	
		  , (case when DRI.FindRouteCode='V-28' then SI.Barcode  end) as "V-28-Packing-DongGoi"	

		  , (case when DRI.FindRouteCode='V-22' then PWI.WorkerName  end) as "V22-Worker"	
		  , (case when DRI.FindRouteCode='V-24' then PWI.WorkerName  end) as "V24-Worker"
		  , (case when DRI.FindRouteCode='V-25' then PWI.WorkerName  end) as "V25-Worker"
		  , (case when DRI.FindRouteCode='V-27' then PWI.WorkerName  end) as "V27-Worker"	
		  , (case when DRI.FindRouteCode='V-28' then PWI.WorkerName  end) as "V28-Worker"

		  , (case when DRI.FindRouteCode='V-22' then PRH.ProdQty  end) as "V22-ProdQty"	
		  , (case when DRI.FindRouteCode='V-24' then PRH.ProdQty  end) as "V24-ProdQty"
		  , (case when DRI.FindRouteCode='V-25' then PRH.ProdQty  end) as "V25-ProdQty"
		  , (case when DRI.FindRouteCode='V-27' then PRH.ProdQty  end) as "V27-ProdQty"	
		  , (case when DRI.FindRouteCode='V-28' then PRH.ProdQty  end) as "V28-ProdQty"
		  --,RI.RouteName
		  --,DRI.FindDateTime as ProdDateTime
		  --,PRH.MachineCode
		  --,MM.MachineName
		  --,PRH.WorkerCode
		  --,PWI.WorkerName
		  --,CASE WHEN SI.SIExtInt01 IS NULL THEN ''
		    --      WHEN SI.SIExtInt01 = 1      THEN '검사불합격'
			--	  WHEN SI.SIExtInt01 = 0       THEN '검사불합격이력'    END                    AS RouteInspectionResult
		 --,CONVERT(BIT,CASE WHEN ISNULL(NP.AftProdQty,0) > 0 THEN 1	ELSE 0 	END)   AS IsHasNextProd
		 --, PRH.ProdQty 
		  --, PRH.ProdQty                                   AS InputProdQty    -- 투입수량
		  --, ISNULL(DRI.DefectQty, 0)                    AS DefectQty          -- 불량수량 		  
		  --, 'No data' as DefectQty
		  --, (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty           -- 생산수량
		  --, SIExtText07 AS MarkingLetter                                       -- 마킹문자
	  FROM STB_SetInfo SI	  
			   LEFT OUTER JOIN ( 
								 SELECT ControlNo, FindRouteCode, FindLineCode, CompanyCode,  (case  when   (DATEPART(HOUR, FindDateTime)>10)     or    (DATEPART(HOUR, FindDateTime)=10 and DATEPART(MINUTE, FindDateTime)>30)     
									  then     convert(varchar(14),DATEADD(HOUR,-2,FindDateTime),120)    
									  else    convert(varchar(14),DATEADD(DAY, -1,  DATEADD(HOUR,-2,FindDateTime)),120)       
									  end )   + (case when  (DATEPART(HOUR, FindDateTime)>10)  and    (DATEPART(HOUR, FindDateTime)<23 ) then 'CA NGAY' else 'CA DEM' end) as FindDateTime --, (SELECT SUM(DefectQty) AS DefectQty FROM STB_DefectRepairInfo WHERE  controlno=dataV22.ControlNo and FindRouteCode=dataV22.FindRouteCode and FindDateTime >=@FromDate and FindDateTime < @ToDate and RepairType = 'NONE') as DefectQty 
								  from dataV22		
								  union
								  SELECT dataV24.ControlNo, dataV24.FindRouteCode, dataV24.FindLineCode, dataV24.CompanyCode, (case  when   (DATEPART(HOUR, dataV24.FindDateTime)>10)     or    (DATEPART(HOUR, dataV24.FindDateTime)=10 and DATEPART(MINUTE, dataV24.FindDateTime)>30)     
									  then     convert(varchar(14),DATEADD(HOUR,-2,dataV24.FindDateTime),120)    
									  else    convert(varchar(14),DATEADD(DAY, -1,  DATEADD(HOUR,-2,dataV24.FindDateTime)),120)       
									  end )   + (case when  (DATEPART(HOUR, dataV24.FindDateTime)>10)  and    (DATEPART(HOUR, dataV24.FindDateTime)<22 ) then 'CA NGAY' else 'CA DEM' end) as FindDateTime--, (SELECT SUM(DefectQty) AS DefectQty FROM STB_DefectRepairInfo WHERE  controlno=dataV24.ControlNo and FindRouteCode=dataV24.FindRouteCode and FindDateTime >=@FromDate and FindDateTime < @ToDate and RepairType = 'NONE') as DefectQty 
								  from dataV24,dataV22
								  where dataV24.ControlNo = dataV22.ControlNo and 	dataV24.FindDateTime >= DATEADD(ss,10,dataV22.FindDateTime)
								  union
								  SELECT dataV25.ControlNo, dataV25.FindRouteCode, dataV25.FindLineCode, dataV25.CompanyCode, (case  when   (DATEPART(HOUR, dataV25.FindDateTime)>10)     or    (DATEPART(HOUR, dataV25.FindDateTime)=10 and DATEPART(MINUTE, dataV25.FindDateTime)>30)     
									  then     convert(varchar(14),DATEADD(HOUR,-2,dataV25.FindDateTime),120)    
									  else    convert(varchar(14),DATEADD(DAY, -1,  DATEADD(HOUR,-2,dataV25.FindDateTime)),120)       
									  end )   + (case when  (DATEPART(HOUR, dataV25.FindDateTime)>10)  and    (DATEPART(HOUR, dataV25.FindDateTime)<22 ) then 'CA NGAY' else 'CA DEM' end) as FindDateTime--, (SELECT SUM(DefectQty) AS DefectQty FROM STB_DefectRepairInfo WHERE  controlno=dataV25.ControlNo and FindRouteCode=dataV25.FindRouteCode and FindDateTime >=@FromDate and FindDateTime < @ToDate and RepairType = 'NONE') as DefectQty 
								  from dataV25,dataV24
								  where dataV25.ControlNo = dataV24.ControlNo and 	dataV25.FindDateTime >= DATEADD(ss,10,dataV24.FindDateTime) 
								  	union
								  SELECT dataV27.ControlNo, dataV27.FindRouteCode, dataV27.FindLineCode, dataV27.CompanyCode, (case  when   (DATEPART(HOUR, dataV27.FindDateTime)>10)     or    (DATEPART(HOUR, dataV27.FindDateTime)=10 and DATEPART(MINUTE, dataV27.FindDateTime)>30)     
									  then     convert(varchar(14), DATEADD(HOUR,-2,dataV27.FindDateTime),120)    
									  else    convert(varchar(14),DATEADD(DAY, -1,  DATEADD(HOUR,-2,dataV27.FindDateTime)),120)       
									  end )   + (case when  (DATEPART(HOUR, dataV27.FindDateTime)>10)  and    (DATEPART(HOUR, dataV27.FindDateTime)<22 ) then 'CA NGAY' else 'CA DEM' end) as FindDateTime--, (SELECT SUM(DefectQty) AS DefectQty FROM STB_DefectRepairInfo WHERE  controlno=dataV27.ControlNo and FindRouteCode=dataV27.FindRouteCode and FindDateTime >=@FromDate and FindDateTime < @ToDate and RepairType = 'NONE') as DefectQty 
								  from dataV27,dataV25
								  where dataV27.ControlNo = dataV25.ControlNo and 	dataV27.FindDateTime >= DATEADD(ss,10,dataV25.FindDateTime) 
								  	union
								  SELECT dataV28.ControlNo, dataV28.FindRouteCode, dataV28.FindLineCode, dataV28.CompanyCode, (case  when   (DATEPART(HOUR, dataV28.FindDateTime)>10)     or    (DATEPART(HOUR, dataV28.FindDateTime)=10 and DATEPART(MINUTE, dataV28.FindDateTime)>30)     
									  then     convert(varchar(14),DATEADD(HOUR,-2,dataV28.FindDateTime),120)    
									  else    convert(varchar(14),DATEADD(DAY, -1,  DATEADD(HOUR,-2,dataV28.FindDateTime)),120)       
									  end )   + (case when  (DATEPART(HOUR, dataV28.FindDateTime)>10)  and    (DATEPART(HOUR, dataV28.FindDateTime)<22 ) then 'CA NGAY' else 'CA DEM' end) as FindDateTime--, 0 as DefectQty 
								  from dataV28,dataV27
								  where dataV28.ControlNo = dataV27.ControlNo and 	dataV28.FindDateTime >= DATEADD(ss,10,dataV27.FindDateTime) 								  
								) DRI   ON si.ControlNo = DRI.ControlNo   								 
			LEFT OUTER JOIN STB_ProdRouteHist    PRH	    ON DRI.ControlNo = PRH.ControlNo     AND PRH.RouteCode = DRI.FindRouteCode			 
			  LEFT OUTER JOIN STB_RouteInfo           RI	    ON DRI.FindRouteCode = RI.RouteCode
			  LEFT OUTER JOIN STB_MaterialMaster  MM2	    ON SI.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo              LI	    ON SI.InputLineCode = LI.LineCode
			  --LEFT OUTER JOIN NextProd                 NP	    ON NP.ControlNo = SI.ControlNo			 
			  --LEFT OUTER JOIN STB_MachineMaster  MM	    ON PRH.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	    ON PRH.WorkerCode = PWI.WorkerCode

			  
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
		  --                                 WHEN (dbo.fnGetNextRouteCode(SI.PONo, @RouteCode) IS NULL 
			--							            OR dbo.fnGetNextRouteCode(SI.PONo, @RouteCode) = 'V-28') THEN -1
			--							   ELSE 0 END    --추가

	 --ORDER BY DRI.FindDateTime, SI.Barcode, DRI.FindRouteCode
	 --group by DRI.ComPanyCode,SI.ControlNo,DRI.FindRouteCode
	 )
	 select --ComPanyCode
	 --,	 ControlNo,
	 		  MaterialCode
		  ,MaterialName
		  ,InputLineCode
		  ,LineName
	 ,min("V22-Winding-Date") as "Date-V22-Winding",
	  max("V-22-Winding-Cuon") as "V-22-Winding-Cuon",
	  max("V22-Worker") as "V22-Worker",
	  sum("V22-ProdQty") as "V22-ProdQty",

						  max("V-24-Curling-UonVien")	as "V-24-Curling-UonVien",
						  max("V24-Worker") as "V24-Worker",
						  sum("V24-ProdQty") as "V24-ProdQty",

								   max("V-25-Sleeve-BocVo"	) as "V-25-Sleeve-BocVo",
								   max("V25-Worker") as "V25-Worker",
								   sum("V25-ProdQty") as "V25-ProdQty",

								   max("V-27-Visual-Ngoaiquan") as "V-27-Visual-Ngoaiquan",
								   max("V27-Worker") as "V27-Worker",
								   sum("V27-ProdQty") as "V27-ProdQty",

								   max("V-28-Packing-DongGoi")	as "V-28-Packing-DongGoi",
								   max("V28-Worker") as "V28-Worker",
								   sum("V28-ProdQty") as "V28-ProdQty"

								  from datatong
								  group by ComPanyCode,ControlNo,MaterialCode
		  ,MaterialName
		  ,InputLineCode
		  ,LineName
END		