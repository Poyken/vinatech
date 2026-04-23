
--       exec  [dbo].[usp_ProdRouteVVTForRouteStockQty_get] '','','VVT','','2024-11-08'
CREATE PROC [dbo].[usp_ProdRouteVVTForRouteStockQty_get]
				@pProcessUserID VARCHAR(20) 
			   ,@pProcessLanguage VARCHAR(20)
			   ,@pCompanyCode VARCHAR(20) = NULL
			   ,@pMaterialCode VARCHAR(20) = NULL
			   ,@pLineCode VARCHAR(20) = NULL
			   ,@ponDate VARCHAR(10) = null
AS
BEGIN

	SET NOCOUNT ON;

	Declare @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
	Declare @MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
	Declare @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '*' ELSE @pLineCode END

	declare @datelimit  VARCHAR(19)='2020-07-01 10:29:59'


	--if(@pProcessUserID='nguyentung') begin
		--raiserror( @pCompanyCode,16,1)
		--return
	--end
	if(@ponDate is not null and @ponDate<>''  ) begin
		declare @onDate date = CONVERT(date,@ponDate,120)
		select @ponDate = CONVERT(varchar(10),@onDate,120)

		 if(@ponDate<>CONVERT(varchar(10),getdate(),120)) begin

			select*from stb_VietnamSemiInventory
			where id >=17835 and convert(varchar(10),DateCapture,120)=@ponDate and IsProdFinish=0 
			return;

		 end
	end



	Declare @RouteBasicTable TABLE (
		RouteCode VARCHAR(20)
	   ,ControlNo VARCHAR(20)
	   ,RouteIndex INT
	);

	Declare @QueryString VARCHAR(MAX)
	Declare @RouteString VARCHAR(MAX) = ''

	;WITH WipRoutingInfo AS (
	SELECT BRD.RouteIndex
		  ,/*case when BRD.RouteCode='V-24' then 'V-22' 
				when BRD.RouteCode='V-25' then 'V-24' 
				when BRD.RouteCode='V-27' then 'V-25' 
				when BRD.RouteCode='V-28' then 'V-27' 
				else BRD.RouteCode end  as*/ BRD.RouteCode
		  ,RI.RouteName
	  FROM STB_BasicRoutingInfo BRI with(nolock) 
	  LEFT OUTER JOIN STB_BasicRoutingDetail BRD	 with(nolock) 	ON BRI.BasicRoutingCode = BRD.BasicRoutingCode	   AND BRD.CompanyCode = @CompanyCode
	  LEFT OUTER JOIN STB_RouteInfo RI		 with(nolock) ON RI.RouteCode = BRD.RouteCode
	 WHERE BRI.BasicRoutingCode = 'WipRouting'
	) 
	INSERT INTO @RouteBasicTable
		SELECT WRI.RouteCode, PRH.ControlNo, WRI.RouteIndex
		  FROM WipRoutingInfo WRI with(nolock) 
		  LEFT OUTER JOIN STB_ProdRouteHist PRH	 with(nolock) ON 1=1
		  LEFT OUTER JOIN STB_SetInfo SI 	 with(nolock) 		    ON PRH.ControlNo = SI.ControlNo
		 GROUP BY WRI.RouteCode, PRH.ControlNo, WRI.RouteIndex
	
		 
;with LotInProduction as(
		SELECT SI.Barcode
		  FROM STB_SetInfo SI with(nolock) 
		  LEFT OUTER JOIN STB_MaterialQcInfo MQI	 with(nolock) 		ON SI.LotNumber = MQI.MaterialQcNo		   AND MQI.InspectionDocType = 'OQC'
		  LEFT OUTER JOIN STB_ProdRouteHist PRH	 with(nolock) 		ON SI.ControlNo = PRH.ControlNo		   AND PRH.RouteCode   like 'V-2%'
		 WHERE SI.LotNumber IS NOT NULL
		   and SI.IsProdFinish = CONVERT(BIT, 0)
		   AND SI.IsLoss =  CONVERT(BIT, 0)
		   and PRH.ProdDateTime>@datelimit
		   except
	      select  lotno  as Barcode
		  from STB_VN_FINISHGOODS with(nolock) 
		  where StatusSystem=N'Nhập' and Statusout is NULL
)
	SELECT *
	  INTO #WipData
	  FROM (
		SELECT SI.Barcode
		      ,SI.InputLineCode
			  ,LI.LineName
			  ,SI.MaterialCode
			  ,MM.MaterialName
			  ,case when PRH.RouteCode='V-24' then 'V-22' 
				when PRH.RouteCode='V-25' then 'V-24' 
				when PRH.RouteCode='V-27' and DATEADD(SECOND,-3,PRH.ProdDateTime)<= PRH.CreateDateTime
											and DATEADD(SECOND,3,PRH.ProdDateTime)>= PRH.CreateDateTime
											  then 'V-25' 					
				else PRH.RouteCode end  as RouteCode
			  ,CASE WHEN LPRH.RouteCode IS NULL THEN 0
					   WHEN LPRH.RouteCode like 'V-2%' AND SI.LotNumber IS NULL THEN PRH.ProdQty
					   WHEN LPRH.RouteCode like 'V-2%' AND SI.LotNumber IS NOT NULL THEN 0					   
					ELSE PRH.ProdQty END AS ProdQty
			  ,LPRH.ProdDateTime
			  ,NULL AS DecisionResult
			  , SI.IsProdFinish        --추가
			  , SI.IsLoss               --추가
			   , SI.Remark
		  FROM @RouteBasicTable RBT 
		  LEFT OUTER JOIN STB_ProdRouteHist PRH		 with(nolock) 	ON RBT.ControlNo = PRH.ControlNo		   AND RBT.RouteCode = PRH.RouteCode		   AND PRH.RouteCode <> (SELECT RouteCode 
																																																								   FROM STB_BasicRoutingDetail  with(nolock) 	
																																																								  WHERE CompanyCode = @CompanyCode AND BasicRoutingCode = 'WipRouting'
																																																									AND IsOutputRoute = CONVERT(BIT, 1)
																																																									)
		  LEFT OUTER JOIN (SELECT ControlNo
											 ,MAX(RouteCode) AS RouteCode
											 ,MAX(ProdDateTime) AS ProdDateTime
									 FROM STB_ProdRouteHist		 with(nolock) 					  
									GROUP BY ControlNo
								  ) LPRH			ON PRH.ControlNo = LPRH.ControlNo		   AND PRH.RouteCode = LPRH.RouteCode
		   LEFT OUTER JOIN STB_SetInfo SI	 with(nolock) 		ON SI.ControlNo = PRH.ControlNo
		   LEFT OUTER JOIN STB_LineInfo LI	 with(nolock) 	     ON SI.InputLineCode = LI.LineCode
		   LEFT OUTER JOIN STB_MaterialMaster MM with(nolock) 		     ON MM.MaterialCode = SI.MaterialCode
		 WHERE RBT.ControlNo IN (SELECT ControlNo 
											   FROM STB_SetInfo  with(nolock) 
											  WHERE IsProdFinish = CONVERT(BIT, 0))
		   AND RBT.ControlNo IN (SELECT ControlNo 
											   FROM STB_SetInfo  with(nolock) 
											  WHERE InputLineCode IN (SELECT LineCode 
																		FROM STB_LineInfo  with(nolock) 
																	   WHERE CompanyCode = @CompanyCode))
			and PRH.ProdDateTime>@datelimit
		UNION ALL

		 -- 제품검사 수량
		SELECT SI.Barcode
		      ,SI.InputLineCode
			  ,LI.LineName
			  ,SI.MaterialCode
			  ,MM.MaterialName
			  ,CASE WHEN MQI.DecisionResult <>'Pass' THEN 'V-99'
					when SI.IsProdFinish = CONVERT(BIT, 1) then 'V-28'
					when PRH.RouteCode='V-27' then 'V-27' 
					--when PRH.RouteCode='V-25' then 'V-25' 
					--when PRH.RouteCode='V-24' then 'V-23' 
					--when PRH.RouteCode='V-23' then 'V-22' 
					END
			  ,PRH.ProdQty
			  ,MQI.DecisionDateTime
			  ,MQI.DecisionResult
			 , SI.IsProdFinish        --추가
			  , SI.IsLoss               --추가
			   , SI.Remark
		  FROM STB_SetInfo SI with(nolock) 
		  LEFT OUTER JOIN STB_MaterialQcInfo MQI	 with(nolock) 		ON SI.LotNumber = MQI.MaterialQcNo		   AND MQI.InspectionDocType = 'OQC'
		  LEFT OUTER JOIN STB_ProdRouteHist PRH		 with(nolock) 	ON SI.ControlNo = PRH.ControlNo		   AND PRH.RouteCode  in ('V-27','V-28','V-99')
		  LEFT OUTER JOIN STB_LineInfo LI		    with(nolock)   ON SI.InputLineCode = LI.LineCode
		   LEFT OUTER JOIN STB_MaterialMaster MM	 with(nolock) 	     ON MM.MaterialCode = SI.MaterialCode
		 WHERE SI.InputLineCode IN (SELECT LineCode FROM STB_LineInfo with(nolock)  WHERE CompanyCode = @CompanyCode)
		 and SI.Barcode in (select Barcode from LotInProduction with(nolock) )
		   --AND SI.LotNumber IS NOT NULL
		   AND (SI.IsProdFinish = CONVERT(BIT, 0) and PRH.RouteCode<>'V-28')
		   --and PRH.ProdDateTime>@datelimit	                   VVKR103R038705    VVKR303R038717	   
	) A


	-- 최종
	SELECT WD.MaterialCode
			  ,WD.MaterialName
			  ,WD.InputLineCode
			  ,WD.LineName
			  ,WD.Barcode
			  ,RI.RouteType
			  ,WD.ProdQty
			  ,IsNull(WD.IsProdFinish, 0)  AS IsProdFinish  --추가			 
			  ,IsNull(WD.IsLoss, 0) AS   IsLoss          --추가
			  ,WD.Remark
	  INTO #LastWipData
	  FROM #WipData WD
	  LEFT OUTER JOIN STB_RouteInfo RI	  with(nolock)    ON WD.RouteCode = RI.RouteCode
	 WHERE (@MaterialCode = '*' OR WD.MaterialCode = @MaterialCode)
	   AND (@LineCode = '*' OR WD.InputLineCode = @LineCode)
	   AND WD.MaterialCode IS NOT NULL
	   AND WD.InputLineCode IS NOT NULL
	   AND WD.IsLoss =  CONVERT(BIT, 0)
	   -- #200627 Start
	   --AND WD.Barcode NOT IN (SELECT Barcode 
				--						FROM STB_SetInfo  with(nolock) 
				--						   WHERE ControlNo IN (SELECT ControlNo 
				--												 FROM STB_ProdRouteHist  with(nolock) 
				--												WHERE RouteCode IN (SELECT RouteCode 
				--																	  FROM STB_BasicRoutingDetail  with(nolock) 
				--																	 WHERE CompanyCode = @CompanyCode 
				--																	   AND BasicRoutingCode = 'WipRouting'
				--																	   AND IsOutputRoute = CONVERT(BIT, 1)
				--												)
				--								  )
				--			 )
		-- #200627 End

	 SELECT @RouteString = @RouteString + '[' + RI.RouteType + '],'
	  FROM                         STB_BasicRoutingInfo BRI with(nolock) 
			   LEFT OUTER JOIN STB_BasicRoutingDetail BRD	 with(nolock) 	ON BRI.BasicRoutingCode = BRD.BasicRoutingCode	   AND BRD.CompanyCode = @CompanyCode
			   LEFT OUTER JOIN STB_RouteInfo RI			 with(nolock) 			ON RI.RouteCode = BRD.RouteCode
	 WHERE BRI.BasicRoutingCode = 'WipRouting'
	 ORDER BY BRD.RouteIndex


	SET @RouteString = LEFT(@RouteString, LEN(@RouteString) - 1)

	SET @QueryString = 'SELECT * FROM #LastWipData PIVOT (SUM(ProdQty) FOR RouteType IN (' + @RouteString +')) AS PVT'+
	'  union	
		select 
		mli.MaterialCode
		, mm.MaterialName
		, si.InputLineCode
		, li.LineDesc as Linename
		, si.Barcode
		, si.IsProdFinish
		, si.IsLoss
		, si.Remark
		,0 as "Route-22"
		,0 as "Route-23"
		,0 as "Route-24"
		,0 as "Route-25"
		,0 as "Route-26"
		,0 as "Route-27"
		,mli.CurrentQty as "Route-99"
		,0 as "Route-28"
		from STB_MaterialLotInfo  mli 
		join STB_SetInfo si on mli.LotNo=si.Barcode
		join  STB_MaterialMaster  mm on mli.MaterialCode=mm.MaterialCode
		join STB_LineInfo li on si.InputLineCode=li.LineCode 
		where mli.MaterialWarehouseCode like ''OQC%'' and mli.CompanyCode=''VVT'' '
					

	if(@pProcessUserID='autojob2020') begin
		insert into stb_vietnamsemiinventory(MaterialCode,MaterialName,InputLineCode,Linename,Barcode,IsProdFinish,IsLoss,Remark,[Route-22],[Route-23],[Route-24],[Route-25],[Route-26],[Route-27],[Route-99],[Route-28])
		EXEC (@QueryString)	
	end
	else begin
		EXEC (@QueryString)
	end


	DROP TABLE #WipData
	DROP TABLE #LastWipData

END


--update A
--set a.IsProdFinish = b.IsProdFinish
--from
--stb_vietnamsemiinventory A join stb_setinfo b 
--on a.barcode=b.barcode



--select id from stb_vietnamsemiinventory where id<17835 and exists
--(
--select barcode,datecapture from stb_vietnamsemiinventory where id >=17835
--)

--select*from STB_SavePackingTime_VVT
---where lotno='VVKS163R033503' and PackQty=0
--and id<>'32329' and id<>''

-- dfdfg
-- MaterialCode	MaterialName	InputLineCode	LineName	Barcode	IsProdFinish	IsLoss	Remark	Route-22	Route-23	Route-24	Route-25	Route-26	Route-27	Route-99	Route-28
-- ECVT27-018	HY-CAP VEC2R7107QG-L (2245)	VVM-09	Manual Line #9(2245)	VVKS142R710702	0	0	NULL	292.00000	NULL	NULL	NULL	NULL	NULL	NULL	NULL



--ALTER TABLE STB_SetInfo ADD Remark NVarchar(Max)
--select * from STB_SetInfo				
		 --  and PRH.ProdDateTime>'2020-08-01 10:29:59'

		 --       exec  [dbo].[usp_ProdRouteVVTForRouteStockQty_get] 'autojob2020','','VVT','',''