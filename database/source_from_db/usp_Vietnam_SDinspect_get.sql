-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-19
-- Browsable : true
-- =============================================
CREATE  PROCEDURE [dbo].[usp_Vietnam_SDinspect_get]
	@pFromDate date = null,
	@pToDate date = null,
	@pCount varchar(10)=null
AS
BEGIN
	SET NOCOUNT ON;
     
if (@pCount <> '' and @pCount is not null)
begin	 

	;with tung0 as (
		SELECT 
		codeparam,
		Lotno as "oldLotno", 
		date,
		SUBSTRING(Lotno,CHARINDEX('VV',Lotno),20) as lotno,
		len(REVERSE(SUBSTRING(Lotno,CHARINDEX('VV',Lotno),20))) as leng,
		CHARINDEX('VV',REVERSE(SUBSTRING(Lotno,CHARINDEX('VV',Lotno),20))) as index1
		FROM
		stb_SDParam SDT  with(nolock) 
		where lotno like '%VV%'
		and  date  between  @pFromDate  and  @pToDate
	),
	tung10 as (
		select 
		--"oldLotno",
		date,
		--lotno,
		upper(substring(replace(replace(SUBSTRING(lotno,leng-index1,20),'ㄱ',''),' ',''),1,14)) as lotno,
		svt.Result
		from tung0
		left outer join stb_SDValueTest svt  with(nolock)  on tung0.codeparam = svt.IDParam
		where len(lotno)>=14 and Result is not null
		group by date,svt.Result,upper(substring(replace(replace(SUBSTRING(lotno,leng-index1,20),'ㄱ',''),' ',''),1,14)) 
	)
	select date,si.InputLineCode , Result, count(*) as Total
		from	tung10 
		left outer join STB_SetInfo si  with(nolock) on tung10.lotno = si.Barcode
		group by date,si.InputLineCode , Result
		--order by date,InputLineCode,Result


end
else
begin

	;with tung as (
		SELECT 
		codeparam,
		Lotno as "oldLotno", 
		date,
		SUBSTRING(Lotno,CHARINDEX('VV',Lotno),20) as lotno,
		len(REVERSE(SUBSTRING(Lotno,CHARINDEX('VV',Lotno),20))) as leng,
		CHARINDEX('VV',REVERSE(SUBSTRING(Lotno,CHARINDEX('VV',Lotno),20))) as index1
		FROM
		stb_SDParam SDT  with(nolock) 
		where lotno like '%VV%'
		and  date  between  @pFromDate  and  @pToDate 
	),
	tung1 as (
		select 
		--"oldLotno",
		date,
		--lotno,
		upper(substring(replace(replace(SUBSTRING(lotno,leng-index1,20),'ㄱ',''),' ',''),1,14)) as lotno,
		svt.*
		from tung
		left outer join stb_SDValueTest svt  with(nolock)  on tung.codeparam = svt.IDParam
		where len(lotno)>=14 and Result is not null
		--group by date,svt.Result,lotno
	)
	select tung1.*, si.InputLineCode --date,si.InputLineCode , Result, count(*)
		from	tung1 
		left outer join STB_SetInfo si  with(nolock) on tung1.lotno = si.Barcode
		--order by date,InputLineCode,lotno
		--group by date,si.InputLineCode , Result

end


END

--       usp_Vietnam_SDinspect_get  '2021-05-18','2021-05-19','count'