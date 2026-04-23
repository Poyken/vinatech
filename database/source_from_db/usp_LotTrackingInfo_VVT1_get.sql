

/* exec usp_LotTrackingInfo_VVT1_get '','','VVT','2020-03-09','2020-03-16','','','',''    */

CREATE  PROCEDURE [dbo].[usp_LotTrackingInfo_VVT1_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(30) = NULL
AS
	--DECLARE @FromDate DATETIME = @pFromDate
	--DECLARE @ToDate DATETIME = @pToDate
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    

	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN

	SET NOCOUNT ON;

	; with tung as (
		 select  c.Barcode--,b.RouteCode,RouteCode as FindRouteCode,min(b.ProdQty) as ProdQty,0 as DefectQty,max(ProdDateTime) as ProdDateTime 
		 from 
		 STB_SetInfo c
		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode='VVT'  and b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
		 ----group by c.Barcode,b.RouteCode--,(ProdDateTime)
		 ----order by a.FindRouteCode 
		 --union
		 --select  c.Barcode--, FindRouteCode as RouteCode,a.FindRouteCode,0 as ProdQty,sum(a.DefectQty) as DefectQty,max(FindDateTime) as ProdDateTime 
		 --from 
		 --STB_SetInfo c
		 --full outer join  STB_DefectRepairInfo a on  a.ControlNo=c.ControlNo
		 --where  (a.CompanyCode='VVT'  and a.FindDateTime>'2020-07-01' )
		 ----group by c.Barcode,a.FindRouteCode--,(FindDateTime)
		 ----order by a.FindRouteCode 
	 ),
	 tungfinished as (
	  	 select  c.Barcode,count(b.RouteCode) as totalcount
		 from 
		 STB_SetInfo c
		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
		 where  c.Barcode in (select Barcode from tung)
		 group by c.Barcode
	 ),
	 tungfinished2 as (		
		 select  c.Barcode,b.RouteCode	, (row_number() over (partition by c.Barcode order by b.Routecode ASC)-tungfinished.totalcount )	  as ProdQtyFinishYn 	 
		 from 
		 STB_SetInfo c
		 left outer join tungfinished on tungfinished.Barcode=c.Barcode
		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
		 where  c.Barcode in (select Barcode from tung)
		 and  b.CreateUserID not in ('test_worker','assy_packing' )
		 --group by c.Barcode,b.RouteCode--,tungfinished.totalcount	 
	 ),
	  tung0 as (
	 	select  c.Barcode,b.RouteCode,RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
		min(b.ProdQty) as ProdQty,0 as DefectQty,max(ProdDateTime) as ProdDateTime 
		from  STB_SetInfo c
		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
		 where c.Barcode in (select Barcode from tung)
		 and  b.CreateUserID not in ('test_worker','assy_packing' )
		 group by c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01
		 --order by a.FindRouteCode 
		 union
		 select  c.Barcode, FindRouteCode as RouteCode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,'' as MachineCode,'' as WorkerCode,SIExtText07,SIExtInt01,
		 0 as ProdQty,sum(a.DefectQty) as DefectQty,max(FindDateTime) as ProdDateTime 
		 from  STB_SetInfo c
		 full outer join  STB_DefectRepairInfo a on  a.ControlNo=c.ControlNo
		 where   c.Barcode in (select Barcode from tung)
		 and  a.CreateUserID not in ('test_worker','assy_packing' )
		 group by c.Barcode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,/*c.MachineCode,c.WorkerCode,*/SIExtText07,SIExtInt01
		 --order by a.FindRouteCode 
	 ),
	 tung11 as (
	 select Barcode,RouteCode,FindRouteCode,max(ControlNo) as ControlNo,max(MaterialCode) as MaterialCode,max(InputLineCode) as InputLineCode,max(MachineCode) as MachineCode,
	 max(WorkerCode) as WorkerCode,max(SIExtText07) as SIExtText07,max(SIExtInt01) as SIExtInt01,sum(ProdQty)as ProdQty,sum(DefectQty) as DefectQty,
	 /*sum(ProdQty)-sum(DefectQty) as soluongOut,*/max(ProdDateTime) as ProdDateTime
	 from tung0
		group by Barcode,RouteCode,FindRouteCode--,ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01
	 --	order by RouteCode
	),
	tung1 as (
	select 
	tung11.*, isnull(ProdQtyFinishYn,0) as ProdQtyFinishYn
	 from tung11
	 left outer join tungfinished2 
	 on tung11.Barcode = tungfinished2.Barcode and tung11.RouteCode = tungfinished2.RouteCode	 
	 ),
	tung22 as (
	select *
	from tung1 where RouteCode='V-22'
	),
	tung23 as (
	select *
	from tung1 where RouteCode='V-23'
	)
	,
	tung24 as (
	select *
	from tung1 where RouteCode='V-24'
	)
	,
	tung25 as (
	select *
	from tung1 where RouteCode='V-25'
	)
	,
	tung27 as (
	select *
	from tung1 where RouteCode='V-27'
	)
	,
	tung28 as (
	select *
	from tung1 where RouteCode='V-28'
	)
	,
	tung40 as (
	select *
	from tung1 where RouteCode='V-40'
	),
	tlast as (
	select *from tung22 --where  ProdDateTime>'2020-07-01'
	union
	select tung23.* from tung23--,tung22  where tung23.Barcode = tung22.Barcode --and ( tung23.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) )
	union  																	
	select tung40.* from tung40--,tung22  where tung40.Barcode = tung22.Barcode --and ( tung40.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) )
	union									 								
	select tung24.* from tung24,tung22  where tung24.Barcode = tung22.Barcode and ( tung24.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) or tung24.ProdQtyFinishYn<0)
	union  									  									
	select tung25.* from tung25,tung24  where tung25.Barcode = tung24.Barcode and ( tung25.ProdDateTime >= DATEADD(ss,5,tung24.ProdDateTime) or tung25.ProdQtyFinishYn<0)
	union  									 									
	select tung27.* from tung27,tung25  where tung27.Barcode = tung25.Barcode and ( tung27.ProdDateTime >= DATEADD(ss,5,tung25.ProdDateTime) or tung27.ProdQtyFinishYn<0)
	union  									 									
	select tung28.* from tung28,tung27  where tung28.Barcode = tung27.Barcode and ( tung28.ProdDateTime >= DATEADD(ss,5,tung27.ProdDateTime) or tung28.ProdQtyFinishYn<0)
	),
	last2 as (
	select Barcode,(RouteCode),(FindRouteCode),ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01, ProdQty, DefectQty,/*soluongOut,*/ 
	CONVERT(varchar(19),ProdDateTime,120) as ProdDateTime
	from tlast
	--order by ProdDateTime
	),
	DRI as (
	select * from last2
	where  ProdDateTime>=@FromDate  and ProdDateTime<@ToDate
	)
	select
		   'VVT'   AS 사업장
		  ,DRI.ControlNo
	      ,DRI.Barcode
		  ,DRI.MaterialCode
		  ,MM2.MaterialName
		  ,DRI.InputLineCode
		  ,LI.LineName
		  ,DRI.RouteCode as RouteCode
		  ,RI.RouteName
		  ,convert(datetime,DRI.ProdDateTime,120) as ProdDateTime
		  ,DRI.MachineCode
		  ,MM.MachineName
		  ,DRI.WorkerCode
		  ,PWI.WorkerName
		  ,CASE WHEN DRI.SIExtInt01 IS NULL THEN ''
		          WHEN DRI.SIExtInt01 = 1      THEN '검사불합격'
				  WHEN DRI.SIExtInt01 = 0       THEN '검사불합격이력'    END                    AS RouteInspectionResult
		  --,CONVERT(BIT,CASE WHEN ISNULL(DRI.AftProdQty,0) > 0 THEN 1	ELSE 0 	END)   AS IsHasNextProd*/
		  , DRI.ProdQty                                   AS InputProdQty    -- 투입수량
		  , ISNULL(DRI.DefectQty, 0)                    AS DefectQty          -- 불량수량 		  
		  , (DRI.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty           -- 생산수량		  
		  , SIExtText07 AS MarkingLetter   
	from DRI 
			LEFT OUTER JOIN STB_RouteInfo          RI	    ON DRI.FindRouteCode = RI.RouteCode
			  LEFT OUTER JOIN STB_MaterialMaster   MM2	    ON DRI.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo         LI	    ON DRI.InputLineCode = LI.LineCode			 
			  LEFT OUTER JOIN STB_MachineMaster    MM	    ON DRI.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	    ON DRI.WorkerCode = PWI.WorkerCode
			    
	 where 1=1
	 	   AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
	   AND (@LineCode = '*' OR DRI.InputLineCode   = @LineCode)
	   AND (@LotNo = '*' OR DRI.Barcode       = @LotNo)
	   --AND (@MaterialCode = '*' OR DRI.MaterialCode = @MaterialCode)

END





