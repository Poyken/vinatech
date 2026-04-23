/*  exec  usp_VVT_ESRdata_uid   '2021-07-14','2021-07-15','',''    */
CREATE  PROCEDURE [dbo].[usp_VVT_ESRdata_uid]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,  
						@pmachinecode VARCHAR(20) = NULL, 
						@pinspectvalue float = NULL,
						@pinspectvalue1  float = NULL, 
						@pinspectvalue2  float = NULL, 
						@pinspectime VARCHAR(25) = NULL,  
						@pline_num VARCHAR(20) =NULL,
						@plinecode  VARCHAR(25) = NULL,    
						@pmaterialcode  VARCHAR(25) = NULL 
AS 
BEGIN 

	SET NOCOUNT ON; 

	declare @tung varchar(30)=cast(@pinspectvalue as varchar(20))
	--raiserror (@pline_num,16,1);

	if (@pinspectvalue is null or @pinspectvalue='') return;
	if (@plinecode is null or @plinecode='') return;
	if (@pmachinecode is null or @pmachinecode='') select @pmachinecode = (case when @pline_num is not null then @pline_num else '' end);
	if (@pinspectime is null or @pinspectime='') select @pinspectime=getdate();

	insert into [SmartFactoryV2].[dbo].[STB_VVT_ESRDATA]
			(machinecode, ip,inspectvalue, inspectvalue1, inspectvalue2, inspectime, line_num, linecode,  materialcode, inspecttime)
	values	( @pmachinecode,'InsertManual', @pinspectvalue, @pinspectvalue1, @pinspectvalue2, @pinspectime, @pline_num, @plinecode, @pmaterialcode, getdate() )
	
END 
