
/* exec usp_VVT_ESRdata_get '2022-01-26','2022-01-26',''   */

CREATE  PROCEDURE [dbo].[usp_VVT_ESRdata_RealTime]
						@pDAY float=1,
						@pHOUR float=0,
						@pLineCode VARCHAR(20) = NULL,	
						@pMaterialCode VARCHAR(30) = NULL,
						@pLotNo  VARCHAR(30) = NULL,
						@pShowRepair varchar(20)='Repair'

AS

	--DECLARE @FromDate DATETIME = @pFromDate
	--DECLARE @ToDate DATETIME = @pToDate
	--DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END


	Declare  @pToDate    datetime  =  dateadd(hour,1,getdate());
	declare  @pFromDate  datetime  =  dateadd(DAY,-isnull(@pDAY,0),getdate());
	set      @pFromDate            =  dateadd(hour,-isnull(@pHOUR,0),getdate());


	DECLARE @FromDate   VARCHAR(19)   = CONVERT(VARCHAR(19), @pFromDate, 120)   --case when datepart(HOUR,@pFromDate)>0  and datepart(HOUR,@pFromDate)<22 then CONVERT(VARCHAR(19), @pFromDate, 120) else CONVERT(VARCHAR(10), @pFromDate, 120)+' 10:00:00' end                                                           -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19)  = CONVERT(VARCHAR(19), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120)  -- case when datepart(HOUR,@pToDate)>0  and datepart(HOUR,@pToDate)<22 then CONVERT(VARCHAR(19), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) else CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120)+' 10:00:00' end                                           -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    		
	

	DECLARE	@LineCode     VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END	
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '%' ELSE @pMaterialCode END

BEGIN
	SET NOCOUNT ON;


--	update STB_VVT_ESRDATA 
--set inspecttime='2022-01-01'
--where   id>=1500000 and linecode in('BigSize','VPCBending','VVC-07','VVC-04') and inspecttime>'2022-08-11 18:00:00' 
--and inspectvalue>1000;

--update STB_VVT_ESRDATA 
--set inspecttime='2022-02-02'
--WHERE INSPECTTIME > '2022-09-07' AND inspectime<'2022-09-06';

exec [usp_VVT_ESRMONITOR] @load=0


update STB_VVT_ESRDATA
set linecode='OQC'
where machinecode='DataQC' and inspecttime> dateadd(day,-10, getdate())




	if (@pFromDate>='2022-12-30')
	begin
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
			 , case when ed.materialcode is null or ed.materialcode='' then mbi.ModelSize  + '('+(mbi.MBIExtText05) + 'F)'  else ed.materialcode end	  as materialcode
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
			where inspecttime >= @FromDate and inspecttime <= @ToDate
			and ( @LineCode='*' or linecode=@LineCode)
			and linecode <> isnull(@pShowRepair,'')
	     RETURN;
	end



	ELSE IF (@pFromDate>='2022-08-12')
	BEGIN
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
			 , case when ed.materialcode is null or ed.materialcode='' then mbi.ModelSize  + '('+(mbi.MBIExtText05) + 'F)'  else ed.materialcode end	  as materialcode
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
			where inspecttime >= @FromDate and inspecttime <= @ToDate
			and ( @LineCode='*' or linecode=@LineCode)
			and linecode <> isnull(@pShowRepair,'')
	 --  UNION ALL
		--select
		--'VVT' as CompanyCode
		--,CompanyCode  as Barcode

		--			  , Case When (inspectvalue) <  1 THEN (inspectvalue) * 1000  ELSE (inspectvalue) END AS inspectvalue

		--			  , Case When (inspectvalue1) <  1 THEN (inspectvalue1) * 1000 ELSE (inspectvalue1) END AS inspectvalue1

		--			  , Case When inspectvalue2 <  1 THEN inspectvalue2 * 1000 ELSE inspectvalue2 END AS inspectvalue2

		--			  , Case When inspectvalue3 <  1 THEN inspectvalue3 * 1000 ELSE inspectvalue3 END AS inspectvalue3

		--			  , Case When inspectvalue4 <  1 THEN inspectvalue4 * 1000 ELSE inspectvalue4 END AS inspectvalue4

		-- , ip
		-- ,  inspectime
		-- , case when linecode like 'VV%' then right(linecode,2) else linecode end as line_num
		-- , linecode 	 
		-- , case when ed.materialcode is null or ed.materialcode='' then mbi.ModelSize  + '('+(mbi.MBIExtText05) + 'F)'  else ed.materialcode end	  as materialcode
		-- ,  COMPort
	 	 
		-- , (case  when   (DATEPART(HOUR, inspecttime)>10)     or    (DATEPART(HOUR, inspecttime)=10 and DATEPART(MINUTE, inspecttime)>0)     
		--			then     convert(varchar(10),inspecttime,120)    
		--			else    convert(varchar(10),DATEADD(DAY, -1,  inspecttime),120)       
		--			end 
		--	 )    as inspectDate

		--from STB_VVT_ESRDATA_20221230 ed with(nolock)
		--		left outer join STB_SetInfo si with(nolock) on ed.CompanyCode = si.Barcode 
		--		  outer apply  ( 
		--			  select top 1 MBIExtText05,right('0' + convert(varchar(2),convert(INT,MBISizeW)),2) + 
		--						right('0'+convert(varchar(2),convert(INT,MBISizeH)),2) as  ModelSize	
		--			  from STB_ModelBasicInfo  with(nolock) 
		--			  where ModelCode=si.MaterialCode --and MaterialTypeCode='FERT'
		--		  ) mbi  
		--where inspecttime >= @FromDate and inspecttime <= @ToDate
		--and ( @LineCode='*' or linecode=@LineCode)
	  return;
	END 




	ELSE
	begin

		SELECT top 10000000		
				case when substring(convert(VARCHAR(19),inspecttime,120),19,1)='3' or substring(convert(VARCHAR(19),inspecttime,120),19,1)='6' or substring(convert(VARCHAR(19),inspecttime,120),19,1)='9'
					then 
					convert(VARCHAR(19),inspecttime,120)
					else convert(VARCHAR(18),inspecttime,120)
					end
					,round(inspectvalue*100,0),ip,
				 case when CompanyCode='VVT' then '' else CompanyCode end as Barcode,
				  '' as machinecode             
				  --,ip
				  , Case When max(inspectvalue) <  1 THEN max(inspectvalue) * 1000 
							--When max(inspectvalue) > 1 and max(inspectvalue)<10 THEN max(inspectvalue) * 10 
							ELSE max(inspectvalue) END AS inspectvalue
				  , Case When max(inspectvalue1) <  1 THEN max(inspectvalue1) * 1000 ELSE max(inspectvalue1) END AS inspectvalue1
				  --, Case When inspectvalue2 <  1 THEN inspectvalue2 * 1000 ELSE inspectvalue2 END AS inspectvalue2
				  , 0 as inspectvalue2
				  ,Convert(varchar(19), dateadd(hour,-2,min(inspecttime)), 120) as inspectime
				  --, Convert(datetime, left(min(inspecttime),20), 121)+2/24   as inspectime
				  
			, case  when   machinecode like '%Factory02%'  then 'F2'				   
					 when   machinecode not like '%COM%'   then RIGHT(machinecode,2) 
					 else machinecode end 
				   as  line_num 				   				   				   				   				   

			, case when linecode is null or linecode='' then dbo.fnVVT_Machine2LineCode(machinecode,COMPort,inspecttime) else linecode end
				 as   linecode   

				  --Line2 com 14,line 1 com15,line3 com12,line4 com 13 ạ anh

			-- ,case when [ip]='InsertManual' then 'InsertManual' else '' end    as [ip]

		    -- , (case when mbi.ModelSize like '%1840%' then '1840' else mbi.ModelSize end)+ '('+(mbi.MBIExtText05) + 'F)'
			,mbi.ModelSize  + '('+(mbi.MBIExtText05) + 'F)'
			  as 
			  materialcode 		
			  , case when si.MaterialCode is null and machinecode='Kiosk-Cell21' then 'ECVT30-261' else si.MaterialCode end as ModelCode
			  , convert(varchar(10), min(inspecttime), 120)  as  inspectDate                            -- 2020.06.08 kilee 추가
			 -- , Convert(datetime, left(min(inspecttime),20), 121)+2/24   as inspectDate               -- 2020.06.08 kilee 


			  FROM (
			  select * from STB_VVT_ESRDATA_20221230 with(nolock) where (isnull(@pLotNo,'')='' or CompanyCode=@pLotNo) 
			  and inspecttime >= @FromDate and inspecttime <= @ToDate and 
			  (@LineCode='*' or 
			  linecode  = @LineCode
			  or
				dbo.fnVVT_Machine2LineCode(machinecode,COMPort,inspecttime)
				 = @LineCode)
			 -- union all
			 -- select * from [STB_VVT_ESRDATA_20220114] with(nolock)  where  inspecttime >= @FromDate and inspecttime <= @ToDate and 
			 -- (@LineCode='*' or 
			 -- linecode = @LineCode or
				--dbo.fnVVT_Machine2LineCode(machinecode,COMPort,inspecttime)
				-- = @LineCode)
			  )  ed  
			  
			left outer join STB_SetInfo si with(nolock) on ed.CompanyCode = si.Barcode 
			  outer apply  ( 
				  select top 1 MBIExtText05,right('0' + convert(varchar(2),convert(INT,MBISizeW)),2) + 
							right('0'+convert(varchar(2),convert(INT,MBISizeH)),2) as  ModelSize	
				  from STB_ModelBasicInfo  with(nolock) 
				  where ModelCode=si.MaterialCode --and MaterialTypeCode='FERT'
			  ) mbi  
			 -- 			  outer apply(			  
				--select  stuff(list,1,1,'') as ModelSize
				--from (
				--		select  ',' + cast(ModelSize as varchar(30)) as [text()]
				--		from 
				--		(
				--			select distinct right('0' + convert(varchar(2),convert(INT,MBISizeW)),2) + 
				--			right('0'+convert(varchar(2),convert(INT,MBISizeH)),2) as  ModelSize					
				--			from    STB_ModelBasicInfo  with(nolock) 
				--			where	MBIExtText05  = mbi.MBIExtText05 and MaterialTypeCode='FERT'
				--		) mbi2
				--		for     xml	  path('')
				--	 ) as Sub(list)
			 -- ) mbi2

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

			,  case when linecode is null or linecode='' then dbo.fnVVT_Machine2LineCode(machinecode,COMPort,inspecttime) else linecode end
				  				
				  --Line2 com 14,line 1 com15,line3 com12,line4 com 13 ạ anh
			-- ,case when [ip]='InsertManual' then 'InsertManual' else '' end    as [ip]
		    -- , (case when mbi.ModelSize like '%1840%' then '1840' else mbi.ModelSize end)+ '('+(mbi.MBIExtText05) + 'F)'			 
			,mbi.ModelSize  + '('+(mbi.MBIExtText05) + 'F)'
			, case when si.MaterialCode is null and machinecode='Kiosk-Cell21' then 'ECVT30-261' else si.MaterialCode end 
			 		  			  
	return;
	end




	


		--SELECT top 10000000		
		--		--case when substring(convert(VARCHAR(19),inspecttime,120),19,1)='3' or substring(convert(VARCHAR(19),inspecttime,120),19,1)='6' or substring(convert(VARCHAR(19),inspecttime,120),19,1)='9'
		--		--	then 
		--		--	convert(VARCHAR(19),inspecttime,120)
		--		--	else convert(VARCHAR(18),inspecttime,120)
		--		--	end
		--		--	,round(inspectvalue*100,0),
		--			ip,
		--		 case when CompanyCode='VVT' then '' else CompanyCode end as Barcode,
		--		  '' as machinecode             
		--		  --,ip
		--		  , Case When max(inspectvalue) <  1 THEN max(inspectvalue) * 1000 
		--					--When max(inspectvalue) > 1 and max(inspectvalue)<10 THEN max(inspectvalue) * 10 
		--					ELSE max(inspectvalue) END AS inspectvalue
		--		  , Case When max(inspectvalue1) <  1 THEN max(inspectvalue1) * 1000 ELSE max(inspectvalue1) END AS inspectvalue1
		--		  --, Case When inspectvalue2 <  1 THEN inspectvalue2 * 1000 ELSE inspectvalue2 END AS inspectvalue2
		--		  , 0 as inspectvalue2
		--		  ,Convert(varchar(19), dateadd(hour,-2,min(inspecttime)), 120) as inspectime
		--		  --, Convert(datetime, left(min(inspecttime),20), 121)+2/24   as inspectime
				  
		--	, case  when   machinecode like '%Factory02%'  then 'F2'				   
		--			 when   machinecode not like '%COM%'   then RIGHT(machinecode,2) 
		--			 else machinecode end 
		--		   as  line_num 				   				   				   				   				   

		--	, case when linecode is null or linecode='' then dbo.fnVVT_Machine2LineCode(machinecode,COMPort,inspecttime) else linecode end
		--		 as   linecode   

		--		  --Line2 com 14,line 1 com15,line3 com12,line4 com 13 ạ anh

		--	-- ,case when [ip]='InsertManual' then 'InsertManual' else '' end    as [ip]

		--     --, (case when mbi2.ModelSize like '%1840%' then '1840' else mbi2.ModelSize end)+ '('+(mbi.MBIExtText05) + 'F)'

		--	 ,mbi.ModelSize  + '('+(mbi.MBIExtText05) + 'F)'
		--	  as 
		--	  materialcode 		
		--	  , case when si.MaterialCode is null and machinecode='Kiosk-Cell21' then 'ECVT30-261' else si.MaterialCode end as ModelCode
		--	  , convert(varchar(10), min(inspecttime), 120)  as  inspectDate                            -- 2020.06.08 kilee 추가
		--	 -- , Convert(datetime, left(min(inspecttime),20), 121)+2/24   as inspectDate               -- 2020.06.08 kilee 

		--	  FROM [STB_VVT_ESRDATA]  ed  with(nolock) 
			  			
		--	  left outer join STB_SetInfo si with(nolock) on ed.CompanyCode = si.Barcode 
		--	  outer apply  ( 
		--		  select top 1 MBIExtText05,right('0' + convert(varchar(2),convert(INT,MBISizeW)),2) + 
		--				right('0'+convert(varchar(2),convert(INT,MBISizeH)),2) as  ModelSize		
		--		  from STB_ModelBasicInfo  with(nolock) 
		--		  where ModelCode=si.MaterialCode  --and MaterialTypeCode='FERT'
		--	  ) mbi  
		--	 -- outer apply(			  
		--		--select  stuff(list,1,1,'') as ModelSize
		--		--from (
		--		--		select  ',' + cast(ModelSize as varchar(30)) as [text()]
		--		--		from 
		--		--		(
		--		--			select distinct right('0' + convert(varchar(2),convert(INT,MBISizeW)),2) + 
		--		--			right('0'+convert(varchar(2),convert(INT,MBISizeH)),2) as  ModelSize					
		--		--			from    STB_ModelBasicInfo  with(nolock) 
		--		--			where	MBIExtText05  = mbi.MBIExtText05 and MaterialTypeCode='FERT'
		--		--		) mbi2
		--		--		for     xml	  path('')
		--		--	 ) as Sub(list)
		--	 -- ) mbi2

		--	  where  (isnull(@pLotNo,'')='' or CompanyCode=@pLotNo) and 
		--	  inspecttime >= @FromDate and inspecttime <= @ToDate --and machinecode like '%Factory%'
		--	  and (@LineCode='*' or 
		--	  linecode = @LineCode or
		--		dbo.fnVVT_Machine2LineCode(machinecode,COMPort,inspecttime)
		--		 = @LineCode)

		--		 group by 	
		--			--case when substring(convert(VARCHAR(19),inspecttime,120),19,1)='3' or substring(convert(VARCHAR(19),inspecttime,120),19,1)='6' or substring(convert(VARCHAR(19),inspecttime,120),19,1)='9'
		--			--then 
		--			--convert(VARCHAR(19),inspecttime,120)
		--			--else convert(VARCHAR(18),inspecttime,120)
		--			--end
		--			--,round(inspectvalue*100,0),
		--			ip,
		--		 case when CompanyCode='VVT' then '' else CompanyCode end 
				              
								  
		--	, case  when   machinecode like '%Factory02%'  then 'F2'				   
		--			 when   machinecode not like '%COM%'   then RIGHT(machinecode,2) 
		--			 else machinecode end 			 			   			   				   				   				   

		--	, case when linecode is null or linecode='' then dbo.fnVVT_Machine2LineCode(machinecode,COMPort,inspecttime) else linecode end
						
		--		  --Line2 com 14,line 1 com15,line3 com12,line4 com 13 ạ anh
		--	-- ,case when [ip]='InsertManual' then 'InsertManual' else '' end    as [ip]
		--    -- , (case when mbi2.ModelSize like '%1840%' then '1840' else mbi2.ModelSize end)+ '('+(mbi.MBIExtText05) + 'F)'
		--	,mbi.ModelSize  + '('+(mbi.MBIExtText05) + 'F)'
		--	  , case when si.MaterialCode is null and machinecode='Kiosk-Cell21' then 'ECVT30-261' else si.MaterialCode end 
			 
			 
END


--select  
--case when substring(convert(VARCHAR(19),inspecttime,120),19,1)='3' or substring(convert(VARCHAR(19),inspecttime,120),19,1)='6' or substring(convert(VARCHAR(19),inspecttime,120),19,1)='9'
--then 
--convert(VARCHAR(19),inspecttime,120)
--else convert(VARCHAR(18),inspecttime,120)
--end
--,round(inspectvalue*100,0),ip,linecode,COMPort,machinecode,max(inspectvalue),min(inspecttime)
-- FROM [STB_VVT_ESRDATA] with(nolock)
-- where inspectime>'2022-04-14 10:00:00'
-- group by case when substring(convert(VARCHAR(19),inspecttime,120),19,1)='3' or substring(convert(VARCHAR(19),inspecttime,120),19,1)='6' or substring(convert(VARCHAR(19),inspecttime,120),19,1)='9'
--then convert(VARCHAR(19),inspecttime,120)
--else convert(VARCHAR(18),inspecttime,120)
--end
--,round(inspectvalue*100,0),ip,linecode,COMPort,machinecode



--select*
-- FROM [STB_VVT_ESRDATA]  ed  with(nolock) 
-- where machinecode like '%Cell01'
-- and inspecttime > '2022-01-20' and   inspecttime < '2022-01-21'





				--case when 
			 
			 /*CompanyCode<>'' and CompanyCode<>'VVT' then (select MBIExtText05+'F' from STB_ModelBasicInfo with(nolock) 
			 where ModelCode=(select materialcode from STB_SetInfo with(nolock) where barcode=CompanyCode)) 
					else  case  when*/   
					
					--machinecode like '%Factory02%'  then 'VVM-BigSize'	 
			 
					--when	machinecode like '%Cell01%'  or  
					--		machinecode like '%Cell02%'  or
					--		machinecode like '%Cell04%'	 or
					--		machinecode like '%Cell05%'  or
					--		machinecode like '%Cell09%'	 or
					--		machinecode like '%Cell10%'	 then '0813/ 0820'	 --0813
							
					--when	machinecode like '%Cell03%' or
					--		machinecode like '%Cell14%' or
					--		machinecode like '%Cell15%'	then '1030'
							  
				 --   when  machinecode like '%Cell06%' or				    
					--	  machinecode like '%Cell08%'  then '1020'	   
						  
					--when  machinecode like '%Cell07%' or							
					--	  machinecode like '%Cell10%' or 					
					--	  machinecode like '%Cell12%' or
					--	  machinecode like '%Cell13%'  then '0813' 

					--when  machinecode like '%Cell11%'   then '0825/ 0830' --0825
					
					--when  machinecode like '%Cell16%'   then '1025' 

					--when  machinecode like '%Cell17%'   then '1325' 

					--when  machinecode like '%Cell18%'   then '1320' 

					--when  machinecode like '%Cell19%'  or
					--	  machinecode like '%Cell20%'   then '1346'

					--when  machinecode like '%Cell21%'  or
					--	  machinecode like '%Cell22%'   then '1840'

					--when  machinecode like '%Manual04%'  and COMPort in ('COM15') and inspecttime>'2021-11-24 19:00:00' then '1346'
					--when  machinecode like '%Manual04%'  and COMPort in ('COM12') and inspecttime>'2021-11-22 19:00:00'  then '1840'	
					--when  machinecode like '%Manual04%'  and COMPort in ('COM9','COM14','COM12') then '1625'	  
					--when  machinecode like '%Manual04%'  and COMPort in ('COM8','COM7','COM13')  then '1859'	 					
					--when  machinecode like '%Manual04%'  and COMPort in ('COM15') and inspecttime<'2021-11-22 19:13:43'  then '1346'	  
					--when  machinecode like '%Manual04%'  and COMPort in ('COM15') and inspecttime>'2021-11-22 19:13:43'  then '1346'	  
					--when  machinecode like '%Manual04%'  then '1859'	  

					--when machinecode like '%Factory02%' or
					--	 machinecode like '%BigSize%'  then '1840' --'3562/ 3582/ 2245'

					--else ''  end 
				/*end   */ 