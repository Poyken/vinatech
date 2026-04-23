
-- =============================================
-- Author: nguyentung@vina.co.kr
-- Create date: 2021-04
-- Browsable : true
-- Group :  [B802] for Vietnam Electrode report Screen
-- Description:	
-- =============================================         usp_Vietnam_ElectrodeProdRouteHist_get '','','2023-09-01','2023-09-07','','VVT',''

CREATE PROCEDURE [dbo].[usp_Vietnam_ElectrodeProdRouteHist_get]
						@pProcessUserID VARCHAR(20), 
						@pProcessLanguage VARCHAR(20), 
						@pFromDate DATE, 
						@pToDate DATE,					
						@pElectrodeRouteName VARCHAR(20) = NULL, 
						@pCompanyCode VARCHAR(20) = NULL,                   -- 사업장 코드 추가 (2020.10.15),
						@pRnD VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(30) = NULL  --update here
AS 

BEGIN 

	Declare @FromDate               Datetime = convert(datetime, convert(varchar(10),@pFromDate,120)+' 10:00:00' ,120)
			 , @ToDate                   Datetime = convert(datetime, convert(varchar(10),Dateadd(Day,1,@pToDate),120)+' 10:00:00' ,120)

			 , @ElectrodeRouteName  VARCHAR(20) = CASE WHEN ISNULL(@pElectrodeRouteName, '') = '' THEN '*' ELSE @pElectrodeRouteName END
	  --    , @ElectrodeRouteGroup VARCHAR(20) = CASE WHEN ISNULL(@pElectrodeRouteGroup, '') = '' THEN '*' ELSE @pElectrodeRouteGroup END
			 , @CompanyCode         VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END

	IF @FromDate = '1900-01-01' OR @ToDate = '1900-01-01' BEGIN
		raiserror('Vui long chon lai ngay thang',16,1)
		return;
	END

	
update STB_ElectrodeWasteInfoNew
set CompanyCode='VVT',WorkCenterCode='VVT_F1'
where DefectCode like 'V-%' and CompanyCode='VNT' and CreateDateTime>'2022-04-01'
and barcode like 'VV%'

	
--;with 
--eweight as (
--select 'CEP85-120' as model, '0.06' as valweight union all 
--select 'CEP85-120F' as model, '0.06' as valweight union all 
--select 'CEP85-200' as model, '0.084' as valweight union all 
--select 'CEP85-200F' as model, '0.084' as valweight union all 
--select 'YP85-116' as model, '0.059' as valweight union all 
--select 'YP85-116F' as model, '0.059' as valweight union all 
--select 'YP85-200' as model, '0.084' as valweight union all 
--select 'YP85-200F' as model, '0.084' as valweight union all 
--select 'CEP85 120' as model, '0.06' as valweight union all 
--select 'CEP85 120F' as model, '0.06' as valweight union all 
--select 'CEP85 200' as model, '0.084' as valweight union all 
--select 'CEP85 200F' as model, '0.084' as valweight union all 
--select 'YP85 116' as model, '0.059' as valweight union all 
--select 'YP85 116F' as model, '0.059' as valweight union all 
--select 'YP85 200' as model, '0.084' as valweight union all 
--select 'YP85 200F' as model, '0.084' as valweight union all

--select 'CEP-120' as model, '0.06' as valweight union all 
--select 'CEP-120F' as model, '0.06' as valweight union all 
--select 'CEP-200' as model, '0.084' as valweight union all 
--select 'CEP-200F' as model, '0.084' as valweight union all 
--select 'YP-116' as model, '0.059' as valweight union all 
--select 'YP-116F' as model, '0.059' as valweight union all 
--select 'YP-200' as model, '0.084' as valweight union all 
--select 'YP-200F' as model, '0.084' as valweight union all 
--select 'CEP 120' as model, '0.06' as valweight union all 
--select 'CEP 120F' as model, '0.06' as valweight union all 
--select 'Coatingroll(85%)' as model, '0.06' as valweight union all 
--select 'CEP 200' as model, '0.084' as valweight union all 
--select 'CEP 200F' as model, '0.084' as valweight union all 
--select 'roll(85%)-SE' as model, '0.084' as valweight union all 
--select 'YP 116' as model, '0.059' as valweight union all 
--select 'YP 116F' as model, '0.059' as valweight union all 
--select 'YP 200' as model, '0.084' as valweight union all 
--select 'YP 200F' as model, '0.084' as valweight union all 

--select 'MSP 200' as model, '0.09156' as valweight union all 
--select 'coatingroll(83%)' as model, '0.09156' as valweight union all 
--select 'YP(A200) 116' as model, '0.059' as valweight union all 
--select 'YP(A200) 200' as model, '0.084' as valweight 

--),
--eweight20 as (
--select model, 
--cast(valweight as float) as valweight
-- from eweight
--)
--,
--emeterMixing10 as(
 
--select 'YP' as type1,'A200' as construct,'200' as thick,'2 BATCH' as batch,'(+)' as anodecathode,76.8 as weight1,360 as meter union 
--select 'YP','A200','200','2 BATCH','(-)',76.8,360 union 
--select 'YP','A200','116','2 BATCH','(+)',76.8,700 union 
--select 'YP','A200','116','2 BATCH','(-)',76.8,700 union 
--select 'YP','85','200','2 BATCH','(+)',65.3,360  union 
--select 'YP','85','200','2 BATCH','(-)',65.3,360 union 
--select 'YP','85','200','','(+)',33.96,180 union 
--select 'YP','85','200','','(-)',33.96,180 union
--select 'CY','85','120','','(+)',32.326,350 union 
--select 'CY','85','120','','(-)',32.326,350 union 
--select 'CY','85','200','','(+)',32.326,180 union 
--select 'CY','85','200','','(-)',32.326,180 union 
--select 'MSP','83','200','','(-)',40.594,200 union 
--select 'MSP','83','200','','(+)',39.366,200  
--),
--uprice0 as (
--select 'CRECL85' AS ELECCODE,'1.37092359156196' AS PMIX,'2.02526513365066' AS PCOAT,'2.0652762554536' AS PPRESS,'2.09791949552551' AS PSLIT union all  
--select 'CRECL85-02','1.37092359156196','2.02526513365066','2.0652762554536','2.09791949552551' union all  
--select 'CRECO85','2.48003715013453','3.13437869222323','3.17438981402617','3.20703305409808' union all  
--select 'CRECO85-02','2.48003715013453','3.13437869222323','3.17438981402617','3.20703305409808' union all  
--select 'CREML83','2.26997009837251','2.92431164046121','2.96432276226414','2.99696600233605' union all  
--select 'CREMM75','3.21139917432491','3.86574071641361','3.90575183821654','3.93839507828845' union all  
--select 'CREMO75','4.41427457758886','5.06861611967756','5.10862724148049','5.1412704815524' union all  
--select 'CREMO83','4.27503001716746','4.92937155925616','4.9693826810591','5.00202592113101' union all  
--select 'CREYK85','0.771473352591805','1.42581489468051','1.46582601648344','1.49846925655535' union all  
--select 'CREYK85-02','0.771473352591805','1.42581489468051','1.46582601648344','1.49846925655535' union all  
--select 'CREYK85A','0.771473352591805','1.42581489468051','1.46582601648344','1.49846925655535' union all  
--select 'CREYO85','1.37578670992635','2.03012825201505','2.07013937381798','2.10278261388989' union all  
--select 'CREYO85-02','1.37578670992635','2.03012825201505','2.07013937381798','2.10278261388989' union all  
--select 'CREYO85A','1.37578670992635','2.03012825201505','2.07013937381798','2.10278261388989' union all  
--select 'CRFCL85','1.37092359156196','1.89079673365066','1.9308078554536','1.96345109552551' union all  
--select 'CRFCL85-02','1.37092359156196','1.89079673365066','1.9308078554536','1.96345109552551' union all  
--select 'CRFCO85','2.48003715013453','2.99991029222323','3.03992141402617','3.07256465409808' union all  
--select 'CRFCO85-02','2.48003715013453','2.99991029222323','3.03992141402617','3.07256465409808' union all  
--select 'CRFML83','2.31793930205271','2.83781244414141','2.87782356594434','2.91046680601625' union all  
--select 'CRFMO83','4.36639992893927','4.88627307102797','4.92628419283091','4.95892743290281' union all  
--select 'CRFYK85','0.771473352591805','1.2913464946805','1.33135761648344','1.36400085655535' union all  
--select 'CRFYK85-02','0.771473352591805','1.2913464946805','1.33135761648344','1.36400085655535' union all  
--select 'CRFYK85A','0.771473352591805','1.2913464946805','1.33135761648344','1.36400085655535' union all  
--select 'CRFYO85','1.37578670992635','1.89565985201505','1.93567097381798','1.96831421388989' union all  
--select 'CRFYO85-02','1.37578670992635','1.89565985201505','1.93567097381798','1.96831421388989' union all  
--select 'CRFYO85A','1.37578670992635','1.89565985201505','1.93567097381798','1.96831421388989' union all  
--select 'CREYK85A200','0.771473352591805','1.42581489468051','1.46582601648344','1.49846925655535' union all  
--select 'CRFYK85A200','0.771473352591805','1.2913464946805','1.33135761648344','1.36400085655535' union all  
--select 'CRYHB6-018','0.771473352591805','1.42581489468051','1.46582601648344','1.49846925655535' union all  
--select 'CRYHB6-019','0.771473352591805','1.2913464946805','1.33135761648344','1.36400085655535' union all  
--select 'CREYK85A-02','0.771473352591805','1.42581489468051','1.46582601648344','1.49846925655535' union all  
--select 'CRFYK85A-02','0.771473352591805','1.2913464946805','1.33135761648344','1.36400085655535' union all  
--select 'CRCEB6-002','1.37092359156196','2.02526513365066','2.0652762554536','2.09791949552551' union all  
--select 'CRCEB6-003','1.37092359156196','1.89079673365066','1.9308078554536','1.96345109552551' union all  
--select 'CRMSB6-005','2.26997009837251','2.92431164046121','2.96432276226414','2.99696600233605' union all  
--select 'CRMSB6-008','2.31793930205271','2.83781244414141','2.87782356594434','2.91046680601625' union all  
--select 'CRCEK0-264','2.48003715013453','3.13437869222323','3.17438981402617','3.20703305409808' union all  
--select 'CRCEK0-265','2.48003715013453','2.99991029222323','3.03992141402617','3.07256465409808' union all  
--select 'CRYHK0-020','1.37578670992635','2.03012825201505','2.07013937381798','2.10278261388989' union all  
--select 'CRYHK0-021','1.37578670992635','1.89565985201505','1.93567097381798','1.96831421388989' union all  
--select 'CREYO85A200','1.37578670992635','2.03012825201505','2.07013937381798','2.10278261388989' union all  
--select 'CRFYO85A200','1.37578670992635','1.89565985201505','1.93567097381798','1.96831421388989' union all  
--select 'CRMSG2-003','3.21139917432491','3.86574071641361','3.90575183821654','3.93839507828845' union all  
--select 'CRMSK0-254','4.41427457758886','5.06861611967756','5.10862724148049','5.1412704815524' union all  
--select 'CREMO75-02','4.41427457758886','5.06861611967756','5.10862724148049','5.1412704815524' union all  
--select 'CRMSK0-260','4.27503001716746','4.92937155925616','4.9693826810591','5.00202592113101' union all  
--select 'CRMSK0-261','4.36639992893927','4.88627307102797','4.92628419283091','4.95892743290281' union all  
--select 'CREMO83-02','4.27503001716746','4.92937155925616','4.9693826810591','5.00202592113101' union all  
--select 'CRFMO83-02','4.36639992893927','4.88627307102797','4.92628419283091','4.95892743290281' union all  
--select 'CRMSK0-263','4.27503001716746','4.92937155925616','4.9693826810591','5.00202592113101' union all  
--select 'CRMSK0-264','4.36639992893927','4.88627307102797','4.92628419283091','4.95892743290281' union all  
--select 'CRCEK0-266','2.48003715013453','3.13437869222323','3.17438981402617','3.20703305409808' union all  
--select 'CRCEK0-267','2.48003715013453','2.99991029222323','3.03992141402617','3.07256465409808' union all  
--select 'CRMSB6-009','2.26997009837251','2.92431164046121','2.96432276226414','2.99696600233605' union all  
--select 'CRMSB6-010','2.31793930205271','2.83781244414141','2.87782356594434','2.91046680601625' union all  
--select 'CRMSG2-001','3.21139917432491','3.86574071641361','3.90575183821654','3.93839507828845' union all  
--select 'CRMSK0-255','4.41427457758886','5.06861611967756','5.10862724148049','5.1412704815524' union all  
--select 'CRYPB6-007','0.771473352591805','1.42581489468051','1.46582601648344','1.49846925655535' union all  
--select 'CRYPB6-009','0.771473352591805','1.2913464946805','1.33135761648344','1.36400085655535' union all  
--select 'CRYPI0-001','0','0','0','0' union all  
--select 'CRYPI0-002','0','0','0','0' union all  
--select 'CRYPK0-011','1.37578670992635','2.03012825201505','2.07013937381798','2.10278261388989' union all  
--select 'CRYPK0-013','1.37578670992635','1.89565985201505','1.93567097381798','1.96831421388989' union all  
--select 'CRYPK0-016','1.37578670992635','1.89565985201505','1.93567097381798','1.96831421388989' union all  
--select 'CRNCC0-001','0','0','0','0' union all  
--select 'CRPSA0-001','0','0','0','0' union all  
--select 'CRLMA0-256','0','0','0','0' union all  
--select 'CRLMA0-258','0','0','0','0' 
--),
--uprice as (          
--select  
--ELECCODE, cast (PMIX as float) as PMIX, cast (PCOAT as float) as PCOAT, cast (PPRESS as float) as PPRESS, cast (PSLIT as float) as PSLIT
--from uprice0
--)


;with electrodeprice as (
 --select 'YP85116STD' as kind,350 as inputlength,11018597.2122279 as vnd,479.069444009908 as usd,1.36876984002831 as unitUSD  union all 
 --select 'YP85116NEO',350,9860963.9434779,428.737562759909,1.22496446502831  union all 
 --select 'YP85200STD',190,8273790.87835909,359.730038189526,1.89331599047119  union all 
 --select 'YP85200NEO',190,7645361.38960909,332.407016939526,1.74951061547119  union all 
 --select 'CY85120STD',350,15622976.5924771,679.259851846832,1.94074243384809  union all 
 --select 'CY85120NEO',350,14465343.3237271,628.927970596832,1.79693705884809  union all 
 --select 'CY85200STD',190,12878170.2586083,559.920446026449,2.94694971592868  union all 
 --select 'CY85200NEO',190,12249740.7698583,532.597424776449,2.80314434092868  union all 
 --select 'MSP83120STD',400,24457812.1405525,1063.38313654576,2.6584578413644  union all 
 --select 'MSP83120NEO',400,23440882.2086591,1019.16879168083,2.54792197920208  union all 
 --select 'MSP83200STD',210,21198354.6190833,921.667592134055,4.38889329587645  union all 
 --select 'MSP83200NEO',210,20809854.1759399,904.776268519128,4.30845842151966  union all 
 --select 'MSP75162STD',290,23034354.8361915,1001.49368853007,3.45342651217264  union all 
 --select 'MSP75200STD',210,21661951.6692571,941.823985619875,4.4848761219994  union all 
 --select 'BA21E83200STD',210,21198354.6190833,921.667592134055,4.38889329587645  union all 
 --select 'BA21E83200NEO',210,20809854.1759399,904.776268519128,4.30845842151966  union all 
 --select 'YP85116STDA',350,11013152.8666798,478.832733333902,1.36809352381115  union all 
 --select 'YP85116NEOA',350,9855519.59792976,428.500852083903,1.22428814881115  union all 
 --select 'YP85200STDA',190,8268346.53281095,359.49332751352,1.892070144808  union all 
 --select 'YP85200NEOA',190,7639917.04406095,332.17030626352,1.748264769808  
 
			--update unitUSD by kind on 2025-04-26 following Mr.Ha request
 select 'YP85116STD' as kind,350 as inputlength,11018597.2122279 as vnd,479.069444009908 as usd,1.79 as unitUSD  union all 
  select 'HCE(6) / BA21E (4) 200STD',0,0,0,5.4300 union all 
 select 'YP85116NEO',350,9860963.9434779,428.737562759909, 1.65  union all 
  select 'YP85200STDA',190,8268346.53281095,359.49332751352,3.39  union all --following Mr Ha request 2025-11-28
 select 'YP85200STD',190,8273790.87835909,359.730038189526,2.38  union all 
 select 'YP85200NEO',190,7645361.38960909,332.407016939526,2.25  union all 
 select 'CY85120STD',350,15622976.5924771,679.259851846832,2.44  union all 
 select 'CY85120NEO',350,14465343.3237271,628.927970596832,2.31  union all 
 select 'CY85200STD',190,12878170.2586083,559.920446026449,3.62  union all 
 select 'CY85200NEO',190,12249740.7698583,532.597424776449,3.49  union all 
 select 'MSP83120STD',400,24457812.1405525,1063.38313654576,2.6584578413644  union all 
 select 'MSP83120NEO',400,23440882.2086591,1019.16879168083,2.54792197920208  union all 
 select 'MSP83200STD',210,21198354.6190833,921.667592134055,4.86  union all 
 select 'MSP83200NEO',210,20809854.1759399,904.776268519128,4.78  union all 
 select 'MSP75162STD',290,23034354.8361915,1001.49368853007,3.90  union all 
 select 'MSP75200STD',210,21661951.6692571,941.823985619875,4.96  union all 
 select 'BA21E83200STD',210,21198354.6190833,921.667592134055,4.38889329587645  union all 
 select 'BA21E83200NEO',210,20809854.1759399,904.776268519128,4.30845842151966  union all 
 select 'YP85116STDA',350,11013152.8666798,478.832733333902,1.36809352381115  union all 
 select 'YP85116NEOA',350,9855519.59792976,428.500852083903,1.22428814881115  union all 
-- select 'YP85200STDA',190,8268346.53281095,359.49332751352,1.892070144808  union all 

 select 'YP85200NEOA',190,7639917.04406095,332.17030626352,1.748264769808	union all
 -- add
 select 'MSP83116STD' , 0, 0, 0, 3.06 union all
 select 'MSP83116NEO' , 0, 0, 0, 2.95 union all
 select 'BY85200STD' , 0, 0, 0, 3.63 union all
 select 'YP85180NEO' , 0, 0, 0, 2.31 union all
 select 'BA83116STD' , 0, 0, 0, 2.86 union all
 select 'BA83116NEO' , 0, 0, 0, 2.75 union all
 select 'BA83200STD' , 0, 0, 0, 4.46 union all
 select 'BA83200NEO' , 0, 0, 0, 4.38 union all
 select 'BA75162STD' , 0, 0, 0, 3.62 union all
 select 'BA75200STD' , 0, 0, 0, 4.56 union all
 select 'PSCAM 120NEO' , 0, 0, 0, 5.00 union all
 select 'NCM 105STD' , 0, 0, 0, 8.3 union all
 select 'PSCAM 95NEO' , 0, 0, 0, 8.3 union all
 select 'CEP85200STD',0,0,0,5.43 union all --Mr hà request 2026-03-27
 --Mr Ha request 2026-01-16 

 select 'HCE 200NEO',0,0,0,3.3900
 --end
-- add 2025-07-29

 
 )
 , electrode2price as (
 select *
 ,case when kind like '%STD' or kind like '%STDA' then '%(+)%' else '%(-)%' end as cath
 , '%'+replace(replace(replace(replace(replace(replace(replace(kind,'75','%'),'83','%'),'85','%'),'NEOA',''),'NEO',''),'STDA',''),'STD','')+'%' as kinda
 from electrodeprice
 )
	SELECT distinct
				 unitPrice
				, PriceGood
				, PriceNG
	  --Dateadd(hour,0, convert(datetime,A.PlanDate,120 ))   PlanDate 
			 	, (case  when   (DATEPART(HOUR, JobDate)>10)     or    (DATEPART(HOUR, JobDate)=10 and DATEPART(MINUTE, JobDate)>0)     
				then     convert(varchar(10),DATEADD(hour,0,JobDate),120)    
				else    convert(varchar(10),DATEADD(hour,0,DATEADD(DAY, -1,  JobDate)),120)       
				end 
		 )  as PlanDate
		  , A.ElectrodeLotNumber as ElectrodeLotNumber
		  , A.PlanShiftCode
		  , CASE WHEN A.PlanShiftCode = '1' THEN '주간' ELSE '야간' END PlanShiftName
		  , A.WorkerCode
		  , A.WorkerName
		  , A.CreateUserID
		  , A.ElectrodeRouteCode
		  , A.ElectrodeRouteName
		  
		  --, BC.Description AS ElectrodeRouteName
		  , case when  A.ElectrodeRouteCode='V-01' then a.ProductionQty else null end as mixingkg 
		  , case when A.ElectrodeRouteCode='V-01' then wmeter *isnull(A.ProductionQty,(select sum(isnull(InputQty1,0))+sum(isnull(InputQty2,0)) from STB_ElectrodeMixStepInfo
where ElectrodeLotNumber= A.ElectrodeLotNumber)) else A.ProductionQty end as ProductionQty
		  , case when A.ElectrodeRouteCode='V-01' then wmeter *isnull(A.ProductionQty,(select sum(isnull(InputQty1,0))+sum(isnull(InputQty2,0)) from STB_ElectrodeMixStepInfo
where ElectrodeLotNumber= A.ElectrodeLotNumber)) else A.GoodQty end  as GoodQty
		  , A.BadQty
		  --, ownDefect   as AdditionDefect
		  --, BadQtySlitting
		  , case when ElectrodeLotNumber like 'VV%' then ROUND(( isnull(A.BadQty,0)*isnull(eweight3.valweight,0)  + isnull(wasteKg,0) ),3) else wasteKg end as WasteWeight   
		  , wasteKg as "WasteWeight(User Input)"
		  ,  ROUND(( (A.BadQty)*(eweight3.valweight) ),3) as "WasteWeight(Meters)" 
		  , eweight3.valweight as UnitWeight
		  , ROUND(case when A.Yield>100 then 100 else A.Yield end, 1) AS Yield
		  , A.MaterialLotNumber
		  , A.Remark
		  , A.SpecificComment1
		  , A.SpecificComment2
		  , A.MaterialCode         
		  , A.MaterialName,
		  A.Factory as Factory  --update here
		  
		  --, Dateadd(hour,0, convert(datetime,A.JobDate,120 ))   JobDate                  
		 -- ,		 (case  when   (DATEPART(HOUR, JobDate)>10)     or    (DATEPART(HOUR, JobDate)=10 and DATEPART(MINUTE, JobDate)>0)     
			--	then     convert(varchar(10),DATEADD(hour,0,JobDate),120)    
			--	else    convert(varchar(10),DATEADD(hour,0,DATEADD(DAY, -1,  JobDate)),120)       
			--	end 
		 --)  as JobDate

		  ,case when A.ElectrodeRouteCode<>'V-11' then  dateadd(hour,2,jobdate) 
		  else jobdate
					--dateadd(hour,2, (case  when   (DATEPART(HOUR, JobDate)>10)     or    (DATEPART(HOUR, JobDate)=10 and DATEPART(MINUTE, JobDate)>0)     
					--		then     convert(varchar(10),DATEADD(hour,0,JobDate),120)    
					--		else    convert(varchar(10),DATEADD(hour,0,DATEADD(DAY, -1,  JobDate)),120)       
					--		end 
					-- ) 		
					--)
		  end JobDate,
		  case 
				when   (DATEPART(HOUR, JobDate)>10)     or    (DATEPART(HOUR, JobDate)=10 and DATEPART(MINUTE, JobDate)>0)     
				then     convert(varchar(10),JobDate,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  JobDate),120)       
				end InputTime
		  , (	SELECT BaseMonth
				 FROM STB_AggregationPeriod with(nolock) 
				 WHERE 1=1										   
				   AND  FromDate <= A.JobDate
				   AND  ToDate    >= A.JobDate
															 )  AS YearMonth
			, A.CompanyCode as CompanyCode
			, A.MachineCode
			, A.MachineName
			, (CASE WHEN A.ElectrodeRouteCode='V-01' THEN PMIX
					WHEN A.ElectrodeRouteCode='V-02' THEN PCOAT
					WHEN A.ElectrodeRouteCode='V-03' THEN PPRESS
					WHEN A.ElectrodeRouteCode='V-11' THEN PSLIT
					ELSE 0 
					END)
					*(
					case when A.ElectrodeRouteCode='V-01' 
					then wmeter *isnull(A.ProductionQty,(select sum(isnull(InputQty1,0))+sum(isnull(InputQty2,0)) 
									from STB_ElectrodeMixStepInfo 
									where ElectrodeLotNumber= A.ElectrodeLotNumber)) else A.GoodQty 
					end
					) AS ProductPrice,
			 (CASE	WHEN EXISTS (Select 1 FROM STB_ElectrodePriceB802 ep where ep.MaterialCode = A.MaterialCode) then (Select ep.Price FROM STB_ElectrodePriceB802 ep where ep.MaterialCode = A.MaterialCode) * ProductionQty 
					ELSE 0 END ) AS ProductPrice2,
			--, IsSlit,
[V-01_W01],
[V-01_W02],
[V-01_W03],
[V-01_W04],
[V-01_W05],
[V-01_W06],
[V-01_W07],
[V-01_W08],
[V-01_W09],
[V-01_W10],
[V-01_W11],
[V-01_W12],
[V-01_W13],
[V-01_W14],
[V-01_W15],
[V-01_YY],
[V-01_ZZ],
[V-02_0A1],
[V-02_0A2],
[V-02_0A3],
[V-02_0A4],
[V-02_W01],
[V-02_W02],
[V-02_W03],
[V-02_W04],
[V-02_W05],
[V-02_W06],
[V-02_W07],
[V-02_W08],
[V-02_W09],
[V-02_W10],
[V-02_W11],
[V-02_W12],
[V-02_W13],
[V-02_W14],
[V-02_W15],[V-02_W16],[V-02_W17],[V-02_W18],
[V-02_YY],
[V-02_ZZ],
[V-03_0B4],
[V-03_OB1],
[V-03_OB2],
[V-03_OB3],
[V-03_W01],
[V-03_W02],
[V-03_W03],
[V-03_W04],
[V-03_W05],
[V-03_W06],
[V-03_W07],
[V-03_W08],
[V-03_W09],
[V-03_W10],
[V-03_W11],
[V-03_W12],
[V-03_W13],
[V-03_W14],
[V-03_W15],
[V-03_YY],
[V-03_ZZ],
[V-04_W01],
[V-04_W02],
[V-04_W03],
[V-04_W04],
[V-04_W05],
[V-04_W06],
[V-04_W07],
[V-04_W08],
[V-04_W09],
[V-04_W10],
[V-04_W11],
[V-04_W12],
[V-04_W13],
[V-04_W14],
[V-04_W15],
[V-11_0C1],
[V-11_0C2],
[V-11_W01],
[V-11_W02],
[V-11_W03],
[V-11_W04],
[V-11_W05],
[V-11_W06],
[V-11_W07],
[V-11_W08],
[V-11_W09],
[V-11_W10],
[V-11_W11],
[V-11_W12],
[V-11_W13],
[V-11_W14],
[V-11_W15],
[V-11_YY],
[V-11_ZZ]--,

--[V-02_0A1],
--[V-02_0A2],
--[V-02_0A3],
--[V-02_0A4],
--[V-02_YY] ,
--[V-02_ZZ]

	  FROM (

			  -- BEGIN:			  

		SELECT 	
				0 as unitPrice
				,0 as PriceGood
				,0 as PriceNG
				,DPP.PlanDate
				,DPP.PlanShiftCode
				,EM.ElectrodeLotNumber
				,EM.WorkerCode
				,PWI.WorkerName
				,isnull(em.CreateUserID,isnull(em.ChangeUserID,'')) as CreateUserID
				,'V-01' AS ElectrodeRouteCode
				,N'믹싱 (Trộn)' AS ElectrodeRouteName
				
				--,case when em.ProductionQty>1000 then em.ProductionQty/1000.00 else em.ProductionQty end as ProductionQty
				,em.ProductionQty AS ProductionQty
				,null as  GoodQty 						
				,null  as BadQty   	
				, null as wasteKg	
				,null AS Yield
				,NULL AS MaterialLotNumber
				,NULL AS Remark
				,NULL AS SpecificComment1
				,NULL AS SpecificComment2
				, DPP.MaterialCode  AS MaterialCode        
				, MM2.MaterialName AS MaterialName
				, EM.CreateDateTime    AS JobDate
				,		  case 
				when   (DATEPART(HOUR, EM.CreateDateTime)>10)     or    (DATEPART(HOUR, EM.CreateDateTime)=10 and DATEPART(MINUTE, EM.CreateDateTime)>0)     
				then     convert(varchar(10),EM.CreateDateTime,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  EM.CreateDateTime),120)       
				end InputTime        
				, isnull(DPP.CompanyCode,PWI.CompanyCode) as CompanyCode
				, EM.MachineCode
				,MM.MachineName,
				NULL as [V-01_W01],
				NULL as [V-01_W02],
				NULL as [V-01_W03],
				NULL as [V-01_W04],
				NULL as [V-01_W05],
				NULL as [V-01_W06],
				NULL as [V-01_W07],
				NULL as [V-01_W08],
				NULL as [V-01_W09],
				NULL as [V-01_W10],
				NULL as [V-01_W11],
				NULL as [V-01_W12],
				NULL as [V-01_W13],
				NULL as [V-01_W14],
				NULL as [V-01_W15],
				NULL as [V-01_YY],
				NULL as [V-01_ZZ],
				NULL as [V-02_0A1],
				NULL as [V-02_0A2],
				NULL as [V-02_0A3],
				NULL as [V-02_0A4],
				NULL as [V-02_W01],
				NULL as [V-02_W02],
				NULL as [V-02_W03],
				NULL as [V-02_W04],
				NULL as [V-02_W05],
				NULL as [V-02_W06],
				NULL as [V-02_W07],
				NULL as [V-02_W08],
				NULL as [V-02_W09],
				NULL as [V-02_W10],
				NULL as [V-02_W11],
				NULL as [V-02_W12],
				NULL as [V-02_W13],
				NULL as [V-02_W14],
				NULL as [V-02_W15],
				NULL as [V-02_W16],
				NULL as [V-02_W17],
				NULL as [V-02_W18],
				NULL as [V-02_YY],
				NULL as [V-02_ZZ],
				NULL as [V-03_0B4],
				NULL as [V-03_OB1],
				NULL as [V-03_OB2],
				NULL as [V-03_OB3],
				NULL as [V-03_W01],
				NULL as [V-03_W02],
				NULL as [V-03_W03],
				NULL as [V-03_W04],
				NULL as [V-03_W05],
				NULL as [V-03_W06],
				NULL as [V-03_W07],
				NULL as [V-03_W08],
				NULL as [V-03_W09],
				NULL as [V-03_W10],
				NULL as [V-03_W11],
				NULL as [V-03_W12],
				NULL as [V-03_W13],
				NULL as [V-03_W14],
				NULL as [V-03_W15],
				NULL as [V-03_YY],
				NULL as [V-03_ZZ],
				NULL as [V-04_W01],
				NULL as [V-04_W02],
				NULL as [V-04_W03],
				NULL as [V-04_W04],
				NULL as [V-04_W05],
				NULL as [V-04_W06],
				NULL as [V-04_W07],
				NULL as [V-04_W08],
				NULL as [V-04_W09],
				NULL as [V-04_W10],
				NULL as [V-04_W11],
				NULL as [V-04_W12],
				NULL as [V-04_W13],
				NULL as [V-04_W14],
				NULL as [V-04_W15],
				NULL as [V-11_0C1],
				NULL as [V-11_0C2],
				NULL as [V-11_W01],
				NULL as [V-11_W02],
				NULL as [V-11_W03],
				NULL as [V-11_W04],
				NULL as [V-11_W05],
				NULL as [V-11_W06],
				NULL as [V-11_W07],
				NULL as [V-11_W08],
				NULL as [V-11_W09],
				NULL as [V-11_W10],
				NULL as [V-11_W11],
				NULL as [V-11_W12],
				NULL as [V-11_W13],
				NULL as [V-11_W14],
				NULL as [V-11_W15],
				NULL as [V-11_YY],
				NULL as [V-11_ZZ]--,
				,EBB.Factory --update here
			FROM STB_SetInfo SI
					  LEFT OUTER JOIN STB_MaterialMaster MM2	 with(nolock) 		ON SI.MaterialCode = MM2.MaterialCode
					  LEFT OUTER JOIN STB_ElectrodeMixInfo EM	 with(nolock) 		ON SI.Barcode = EM.ElectrodeLotNumber
					  LEFT OUTER JOIN STB_MachineMaster MM		 with(nolock) 	ON EM.MachineCode = MM.MachineCode
					  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	 with(nolock) 		ON EM.WorkerCode = PWI.WorkerCode
					  LEFT OUTER JOIN STB_DayProdPlan DPP with(nolock) on si.DayPlanNo  = dpp.DayPlanNo
					  LEFT OUTER JOIN Electrode_BN_BG EBB with(nolock) on SI.MaterialCode = EBB.MaterialCode --update here
			 WHERE /*DPP.LineCode = 'ELECTRODE LINE'  and*/ 
				(  EM.CreateDateTime between @FromDate   and  @ToDate )
				--and MM2.Materialtypecode<>'FERT'
				and si.MaterialCode not like '%ECVT%'

			UNION ALL

			  -- 1. 
				SELECT  	
						0 as unitPrice
						,0 as PriceGood
						,0 as PriceNG
						,DPP.PlanDate
						  ,DPP.PlanShiftCode
						  ,ECI.ElectrodeLotNumber
						  ,ECI.WorkerCode
						  ,PWI.WorkerName
						  ,isnull(eci.CreateUserID,isnull(eci.ChangeUserID,'')) as CreateUserID
				,'V-02' AS ElectrodeRouteCode
				,N'코팅 (Mạ điện cực)' AS ElectrodeRouteName
						  ,case when eci.CreateDateTime between @FromDate and @ToDate then ECI.ProductionQty else 0 end as ProductionQty
						  ,case when eci.CreateDateTime between @FromDate and @ToDate then ECI.GoodQty  else 0 end GoodQty 
						  --- isnull((select sum(isnull(defectweight,0)) from STB_ElectrodeWasteInfoNew  WITH(NOLOCK) where upper(barcode) = eci.ElectrodeLotNumber group by barcode),0) as GoodQty
						  ,case when eci.CreateDateTime between @FromDate and @ToDate then isnull(ECI.BadQty,0)  else 0 end  as BadQty   					 
						  , ((select sum(isnull(defectweight,0)) from STB_ElectrodeWasteInfoNew  WITH(NOLOCK) where upper(barcode) = eci.ElectrodeLotNumber  and RouteCode = 'V-02' and CreateDateTime between @FromDate and @ToDate group by barcode)) as wasteKg	 
						  ---, isnull((select sum(isnull(defectweight,0)) from STB_ElectrodeWasteInfoNew  WITH(NOLOCK) where upper(barcode) = eci.ElectrodeLotNumber group by barcode),0)
						  , CASE WHEN ECI.ProductionQty = 0 THEN 0 
								when eci.CreateDateTime < @FromDate or eci.CreateDateTime > @ToDate then 0
								WHEN  ECI.GoodQty = 0 THEN 0  
								ELSE  ((ECI.GoodQty ) 
										/ case when isnull(ECI.ProductionQty,1)=0 then 1 else isnull(ECI.ProductionQty,1) end) * 100 END AS Yield 
						  --, isnull(ownDefect,0) as ownDefect  
						  ,ECI.MaterialLotNumber
						  ,ECI.Remark
						  ,ECI.SpecificComment1
						  ,ECI.SpecificComment2

						  , DPP.MaterialCode        AS MaterialCode            
						  , (Select MaterialName From STB_MaterialMaster MM  with(nolock) WHERE MM.MaterialCode = DPP.MaterialCode) AS MaterialName 
						  , ECI.CreateDateTime      AS JobDate        
						  		  ,case 
				when   (DATEPART(HOUR, ECI.CreateDateTime)>10)     or    (DATEPART(HOUR, ECI.CreateDateTime)=10 and DATEPART(MINUTE, ECI.CreateDateTime)>0)     
				then     convert(varchar(10),ECI.CreateDateTime,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  ECI.CreateDateTime),120)       
				end InputTime             
						  , isnull(ewin.CompanyCode,DPP.CompanyCode) as CompanyCode
						  , ECI.MachineCode
						  , MM.MachineName
											 --  ,case when c.Barcode is  null then 'Not Slitting' else 'Slitted' end as IsSlit
											   ,
[V-01_W01],
[V-01_W02],
[V-01_W03],
[V-01_W04],
[V-01_W05],
[V-01_W06],
[V-01_W07],
[V-01_W08],
[V-01_W09],
[V-01_W10],
[V-01_W11],
[V-01_W12],
[V-01_W13],
[V-01_W14],
[V-01_W15],
[V-01_YY],
[V-01_ZZ],
[V-02_0A1],
[V-02_0A2],
[V-02_0A3],
[V-02_0A4],
[V-02_W01],
[V-02_W02],
[V-02_W03],
[V-02_W04],
[V-02_W05],
[V-02_W06],
[V-02_W07],
[V-02_W08],
[V-02_W09],
[V-02_W10],
[V-02_W11],
[V-02_W12],
[V-02_W13],
[V-02_W14],
[V-02_W15],[V-02_W16],[V-02_W17],[V-02_W18],
[V-02_YY],
[V-02_ZZ],
[V-03_0B4],
[V-03_OB1],
[V-03_OB2],
[V-03_OB3],
[V-03_W01],
[V-03_W02],
[V-03_W03],
[V-03_W04],
[V-03_W05],
[V-03_W06],
[V-03_W07],
[V-03_W08],
[V-03_W09],
[V-03_W10],
[V-03_W11],
[V-03_W12],
[V-03_W13],
[V-03_W14],
[V-03_W15],
[V-03_YY],
[V-03_ZZ],
[V-04_W01],
[V-04_W02],
[V-04_W03],
[V-04_W04],
[V-04_W05],
[V-04_W06],
[V-04_W07],
[V-04_W08],
[V-04_W09],
[V-04_W10],
[V-04_W11],
[V-04_W12],
[V-04_W13],
[V-04_W14],
[V-04_W15],
[V-11_0C1],
[V-11_0C2],
[V-11_W01],
[V-11_W02],
[V-11_W03],
[V-11_W04],
[V-11_W05],
[V-11_W06],
[V-11_W07],
[V-11_W08],
[V-11_W09],
[V-11_W10],
[V-11_W11],
[V-11_W12],
[V-11_W13],
[V-11_W14],
[V-11_W15],
[V-11_YY],
[V-11_ZZ]--,
,EBB.Factory  --update

--[V-02_0A1],
--[V-02_0A2],
--[V-02_0A3],
--[V-02_0A4],
--[V-02_YY] ,
--[V-02_ZZ]
				  FROM STB_DayProdPlan DPP with(nolock) 
						  LEFT OUTER JOIN STB_SetInfo SI   				 with(nolock)                 ON DPP.DayPlanNo = SI.DayPlanNo
						  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI	 with(nolock) 			ON ECI.ElectrodeLotNumber = SI.Barcode
							--LEFT OUTER JOIN STB_MaterialMaster MM2	 with(nolock) 		ON SI.MaterialCode = MM2.MaterialCode
						  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	 with(nolock) 			ON PWI.WorkerCode = ECI.WorkerCode
						  LEFT OUTER JOIN STB_MachineMaster MM  with(nolock) ON MM.MachineCode = ECI.MachineCode
						  LEFT OUTER JOIN Electrode_BN_BG EBB with(nolock) ON DPP.MaterialCode = EBB.MaterialCode  --update

						left outer join 
						(select*from (
select barcode, sum(DefectWeight) as  DefectWeight , (ew1.DefectCode ) as DefectDesc, max(CompanyCode) as CompanyCode  --, sum(isnull(DefectWeight,0)) as ownDefect
from STB_ElectrodeWasteInfoNew ew1   with(nolock) 
	  LEFT OUTER JOIN STB_DefectInfo DI    with(nolock) on ew1.DefectCode = DI.DefectCode
where  ew1.CreateDateTime between @FromDate and @ToDate   and  RouteCode='V-02' 
group by barcode,ew1.DefectCode
)	ElectrodeWasteInfoNew 
pivot 
( sum(DefectWeight	)
for  DefectDesc in (
[V-01_W01],
[V-01_W02],
[V-01_W03],
[V-01_W04],
[V-01_W05],
[V-01_W06],
[V-01_W07],
[V-01_W08],
[V-01_W09],
[V-01_W10],
[V-01_W11],
[V-01_W12],
[V-01_W13],
[V-01_W14],
[V-01_W15],
[V-01_YY],
[V-01_ZZ],
[V-02_0A1],
[V-02_0A2],
[V-02_0A3],
[V-02_0A4],
[V-02_W01],
[V-02_W02],
[V-02_W03],
[V-02_W04],
[V-02_W05],
[V-02_W06],
[V-02_W07],
[V-02_W08],
[V-02_W09],
[V-02_W10],
[V-02_W11],
[V-02_W12],
[V-02_W13],
[V-02_W14],
[V-02_W15],[V-02_W16],[V-02_W17],[V-02_W18],
[V-02_YY],
[V-02_ZZ],
[V-03_0B4],
[V-03_OB1],
[V-03_OB2],
[V-03_OB3],
[V-03_W01],
[V-03_W02],
[V-03_W03],
[V-03_W04],
[V-03_W05],
[V-03_W06],
[V-03_W07],
[V-03_W08],
[V-03_W09],
[V-03_W10],
[V-03_W11],
[V-03_W12],
[V-03_W13],
[V-03_W14],
[V-03_W15],
[V-03_YY],
[V-03_ZZ],
[V-04_W01],
[V-04_W02],
[V-04_W03],
[V-04_W04],
[V-04_W05],
[V-04_W06],
[V-04_W07],
[V-04_W08],
[V-04_W09],
[V-04_W10],
[V-04_W11],
[V-04_W12],
[V-04_W13],
[V-04_W14],
[V-04_W15],
[V-11_0C1],
[V-11_0C2],
[V-11_W01],
[V-11_W02],
[V-11_W03],
[V-11_W04],
[V-11_W05],
[V-11_W06],
[V-11_W07],
[V-11_W08],
[V-11_W09],
[V-11_W10],
[V-11_W11],
[V-11_W12],
[V-11_W13],
[V-11_W14],
[V-11_W15],
[V-11_YY],
[V-11_ZZ]--,

--[V-02_0A1],
--[V-02_0A2],
--[V-02_0A3],
--[V-02_0A4],
--[V-02_YY] ,
--[V-02_ZZ]
)
) pvt
)              ewin            on  eci.ElectrodeLotNumber=ewin.barcode
				 WHERE /*DPP.LineCode = 'ELECTRODE LINE'  and*/ 
				(  ECI.CreateDateTime between @FromDate   and  @ToDate )
				 --and c.barcode is null
				 	--and MM2.Materialtypecode<>'FERT'
					and si.MaterialCode not like '%ECVT%'

			 UNION ALL

		 --2. 
			SELECT  	
					0 as unitPrice
					,0 as PriceGood
					,0 as PriceNG
					,DPP.PlanDate
					  ,DPP.PlanShiftCode
					  ,ERPI.ElectrodeLotNumber
					  ,ERPI.WorkerCode
					  ,PWI.WorkerName
					  ,isnull(ERPI.CreateUserID,isnull(ERPI.ChangeUserID,'')) as CreateUserID
				,'V-03' AS ElectrodeRouteCode
				,N'롤프레싱 (Ép cuộn)' AS ElectrodeRouteName
					  --,case when b.Barcode is  null then 'RollPress' else 'Slitting' end  AS ElectrodeRouteName
					 
					  	  ,case when ERPI.CreateDateTime between @FromDate and @ToDate then isnull(ERPI.ProductionQty,ERPI.GoodQty+isnull(ERPI.BadQty,0)) else 0 end as ProductionQty
						  ,case when ERPI.CreateDateTime between @FromDate and @ToDate then ERPI.GoodQty  else 0 end GoodQty 
						  --- isnull((select sum(isnull(defectweight,0)) from STB_ElectrodeWasteInfoNew  WITH(NOLOCK) where upper(barcode) = eci.ElectrodeLotNumber group by barcode),0) as GoodQty
						  ,case when ERPI.CreateDateTime between @FromDate and @ToDate then isnull(ERPI.BadQty,0)  else 0 end  as BadQty   
	
					  , ((select sum(isnull(defectweight,0)) from STB_ElectrodeWasteInfoNew  WITH(NOLOCK) where upper(barcode) = ERPI.ElectrodeLotNumber and RouteCode = 'V-03'  and CreateDateTime between @FromDate and @ToDate group by barcode)) as wasteKg
					 -- , isnull(ownDefect,0) as ownDefect  
					  --,0 as BadQtySlitting

					  ,CASE WHEN isnull(ERPI.ProductionQty,ERPI.GoodQty+isnull(ERPI.BadQty,0)) = 0 THEN 0 
					  when ERPI.CreateDateTime < @FromDate or ERPI.CreateDateTime > @ToDate then 0
					  WHEN ERPI.GoodQty = 0 THEN 0 ELSE	( (ERPI.GoodQty) 
						/ case when isnull(eci.ProductionQty,isnull(eci.GoodQty,1)+isnull(eci.BadQty,1))=0 then 1 else
									isnull(eci.ProductionQty,isnull(eci.GoodQty,1)+isnull(eci.BadQty,1)) end
						) * 100 END AS Yield

					  ,NULL AS MaterialLotNumber
					  ,NULL AS Remark
					  ,NULL AS SpecificComment1
					  ,NULL AS SpecificComment2

					  , DPP.MaterialCode         AS MaterialCode                    
					 , (Select MaterialName From STB_MaterialMaster MM with(nolock)  WHERE MM.MaterialCode = DPP.MaterialCode) AS MaterialName      			  
					 , ERPI.CreateDateTime        AS JobDate  
					 ,		  case 
				when   (DATEPART(HOUR, ERPI.CreateDateTime)>10)     or    (DATEPART(HOUR, ERPI.CreateDateTime)=10 and DATEPART(MINUTE, ERPI.CreateDateTime)>0)     
				then     convert(varchar(10),ERPI.CreateDateTime,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  ERPI.CreateDateTime),120)       
				end InputTime           
					  , isnull(ewin.CompanyCode,DPP.CompanyCode) as CompanyCode
					  , ERPI.MachineCode
					  , MM.MachineName
					  
						   --,case when b.Barcode is  null then 'Not Slitting' else 'Slitted' end as IsSlit
						   ,
 [V-01_W01],
 [V-01_W02],
 [V-01_W03],
 [V-01_W04],
 [V-01_W05],
 [V-01_W06],
 [V-01_W07],
 [V-01_W08],
 [V-01_W09],
 [V-01_W10],
 [V-01_W11],
 [V-01_W12],
 [V-01_W13],
 [V-01_W14],
 [V-01_W15],
 [V-01_YY],
 [V-01_ZZ],
 [V-02_0A1],
 [V-02_0A2],
 [V-02_0A3],
 [V-02_0A4],
 [V-02_W01],
 [V-02_W02],
 [V-02_W03],
 [V-02_W04],
 [V-02_W05],
 [V-02_W06],
 [V-02_W07],
 [V-02_W08],
 [V-02_W09],
 [V-02_W10],
 [V-02_W11],
 [V-02_W12],
 [V-02_W13],
 [V-02_W14],
 [V-02_W15],[V-02_W16],[V-02_W17],[V-02_W18],
 [V-02_YY],
 [V-02_ZZ],
 [V-03_0B4],
 [V-03_OB1],
 [V-03_OB2],
 [V-03_OB3],
 [V-03_W01],
 [V-03_W02],
 [V-03_W03],
 [V-03_W04],
 [V-03_W05],
 [V-03_W06],
 [V-03_W07],
 [V-03_W08],
 [V-03_W09],
 [V-03_W10],
 [V-03_W11],
 [V-03_W12],
 [V-03_W13],
 [V-03_W14],
 [V-03_W15],
 [V-03_YY],
 [V-03_ZZ],
 [V-04_W01],
 [V-04_W02],
 [V-04_W03],
 [V-04_W04],
 [V-04_W05],
 [V-04_W06],
 [V-04_W07],
 [V-04_W08],
 [V-04_W09],
 [V-04_W10],
 [V-04_W11],
 [V-04_W12],
 [V-04_W13],
 [V-04_W14],
 [V-04_W15],
 [V-11_0C1],
 [V-11_0C2],
 [V-11_W01],
 [V-11_W02],
 [V-11_W03],
 [V-11_W04],
 [V-11_W05],
 [V-11_W06],
 [V-11_W07],
 [V-11_W08],
 [V-11_W09],
 [V-11_W10],
 [V-11_W11],
 [V-11_W12],
 [V-11_W13],
 [V-11_W14],
 [V-11_W15],
 [V-11_YY],
 [V-11_ZZ]--,
 ,Ebb.Factory  --update

 --[V-02_0A1],
 --[V-02_0A2],
 --[V-02_0A3],
 --[V-02_0A4],
 --[V-02_YY] ,
 --[V-02_ZZ]
			  FROM STB_DayProdPlan DPP with(nolock) 
					  LEFT OUTER JOIN STB_SetInfo SI				 with(nolock)                    ON DPP.DayPlanNo = SI.DayPlanNo
					  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI	 with(nolock) 			ON ECI.ElectrodeLotNumber = SI.Barcode
					  LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI	 with(nolock) 	   ON  ERPI.ElectrodeLotNumber = SI.Barcode
					--LEFT OUTER JOIN STB_MaterialMaster MM2	 with(nolock) 		ON SI.MaterialCode = MM2.MaterialCode

					  LEFT OUTER JOIN STB_ProdWorkerInfo PWI			 with(nolock)    ON PWI.WorkerCode = ERPI.WorkerCode
					  LEFT OUTER JOIN STB_MachineMaster MM  with(nolock) ON MM.MachineCode = ERPI.MachineCode
					    LEFT OUTER JOIN Electrode_BN_BG EBB with(nolock) on DPP.MaterialCode = EBB.MaterialCode --update
						left outer join 
						(select*from (
select barcode, sum(DefectWeight) as  DefectWeight , (ew1.DefectCode ) as DefectDesc, max(CompanyCode) as CompanyCode --, sum(isnull(DefectWeight,0)) as ownDefect
from STB_ElectrodeWasteInfoNew ew1   with(nolock) 
	  LEFT OUTER JOIN STB_DefectInfo DI    with(nolock) on ew1.DefectCode = DI.DefectCode
where  ew1.CreateDateTime between @FromDate and @ToDate   and  RouteCode='V-03' 
group by barcode,ew1.DefectCode
)	ElectrodeWasteInfoNew 
pivot 
( sum(DefectWeight	)
for  DefectDesc in (
[V-01_W01],
[V-01_W02],
[V-01_W03],
[V-01_W04],
[V-01_W05],
[V-01_W06],
[V-01_W07],
[V-01_W08],
[V-01_W09],
[V-01_W10],
[V-01_W11],
[V-01_W12],
[V-01_W13],
[V-01_W14],
[V-01_W15],
[V-01_YY],
[V-01_ZZ],
[V-02_0A1],
[V-02_0A2],
[V-02_0A3],
[V-02_0A4],
[V-02_W01],
[V-02_W02],
[V-02_W03],
[V-02_W04],
[V-02_W05],
[V-02_W06],
[V-02_W07],
[V-02_W08],
[V-02_W09],
[V-02_W10],
[V-02_W11],
[V-02_W12],
[V-02_W13],
[V-02_W14],
[V-02_W15],[V-02_W16],[V-02_W17],[V-02_W18],
[V-02_YY],
[V-02_ZZ],
[V-03_0B4],
[V-03_OB1],
[V-03_OB2],
[V-03_OB3],
[V-03_W01],
[V-03_W02],
[V-03_W03],
[V-03_W04],
[V-03_W05],
[V-03_W06],
[V-03_W07],
[V-03_W08],
[V-03_W09],
[V-03_W10],
[V-03_W11],
[V-03_W12],
[V-03_W13],
[V-03_W14],
[V-03_W15],
[V-03_YY],
[V-03_ZZ],
[V-04_W01],
[V-04_W02],
[V-04_W03],
[V-04_W04],
[V-04_W05],
[V-04_W06],
[V-04_W07],
[V-04_W08],
[V-04_W09],
[V-04_W10],
[V-04_W11],
[V-04_W12],
[V-04_W13],
[V-04_W14],
[V-04_W15],
[V-11_0C1],
[V-11_0C2],
[V-11_W01],
[V-11_W02],
[V-11_W03],
[V-11_W04],
[V-11_W05],
[V-11_W06],
[V-11_W07],
[V-11_W08],
[V-11_W09],
[V-11_W10],
[V-11_W11],
[V-11_W12],
[V-11_W13],
[V-11_W14],
[V-11_W15],
[V-11_YY],
[V-11_ZZ]--,

--[V-02_0A1],
--[V-02_0A2],
--[V-02_0A3],
--[V-02_0A4],
--[V-02_YY] ,
--[V-02_ZZ]
)
) pvt
)              ewin            on  ERPI.ElectrodeLotNumber=ewin.barcode
			 WHERE /*DPP.LineCode = 'ELECTRODE LINE'   and */ ( (ERPI.CreateDateTime) between @FromDate   and  @ToDate )
			 --and b.Barcode is  null
			 	--and MM2.Materialtypecode<>'FERT'
				and si.MaterialCode not like '%ECVT%'
			 			 UNION ALL

		 --2. 
			SELECT  	
					unitUSD as unitPrice
					,unitUSD*(case when b.CreateDateTime between @FromDate and @ToDate then b.GoodQtyLength  else 0 end) as PriceGood
					,unitUSD*(case when b.CreateDateTime between @FromDate and @ToDate then isnull(b.ProductionQty,b.GoodQtyLength+isnull(0,0)) else 0 end-case when b.CreateDateTime between @FromDate and @ToDate then b.GoodQtyLength  else 0 end) as PriceNG
					,DPP.PlanDate
					  ,DPP.PlanShiftCode
					  ,ERPI.ElectrodeLotNumber
					  ,ERPI.WorkerCode
					  ,PWI.WorkerName
					  ,isnull(ERPI.CreateUserID,isnull(ERPI.ChangeUserID,'')) as CreateUserID
				,'V-11' AS ElectrodeRouteCode
				,N'슬리팅 (Slitting)' AS ElectrodeRouteName
					  --,case when b.Barcode is  null then 'RollPress' else 'Slitting' end  AS ElectrodeRouteName
					 
					  		,case when b.CreateDateTime between @FromDate and @ToDate then isnull(b.ProductionQty,b.GoodQtyLength+isnull(0,0)) else 0 end as ProductionQty
						  ,case when b.CreateDateTime between @FromDate and @ToDate then b.GoodQtyLength  else 0 end GoodQty 
						  --- isnull((select sum(isnull(defectweight,0)) from STB_ElectrodeWasteInfoNew  WITH(NOLOCK) where upper(barcode) = eci.ElectrodeLotNumber group by barcode),0) as GoodQty
						,0   as BadQty --  ,case when b.CreateDateTime between @FromDate and @ToDate then isnull(ERPI.BadQty,0)  else 0 end  as BadQty   

					  --ERPI
					  --, isnull((select sum(isnull(defectweight,0)) from STB_ElectrodeWasteInfoNew  WITH(NOLOCK) where upper(barcode) = eci.ElectrodeLotNumber  and RouteCode like 'V-11'  group by barcode),0) as BadQty 
					  , ((select sum(isnull(defectweight,0)) from STB_ElectrodeWasteInfoNew  WITH(NOLOCK) where upper(barcode) = b.ElectrodeLotNumber  and RouteCode = 'V-11'  and CreateDateTime between @FromDate and @ToDate group by barcode)) as wasteKg   					 
					 -- , isnull(ownDefect,0) as ownDefect  
					  --,0 as BadQtySlitting

					  ,CASE WHEN isnull(b.ProductionQty,b.GoodQtyLength+isnull(0,0)) = 0 THEN 0 
					  when b.CreateDateTime < @FromDate or b.CreateDateTime > @ToDate then 0
					  WHEN b.GoodQtyLength = 0 THEN 0 ELSE	( (b.GoodQtyLength) 
						/ case when isnull(ERPI.ProductionQty,ERPI.GoodQty+isnull(ERPI.BadQty,1))=0 then 1 else
									isnull(ERPI.ProductionQty,ERPI.GoodQty+isnull(ERPI.BadQty,1)) end
						) * 100 END AS Yield

					  ,NULL AS MaterialLotNumber
					  ,NULL AS Remark
					  ,NULL AS SpecificComment1
					  ,NULL AS SpecificComment2

					  , DPP.MaterialCode    AS MaterialCode       
					 , (Select MaterialName From STB_MaterialMaster MM with(nolock)  WHERE MM.MaterialCode = DPP.MaterialCode) AS MaterialName    
					 , b.CreateDateTime      AS JobDate   
					 ,		  case 
				when   (DATEPART(HOUR, b.CreateDateTime )>10)     or    (DATEPART(HOUR, b.CreateDateTime )=10 and DATEPART(MINUTE, b.CreateDateTime )>0)     
				then     convert(varchar(10),b.CreateDateTime ,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  b.CreateDateTime ),120)       
				end InputTime        
					  , isnull(ewin.CompanyCode,DPP.CompanyCode) as CompanyCode
					  , '' as MachineCode
					  , '' as MachineName	

					--,case when b.Barcode is  null then 'Not Slitting' else 'Slitted' end as IsSlit
						   ,
 [V-01_W01],
 [V-01_W02],
 [V-01_W03],
 [V-01_W04],
 [V-01_W05],
 [V-01_W06],
 [V-01_W07],
 [V-01_W08],
 [V-01_W09],
 [V-01_W10],
 [V-01_W11],
 [V-01_W12],
 [V-01_W13],
 [V-01_W14],
 [V-01_W15],
 [V-01_YY],
 [V-01_ZZ],
 [V-02_0A1],
 [V-02_0A2],
 [V-02_0A3],
 [V-02_0A4],
 [V-02_W01],
 [V-02_W02],
 [V-02_W03],
 [V-02_W04],
 [V-02_W05],
 [V-02_W06],
 [V-02_W07],
 [V-02_W08],
 [V-02_W09],
 [V-02_W10],
 [V-02_W11],
 [V-02_W12],
 [V-02_W13],
 [V-02_W14],
 [V-02_W15],[V-02_W16],[V-02_W17],[V-02_W18],
 [V-02_YY],
 [V-02_ZZ],
 [V-03_0B4],
 [V-03_OB1],
 [V-03_OB2],
 [V-03_OB3],
 [V-03_W01],
 [V-03_W02],
 [V-03_W03],
 [V-03_W04],
 [V-03_W05],
 [V-03_W06],
 [V-03_W07],
 [V-03_W08],
 [V-03_W09],
 [V-03_W10],
 [V-03_W11],
 [V-03_W12],
 [V-03_W13],
 [V-03_W14],
 [V-03_W15],
 [V-03_YY],
 [V-03_ZZ],
 [V-04_W01],
 [V-04_W02],
 [V-04_W03],
 [V-04_W04],
 [V-04_W05],
 [V-04_W06],
 [V-04_W07],
 [V-04_W08],
 [V-04_W09],
 [V-04_W10],
 [V-04_W11],
 [V-04_W12],
 [V-04_W13],
 [V-04_W14],
 [V-04_W15],
 [V-11_0C1],
 [V-11_0C2],
 [V-11_W01],
 [V-11_W02],
 [V-11_W03],
 [V-11_W04],
 [V-11_W05],
 [V-11_W06],
 [V-11_W07],
 [V-11_W08],
 [V-11_W09],
 [V-11_W10],
 [V-11_W11],
 [V-11_W12],
 [V-11_W13],
 [V-11_W14],
 [V-11_W15],
 [V-11_YY],
 [V-11_ZZ]--,
 , EBB.Factory  --update

 --[V-02_0A1],
 --[V-02_0A2],
 --[V-02_0A3],
 --[V-02_0A4],
 --[V-02_YY] ,
 --[V-02_ZZ]
			  FROM STB_DayProdPlan DPP with(nolock) 
					  LEFT OUTER JOIN STB_SetInfo SI				 with(nolock)                    ON DPP.DayPlanNo = SI.DayPlanNo
					  LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI	 with(nolock) 	   ON SI.Barcode = ERPI.ElectrodeLotNumber
					  outer apply( 
					  --fix 2026-02-24
					  --begin
					--  select top 1 * from STB_ElectrodeSlittingResult   with(nolock) where ElectrodeLotNumber=ERPI.ElectrodeLotNumber
					SELECT 
        SUM(ProductionQty)/5 AS ProductionQty,      
        SUM(GoodQtyLength)/5 AS GoodQtyLength,      
        MAX(CreateDateTime) AS CreateDateTime,     
        MAX(ElectrodeLotNumber) AS ElectrodeLotNumber,
        MAX(Barcode) AS Barcode
    FROM STB_ElectrodeSlittingResult WITH(NOLOCK) 
    WHERE ElectrodeLotNumber = ERPI.ElectrodeLotNumber
      AND SI.MaterialCode IN ('CRYPK0-017','CRYPK0-018','CRCEK0-268','CRYPK0-016') -- Mr hà request 2026-03-30
    
    UNION ALL

    SELECT TOP 1 
        ProductionQty, 
        GoodQtyLength, 
        CreateDateTime, 
        ElectrodeLotNumber, 
        Barcode
    FROM STB_ElectrodeSlittingResult WITH(NOLOCK) 
    WHERE ElectrodeLotNumber = ERPI.ElectrodeLotNumber
      AND (SI.MaterialCode NOT IN ('CRYPK0-017','CRYPK0-018','CRCEK0-268','CRYPK0-016') OR SI.MaterialCode IS NULL) -- Mr hà request 2026-03-30
    ORDER BY CreateDateTime DESC
	                   --end
)
					  b
					  LEFT OUTER JOIN STB_MaterialMaster MM2	 with(nolock) 		ON SI.MaterialCode = MM2.MaterialCode
					  LEFT OUTER JOIN STB_ProdWorkerInfo PWI			 with(nolock)    ON PWI.WorkerCode = ERPI.WorkerCode
					  LEFT OUTER JOIN STB_MachineMaster MM  with(nolock) ON MM.MachineCode = ERPI.MachineCode
					    LEFT OUTER JOIN Electrode_BN_BG EBB with(nolock) ON DPP.MaterialCode = EBB.MaterialCode --update
					  outer apply (select top 1 unitUSD from electrode2price where mm2.MaterialName like cath and (mm2.MaterialName like kinda or mm2.MaterialSource+mm2.MaterialThickness like kinda) ) tbprice
						left outer join 
						(select*from (
select barcode, sum(DefectWeight) as  DefectWeight , (ew1.DefectCode ) as DefectDesc, max(CompanyCode) as CompanyCode --, sum(isnull(DefectWeight,0)) as ownDefect
from STB_ElectrodeWasteInfoNew ew1   with(nolock) 
	  LEFT OUTER JOIN STB_DefectInfo DI    with(nolock) on ew1.DefectCode = DI.DefectCode
where  ew1.CreateDateTime between @FromDate and @ToDate   and  RouteCode='V-11' 
group by barcode,ew1.DefectCode
)	ElectrodeWasteInfoNew 
pivot 
( sum(DefectWeight	)
for  DefectDesc in (
[V-01_W01],
[V-01_W02],
[V-01_W03],
[V-01_W04],
[V-01_W05],
[V-01_W06],
[V-01_W07],
[V-01_W08],
[V-01_W09],
[V-01_W10],
[V-01_W11],
[V-01_W12],
[V-01_W13],
[V-01_W14],
[V-01_W15],
[V-01_YY],
[V-01_ZZ],
[V-02_0A1],
[V-02_0A2],
[V-02_0A3],
[V-02_0A4],
[V-02_W01],
[V-02_W02],
[V-02_W03],
[V-02_W04],
[V-02_W05],
[V-02_W06],
[V-02_W07],
[V-02_W08],
[V-02_W09],
[V-02_W10],
[V-02_W11],
[V-02_W12],
[V-02_W13],
[V-02_W14],
[V-02_W15],[V-02_W16],[V-02_W17],[V-02_W18],
[V-02_YY],
[V-02_ZZ],
[V-03_0B4],
[V-03_OB1],
[V-03_OB2],
[V-03_OB3],
[V-03_W01],
[V-03_W02],
[V-03_W03],
[V-03_W04],
[V-03_W05],
[V-03_W06],
[V-03_W07],
[V-03_W08],
[V-03_W09],
[V-03_W10],
[V-03_W11],
[V-03_W12],
[V-03_W13],
[V-03_W14],
[V-03_W15],
[V-03_YY],
[V-03_ZZ],
[V-04_W01],
[V-04_W02],
[V-04_W03],
[V-04_W04],
[V-04_W05],
[V-04_W06],
[V-04_W07],
[V-04_W08],
[V-04_W09],
[V-04_W10],
[V-04_W11],
[V-04_W12],
[V-04_W13],
[V-04_W14],
[V-04_W15],
[V-11_0C1],
[V-11_0C2],
[V-11_W01],
[V-11_W02],
[V-11_W03],
[V-11_W04],
[V-11_W05],
[V-11_W06],
[V-11_W07],
[V-11_W08],
[V-11_W09],
[V-11_W10],
[V-11_W11],
[V-11_W12],
[V-11_W13],
[V-11_W14],
[V-11_W15],
[V-11_YY],
[V-11_ZZ]--,

--[V-02_0A1],
--[V-02_0A2],
--[V-02_0A3],
--[V-02_0A4],
--[V-02_YY] ,
--[V-02_ZZ]
)
) pvt
)              ewin            on  ERPI.ElectrodeLotNumber=ewin.barcode
			 WHERE /*DPP.LineCode = 'ELECTRODE LINE' 			 and */ 
			 ( b.CreateDateTime between @FromDate   and  @ToDate
			 )
			 and b.Barcode is not null
			 	--and MM2.Materialtypecode<>'FERT'
				and si.MaterialCode not like '%ECVT%'

		) A
		--LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC	 with(nolock) 	  ON BC.ItemCode = A.ElectrodeRouteName		 AND BC.CodeGroup = '@ElectrodeRouteGroup'
		LEFT OUTER JOIN STB_MaterialMaster MM2  with(nolock) ON A.MaterialCode = mm2.MaterialCode
		LEFT OUTER JOIN [dbo].[fn_VVT_ElectrodeCodeStagePrice]() uprice  ON A.MaterialCode = uprice.ELECCODE
		OUTER apply( 
				select top 1 valweight 
				from [dbo].[fn_VVT_ElectrodeTYPEweight]() eweight2 
				where MM2.MaterialName like '%' + eweight2.model + '%' 
				) eweight3

		outer apply(

	       select top 1 (meter/weight1*1.0) as wmeter from  [dbo].[fn_VVT_ElecMixingKg2Met]() emeterMixing
	       where 
			(A.MaterialName like ('%'+emeterMixing.type1 + '%'+emeterMixing.construct + '%'+ emeterMixing.thick+ '%'+emeterMixing.batch+ '%'+emeterMixing.anodecathode+'%')
			or A.MaterialName like ('%'+emeterMixing.type1 + '%'+ emeterMixing.thick+'%'+emeterMixing.construct +  '%'+emeterMixing.batch+ '%'+emeterMixing.anodecathode+'%')
			or  A.MaterialName like ('%'+emeterMixing.type1 + '%'+emeterMixing.construct + '%'+ emeterMixing.thick+ '%'+emeterMixing.anodecathode+'%') and (	   
														select count(*) from   [dbo].[fn_VVT_ElecMixingKg2Met]() emeterMixing
														 where 			A.MaterialName like ('%'+emeterMixing.type1 + '%'+emeterMixing.construct + '%'+ emeterMixing.thick+ '%'+emeterMixing.batch+ '%'+emeterMixing.anodecathode+'%')
																	 or A.MaterialName like ('%'+emeterMixing.type1 + '%'+ emeterMixing.thick+'%'+emeterMixing.construct +  '%'+emeterMixing.batch+ '%'+emeterMixing.anodecathode+'%')
														 )=0
			)
	   )  meterMixing


	 WHERE 1=1		
		AND (@ElectrodeRouteName = '*' OR A.ElectrodeRouteName = @ElectrodeRouteName)		
		--AND ((@CompanyCode = '*') OR ( A.CompanyCode = @CompanyCode) or  
		and (  isnull(@pRnD,'')<>'RnD' and A.createuserid not in ('42205001','42304044')  or A.createuserid in ('42205001','42304044') and  isnull(@pRnD,'')='RnD'  ) 
		--and jobdate >= @FromDate and jobdate<=@ToDate
		and @pWorkCenterCode IS NULL OR Factory LIKE '%' + @pWorkCenterCode + '%' --update here
		and (ElectrodeLotNumber like 'VV%' or case when ElectrodeLotNumber like 'VV%' then ( isnull(A.BadQty,0)*isnull(eweight3.valweight,0)  + wasteKg) else wasteKg end>0)
		order by jobdate,ElectrodeLotNumber,ElectrodeRouteName 		

END 



--ChangeUserID
--42304044
--select top 1 * from STB_ElectrodeMixInfo
--where CreateUserID in ('42205001','42304044')  and CreateDateTime>'2023-08-20'
--or ElectrodeLotNumber='VVNQ2120001E13'

