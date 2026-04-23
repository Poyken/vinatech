-- ==================================================================
-- Author      : Mr.Tung
-- Create date : 2020-08
--                 J5+(L5-K5)/((K5-I5)/(J5-H5))     =  expectedday             (L5-=  (expectedday-j5)* ((K5-I5)/(J5-H5))+ k5
-- exec usp_Vietnam_ESR_growup_dayByday_get '','','','','','2021-06-16','2021-06-23'
-- =========================================================================================================
CREATE PROC [dbo].[usp_Vietnam_ESR_growup_dayByday_get]
				@pProcessUserID     Varchar(20),
				@pProcessLanguage Varchar(20),
				@pSize             Varchar(20) = null,
				@pFarad            Varchar(20) = null,
				@pLotNo            Varchar(20) = null,
				@pFromDate  Datetime = null,
				@pFromTo    Datetime = null
AS

BEGIN

	SET NOCOUNT ON;

	Declare @LotNo VARCHAR(20) = CASE WHEN ISNULL(@pLotNo, '') = '' THEN '*' ELSE @pLotNo END
	       ,@Size VARCHAR(20) = CASE WHEN ISNULL(@pSize, '') = '' THEN '*' ELSE @pSize END
		   ,@Farad VARCHAR(20) = CASE WHEN ISNULL(@pFarad, '') = '' THEN '*' ELSE @pFarad END

	if(@pLotNo is not null and @pLotNo<>'')
	begin
		select @pFromDate = '2019-01-01 00:00:00'
		select @pFromTo = getdate();
	end


	;with CollectInfo as (
		select '0813-1F' as size, 94 as internal, 130 as VEC27,145 as VEC30,155 as WEC27,145 as WEC30  union all 
		select '0820-3.3F (CY전극)' as size, 41 as internal, 55 as VEC27,70 as VEC30,80 as WEC27,75 as WEC30  union all 
		--select '' as size, 0 as internal, 0 as VEC27, 0 as VEC30, 0 as WEC27, 0 as WEC30  union all 
		select '0820-3.3F (M전극)' as size, 52 as internal, 55 as VEC27,70 as VEC30,80 as WEC27,75 as WEC30  union all 
		--select '' as size, 0 as internal, 0 as VEC27, 0 as VEC30, 0 as WEC27, 0 as WEC30  union all 
		select '0825-5F' as size, 24 as internal, 35 as VEC27,40 as VEC30,45 as WEC27,50 as WEC30  union all 
		select '0830-7F' as size, 18 as internal, 35 as VEC27,35 as VEC30,0 as WEC27,45 as WEC30  union all 
		select '1020-5F' as size, 39 as internal, 55 as VEC27,65 as VEC30,65 as WEC27,80 as WEC30  union all 
		select '1020-7F' as size, 33 as internal, 55 as VEC27,65 as VEC30,65 as WEC27,80 as WEC30  union all 
		select 'WEC 1025-7F ' as size, 27.6 as internal, 0  as VEC27,0 as VEC30,0 as WEC27,35 as WEC30  union all 
		select 'VEC 1025-7F' as size, 21.3 as internal, 27 as VEC27,0 as VEC30,0 as WEC27,0 as WEC30  union all 
		select '1025-10F' as size, 22 as internal, 25 as VEC27,35 as VEC30,37 as WEC27,45 as WEC30  union all 
		select '1030-10F(S)' as size, 18.5 as internal, 0  as VEC27,25 as VEC30,30 as WEC27,30 as WEC30  union all 
		select '1030-10F(L) ' as size, 16.5 as internal, 20 as VEC27,0 as VEC30,30 as WEC27,30 as WEC30  union all 
		select 'VET1030-10F' as size, 23 as internal, 32 as VEC27, 32 as VEC30, 32 as WEC27, 32 as WEC30  union all 
		select '1030-12F' as size, 15 as internal, 0  as VEC27,0 as VEC30,0 as WEC27,30 as WEC30  union all 
		select '1320-10F' as size, 26 as internal, 35 as VEC27,40 as VEC30,35 as WEC27,40 as WEC30  union all 
		select '1325-15F' as size, 25 as internal, 25 as VEC27,30 as VEC30,30 as WEC27,37 as WEC30  union all 
		select '1325-18F' as size, 15 as internal, 25 as VEC27,25 as VEC30,30 as WEC27,30 as WEC30  union all 
		select '1346-40F' as size, 12 as internal, 15 as VEC27,0 as VEC30,18 as WEC27,0 as WEC30  union all 
		select '2.3V 1625-50F' as size, 51 as internal, 60 as VEC27, 60 as VEC30, 60 as WEC27, 60 as WEC30  union all 
		select '1625-25F' as size, 12 as internal, 17 as VEC27,20 as VEC30,21 as WEC27,20 as WEC30  union all 
		select '1830-34F' as size, 10 as internal, 15 as VEC27,0 as VEC30,18 as WEC27,0 as WEC30  union all 
		select '1840-50F' as size, 10 as internal, 11 as VEC27,12.5 as VEC30,13.5 as WEC27,13 as WEC30  union all 
		select '1840-60F' as size, 10.6 as internal, 11 as VEC27,12.5 as VEC30,0 as WEC27,13 as WEC30  union all 
		select '3.0V 1859-100F' as size, 7.7 as internal, 0 as VEC27,10 as VEC30,0 as WEC27,12 as WEC30  union all 
		select '2.7V 1859-100F' as size, 7.7 as internal, 10 as VEC27,0 as VEC30,12 as WEC27,0 as WEC30  union all 
		select '2.3V 1840-120F' as size, 38.8 as internal, 45 as VEC27, 45 as VEC30, 45 as WEC27, 45 as WEC30  union all 
		select '2245-100F' as size, 4.5 as internal, 6 as VEC27, 6 as VEC30, 0 as WEC27, 0 as WEC30  union all 
		select '2.3V 2245-220F' as size, 16 as internal, 30 as VEC27, 30 as VEC30, 0 as WEC27, 0 as WEC30  union all 
		select '2.3V 2245-300F' as size, 16 as internal, 30 as VEC27, 30 as VEC30, 0 as WEC27, 0 as WEC30  union all 
		select '3562-360F' as size, 2.6 as internal, 3 as VEC27, 3 as VEC30, 0 as WEC27, 0 as WEC30  union all 
		select '3582-500F' as size, 2.6 as internal, 3 as VEC27, 3 as VEC30, 0 as WEC27, 0 as WEC30 
		)
		,SizeClearly as (
		select 
		substring(ltrim(rtrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(size,'(S)',''),'(L)',''),
		'(CY전극)',''),'(M전극)',''),'WEC',''),'VEC',''),'2.7V',''),'VET',''),'3.0V',''),'2.3V',''))),1,4) as size1,
		substring(ltrim(rtrim(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(size,'(S)',''),'(L)',''),
		'(CY전극)',''),'(M전극)',''),'WEC',''),'VEC',''),'2.7V',''),'VET',''),'3.0V',''),'2.3V',''))),6,4) as farad,
		*
		from
		CollectInfo
		),
		mbi as (
		select '' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2) + '' AS Size2
		,*
		from STB_ModelBasicInfo with(nolock) 
		)
		,JoinCollect as (
		select
		case when MBIExtText01='2R7' and MBIExtText03='VEC' and MBIExtText04='2.7' then SizeClearly.VEC27 
			 when MBIExtText01='2R7' and MBIExtText03='WEC' and MBIExtText04='2.7'  then SizeClearly.WEC27 
			 when MBIExtText01='3R0' and MBIExtText03='VEC' and MBIExtText04='3.0'  then SizeClearly.VEC30 
			 when MBIExtText01='3R0' and MBIExtText03='WEC' and MBIExtText04='3.0'  then SizeClearly.Wec30
		else (case when VEC27<>0 then VEC27 when VEC30<>0 then VEC30 when WEC27<>0 then WEC27 when WEC30<>0 then WEC30 else 0 end) end as customer,
		SizeClearly.*,
		mbi.*
		from mbi
		left outer join SizeClearly  on SizeClearly.size1 = mbi.size2
		)
		,LastFilter as (
		select
		case when (size like '%CY%' and modelname not like '%CY%') 
				or (size like '%M%' and modelname not like '%MSP%')
				or (size like '%VET%' and modelname not like '%VET%')
				or (size like '%L%' and modelname not like '%-L%')
				or (size like '%2.3%' and MBIExtText04 not like '%2.3%')
				or (size like '%2.7%' and MBIExtText04 not like '%2.7%')
				or (size like '%3.0%' and MBIExtText04 not like '%3.0%')
				or ModelCode in ('ECVT27-370','ECVT27-371','ECVT27-388','ECVT30-293') and size like '%S%' then 0 else customer end as customer1,
		*
		from JoinCollect
		)
		,ESRspec as (
		select 
		internal,customer,size1,size2,size,MBIExtText01,MBIExtText02,MBIExtText03 as sleeve,MBIExtText04 as voltage,farad,MBIExtText05,
		ModelCode,ModelName,MaterialTypeCode,ProductGroupCode
		,CreateDateTime,CreateUserID,ChangeDateTime,ChangeUserID,MBIExtBit01,MBISizeW,MBISizeH
		from LastFilter
		where (customer1>0 or customer1 is null) and (farad=MBIExtText05+'F' or farad is null) and customer1 is not null
		--order by size2, modelcode
		),
	Average as (select  id,
		'' + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2) + '' AS Size
		,si.barcode
		,isnull(sved.LotNo,si.barcode) as LotNo
		,isnull(sved.Farad,ESRspec.Mbiexttext05) as Farad
		,isnull(sved.productdate,si.inputdatetime) as productdate
		,isnull(sved.prodqty, si.prodqty) as prodqty
		,isnull(sved.ESR_OQC_Date, mqsr.createdatetime) as "ESR_OQC_Date"
		,isnull(sved.ESR_Result, mqsr.testvalue) as "ESR_Result"
		,isnull(sved.modelcode, ESRspec.modelcode) as modelcode
		,isnull(sved.modelname,ESRspec.modelname) as modelname
		--,MaterialTypeCode
		--,substring(modelname,CHARINDEX(' ',modelname)+1,CHARINDEX(')',modelname)-CHARINDEX('(',modelname)-1 ) as PartNo
		--,si.*
		,isnull(sved.ESR_TQC_Date,getdate()) as "ESR_TQC_Date"
		,isnull(sved.T_ESR_Result,0) as "T_ESR_Result"
		,isnull(sved.InternalSpec,ESRspec.internal) as InternalSpec
		--,isnull(sved.EstimatedArivalDateofIS,'') as EstimatedArivalDateofIS
		,case when T_ESR_Result=0 and EstimatedArivalDateofIS is null then NULL else isnull(
					--sved.EstimatedArivalDateofIS,
					(
								dateadd(
								DAY,(isnull(sved.InternalSpec,ESRspec.internal)-isnull(sved.T_ESR_Result,0))
								/(
									isnull(case when (isnull(sved.T_ESR_Result,0)-isnull(sved.ESR_Result, mqsr.testvalue))=0 then 1 else (isnull(sved.T_ESR_Result,0)-isnull(sved.ESR_Result, mqsr.testvalue))  end,1)
									/isnull(case when DATEDIFF(day, isnull(sved.ESR_OQC_Date, null ) ,  isnull(sved.ESR_TQC_Date,null ) ) =0 then 1 else  DATEDIFF(day, isnull(sved.ESR_OQC_Date, null ) ,  isnull(sved.ESR_TQC_Date,null ) ) end,1)
								)
								,isnull(sved.ESR_TQC_Date,null) 
								)				
					)
					,null
				) 
		end
		as EstimatedArivalDateofIS

		,case when T_ESR_Result=0 and EstimatedArivalDateofCS is null then NULL else isnull(
					--sved.EstimatedArivalDateofCS,
					(
						dateadd(
								DAY,(isnull(sved.CustomerSpec,ESRspec.customer)-isnull(sved.T_ESR_Result,0))
								/(
									isnull(case when (isnull(sved.T_ESR_Result,0)-isnull(sved.ESR_Result, mqsr.testvalue))=0 then 1 else (isnull(sved.T_ESR_Result,0)-isnull(sved.ESR_Result, mqsr.testvalue)) end,1)
									/isnull(case when DATEDIFF(day, isnull(sved.ESR_OQC_Date, null ) ,  isnull(sved.ESR_TQC_Date,null ) ) =0 then 1 else DATEDIFF(day, isnull(sved.ESR_OQC_Date, null ) ,  isnull(sved.ESR_TQC_Date,null ) ) end,1)
								)
								,isnull(sved.ESR_TQC_Date,null) 
								)					
					),null
				)
		 end 
		 as EstimatedArivalDateofCS

		 ,		-- L5 = (today - dateJ5)* ((K5-I5)/(dateJ5-dateH5)) - K5	
		case when (		DATEDIFF(DAY, isnull(sved.ESR_TQC_Date, null), getdate() ) 
				* 
				(
						(isnull(sved.T_ESR_Result,0)-isnull(sved.ESR_Result, mqsr.testvalue))
						/DATEDIFF(day, isnull(sved.ESR_OQC_Date, mqsr.createdatetime) ,  isnull(sved.ESR_TQC_Date,null) ) 
				) + isnull(sved.T_ESR_Result,0)														
				) < 0 
		then 0 
		else
			(		DATEDIFF(DAY, isnull(sved.ESR_TQC_Date, null), getdate() ) 
				* 
				(
						(isnull(sved.T_ESR_Result,0)-isnull(sved.ESR_Result, mqsr.testvalue))
						/DATEDIFF(day, isnull(sved.ESR_OQC_Date, mqsr.createdatetime) ,  isnull(sved.ESR_TQC_Date,null) ) 
				) + isnull(sved.T_ESR_Result,0)														
			)
		end		
		as ESR_Today
		--,(
		--							 case when (isnull(sved.T_ESR_Result,0)-isnull(sved.ESR_Result,0)) = 0 then 1 else (isnull(sved.T_ESR_Result,0)-isnull(sved.ESR_Result,0)) end
		--							 / 
		--							 case when DATEDIFF(day, isnull(sved.ESR_OQC_Date,null ) ,  isnull(sved.ESR_TQC_Date,1 ) ) =0 then 1 else DATEDIFF(day, isnull(sved.ESR_OQC_Date,null ) ,  isnull(sved.ESR_TQC_Date,1 ) ) end
									
		--						) as tung
				
			  -- exec usp_Vietnam_ESR_growup_dayByday_get '','','','','VVLL173R012614','2021-01-01','2021-06-23'
		,isnull(sved.CustomerSpec,ESRspec.customer) as CustomerSpec
		,sved.LotNo as Lotno2
		 ,mqsr.MaterialQcSampleNo,
		 mqsr.MaterialQcDetailNo
		 --, mqd.*

		from  STB_SetInfo  si  with(nolock)
		left  outer join  STB_Vietnam_ESRgrowup_dayByday  sved   with(nolock) on si.barcode = sved.LotNo
		--left  outer join  STB_ModelBasicInfo  mbi  with(nolock) on si.materialcode = mbi.modelcode
		left  outer join  STB_MaterialQcinfo  mqi with(nolock) on si.barcode = mqi.MaterialQcno
		left  outer join  STB_MaterialQcDetail  mqd with(nolock) on mqi.MaterialQcno = mqd.MaterialQcno
		left  outer join  STB_MaterialQcSampleResult mqsr with(nolock) on mqd.MaterialQcno = mqsr.MaterialQcno 
		left outer join ESRspec with(nolock) on si.MaterialCode = ESRspec.ModelCode
		where  InputDateTime  between @pFromDate  and  @pFromTo 
		and QcInspectionItemName = 'ESR' and mqsr.MaterialQcDetailNo=19 	--ESR data
		and (@LotNo = '*' or si.Barcode=@pLotNo)
		and si.Barcode like 'VV%'
		and (@Size = '*' or RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBISizeH)), 2)=@pSize)
		and (@Farad = '*' or isnull(sved.Farad,Mbiexttext05)=@pFarad )
		--and (sved.MaterialQcSampleNo = mqsr.MaterialQcSampleNo or sved.MaterialQcSampleNo is null and mqsr.MaterialQcDetailNo>0) 
		--and (sved.MaterialQcDetailNo = mqsr.MaterialQcDetailNo or sved.MaterialQcDetailNo is null and mqsr.MaterialQcDetailNo>0)
		--and (sved.MaterialQcSampleNo = mqsr.MaterialQcSampleNo or sved.MaterialQcSampleNo is null and mqsr.MaterialQcDetailNo>0) 
		--and (sved.MaterialQcDetailNo = mqsr.MaterialQcDetailNo or sved.MaterialQcDetailNo is null and mqsr.MaterialQcDetailNo>0)
		and (sved.LotNo = mqsr.MaterialQcno or sved.LotNo is null)
		--and (sved.ESR_Result = mqsr.TestValue or sved.ESR_Result is null)

		--,convert(varchar(20),isnull(mbisizew,0)) + convert(varchar(20),isnull(mbisizeh,0))  as Size
		--order by si.barcode
		)
		, avgTab as (
			select   LotNo,--MaterialQcDetailNo,MaterialQcDetailNo,
		  convert(numeric(10,2),AVG(convert(numeric(20,5),ESR_Result))) as AVG0,
		  --AVG(ESR_OQC_Date) as AVG_OQC_Date
		  CAST(AVG(CAST(ESR_OQC_Date AS FLOAT)) AS DATETIME) as  AVG_OQC_Date,
		  convert(numeric(10,2),AVG(T_ESR_Result)) as AVG1,
		  --AVG(ESR_TQC_Date) as AVG_TQC_Date
		  CAST(AVG(CAST(ESR_TQC_Date AS FLOAT)) AS DATETIME) as  AVG_TQC_Date,
		  AVG(InternalSpec) as AVG2,
		   convert(numeric(10,2),AVG(ESR_Today)) as AVG4,
		  AVG(CustomerSpec) as AVG3,
		  convert(varchar(10),CAST(MIN(CAST(EstimatedArivalDateofCS AS FLOAT)) AS DATETIME),120) as  EAD_CS,
		  convert(varchar(10),CAST(MIN(CAST(EstimatedArivalDateofIS AS FLOAT)) AS DATETIME),120) as  EAD_IS
		  --AVG(EstimatedArivalDateofCS) as EAD_CS,
		  --AVG(EstimatedArivalDateofIS) as EAD_IS
			from Average
			where ((T_ESR_Result<>0 and LotNo2 is not null) or (T_ESR_Result=0 and LotNo2 is null))
			group by   LotNo--,MaterialQcDetailNo,MaterialQcDetailNo
		 )
	select Average.*
		 ,avgTab.AVG0 as "AVG ESR_Result"
		 --,avgTab.AVG0
		 ,case when T_ESR_Result=0 and LotNo2 is not null then NULL else avgTab.AVG1 end as "AVG T_ESR_Result"
		 --,avgTab.AVG1  as "AVG T_ESR_Result"
		 ,avgTab.AVG2 as "AVG InternalSpec"
		 ,avgTab.AVG3 as "AVG CustomerSpec"
		 ,case when T_ESR_Result=0 and LotNo2 is not null then NULL else avgTab.AVG4 end as "AVG ESR_Today"
		 ,case when T_ESR_Result=0 and LotNo2 is not null then NULL else EAD_CS end as EAD_CS
		 ,case when T_ESR_Result=0 and LotNo2 is not null then NULL else EAD_IS end as EAD_IS
		-- ,isnull(
		--			EAD_CS,
		--			(
		--				dateadd(
		--						DAY,(isnull(AVG3,0)-isnull(AVG1,0))
		--						/(
		--							(isnull(AVG1,1)-isnull(AVG0, 0))
		--							/DATEDIFF(day, isnull(AVG_OQC_Date, Dateadd(DAY,2,getdate())) ,  isnull(AVG_TQC_Date, getdate()) ) 
		--						)
		--						,isnull(AVG_TQC_Date, getdate()) 
		--						)					
		--			)
		--		)
		-- as EAD_CS

		-- ,isnull(
		--			EAD_IS,
		--			(
		--				dateadd(
		--						DAY,(isnull(AVG2,0)-isnull(AVG1,0))
		--						/(
		--							(isnull(AVG1,1)-isnull(AVG0, 0))
		--							/DATEDIFF(day, isnull(AVG_OQC_Date,  Dateadd(DAY,2,getdate()) ) ,  isnull(AVG_TQC_Date, getdate()) ) 
		--						)
		--						,isnull(AVG_TQC_Date, getdate()) 
		--						)					
		--			)
		--		)
		--as EAD_IS
		 from Average join avgTab on Average.LotNo = avgTab.LotNo 
		  --and Average.id=avgTab.id

		  -- exec usp_Vietnam_ESR_growup_dayByday_get '','','','','VVLL173R012614','2021-01-01','2021-06-23'
END


--select*from
--STB_Vietnam_ESRgrowup_dayByday
--where LotNo='VVLO163R033501'

