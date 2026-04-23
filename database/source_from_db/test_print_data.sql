-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec test_print_data '','','20231205001642','VVNU052R750601','Sleeve','ML20230705000257',''
--exec test_print_data '','','20231205001642','VVNU052R750601','Electrolyte','ML20231109000002',''
--exec test_print_data '','','20231204000914','VVNU043R033533','ElectrodeM','VVNN1720001E15-026',''

CREATE PROCEDURE [dbo].[test_print_data]
	@pProcessUserID VARCHAR(20), 
	@pProcessLanguage VARCHAR(20), 
	@pRawMaterialInputHistNo VARCHAR(20)= NULL, 
	@pBarcode VARCHAR(20)			    = NULL ,	 
	@pProductGroupCode VARCHAR(20)	    = NULL , 
	@pRawMaterialBarcode NVARCHAR(200)   = NULL,
	@pLotID_Warehouse_Created VARCHAR(20)	    = NULL  
AS

BEGIN

	Declare @err nvarchar(2000)=''; 

	print '=>>>>>>>>>>>>' +@pRawMaterialBarcode
	declare @validDate varchar(20);
	declare @MaterialCode varchar(30)=''
	Declare @count int=0; 
	DECLARE @RawMaterialBarcode NVARCHAR(200) =  @pRawMaterialBarcode
		print '=>>>>>>>>>>>>' +@RawMaterialBarcode		
	DECLARE @LotNonew1 VARCHAR(20) = ''
	DECLARE @LotNonew2 VARCHAR(20) = ''
	DECLARE @LotNonew3 VARCHAR(20) = ''
	DECLARE @LotNonew4 VARCHAR(20) = ''
	DECLARE @LotNonew5 VARCHAR(20) = ''
	DECLARE @LotNonew6 VARCHAR(20) = ''
	select @LotNonew1 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@pBarcode; 
	
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
		
	
	declare @bangcode varchar(30)= @pBarcode;
				
	-- Lấy mã Model Code của hàng Thành phẩm , mã code Cell hoặc Module
	select @pBarcode = Barcode , @MaterialCode=MaterialCode
	from STB_SetInfo   WITH(NOLOCK) where Barcode in (@pBarcode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6);
	

	--- đoạn này nếu để MÃ Lót ở bên dưới đây , thì sẽ không kiểm tra gì cả , Lưu lại được luôn
	--Md.Diep request pass condition for this Lot 2023-07-31
	-- Mở thêm từ VVNU013R060614
if(@pBarcode not in ('VVNP313R015601','VVNP313R015602'

) 
		or @bangcode not in ('VVNP313R015601','VVNP313R015602'
	
) ) 

BEGIN


	set @pRawMaterialBarcode = ltrim(rtrim(isnull(@pRawMaterialBarcode,''))); 
	set @pLotID_Warehouse_Created =ltrim(rtrim( isnull(@pLotID_Warehouse_Created,'')));


	exec usp_VVT_checkHOLD_Material @lotid=@pRawMaterialBarcode        -- check  NVL thô, mã Lót ML.... nếu bị HOLD thì không thể Lưu lại
	
	exec usp_VVT_checkHOLD_Material @lotid=@pLotID_Warehouse_Created   -- check  NVL thô, mã Lót ML.... nếu bị HOLD thì không thể Lưu lại
	




	select @count=count(*) from stb_materialdoclotinfo
	where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'')<>''
	


	 -- Nếu đúng là mã Lót ML.... của Kho NVL thì sẽ được phép đi qua Đoạn này
	 -- Nếu không phải mã Lót ML , không phải mã Điện cực , thì sẽ báo lỗi
	if(@count>0) begin   



		-- Đoạn này là điều kiện ngoại lệ bỏ qua ko check Hết hạn  NGày tháng nữa , 
		-- chỉ cần thêm Lót Ngoại lệ vào màn hình C555 là sẽ đc loại trừ Chặn hết hạn
		declare @OpenExpired bit = 0 
	 	;with data1 as (
			select LotID,max(createdatetime) as createdatetime
			from stb_vvt_OpenExpiredMaterial  with(nolock) 
			where (LotID=@pRawMaterialBarcode)
			group by lotid
		)
		select top 1 @OpenExpired = voem.OpenExpired 
		from stb_vvt_OpenExpiredMaterial voem with(nolock) 
		join data1 on voem.lotid = data1.lotid and voem.createdatetime = data1.createdatetime

		print '=> RawMaterialBarcode 0 :'+@RawMaterialBarcode
		declare @mmmaterialcode varchar(30)='';
		select top 1  @validDate=isnull(LotAttr10,'2010-01-01'),@mmmaterialcode=isnull(MaterialCode,''),@RawMaterialBarcode= isnull(LotNo ,'')
		from stb_materialdoclotinfo
		where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'')<>''

		print '=> RawMaterialBarcode 1 :'+@RawMaterialBarcode
		 set @pRawMaterialBarcode =  @mmmaterialcode +'#'+ @RawMaterialBarcode +' ; '+ @pRawMaterialBarcode +';'+@pLotID_Warehouse_Created
		 set @RawMaterialBarcode = @pRawMaterialBarcode
		 print '=> RawMaterialBarcode 2 :'+@RawMaterialBarcode


		 -- Nếu không mở chặn ở màn hình C555 , không phải Lót NVL Ngoại lệ , thì sẽ vào cảnh báo Hết hạn 
		if(isnull(@OpenExpired,0)=0 or @OpenExpired=0 or convert(bit,@OpenExpired)=0)
		 begin try	
			if  isnull((select  dateadd(day,ISNULL(MMExtInt01,3) * 30,@validDate)  from STB_MaterialMaster where MaterialCode= @mmmaterialcode),getdate()-1)
				< getdate()
			begin 
						set @err=N'Ngày tháng Sản xuất của Vendor Lot quá hạn sử dụng,  Hoặc chưa thiết lập MMExtInt01 trong màn hình A230: ' + 
												@pProductGroupCode+' _ '+ @RawMaterialBarcode +' _ '+
												@validDate + N'. Vui lòng kiểm tra lại!';
					RAISERROR (@err,16,1);
					return;
			end
				
		 end try
		 begin catch
		
					set @err=N'Không thể chuyển đổi kí tự thành Ngày tháng,  (Lotattr10)Đặc tính 10 màn hình F330:' + 
									@pProductGroupCode+' _ '+ @RawMaterialBarcode +' _ '+
									@validDate ;

					SET @err = isnull(ERROR_MESSAGE(),'')  +'_...............................'+ @err;

					RAISERROR (@err,16,1);
					return;
		 end catch

	 end


	 	 -- Nếu là CELL, không phải mã Lót ML , không phải mã Điện cực , không phải MODULE & SINGLECELL , thì sẽ báo lỗi không đc sử dụng như bên dưới
    else  
		if(isnull(@RawMaterialBarcode,'')<>'' and UPPER(isnull(@pProductGroupCode,'')) not in ( 'ELECTRODEP','ELECTRODEM' ) and UPPER(isnull(@pProductGroupCode,'')) not like 'MODULE%'  and UPPER(isnull(@pProductGroupCode,'')) not like 'SINGLE%'
		
		or isnull(@RawMaterialBarcode,'')<>'' and UPPER(isnull(@pProductGroupCode,''))='MODULESLEEVE' 		
	)  --Chặn Label Vendor Lot , Nếu không phải mã điện cực VV.... hoặc VJ..... thì sẽ cảnh báo
	 
	 begin
	 
				set @err=N'Không được sử dụng mã Vendor Lót không phải của Kho Nguyên liệu bắt đầu = kí tự   ML.... ' + 
									isnull(@pProductGroupCode,'') +' _ ' + isnull(@RawMaterialBarcode,'') +' _ '+
									isnull(@validDate,'') ;
									
					RAISERROR (@err,16,1);
					return;
	 end



		--Declare @err nvarchar(1000)=''; 
		Declare @company varchar(10)=''; 


	select @company= companycode from STB_UserInfo  with(nolock)  
		where UserID=isnull(@pProcessUserID,'') 
		
			

	DECLARE 
			@ProductGroupCode VARCHAR(20) = @pProductGroupCode,
			@Barcode VARCHAR(20) = @pBarcode
					   

		
	if(ltrim(rtrim(isnull(@pRawMaterialBarcode,'')))='') begin
	
		if(ltrim(rtrim(isnull(@pRawMaterialInputHistNo,'')))='')
			UPDATE STB_RawMaterialInputHist
			SET
				RawMaterialBarcode =  '',				
				ChangeDateTime = GETDATE(),
				ChangeUserID = @pProcessUserID
		WHERE   RawMaterialInputHistNo = @pRawMaterialInputHistNo

	   return;

	end
	print '--------->' +@BarCode
	print '--------->' +@ProductGroupCode
	print '--------->' +@pRawMaterialBarcode
		declare @ModelSize VARCHAR(10) = '';
	declare @ModelName NVARCHAR(200) = '';

	select @ModelSize =	right('0'+convert(varchar(2),convert(INT,MBISizeW)),2)+right('0'+convert(varchar(2),convert(INT,MBISizeH)),2)
	from STB_ModelBasicInfo with(nolock)
	where modelcode  = (select MaterialCode from STB_SetInfo WITH(NOLOCK) where Barcode in (@pBarcode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6))
	
	select  @ModelName = replace(replace(replace(replace(replace(replace(replace(ModelName,@ModelSize,''),'(',''),')',''),' ',''),'HY-CAP ',''),'HY-CAP',''),'-','%')
	from STB_ModelBasicInfo with(nolock)
	where modelcode  = (select MaterialCode from STB_SetInfo WITH(NOLOCK) where Barcode in (@pBarcode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6))
		

declare @cterminal1			nVARCHAR(300)='',
	@cterminal2			nVARCHAR(300)='',
	@crubber		nVARCHAR(300)='',
	@celectrolyte	nVARCHAR(300)='',
	@ccase			nVARCHAR(300)='',
	@csleeve		nVARCHAR(300)='',
	@ctape			nVARCHAR(300)='',
	@cseparator			nVARCHAR(300)='',
	@cElectrode1	nVARCHAR(300)='',
	@cElectrode2	nVARCHAR(300)=''
		


	select @cterminal1 = '  <<>>  '+materialcode+'  '+semiProductname  from stb_vvt_materialbo with(nolock)
			  where part like '%terminal%+%' and size = @ModelSize and semiProductname  like '%'+@ModelName+'%'

	select  @cterminal2= '  <<>>  '+materialcode+'  '+semiProductname  from stb_vvt_materialbo with(nolock)
			  where part like '%terminal%-%' and size = @ModelSize and semiProductname  like '%'+@ModelName+'%'

	select  @crubber= '  <<>>  '+materialcode+'  '+semiProductname  from stb_vvt_materialbo with(nolock)
			  where part like '%rubber%' and size = @ModelSize and semiProductname  like '%'+@ModelName+'%'

	select  @celectrolyte= '  <<>>  '+materialcode+'  '+semiProductname  from stb_vvt_materialbo with(nolock)
			  where part like '%electrolyte%' and size = @ModelSize and semiProductname  like '%'+@ModelName+'%'

	select  @ccase= '  <<>>  '+materialcode+'  '+semiProductname  from stb_vvt_materialbo with(nolock)
			  where part like '%case%' and size = @ModelSize and semiProductname  like '%'+@ModelName+'%'

	select  @csleeve= '  <<>>  '+materialcode+'  '+semiProductname  from stb_vvt_materialbo with(nolock)
			  where part like '%sleeve%' and size = @ModelSize and semiProductname  like '%'+@ModelName+'%'

	select  @ctape= '  <<>>  '+materialcode+'  '+semiProductname  from stb_vvt_materialbo with(nolock)
			  where part like '%tape%' and size = @ModelSize and semiProductname  like '%'+@ModelName+'%'

	select  @cseparator= '  <<>>  '+materialcode+'  '+semiProductname  from stb_vvt_materialbo with(nolock)
			  where part like '%separator%' and size = @ModelSize and semiProductname  like '%'+@ModelName+'%'

	select  @cElectrode1= '  <<>>  '+materialcode+'  '+semiProductname  from stb_vvt_materialbo with(nolock)
			  where part like '%electrode%+%' and size = @ModelSize and semiProductname  like '%'+@ModelName+'%'

	select  @cElectrode2= '  <<>>  '+materialcode+'  '+semiProductname  from stb_vvt_materialbo with(nolock)
			  where part like '%electrode%-%' and size = @ModelSize and semiProductname  like '%'+@ModelName+'%'
			  




	        -- chặn hết hạn sử dụng NVL của hàng Hela 1840
		--exec GetDatefromVENDORLOT1840 
						--	@pBarCode = @BarCode,
							--@pProductGroupCode = @ProductGroupCode,
							--@pRawMaterialBarcode = @RawMaterialBarcode.

							if( UPPER(isnull(@pProductGroupCode,'')) in ( 'ELECTRODEP','ELECTRODEM' )  ) begin	
		
				select @pRawMaterialBarcode = ltrim(rtrim(@pRawMaterialBarcode));


				--Mr.Duy Chặn hết hạn điện cực sx tại VN 2023-12-5
					print '====================>'+ @pProductGroupCode
					--kiểm tra C555
					declare @OpenExpiredELECTRODE bit = 0 
	 				;with data1 as (
						select LotID,max(createdatetime) as createdatetime
						from stb_vvt_OpenExpiredMaterial  with(nolock) 
						where (LotID=substring(@pRawMaterialBarcode,1,14)  )
						group by lotid
					)
					select top 1 @OpenExpiredELECTRODE = voem.OpenExpired 
					from stb_vvt_OpenExpiredMaterial voem with(nolock) 
					join data1 on voem.lotid=data1.lotid and voem.createdatetime = data1.createdatetime
					--End kiểm tra C555
					print @OpenExpiredELECTRODE
				if(isnull(@OpenExpiredELECTRODE,0)=0 or @OpenExpiredELECTRODE=0 or convert(bit,@OpenExpiredELECTRODE)=0)
				 begin 
					if(@pRawMaterialBarcode like 'VV%' or @pRawMaterialBarcode like 'VJ%')
					begin
				
						DECLARE @time varchar(20)
						DECLARE @nDay int
						SET @time=dbo.fn_VVT_getdatebyVendorLot('SRFYPK0',@pRawMaterialBarcode)
						SET @nDay = Cast(DATEDIFF(dd,@time, GETDATE()) as int)
							if(@nDay>=90)
							begin
								set @err=N'Mã Lot đã hết hạn.Vui lòng muốn mở liên hệ với QC Chị thơm:' +@pRawMaterialBarcode;
								raiserror (@err ,16,1) ;
							end
					end
				 end
			   --End code chặn

				if(len(@pRawMaterialBarcode)>14)
					select @pRawMaterialBarcode = substring(@pRawMaterialBarcode,1,18);
					
					
				select @count=count(*) from STB_SetInfo  si			with(nolock) 
					join STB_ElectrodeSlittingInfo esi		with(nolock) on si.Barcode = esi.ElectrodeLotNumber
					join STB_ElectrodeSlittingResult esr	with(nolock) on esi.ElectrodeLotNumber = esr.ElectrodeLotNumber
					where esr.Barcode=@pRawMaterialBarcode

				if(@count<1 and @err='')  begin	
					set @err = N'Chưa nhập thông tin Slitting Điện cực ở màn hình B552, hoặc sai mã Lot Slitting Điện cực: ' + @pRawMaterialBarcode ;
				end

				select  @count=count(*)  from STB_SetInfo with(nolock) where barcode=@pBarcode

				if(@count<1 and @err='')  begin	
					set @err = N'Sai dữ liệu hoặc không tồn tại LotNo: ' + @pBarcode ;
				end

				select  @count=count(*)  from STB_ModelBasicInfo  with(nolock)  where ModelCode=(select MaterialCode from STB_SetInfo with(nolock) where barcode=@pBarcode)

				if(@count<1 and @err='')  begin	
					set @err = N'Chưa thiết lập thông tin cơ bản cho Sản phẩm: ' + (select MaterialCode from STB_SetInfo with(nolock) where barcode=@pBarcode) ;
				end
				

				declare @partno varchar(10)='';
				declare @electype varchar(10)='';
				declare @elecsize varchar(10)='';


				select   @count=count(*) from Stb_SlittingStock_VVT with(nolock) where barcode=@pRawMaterialBarcode ;


				select top 1  @partno=PartNo
				,@electype = SlittingCode
				,@elecsize = SlittingSize
				from Stb_SlittingStock_VVT with(nolock) where barcode=@pRawMaterialBarcode ;


				if(@count=0  or @partno in ('1020','1320') and @electype='YP' and @elecsize='200' ) begin

					if(@count>0) begin
						update  Stb_SlittingStock_VVT
						set  warehousecode='CHG_VN_WH'
						, Barcode=convert(varchar(6),DATEPART(microsecond,getdate())) + Barcode
						, ElectrodeLotNumber=convert(varchar(6),DATEPART(microsecond,getdate())) + ElectrodeLotNumber					  
						where barcode=@pRawMaterialBarcode ;
					end

					--  phần này liên quan đến tồn kho Slitting Zone    http://192.168.1.234:8090/tv  
					-- khi mã Slitting Điện cực bắn vào đây, thì sẽ tự động trừ tồn kho ở    http://192.168.1.234:8090/tv  
					exec usp_Vietnam_SlittingStock_get  @pProcessUserID,'EA_PASS','','',@pRawMaterialBarcode,@pBarcode ;

				end


				DECLARE @pProductGroupCodeM VARCHAR(20) = @pProductGroupCode;
				--đây là phần ngoại lệ hàng Bigsize , là chỉ dùng điện cực Dương, không dùng điện cực Âm, 
				--nên thay đổi biến  @pProductGroupCode từ ELECTRODEM -> ELECTRODEP
				;with texclude as (
				select 'VEC2R7107QG' as model union all
				select 'VEB3R0107QG' as model union all
				select 'VEC3R0107QG' as model union all
				select 'VEC3R0107QG' as model union all
				select 'VEC3R0107QG' as model union all
				select 'VEC3R0227QG' as model union all
				select 'VEC2R7367QG' as model union all
				select 'VEC3R0367QG' as model union all
				select 'VEP3R0367QG' as model union all
				select 'VEC3R0387QG' as model union all
				select 'VEC3R0407QA' as model union all
				select 'VEC2R7507QG' as model union all
				select 'VEC3R0507QG' as model union all
				select 'VEP3R0507QG' as model union all
				select 'VEC3R0357QG' as model union all
				select 'VEC3R0107QG' as model union all
				select 'VHC2R3506QG-A' as model union all				
				select '(2245)' as model		  union all
				select 'VEC2R7227QG' as model		  union all
				select 'VEC3R0227QG' as model		  union all
				select '(2570)' as model		  union all
				select '(3562)' as model		  union all
				select '(3567)' as model		  union all
				select '(3060)' as model		  union all
				select '(3582)' as model		
				)
				select  @count=count(*)  from STB_ModelBasicInfo  mbi with(nolock) 
				join  texclude on ModelName like '%'+texclude.model+'%'
				where mbi.ModelCode = (select MaterialCode from STB_SetInfo with(nolock) where barcode=@pBarcode)
								
				if(@count>0 and UPPER(isnull(@pProductGroupCode,''))='ELECTRODEM') 
					select @pProductGroupCode='ELECTRODEP'




				select  @count=count(*)  from STB_MaterialMaster  with(nolock)  
				where MaterialCode=(select MaterialCode from STB_SetInfo with(nolock) where barcode=substring(@pRawMaterialBarcode,1,14) )
				and ( MaterialName like  case when  UPPER(isnull(@pProductGroupCode,''))='ELECTRODEP' then '%(+)%' else '%(-)%' end 
						or  MaterialName like case when  UPPER(isnull(@pProductGroupCode,''))='ELECTRODEP' then '%Etch%' else '%Form%' end
					)

				if(@count<1 and @err='')  begin	
					set @err = N'Không đúng loại Điện cực (Dương)(+Etching) hoặc (Âm)(-Forming):  ' 
									+ @pProductGroupCode +' : '
									+ (select MaterialCode from STB_SetInfo with(nolock) where barcode=substring(@pRawMaterialBarcode,1,14)) ;
				end

				set @pProductGroupCode = @pProductGroupCodeM
							

				;with checkWidth as (
						select mm.MaterialCode,mm.MaterialName,mm.MaterialSource,mm.MaterialThickness, esr.ElectrodeLotNumber,esr.Barcode,seq,
						esr.ElectrodeThick,esr.SlittingWidth,esr.GoodQtyLength,esr.CreateDateTime,esr.CreateUserID,esr.LotUniqueNumber
						from STB_SetInfo  si					with(nolock) 
						join STB_ElectrodeSlittingInfo   esi	with(nolock) on si.Barcode = esi.ElectrodeLotNumber
						join STB_ElectrodeSlittingResult  esr	with(nolock) on esi.ElectrodeLotNumber = esr.ElectrodeLotNumber
						left outer join STB_MaterialMaster  mm	with(nolock) on si.MaterialCode = mm.MaterialCode
						where esr.Barcode=@pRawMaterialBarcode
				)
				select  @count=count(*)  from Stb_SlittingStock_VVT slc	with(nolock)   -----Slitting Zone    http://192.168.1.234:8090/tv  
				join checkWidth cw on --(
				slittingcode like '%'+cw.MaterialSource+'%' 
				and (replace(SlittingCode,SlittingSize,'') + SlittingSize) like '%'+cw.MaterialThickness+'%' 
				and slc.Barcode = @pRawMaterialBarcode
				--or MaterialName like '%'+replace(SlittingCode,SlittingSize,'')+'%'
				--			+ (case when @pBarcode in ('VVMP253R010520',
				--									'VVMP213R010518',
				--									'VVMP213R010519',
				--									'VVMP223R010517',
				--									'VVMP223R010518',
				--									'VVMP223R010536',
				--									'VVMP253R010518',
				--									'VVMP253R010519',
				--									'VVMP253R010520',
				--									'VVMP253R010521',
				--									'VVMP273R010501',
				--									'VVMP273R010502',
				--									'VVMP273R010513') then '200' else SlittingSize end)+'%' ) 
				and Width=cw.SlittingWidth 
				and slc.Farad = (
								select cast(MBIExtText05 as float) from STB_ModelBasicInfo  with(nolock)  
								where ModelCode=(select MaterialCode from STB_SetInfo with(nolock) where barcode=@pBarcode)
								 )	
				and slc.PartNo = @ModelSize
				--and case when slc.PartNo in ('1020','1320') and slc.SlittingCode like 'YP%' and slc.SlittingSize='200' then '1020,1320'
				--else slc.PartNo end like '%'+ + '%'	
						
				if(@pBarcode='VVNK162R812601' and @pRawMaterialBarcode='VJMT1020001E02-018' and @pProductGroupCode = 'ELECTRODEP'
				or @pBarcode='VVNK162R812601' and @pRawMaterialBarcode='VJMU1220001E05-020' and @pProductGroupCode = 'ELECTRODEM')
				begin
					set @err='';
					set @count=1;
					--cho phep theo email  VŨ HUY, ngay 28 tháng 2 năm 2023
				end
				

				if(@count<1 and @err='')  begin
					set @err = N'Không tồn tại thiết lập Điện cực của LotNo:  ' +@pBarcode + '  PartNo  = ' 
								
								+ isnull((
									select @ModelSize  
									+ ' , Farad = '+MBIExtText05+'F'
									from STB_ModelBasicInfo  with(nolock)  				
									where ModelCode=(select MaterialCode from STB_SetInfo with(nolock) where barcode=@pBarcode)
								    ),'')
								
								+  N'  với Lot Slitting Điện cực:  ' + @pRawMaterialBarcode + N' ,  Chiều rộng(Width)  = '
								
								+ isnull((select convert(varchar(8),convert(numeric(5,2),SlittingWidth)) from STB_ElectrodeSlittingResult  with(nolock) where Barcode=@pRawMaterialBarcode),'')
								
								+ isnull((select N' ,  Loại Điện cực  = ' + mm.MaterialSource + N' ,  độ Dày = '+ mm.MaterialThickness +'  ,  code = '+ si.MaterialCode + ' : '+ mm.MaterialName 
									from  STB_SetInfo si with(nolock) 
									left outer join STB_MaterialMaster mm  with(nolock)  on si.MaterialCode=mm.MaterialCode
									where barcode = SUBSTRING(@pRawMaterialBarcode,1,14)  ),'   Thiết lập trong bảng  STB_MATERIALMASTER  thiếu dữ liệu  MaterialSource và MaterialThickness')

								+ N'   .   Dữ liệu trong  STB_SLITTINGLOCATIONCONFIG_VVT  = '
								
								+ isnull((select top 1 SlittingCode+'-'+SlittingSize+N',   Chiều rộng(Width)  = '+convert(varchar(8),convert(numeric(5,2),Width))+', Farad ='+convert(varchar(5),convert(INT,Farad))
									from STB_SLITTINGLOCATIONCONFIG_VVT with(nolock) where PartNo in (
									select @ModelSize  + ' , Farad='+MBIExtText05+'F'
									from STB_ModelBasicInfo  with(nolock)  				
									where ModelCode=(select MaterialCode from STB_SetInfo with(nolock) where barcode=@pBarcode)
								    ) ),N'  Chưa  CONFIG  trong bảng  :  STB_SLITTINGLOCATIONCONFIG_VVT ') 

				end

							   					
				select  @count=count(*)  from Stb_SlittingStock_VVT where barcode=@pRawMaterialBarcode
		


				if(@pBarcode='VVNK162R812601' and @pRawMaterialBarcode='VJMT1020001E02-018' and @pProductGroupCode = 'ELECTRODEP'
				or @pBarcode='VVNK162R812601' and @pRawMaterialBarcode='VJMU1220001E05-020' and @pProductGroupCode = 'ELECTRODEM')
				begin
					set @err='';
					set @count=1;
					--cho phep theo email  VŨ HUY, ngay 28 tháng 2 năm 2023
				end


				if(@count<1 or @err <> '' )begin	
					set @err = @pBarcode +'_'+substring(@RawMaterialBarcode,1,20)+'...' +' : '+@err 
						+ case when upper(@pProductGroupCode)='ELECTRODEM' then  isnull(@cElectrode2,'.')  else  isnull(@cElectrode1,'.')  end	
					raiserror (@err ,16,1) ;
					return;
					set @err=@err; --  vvmm2820001e01  
				end		
								

				declare @LotCount int = 0;
				select  @LotCount = (case when upper(ListUsed) like '%'+upper(@pBarcode)+'%' then isnull(LotCount,0) else isnull(LotCount,0)+1 end)
				from Stb_SlittingStock_VVT where barcode=@pRawMaterialBarcode ;

				update  Stb_SlittingStock_VVT 
					set	WarehouseCode = 'ROUTE_VN_WH',
						ListUsed = REPLACE(isnull(ListUsed,''),@pBarcode,'')+@pBarcode+';',
						ListDate = isnull(ListDate,'') + convert(varchar(19),getdate(),120) + ';',
						LotCount = @LotCount
					where Barcode = @pRawMaterialBarcode
		end		 					

END
end

