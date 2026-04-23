
--  exec [usp_VVT_checkFIFO_FinishGood_BG] 'VVPN113R010610',0
CREATE PROCEDURE [dbo].[usp_VVT_checkFIFO_FinishGood_BG] 
				@pLotNo VARCHAR(20) = NULL,
				--@pPackingID VARCHAR(20) = NULL,
				--@pPartNo VARCHAR(20) = NULL
				@NewProductID INT OUTPUT
AS
BEGIN


	SET NOCOUNT ON;

	if(isnull(@pLotNo,'')='') return;
	declare @ccount INT=0;

	declare @partno varchar(100)='';
	declare @matno varchar(50)='';
	declare @materialcode varchar(50)=null;
	declare @packingdate varchar(10)='';
	declare @currentLotno varchar(30)='';

	declare @soonlotno    varchar(50)='';
	declare @soonpartno   varchar(50)='';
	declare @soonlocation varchar(50)='';
	declare @soonpackdate varchar(50)='';
	
	DECLARE @LotNonew1 VARCHAR(20) = ''
	DECLARE @LotNonew2 VARCHAR(20) = ''
	DECLARE @LotNonew3 VARCHAR(20) = ''
	DECLARE @LotNonew4 VARCHAR(20) = ''
	DECLARE @LotNonew5 VARCHAR(20) = ''
	DECLARE @LotNonew6 VARCHAR(20) = ''

	DECLARE @matno1 VARCHAR(20) = ''
	DECLARE @matno2 VARCHAR(20) = ''
	DECLARE @matno3 VARCHAR(20) = ''
	DECLARE @matno4 VARCHAR(20) = ''
	DECLARE @matno5 VARCHAR(20) = ''
	DECLARE @matno6 VARCHAR(20) = ''

	select @LotNonew1 = NewBarcode,@matno1=AftMaterialCode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@pLotNo; 
	
	select @LotNonew2 = NewBarcode,@matno2=AftMaterialCode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew1 ;

	select @LotNonew3 = NewBarcode,@matno3=AftMaterialCode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew2 ;

	select @LotNonew4 = NewBarcode,@matno4=AftMaterialCode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew3 ;

	select @LotNonew5 = NewBarcode,@matno5=AftMaterialCode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew4 ;

	select @LotNonew6 = NewBarcode,@matno5=AftMaterialCode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew5 ;
	


	select @currentLotno = Barcode ,@materialcode = isnull(@materialcode,MaterialCode)
	from STB_SetInfo   WITH(NOLOCK) where Barcode = @pLotNo


	if(isnull ( @currentLotno,'')='') begin
		select @currentLotno = Barcode ,@materialcode = isnull(@materialcode,MaterialCode)
		from STB_SetInfo   WITH(NOLOCK) where Barcode in (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6);
	end


	select @partno = MaterialName , @matno = MaterialCode,@materialcode = isnull(@materialcode,MaterialCode)
	from stb_materialmaster  WITH(NOLOCK)
	where materialcode = (select materialcode from stb_setinfo where barcode=@currentLotno)


	if(isnull ( @partno,'')='') begin
		SELECT @partno = MaterialName , @matno = isnull(@matno,MaterialCode),@materialcode = isnull(@materialcode,MaterialCode)
		from STB_VN_FINISHGOODS_BG  with(nolock) where lotno=@pLotNo
	end


	 
	set @matno = case when isnull(@matno,'*')<>'ECVT27-369' then '*' end 
	

	set @partno=upper(@partno)
	set @partno = replace(replace(@partno,'HY-CAP',''),'HYCAP','')
	set @partno = ltrim(rtrim(@partno))


	declare @index1 INT = charindex(' ',@partno);
	declare @index2 INT = charindex('(',@partno)-1;


	if(@index1>10)
		set @partno = ltrim(rtrim( substring(@partno,1,@index1) ));
	else  if(@index2>10)
		set @partno = ltrim(rtrim( substring(@partno,1,@index2) ));
	

	select @packingdate = max(ProductionDate),@materialcode = isnull(@materialcode,max(MaterialCode))
	from STB_MaterialLotInfo mli with(nolock)
	where mli.lotno = @currentLotno


	if(isnull ( @packingdate,'')='') begin
			select @packingdate = max(ProductionDate),@materialcode = isnull(@materialcode,max(MaterialCode))
			from STB_MaterialLotInfo mli with(nolock)
			where mli.lotno  in (@pLotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6);
	end

	--print 'tung'
	--print @materialcode
	--print @matno
	--print @matno1
	--print @matno2
	--print @matno3
	--print @matno4
	--print @matno5
	--print @matno6
	--print 'tung'


	;with data1 as (
	select lotno ,'' oldbarcode, MaterialCode,'' oldmaterial,locations from 	STB_VN_FINISHGOODS_BG fg with(nolock)
	where fg.flag=1 and isnull(fg.dateexport,'')='' and  isnull(fg.typeexport,'')='' and isnull(Statusout,'')<>N'Xuất'
	and MaterialCode in (@materialcode,@matno,@matno1,@matno2,@matno3,@matno4,@matno5,@matno6)
	)
	,data2 as (
		select NewBarcode as lotno,lcmi.oldbarcode,AftMaterialCode,BefMaterialCode,fg.locations
		from STB_LotChangeMaterialHistory lcmi WITH(NOLOCK)
		join data1 on lcmi.oldbarcode = data1.lotno
		join STB_VN_FINISHGOODS_BG fg with(nolock) on NewBarcode = fg.LotNo and fg.flag=1 and isnull(fg.dateexport,'')='' and  isnull(fg.typeexport,'')='' and isnull(Statusout,'')<>N'Xuất'
		and fg.MaterialCode in (@materialcode,@matno,@matno1,@matno2,@matno3,@matno4,@matno5,@matno6)
	)
	,data3 as (
		select NewBarcode as lotno,lcmi.oldbarcode,lcmi.AftMaterialCode,lcmi.BefMaterialCode,fg.locations
		from STB_LotChangeMaterialHistory lcmi WITH(NOLOCK)
		join data2 on lcmi.oldbarcode = data2.lotno
				join STB_VN_FINISHGOODS_BG fg with(nolock) on NewBarcode = fg.LotNo and fg.flag=1 and isnull(fg.dateexport,'')='' and  isnull(fg.typeexport,'')='' and isnull(Statusout,'')<>N'Xuất'
				and fg.MaterialCode in (@materialcode,@matno,@matno1,@matno2,@matno3,@matno4,@matno5,@matno6)
	)
	,data4 as (
		select NewBarcode as lotno,lcmi.oldbarcode,lcmi.AftMaterialCode,lcmi.BefMaterialCode,fg.locations
		from STB_LotChangeMaterialHistory lcmi WITH(NOLOCK)
		join data3 on lcmi.oldbarcode = data3.lotno
				join STB_VN_FINISHGOODS_BG fg with(nolock) on NewBarcode = fg.LotNo and fg.flag=1 and isnull(fg.dateexport,'')='' and  isnull(fg.typeexport,'')='' and isnull(Statusout,'')<>N'Xuất'
				and fg.MaterialCode in (@materialcode,@matno,@matno1,@matno2,@matno3,@matno4,@matno5,@matno6)
	)
	,datalast as (
		select si.barcode,mm.materialname,data1.*,mli.ProductionDate from data1
	join stb_setinfo si  with(nolock) on data1.lotno=si.barcode
	join stb_materialmaster mm with(nolock) on si.materialcode = mm.materialcode and  materialname like '%'+@partno+'%'	
	join  STB_MaterialLotInfo mli with(nolock) on mli.lotno=si.barcode and ProductionDate < @packingdate
	where (si.materialcode = @matno or @matno='*' ) --and data1.OldBarcode is not null
	union
		select si.barcode,mm.materialname,data2.*,mli.ProductionDate from data2
	join stb_setinfo si  with(nolock) on data2.lotno=si.barcode
	join stb_materialmaster mm with(nolock) on si.materialcode = mm.materialcode and  materialname like '%'+@partno+'%'
	join  STB_MaterialLotInfo mli with(nolock) on mli.lotno=si.barcode and ProductionDate < @packingdate
	where (si.materialcode = @matno or @matno='*' )-- and data2.OldBarcode is not null
	union
		select si.barcode,mm.materialname,data3.*,mli.ProductionDate from data3
	join stb_setinfo si  with(nolock) on data3.lotno=si.barcode
	join stb_materialmaster mm with(nolock) on si.materialcode = mm.materialcode and  materialname like '%'+@partno+'%'
	join  STB_MaterialLotInfo mli with(nolock) on mli.lotno=si.barcode and ProductionDate < @packingdate
	where (si.materialcode = @matno or @matno='*' ) --and data3.OldBarcode is not null
	union
		select si.barcode,mm.materialname,data4.*,mli.ProductionDate from data4
	join stb_setinfo si  with(nolock) on data4.lotno=si.barcode
	join stb_materialmaster mm with(nolock) on si.materialcode = mm.materialcode and  materialname like '%'+@partno+'%'
	join  STB_MaterialLotInfo mli with(nolock) on mli.lotno=si.barcode and ProductionDate < @packingdate
	where (si.materialcode = @matno or @matno='*' ) --and data4.OldBarcode is not null
	)
	select top 1 @soonlotno=barcode,@soonpartno=materialname,@soonlocation=locations,@soonpackdate=ProductionDate
	from datalast
	order by ProductionDate 


	set	 @soonlotno    = isnull( @soonlotno,'');
	set @soonpartno    = isnull( @soonpartno,'');
	set @soonlocation  = isnull( @soonlocation,'');
	set @soonpackdate  = isnull( @soonpackdate,'');

	print 'fd'+ @soonlotno
	
	if(isnull(@soonlotno,'')<>'') begin

	 		raiserror (N'FIFO thành phẩm: Tồn tại Lót %s hàng %s, đóng thùng ngày %s ở vị trí %s',16,1,@soonlotno,@soonpartno,@soonpackdate,@soonlocation)
			set @NewProductID=1
		
			return ;
	end
	
		print '1'
	
	--select @ccount=count(*) from sTB_SetInfo si  with(nolock) 
	--where barcode = (select lotno from 	STB_VN_FINISHGOODS_BG fg with(nolock) where lotno=@pLotNo)

	--select * from 	STB_VN_FINISHGOODS_BG fg with(nolock)
	--left outer join STB_SetInfo si  with(nolock) on fg.lotno=si.Barcode
	----left outer join STB_MaterialMaster mm with(nolock)
	--where fg.flag=1 and isnull(fg.dateexport,'')='' and  isnull(fg.typeexport,'')=''
	--and fg.lotno is not null and si.barcode is null

		
		--if(@ccount>0) begin
		--	raiserror (' %s',16,1,@pLotNo)
		--	return;
		--end


		--select @ccount=count(*) 	 
		--FROM [SmartFactoryV2].[dbo].[STB_MaterialQcInfo]
		--where inspectiondoctype='OQC' and DecisionResult='Pass' and materialqcno = @pLotNo

		--if(@ccount=0) begin
		--	raiserror (' %s',16,1,@pLotNo)
		--	return;
		--end

		
END




--select ProductionDate from 	 STB_MaterialLotInfo mli with(nolock)
--where CreateDateTime>'2022-09-25'
--and lotno like 'V%'



--select top 1000 * from STB_VN_FINISHGOODS_BG
--   [usp_VVT_checkFIFO_FinishGood] 'VJMR162R750648'
