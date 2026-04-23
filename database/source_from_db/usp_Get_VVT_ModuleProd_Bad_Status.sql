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
-- [프로시저 실행문]      EXEC usp_GetProdBadStatus  '','','VVT','','','','','2019-12-15','2019-12-15',''
-- [프로시저 실행문]      EXEC usp_GetProdBadStatus  '','','','VNT','','ASSYLINE-13','','','2020-07-12','2020-07-13',''

-- SELECT * FROM STB_DefectRepairInfo WHERE FindLineCode = 'ASSYLINE-05' and FindJobdate Between '2019-09-01' and '2019-09-10' and DefectCode in ( '015', '082')            -- 불량코드 등록자 확인
-- SELECT * FROM STB_Setinfo where ControlNo in ( '20190903000090', '20190904000116')   -- 해당 바코드 정보 확인

--exec usp_Get_VVT_ModuleProd_Bad_Status '','',0,'VVT','','','','','2021-09-01','2021-09-30',null
CREATE PROCEDURE [dbo].[usp_Get_VVT_ModuleProd_Bad_Status]
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
	DECLARE @FromDate DATETIME                   = @pFromDate
	DECLARE @ToDate DATETIME                      = @pToDate
	DECLARE @IsOutputRoute BIT = @pIsOutputRoute





	select @FromDate   = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	select @ToDate     = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'

	
;with ViewBarcode as (
		 select  c.Barcode
		 from 
		 STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode='VVT'  and isnull(b.ProdDateTime,b.CreateDateTime)>=@FromDate 
		 and isnull(b.ProdDateTime,b.CreateDateTime)<=@ToDate and  SUBSTRING (c.Barcode, 1, 1) ='M'
	 ),
RawView as (
 	select  c.Barcode,isnull(b.RouteCode,a.FindRouteCode) RouteCode,isnull(b.RouteCode,a.FindRouteCode) as FindRouteCode,c.ControlNo,c.MaterialCode,
		InputLineCode,isnull(b.MachineCode,'')MachineCode,isnull(b.WorkerCode,'')WorkerCode,SIExtText07,SIExtInt01,DefectCode,
		isnull(max(b.ProdQty),0) as ProdQty, sum(isnull(a.DefectQty,0)) as DefectQty,  sum(isnull(a.RepairQty,0)) as RepairQty ,
		isnull(max(b.ProdDateTime),max(a.CreateDateTime)) as ProdDateTime, dateadd(second,-6,max(a.CreateDateTime)) as CreateDateTime
		from  STB_SetInfo c with(nolock) 
		 left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=c.ControlNo 
		 left outer join   STB_ProdRouteHist     b	 with(nolock)   on  c.ControlNo=b.ControlNo	 and  a.FindRouteCode = b.RouteCode
		
		 where c.Barcode in (select  Barcode  from  ViewBarcode  with(nolock) ) 
		 and    (isnull(b.ProdDateTime,a.CreateDateTime)>=@FromDate  and isnull(b.ProdDateTime,a.CreateDateTime)<=@ToDate)
		 group by c.Barcode,b.RouteCode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,DefectCode
)
,
--AlloyView as (
--select RawView.* --, 
	--(row_number() over (partition by RawView.Barcode order by RawView.RouteCode ASC) )     as Routerank 
		--, (row_number() over (partition by RawView.Barcode order by RawView.ProdDateTime ASC) )  as Timerank 	
		--, prh.ProdDateTime as maxProdDateTime
		--, ( count(prh.RouteCode))  as total
		--  from RawView
		  --join STB_ProdRouteHist  prh with(nolock) on RawView.ControlNo = prh.ControlNo --and RawView.RouteCode = prh.RouteCode
		  --group by Barcode,RawView.RouteCode, FindRouteCode,RawView.ControlNo,RawView.MaterialCode,InputLineCode,
		  --RawView.MachineCode,RawView.WorkerCode,SIExtText07,SIExtInt01,RawView.ProdQty,RawView.DefectQty,RawView.ProdDateTime--, prh.ProdDateTime
--)
X as(
		select  
		 RV.Barcode,RV.RouteCode, RV.RouteCode as FindRouteCode ,ControlNo,RV.MaterialCode,RV.InputLineCode as LineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,DefectCode,
		 ri.RouteName, 
		 MM2.MaterialName,
		 li.LineName, pwi.WorkerName,mm.MachineName,
		  RV.ProdDateTime	
		 , (case  when   (DATEPART(HOUR, ProdDateTime)>10)     or    (DATEPART(HOUR, ProdDateTime)=10 and DATEPART(MINUTE, ProdDateTime)>30)     
				then     convert(varchar(10),ProdDateTime,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  ProdDateTime),120)       
				end )    as  JobDate ,
		  max(RV.ProdQty) as ProdQty,
		  sum(RV.DefectQty - RV.RepairQty) as DefectQty, 
		  CONVERT(varchar(10),RV.ProdDateTime,120) as ProdDate,  
		  DATEPART(YEAR, ProdDateTime)  as ProdYear,
		  DATEPART(MONTH, ProdDateTime)  as ProdMonth,
		  DATEPART(DAY, ProdDateTime)  as ProdDay,
		  DATEPART(HOUR, ProdDateTime)  as ProdHour,
		  DATEPART(MINUTE, ProdDateTime)  as ProdMinute,
		  DATEPART(SECOND, ProdDateTime)  as ProdSecond,
		  substring(MM2.MaterialName,CHARINDEX('(',MM2.MaterialName)+1,CHARINDEX(')',MM2.MaterialName)-CHARINDEX('(',MM2.MaterialName)-1 ) as SizeCode
		--, (select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode ) 
		from RawView RV 
		--left outer join STB_MaterialLotInfo mli  with(nolock) on RV.barcode = mli.Lotno 
			LEFT OUTER JOIN STB_RouteInfo          RI	  with(nolock)     ON RV.RouteCode = RI.RouteCode
			LEFT OUTER JOIN STB_MaterialMaster     MM2      with(nolock)     ON RV.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo         LI	  with(nolock)    ON RV.InputLineCode = LI.LineCode			 
			  LEFT OUTER JOIN STB_MachineMaster    MM	  with(nolock)     ON RV.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	  with(nolock)     ON RV.WorkerCode = PWI.WorkerCode
		--	  outer APPLY
		--				 (SELECT distinct t1.Lotno
		--				  FROM STB_MaterialLotInfo t1  with(nolock) 
		--				  WHERE t1.Lotno=RV.Barcode and t1.CurrentQty>0
		--				 ) mli	
		--where 
		--( 
		--	(mli.Lotno is not null )  or -- RV.routecode='V-22' or 
		--	(select count(ControlNo)  from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode ) > 0 or
		--	(select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno  and routecode>=RV.routecode ) > Dateadd(second,5,RV.CreateDateTime) 
		--) 
		group by 		 RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, 		 MM2.MaterialName,		 li.LineName, pwi.WorkerName,mm.MachineName,		  RV.ProdDateTime,DefectCode
)
	,
	  Z as (
		select sum(DefectQty) as TotalErrQty
		from X WITH(NOLOCK)
	  ),
	 STB_Defect_VVT as (
	    SELECT --ROW_NUMBER() OVER(ORDER BY X.DefectQty DESC) AS ROWNUM
			  X.JobDate    AS 작업일자
			,  X.LineCode   AS  라인코드		  
			,  X.RouteCode AS 공정코드
			,  X.RouteName AS 공정명
			,  X.MaterialCode  AS 품목코드
			,  X.MaterialName  AS 품목명
			,  X.DefectCode AS  불량코드
			,  di.BasicDefectName AS 불량명 
			,  X.DefectQty AS 불량수량		
			, (X.DefectQty / (select TotalErrQty from Z) ) * 100 AS 불량률
			,  X.ControlNo                       AS ControlNo
			, X.Barcode
			--, dbo.fnGetWastePrice(X.LineCode, X.RouteCode, X.MaterialCode, X.DefectQty) AS DefectWastePrice
			--, dbo.fnGetWastePriceByMaterial(@CompanyCode
			--                              , @WorkCenterCode
			--							  , X.LineCode
			--							  , X.MaterialCode
			--							  , 'PC'
			--							  , X.RouteCode
			--							  , X.DefectQty) AS DefectWastePrice			
		from X WITH(NOLOCK)
				 --left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=x.ControlNo and a.FindRouteCode = x.RouteCode and CreateDateTime between @FromDate and @ToDate
				 left  outer join  STB_DefectInfo        di   with(nolock)  on  X.DefectCode = di.DefectCode
		    --,Z WITH(NOLOCK)
	)
,
	PricesOri as (

select 'EDVTMD-153' as model ,'0.167335353511788' as [MV-01] ,'0.175350776379432'  as [MV-02],'0.175350776379432' as [MV-03],'0.185133724381414' as [MV-04] ,'0.213940627791835' as [MV-05]  union all 
select 'RDMD00-129' ,'0.167335353511788' ,'0.175350776379432' ,'0.175350776379432','0.185133724381414' ,'0.213940627791835'  union all 
select 'ECVT54-057' ,'0.167335353511788' ,'0.175350776379432' ,'0.175350776379432','0.185133724381414' ,'0.213940627791835'  union all 
select 'ECVT54-055' ,'0.157362280511788' ,'0.165377703379432' ,'0.165377703379432','0.175160651381414' ,'0.203967554791835'  union all 
select 'EDVTMD-142' ,'0.157362280511788' ,'0.165377703379432' ,'0.165377703379432','0.175160651381414' ,'0.203967554791835'  union all 
select 'EDVTMD-161' ,'0.157362280511788' ,'0.165377703379432' ,'0.165377703379432','0.175160651381414' ,'0.203967554791835'  union all 
select 'EDVTMD-137' ,'0.157362280511788' ,'0.165377703379432' ,'0.165377703379432','0.175160651381414' ,'0.203967554791835'  union all 
select 'EDVTMD-151' ,'0.157362280511788' ,'0.165377703379432' ,'0.165377703379432','0.175160651381414' ,'0.203967554791835'  union all 
select 'EDVTMD-186' ,'0.167335353511788' ,'0.175350776379432' ,'0.175350776379432','0.185133724381414' ,'0.213940627791835'  union all 
select 'RDMD00-255' ,'0.167335353511788' ,'0.175350776379432' ,'0.175350776379432','0.185133724381414' ,'0.263940627791835'  union all 
select 'EDVTMD-152' ,'0.167335353511788' ,'0.175350776379432' ,'0.175350776379432','0.185133724381414' ,'0.213940627791835'  union all 
select 'RDMD00-237' ,'0.167335353511788' ,'0.175350776379432' ,'0.175350776379432','0.185133724381414' ,'0.213940627791835'  union all 
select 'XXX1' ,'0.157362280511788' ,'0.165377703379432' ,'0.165377703379432','0.175160651381414' ,'0.203967554791835'  union all 
select 'EDVTMD-146' ,'0.193181545227451' ,'0.204315075921183' ,'0.204315075921183','0.215358441059164' ,'0.244165344469585'  union all 
select 'ECVT54-052' ,'0.193181545227451' ,'0.204315075921183' ,'0.204315075921183','0.215358441059164' ,'0.244165344469585'  union all 
select 'ECVT54-060' ,'0.203154618227451' ,'0.214288148921183' ,'0.214288148921183','0.225331514059164' ,'0.254138417469585'  union all 
select 'EDVTMD-165' ,'0.203154618227451' ,'0.214288148921183' ,'0.214288148921183','0.225331514059164' ,'0.254138417469585'  union all 
select 'EDVTMD-175' ,'0.203154618227451' ,'0.214288148921183' ,'0.214288148921183','0.225331514059164' ,'0.254138417469585'  union all 
select 'ECVT81-002' ,'0.309476907112186' ,'0.322169491718961' ,'0.322169491718961','0.333212856856942' ,'0.362441354429683'  union all 
select 'EDVTMD-150' ,'0.203154618227451' ,'0.421593598921183' ,'0.421593598921183','0.432636964059164' ,'0.461443867469585'  union all 
select 'EDVTMD-174' ,'0.203154618227451' ,'0.421593598921183' ,'0.421593598921183','0.432636964059164' ,'0.461443867469585'  union all 
select 'RDMD00-238' ,'0.203154618227451' ,'0.421593598921183' ,'0.421593598921183','0.432636964059164' ,'0.461443867469585'  union all 
select 'RDMD00-239' ,'0.203154618227451' ,'0.421593598921183' ,'0.421593598921183','0.432636964059164' ,'0.461443867469585'  union all 
select 'EDVTMD-145' ,'0.193181545227451' ,'0.204315075921183' ,'0.204315075921183','0.215358441059164' ,'0.244165344469585'  union all 
select 'EDVTMD-187' ,'0.193181545227451' ,'0.204315075921183' ,'0.204315075921183','0.215358441059164' ,'0.244165344469585'  union all 
select 'RDMD00-256' ,'0.193181545227451' ,'0.204315075921183' ,'0.204315075921183','0.215358441059164' ,'0.294165344469585'  union all 
select 'RDMD00-266' ,'0.193181545227451' ,'0.204315075921183' ,'0.204315075921183','0.215358441059164' ,'0.294165344469585'  union all 
select 'EDVTMD-188' ,'0.193181545227451' ,'0.204315075921183' ,'0.204315075921183','0.215358441059164' ,'0.294165344469585'  union all 
select 'EDVTMD-201' ,'0.193181545227451' ,'0.204315075921183' ,'0.204315075921183','0.215358441059164' ,'0.294165344469585'  union all 
select 'EDVTMD-197' ,'0.193181545227451' ,'0.204315075921183' ,'0.204315075921183','0.215358441059164' ,'0.294165344469585'  union all 
select 'EDVTMD-199' ,'0.193181545227451' ,'0.204315075921183' ,'0.204315075921183','0.215358441059164' ,'0.294165344469585'  union all 
select 'RDMD00-248' ,'0.193181545227451' ,'0.204315075921183' ,'0.204315075921183','0.215358441059164' ,'0.294165344469585'  union all 
select 'EDVTMD-159' ,'0.203154618227451' ,'0.214288148921183' ,'0.214288148921183','0.225331514059164' ,'0.254138417469585'  union all 
select 'EDVTMD-190' ,'0.203154618227451' ,'0.214288148921183' ,'0.214288148921183','0.225331514059164' ,'0.254138417469585'  union all 
select 'EDVTMD-095' ,'0.203154618227451' ,'0.214288148921183' ,'0.214288148921183','0.225331514059164' ,'0.254138417469585'  union all 
select 'EDVTMD-182' ,'0.203154618227451' ,'0.214288148921183' ,'0.214288148921183','0.225331514059164' ,'0.254138417469585'  union all 
select 'RDMD00-203' ,'0.193181545227451' ,'0.204315075921183' ,'0.204315075921183','0.215358441059164' ,'0.294165344469585'  union all 
select 'EDVTMD-169' ,'0.309476907112186' ,'0.322169491718961' ,'0.322169491718961','0.333212856856942' ,'0.362441354429683'  union all 
select 'ECVT54-054' ,'0.202550106944095' ,'0.21056552981174' ,'0.21056552981174','0.221608894949721' ,'0.250415798360143'  union all 
select 'EDVTMD-193' ,'0.202550106944095' ,'0.21056552981174' ,'0.21056552981174','0.221608894949721' ,'0.250415798360143'  union all 
select 'RDMD00-241' ,'0.212523179944095' ,'0.42784405281174' ,'0.42784405281174','0.439739051149721' ,'0.468545954560143'  union all 
select 'ECVT60-013' ,'0.256975562583354' ,'0.265058336557109' ,'0.265058336557109','0.277175227919613' ,'0.305991752916622'  union all 
select 'ECVT54-009' ,'0.256975562583354' ,'0.265058336557109' ,'0.265058336557109','0.277175227919613' ,'0.305991752916622'  union all 
select 'ECVT54-056' ,'0.256757579612778' ,'0.264840353586533' ,'0.264840353586533','0.276957244949038' ,'0.305773769946046'  union all 
select 'EDVTMD-177' ,'0.301020094612778' ,'0.309102868586533' ,'0.309102868586533','0.321219759949038' ,'0.350036284946046'  union all 
select 'EDVTMD-184' ,'0.256975562583354' ,'0.265058336557109' ,'0.265058336557109','0.277175227919613' ,'0.305991752916622'  union all 
select 'ECVT60-011' ,'0.256757579612778' ,'0.264840353586533' ,'0.264840353586533','0.276957244949038' ,'0.305773769946046'  union all 
select 'EDVTMD-179' ,'0.256975562583354' ,'0.265058336557109' ,'0.265058336557109','0.277175227919613' ,'0.305991752916622'  union all 
select 'EDVTMD-210' ,'0.256975562583354' ,'0.265058336557109' ,'0.265058336557109','0.277175227919613' ,'0.305991752916622'  union all 
select 'EDVTMD-191' ,'0.256975562583354' ,'0.265058336557109' ,'0.265058336557109','0.277175227919613' ,'0.305991752916622'  union all 
select 'RDMD00-117' ,'0.256757579612778' ,'0.264840353586533' ,'0.264840353586533','0.276957244949038' ,'0.305773769946046'  union all 
select 'EDVTMD-181' ,'0.256757579612778' ,'0.264840353586533' ,'0.264840353586533','0.276957244949038' ,'0.305773769946046'  union all 
select 'RDMD00-217' ,'0.301020094612778' ,'0.309102868586533' ,'0.309102868586533','0.321219759949038' ,'0.350036284946046'  union all 
select 'EDVTMD-071' ,'0.301020094612778' ,'0.309102868586533' ,'0.309102868586533','0.321219759949038' ,'0.440036284946046'  union all 
select 'EDVTMD-149' ,'0.292031797496204' ,'0.306837991469959' ,'0.306837991469959','0.320013821482463' ,'0.348830346479472'  union all 
select 'ECVT54-015' ,'0.292031797496204' ,'0.306837991469959' ,'0.306837991469959','0.320013821482463' ,'0.348830346479472'  union all 
select 'EDVTMD-127' ,'0.292031797496204' ,'0.306837991469959' ,'0.306837991469959','0.320013821482463' ,'0.348830346479472'  union all 
select 'EDVTMD-163' ,'0.292031797496204' ,'0.306837991469959' ,'0.306837991469959','0.320013821482463' ,'0.348830346479472'  union all 
select 'EDVTMD-157' ,'0.328258055095604' ,'0.563816539069359' ,'0.563816539069359','0.576992369081863' ,'0.605808894078872'  union all 
select 'EDVTMD-158' ,'0.328258055095604' ,'0.563816539069359' ,'0.563816539069359','0.576992369081863' ,'0.605808894078872'  union all 
select 'EDVTMD-180' ,'0.328258055095604' ,'0.563816539069359' ,'0.563816539069359','0.576992369081863' ,'0.605808894078872'  union all 
select 'RDMD00-228' ,'0.328258055095604' ,'0.563816539069359' ,'0.563816539069359','0.576992369081863' ,'0.605808894078872'  union all 
select 'RDMD00-227' ,'0.328258055095604' ,'0.563816539069359' ,'0.563816539069359','0.576992369081863' ,'0.605808894078872'  union all 
select 'ECVT60-020' ,'0.292031797496204' ,'0.306837991469959' ,'0.306837991469959','0.320013821482463' ,'0.348830346479472'  union all 
select 'RDMD00-V02' ,'0.292031797496204' ,'0.306837991469959' ,'0.306837991469959','0.320013821482463' ,'0.348830346479472'  union all 
select 'EDVTMD-195' ,'0.292031797496204' ,'0.306837991469959' ,'0.306837991469959','0.320013821482463' ,'0.348830346479472'  union all 
select 'RDMD00-190' ,'0.292031797496204' ,'0.306837991469959' ,'0.306837991469959','0.320013821482463' ,'0.348830346479472'  union all 
select 'EDVTMD-116' ,'0.297454272288761' ,'0.312260466262516' ,'0.312260466262516','0.32543629627502' ,'0.354252821272029'  union all 
select 'EDVTMD-185' ,'0.297454272288761' ,'0.312260466262516' ,'0.312260466262516','0.32543629627502' ,'0.354252821272029'  union all 
select 'EDVTMD-148' ,'0.302200838486927' ,'0.310283612460682' ,'0.310283612460682','0.324518381123187' ,'0.35352205755034'  union all 
select 'EDVTMD-167' ,'0.287297257486927' ,'0.295380031460682' ,'0.295380031460682','0.309614800123187' ,'0.33861847655034'  union all 
select 'EDVTMD-166' ,'0.287297257486927' ,'0.295380031460682' ,'0.295380031460682','0.309614800123187' ,'0.33861847655034'  union all 
select 'ECVT54-059' ,'0.331559772486927' ,'0.339642546460682' ,'0.339642546460682','0.353877315123187' ,'0.38288099155034'  union all 
select 'EDVTMD-202' ,'0.331559772486927' ,'0.339642546460682' ,'0.339642546460682','0.353877315123187' ,'0.38288099155034'  union all 

select 'MVCE60-026' ,'0.331559772486927' ,'0.339642546460682' ,'0.339642546460682','0.353877315123187' ,'0.38288099155034'  union all 
select 'ECVT60-009' ,'0.331559772486927' ,'0.599614786460682' ,'0.599614786460682','0.613849555123187' ,'0.64285323155034'  union all 
select 'ECVT60-010' ,'0.287297257486927' ,'0.295380031460682' ,'0.295380031460682','0.309614800123187' ,'0.33861847655034'  union all 
select 'EDVTMD-194' ,'0.287297257486927' ,'0.295380031460682' ,'0.295380031460682','0.309614800123187' ,'0.33861847655034'  union all 
select 'RDMD00-121' ,'0.302200838486927' ,'0.310283612460682' ,'0.310283612460682','0.324518381123187' ,'0.35352205755034'  union all 
select 'EDVTMD-192' ,'0.302200838486927' ,'0.310283612460682' ,'0.310283612460682','0.324518381123187' ,'0.35352205755034'  union all 
select 'RDMD00-123' ,'0.302200838486927' ,'0.310283612460682' ,'0.310283612460682','0.324518381123187' ,'0.35352205755034'  union all 
select 'RDMD00-136' ,'0.98395535415995' ,'1.21279041813371' ,'1.21279041813371','1.21971851011121' ,'1.2498080675888'  union all 
select 'EDVTMD-080' ,'0.460258512741638' ,'0.468341286715394' ,'0.468341286715394','0.487447173167898' ,'0.517023887465932'  union all 
select 'EDVTMD-139' ,'0.460258512741638' ,'0.468341286715394' ,'0.468341286715394','0.487447173167898' ,'0.517023887465932'  union all 
select 'EDVTMD-164' ,'0.480235010587356' ,'0.488317784561112' ,'0.488317784561112','0.502219183648616' ,'0.531909753245625'  union all 
select 'ECVT54-061' ,'0.514166422112355' ,'0.525367303912197' ,'0.525367303912197','0.540748751855702' ,'0.570439321452711'  union all 
select 'EDVTMD-173' ,'0.514166422112355' ,'0.525367303912197' ,'0.525367303912197','0.540748751855702' ,'0.570439321452711'  union all 
select 'ECVT60-008' ,'0.514166422112355' ,'0.525367303912197' ,'0.525367303912197','0.540748751855702' ,'0.570439321452711'  union all 
select 'ECVT60-012' ,'0.514166422112355' ,'0.525367303912197' ,'0.525367303912197','0.540748751855702' ,'0.570439321452711'  union all 
select 'ECVT60-069' ,'0.514166422112355' ,'0.525367303912197' ,'0.525367303912197','0.540748751855702' ,'0.570439321452711'  union all 
select 'EDVTMD-198' ,'0.514166422112355' ,'0.525367303912197' ,'0.525367303912197','0.540748751855702' ,'0.570439321452711'  union all 
select 'MVCC60-069' ,'0.514166422112355' ,'0.525367303912197' ,'0.525367303912197','0.540748751855702' ,'0.570439321452711'  union all 
select 'EDVTMD-156' ,'0.476067042112355' ,'0.694573373912197' ,'0.694573373912197','0.709954821855702' ,'0.739645391452711'  union all 
select 'EDVTMD-155' ,'0.476067042112355' ,'0.694573373912197' ,'0.694573373912197','0.709954821855702' ,'0.739645391452711'  union all 
select 'EDVTMD-118' ,'1.47136127864004' ,'1.47937670150768' ,'1.47937670150768','1.49812734710566' ,'1.5286669115784'  union all 
select 'RDMD00-250' ,'1.47136127864004' ,'1.47937670150768' ,'1.47937670150768','1.49812734710566' ,'1.5286669115784'  union all 
select 'ECVT54-033' ,'1.32775013610503' ,'2.68806943497267' ,'2.68806943497267','2.71800785145065' ,'2.75121583413644'  union all 
select 'EDVTMD-183' ,'1.64193389292855' ,'3.67571576179619' ,'3.67571576179619','3.70565417827417' ,'3.74182363258822'  union all 
select 'EDVTMD-160' ,'2.10067117975207' ,'4.11540335861972' ,'4.11540335861972','4.1222737210777' ,'4.1606334025374'  union all 
select 'EDVTMD-144' ,'1.88833828493841' ,'2.54516373780606' ,'2.54516373780606','2.57979173973404' ,'2.61652675709519'  union all 
select 'EDVTMD-082' ,'20.1098012346994' ,'23.4404087789331' ,'23.4404087789331','27.6943990897671' ,'27.794602647017' 

)
,Prices11 as(
select model, 
cast([MV-01] as float) as [MV-01],
cast([MV-02] as float) as [MV-02],
cast([MV-03] as float) as [MV-03],
cast([MV-04] as float) as [MV-04],
cast([MV-05] as float) as [MV-05]
from PricesOri
)
,Prices as (
select * from Prices11
unpivot (ProcessUnitPriceEA  for routecode in ([MV-01],[MV-02],[MV-03],[MV-04],[MV-05]) ) unpvt
)
	 SELECT  /* dbo.fnGetLocalTime(*/A.작업일자--,@pUtcOffset) AS 작업일자
				,A.라인코드
				,A.공정코드
				,A.공정명
				,A.품목코드
				,A.품목명
				,A.불량코드
				,A.불량명
				--,A.불량내용
				,A.불량수량
				,A.불량률
				--,SUM(B.불량률) AS 누적불량률
				,A.ControlNo
				,A.Barcode as LotNo
				, ISNULL(A.불량수량, 0) * ISNULL(vwup.ProcessUnitPriceEA,0)  as     DefectWastePrice
	    FROM STB_Defect_VVT A WITH(NOLOCK)
		 left outer join Prices vwup on vwup.model = A.품목코드 and vwup.routecode=A.공정코드

--outer apply (
--select model, convert(numeric(38,15),isnull(max(val),0) ) as ProcessUnitPriceEA
--from Prices
--where A.품목코드 = model and 공정코드=routecode and routecode<>'MV-05' 
--group by model
--)  vwup

	   --          INNER JOIN STB_Defect_VVT B WITH(NOLOCK)  ON B.ROWNUM <= A.ROWNUM
	   --    GROUP BY A.작업일자
	   --            , A.라인코드 
				--   , A.공정코드
				--   , A.공정명 
				--   , A.품목코드
			 --      , A.품목명
				--   , A.불량코드
				--   , A.불량명
				--   , A.불량수량
				--   , A.불량률
				--   , A.ControlNo
				--   , A.DefectWastePrice
				--   ,a.Barcode
	   --ORDER BY SUM(B.불량률)
	   ORDER BY ISNULL(A.불량수량, 0) *   convert(numeric(38,15), ISNULL(vwup.ProcessUnitPriceEA,0) )  desc
	   --       EXEC usp_Get_VVT_Prod_Bad_Status  '','',420,'VVT','','','','','2020-09-12','2020-09-18',''

  



----select*from   STB_DefectRepairInfo 
----where controlno =(select controlno from STB_SetInfo where Barcode='VVLM303R036703')

----select
----sum(DefectQty)
----from
----STB_ProdRouteHist a 
----left outer join STB_DefectRepairInfo b on a.ControlNo = b.ControlNo
----where a.CreateDateTime > '2021-04-30 10:30:00' and a.CreateDateTime < '2021-05-01 10:30:00' and a.RouteCode like 'V%'
   

END