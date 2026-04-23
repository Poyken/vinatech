
CREATE PROCEDURE [dbo].[usp_Vietnam_SlitCutter_get]
	@pFrom    datetime =null,	
	@pTo      datetime =null,	
	@pQRCODE  VARCHAR(100)=null,
	@pwarning INT = 0
AS
BEGIN

	SET NOCOUNT ON;

	if(isnull(@pwarning,0)>0) begin

		select   qrcode, begintime, isnull(endtime, getdate()) endtime, isnull(totalkm,0)totalkm, 
		warn20, 	warn40, warn60, warn70, 
		isnull(comment,'')comment, 'loc'+convert(varchar(9),id) as location, 

		isnull(case when warn20 is null then 0
					when warn40 is null then 1
					when warn60 is null then 2
					when warn70 is null then 3
					else warninglevel end,-1) as warninglevel, 

		isnull(historylot,'')historylot ,
		isnull(begintime, getdate()) createdatetime

		from STB_Vietnam_SlitCutter with(nolock)
		where  qrcode not like '%-OLD' 
		and (
		totalkm>=20000 and warn20 is not null
		or totalkm>=40000 and warn40 is not null
		or totalkm>=60000 and warn60 is not null
		or totalkm>=69000 and warn70 is not null
		)
		and (
		warn20> dateadd(day,-100,getdate() )   
		or warn40> dateadd(day,-100,getdate() )
		or warn60> dateadd(day,-100,getdate() )
		or warn70> dateadd(day,-100,getdate() )
		);
		return;
	end

	select  qrcode, begintime, isnull(endtime, getdate()) endtime, isnull(totalkm,0)totalkm, warn20, 
	warn40, warn60, warn70, isnull(comment,'')comment, 'loc'+convert(varchar(9),id) as location, isnull(historylot,'')historylot ,isnull(begintime, getdate()) createdatetime,sendEmail
	from STB_Vietnam_SlitCutter with(nolock)
	--where  qrcode not like '%-OLD' 
	order by qrcode, begintime desc

END
