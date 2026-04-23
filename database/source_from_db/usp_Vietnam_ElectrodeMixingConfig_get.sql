-- =============================================
-- Author: nguyentung@vina.co.kr
-- Create date: 2021-12
-- Browsable : true
-- Group :  [B552] for Vietnam Electrode Check Vendor Lot format
-- Description:	
-- =============================================       usp_Vietnam_ElectrodeMixingConfig_get 'VVNQ3020001E05','YP-50F','ML20230623000183'
CREATE PROCEDURE [dbo].[usp_Vietnam_ElectrodeMixingConfig_get]
						@pElectrodeBarcode VARCHAR(30),
						@pMaterialCode VARCHAR(30),
						@pVendorQRcode VARCHAR(200),
						@pOrder VARCHAR(10)=null
AS 

BEGIN 

--if(@pElectrodeBarcode is null or @pElectrodeBarcode='' or @pMaterialCode is null or @pMaterialCode='' or @pVendorQRcode is null or @pVendorQRcode='') begin
--select 'notfound' as notfound
--return ;
--end




	set @pVendorQRcode = ltrim(rtrim(isnull(@pVendorQRcode,''))); 
	--set @pLotID_Warehouse_Created =ltrim(rtrim( @pLotID_Warehouse_Created));


	declare @output nvarchar(500)='.';
	exec usp_VVT_checkHOLD_Material   @lotid=@pVendorQRcode,   @output=@output  

	if(@output<>'.') begin
			select @pMaterialCode as MaterialCode,	'z' MaterialName,'z'	nameConfig ,'' Prefix,	'' Suffix,	'' Contain,	'' Proper1,	'' Proper2,	
								0 Length,2 as pos,@output as step, @output  as nextstep
			return;
	end

	declare @validDate varchar(20);
	declare @MaterialCode varchar(30)=''
	Declare @count int=0; 
	DECLARE @VendorQRcode NVARCHAR(200) =  @pVendorQRcode 


	select @count=count(*) 
	from stb_materialdoclotinfo
	where lotid in (@pVendorQRcode) and isnull(lotid,'')<>''

	declare @ktthh int=0;
	select @ktthh=count(*) from stb_vvt_OpenExpiredMaterial where LotID=@pVendorQRcode
	
	if(@count>0) begin
			select top 1 @validDate=isnull(LotAttr10,'2010-01-01'),@MaterialCode=isnull(MaterialCode,''),@VendorQRcode= isnull(LotNo ,'')
			from stb_materialdoclotinfo
			where lotid in (@pVendorQRcode) and isnull(lotid,'')<>''

		 set @VendorQRcode =  @pVendorQRcode
		 set @pVendorQRcode = @MaterialCode +'#'+ @VendorQRcode +' ; ' + @pVendorQRcode 

		 --if(isnull(@validDate,'')<>'')
		 if(
			rtrim(ltrim(@pVendorQRcode)) not in ('ML20230529000133')
		 )
		 begin try	
			if  (isnull((select  dateadd(day,ISNULL(MMExtInt01,3) * 30,@validDate)  from STB_MaterialMaster where MaterialCode= @MaterialCode),getdate()-1)< getdate() and @ktthh=0)
			begin 
						declare @err2 nvarchar(2000)=N'⚠ Ngày tháng Sản xuất của Vendor Lot quá hạn sử dụng,  Hoặc chưa thiết lập MMExtInt01 trong màn hình A230: ' + 
												' _ '+ @pVendorQRcode +' _ '+
												@validDate + N'. Vui lòng kiểm tra lại!';
					--RAISERROR (@err2,16,1);
									
					select @pMaterialCode as MaterialCode,	'z' MaterialName,'z'	nameConfig ,'' Prefix,	'' Suffix,	'' Contain,	'' Proper1,	'' Proper2,	
								0 Length,2 as pos,'check datetime of raw materials.' as step, @err2  as nextstep
					return;	
			end
				
		 end try
		 begin catch
					declare @err6 nvarchar(2000)=N'⚠ Không thể chuyển đổi kí tự thành Ngày tháng,  (Lotattr10)Đặc tính 10 màn hình F330: ' + 
									' _ '+ @pVendorQRcode +' _ '+
									@validDate ;
					declare @err22 nvarchar(2000)=ERROR_MESSAGE();
					
					if(@err22 like N'%Ngày tháng Sản xuất của Vendor Lot quá hạn sử dụng%') set @err6=@err22;
					else
						SET @err6 = @err6 +'_...........................'+ ERROR_MESSAGE();

					
					select @pMaterialCode as MaterialCode,	'z' MaterialName,'z'	nameConfig ,'' Prefix,	'' Suffix,	'' Contain,	'' Proper1,	'' Proper2,	
								0 Length,2 as pos,'check datetime of raw materials..' as step, @err6  as nextstep
					--RAISERROR (@err6,16,1);
					return;
		 end catch
	 end
	 	
		

		------   usp_Vietnam_ElectrodeMixingConfig_get 'VVNQ3020001E05','BM400','ML20230529000144'--'ML20230623000183'



declare @Out NVARCHAR(2200) ='';
exec GetDatefromVENDORLOTmixing @pBarCode ='',
								@pProductGroupCode = @pMaterialCode, 
								@pRawMaterialBarcode = @pVendorQRcode,
								@pOut = @Out

if(isnull(@Out,'')<>'') begin

	
	select @pMaterialCode as MaterialCode,	'z' MaterialName,'z'	nameConfig ,'' Prefix,	'' Suffix,	'' Contain,	'' Proper1,	'' Proper2,	
	0 Length,2 as pos,'check datetime of raw materials' as step,N'⚠ Liên hệ IQC check lại ngày tháng trên mã Code Vendor: '+@Out  as nextstep
	union all
	select  top 90 
	--convert(datetime,right(rtrim(ltrim(@pVendorQRcode)),6),120),
	si.MaterialCode,	mm.MaterialName,ecc.MaterialName as	nameConfig ,Prefix,	Suffix,	Contain,	Proper1,	Proper2,	
	Length,1 as pos,'check datetime of raw materials' as step,N'⚠ Liên hệ IQC check lại ngày tháng trên mã Code Vendor: '+@Out  as nextstep
	from STB_SetInfo  si with(nolock)  
	join STB_MaterialMaster  mm with(nolock)	on si.MaterialCode=mm.MaterialCode 
	join Stb_VVT_ElectrodeChildConfig_VVT  ecc with(nolock) 
	on  (upper(replace(replace(replace(replace(replace(mm.MaterialName,'*',''),')',''),'(',''),' ',''),'-','')) like '%' + upper(ecc.electrodecode) + '%'	
		or ecc.electrodecode is null)
	where si.barcode = @pElectrodeBarcode 
	order by pos 

	return;
end

declare @MatName varchar(100)='';
declare @childMaterial varchar(50) ='';

	--select @pVendorQRcode = ltrim(rtrim(@pVendorQRcode));

  if(CHARINDEX('#',@pVendorQRcode,11) < 1 and len(@pVendorQRcode) > 10 and @pVendorQRcode not like '%PYP-50F%') 
	 select @pVendorQRcode = SUBSTRING(@pVendorQRcode,1,10) + '#' + substring(@pVendorQRcode,11,len(@pVendorQRcode));


--if( @pVendorQRcode  like '%PYP-50F%')  select @pVendorQRcode +'# ';

	 
if(CHARINDEX('#',@pVendorQRcode,1) > 1) 
begin
	select @childMaterial  = upper(SUBSTRING(@pVendorQRcode,1,CHARINDEX('#',@pVendorQRcode,1)-1 ));

	select @MatName = MaterialName 
	from STB_MaterialMaster with(nolock) 
	where --materialcode=SUBSTRING(@pVendorQRcode,1,CHARINDEX('#',@pVendorQRcode,1)-1 ) or 
	materialcode=replace(@childMaterial,'VJJ','')
end

--if(@childMaterial is null or @childMaterial='') begin
--	select @childMaterial  = @pVendorQRcode;
--end

--raiserror(@childMaterial,16,1)
--return;

	declare @prodcode varchar(50) = ''; 
	select @prodcode = materialcode from STB_SetInfo with(nolock)  where Barcode=  @pElectrodeBarcode 


if (CHARINDEX('#',@pVendorQRcode,1) > 1 or @pMaterialCode like 'YP-50F%' /*and
@childMaterial in (
'GAKCCA-003',
'GAPOCA-006',
'GATCCC-001',
'GADACB-001',
'GAADCB-001',
'GAZOCB-001',
'GADPCB-002',
'GAJCFO-002'
) or 
CHARINDEX('#',@pVendorQRcode,1) > 1 and 
(upper(replace(replace(replace(replace(replace(@pMaterialCode,'*',''),')',''),'(',''),' ',''),'-',''))  like '%YP50F%' 
or  upper(replace(replace(replace(replace(replace(@pMaterialCode,'*',''),')',''),'(',''),' ',''),'-',''))  like '%MSP20%' 
or  upper(replace(replace(replace(replace(replace(@pMaterialCode,'*',''),')',''),'(',''),' ',''),'-',''))  like '%CEP21%' 
or  upper(replace(replace(replace(replace(replace(@MatName,'*',''),')',''),'(',''),' ',''),'-',''))  like '%YP50F%' 
or  upper(replace(replace(replace(replace(replace(@MatName,'*',''),')',''),'(',''),' ',''),'-',''))  like '%MSP20%' 
or  upper(replace(replace(replace(replace(replace(@MatName,'*',''),')',''),'(',''),' ',''),'-',''))  like '%CEP21%' )*/
) 
begin 

	--declare @childMaterial varchar(50) = SUBSTRING(@pVendorQRcode,1,CHARINDEX('#',@pVendorQRcode,1)-1 ); 
	declare @vendorLot varchar(50) =   replace(@pVendorQRcode, @childMaterial + '#', '') 

	if(@vendorLot is null or @vendorLot='') begin 
		--declare @err2 varchar(500) = 'Thieu du lieu cua Vendor Lot: ' + @pVendorQRcode; 
		--raiserror (@err2,16,1) 

		select  si.MaterialCode, mm.MaterialName,ecc.MaterialName as	nameConfig ,Prefix,	Suffix,	Contain,	 
		Proper1,	Proper2,	Length,1 as pos,N'⚠Check vendor Lot' as step,N'⚠Thiếu dữ liệu của Vendor Lot: ' + @pVendorQRcode as nextstep 
		from STB_SetInfo  si with(nolock)  
		join STB_MaterialMaster  mm with(nolock)	on si.MaterialCode=mm.MaterialCode  
		join Stb_VVT_ElectrodeChildConfig_VVT  ecc with(nolock)  
		on  (upper(replace(replace(replace(replace(replace(mm.MaterialName,'*',''),')',''),'(',''),' ',''),'-','')) like '%' + upper(ecc.electrodecode) + '%'	 
		or ecc.electrodecode is null) 
		where si.barcode = @pElectrodeBarcode 	  
		--		and (  upper(replace(replace(replace(replace(replace(ecc.MaterialName,'*',''),')',''),'(',''),' ',''),'-',''))  like '%YP50F%'
		--		or  upper(replace(replace(replace(replace(replace(ecc.MaterialName,'*',''),')',''),'(',''),' ',''),'-',''))  like '%MSP20%'
		--		or  upper(replace(replace(replace(replace(replace(ecc.MaterialName,'*',''),')',''),'(',''),' ',''),'-',''))  like '%CEP21%'
		--		or @childMaterial in (
		--'GAKCCA-003',
		--'GAPOCA-006',
		--'GATCCC-001',
		--'GADACB-001',
		--'GAADCB-001',
		--'GAZOCB-001',
		--'GADPCB-002',
		--'GAJCFO-002'
		--))

		--and  upper(replace(replace(replace(replace(replace(@MatName,'*',''),')',''),'(',''),' ',''),'-',''))  
		--like '%'+upper(replace(replace(replace(replace(replace(ecc.MaterialName,'*',''),')',''),'(',''),' ',''),'-',''))+'%'

		return;
	end



	--declare @count INt =0

	select @count = count(*) from 
	STB_ElectrodeStep  with(nolock) 
	where prodcode = @prodcode --'CRYPK0-013' 
	and ( replace(MaterialCode,'VJJ','') = case when @pMaterialCode like 'YP-50F' and @pVendorQRcode like '%PYP-50F%'    then 'GAKCCA-002' 
							  when @pMaterialCode like 'YP-50F%' and @pVendorQRcode like '%PYP-50F%' then 'GAKCCA-003' 							  
							  when @pMaterialCode like 'YP-50F%'  and @VendorQRcode not like 'ML%' then 'YP-50Fpreventin'
							  else
							  replace(@childMaterial,'VJJ','' ) 
							  end 

		or replace(MaterialCode,'VJJ','') = case when @pMaterialCode like 'YP-50F' and @pVendorQRcode like '%PYP-50F%'    then 'GAKCCA-002' 
							  when @pMaterialCode like 'YP-50F%' and @pVendorQRcode like '%PYP-50F%' then 'GAKCCA-003' 							  
							  when @pMaterialCode like 'YP-50F%'  and @VendorQRcode not like 'ML%' then 'YP-50Fpreventin'
							  else
							  (
								  case when replace(@childMaterial,'VJJ','' )='GAADCB-001'
								  then 'GAJSCB-001'  else replace(@childMaterial,'VJJ','' ) end 
								  )
							  end 
		 )  

							 
							 --VJJJVJVGAKCCA-002 


    if(@count=0) begin 
		--declare @err1 varchar(500)= 'Thiet lap '+@prodcode+' khong hop le voi Ma Code Nguyen lieu: '+@childMaterial; 
		--raiserror (@err1,16,1) 
		select  si.MaterialCode, mm.MaterialName,ecc.MaterialName as	nameConfig ,Prefix,	Suffix,	Contain,	Proper1,	Proper2,	Length,1 as pos,
		'Check Material Code' as step,N'⚠Thiết lập '+@prodcode+N' không hợp lệ với Mã Code Nguyên liệu: '+@childMaterial+' ; ' +@pVendorQRcode as nextstep
		from STB_SetInfo  si with(nolock) 
		join STB_MaterialMaster  mm with(nolock)	on si.MaterialCode=mm.MaterialCode 
		join Stb_VVT_ElectrodeChildConfig_VVT  ecc with(nolock)  
		on  (upper(replace(replace(replace(replace(replace(mm.MaterialName,'*',''),')',''),'(',''),' ',''),'-','')) like '%' + upper(ecc.electrodecode) + '%'	
		or ecc.electrodecode is null)
		where si.barcode = @pElectrodeBarcode 	

		return; 
	end		

	if(@childMaterial is null or @childMaterial='') begin
			select @childMaterial = MaterialCode from 
			STB_ElectrodeStep  with(nolock) 
			where prodcode = @prodcode --'CRYPK0-013' 
			and (  replace(MaterialCode,'VJJ','')  = case when @pMaterialCode like 'YP-50F' and @pVendorQRcode like '%PYP-50F%'    then 'GAKCCA-002' 
									  when @pMaterialCode like 'YP-50F%' and @pVendorQRcode like '%PYP-50F%' then 'GAKCCA-003' 									  
									  when @pMaterialCode like 'YP-50F%' and @VendorQRcode not like 'ML%' then 'YP-50Fpreventin'
									  else
									  replace(@childMaterial,'VJJ','' ) 
									  end 
					or   replace(MaterialCode,'VJJ','')  = case when @pMaterialCode like 'YP-50F' and @pVendorQRcode like '%PYP-50F%'    then 'GAKCCA-002' 
									  when @pMaterialCode like 'YP-50F%' and @pVendorQRcode like '%PYP-50F%' then 'GAKCCA-003' 									  
									  when @pMaterialCode like 'YP-50F%'  and @VendorQRcode not like 'ML%' then 'YP-50Fpreventin'
									  else
									   (
										  case when replace(@childMaterial,'VJJ','' )='GAADCB-001'
										  then 'GAJSCB-001'  else replace(@childMaterial,'VJJ','' ) end 
										  )

									  end 

				  )  

	end


	declare @childStep varchar(50) ='';
	  SELECT TOP 1
	   --    ES.ElectrodeStepCode
	   --   ,ES.seq
		  --,MM.MaterialName
		  --,ISNULL(ES.StdMinVal, 0) AS StdMinVal
		  --,ISNULL(ES.StdMaxVal, 100) AS StdMaxVal
		  --,ES.UniqueSeq		 
		  @childStep =  replace(es.MaterialCode,'VJJ','') 
	  FROM (
			SELECT *, ROW_NUMBER() OVER(ORDER BY CASE 
						  WHEN ES.ElectrodeStepCode = 'D' THEN  case when @pOrder is not null and @pOrder<>''  then 2 else 1 end
						  WHEN ES.ElectrodeStepCode = 'G' THEN  case when @pOrder is not null and @pOrder<>'' then 1 else 2 end
						  WHEN ES.ElectrodeStepCode = 'K' THEN 3
						  WHEN ES.ElectrodeStepCode = 'P' THEN 4
						  WHEN ES.ElectrodeStepCode = 'S' THEN 5
						  WHEN ES.ElectrodeStepCode = 'DA' THEN 6
						  END , ES.seq) AS UniqueSeq
			FROM STB_ElectrodeStep ES with(nolock) 
			WHERE ProdCode in ( SELECT  MaterialCode FROM STB_SetInfo  with(nolock) WHERE Barcode = @pElectrodeBarcode )
	  ) ES 
	  LEFT OUTER JOIN STB_ElectrodeMixStepInfo EMSI  with(nolock)  ON ES.ElectrodeStepCode = EMSI.ElectrodeStep AND ES.seq = EMSI.seq AND EMSI.ElectrodeLotNumber = @pElectrodeBarcode
	  LEFT OUTER JOIN STB_MaterialMaster MM  with(nolock) ON MM.MaterialCode = ES.MaterialCode
	  WHERE EMSI.ElectrodeLotNumber IS NULL  --and es.MaterialCode = 'VJJJVJVVCMDFM-001'
	  ORDER BY CASE		  WHEN ES.ElectrodeStepCode = 'D' THEN  case when @pOrder is not null and @pOrder<>''  then 2 else 1 end
						  WHEN ES.ElectrodeStepCode = 'G' THEN  case when @pOrder is not null and @pOrder<>'' then 1 else 2 end
						  WHEN ES.ElectrodeStepCode = 'K' THEN 3
						  WHEN ES.ElectrodeStepCode = 'P' THEN 4
						  WHEN ES.ElectrodeStepCode = 'S' THEN 5
						  WHEN ES.ElectrodeStepCode = 'DA' THEN 6
						  END , ES.seq


		if(
			@childStep=replace(@childMaterial,'VJJ','' ) or
			@childStep = case when replace(@childMaterial,'VJJ','' )='GAADCB-001'  then 'GAJSCB-001'  else replace(@childMaterial,'VJJ','' ) end  
		) 
			 begin
				set @childStep=@childStep;
			 end
		else
		begin
					select  si.MaterialCode, mm.MaterialName,ecc.MaterialName as	nameConfig ,Prefix,	Suffix,	Contain,	Proper1,	Proper2,	Length,1 as pos,
					'Wrong Step' as step,N'⚠Nguyên liệu được thiết lập, nhưng không đúng bước hiện tại là : ' + @childStep+' ; '+@pVendorQRcode as nextstep
					from STB_SetInfo  si with(nolock) 
					join STB_MaterialMaster  mm with(nolock)	on si.MaterialCode=mm.MaterialCode 
					join Stb_VVT_ElectrodeChildConfig_VVT  ecc with(nolock)  
					on  (upper(replace(replace(replace(replace(replace(mm.MaterialName,'*',''),')',''),'(',''),' ',''),'-','')) like '%' + upper(ecc.electrodecode) + '%'	
					or ecc.electrodecode is null)
					where si.barcode = @pElectrodeBarcode 	
					
					return;
		end	


		select  top 30  si.MaterialCode, mm.MaterialName,ecc.MaterialName as	nameConfig ,Prefix,	Suffix,	Contain,	Proper1,	Proper2,	Length,1 as pos,'OK' as step,'OK' as nextstep
		from STB_SetInfo  si with(nolock) 
		join STB_MaterialMaster  mm with(nolock)	on si.MaterialCode=mm.MaterialCode 
		join Stb_VVT_ElectrodeChildConfig_VVT  ecc with(nolock)  
		on  (upper(replace(replace(replace(replace(replace(mm.MaterialName,'*',''),')',''),'(',''),' ',''),'-','')) like '%' + upper(ecc.electrodecode) + '%'	
		or ecc.electrodecode is null)
		where si.barcode = @pElectrodeBarcode 	
		
		return; 	
end
else begin

	;with b1 as (
	select  top 90 
	--convert(datetime,right(rtrim(ltrim(@pVendorQRcode)),6),120),
	si.MaterialCode,	mm.MaterialName,ecc.MaterialName as	nameConfig ,Prefix,	Suffix,	Contain,	Proper1,	Proper2,	Length,1 as pos,'mapping Barcode and MaterialCode' as step,N'⚠ Tên NGUYÊN LIỆU theo QR-VendorLot không khớp với tên Nguyên liệu được thiết lập trong STB_VVT_ELECTRODECHILDCONFIG_VVT ' as nextstep

	from STB_SetInfo  si with(nolock)  
	join STB_MaterialMaster  mm with(nolock)	on si.MaterialCode=mm.MaterialCode 
	join Stb_VVT_ElectrodeChildConfig_VVT  ecc with(nolock)  

	on  (upper(replace(replace(replace(replace(replace(mm.MaterialName,'*',''),')',''),'(',''),' ',''),'-','')) like '%' + upper(ecc.electrodecode) + '%'	
		or ecc.electrodecode is null)
	where si.barcode = @pElectrodeBarcode 
	),
	b2 as ( 
		select  top 90 
		MaterialCode,	MaterialName,	nameConfig ,Prefix,	Suffix,	Contain,	Proper1,	Proper2,	Length,2 as pos, 'check material name config' as step,N'⚠ TIỀN TỐ của QR-VendorLot và chuỗi CONTAINs không khớp với thiết lập trong STB_VVT_ELECTRODECHILDCONFIG_VVT ' as nextstep
		from b1
		where  upper(replace(replace(replace(replace(replace(@pMaterialCode,'*',''),')',''),'(',''),' ',''),'-',''))  like '%' + upper(replace(replace(replace(replace(replace((b1.nameConfig),'*',''),')',''),'(',''),' ',''),'-','')) + '%'
	),
	b3 as (
		select  top 90 
		MaterialCode,	MaterialName,	nameConfig ,Prefix,	Suffix,	Contain,	Proper1,	Proper2,	Length,3 as pos,'check prefix and contain' as step, N'⚠ CHIỀU DÀI QR-VendorLot không khớp với thiết lập trong STB_VVT_ELECTRODECHILDCONFIG_VVT ' as nextstep
		from b2
		where   upper(b2.prefix) = upper(left(rtrim(ltrim(@pVendorQRcode)), len(b2.prefix)) )
		and  upper(@pVendorQRcode) like '%' + upper(b2.contain) + '%'
		and upper(b2.contain) like (case  when @pMaterialCode='YP-50F' and (select count(*) from STB_ElectrodeStep where prodcode=@prodcode and MaterialCode='GAKCCA-002')>0 then '06%PYP-50F'
										  when @pMaterialCode='YP-50F' and (select count(*) from STB_ElectrodeStep where prodcode=@prodcode and MaterialCode='GAKCCA-003')>0 then 'PYP-50F' 
										  else '%' end)
	)
	select top 90 * from b1 
	union 
	select  top 90 * from b2 
	union 
	select  top 90 * from b3 
	union 
	select  top 90 
	MaterialCode,	MaterialName,	nameConfig ,Prefix,	Suffix,	Contain,	Proper1,	Proper2,	Length,4 as pos, 'check length' as step,N'OK' as nextstep
	from b3 
	where (len(replace(@pVendorQRcode,' ',''))=b3.Length or b3.Length=0)
	order by pos desc 

 end

END 


---select upper(left(rtrim(ltrim('[)>  PYP-50F 1TK210528-01 SK210528-01-17 Q006 16D20210528 21VKURARAY CO., LTD. ')), len('[)>')) )

--usp_ElectrodeStep_get
--    usp_Vietnam_ElectrodeMixingConfig_get 'VVLU0420001E03','','ptfe-D1-E'

--select top 120 * from 
--STB_MaterialLotInfo
--where MaterialCode=replace('GAKCCA-002','VJJJVJV','')
--and MaterialWarehouseCode like 'ROH%WH'
--and Lotid=@

  -- select*from  Stb_VVT_ElectrodeChildConfig_VVT
  
--delete STB_ElectrodeMixStepInfo
-- where ElectrodeLotNumber='VVMJ1020001E06'

  
  /*
select ElectrodeStep,seq,ElectrodeMaterialCode from STB_ElectrodeMixStepInfo
  where ElectrodeLotNumber='VVMJ1112001E11' and CreateDateTime = (  select max (CreateDateTime) from STB_ElectrodeMixStepInfo
  where ElectrodeLotNumber='VVMJ1112001E11' )
   


  select*from 
  STB_ElectrodeStep 
where prodcode= (select materialcode from STB_SetInfo where barcode='VVMJ1112001E11')
*/



--declare @MatName varchar(100)=''
--select @MatName = MaterialName 
--from STB_MaterialMaster
--where materialcode=SUBSTRING(@tung,1,CHARINDEX('#',@tung,1)-1 )


--declare @tung varchar(100)='VJJJVJVGAKCCA-002#23842034'
--select SUBSTRING(@tung,1,CHARINDEX('#',@tung,1)-1 )


