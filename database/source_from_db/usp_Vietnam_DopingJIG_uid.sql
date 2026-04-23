

-- =============================================       [usp_Vietnam_DopingJIG_uid] 'hihi','JIG21^JIG22'
CREATE PROCEDURE [dbo].[usp_Vietnam_DopingJIG_uid]
						@pLotNo VARCHAR(20)=null, 
						@plistJIGs VARCHAR(4000)=null
AS

BEGIN
		
	declare @ccount INT=0,
			@ccount2 INT=0;

	if(@pLotNo is null or rtrim(ltrim(isnull(@pLotNo,'')))='') begin
		select N'Thiếu dữ liệu mã LotNo' as errinfo
		return;
	end 


	DECLARE @LotNonew1 VARCHAR(20) = ''
	DECLARE @LotNonew2 VARCHAR(20) = ''
	DECLARE @LotNonew3 VARCHAR(20) = ''
	DECLARE @LotNonew4 VARCHAR(20) = ''
	DECLARE @LotNonew5 VARCHAR(20) = ''
	DECLARE @LotNonew6 VARCHAR(20) = ''
	select @LotNonew1 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@pLotNo; 
	
	select @LotNonew2 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew1 ;

	select @LotNonew3 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew2 ;

	select @LotNonew4 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew3 ;

	select @LotNonew5 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew4 ;

	select @LotNonew6 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew5 ;
		
	select @ccount = count(*) 
	from STB_SetInfo   WITH(NOLOCK) where Barcode in (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6);
	   
	if(@ccount=0)begin 
		select N'Mã LotNo không đúng, không tìm thấy trong hệ thống!' as errinfo
		return;
	end



	if(@plistJIGs is null or rtrim(ltrim(isnull(@plistJIGs,'')))='')begin
		select N'Thiếu dữ liệu mã Lot hoặc JIG QR Code' as errinfo
		return;
	end 
				

	update Stb_VVT_DopingJIG
	set Status='autoend', ChangeDateTime=getdate()	
	where status like '%run%' and EndDateTime <= getdate();

	insert into Stb_VVT_DopingJIG_History
	select JigID, LotInUsed, Status, LastJig, BeginDateTime, EndDateTime, Comment1, Comment2, getdate()
    from Stb_VVT_DopingJIG
	where status like '%autoend%'
	and ChangeDateTime > dateadd(second,5,getdate())
	


	
	select @ccount = COUNT(*)
    from Stb_VVT_DopingJIG
	where status like '%run%'
	and JigID in  (select value from dbo.fn_split_string(@plistJIGs,'^') )
	and EndDateTime>= getdate();




	select @ccount2 = COUNT(*)
    from Stb_VVT_DopingJIG
	where status like '%run%'
	and JigID in  (select value from dbo.fn_split_string(@plistJIGs,'^') )
	and EndDateTime>= getdate() and LotInUsed<>@pLotNo ;
	
	if(@ccount>0 and @ccount2=0) begin

	    select @ccount2=count(*) from dbo.fn_split_string(@plistJIGs,'^')
		
		if( @ccount2 > @ccount) begin
					insert into Stb_VVT_DopingJIG_History
				select JigID, LotInUsed, Status, LastJig, BeginDateTime, EndDateTime, Comment1, Comment2, getdate()
				from Stb_VVT_DopingJIG
				where status like '%run%';

						update Stb_VVT_DopingJIG
						set  LotInUsed=@pLotNo, 
						status='run',  
						BeginDateTime = getdate(), 
						EndDateTime = DATEADD(hour,6,getdate()),
						ChangeDateTime = getdate()
						where JigID in (select value from dbo.fn_split_string(@plistJIGs,'^') ) 
						and EndDateTime<=getdate();

				--insert into Stb_VVT_DopingJIG_History
				--select JigID, LotInUsed, Status, LastJig, BeginDateTime, EndDateTime, Comment1, Comment2, getdate()
				--from Stb_VVT_DopingJIG 
				--where status like '%run%' 
				--and JigID in (select value from dbo.fn_split_string(@plistJIGs,'^') ) ;
		 end

			select N'OK, xử lý thành công. '  + 
					N'JIG đã bắt đầu chạy từ: '+
						( select  N'LẦN '+convert(varchar(3),row_number() over(order by begindate ))+':  '+begindate +',  ' 
							from (select distinct convert(varchar(19),dateadd(hour,-2,isnull((BeginDateTime),'')),120) 
										as begindate
									from Stb_VVT_DopingJIG
									where status like '%run%'
									and JigID in  (select value from dbo.fn_split_string(@plistJIGs,'^') )
								  ) 
							begintable
							for xml path ('')	
						)
					as errinfo 
			return;
	end

		


	
	if(@ccount>0) begin
			select *, N'JIG đang trong tình trạng hoạt động, cần Hủy bỏ với Lot trước đó!' as errinfo
			from Stb_VVT_DopingJIG
			where status like '%run%' 	and EndDateTime>= getdate()
			and JigID in  (select value from dbo.fn_split_string(@plistJIGs,'^') ) ;

			return;
	end
	   

	insert into Stb_VVT_DopingJIG_History
	select JigID, LotInUsed, Status, LastJig, BeginDateTime, EndDateTime, Comment1, Comment2, getdate()
    from Stb_VVT_DopingJIG
	where status like '%run%';
	
	update Stb_VVT_DopingJIG
	set  LotInUsed=@pLotNo, 
	status='run',  
	BeginDateTime = getdate(), 
	EndDateTime = DATEADD(hour,6,getdate()),
	ChangeDateTime = getdate()
	where JigID in (select value from dbo.fn_split_string(@plistJIGs,'^') ) ;
	
	--insert into Stb_VVT_DopingJIG_History
	--select JigID, LotInUsed, Status, LastJig, BeginDateTime, EndDateTime, Comment1, Comment2, getdate()
 --   from Stb_VVT_DopingJIG 
	--where status like '%run%' 
	--and JigID in (select value from dbo.fn_split_string(@plistJIGs,'^') ) ;

	select N'OK, xử lý thành công!'  as errinfo

end

