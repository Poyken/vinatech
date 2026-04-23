

--  usp_VetESRdata_PowerBI_get '2021-03-17','2021-03-19', '',''
--  usp_VetESRdata_PowerBI_get '',''


--  usp_VetESRdata_PowerBI_get     6,  ''
--  usp_VetESRdata_PowerBI_get      24,  'VVC-03'


CREATE  PROCEDURE [dbo].[usp_VetESRdata_PowerBI_get]
						@pPeriodTime INT,
						@pLineCode VARCHAR(20) =Null,
						@pShowRepair varchar(20)='Repair'
AS
	
	DECLARE   @PeriodTime  INT               = @pPeriodTime * (-1)                                                           
	DECLARE	@LineCode     VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END	


BEGIN
	SET NOCOUNT ON;
	--	DECLARE @FromDate   VARCHAR(19)   = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	--//DECLARE @ToDate      VARCHAR(19)  = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    		
	--DECLARE	@LineCode     VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END	
	--DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '%' ELSE @pMaterialCode END

	
	select
	'VVT' as CompanyCode
	,CompanyCode  as Barcode

				  , Case When (inspectvalue) <  1 THEN (inspectvalue) * 1000  ELSE (inspectvalue) END AS inspectvalue

				  , Case When (inspectvalue1) <  1 THEN (inspectvalue1) * 1000 ELSE (inspectvalue1) END AS inspectvalue1

				  , Case When inspectvalue2 <  1 THEN inspectvalue2 * 1000 ELSE inspectvalue2 END AS inspectvalue2

				  , Case When inspectvalue3 <  1 THEN inspectvalue3 * 1000 ELSE inspectvalue3 END AS inspectvalue3

				  , Case When inspectvalue4 <  1 THEN inspectvalue4 * 1000 ELSE inspectvalue4 END AS inspectvalue4

	 , ip
	 ,  inspectime
	 , case when linecode like 'VV%' then right(linecode,2) else linecode end as line_num
	 , linecode 	 
	 , mbi.ModelSize  + '('+(mbi.MBIExtText05) + 'F)' 	  as materialcode
	 ,  COMPort
	 	 
	 , (case  when   (DATEPART(HOUR, inspecttime)>10)     or    (DATEPART(HOUR, inspecttime)=10 and DATEPART(MINUTE, inspecttime)>0)     
				then     convert(varchar(10),inspecttime,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  inspecttime),120)       
				end 
		 )    as inspectDate

	from STB_VVT_ESRDATA ed with(nolock)
			left outer join STB_SetInfo si with(nolock) on ed.CompanyCode = si.Barcode 
			  outer apply  ( 
				  select top 1 MBIExtText05,right('0' + convert(varchar(2),convert(INT,MBISizeW)),2) + 
							right('0'+convert(varchar(2),convert(INT,MBISizeH)),2) as  ModelSize	
				  from STB_ModelBasicInfo  with(nolock) 
				  where ModelCode=si.MaterialCode --and MaterialTypeCode='FERT'
			  ) mbi  
	where inspectime  > Convert(Varchar(20), DateAdd(hour, @PeriodTime, GETDATE()) )
	and ( @LineCode='*' or linecode=@LineCode)
	and linecode <> isnull(@pShowRepair,'')


	return;

	

		SELECT 
			case when substring(convert(VARCHAR(19),inspecttime,120),19,1)='3' or substring(convert(VARCHAR(19),inspecttime,120),19,1)='6' or substring(convert(VARCHAR(19),inspecttime,120),19,1)='9'
					then 
					convert(VARCHAR(19),inspecttime,120)
					else convert(VARCHAR(18),inspecttime,120)
					end
					,round(inspectvalue*100,0),ip,
			 'VVT'           as CompanyCode
			, '베트남법인' as CompanyName
			,case when CompanyCode='VVT' then '' else CompanyCode end as Barcode
			, '' as machinecode             
			, Case When max(inspectvalue)  <  1 THEN max(inspectvalue)  * 1000  ELSE max(inspectvalue) END AS inspectvalue
			, Case When max(inspectvalue1) <  1 THEN max(inspectvalue1) * 1000 ELSE max(inspectvalue1) END AS inspectvalue1
			, Case When max(inspectvalue2) <  1 THEN max(inspectvalue2) * 1000 ELSE max(inspectvalue2) END AS inspectvalue2
			--, Inspectime
	--		, Convert(datetime, inspectime) as inspectime
	,Convert(varchar(19), dateadd(hour,-2,min(inspecttime)), 120) as inspectime

			, case  when   machinecode like '%Factory02%'  then 'F2'				   
					 when   machinecode not like '%COM%'   then RIGHT(machinecode,2) 
					 else machinecode end 
				   as  line_num 
				   				   

			, case when linecode is null or linecode='' then dbo.fnVVT_Machine2LineCode(machinecode,COMPort,inspecttime) else linecode end
				 as   linecode   
        --,[ip]

	 -- this section below , by Mr.Tung add MaterialCode as Mr.최우석 requirement,  on  07-April-2021

	    		     ,  (case when mbi2.ModelSize like '%0825%1840%' then '1840' else mbi2.ModelSize end)+ '('+(mbi.MBIExtText05) + 'F)'
			  as 
			  modelsize
			  , case when si.MaterialCode is null and machinecode='Kiosk-Cell21' then 'ECVT30-261' else si.MaterialCode end as MaterialCode
			  , convert(varchar(10), min(inspecttime), 120)  as  inspectDate  	  
			    
			 , Convert(datetime, left(min(inspectime),20), 121)   as inspectDate                   -- 2020.06.08 kilee 

			  FROM STB_VVT_ESRDATA ed with(nolock)
			    left outer join STB_SetInfo si with(nolock) on ed.CompanyCode = si.Barcode 
			  outer apply  ( 
				  select top 1 MBIExtText05
				  from STB_ModelBasicInfo  with(nolock) 
				  where ModelCode=si.MaterialCode  and MaterialTypeCode='FERT'
			  ) mbi  
			  outer apply(			  
				select  stuff(list,1,1,'') as ModelSize
				from (
						select  ',' + cast(ModelSize as varchar(30)) as [text()]
						from 
						(
							select distinct right('0' + convert(varchar(2),convert(INT,MBISizeW)),2) + 
							right('0'+convert(varchar(2),convert(INT,MBISizeH)),2) as  ModelSize					
							from    STB_ModelBasicInfo
							where	MBIExtText05  = mbi.MBIExtText05 and MaterialTypeCode='FERT'
						) mbi2
						for     xml	  path('')
					 ) as Sub(list)
			  ) mbi2
			  WHERE 1=1
			  and linecode <> isnull(@pShowRepair,'')
				AND Convert(datetime, left(inspectime,20), 121)  > Convert(Varchar(20), DateAdd(hour, @PeriodTime, GETDATE()) )
				and (@LineCode='*' or linecode=@LineCode or dbo.fnVVT_Machine2LineCode(machinecode,COMPort,inspecttime) = @LineCode)


						 group by 	
					case when substring(convert(VARCHAR(19),inspecttime,120),19,1)='3' or substring(convert(VARCHAR(19),inspecttime,120),19,1)='6' or substring(convert(VARCHAR(19),inspecttime,120),19,1)='9'
					then 
					convert(VARCHAR(19),inspecttime,120)
					else convert(VARCHAR(18),inspecttime,120)
					end
					,round(inspectvalue*100,0),
					ip,
				 case when CompanyCode='VVT' then '' else CompanyCode end 
				         
								  
			, case  when   machinecode like '%Factory02%'  then 'F2'				   
					 when   machinecode not like '%COM%'   then RIGHT(machinecode,2) 
					 else machinecode end 			 			   			   				   				   				   

						, case when linecode is null or linecode='' then dbo.fnVVT_Machine2LineCode(machinecode,COMPort,inspecttime) else linecode end
					
				  --Line2 com 14,line 1 com15,line3 com12,line4 com 13 ạ anh
			-- ,case when [ip]='InsertManual' then 'InsertManual' else '' end    as [ip]
		     , (case when mbi2.ModelSize like '%0825%1840%' then '1840' else mbi2.ModelSize end)+ '('+(mbi.MBIExtText05) + 'F)'			 
			  , case when si.MaterialCode is null and machinecode='Kiosk-Cell21' then 'ECVT30-261' else si.MaterialCode end 

			 Order by Convert(datetime, left(min(inspectime),20), 121) desc

END


/*
select LineCode, * FROM STB_VVT_ESRDATA
where 1=1
and LineCode = 'VVC-04'
order by inspectTime desc

*/

