
-- Exec [usp_Vietnam_SlittingStock_get] '', '', '2021-03-01 00:00:00', '2021-03-12 00:00:00', '', 'VVT' 
-- ============================================= 
create PROCEDURE [dbo].[usp_Vietnam_SlittingStock_get1] 
						@pProcessUserID		VARCHAR(20), 
						@pProcessLanguage VARCHAR(20),  
						@pCompanyCode		VARCHAR(20) = NULL  , 
						@pLocation		 VARCHAR(50)=NULL, 
						@pBarcode		 VARCHAR(50)=NULL 
						
AS 

BEGIN 


				--if(@pProcessUserID='nguyentung') begin		
				--	 raiserror(@pBarcode,16,1)
				--	 return;
				--	 end

set nocount off;

declare @errr nvarchar(500)=''; 
declare @eapassing varchar(20)='EA_PASS'; 
declare @count int = 0; 
declare @oldloca varchar(50) =''; 

set @pLocation=upper(isnull(@pLocation,'')) 
set @pBarcode=upper(isnull(@pBarcode,'')) 

--select * from Stb_SlittingStock_VVT  with(nolock) where barcode=@pBarcode ;

	--if(@pProcessUserID='' or @pProcessUserID is null)BEGIN
	--	SET @pProcessUserID= @pProcessLanguage
	--	set @pProcessLanguage ='';
	--END

	if ( isnull(@pLocation,'') <> '' and @pLocation not in ('SANXUAT','NG') ) begin
		
		select @count=count(*) from stb_slittinglocationconfig_vvt with(nolock) 
		where (PositiveLocation=@pLocation or NegativeLocation=@pLocation);
		if(@count<1 )  begin	
			set @errr = N'Không tồn tại Vitri Điện cực này trong thiết lập, kiểm tra hoặc liên hệ với Quản lý Điện cực: ' +@pLocation ;
			if(@pProcessLanguage<>@eapassing) begin
				raiserror (@errr,16,1);
				return;
			end
			else select @errr;
			
		end
		
	end




	if ( isnull(@pBarcode,'') <> '' ) begin	
	-- set @errr='1';
		select @count=count(*) from STB_SetInfo  si			with(nolock) 
		join STB_ElectrodeSlittingInfo esi		with(nolock) on si.Barcode = esi.ElectrodeLotNumber
		join STB_ElectrodeSlittingResult esr	with(nolock) on esi.ElectrodeLotNumber = esr.ElectrodeLotNumber
		where esr.Barcode=@pBarcode;
		if(@count<1 )  begin	
			set @errr = N'Không tồn tại mã Lot Slitting này trong hệ thống, hoặc sai mã Lot Slitting Điện cực: ' + @pBarcode ;
			if(@pProcessLanguage<>@eapassing) begin
				raiserror (@errr,16,1);
				return;
			end
			else select @errr;
			
		end
	end
	   



	declare @lstdate varchar(1000) = '';
	select @count = count(*),@lstdate=substring(max(ListDate),len(max(ListDate))-20,20) from Stb_SlittingStock_VVT sls  with(nolock) where Barcode=@pBarcode and ([location]='SANXUAT' or WarehouseCode='ROUTE_VN_WH')
	if(@count>0)begin
			set @errr = N'Lot Slitting Điện cực đã được đưa ra SẢN XUẤT từ ngày '+@lstdate;
			if(@pProcessLanguage<>@eapassing) begin
				raiserror (@errr,16,1);
				return;
			end
			else select @errr;
			
	end




--SlittingCode	SlittingSize	Farad	Width


if(@pLocation ='SANXUAT' and @pProcessUserID='') 
begin
	
	declare @prefixbarcode varchar(2) = SUBSTRING(@pBarcode,1,2);
	declare @topLotNo varchar(50)='';
	declare @eloca nvarchar(50)='';
	declare @matdata nvarchar(50)='';
	---declare @pbarcode varchar(20)='VVMR1020001E05-019'

	select top 1 @topLotNo = table2.barcode,@eloca=table2.Location,@matdata=table2.materialcode 
	from Stb_SlittingStock_VVT  table1 with(nolock)  
	join Stb_SlittingStock_VVT  table2 with(nolock)  	
	  --on --replace(table1.SlittingCode,table1.SlittingSize,'') = replace(table2.SlittingCode,table2.SlittingSize,'')  
	   --table1.SlittingSize = table2.SlittingSize   
	  on table1.PartNo = table2.PartNo 
	  and table1.Width = table2.Width  
	  and table1.Farad = table2.Farad  
	left outer join STB_ElectrodeSlittingResult esr  with(nolock)  on esr.Barcode = table2.Barcode 
	where table1.Barcode=@pBarcode  
		and table2.MaterialName like (case  when table1.MaterialName like '%(+)%'  then '%(+)%' 
											when  table1.MaterialName like '%(-)%' then '%(-)%' 
											else table1.MaterialName end)

	and table2.WarehouseCode='ELEC_VN_WH' and len(table2.Location) in (5,6)
	and table2.Barcode like 'V%'

	and case when table2.PartNo='1030' then SUBSTRING(table2.Barcode,1,2) else '1' end
						= case when table2.PartNo='1030' then @prefixbarcode else '1' end

	and  convert(varchar(10), isnull(esr.CreateDateTime,table2.CreateDateTime),120)  < 
	
		 convert(varchar(10), isnull(
				(select CreateDateTime from  STB_ElectrodeSlittingResult  with(nolock) where Barcode = @pBarcode),
				(select CreateDateTime from  Stb_SlittingStock_VVT  with(nolock) where Barcode = @pBarcode)
			  ) , 120)

	-------order by table2.id --isnull(esr.CreateDateTime,table2.CreateDateTime) ,table2.Barcode

	

	--select top 1 @topLotNo = sls.barcode,@eloca=sls.Location,@matdata=sim.materialcode 
	--FROM STB_SetInfo SIM   with(nolock) 
	--left outer join STB_ModelBasicInfo mbi  with(nolock)  on  sim.materialcode = mbi.ModelCode 
	--LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI  with(nolock)  ON  SIM.Barcode = ERPI.ElectrodeLotNumber 
	--LEFT OUTER JOIN Stb_SlittingStock_VVT sls  with(nolock) on SIM.Barcode = sls.ElectrodeLotNumber
	--OUTER APPLY (
	--	select top 1 * from STB_ElectrodeSlittingResult esr  with(nolock)  
	--	where esr.ElectrodeLotNumber = ERPI.ElectrodeLotNumber 			
	--	) esr
	--where 
	--sim.MaterialCode = (select materialcode from STB_SetInfo where Barcode=substring(@pBarcode ,1,14) )
	--and sls.Farad = convert(float,isnull(Mbi.MBIExtText05,'0') )		
	----sib.barcode= substring(@pBarcode ,1,14)
	----and sim.createdatetime < sib.createdatetime 

	--and convert(varchar(10),isnull (ERPI.CreateDateTime,   (select createdatetime from   STB_ElectrodeSlittingInfo  with(nolock)  where ElectrodeLotNumber=sim.barcode)),120)
	--    < convert(varchar(10),isnull ((select createdatetime from  STB_ElectrodeRollPressingInfo  with(nolock)  where ElectrodeLotNumber=substring(@pBarcode ,1,14) ),   (select createdatetime from   STB_ElectrodeSlittingInfo  where ElectrodeLotNumber=substring(@pBarcode ,1,14) )),120)
	--and sls.WarehouseCode='ELEC_VN_WH' and sls.Location<>'NG'
	----and SIM.Barcode like 'VV%'

	--and ERPI.GoodQty>0	
	--and sim.barcode < substring(@pBarcode ,1,14)
	--and sls.Width = (select Width from Stb_SlittingStock_VVT  with(nolock) where Barcode=@pBarcode)
	--and  ( esr.GoodQtyLength is not null   and  esr.ProductionQty is not null )
	----and (eci.CompanyCode='VVT' or eci.CompanyCode is null)
	--order by isnull ((select createdatetime from  STB_ElectrodeRollPressingInfo  with(nolock) where ElectrodeLotNumber=sim.barcode),   (select createdatetime from   STB_ElectrodeSlittingInfo  where ElectrodeLotNumber=sim.barcode))--sim.CreateDateTime,sim.barcode 
	
	
    if(@topLotNo <> @pBarcode and @topLotNo<>'' and @topLotNo is not null  ) begin 
		set  @errr = N'FIFO SLITTING: mã được Scan='+@pBarcode+N', tồn tại Lót Điện cực:      '''+@topLotNo+N'''  , mã nguyên liệu:  '''+@matdata+N'''    chưa xuất ra SX, cần xuất Lót này ở vị trí       '''+@eloca+N'''     ra SẢN XUẤT trước'; 
			--raiserror (@errr,16,1) ; 
			select  @errr;
			return; 
	end 
	else begin
		select @count=count(*) from Stb_SlittingStock_VVT  with(nolock) where Barcode=@pBarcode
		if(@count<1) begin
			set @errr=N'Lót Slitting này chưa được chuyển vào khu vực Slitting: '+@pBarcode +N'. Cần Scan vào Vị trí ở khu vực Slitting trước!';
			select @errr
			return;
		end

	end
	
end


	
	if (  isnull(@pLocation,'') <> ''  and isnull(@pBarcode,'') <> '' or @pProcessLanguage=@eapassing ) begin
	-- set @errr='2';
		;with checkWidth as (
				select mm.MaterialCode,mm.MaterialName,mm.MaterialSource,mm.MaterialThickness, esr.ElectrodeLotNumber,esr.Barcode,seq,
				esr.ElectrodeThick,esr.SlittingWidth,esr.GoodQtyLength,esr.CreateDateTime,esr.CreateUserID,esr.LotUniqueNumber
				from STB_SetInfo  si					with(nolock) 
				join STB_ElectrodeSlittingInfo   esi	with(nolock) on si.Barcode = esi.ElectrodeLotNumber
				join STB_ElectrodeSlittingResult  esr	with(nolock) on esi.ElectrodeLotNumber = esr.ElectrodeLotNumber
				left outer join STB_MaterialMaster  mm	with(nolock) on si.MaterialCode = mm.MaterialCode
				where esr.Barcode=@pBarcode 
		)
		select  @count=count(*)  from stb_slittinglocationconfig_vvt	with(nolock) 
		join checkWidth cw on (SlittingCode like '%'+cw.MaterialSource+'%' and SlittingCode like '%'+cw.MaterialThickness+'%' 
		or MaterialName like '%'+replace(SlittingCode,SlittingSize,'')+'%'+SlittingSize+'%' ) 
		and (
			Width=cw.SlittingWidth and (( case when MaterialName like '%+%' or MaterialName like '%Etch%' then PositiveLocation else NegativeLocation end=@pLocation ) 
			or @pProcessLanguage=@eapassing and (@pProcessUserID<>'' and @pProcessUserID is not null))
		)
		
		--ở đây có thể thêm điều kiện   or  @pProcessLanguage<>@eapassing
		if(@count<1 and @pLocation not in ('SANXUAT','NG') )  begin
			set @errr = N'Không tồn tại thiết lập mã vị trí: ' +@pLocation+  N' , với mã Lot Slitting Điện cực: ' + @pBarcode ;
			if(@pProcessLanguage<>@eapassing) begin
				raiserror (@errr,16,1);
				return;
			end
			else select @errr;
			
		end

		select   @count=count(*)  from Stb_SlittingStock_VVT  with(nolock) where barcode=@pBarcode ;
		if(@count>0 )  begin
			-- set @errr='3';
			select  top 1 @oldloca=[Location]  from Stb_SlittingStock_VVT  with(nolock) where barcode=@pBarcode ;
			if(@pProcessLanguage <> @eapassing)  begin
				set @errr = N'Lot Điện cực đã có trong kho Slitting: ' + @pBarcode + ' Vị trí: ' + 
					(select [Location] from Stb_SlittingStock_VVT  with(nolock) where barcode=@pBarcode ) ;
				raiserror (@errr,16,1);
				return;
			end
			else  begin
					update  Stb_SlittingStock_VVT 
					set	WarehouseCode = case when @pLocation='SANXUAT' then 'ROUTE_VN_WH' else WarehouseCode end,
						ListUsed = REPLACE(isnull(ListUsed,''),@pBarcode,'')+@pBarcode+';',
						ListDate = isnull(ListDate,'') + convert(varchar(19),getdate(),120) + ';',
						[Location] = case when @pLocation='SANXUAT' then [Location] else @pLocation end
					where Barcode = @pBarcode

					if @pLocation='SANXUAT'
						set @errr= N'OK, THANH CONG chuyển Lot Điện cực đến Kho Sản xuất: ' + @pBarcode ;

					if @pLocation='NG'
						set @errr= N'OK, THANH CONG chuyển Lot Điện cực đến Kho Lỗi NG: ' + @pBarcode ;

			end
		end
		else begin
		-- set @errr='4';
			;with checkWidth as (
					select mm.MaterialCode,mm.MaterialName,mm.MaterialSource,mm.MaterialThickness, esr.ElectrodeLotNumber,esr.Barcode,seq,
					esr.ElectrodeThick,esr.SlittingWidth,esr.GoodQtyLength,esr.CreateDateTime,esr.CreateUserID,esr.LotUniqueNumber
					from STB_SetInfo  si					with(nolock) 
					join STB_ElectrodeSlittingInfo   esi	with(nolock) on si.Barcode = esi.ElectrodeLotNumber
					join STB_ElectrodeSlittingResult  esr	with(nolock) on esi.ElectrodeLotNumber = esr.ElectrodeLotNumber
					left outer join STB_MaterialMaster  mm	with(nolock) on si.MaterialCode = mm.MaterialCode
					where esr.Barcode=@pBarcode 
			)
		 select top 1 @count = count(*) from stb_slittinglocationconfig_vvt	with(nolock) 
			join checkWidth cw on (SlittingCode like '%'+cw.MaterialSource+'%' and SlittingCode like '%'+cw.MaterialThickness+'%' 
			or MaterialName like '%'+replace(SlittingCode,SlittingSize,'')+'%'+SlittingSize+'%' ) 
			and (
				Width=cw.SlittingWidth and ((PositiveLocation=@pLocation or NegativeLocation=@pLocation or @pLocation  in ('SANXUAT','NG')) 
				or @pProcessLanguage=@eapassing and (@pProcessUserID<>'' and @pProcessUserID is not null))
			)

			
			if(@count>0 )  begin		
			  
			  ;with checkWidth as (
					select mm.MaterialCode,mm.MaterialName,mm.MaterialSource,mm.MaterialThickness, esr.ElectrodeLotNumber,esr.Barcode,seq,
					esr.ElectrodeThick,esr.SlittingWidth,esr.GoodQtyLength,esr.CreateDateTime,esr.CreateUserID,esr.LotUniqueNumber
					from STB_SetInfo  si					with(nolock) 
					join STB_ElectrodeSlittingInfo   esi	with(nolock) on si.Barcode = esi.ElectrodeLotNumber
					join STB_ElectrodeSlittingResult  esr	with(nolock) on esi.ElectrodeLotNumber = esr.ElectrodeLotNumber
					left outer join STB_MaterialMaster  mm	with(nolock) on si.MaterialCode = mm.MaterialCode
					where esr.Barcode=@pBarcode 
			)
			insert into Stb_SlittingStock_VVT (PartNo,CoatingCode,SlittingCode,SlittingSize,Farad,Width,RollQty,[Location],MaterialCode,MaterialName,
			MaterialSource,MaterialThickness,ElectrodeLotNumber,Barcode,seq,ElectrodeThick,SlittingWidth,GoodQtyLength,CreateDateTime,CreateUserID,LotUniqueNumber,WarehouseCode)
			select top 1 PartNo,CoatingCode,SlittingCode,SlittingSize,Farad,Width,RollQty,
			case when @pProcessLanguage=@eapassing then (case when isnull(@pLocation,'') = '' then 'NoInput' else @pLocation end )  ---ở đây có thể lấy luôn @pLocation
			else (case when MaterialName like '%+%' or MaterialName like '%Etch%' then PositiveLocation else NegativeLocation end) end  as [Location]
			,MaterialCode,MaterialName,MaterialSource,
			MaterialThickness,ElectrodeLotNumber,Barcode,seq,ElectrodeThick,SlittingWidth,GoodQtyLength,getdate(),@pProcessUserID,LotUniqueNumber,(case when @pLocation='SANXUAT' then 'ROUTE_VN_WH' else 'ELEC_VN_WH' end) 
			from stb_slittinglocationconfig_vvt	with(nolock) 
			join checkWidth cw on (SlittingCode like '%'+cw.MaterialSource+'%' and SlittingCode like '%'+cw.MaterialThickness+'%' 
			or MaterialName like '%'+replace(SlittingCode,SlittingSize,'')+'%'+SlittingSize+'%' ) 
			and (
				Width=cw.SlittingWidth and ((PositiveLocation=@pLocation or NegativeLocation=@pLocation or @pLocation  in ('SANXUAT','NG')) 
				or @pProcessLanguage=@eapassing and (@pProcessUserID<>'' and @pProcessUserID is not null))
			)

				set @errr = N'OK, THANH CONG: đưa Lot điện cực vào kho Slitting: ' + @pBarcode + N' Vị trí: ' + 
						(select [Location] from Stb_SlittingStock_VVT  with(nolock) where barcode=@pBarcode ) ;
				if(@pProcessLanguage<>@eapassing) begin
				raiserror (@errr,16,1);
				return;
				end
				else select @errr;

			end
						
		end
	end	

	-- set @errr='5';

	if(@pProcessLanguage = @eapassing OR @pProcessUserID=@eapassing) begin
		declare @ploca varchar(50) = '';
		select   @count=count(*)   from Stb_SlittingStock_VVT  with(nolock) where barcode=@pBarcode and [Location]=@pLocation ;
		if(@count>0 and @pLocation<>'SANXUAT') begin
			if(@pLocation<>@oldloca)
				select N'OK, THANH CONG chuyển Lot Điện cực đến kho Slitting: ' + @pBarcode + N' Vị trí: ' + @pLocation;
			else  select N'OK, THANH CONG Lot Điện cực đã ở kho Slitting: ' + @pBarcode + N' Vị trí: ' + @pLocation;
		end
		else select case when @errr<>'' then @errr else N'Không thể thay đổi Vị trí vào lúc này!' end;
	end

END

--   select * from   Stb_SlittingStock_VVT  with(nolock) where barcode='VVMN0812001E16-016' ;
--select   count(*) ,Location  from Stb_SlittingStock_VVT with(nolock)  where barcode like '%VVMN0812001E16%' group by Location
 