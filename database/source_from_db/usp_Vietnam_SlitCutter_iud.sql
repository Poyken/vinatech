
CREATE PROCEDURE [dbo].[usp_Vietnam_SlitCutter_iud]
	@pQRCODE  VARCHAR(100)=null,
	@pBarcode VARCHAR(100)=null,
	@pComment NVARCHAR(1000)=null
AS
BEGIN

	declare @count int =0;
	declare @met float =0;
	declare @maxid int =0;
	declare @needcheck int=0;
	declare @errr NVARCHAR(4000)='',@warn20 datetime,@warn40 datetime,@warn60 datetime,@warn70 datetime;
		declare @totalkm1 float=0;
		declare @buffer float=500;


	set @pBarcode=rtrim(ltrim(upper(@pBarcode)));
	set @pQRCODE = rtrim(ltrim(upper(@pQRCODE)));

	SET NOCOUNT ON;

	select  @count = count(*)
	from STB_Vietnam_SlitCutter with(nolock)
	where  replace(upper(qrcode),'-OLD','') = (@pQRCODE);

	if(@count=0) begin
		set @errr= N'Sai mã-dao cắt, hoặc không tồn tại mã-dao cắt này: ' +@pQRCODE 
		select @errr;
		return;
	end


	select  @maxid = max(id)
		from STB_Vietnam_SlitCutter with(nolock)
		where  replace(upper(qrcode),'-OLD','') = (@pQRCODE);

	


		select  @totalkm1 = totalkm, @needcheck=isnull(needcheck,0),@warn20 = warn20 , @warn40 = warn40,@warn60=warn60,@warn70=warn70
		from STB_Vietnam_SlitCutter with(nolock)
		where id=@maxid;


	if(@pBarcode='KIEMTRA') begin		
		if(@totalkm1>=20000 and @totalkm1<20000+@buffer
		or @totalkm1>=40000 and @totalkm1<40000+@buffer
		or @totalkm1>=60000 and @totalkm1<60000+@buffer 
		or @totalkm1>=70000) 
		begin
			update STB_Vietnam_SlitCutter
				set needcheck=-1
				where id=@maxid;
			
			update STB_Vietnam_SlitCutter 
			set comment = isnull(comment,'') + ' - ' + @pBarcode 
			where id=@maxid; 
				
			set     @errr= N'OK, THANH CONG Bạn có thể tiếp tục sử dụng dao cắt: '+@pQRCODE
			select  @errr;
		end
	end
	else 
	if(@pBarcode='THAYTHE') begin
		
		update STB_Vietnam_SlitCutter 
		set comment = isnull(comment,'') + ' - ' + @pBarcode ,   qrcode=qrcode+'-OLD' , endtime=isnull(endtime,getdate())
		where id=@maxid; 


		update STB_Vietnam_SlitCutter 
		set   qrcode=qrcode+'-OLD' , endtime=isnull(endtime,getdate())
		where  replace(upper(qrcode),'-OLD','') = (@pQRCODE) and upper(qrcode) not like '%-OLD'
		

		insert into STB_Vietnam_SlitCutter (qrcode,	begintime,	totalkm,comment,historylot) 
		values (@pQRCODE, getdate(), 0,'','');
		
		begin try
		insert into STB_Vietnam_SlitCutterHistory (qrcode,barcode, createdatetime) values (@pQRCODE,@pBarcode,getdate());
		end try
		begin catch
		end catch

		set     @errr= N'OK, THANH CONG Thay đổi mã Dao: ' + @pQRCODE 
		select  @errr;

	end
	else 
	begin

		select @met=GoodQty 
		from STB_ElectrodeRollPressingInfo with(nolock) 
		where ElectrodeLotNumber = SUBSTRING(rtrim(ltrim(@pBarcode)),1,14) 

		if(isnull(@met,0)=0) begin 
			set     @errr= N'Sai mã lot Điện cực, hoặc chưa nhập Rollpress Điện cực: ' + @pBarcode 
			select  @errr; 
			return; 
		end 
		

		select  @errr = (select top 1 Item from dbo.fnSplitToTable(',',(select Item from dbo.fnSplitToTable(@pBarcode, replace(historylot,@pBarcode,@pBarcode+' '+qrcode) ) where RowNo=2)))
		from STB_Vietnam_SlitCutter with(nolock)
		where  upper(historylot) like '%'+@pBarcode+'%'
	
		select  @count=count(*)
		from STB_Vietnam_SlitCutter with(nolock)
		where  upper(historylot) like '%'+@pBarcode+'%'
		
		if(@count>0) begin 
			set     @errr= N'Mã Lót điện cực: '+@pBarcode+N' đã được đưa vào dao Cắt: ' + @errr 
			select  @errr;
			return; 
		end 		
		
		if(@needcheck <> -1 )
		if(@totalkm1>=20000 and @totalkm1<20000+@buffer
			or @totalkm1>=40000 and @totalkm1<40000+@buffer
			or @totalkm1>=60000 and @totalkm1<60000+@buffer 
			or @totalkm1>=70000) begin

			if(@totalkm1>=70000 ) 
				set     @errr= N'Dao cắt `'+@pQRCODE+N'` đã đến khoảng cách cần thay !!! Length=' + convert(varchar(5),@totalkm1) +' meters'
			if(@totalkm1>=20000 and @totalkm1<20000+@buffer and @warn20 is null)
				set     @errr= N'Dao cắt `'+@pQRCODE+N'` đã đến khoảng cách cần kiểm tra lưỡi ! Length=' + convert(varchar(5),@totalkm1) +' meters'
			if(@totalkm1>=40000 and @totalkm1<40000+@buffer and @warn40 is null)
				set     @errr= N'Dao cắt `'+@pQRCODE+N'` đã đến khoảng cách cần kiểm tra lưỡi ! Length=' + convert(varchar(5),@totalkm1) +' meters'
			if(@totalkm1>=60000 and @totalkm1<60000+@buffer and @warn60 is null)
				set     @errr= N'Dao cắt `'+@pQRCODE+N'` đã đến khoảng cách cần kiểm tra lưỡi ! Length=' + convert(varchar(5),@totalkm1) +' meters'
			update STB_Vietnam_SlitCutter
			set needcheck=1
			where id=@maxid;

			select  @errr;
			return; 
		end


		if(@totalkm1 between 0 and 20000
			or @totalkm1 between 20000+@buffer and 40000
			or @totalkm1 between 40000+@buffer and 60000
			or @totalkm1 between 60000+@buffer and 70000)
					update STB_Vietnam_SlitCutter
					set needcheck=0
					where id=@maxid and isnull(needcheck,0)<>0;

		
		update STB_Vietnam_SlitCutter 
		set historylot = isnull(historylot,'') + @pBarcode +'_'+ convert(varchar(19), dateadd(hour,-2,getdate()),120 ) + ',',
			totalkm = isnull(totalkm,0) + @met , 
			warn20 = case when (isnull(totalkm,0) + @met)>=20000 and warn20 is null  then getdate() else warn20 end , 
			warn40 = case when (isnull(totalkm,0) + @met)>=40000 and warn40 is null  then getdate() else warn40 end , 
			warn60 = case when (isnull(totalkm,0) + @met)>=60000 and warn60 is null  then getdate() else warn60 end , 
			warn70 = case when (isnull(totalkm,0) + @met)>=69000 and warn70 is null  then getdate() else warn70 end 
		where id=@maxid; 
		
		begin try
		insert into STB_Vietnam_SlitCutterHistory (qrcode,barcode, createdatetime) values (@pQRCODE,@pBarcode,getdate());
		end try
		begin catch
		end catch

		set      @errr= N'OK, THANH CONG Scan mã Lót '+@pBarcode+N' để cộng vào độ dài cắt của mã Dao: ' + @pQRCODE 
	    select   @errr; 

	end 

END 





