-- =============================================
-- Author : Mr.Tung
-- Modified : 
-- 2021-06-19 : Mr.Tung  adding LotID columns
--        exec usp_Vietnam_TappingBennding_get_test2 '','','2024-01-01','2024-12-30','tapping' 
-- =============================================

CREATE PROC [dbo].[usp_Vietnam_TappingBennding_get_test2]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATETIME = NULL,
	@pTodate  DATETIME = NULL,
	@pType VARCHAR(20) = NULL,
	@pTapingTQC VARCHAR(30) = NULL,
	@pMarking varchar(50)=NULL
AS
BEGIN
	SET NOCOUNT ON;
	declare @FromDate varchar(19) = convert(varchar(10),@pFromDate,120) + ' 10:00:00'
	declare @Todate varchar(19) = convert(varchar(10),dateadd(DAY,1,@pTodate),120) + ' 10:00:00'
		
	select @pType = isnull(@pType,'Tapping')
		
	;with  weight1 as (
  select '0813' as model, '0.354' as [V-22],  '0.58' as [V-23],  '1.003' as [V-24],  '1.0547' as [V-25], '1.0547' as [V-26], '1.0547' as [V-27], '1.0547' as [V-28]  union all 
  select '0820' as model, '0.569' as [V-22],  '0.801' as [V-23],  '1.45' as [V-24],  '1.6389' as [V-25], '1.6389' as [V-26], '1.6389' as [V-27], '1.6389' as [V-28]  union all 
  select '0825' as model, '0.7' as [V-22],  '0.92' as [V-23],  '2.404' as [V-24],  '2.0625' as [V-25], '2.0625' as [V-26], '2.0625' as [V-27], '2.0625' as [V-28]  union all 
  select '0830' as model, '0.7' as [V-22],  '0.92' as [V-23],  '2.073' as [V-24],  '2.2' as [V-25], '2.2' as [V-26], '2.2' as [V-27], '2.2' as [V-28]  union all 
  select '1020' as model, '0.703' as [V-22],  '1.105' as [V-23],  '2.031' as [V-24],  '2.43' as [V-25], '2.43' as [V-26], '2.43' as [V-27], '2.43' as [V-28]  union all 
  select '1025' as model, '0.86' as [V-22],  '1.26' as [V-23],  '2.46' as [V-24],  '2.5' as [V-25], '2.5' as [V-26], '2.5' as [V-27], '2.5' as [V-28]  union all 
  select '1030' as model, '1.065' as [V-22],  '1.463' as [V-23],  '2.961' as [V-24],  '3.137' as [V-25], '3.137' as [V-26], '3.137' as [V-27], '3.137' as [V-28]  union all 
  select '1035' as model, '1.065' as [V-22],  '1.463' as [V-23],  '2.961' as [V-24],  '3.137' as [V-25], '3.137' as [V-26], '3.137' as [V-27], '3.137' as [V-28]  union all 
  select '1320' as model, '1.375' as [V-22],  '2.001' as [V-23],  '3.44' as [V-24],  '3.9167' as [V-25], '3.9167' as [V-26], '3.9167' as [V-27], '3.9167' as [V-28]  union all 
  select 'WEC3R0106QD-C040' as model, '1.375' as [V-22],  '2.001' as [V-23],  '3.44' as [V-24],  '3.9167' as [V-25], '3.9167' as [V-26], '3.449' as [V-27], '3.9167' as [V-28]  union all 
  select '1325' as model, '1.48' as [V-22],  '2.2' as [V-23],  '4.28' as [V-24],  '4.6472' as [V-25], '4.6472' as [V-26], '4.6472' as [V-27], '4.6472' as [V-28]  union all 
  select '1346' as model, '2.689' as [V-22],  '3.334' as [V-23],  '7.642' as [V-24],  '8.106' as [V-25], '8.106' as [V-26], '8.106' as [V-27], '8.106' as [V-28]  union all 
  select '1625' as model, '2.377' as [V-22],  '3.807' as [V-23],  '7.798' as [V-24],  '7' as [V-25], '7' as [V-26], '7' as [V-27], '7' as [V-28]  union all 
  select '1830' as model, '2.377' as [V-22],  '3.807' as [V-23],  '7.798' as [V-24],  '7' as [V-25], '7' as [V-26], '7' as [V-27], '7' as [V-28]  union all 
  select '1840' as model, '2.377' as [V-22],  '3.807' as [V-23],  '7.798' as [V-24],  '7' as [V-25], '7' as [V-26], '7' as [V-27], '7' as [V-28]  union all 
  select '1859' as model, '2.377' as [V-22],  '3.807' as [V-23],  '7.798' as [V-24],  '7' as [V-25], '7' as [V-26], '7' as [V-27], '7' as [V-28]  union all 
  select '2245' as model, '7.618' as [V-22],  '10.576' as [V-23],  '20.7' as [V-24],  '26.7857' as [V-25], '26.7857' as [V-26], '26.7857' as [V-27], '26.7857' as [V-28]  union all 
  select '2570' as model, '7.618' as [V-22],  '10.576' as [V-23],  '20.7' as [V-24],  '26.7857' as [V-25], '26.7857' as [V-26], '26.7857' as [V-27], '26.7857' as [V-28]  union all 
  select '3562' as model, '28.307' as [V-22],  '48.85' as [V-23],  '70.74' as [V-24],  '73.5333' as [V-25], '73.5333' as [V-26], '73.5333' as [V-27], '73.5333' as [V-28]  union all 
  select '3567' as model, '28.307' as [V-22],  '48.85' as [V-23],  '70.74' as [V-24],  '73.5333' as [V-25], '73.5333' as [V-26], '73.5333' as [V-27], '73.5333' as [V-28]  union all 
  select '3582' as model, '28.307' as [V-22],  '48.85' as [V-23],  '70.74' as [V-24],  '73.5333' as [V-25], '73.5333' as [V-26], '73.5333' as [V-27], '73.5333' as [V-28] 
),
weight2 as (
select model, 
cast([V-22] as numeric(10,5)) as [V-22],
cast([V-23] as numeric(10,5)) as [V-23],
cast([V-24] as numeric(10,5)) as [V-24],
cast([V-25] as numeric(10,5)) as [V-25],
cast([V-26] as numeric(10,5)) as [V-26],
cast([V-27] as numeric(10,5)) as [V-27],
cast([V-28] as numeric(10,5)) as [V-28]
 from weight1
 ),
 weight3 as (
select model, routecode , valweight
from weight2
unpivot
(
  valweight
  for routecode in ([V-22],[V-23],[V-24],[V-25],[V-26],[V-27],[V-28])
) u
),
	 rawdata as (

	select *from (
		SELECT 
			--case when	(DATEPART(HOUR,CreateDateTime)>10) or 
			--			(DATEPART(HOUR,CreateDateTime) = 10 and DATEPART(MINUTE,CreateDateTime)>=30 )
			--			then CONVERT(VARCHAR(10),CreateDateTime,120) 
			--	 else CONVERT(VARCHAR(10),DATEADD(DAY,-1,CreateDateTime),120)  end
			CreateDateTime
			as dates,
			ModelCode,
			CODEPRODUCTION,
			upper(LOTNO) as LOTNO,
			machinename,
			createuserid as workerno,
			isnull(qtylotno,0) as total,
			--QTYERROR as totalNG,
			QTYERROR,
			NAMEERROR	,
			MarkingLetters
		FROM	
			STB_VN_BENDING_TAPPING WITH(NOLOCK)
		where 
			TYPESS = case when @pType is null or @pType='' or upper(@pType)='TAPPING' then 'TAPPING' else @pType end
			and CreateDateTime between @FromDate and @Todate
			and CreateDateTime > '2021-01-01'
			and MarkingLetters like case when rtrim(ltrim(isnull(@pMarking,'')))='' then '%' else '%'+@pMarking+'%' end
			--and LOTNO like (case when @pTapingTQC is not null and @pTapingTQC<>'' then 'TQC%' else 'V%' end)
			and LotNo ='VVOR043R010514'
		) 
		rawtable

	PIVOT ( sum(QTYERROR) for nameerror in (
	[RÁCH VỎ],
	[XƯỚC CHÂN],
	[TANCHA BIẾN SẮC],
	[BẸP VỎ NHÔM],
	[NGƯỢC CỰC],
	[CONG CHÂN],
	[DỊ VẬT],
	[TRÀN DỊCH],
	[BIẾN SẮC ĐÁY],
	[RÁCH CAO SU],
	[LỒI ĐÁY],
	[BẸP ĐÁY],
	[NG MARKING],
	[THIẾU SỐ LƯỢNG],
	[NG TAPE],
	[NG ESR],
	[NG OCV],
	[LỖI KHÁC]

	/*[NGƯỢC],
	[HƯ HỎNG],
	[XƯỚC]
	[BIẾN SẮC],
	[HỦY CHÂN],
	[LỖI CHÂN],
	[BẸP THÂN],
	[NHIỄM BẨN],
	[BÓC NGƯỢC],
	[DỊ VẬT],
	[BẸP ĐÁY]*/
	) ) mypivot
	)



	select Dates,si.materialcode as ModelCode,codeproduction,LotNo,
	case when isnull(machinename,@pType+' ￡1')='May 1' then 'Tapping ￡1'
		 when isnull(machinename,@pType+' ￡1')='May 2' then 'Tapping ￡2'
		 when isnull(machinename,@pType+' ￡1')='May 3' then 'Tapping ￡3'
		 when isnull(machinename,@pType+' ￡1')='Taping ￡1' then 'Tapping ￡1'
		 when isnull(machinename,@pType+' ￡1')='Taping ￡2' then 'Tapping ￡2'
		 when isnull(machinename,@pType+' ￡1')='Taping ￡3' then 'Tapping ￡3'
		 else isnull(machinename,@pType+' ￡1') end
	as MachineName,
	--isnull(machinename,'Taping ￡1') as MachineName,
	isnull(pwi.WorkerName,'Worker Account') as WorkerName,
	MarkingLetters,
	---(case when max(total)>=6000 then max(total) else sum(total) end) as Total_Qty, 
	sum(distinct total) as Total_Qty, 
	--convert(numeric(10,2),100*((case when max(total)>=6000 then max(total) else sum(total) end)-sum(TotalNG) )/sum(convert(numeric(10,2),total)) ) as OK_rate,
	((sum(distinct total))-sum(isnull(([RÁCH VỎ])          ,0) + isnull(([XƯỚC CHÂN])        ,0) + isnull(([TANCHA BIẾN SẮC])  ,0) + isnull(([BẸP VỎ NHÔM])      ,0) + isnull(([NGƯỢC CỰC])        ,0) + isnull(([CONG CHÂN])        ,0) + isnull(([DỊ VẬT])           ,0) + isnull(([TRÀN DỊCH])        ,0) + isnull(([BIẾN SẮC ĐÁY])     ,0) + isnull(([RÁCH CAO SU])      ,0) + isnull(([LỒI ĐÁY])          ,0) + isnull(([BẸP ĐÁY])          ,0) + isnull(([NG MARKING])       ,0) + isnull(([THIẾU SỐ LƯỢNG])   ,0) + isnull(([NG TAPE])          ,0) + isnull(([LỖI KHÁC])          ,0)) )  as OK_rate,
	sum(isnull(([RÁCH VỎ])          ,0) + isnull(([XƯỚC CHÂN])        ,0) + isnull(([TANCHA BIẾN SẮC])  ,0) + isnull(([BẸP VỎ NHÔM])      ,0) + isnull(([NGƯỢC CỰC])        ,0) + isnull(([CONG CHÂN])        ,0) + isnull(([DỊ VẬT])           ,0) + isnull(([TRÀN DỊCH])        ,0) + isnull(([BIẾN SẮC ĐÁY])     ,0) + isnull(([RÁCH CAO SU])      ,0) + isnull(([LỒI ĐÁY])          ,0) + isnull(([BẸP ĐÁY])          ,0) + isnull(([NG MARKING])       ,0) + isnull(([THIẾU SỐ LƯỢNG])   ,0) + isnull(([NG TAPE])          ,0) + isnull(([LỖI KHÁC])          ,0)) as Total_NG,
	convert(numeric(10,2),100*(sum(isnull(([RÁCH VỎ])          ,0) + isnull(([XƯỚC CHÂN])        ,0) + isnull(([TANCHA BIẾN SẮC])  ,0) + isnull(([BẸP VỎ NHÔM])      ,0) + isnull(([NGƯỢC CỰC])        ,0) + isnull(([CONG CHÂN])        ,0) + isnull(([DỊ VẬT])           ,0) + isnull(([TRÀN DỊCH])        ,0) + isnull(([BIẾN SẮC ĐÁY])     ,0) + isnull(([RÁCH CAO SU])      ,0) + isnull(([LỒI ĐÁY])          ,0) + isnull(([BẸP ĐÁY])          ,0) + isnull(([NG MARKING])       ,0) + isnull(([THIẾU SỐ LƯỢNG])   ,0) + isnull(([NG TAPE])          ,0) + isnull(([LỖI KHÁC])          ,0)) )
									/case when sum(convert(numeric(10,2),total))=0 or sum(convert(numeric(10,2),total)) is null then 1 else sum(convert(numeric(10,2),total)) end ) 
										as NG_rate,
	isnull(sum([RÁCH VỎ])          ,0)                      as  [RÁCH VỎ],
	isnull(sum([XƯỚC CHÂN])        ,0)                        as  [XƯỚC CHÂN],
	isnull(sum([TANCHA BIẾN SẮC])  ,0)                              as  [TANCHA BIẾN SẮC],
	isnull(sum([BẸP VỎ NHÔM])      ,0)                          as  [BẸP VỎ NHÔM],
	isnull(sum([NGƯỢC CỰC])        ,0)                        as  [NGƯỢC CỰC],
	isnull(sum([CONG CHÂN])        ,0)                        as  [CONG CHÂN],
	isnull(sum([DỊ VẬT])           ,0)                     as  [DỊ VẬT],
	isnull(sum([TRÀN DỊCH])        ,0)                        as  [TRÀN DỊCH],
	isnull(sum([BIẾN SẮC ĐÁY])     ,0)                           as  [BIẾN SẮC ĐÁY],
	isnull(sum([RÁCH CAO SU])      ,0)                          as  [RÁCH CAO SU],
	isnull(sum([LỒI ĐÁY])          ,0)                      as  [LỒI ĐÁY],
	isnull(sum([BẸP ĐÁY])          ,0)                      as  [BẸP ĐÁY],
	isnull(sum([NG MARKING])       ,0)                         as  [NG MARKING],
	isnull(sum([THIẾU SỐ LƯỢNG])   ,0)                             as  [THIẾU SỐ LƯỢNG],
	isnull(sum([NG TAPE])          ,0)                      as  [NG TAPE],
	isnull(sum([NG ESR])          ,0)                      as  [NG ESR],
	isnull(sum([NG OCV])          ,0)                      as  [NG OCV],

	isnull(sum([LỖI KHÁC])          ,0)                      as  [LỖI KHÁC]
	, weight3.valweight as WeightUnit 
	, ISNULL(sum(isnull(([RÁCH VỎ])          ,0) + isnull(([XƯỚC CHÂN])        ,0) + isnull(([TANCHA BIẾN SẮC])  ,0) + isnull(([BẸP VỎ NHÔM])      ,0) + isnull(([NGƯỢC CỰC])        ,0) + isnull(([CONG CHÂN])        ,0) + isnull(([DỊ VẬT])           ,0) + isnull(([TRÀN DỊCH])        ,0) + isnull(([BIẾN SẮC ĐÁY])     ,0) + isnull(([RÁCH CAO SU])      ,0) + isnull(([LỒI ĐÁY])          ,0) + isnull(([BẸP ĐÁY])          ,0) + isnull(([NG MARKING])       ,0) + isnull(([THIẾU SỐ LƯỢNG])   ,0) + isnull(([NG TAPE])          ,0)+ isnull(([NG ESR])          ,0) + isnull(([NG OCV])          ,0)  + isnull(([LỖI KHÁC])          ,0)), 0) * weight3.valweight/1000 as WasteWeight
	,			(case  when   (DATEPART(HOUR, dates)>=10)     --or    (DATEPART(HOUR, dates)=10 and DATEPART(MINUTE, dates)>30)     
				then     convert(varchar(10),dates,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  dates),120)       
				end 
		 )    
		  as  JobDate

	into #t
	from rawdata
	left outer join STB_ProdWorkerInfo PWI WITH(NOLOCK) on rawdata.workerno=pwi.WorkerCode
	left outer join STB_SetInfo si with(nolock) on (rawdata.LOTNO = si.Barcode or stuff(rawdata.LOTNO,1,2,'VV') = si.Barcode)

	OUTER APPLY (select top 1 * from    weight3 
								where (SUBSTRING(codeproduction, CHARINDEX('(', codeproduction, 0) + 1, 4) = weight3.model 
											or codeproduction = weight3.model )
								and weight3.routecode ='V-27'
			   )weight3

	group by dates,si.materialcode,codeproduction,lotno,machinename,pwi.workername,MarkingLetters,weight3.valweight
	--,total
	--select *from STB_VN_BENDING_TAPPING
	--where lotno='VVLL303R033531'

		SELECT
					LotNo,
					ModelCode,
					codeproduction,
					WorkerName,
					MarkingLetters,
					Total_Qty,
					OK_rate,
					Total_NG,
					NG_rate,
					[RÁCH VỎ],
					[XƯỚC CHÂN],
					[TANCHA BIẾN SẮC],
					[BẸP VỎ NHÔM],
					[NGƯỢC CỰC],
					[CONG CHÂN],
					[DỊ VẬT],
					[TRÀN DỊCH],
					[BIẾN SẮC ĐÁY],
					[RÁCH CAO SU],
					[LỒI ĐÁY],
					[BẸP ĐÁY],
					[NG MARKING],
					[THIẾU SỐ LƯỢNG],
					[NG TAPE],
					[LỖI KHÁC],
					WeightUnit,
					WasteWeight,
					JobDate,
					[BẸP ĐÁY],
					[NG MARKING],
					[THIẾU SỐ LƯỢNG],
					[NG TAPE],
					[NG ESR],
					[NG OCV],
					MachineName,
					CASE
					--WHEN ModelCode = 'ECVT30-276' THEN Total_NG * 0.068196416381011
					--WHEN ModelCode = 'ECVT30-276' AND codeproduction = 'HY-CAP WEC3R0335QG (0820)' THEN Total_NG * 0.068196416381011
					WHEN ModelCode = 'ECVT30-270' THEN Total_NG * 0.119643996223532
					WHEN ModelCode = 'ECVT30-252' THEN Total_NG * 0.20248255063794
					WHEN ModelCode = 'ECVT30-220' THEN Total_NG * 0.0627954967186611
					WHEN ModelCode = 'ECVT30-281' THEN Total_NG * 0.0960908923352989
					WHEN ModelCode = 'ECVT30-247' THEN Total_NG * 0.115990703123016
					WHEN ModelCode = 'ECVT30-325' THEN Total_NG * 0.128810246738122
					WHEN ModelCode = 'ECVT30-250' THEN Total_NG * 0.179960639713021
					WHEN ModelCode = 'ECVT27-370' THEN Total_NG * 0.117055928123016
					WHEN ModelCode = 'ECVT30-338' THEN Total_NG * 0.179960639713021
					WHEN ModelCode = 'ECVT30-334' THEN Total_NG * 0.115990703123016
					WHEN ModelCode = 'ECVT27-386' THEN Total_NG * 0.115990703123016
					WHEN ModelCode = 'ECVT27-232' THEN Total_NG * 0.0970003075397373
					WHEN ModelCode = 'ECVT27-356' THEN Total_NG * 0.312729285
					WHEN ModelCode = 'ECVT30-288' THEN Total_NG * 0.183876144896871
					WHEN ModelCode = 'ECVT27-396' THEN Total_NG * 0.238492086494935
					WHEN ModelCode = 'ECVT30-343' THEN Total_NG * 0.358475260244777
					WHEN ModelCode = 'ECVT30-317' THEN Total_NG * 0.238492086494935
					WHEN ModelCode = 'VVWEC30-060' THEN Total_NG * 0.183876144896871
					WHEN ModelCode = 'ECVT30-345' THEN Total_NG * 0.128810246738122
					WHEN ModelCode = 'ECVT30-292' THEN Total_NG * 0.119643996223532
					WHEN ModelCode = 'ECVT30-348' THEN Total_NG * 0.238492086
					WHEN ModelCode = 'ECVT30-347' THEN Total_NG * 0.097000308
					WHEN ModelCode = 'VVWEC27-022' THEN Total_NG *  0.312729285
					WHEN ModelCode = 'ECVT30-289' THEN Total_NG *  0.183876145

					WHEN ModelCode = 'ECVT27-382' THEN Total_NG * 0.350425619352832
					WHEN ModelCode = 'ECVT30-333' THEN Total_NG * 0.350425619352832
					WHEN ModelCode = 'ECVT30-258' THEN Total_NG *  0.37912454556157
					WHEN ModelCode = 'ECVT30-346' THEN Total_NG *  0.125005085652749

					WHEN ModelCode = 'ECVT27-350' THEN Total_NG * 0.21309135
					WHEN ModelCode = 'ECVT27-358' THEN Total_NG * 0.379124546
					WHEN ModelCode = 'ECVT27-369' THEN Total_NG * 0.379124546
					WHEN ModelCode = 'ECVT30-197' THEN Total_NG * 2.319992602
					WHEN ModelCode = 'ECVT30-252' THEN Total_NG * 0.21309135
					WHEN ModelCode = 'ECVT30-260' THEN Total_NG * 0.402298993
					WHEN ModelCode = 'ECVT30-261' THEN Total_NG * 0.402298993
					WHEN ModelCode = 'ECVT30-262' THEN Total_NG * 0.201290623
					WHEN ModelCode = 'ECVT30-262' AND codeproduction ='WEC3R0156QG' THEN Total_NG * 0.201290623
					WHEN ModelCode = 'ECVT30-294' AND  codeproduction = 'HY-CAP VEC3R0387QG (3562)' THEN Total_NG * 2.319992602
					WHEN ModelCode = 'ECVT30-338' AND codeproduction ='WEC3R0106QD-C040' THEN Total_NG * 0.185988402
					WHEN codeproduction = 'HY-CAP VEC2R7506QG (1840)' THEN Total_NG * 0.379124546
					WHEN codeproduction = 'HY-CAP WEC3R0186QC (1325)' THEN Total_NG * 0.21309135
					WHEN codeproduction = 'HY-CAP VEC3R0186QC (1325)' THEN Total_NG * 0.21309135
					WHEN codeproduction = 'HY-CAP VEC3R0156QG (1325)' THEN Total_NG * 0.201290623
					-- them ms.Sao 27-07-2024
					WHEN ModelCode = 'ECVT30-275'  THEN Total_NG * 0.082515644
					 WHEN ModelCode = 'ECVT30-276' THEN Total_NG * 0.068196416381011
				

					ELSE 0.000
					END AS PRICES,
					dates
					
		FROM
				#t


	DROP TABLE #t

END			










--USE [SmartFactoryV2]
--GO

--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--create PROC [dbo].[usp_Vietnam_TappingBennding_popup]
--AS
--BEGIN
--	SET NOCOUNT ON;
--	select 'Tapping' as "Type", 'Tapping' as TypeName
--	union all
--	select 'Bending' as "Type", 'Bending' as TypeName
--END 

