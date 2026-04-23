

CREATE PROCEDURE [dbo].[usp_Vietnam_CancelDocLo]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocNo VARCHAR(20) ,
	@pCount numeric(10,0) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
		
	;with lstdocno as (
		select '210824000190' as DocLo 
		union all
		select '210621000165' as DocLo 
		union all 
		select '210518000147' as DocLo 
		union all 
		select '210515000189' as DocLo 
		union all 
		select '210515000179' as DocLo 
		union all 
		select '210813000011' as DocLo 
		union all 
		select '220627000218' as DocLo 
		union all 

		select '220808000023' as DocLo 
	)
	select @pCount = count(DocLo) from lstdocno
	where DocLo = @pMaterialDocNo


	select @pCount = count(MaterialDocNo) from STB_MaterialDocInfo 
	where MaterialDocNo = @pMaterialDocNo


	--Mr.Tung modify for Cancel VJ from Vietnam Factory
	if(@pCount=0)
				select @pCount = count(mdd.MaterialDocNo)
				from 
				stb_materiallotinfo mli			 with(nolock) 
				join stb_materialdoclotinfo mdli with(nolock)  on mli.LotID=mdli.LotID
				join STB_MaterialDocDetail mdd   with(nolock)   on mdli.MaterialDocDetailNo = mdd.MaterialDocDetailNo
				left outer join stb_setinfo  si			 with(nolock)  on si.barcode = mli.lotno
				left outer join STB_ProdRouteHist prh		 with(nolock)   on si.ControlNo = prh.ControlNo
				where  prh.RouteCode >= 'V-27' and mdd.MaterialDocNo=@pMaterialDocNo
				--mli.lotno='VJLN283R036716' and 
	
END
