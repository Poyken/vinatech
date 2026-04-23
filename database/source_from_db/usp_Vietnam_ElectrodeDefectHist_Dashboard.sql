-- =============================================
-- Author: nguyentung@vina.co.kr
-- Create date: 2021-04
-- Browsable : true
-- Group :  [B802] for Vietnam Electrode report Screen
-- Description:	
-- =============================================
create PROCEDURE [dbo].[usp_Vietnam_ElectrodeDefectHist_Dashboard]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pFromDate DATE,
						@pToDate DATE,					
						@pElectrodeRouteName VARCHAR(20) = NULL,
						@pCompanyCode VARCHAR(20) = NULL,                   -- 사업장 코드 추가 (2020.10.15),            
						@pRnD VARCHAR(20) = NULL,
						@pWorkCenterCode NVARCHAR(20) = NULL  --update here
						--usp_Vietnam_ElectrodeDefectHist_get '','','2021-11-01','2021-11-30','','VVT'
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


;with 
--info as ( 
-----select 'V-11_ZZ' as defect , 'Etching-MSP 75 162' as collecter, '3.95732428698369' as upricem, '49.3559961559069' as upricekg, '0.0801792' as m2kg,  '12.4720625798212' as  kg2m 
--select 'V-01_W13' as defect , 'Etching-YP 85 116' as collecter, '0.771473352591805' as upricem, '17.7161724527135' as upricekg, '0.109714285714286' as m2kg,  '9.11458333333333' as  kg2m  union all 
--select 'V-11_ZZ', 'Forming-MSP 83 200', '4.95892743290281', '59.3741311410778', '0.08352',  '11.9731800766284' union all
--select 'V-11_ZZ', 'Etching-MSP 75 162', '3.93839507828845', '49.1199098804734', '0.0801792',  '12.4720625798212' 
--),
--infoWeight10 as (
--select 
--defect,
--collecter as matname,
--rtrim(ltrim(case when collecter like '%Forming%' then ' (-) ' 
--			when collecter like '%Etching%' then ' (+) ' else collecter end)) as collecter,
--right(rtrim(ltrim( collecter )),3) as size,
--'(8%)' as size1,
--'(7%)' as size2,
--cast (upricem as float) as upricem,
--cast (upricekg as float) as upricekg,
--cast (m2kg as float) as m2kg,
--cast (kg2m as float) as kg2m
--from info
--)
--,
--eweight as (
--select 'CEP85-120' as model, '0.06' as valweight union all 
--select 'YP(A200) 200' as model, '0.084' as valweight 

--),
--eweight2 as (
--select model, 
--cast(valweight as float) as valweight
-- from eweight
--),
--emeterMixing10 as(
--select 'YP' as type1,'85' as construct,'200' as thick,'2 BATCH' as batch,'(+)' as anodecathode,65.3 as weight1,360 as meter union 
--select 'MSP','83','200','','(+)',39.366,200  
--),
electabledist as (
select distinct barcode, ab.RouteCode, ri.RouteName, max(defectcode) as defectcode, max(ab.CreateDateTime) as CreateDateTime from STB_ElectrodeWasteInfoNew ab with(nolock)  
left outer join STB_RouteInfo ri with(nolock)  on ab.RouteCode = ri.RouteCode
where  ab.CreateDateTime between @FromDate and  @ToDate and DefectCode like 'V-%'
group by  barcode, ab.RouteCode, ri.RouteName
),
lasttable as (
	select  
	(case  when   (DATEPART(HOUR, ab.CreateDateTime)>10)     or    (DATEPART(HOUR, ab.CreateDateTime)=10 and DATEPART(MINUTE, ab.CreateDateTime)>0)     
				then     convert(varchar(10),DATEADD(hour,0,ab.CreateDateTime),120)    
				else    convert(varchar(10),DATEADD(hour,0,DATEADD(DAY, -1,  ab.CreateDateTime)),120)     
				end 
		 )  as Input_Waste,
	(case  when   (DATEPART(HOUR, ECI.CreateDateTime)>10)     or    (DATEPART(HOUR, ECI.CreateDateTime)=10 and DATEPART(MINUTE, ECI.CreateDateTime)>0)     
				then     convert(varchar(10),DATEADD(hour,0,ECI.CreateDateTime),120)    
				else    convert(varchar(10),DATEADD(hour,0,DATEADD(DAY, -1,  ECI.CreateDateTime)),120)       
				end 
		 )  as  Coating_Date,
	(case  when   (DATEPART(HOUR, ERPI.CreateDateTime)>10)     or    (DATEPART(HOUR, ERPI.CreateDateTime)=10 and DATEPART(MINUTE, ERPI.CreateDateTime)>0)     
				then     convert(varchar(10),DATEADD(hour,0,ERPI.CreateDateTime),120)    
				else    convert(varchar(10),DATEADD(hour,0,DATEADD(DAY, -1,  ERPI.CreateDateTime)),120)       
				end 
		 )  as  Rollpress_Date,
	(case  when   (DATEPART(HOUR, b.CreateDateTime)>10)     or    (DATEPART(HOUR, b.CreateDateTime)=10 and DATEPART(MINUTE, b.CreateDateTime)>0)     
				then     convert(varchar(10),DATEADD(hour,0,b.CreateDateTime),120)    
				else    convert(varchar(10),DATEADD(hour,0,DATEADD(DAY, -1,  b.CreateDateTime)),120)       
				end 
		 )  as  Slitting_Date,
	ab.barcode,
	ab.RouteCode,
	ri.RouteName,
	ab.DefectCode ,
	ab.DefectWeight as "Defect(KG)",
	null UnitMet2Kg,
	case when ab.RouteCode='V-01' or ab.DefectCode like 'V-01%' then isnull(wmeter,0)* ab.DefectWeight 
	when ab.CreateDateTime >='2024-07-01' and ab.DefectCode in ('V-02_W18') and sveepm.typenew is not null  then cast ((ab.DefectWeight*1000)/isnull(sveepm.kg2m, 0 )  as numeric(10,5)) -- công thức theo Ms.Sao. Mr.Duy thêm 2024.07.26
	when ab.DefectCode in ('V-01_W02',
	'V-01_W12',
	'V-02_W02',
	'V-02_W04',
	'V-02_W16',
	'V-03_W02',
	'V-03_W12',
	'V-11_W02',
	'V-11_W12')
	then
	cast (isnull(infoWeight.kg2m, 0 )* ab.DefectWeight as numeric(10,5))/2
	else cast (isnull(infoWeight.kg2m, 0 )* ab.DefectWeight as numeric(10,5)) end as "Defect(Meter)",
	si.MaterialCode,
	mm2.MaterialName,
	-- cast ((isnull(infoWeight.upricekg,0) * ab.DefectWeight ) as numeric(10,5)) as "WastePrice(USD)",
	--Công thức mới chị Mrs.Sao 2024-01-04
	 cast ((isnull(case when ab.RouteCode='V-01' or ab.DefectCode like 'V-01%' then isnull(wmeter,0)* ab.DefectWeight
	 when ab.DefectCode in ('V-01_W02',
	'V-01_W12',
	'V-02_W02',
	'V-02_W04',
	'V-02_W16',
	'V-03_W02',
	'V-03_W12',
	'V-11_W02',
	'V-11_W12')
	then
	cast (isnull(infoWeight.kg2m, 0 )* ab.DefectWeight as numeric(10,5))/2
	 else cast (isnull(infoWeight.kg2m, 0 )* ab.DefectWeight as numeric(10,5)) end,0) * infoWeight.upricem ) as numeric(10,5)) as "WastePrice(USD)",
	cast (infoWeight.upricem  as numeric(10,5)) PriceMeter,
	cast (infoWeight.upricekg as numeric(10,5)) PriceKg,
	isnull(ab.CreateUserID,isnull(ab.ChangeUserID,'')) as CreateUserID
	, ab.MachineCode
	, MM.MachineName,
	ebb.Factory as Factory --update here
	--ab.*
	from STB_ElectrodeWasteInfoNew ab  with(nolock) 
		left outer join STB_RouteInfo ri with(nolock)  on ab.RouteCode = ri.RouteCode
	  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI   with(nolock) on ab.Barcode = ECI.ElectrodeLotNumber
	  	  LEFT OUTER JOIN STB_MachineMaster MM  with(nolock) ON MM.MachineCode = ab.MachineCode
		LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI   with(nolock) on ab.Barcode = ERPI.ElectrodeLotNumber
		  --LEFT OUTER JOIN STB_ElectrodeSlittingResult ERPI1 on ab.Barcode = ERPI1.ElectrodeLotNumber
		  outer apply( select top 1 * from STB_ElectrodeSlittingResult   with(nolock) where ElectrodeLotNumber = ERPI.ElectrodeLotNumber  ) b --on ab.Barcode = b.ElectrodeLotNumber
	--left outer join STB_DefectInfo b on replace(a.DefectCode,'E-','V-') = b.DefectCode
		   left outer join stb_setinfo si  with(nolock) on ab.barcode = si.Barcode
	   left outer join Electrode_BN_BG ebb with(nolock) on si.MaterialCode = ebb.MaterialCode  --update here
	   left outer join STB_MaterialMaster mm2 with(nolock) on si.MaterialCode = mm2.MaterialCode 
	   	OUTER apply( 
					select top 1 valweight 
					from [dbo].[fn_VVT_ElectrodeTYPEweight]() eweight2 
					where MM2.MaterialName like '%' + eweight2.model + '%' 
		)  eweight3 
	   outer apply ( 
		   select top 1 * from [dbo].[fn_VVT_ElecErrorPriceMeter2KG]() infoWeight0 
		   where infoWeight0.defect=ab.DefectCode 
		   and (infoWeight0.collecter=right(rtrim(ltrim(mm2.MaterialName)),3) or mm2.MaterialName like '%'+infoWeight0.matname+'%')
		   --and (mm2.MaterialName like '%'+infoWeight0.matname+'%')  -- update 2025-07-29 Mr.Manh
		   and (mm2.MaterialName like '%'+ infoWeight0.size +'%' or mm2.MaterialName like '%'+ infoWeight0.size1 +'%' or mm2.MaterialName like '%'+ infoWeight0.size2 +'%')
		   --
		   -- Mr.Manh update 2025-07-31: vì add nhiều mã mới có tên không theo tiêu chuẩn lọc
		   ORDER BY 
				CASE 
					WHEN mm2.MaterialName like '%'+infoWeight0.matname+'%' THEN 1 
					ELSE 3 
				END
			-- End update
	   )  infoWeight 
	   	outer apply ( 
		   select top 1 * from STB_VVT_ElecErrorPriceMeter2KG sve
		   where 
		   1=1 
		   and sve.defect=ab.DefectCode 
		   and (sve.collecter=right(rtrim(ltrim(mm2.MaterialName)),3) or mm2.MaterialName like '%'+sve.materialname+'%')
		   and mm2.MaterialName like '%'+sve.electrolysis+'%'
		   and (mm2.MaterialName like '%'+ sve.size +'%' or mm2.MaterialName like '%'+ sve.size1 +'%' or mm2.MaterialName like '%'+ sve.size2 +'%')
		   -- 1. nếu distinguish_materialName thuộc MaterialName và không null
		   -- 2. MaterialName không được null và distinguish_materialName phải null
			AND (
			(mm2.MaterialName LIKE '%' + sve.distinguish_materialName + '%' AND sve.distinguish_materialName IS NOT NULL)
			OR 
			(mm2.MaterialName IS NOT NULL AND sve.distinguish_materialName IS NULL)
			)
			--do có những trường hợp chỉ khác nhau 1 2 kí tự nên rất khó phân biệt được khi tìm kiếm kết quả đúng với like
			-- sẽ ưu tiên theo các trường hợp bên dưới 
			-- 1. ưu tiên tìm distinguish_materialName có trong mm2.MaterialName
			-- 2. ưu tiên distinguish_materialName null
			-- 3. còn lại 
			ORDER BY 
				CASE 
					WHEN mm2.MaterialName LIKE '%' + sve.distinguish_materialName + '%' THEN 1 
					WHEN sve.distinguish_materialName IS NULL THEN 2 
					ELSE 3 
			END
	   )  sveepm 
	   outer apply( 
	   select top 1 (meter/weight1*1.0) as wmeter from  [dbo].[fn_VVT_ElecMixingKg2Met]()  emeterMixing 
	   where    mm2.MaterialName like ('%'+emeterMixing.type1 + '%'+emeterMixing.construct + '%'+ emeterMixing.thick+ '%'+emeterMixing.batch+ '%'+emeterMixing.anodecathode+'%')
			or  mm2.MaterialName like ('%'+emeterMixing.type1 + '%'+emeterMixing.construct + '%'+ emeterMixing.thick+ '%'+emeterMixing.anodecathode+'%')
	   )  meterMixing 
	where  ab.CreateDateTime between @FromDate and  @ToDate and DefectCode like 'V-%'
	
	
		--union 

		--select   
	 
		--(case  when   (DATEPART(HOUR, ab.CreateDateTime)>10)     or    (DATEPART(HOUR, ab.CreateDateTime)=10 and DATEPART(MINUTE, ab.CreateDateTime)>0)     
		--			then     convert(varchar(10),DATEADD(hour,0,ab.CreateDateTime),120)    
		--			else    convert(varchar(10),DATEADD(hour,0,DATEADD(DAY, -1,  ab.CreateDateTime)),120)     
		--			end 
		--	 )  as Input_Waste,
		--(case  when   (DATEPART(HOUR, ECI.CreateDateTime)>10)     or    (DATEPART(HOUR, ECI.CreateDateTime)=10 and DATEPART(MINUTE, ECI.CreateDateTime)>0)     
		--			then     convert(varchar(10),DATEADD(hour,0,ECI.CreateDateTime),120)    
		--			else    convert(varchar(10),DATEADD(hour,0,DATEADD(DAY, -1,  ECI.CreateDateTime)),120)       
		--			end 
		--	 )  as  Coating_Date,
		--(case  when   (DATEPART(HOUR, ERPI.CreateDateTime)>10)     or    (DATEPART(HOUR, ERPI.CreateDateTime)=10 and DATEPART(MINUTE, ERPI.CreateDateTime)>0)     
		--			then     convert(varchar(10),DATEADD(hour,0,ERPI.CreateDateTime),120)    
		--			else    convert(varchar(10),DATEADD(hour,0,DATEADD(DAY, -1,  ERPI.CreateDateTime)),120)       
		--			end 
		--	 )  as  Rollpress_Date,
		--(case  when   (DATEPART(HOUR, b.CreateDateTime)>10)     or    (DATEPART(HOUR, b.CreateDateTime)=10 and DATEPART(MINUTE, b.CreateDateTime)>0)     
		--			then     convert(varchar(10),DATEADD(hour,0,b.CreateDateTime),120)    
		--			else    convert(varchar(10),DATEADD(hour,0,DATEADD(DAY, -1,  b.CreateDateTime)),120)       
		--			end 
		--	 )  as  Slitting_Date,
		--ab.barcode,
		--ab.RouteCode,
		--ab.RouteName,
		--'Coating_Meter' as DefectCode ,
		--(( isnull(eci.BadQty,0)* isnull(isnull(infoWeight.m2kg,eweight3.valweight),0) ) ) as DefectWeight,
		--isnull(infoWeight.m2kg,eweight3.valweight) UnitMet2Kg,
		--isnull(eci.BadQty,0) as Meter_NG,
		--si.MaterialCode,
		--mm2.MaterialName,
		-- (isnull(infoWeight.upricem,0) * isnull(eci.BadQty,0) ) as WastePrice,
		--cast (infoWeight.upricem as numeric(10,5)) PriceMeter,
		--cast (infoWeight.upricekg as numeric(10,5)) PriceKg
		----ab.*
		--from electabledist ab  with(nolock) 
		--  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI   with(nolock) on ab.Barcode = ECI.ElectrodeLotNumber
		--	LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI   with(nolock) on ab.Barcode = ERPI.ElectrodeLotNumber
		--	  --LEFT OUTER JOIN STB_ElectrodeSlittingResult ERPI1 on ab.Barcode = ERPI1.ElectrodeLotNumber
		--	  outer apply( select top 1 * from STB_ElectrodeSlittingResult   with(nolock) where ElectrodeLotNumber = ERPI.ElectrodeLotNumber  ) b --on ab.Barcode = b.ElectrodeLotNumber
		----left outer join STB_DefectInfo b on replace(a.DefectCode,'E-','V-') = b.DefectCode
		--LEFT OUTER JOIN STB_SetInfo SI				 with(nolock)                    ON ab.Barcode = si.Barcode
		--		LEFT OUTER JOIN STB_MaterialMaster MM2  with(nolock) ON si.MaterialCode = mm2.MaterialCode
		--		OUTER apply( 
		--				select top 1 valweight 
		--				from eweight2 
		--				where MM2.MaterialName like '%' + eweight2.model + '%' 
		--				) eweight3
		--	OUTER apply( select top 1 * 
		--					from infoWeight0 --on --infoWeight.defect = ab.defectcode and 
		--					where infoWeight0.collecter = right(rtrim(ltrim(mm2.MaterialName)),3) 
		--					and (mm2.MaterialName like '%' + infoWeight0.size + '%' or mm2.MaterialName like '%' + infoWeight0.size1 + '%')
		--					) infoWeight

		--where  ab.CreateDateTime between @FromDate and  @ToDate and DefectCode like 'V-%'
		--and isnull(ERPI.BadQty,0)>0
		--and isnull(isnull(infoWeight.m2kg,eweight3.valweight),0)>0

		--union

		--select  
	 
		--(case  when   (DATEPART(HOUR, ab.CreateDateTime)>10)     or    (DATEPART(HOUR, ab.CreateDateTime)=10 and DATEPART(MINUTE, ab.CreateDateTime)>0)     
		--			then     convert(varchar(10),DATEADD(hour,0,ab.CreateDateTime),120)    
		--			else    convert(varchar(10),DATEADD(hour,0,DATEADD(DAY, -1,  ab.CreateDateTime)),120)     
		--			end 
		--	 )  as Input_Waste,
		--(case  when   (DATEPART(HOUR, ECI.CreateDateTime)>10)     or    (DATEPART(HOUR, ECI.CreateDateTime)=10 and DATEPART(MINUTE, ECI.CreateDateTime)>0)     
		--			then     convert(varchar(10),DATEADD(hour,0,ECI.CreateDateTime),120)    
		--			else    convert(varchar(10),DATEADD(hour,0,DATEADD(DAY, -1,  ECI.CreateDateTime)),120)       
		--			end 
		--	 )  as  Coating_Date,
		--(case  when   (DATEPART(HOUR, ERPI.CreateDateTime)>10)     or    (DATEPART(HOUR, ERPI.CreateDateTime)=10 and DATEPART(MINUTE, ERPI.CreateDateTime)>0)     
		--			then     convert(varchar(10),DATEADD(hour,0,ERPI.CreateDateTime),120)    
		--			else    convert(varchar(10),DATEADD(hour,0,DATEADD(DAY, -1,  ERPI.CreateDateTime)),120)       
		--			end 
		--	 )  as  Rollpress_Date,
		--(case  when   (DATEPART(HOUR, b.CreateDateTime)>10)     or    (DATEPART(HOUR, b.CreateDateTime)=10 and DATEPART(MINUTE, b.CreateDateTime)>0)     
		--			then     convert(varchar(10),DATEADD(hour,0,b.CreateDateTime),120)    
		--			else    convert(varchar(10),DATEADD(hour,0,DATEADD(DAY, -1,  b.CreateDateTime)),120)       
		--			end 
		--	 )  as  Slitting_Date,
		--ab.barcode,
		--ab.RouteCode,
		--ab.RouteName,

		--'Rollpress_Meter' as DefectCode ,
		-- (( isnull(ERPI.BadQty,0)* isnull(isnull(infoWeight.m2kg,eweight3.valweight),0) ) ) as DefectWeight,
		--isnull(infoWeight.m2kg,eweight3.valweight) UnitMet2Kg,
		--isnull(ERPI.BadQty,0) as Meter_NG,
		--si.MaterialCode,
		--mm2.MaterialName,
		-- (isnull(infoWeight.upricem,0) * isnull(eci.BadQty,0)) as WastePrice,
		--cast (infoWeight.upricem as numeric(10,5)) PriceMeter,
		--cast (infoWeight.upricekg as numeric(10,5)) PriceKg
		----ab.*
		--from electabledist ab 
		--  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI   with(nolock) on ab.Barcode = ECI.ElectrodeLotNumber 
		--	LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI   with(nolock) on ab.Barcode = ERPI.ElectrodeLotNumber 
		--	  --LEFT OUTER JOIN STB_ElectrodeSlittingResult ERPI1 on ab.Barcode = ERPI1.ElectrodeLotNumber 
		--	  outer apply( select top 1 * from STB_ElectrodeSlittingResult   with(nolock) where ElectrodeLotNumber = ERPI.ElectrodeLotNumber  ) b --on ab.Barcode = b.ElectrodeLotNumber
		----left outer join STB_DefectInfo b on replace(a.DefectCode,'E-','V-') = b.DefectCode 
		--LEFT OUTER JOIN STB_SetInfo SI				 with(nolock)                    ON ab.Barcode = si.Barcode 
		--		LEFT OUTER JOIN STB_MaterialMaster MM2  with(nolock) ON si.MaterialCode = mm2.MaterialCode 
		--		OUTER apply( 
		--				select top 1 valweight 
		--				from eweight2 
		--				where MM2.MaterialName like '%' + eweight2.model + '%' 
		--				) eweight3 
		--	OUTER apply( select top 1 * 
		--					from infoWeight0 --on --infoWeight.defect = ab.defectcode and 
		--					where infoWeight0.collecter = right(rtrim(ltrim(mm2.MaterialName)),3) 
		--					and (mm2.MaterialName like '%' + infoWeight0.size + '%' or mm2.MaterialName like '%' + infoWeight0.size1 + '%') 
		--					) infoWeight 

		--where  ab.CreateDateTime between @FromDate and  @ToDate and DefectCode like 'V-%' 
		--and isnull(ERPI.BadQty,0)>0 
		--and isnull(isnull(infoWeight.m2kg,eweight3.valweight),0)>0 
	) 

select lasttable.*, 
     
	     case  when di.DefectEnglishName IS NOT NULL THEN di.DefectEnglishName
	     when 'Coating_Meter' = lasttable.DefectCode then N'Coating_Lỗi Mét chuyển đổi thành KG' 
	     when 'Rollpress_Meter' = lasttable.DefectCode then N'Rollpress_Lỗi Mét chuyển đổi thành KG' 
	     else di.DefectDesc end as DefectDesc  

from lasttable 
left outer join STB_DefectInfo di   with(nolock) on lasttable.DefectCode = di.DefectCode 
where  (  isnull(@pRnD,'')<>'RnD' and lasttable.createuserid not in ('42205001','42304044')  or lasttable.createuserid in ('42205001','42304044') and  isnull(@pRnD,'')='RnD'  )
and @pWorkCenterCode IS NULL OR Factory LIKE '%' + @pWorkCenterCode + '%'  --update here
order by Barcode,Coating_Date,Rollpress_Date,Slitting_Date 

END



