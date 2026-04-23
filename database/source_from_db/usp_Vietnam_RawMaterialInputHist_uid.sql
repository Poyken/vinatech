-- =============================================
-- Author : Mr.Tung
-- Date: 06-15-2021

--     usp_Vietnam_RawMaterialInputHist_uid  '','','','VVPM082R750609','Separator','ML20250225000112','','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_RawMaterialInputHist_uid]
	@pProcessUserID VARCHAR(20), 
	@pProcessLanguage VARCHAR(20), 
	@pRawMaterialInputHistNo VARCHAR(20)= NULL, 
	@pBarcode VARCHAR(20)			    = NULL ,	 
	@pProductGroupCode VARCHAR(20)	    = NULL , 
	@pRawMaterialBarcode NVARCHAR(200)   = NULL, 
	@pLotID_Warehouse_Created VARCHAR(20)	    = NULL ,  
	@pCreateDateTime DATETIME		    = NULL , 
	@pChangeDateTime DATETIME		    = NULL  ,
	@pMaterialCode VARCHAR(50)	    = NULL -- Mr.Duy check ha nam factory 2025-01-13 
AS

BEGIN
	
		Declare @err nvarchar(2000)=''; 

		--raiserror(@pRawMaterialBarcode,16,1)
	declare @validDate varchar(20);
	declare @MaterialCode varchar(50)=''
	Declare @count int=0; 
	DECLARE @RawMaterialBarcode NVARCHAR(200) =  @pRawMaterialBarcode

	DECLARE @LotMaterialBarcode NVARCHAR(200) =  @pRawMaterialBarcode	-- láº¥y mÃ£ nguyÃªn liá»‡u nháº­p vÃ o khÃ´ng Ä‘Æ°á»£c thay Ä‘á»•i 
	DECLARE @BarcodeInsert NVARCHAR(200) =  @pBarcode -- láº¥y code cá»§a sáº£n xuáº¥t nháº­p vÃ o khÃ´ng Ä‘Æ°á»£c thay Ä‘á»•i 

	declare @ChildMaterialCode varchar(50)=@pMaterialCode -- Ä‘Ã¢y lÃ  láº¥y mÃ£ code nguyÃªn liá»‡u trong BOM
	--raiserror(@MaterialCode,16,1)

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
	DECLARE @checkWorkCenterCode VARCHAR(10) = NULL
	-- Láº¥y mÃ£ Model Code cá»§a hÃ ng ThÃ nh pháº©m , mÃ£ code Cell hoáº·c Module
	--select @pBarcode = Barcode , @MaterialCode=MaterialCode
	--from STB_SetInfo   WITH(NOLOCK) where Barcode in (@pBarcode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6);
	
	select @pBarcode = Barcode , @MaterialCode=SI.MaterialCode, @checkWorkCenterCode = DPP.WorkCenterCode
	from STB_SetInfo SI  WITH(NOLOCK) 
	LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK) ON SI.DayPlanNo = DPP.DayPlanNo
	where Barcode in (@pBarcode,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6);


	--- Ä‘oáº¡n nÃ y náº¿u Ä‘á»ƒ MÃƒ LÃ³t á»Ÿ bÃªn dÆ°á»›i Ä‘Ã¢y , thÃ¬ sáº½ khÃ´ng kiá»ƒm tra gÃ¬ cáº£ , LÆ°u láº¡i Ä‘Æ°á»£c luÃ´n
	--Md.Diep request pass condition for this Lot 2023-07-31
	-- Má»Ÿ thÃªm tá»« VVNU013R060614

	--check nvl Ä‘Ã£ Ä‘Æ°á»£c xuáº¥t ra sx hay chÆ°a

	--Declare @InputLineCode1 varchar(50),@ExportLineCode
	
	/*
	if(@pCompanyCode = 'VVT' and  UPPER(isnull(@pProductGroupCode,'')) not in ( 'ELECTRODEP','ELECTRODEM' ) and @pRawMaterialBarcode <> '')
	begin
		exec usp_checkExportWarehouseCodeInRouteWh @pWorkCenterCode,@pRawMaterialBarcode,@Linecode output
	end
	
	
	--Kiá»ƒm tra xem hÃ ng vÃ  nvl xuáº¥t cÃ³ cÃ¹ng line lÃ m hay khÃ´ng 
	if(@InputLineCode <> @Linecode)
	begin
			declare @errorInput nvarchar(200) = N'Lot : ' +@pRawMaterialBarcode+N' Ä‘Æ°á»£c xuáº¥t ra line : '+@Linecode+N' khÃ´ng pháº£i ra line báº¡n Ä‘ang nháº­p vui lÃ²ng kiá»ƒm tra láº¡i vá»›i kho !'

			RAISERROR(@errorInput,16,1)
	end
	*/


-- Chia nhÃ  mÃ¡y BG2 riÃªng
IF @checkWorkCenterCode NOT IN ('VVT_F4')
BEGIN





--thÃªm Ä‘iá»u kiá»‡n bá» qua khÃ´ng cáº§n check váº­t liá»‡u nháº­p vÃ o
declare @check varchar(10)
	if(@MaterialCode in ('EDVTMD-082')
	and @pRawMaterialBarcode  in ('0000000000')
	and @pProductGroupCode in ( 'SLEEVE','MODULESLEEVE' )
	)
	begin
		set @check ='a'
	end 
--end

	--RAISERROR(@MaterialCode,16,1)
	--RAISERROR(@pLotID_Warehouse_Created,16,1) 
	--select * from stb_setinfo where barcode='VE250221-004'
if(
(

@pBarcode not in ('VVPL072R7106051','VVNP313R015602','MVVOS236R035501','VVPS283R010704','VE241102-001','VE250210-005','VE250221-004','VVPU223R825703',
'VE250114-008',
'VE250304-006',
'VE250205-007'
) 


or @bangcode not in ('VVPL072R7106051','VVNP313R015602','MVVOS236R035501','VVPS283R010704','VE241102-001','VE250210-005','VE250221-004',
'VE250114-008',
'VE250304-006',
'VE250205-007'
)

)
 --and  @MaterialCode not in ('16VS47MC6XXXXXVC01','25RHV10MB6XXXXT101')
and @check is null
		) 

BEGIN

	
	set @pRawMaterialBarcode = ltrim(rtrim(isnull(@pRawMaterialBarcode,''))); 
	set @pLotID_Warehouse_Created =ltrim(rtrim( isnull(@pLotID_Warehouse_Created,'')));


	exec usp_VVT_checkHOLD_Material @lotid=@pRawMaterialBarcode        -- check  NVL thÃ´, mÃ£ LÃ³t ML.... náº¿u bá»‹ HOLD thÃ¬ khÃ´ng thá»ƒ LÆ°u láº¡i
	
	exec usp_VVT_checkHOLD_Material @lotid=@pLotID_Warehouse_Created   -- check  NVL thÃ´, mÃ£ LÃ³t ML.... náº¿u bá»‹ HOLD thÃ¬ khÃ´ng thá»ƒ LÆ°u láº¡i
	


	select @count=count(*) from stb_materialdoclotinfo
	where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'')<>''
	-- check táº¡m cho bÃªn Ä‘iá»‡n cá»±c
	-- khi mÃ£ cÃ³ Ä‘áº§u lÃ  sp má»›i kiá»ƒm tra
	if(@count <1 and (@RawMaterialBarcode like '%SP%' or @RawMaterialBarcode like '%SL%' or @RawMaterialBarcode like '%SM%'))
	begin
		select @count=count(*) from STB_MaterialLotInfo
		where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'')<>''
	end
	

	--declare @fd varchar(20) = @count
	
	--RAISERROR(@pRawMaterialBarcode,16,1)
	 -- Náº¿u Ä‘Ãºng lÃ  mÃ£ LÃ³t ML.... cá»§a Kho NVL thÃ¬ sáº½ Ä‘Æ°á»£c phÃ©p Ä‘i qua Äoáº¡n nÃ y
	 -- Náº¿u khÃ´ng pháº£i mÃ£ LÃ³t ML , khÃ´ng pháº£i mÃ£ Äiá»‡n cá»±c , thÃ¬ sáº½ bÃ¡o lá»—i
	if(@count>0) begin   



		-- Äoáº¡n nÃ y lÃ  Ä‘iá»u kiá»‡n ngoáº¡i lá»‡ bá» qua ko check Háº¿t háº¡n  NGÃ y thÃ¡ng ná»¯a , 
		-- chá»‰ cáº§n thÃªm LÃ³t Ngoáº¡i lá»‡ vÃ o mÃ n hÃ¬nh C555 lÃ  sáº½ Ä‘c loáº¡i trá»« Cháº·n háº¿t háº¡n
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

		
		declare @mmmaterialcode varchar(30)='';
		select top 1  @validDate=isnull(LotAttr10,'2010-01-01'),@mmmaterialcode=isnull(MaterialCode,''),@RawMaterialBarcode= isnull(LotNo ,'')
		from stb_materialdoclotinfo
		where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'')<>''

		 --kiá»ƒm tra Ä‘Ã£ tÃ¡ch nvl thÃ¬ váº«n cho nháº­p
		if(@mmmaterialcode ='' and  (@RawMaterialBarcode like '%SP%' or @RawMaterialBarcode like '%SL%'or @RawMaterialBarcode like '%SM%'))
		 begin 
		--RAISERROR('jf',16,1)
			 select top 1  @validDate=isnull(LotAttr10,'2010-01-01'),@mmmaterialcode=isnull(MaterialCode,''),@RawMaterialBarcode= isnull(LotNo ,'')
			from stb_materiallotinfo
			where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'')<>''
		 end
		 
		 set @pRawMaterialBarcode =  @mmmaterialcode +'#'+ @RawMaterialBarcode +' ; '+ @pRawMaterialBarcode +';'+@pLotID_Warehouse_Created
		 set @RawMaterialBarcode = @pRawMaterialBarcode
		 

		--RAISERROR(@validDate,16,1)
		--return
		
		 -- Náº¿u khÃ´ng má»Ÿ cháº·n á»Ÿ mÃ n hÃ¬nh C555 , khÃ´ng pháº£i LÃ³t NVL Ngoáº¡i lá»‡ , thÃ¬ sáº½ vÃ o cáº£nh bÃ¡o Háº¿t háº¡n 
		if((isnull(@OpenExpired,0)=0 or @OpenExpired=0 or convert(bit,@OpenExpired)=0) and @mmmaterialcode not in ('TRAY1320-B015'))
		 begin try	
			if  isnull((select  dateadd(day,(ISNULL(MMExtInt01,3) * 30)+ISNULL(MMExtInt01,3)/12*6,@validDate)  from STB_MaterialMaster where MaterialCode= @mmmaterialcode),getdate()-1)
				< getdate()
			begin 
						set @err=N'NgÃ y thÃ¡ng Sáº£n xuáº¥t cá»§a Vendor Lot quÃ¡ háº¡n sá»­ dá»¥ng,  Hoáº·c chÆ°a thiáº¿t láº­p MMExtInt01 trong mÃ n hÃ¬nh A230: ' + 
												@pProductGroupCode+' _ '+ @RawMaterialBarcode +' _ '+
												@validDate + N'. Vui lÃ²ng kiá»ƒm tra láº¡i!';
					RAISERROR (@err,16,1);
					return;
			end
				
		 end try
		 begin catch

					set @err=N'KhÃ´ng thá»ƒ chuyá»ƒn Ä‘á»•i kÃ­ tá»± thÃ nh NgÃ y thÃ¡ng,  (Lotattr10)Äáº·c tÃ­nh 10 mÃ n hÃ¬nh F330:' + 
									@pProductGroupCode+' _ '+ @RawMaterialBarcode +' _ '+
									@validDate ;

					SET @err = isnull(ERROR_MESSAGE(),'')  +'_...............................'+ @err;

					RAISERROR (@err,16,1);
					return;
		 end catch
		 

	 end

	 	 -- Náº¿u lÃ  CELL, khÃ´ng pháº£i mÃ£ LÃ³t ML , khÃ´ng pháº£i mÃ£ Äiá»‡n cá»±c , khÃ´ng pháº£i MODULE & SINGLECELL , thÃ¬ sáº½ bÃ¡o lá»—i khÃ´ng Ä‘c sá»­ dá»¥ng nhÆ° bÃªn dÆ°á»›i
    else 
	
	  
	    
		if(isnull(@RawMaterialBarcode,'')<>'' and UPPER(isnull(@pProductGroupCode,'')) not in ( 'ELECTRODEP','ELECTRODEM' ) and UPPER(isnull(@pProductGroupCode,'')) not like 'MODULE%'  and UPPER(isnull(@pProductGroupCode,'')) not like 'SINGLE%'
		
		or isnull(@RawMaterialBarcode,'')<>'' and UPPER(isnull(@pProductGroupCode,''))='MODULESLEEVE' 		
	)  --Cháº·n Label Vendor Lot , Náº¿u khÃ´ng pháº£i mÃ£ Ä‘iá»‡n cá»±c VV.... hoáº·c VJ..... thÃ¬ sáº½ cáº£nh bÃ¡o
	 
	 begin
	 	--RAISERROR (@pLotID_Warehouse_Created,16,1);
				set @err=N'KhÃ´ng Ä‘Æ°á»£c sá»­ dá»¥ng mÃ£ Vendor LÃ³t khÃ´ng pháº£i cá»§a Kho NguyÃªn liá»‡u báº¯t Ä‘áº§u = kÃ­ tá»±   ML.... ' + 
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

	

		

	        -- cháº·n háº¿t háº¡n sá»­ dá»¥ng NVL cá»§a hÃ ng Hela 1840
		exec GetDatefromVENDORLOT1840 
							@pBarCode = @BarCode,
							@pProductGroupCode = @ProductGroupCode,
							@pRawMaterialBarcode = @RawMaterialBarcode

		
	--if(@pbarcode='VVNK073R010715') begin
	--	raiserror(@MateialCode,16,1)
	--	return;
	--end
	
	

	
	

	declare @ModelSize VARCHAR(10) = '';
	declare @ModelName NVARCHAR(200) = '';

	select @ModelSize =RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))	--right('0'+convert(varchar(2),convert(INT,MBISizeW)),2)+right('0'+convert(varchar(2),convert(INT,MBISizeH)),2)
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
			  



			 
		if( UPPER(isnull(@pProductGroupCode,'')) in ( 'TERMINALP','TERMINALM','ATLTERMINAL' )  ) begin	
		
				if( ltrim(@pRawMaterialBarcode) like '15166-21.3%') set @pRawMaterialBarcode = 'GBYCTT-003'+@pRawMaterialBarcode
				if( ltrim(@pRawMaterialBarcode) like '15166-17.8%') set @pRawMaterialBarcode = 'GBYCTT-002'+@pRawMaterialBarcode
							
			
			select @count=count(*) from STB_SetInfo where barcode = @pBarcode and (MaterialCode like 'LIVT%') ---or MaterialCode LIKE 'ECVT%') -- Mr.Trieu add model code start ECVT
			
		-- select count(*) from STB_SetInfo where barcode = 'VVPR292R710617' and (MaterialCode like 'LIVT%' or MaterialCode LIKE 'ECVT%')
			if(@count=0) begin
				
				  select  @count=count(*) from STB_MaterialMaster with(nolock) where MaterialCode= (select MaterialCode from STB_SetInfo where barcode = @pBarcode)
					and (
					MaterialName like '%VEC2R7506QG%' or

					MaterialName like '%VEC3R0606QG%' or

					MaterialName like '%WEC2R7506QG%' or

					MaterialName like '%WEC3R0506QG%' or

					MaterialName like '%WEC3R0606QG%' or

					MaterialName like '%VHC2R3127QG%' 
					)
			end
		
			
			
			if(1=1 or @count>0) begin
		
			;with Termi1 as (
			--select 'GBHB00-035' as Terminal , 'VEC2R7105QG' as model,'0813' as size  union all
			  select materialcode as Terminal,  replace(replace(replace(replace(replace(replace(semiProductname,'HY-CAP ',''),'HY-CAP',''),'-C',''),'-M',''),'MSP',''),'(CY)','') as model, replace(size,'-L','') as size 
			  from stb_vvt_materialbo with(nolock)
			  where part like '%terminal%' and size is not null and semiProductname not like '%Element%'
			  union all 
			  select distinct ChildMaterialCode,replace(replace(replace(replace(replace(replace(mbi.modelname,'HY-CAP ',''),'HY-CAP',''),'-C',''),'-M',''),'MSP',''),'(CY)',''),
				--RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) 
				RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
				from STB_BomDetail bd with(nolock) 
				join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
				where   modelname like '%HY-CAP%' or  modelname like 'VEL%'  --or ModelName like 'ECVT%'
			)
			 ,Termi as (
			  select Terminal, 
			  --replace(replace(replace(replace(model,'('+size+')',''),'(',''),')',''),' ','') 
			  replace(replace(model,' ',''),'('+size+')','') model, size 
			  from Termi1
			 where len(size)=4 or len(size)=5
			
			union all
			--hela 1840
			--select 'GBHB00-043' as Terminal , 'VEC2R7506QG' as model,'1840' as size  union all  
			select 'GBHB00-042' as Terminal , 'VEC2R7506QG' as model,'1840' as size  union all
			--select 'GBHB00-043' as Terminal , 'VEC3R0606QG' as model,'1840' as size  union all --duy remote
			select 'GBHB00-042' as Terminal , 'VEC3R0606QG' as model,'1840' as size  union all
			--select 'GBHB00-043' as Terminal , 'WEC2R7506QG' as model,'1840' as size  union all
			select 'GBHB00-042' as Terminal , 'WEC2R7506QG' as model,'1840' as size  union all
			--select 'GBHB00-043' as Terminal , 'WEC3R0506QG' as model,'1840' as size  union all
			select 'GBHB00-042' as Terminal , 'WEC3R0506QG' as model,'1840' as size  union all
			--select 'GBHB00-043' as Terminal , 'WEC3R0606QG' as model,'1840' as size  union all
			select 'GBHB00-042' as Terminal , 'WEC3R0606QG' as model,'1840' as size  union all
			--select 'GBHB00-043' as Terminal , 'VHC2R3127QG' as model,'1840' as size  union all
			select 'GBHB00-042' as Terminal , 'VHC2R3127QG' as model,'1840' as size  union all
		
			select 'GBYCTT-003' as Terminal , 'VEL08253R8506G-B034' as model,'0825' as size  union all
			select 'GBYCTT-002' as Terminal , 'VEL08253R8506G-B034' as model,'0825' as size  union all
			select 'GBYCTT-003' as Terminal , 'VEL08253R8506G'		as model,'0825' as size  union all
			select 'GCSAAT-002' as Terminal , 'VEC3R0107QG'		as model,'2245' as size  union all			--DinhManh update 2025-06-26 tancha
			select 'GBHB00-042' as Terminal , 'VEC3R0606QG'		as model,'1840' as size  union all			--DinhManh update 2025-09-22 tancha
			select 'GBHB00-S05' as Terminal , 'VEC3R0606QG'		as model,'1840' as size  union all			--DinhManh update 2025-09-22 tancha
			select 'GBHB00-033' as Terminal , 'VEC3R0406QC'		as model,'1346' as size  union all	
			select 'GBHB00-036' as Terminal , 'WEC3R0205QA'     as model,'0816' as size union all -- update 2026-01-05
			select 'GBHB00-049' as Terminal , 'WEC3R0205QA'     as model,'0816' as size union all -- update 2026-01-05
			select 'GBYCTT-002' as Terminal , 'VEL08253R8506G'		as model,'0825' as size union all
			select 'GBNN00-002' as Terminal , 'WEC3R0105QD' as model,'0612' as size union all
			SELECT 'GBNN00-001' AS Terminal, 'WEC3R0105QD' AS model, '0612' AS size union all
			select 'GBHB00-034' as Terminal , 'VET10252R7106G'		as model,'1025' as size

			)
			,								
				checkLotNo as (
					select N'1.KhÃ´ng Ä‘Ãºng LotNo' as infoe
					 --where @pBarcode  IN( 'VVPR292R710617','VVPR293R040606')
					)
					,

					--select top 1 * from STB_MaterialMaster where MaterialCode='ECVT27-399'
				checkElectrolyte as (
					select si.barcode,mm.MaterialCode,MaterialName,N'2.ChÆ°a thiáº¿t láº­p mÃ£ code Tancha cho sáº£n pháº©m nÃ y: '+mm.MaterialCode+' -> '+MaterialName as infoe from 
					STB_SetInfo si with(nolock) 
					--where barcode=isnull(@pBarcode,'')
					join  STB_MaterialMaster mm with(nolock) on mm.materialcode = si.materialcode					
					where  
						barcode=isnull(@pBarcode,'') --and  mm.MaterialCode not like 'ECVT%'   -- pass qua model ECVT
                       --and si.barcode In( 'VVPR292R710617','VVPR293R040606')  -- pass qua barcode cá»¥ thá»ƒ
					),
				checkQRCode as (
					select barcode,MaterialCode,MaterialName,Termi.model,Terminal,N'3.MÃ£ Tancha Ä‘Æ°á»£c thiáº¿t láº­p, khÃ¡c vá»›i mÃ£ QRCODE nháº­p vÃ o B597: '+@pRawMaterialBarcode as infoe 
					from checkElectrolyte
					join   Termi on  checkElectrolyte.MaterialName like  '%' + Termi.model + '%' and @ModelSize = Termi.size 		 
					),
				chk as(
					select barcode,checkQRCode.MaterialCode,checkQRCode.MaterialName,model,Terminal,N'3.1. KhÃ´ng Ä‘Ãºng loáº¡i Tancha (DÆ°Æ¡ng)(+) hoáº·c (Ã‚m)(-): '+@pProductGroupCode as infoe 			
					from checkQRCode 
					join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = checkQRCode.Terminal				 
					   and Terminal = substring(isnull(@pRawMaterialBarcode,''),1,10) 
					   and mm2.MaterialName like case when  UPPER(isnull(@pProductGroupCode,''))='ATLTERMINAL' then '%' else  (case when  UPPER(isnull(@pProductGroupCode,''))='TERMINALP' then '%(+)%' else '%(-)%' end ) end
					   and  UPPER(isnull(mm2.ProductGroupCode,'')) like '%TERMINAL%'				
					),
				checkQRProduct as (
					select '4.OK' as infoe from checkQRCode 					
					join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = checkQRCode.Terminal				 
				   and Terminal = substring(isnull(@pRawMaterialBarcode,''),1,10)
					   and mm2.MaterialName like case when  UPPER(isnull(@pProductGroupCode,''))='ATLTERMINAL' then '%' else  (case when  UPPER(isnull(@pProductGroupCode,''))='TERMINALP' then '%(+)%' else '%(-)%' end ) end
				   and  UPPER(isnull(mm2.ProductGroupCode,''))  like '%TERMINAL%' 
				   )
				   ,
				collectErr as (
				   select infoe from checkLotNo
				   union all
				   select infoe from checkElectrolyte
				   union all
				   select infoe from checkQRCode
				   union all
				   select infoe from chk
				   union all
				   select infoe from checkQRProduct
				   )
				   select @err = max(infoe) from collectErr
						---2. kiem tra loai TanCha tÆ°Æ¡ng á»©ng vs BOM  
              
				if(@err <> '4.OK' or @err not like '%.OK'  )begin	
						set @err = @pBarcode+'_'+substring(@RawMaterialBarcode,1,20)+'...' +' : '+  @err + case when @pProductGroupCode='TERMINALM' then isnull(@cterminal2,'.-')  else isnull(@cterminal1,'.+')  end				
						raiserror (@err ,16,1) ;
						return;					
					set @err=@err; 
				end			

				if( ltrim(@pRawMaterialBarcode) like 'GBYCTT-00%') set @pRawMaterialBarcode = substring(@pRawMaterialBarcode,11,len(@pRawMaterialBarcode))
			end --end of @count
		end


	




	   



		if( UPPER(isnull(@pProductGroupCode,'')) = 'ELECTROLYTE' ) begin
				
				if( ltrim(@pRawMaterialBarcode) like 'PEVN62-001%') set @pRawMaterialBarcode = 'GBEC00-008'+@pRawMaterialBarcode
		
			;with eleclyte1 as ( 
				
			  select materialcode as electrolyte, replace(replace(replace(replace(replace(replace(semiProductname,'HY-CAP ',''),'HY-CAP',''),'-C',''),'-M',''),'MSP',''),'(CY)','') as model, replace(size,'-L','') as size 
			  from stb_vvt_materialbo with(nolock)
			  where part like '%electrolyte%' and size is not null and semiProductname not like '%Element%'
			  			  union all 
						  select 'GBCP00-001' as electrolyte , 'VEB2R8126HC' as model ,'1030' as size
						  union all 
						  select 'GBCP00-004' as electrolyte , 'WEC2R7106QG-L' as model ,'1030' as size
						   union all 
						  select 'GBCP00-004' as electrolyte , 'WEC3R0505QG' as model ,'1020' as size   
						   union all 
						  select 'GBCP00-004' as electrolyte , 'WEC3R0705QG' as model ,'1020' as size  
						     union all 
						  select 'GBCP00-004' as electrolyte , 'VEC3R0227QG' as model ,'2570' as size  
						       union all 
						  select 'GBCP00-004' as electrolyte , 'VEC3R0705QG' as model ,'1020' as size  
						  	       union all 
						  select 'GBCP00-004' as electrolyte , 'VEC2R7705QG' as model ,'1020' as size
						         union all 
						  select 'GBCP00-004' as electrolyte , 'WEC2R7105QG' as model ,'0813' as size  
						           union all 
						  select 'GBCP00-004' as electrolyte , 'WEC3R0126HC' as model ,'1030' as size
						        union all 
						  select 'GBCP00-004' as electrolyte , 'WEC3R0705QD' as model ,'0830' as size
						          union all 
						  select 'GBCP00-004' as electrolyte , 'WEC3R0356QG' as model ,'1635' as size
									union all 
						  select 'GBCP00-004' as electrolyte , 'VEC2R7505QA' as model ,'0825' as size
						  		union all 
						  select 'GBCP00-004' as electrolyte , 'VEC3R0507QG' as model ,'3582' as size
								union all 
						  select 'GBCP00-004' as electrolyte , 'VEC2R7505QG' as model ,'1020' as size   --2025-05-13
								union all 
						  select 'GBCP00-004' as electrolyte , 'WEC2R7335QG' as model ,'0820' as size   --2025-05-17
								union all 
						  select 'GBCP00-004' as electrolyte , 'VEC3R0107QD' as model ,'1859' as size   --2025-05-17
								union all 
						  select 'GBCP00-004' as electrolyte , 'VEC3R0705QD' as model ,'0830' as size   --2025-05-25
								union all 
						  select 'GBCP00-004' as electrolyte , 'WEC3R0105QD' as model ,'0612' as size   --2025-05-26
								union all 
						  select 'GBCP00-004' as electrolyte , 'VEC3R0106QG' as model ,'1030' as size   --2025-05-31
								union all 
						  select 'GBCP00-004' as electrolyte , 'VEC3R0335QG' as model ,'0820' as size   --2025-05-31
								union all
						  select 'GBCP00-004' as electrolyte , 'VEC3R0505QG' as model ,'1020' as size   --2025-06-02
								union all
						  select 'GBCP00-004' as electrolyte , 'VEC2R7106ZG' as model ,'1030' as size   --2025-06-11
								union all
						  select 'GBCP00-004' as electrolyte , 'WEC3R0205QA' as model ,'0816' as size   --2025-06-17
						  union all
						  select 'GBCP00-004' as electrolyte,'VEP3R0367QG' as model,'3562' size -- 2025-07-26 
						  union all
						  select 'GBCP00-004' as electrolyte,'VEC3R0105QG' as model,'0813' size -- 2025-08-01
						  union all
						  select 'GBCP00-004' as electrolyte,'WEC3R0106QD' as model, '1320' size --2025-08-04
						  union all
						  select 'GBCP00-004' as electrolyte,'VEC2R7107QG' as model, '2245' size --2025-08-21
						  union all
						  select 'GBCP00-004' AS electrolyte, 'VEC2R7105QG'  as model, '0813' size -- 2025-08-23
						  union all
						  select 'GBCP00-004' AS electrolyte, 'WEC3R0156QD'  as model, '1035' size -- 2025-09-06
						  UNION ALL
						  select 'GBCP00-004' AS electrolyte, 'WEC2R7106QG'  as model, '1030' size -- 2025-09-11
						  UNION ALL
						  select 'PD-MMST00-002' AS electrolyte, 'VEC3R0606QG'  as model, '1840' size -- 2025-09-22
						   UNION ALL
						  select 'GBCP00-004' AS electrolyte, 'WEC3R0107QD'  as model, '1859' size -- 2025-12-03
						  UNION ALL
						  select 'GBEC00-011' AS electrolyte, 'VEC3R0727QG'  as model, '35105' size -- 2026-01-13
						UNION ALL
						  select 'GBEC00-011' AS electrolyte, 'VEC3R0367QG'  as model, '3562' size -- 2026-01-13
						  UNION ALL
						  select 'GBEC00-011' AS electrolyte, 'VEC3R0107QG'  as model, '2245' size -- 2026-01-14

						  UNION ALL
						  select 'GBEC00-011' AS electrolyte, 'VEC3R0606QG'  as model, '1840' size -- 2026-01-15
						  UNION ALL
						  select 'GBEC00-011' AS electrolyte, 'VEC2R7406QC'  as model, '1346' size -- 2026-01-15
						  UNION ALL
						  select 'GBEC00-011' AS electrolyte, 'VEC3R0406QC'  as model, '1346' size -- 2026-04-11 for Model 1346-40F by nguyenvanduc
						  UNION ALL
						  select 'GBEC00-011' AS electrolyte, 'VEC3R0387QG'  as model, '3562' size -- 2026-01-26
						  UNION ALL
						  select 'GBEC00-011' AS electrolyte, 'WEC3R0106QD'  as model, '1320' size -- 2026-01-27
						  UNION ALL
						  select 'GBEC00-011' AS electrolyte, 'WEC3R0186QC'  as model, '1325' size -- 2026-02-02
						  UNION ALL
						  select 'GBEC00-011' AS electrolyte, 'VEC2R7506QG'  as model, '1840' size -- 2026-02-13
						  UNION ALL
						  select 'GBEC00-011' AS electrolyte, 'WEC3R0156QG'  as model, '1325' size -- 2026-02-13
							UNION ALL
						  select 'GBEC00-011' AS electrolyte, 'WEC3R0506QG'  as model, '1840' size -- 2026-02-13
						  UNION ALL
						  select 'GBEC00-011' AS electrolyte, 'VEP3R0367QG'  as model, '3562' size -- 2026-02-13
						  UNION ALL
						  select 'GBCP00-004' AS electrolyte, 'WEC2R7346QA'  as model, '1830' size -- 2026-03-09
						  UNION ALL
						   select 'GBEC00-011' AS electrolyte, 'VEC2R7107QG'  as model, '2245' size  UNION ALL
						  select 'GBEC00-011' AS electrolyte, 'WEC3R0156QG'  as model, '1325' size -- 2026-03-02

				-- WEC3R0156QG (1325)

				union all
			  select distinct ChildMaterialCode,replace(replace(replace(replace(replace(replace(mbi.modelname,'HY-CAP ',''),'HY-CAP',''),'-C',''),'-M',''),'MSP',''),'(CY)',''),
				--RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) 
				RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
				from STB_BomDetail bd with(nolock) 
				join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
				where   modelname like '%HY-CAP%' or  modelname like 'VEL%'
								union all
			  select distinct replace(ChildMaterialCode,'GBCP00-001','GBEC00-007'),replace(replace(replace(replace(replace(replace(mbi.modelname,'HY-CAP ',''),'HY-CAP',''),'-C',''),'-M',''),'MSP',''),'(CY)',''),
				--RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) 
				RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
				from STB_BomDetail bd with(nolock) 
				join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
				where   modelname like '%HY-CAP%' or  modelname like 'VEL%'
			)
			 ,eleclyte as (
			  select electrolyte, replace(replace(model,' ',''),'('+size+')','') model, size 
			  from eleclyte1
			where len(size)=4 or len(size)=5
			)
					--VEC2R7107QD GBEC00-008
					,
					checkLotNo as (
					select N'1.KhÃ´ng Ä‘Ãºng LotNo' as infoe
					)
					,
					checkElectrolyte as (
					select si.barcode,mm.MaterialCode,MaterialName,N'2.ChÆ°a thiáº¿t láº­p mÃ£ code Electrolyte/ DUNG Dá»ŠCH cho sáº£n pháº©m nÃ y: '+mm.MaterialCode+' -> '+MaterialName as infoe from 
					STB_SetInfo si with(nolock) 
					--where barcode=isnull(@pBarcode,'')
					join  STB_MaterialMaster mm with(nolock) on mm.materialcode = si.materialcode					
					where  
						barcode=isnull(@pBarcode,'') --isnull('VVLT292R710706','')
					),
					checkQRCode as (
					select barcode,MaterialCode,MaterialName,eleclyte.model,electrolyte,N'3.MÃ£ Electrolyte/ DUNG Dá»ŠCH Ä‘Æ°á»£c thiáº¿t láº­p, khÃ¡c vá»›i mÃ£ QRCODE nháº­p vÃ o B597: '+@pRawMaterialBarcode as infoe 
					from checkElectrolyte
					join   eleclyte on  checkElectrolyte.MaterialName like  '%' + eleclyte.model + '%'  and @ModelSize = eleclyte.size 
					),
					checkQRProduct as (
					select '4.OK' as infoe from checkQRCode 					
					join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = checkQRCode.electrolyte				 
				   and electrolyte = substring(isnull(@pRawMaterialBarcode,''),1,10) --isnull('GBCP00-001','') 
				   and  UPPER(isnull(mm2.ProductGroupCode,'')) = UPPER(isnull(@pProductGroupCode,''))--'ELECTROLYTE'
				   )
				   ,
				   collectErr as (
				   select infoe from checkLotNo
				   union all
				   select infoe from checkElectrolyte
				   union all
				   select infoe from checkQRCode
				   union all
				   select infoe from checkQRProduct
				   )
				   select @err = max(infoe) from collectErr
						---2. kiem tra loai dung dá»‹ch tÆ°Æ¡ng á»©ng vs BOM  

				if(@err <> '4.OK' or @err not like '%.OK'  )begin 
					
					set @err = @err +  isnull(@celectrolyte,'.') 
					
					--select @count=count(*)
					--from 	stb_modelbasicinfo with(nolock) 
					--where modelcode = @MaerialCode   and  isnull(MBIExtText01,'') = '2R3' 

					--if(@count=0 ) begin
					   set @err = @pBarcode+'_'+substring(@RawMaterialBarcode,1,20)+'...'  +' : '+ @err
						raiserror (@err ,16,1) ; 
						return; 
					--end

					set @err=@err;
				end	 

				if( ltrim(@pRawMaterialBarcode) like 'GBEC00-008%PEVN62%') set @pRawMaterialBarcode = substring(@pRawMaterialBarcode,11,len(@pRawMaterialBarcode))

		end



		--check vá» bá»c
	if( UPPER(isnull(@pProductGroupCode,'')) in ( 'SLEEVE','MODULESLEEVE' ) ) begin	
		  select @pRawMaterialBarcode = substring(ltrim(rtrim(@pRawMaterialBarcode)),1,10)
	 --raiserror(@pRawMaterialBarcode,16,1)
	 -- Mr.Triá»u chuáº©n bá»‹ audit cháº·n khÃ´ng cho OP nháº­p nháº§m vá» nhÃ´m 	
	DECLARE @MateriaCodeGroupSLEEVE NVARCHAR(50)
	SELECT  @MateriaCodeGroupSLEEVE=PG.ProductGroupCode from STB_MaterialMaster MM 
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK) ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK) ON MM.ProductGroupCode = PG.ProductGroupCode
	where MM.MaterialCode=@pRawMaterialBarcode
	if((isnull( @MateriaCodeGroupSLEEVE,'')) not in ( 'SLEEVE','MODULESLEEVE' ))
	begin
	   set @err = N'MÃ£ nÃ y khÃ´ng pháº£i lÃ  vá» bá»c cá»§a LotNo: ' +@pBarcode+  N'vá»›i mÃ£ nguyÃªn váº­t liá»‡u: '  + @pRawMaterialBarcode ;
	   raiserror (@err ,16,1) ;
	   return;
	end




			declare @excluded INT=0 ;
			select @excluded = count(*) from STB_MaterialMaster
			where MaterialCode = (select MaterialCode from STB_SetInfo where Barcode=@pBarcode)
			and MaterialCode in ('EDVTMD-082','EDVTMD-160','EDVTMD-220');
				----			--bá»• sung ngÃ y 25 thÃ¡ng 2 theo Zalo Mr.Bach 
				----select '' as sleeving, 'VEM16R0606QG' as model, '' as size union all 
				----select '' as sleeving, 'VEM12R0126QG' as model, '' as size 		
						
		--	
			--ML20240725000710
			--usp_Vietnam_RawMaterialInputHist_uid  '','','','VVPJ063R015601','SLEEVE','ML20240604000376','','',''
			--print (@ModelSize +' '+ @MaterialCode+'_+'+ @pRawMaterialBarcode +'+_'+@ModelSize +'_____________'+@mmmaterialcode+'__'+@pProductGroupCode)

			;with Sleev1 as ( 				
			
			  select materialcode as Sleeving, replace(replace(replace(replace(replace(replace(semiProductname,'HY-CAP ',''),'HY-CAP',''),'-C',''),'-M',''),'MSP',''),'(CY)','') as model, replace(size,'-L','') as size 
			  from stb_vvt_materialbo with(nolock)
			  where part like '%sleeve%' and size is not null and semiProductname not like '%Element%'
			  			  union all 
						   select 'GCMDPT-380' as Sleeving , 'VEB2R8126HC' as model,'1030' as size 

			 
			 union all
			  select distinct ChildMaterialCode,replace(replace(replace(replace(replace(replace(mbi.modelname,'HY-CAP ',''),'HY-CAP',''),'-C',''),'-M',''),'MSP',''),'(CY)',''),
				--RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) 
				RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
				from STB_BomDetail bd with(nolock) 
				join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
				where   modelname like '%HY-CAP%' or  modelname like 'VEL%'   or  modelname like 'WEC%'  or  modelname like 'VEC%'
			)
			 ,Sleev as (
			  select Sleeving, replace(replace(model,' ',''),'('+size+')','') model, size 
			  from Sleev1
			  where len(size)=4 or len(size)=5
			  union all
			  	select 'GCMDPT-200' as Sleeving , 'VEC2R7105QG' as model,'0813' as size  union all
			select 'GCMDPT-358' as Sleeving , 'VEC3R0105QG' as model,'0813' as size  union all
			select 'GCMDPT-421' as Sleeving , 'WEC2R7105QG' as model,'0813' as size  union all
			select 'GCMDPT-379' as Sleeving , 'WEC3R0105QG' as model,'0813' as size  union all
			select 'GCMDPT-201' as Sleeving , 'VEC2R7335QG' as model,'0820' as size  union all
			select 'GCMDPT-300' as Sleeving , 'VEC3R0205QG' as model,'0820' as size  union all
			select 'GCMDPT-216' as Sleeving , 'VEC3R0335QG' as model,'0820' as size  union all
			select 'GCMDPT-235' as Sleeving , 'VEC2R7305QG' as model,'0820' as size  union all
			select 'GCMDPT-430' as Sleeving , 'VEC3R0305QG' as model,'0820' as size  union all
			select 'GCMDPT-393' as Sleeving , 'WEC2R7335QG' as model,'0820' as size  union all
			select 'GCMDPT-402' as Sleeving , 'WEC3R0205QG' as model,'0820' as size  union all
			select 'GCMDPT-382' as Sleeving , 'WEC3R0335QG%C' as model,'0820' as size  union all
			select 'GCMDPT-382' as Sleeving , 'WEC3R0335QG%M' as model,'0820' as size  union all
			select 'GCMDPT-382' as Sleeving , 'WEC3R0335QG%M0.6T' as model,'0820' as size  union all
			select 'GCMDPT-234' as Sleeving , 'VEC2R7155QG' as model,'0820' as size  union all
			select 'GCMDPT-344' as Sleeving , 'VEC3R0155QG' as model,'0820' as size  union all
			select 'GCMDPT-400' as Sleeving , 'WEC2R7155QG' as model,'0820' as size  union all
			select 'GCMDPT-401' as Sleeving , 'WEC3R0155QG' as model,'0820' as size  union all
			select 'GCMDPT-340' as Sleeving , 'WEC3R0335QG' as model,'0820' as size  union all    --2025-06-09
			select 'GCMDPT-196' as Sleeving , 'VEC2R7505QA' as model,'0825' as size  union all
			select 'GCMDPT-196' as Sleeving , 'VEC2R7505QA' as model,'0825' as size  union all
			select 'GCMDPT-298' as Sleeving , 'VEC3R0505QD' as model,'0825' as size  union all
			select 'GCMDPT-501' as Sleeving , 'WEC2R7505QA' as model,'0825' as size  union all
			select 'GCMDPT-419' as Sleeving , 'WEC3R0505QD' as model,'0825' as size  union all
			select 'GCMDPT-369' as Sleeving , 'VEC3R0705QD' as model,'0830' as size  union all
			select 'GCMDPT-416' as Sleeving , 'WEC3R0705QD' as model,'0830' as size  union all
			select 'GCMDPT-197' as Sleeving , 'VEC2R7505QG' as model,'1020' as size  union all
			select 'GCMDPT-198' as Sleeving , 'VEC2R7705QG' as model,'1020' as size  union all
			select 'GCMDPT-275' as Sleeving , 'VEC3R0505QG' as model,'1020' as size  union all
			select 'GCMDPT-340' as Sleeving , 'VEC3R0705QG' as model,'1020' as size  union all
			select 'GCMDPT-408' as Sleeving , 'WEC2R7505QG' as model,'1020' as size  union all
			select 'GCMDPT-390' as Sleeving , 'WEC2R7705QG' as model,'1020' as size  union all
			select 'GCMDPT-409' as Sleeving , 'WEC3R0505QG' as model,'1020' as size  union all
			select 'GCMDPT-391' as Sleeving , 'WEC3R0705QG' as model,'1020' as size  union all
			select 'GCMDPT-194' as Sleeving , 'VHC2R3106QG' as model,'1020' as size  union all
			select 'GCMDPT-352' as Sleeving , 'VEC2R7705QG' as model,'1025' as size  union all
			select 'GCMDPT-257' as Sleeving , 'VEC2R7905VA' as model,'1025' as size  union all
			select 'GCMDPT-259' as Sleeving , 'VEC2R7106QA' as model,'1025' as size  union all
			select 'GCMDPT-256' as Sleeving , 'VEC3R0106QA' as model,'1025' as size  union all
			select 'GCMDPT-386' as Sleeving , 'WEC2R7106QA' as model,'1025' as size  union all
			select 'GCMDPT-406' as Sleeving , 'WEC3R0106QA' as model,'1025' as size  union all
			select 'GCMDPT-391' as Sleeving , 'WEC3R0705QG' as model,'1025' as size  union all
			select 'GCMDPT-202' as Sleeving , 'VEC2R7106QG' as model,'1030' as size  union all
			select 'GCMDPT-202' as Sleeving , 'VEC2R7106QG%L'as model,'1030' as size  union all

			select 'GCMDPT-317' as Sleeving , 'VEC2R7106ZG'as model,'1030' as size  union all --Mr.Duy add

			select 'GCMDPT-470' as Sleeving , 'VEL13353R8257G'as model,'1335' as size  union all --Mr.Duy add
			
		


			select 'GCMDPT-220' as Sleeving , 'VEC3R0106QG' as model,'1030' as size  union all
			select 'GCMDPT-265' as Sleeving , 'VEC2R5106QG' as model,'1030' as size  union all
			select 'GCMDPT-399' as Sleeving , 'WEC2R7106QG' as model,'1030' as size  union all
			select 'GCMDPT-399' as Sleeving , 'WEC2R7106QG%L'as model,'1030' as size  union all
			select 'GCMDPT-380' as Sleeving , 'WEC3R0106QG' as model,'1030' as size  union all
			select 'GCMDPT-380' as Sleeving , 'WEC3R0106QG%L'as model,'1030' as size  union all
			select 'GCMDPT-459' as Sleeving , 'WEC3R0126HC' as model,'1030' as size  union all
			select 'GCMDPT-211' as Sleeving , 'VHC2R3226QG' as model,'1030' as size  union all
			select 'GCMDPT-452' as Sleeving , 'WEC3R0156QD' as model,'1035' as size  union all
			select 'GCMDPT-288' as Sleeving , 'VEC2R7106QC' as model,'1320' as size  union all
			select 'GCMDPT-288' as Sleeving , 'VEC2R7106QC' as model,'1320' as size  union all
			select 'GCMDPT-307' as Sleeving , 'VEC3R0106QD' as model,'1320' as size  union all
			select 'GCMDPT-420' as Sleeving , 'WEC2R7106QC' as model,'1320' as size  union all
			select 'GCMDPT-424' as Sleeving , 'WEC3R0106QD' as model,'1320' as size  union all
			select 'GCMDPT-204' as Sleeving , 'VEC2R7156QG' as model,'1325' as size  union all
			select 'GCMDPT-223' as Sleeving , 'VEC2R7186QC' as model,'1325' as size  union all
			select 'GCMDPT-227' as Sleeving , 'VEC3R0156QG' as model,'1325' as size  union all
			select 'GCMDPT-365' as Sleeving , 'VEC3R0156HG' as model,'1325' as size  union all
			select 'GCMDPT-405' as Sleeving , 'WEC2R7156QG' as model,'1325' as size  union all
			select 'GCMDPT-442' as Sleeving , 'WEC2R7186QC' as model,'1325' as size  union all
			select 'GCMDPT-392' as Sleeving , 'WEC3R0156QG' as model,'1325' as size  union all
			select 'GCMDPT-371' as Sleeving , 'VEC3R0186QC' as model,'1325' as size  union all
			select 'GCMDPT-384' as Sleeving , 'WEC3R0186QC' as model,'1325' as size  union all
			select 'GCMDPT-415' as Sleeving , 'WEC2R7406QC' as model,'1346' as size  union all
			select 'GCMDPT-301' as Sleeving , 'VEC2R7406QC' as model,'1346' as size  union all
			select 'GCMDPT-208' as Sleeving , 'VEC2R7256QG' as model,'1625' as size  union all
			select 'GCMDPT-240' as Sleeving , 'VEC3R0256QG' as model,'1625' as size  union all
			select 'GCMDPT-504' as Sleeving , 'WEC2R7256QG' as model,'1625' as size  union all
			select 'GCMDPT-383' as Sleeving , 'WEC3R0256QG' as model,'1625' as size  union all
			select 'GCMDPT-422' as Sleeving , 'VHC2R3506QG' as model,'1625' as size  union all
			select 'GCMDPT-376' as Sleeving , 'VEC3R0356QG' as model,'1635' as size  union all

			select 'GCMDPT-S07' as Sleeving , 'WEC6R0126QG-H' as model,'' as size  union all --Mr.Back yeu cau 20 thang 10
			 
			select 'GCMDPT-241' as Sleeving , 'VEC2R7346QA' as model,'1830' as size  union all
			select 'GCMDPT-403' as Sleeving , 'WEC2R7346QA' as model,'1830' as size  union all

			select 'GCMDPT-199' as Sleeving , 'VEC2R7506QG' as model,'1840' as size  union all --hela 1840
			select 'GCMDPT-276' as Sleeving , 'VEC3R0606QG' as model,'1840' as size  union all
			select 'GCMDPT-378' as Sleeving , 'WEC2R7506QG' as model,'1840' as size  union all
			select 'GCMDPT-388' as Sleeving , 'WEC3R0506QG' as model,'1840' as size  union all
			select 'GCMDPT-404' as Sleeving , 'WEC3R0606QG' as model,'1840' as size  union all
			select 'GCMDPT-210' as Sleeving , 'VHC2R3127QG' as model,'1840' as size  union all
						
						----1840 module  , mr huy anh 19 thang 11 , 2022	
			select 'GCMDPT-S01' as sleeving, 'VEC6R0306QG%WC' as model, '' as size	union all 
			select 'GCMDPT-S01' as sleeving, 'VEC6R0306QG' as model, '' as size	union all 
			
				

			select 'GCMDPT-370' as Sleeving , 'VEC2R7107QD' as model,'1859' as size  union all
			select 'GCMDPT-410' as Sleeving , 'WEC2R7107QD' as model,'1859' as size  union all
			select 'GCMDPT-308' as Sleeving , 'VEC3R0107QD' as model,'1859' as size  union all
			select 'GCMDPT-242' as Sleeving , 'VEC2R7107QG' as model,'2245' as size  union all
			select 'GCMDPT-277' as Sleeving , 'VEC3R0107QG%L'as model,'2245' as size  union all
			select 'GCMDPT-368' as Sleeving , 'VEB3R0107QG' as model,'2245' as size  union all
			select 'GCMDPT-277' as Sleeving , 'VEC3R0107QG' as model,'2245' as size  union all
			select 'GCMDPT-262' as Sleeving , 'VHC2R3307QG' as model,'2245' as size  union all
			select 'GCMDPT-258' as Sleeving , 'VHC2R3227QG' as model,'2245' as size  union all

			select 'GCMDPT-407' as Sleeving , 'VEC3R0227QG' as model,'2570' as size  union all
			select 'GCMDPT-285' as Sleeving , 'VEC2R7367QG' as model,'3562' as size  union all
			select 'GCMDPT-218' as Sleeving , 'VEC3R0367QG' as model,'3562' as size  union all
			select 'GCMDPT-427' as Sleeving , 'VEP3R0367QG' as model,'3562' as size  union all
			select 'GCMDPT-435' as Sleeving , 'VEC3R0387QG' as model,'3562' as size  union all
			select 'GCMDPT-362' as Sleeving , 'VEC3R0407QA' as model,'3567' as size  union all
			select 'GCMDPT-273' as Sleeving , 'VEC2R7507QG' as model,'3582' as size  union all
			select 'GCMDPT-353' as Sleeving , 'VEC3R0507QG' as model,'3582' as size  union all
			select 'GCMDPT-443' as Sleeving , 'VEP3R0507QG' as model,'3582' as size  union all
			select 'GCMDPT-217' as Sleeving , 'VEC3R0357QG' as model,'3562' as size  union all

			--WEC6R0755QG-WCI(35)(3)
			--- chá»— dÆ°á»›i Ä‘Ã¢y lÃ  hÃ ng Module nÃªn Ä‘á»ƒ trá»‘ng cá»™t Size
			select 'GCMDPT-445' as sleeving, 'WEC6R0505QA-I' as model, '' as size union all 
				select 'GCMDPT-205' as sleeving, 'VEC5R4504QG-I' as model, '' as size union all 
				select 'GCMDPT-205' as sleeving, 'VEC5R4504QG-H' as model, '' as size union all 
				select 'GCMDPT-205' as sleeving, 'VEC5R4504QG-O' as model, '' as size union all 
				select 'GCMDPT-432' as sleeving, 'WEC5R4504QG-I' as model, '' as size union all 
				select 'GCMDPT-432' as sleeving, 'WEC5R4504QG-H' as model, '' as size union all 
				select 'GCMDPT-355' as sleeving, 'VEC6R0504QG-I' as model, '' as size union all 
				select 'GCMDPT-387' as sleeving, 'WEC6R0504QG-I' as model, '' as size union all 
				select 'GCMDPT-387' as sleeving, 'WEC6R0504QG-O' as model, '' as size union all 
				select 'GCMDPT-355' as sleeving, 'VEC6R0504QG-H' as model, '' as size union all 
				select 'GCMDPT-355' as sleeving, 'VEC6R0504QG-O' as model, '' as size union all 
				select 'GCMDPT-432' as sleeving, 'WEC5R4504QG-O' as model, '' as size union all 
				select 'GCMDPT-387' as sleeving, 'WEC6R0504QG-H' as model, '' as size union all 

				select 'PBDM00-185' as sleeving, 'VEC5R4155QG-I (23x17x9)' as model, '' as size union all
				select 'PBDM00-186' as sleeving, 'WEC6R0255QG-IL' as model, '' as size union all
				select 'PBDM00-186' as sleeving, 'WEC6R0505QG-I' as model, '' as size union all
				select 'PBDM00-186' as sleeving, 'WEC6R0505QA-I-L' as model, '' as size union all
				select 'PBDM00-184' as sleeving, 'WEC6R0505QA-O' as model, '' as size union all
				select 'PBDM00-184' as sleeving, 'WEC5R4505QG-O' as model, '' as size union all
				select 'PBDM00-184' as sleeving, 'WEC6R0355QG-OL' as model, '' as size union all
				select 'PBDM00-171' as sleeving, 'WCI(62mm)' as model, '' as size union all
				select 'PBDM00-171' as sleeving, 'WCI(35mm)' as model, '' as size union all
				select 'PBDM00-171' as sleeving, 'WCI(50mm)' as model, '' as size union all
				select 'GCMDPT-206' as sleeving, 'VEC5R4155QG-I' as model, '' as size union all 

				select 'GCMDPT-206' as sleeving, 'VEC5R4155QG-H' as model, '' as size union all 
				select 'GCMDPT-206' as sleeving, 'VEC5R4155QG-O' as model, '' as size union all 
				select 'GCMDPT-394' as sleeving, 'WEC5R4155QG-I' as model, '' as size union all 
				select 'GCMDPT-394' as sleeving, 'WEC5R4155QG-H' as model, '' as size union all 
				select 'GCMDPT-394' as sleeving, 'WEC5R4155QG-O' as model, '' as size union all 
				select 'GCMDPT-254' as sleeving, 'VEC6R0155QG-I' as model, '' as size union all 
				select 'GCMDPT-254' as sleeving, 'VEC6R0155QG-H' as model, '' as size union all 
				select 'GCMDPT-431' as sleeving, 'WEC6R0155QG-I%L' as model, '' as size union all 
				select 'GCMDPT-431' as sleeving, 'WEC6R0155QG-I' as model, '' as size union all 
				select 'GCMDPT-254' as sleeving, 'VEC6R0155QG-O' as model, '' as size union all 
				select 'GCMDPT-431' as sleeving, 'WEC6R0155QG-H' as model, '' as size union all 
				select 'GCMDPT-431' as sleeving, 'WEC6R0155QG-O' as model, '' as size union all 
				select 'GCMDPT-463' as sleeving, 'VEC9R0115QG-I' as model, '' as size union all 
				select 'GCMDPT-431' as sleeving, 'WEC6R0155QG-WCI%25%' as model, '' as size union all 
				select 'GCMDPT-431' as sleeving, 'WEC6R0155QG-WCI%35%' as model, '' as size union all 
				select 'GCMDPT-431' as sleeving, 'WEC6R0155QG-WCI%40%' as model, '' as size union all 
				select 'GCMDPT-431' as sleeving, 'WEC6R0155QG-WCI%67%' as model, '' as size union all 
				select 'GCMDPT-439' as sleeving, 'WEC6R0755QG-WCI(35)(3)' as model, '' as size union all  --Duy Add to Huyen 2023-12-21

				--Mr.Duy bá»• sung
				select 'GCMDPT-S10' as sleeving, 'WEC6R0504QD-I' as model, '' as size union all 
				
								--back SÆ¡ bá»• sung data ngÃ y 24 thÃ¡ng 1
				select 'GCMDPT-431' as sleeving, 'WEC6R0155QG-IL%ET%' as model, '' as size union all 
				select 'GCMDPT-472' as sleeving, 'WEC6R0105QA-O' as model, '' as size union all 
				select 'GCMDPT-387' as sleeving, 'WEC6R0504QG-I%T%' as model, '' as size union all 
				select 'GCMDPT-431' as sleeving, 'WEC6R0155QG-I%T%' as model, '' as size union all 
				select 'GCMDPT-445' as sleeving, 'WEC6R0505QA-I%L%1025%' as model, '' as size union all 


				select 'GCMDPT-207' as sleeving, 'VEC5R4255QA-I' as model, '' as size union all 
				select 'GCMDPT-434' as sleeving, 'WEC6R0255QD-I' as model, '' as size union all 
				select 'GCMDPT-434' as sleeving, 'WEC6R0255QD-WCI%20%' as model, '' as size union all 
				select 'GCMDPT-385' as sleeving, 'WEC6R0255QG-H' as model, '' as size union all 
				select 'GCMDPT-209' as sleeving, 'VEC5R4255QG-H' as model, '' as size union all 
				select 'GCMDPT-245' as sleeving, 'VEC5R4355QG-I' as model, '' as size union all 
				select 'GCMDPT-245' as sleeving, 'VEC5R4355QG-O' as model, '' as size union all 
				select 'GCMDPT-245' as sleeving, 'VEC5R4355QG-H' as model, '' as size union all 
				select 'GCMDPT-413' as sleeving, 'WEC5R4355QG-I' as model, '' as size union all 
				select 'GCMDPT-413' as sleeving, 'WEC5R4355QG-H' as model, '' as size union all 
				select 'GCMDPT-413' as sleeving, 'WEC5R4355QG-O' as model, '' as size union all 
				select 'GCMDPT-209' as sleeving, 'VEC5R4255QG-I' as model, '' as size union all 
				select 'GCMDPT-209' as sleeving, 'VEC5R4255QG-O' as model, '' as size union all 
				select 'GCMDPT-467' as sleeving, 'WEC5R4255QG-I' as model, '' as size union all 
				select 'GCMDPT-467' as sleeving, 'WEC5R4255QG-H' as model, '' as size union all 
				select 'GCMDPT-467' as sleeving, 'WEC5R4255QG-O' as model, '' as size union all 
				select 'GCMDPT-292' as sleeving, 'VEC6R0255QG-I' as model, '' as size union all 
				select 'GCMDPT-309' as sleeving, 'VEC6R0355QG-I' as model, '' as size union all 
				select 'GCMDPT-292' as sleeving, 'VEC6R0255QG-H' as model, '' as size union all 
				select 'GCMDPT-292' as sleeving, 'VEC6R0255QG-O' as model, '' as size union all 
				select 'GCMDPT-309' as sleeving, 'VEC6R0355QG-H' as model, '' as size union all 
				select 'GCMDPT-309' as sleeving, 'VEC6R0355QG-O' as model, '' as size union all 
				select 'GCMDPT-441' as sleeving, 'WEC6R0355QG-I' as model, '' as size union all 
				select 'GCMDPT-441' as sleeving, 'WEC6R0355QG-H' as model, '' as size union all 
				select 'GCMDPT-441' as sleeving, 'WEC6R0355QG-O' as model, '' as size union all 
				select 'GCMDPT-385' as sleeving, 'WEC6R0255QG-I' as model, '' as size union all 
				select 'GCMDPT-385' as sleeving, 'WEC6R0255QG-O' as model, '' as size union all 
				select 'GCMDPT-282' as sleeving, 'VEN5R0305QG-3PLA' as model, '' as size union all 
				select 'GCMDPT-440' as sleeving, 'WEN6R0355QG-3PLA' as model, '' as size union all 
				select 'GCMDPT-319' as sleeving, 'VEC5R4505QA-I' as model, '' as size union all 
				select 'GCMDPT-445' as sleeving, 'WEC6R0505QA-O' as model, '' as size union all 
				select 'GCMDPT-319' as sleeving, 'VEC5R4505QA-WCI%17%' as model, '' as size union all 
				select 'GCMDPT-319' as sleeving, 'VEC5R4505QA-WC%50%' as model, '' as size union all 
				select 'GCMDPT-319' as sleeving, 'VEC5R4505QA-WC%60%' as model, '' as size union all 
				select 'GCMDPT-381' as sleeving, 'VEC6R0505QA-WC%50%' as model, '' as size union all 
				select 'GCMDPT-381' as sleeving, 'VEC6R0505QA-WCI%17%' as model, '' as size union all 
				select 'GCMDPT-423' as sleeving, 'VEC7R5335QG-L%G' as model, '' as size union all 
				select 'GCMDPT-284' as sleeving, 'VEC5R4505QG-H' as model, '' as size union all 
				select 'GCMDPT-284' as sleeving, 'VEC5R4505QG-I' as model, '' as size union all 
				select 'GCMDPT-397' as sleeving, 'WEC5R4505QA-I' as model, '' as size union all 
				select 'GCMDPT-381' as sleeving, 'VEC6R0505QA-I' as model, '' as size union all 
				select 'GCMDPT-445' as sleeving, 'WEC6R0505QA-WCI%35%' as model, '' as size union all 
				select 'GCMDPT-319' as sleeving, 'VEC5R4505QA-WCI%62%' as model, '' as size union all 
				select 'GCMDPT-445' as sleeving, 'WEC6R0505QA-WCI%62%' as model, '' as size union all 
				select 'GCMDPT-445' as sleeving, 'WEC6R0505QA-O%L' as model, '' as size union all 
				select 'GCMDPT-284' as sleeving, 'VEC5R4505QG-I%L' as model, '' as size union all 
				select 'GCMDPT-284' as sleeving, 'VEC5R4505QG-O' as model, '' as size union all 
				select 'GCMDPT-284' as sleeving, 'VEC5R4505QG-W%100%' as model, '' as size union all 
				select 'GCMDPT-279' as sleeving, 'VEC6R0505QG-W%100%' as model, '' as size union all 
				select 'GCMDPT-412' as sleeving, 'WEC6R0505QG-I' as model, '' as size union all 
				select 'GCMDPT-412' as sleeving, 'WEC6R0505QG-H' as model, '' as size union all 
				select 'GCMDPT-412' as sleeving, 'WEC6R0505QG-O' as model, '' as size union all 
				select 'GCMDPT-279' as sleeving, 'VEC6R0505QG-O' as model, '' as size union all 
				select 'GCMDPT-279' as sleeving, 'VEC6R0505QG-H' as model, '' as size union all 
				select 'GCMDPT-279' as sleeving, 'VEC6R0505QG-I' as model, '' as size union all 
				select 'GCMDPT-279' as sleeving, 'VEC6R0505QG-W%50%' as model, '' as size union all 
				select 'GCMDPT-279' as sleeving, 'VEC6R0505QG-W%60%' as model, '' as size union all 
				select 'GCMDPT-412' as sleeving, 'WEC6R0505QG-W%100%' as model, '' as size union all 
				select 'GCMDPT-412' as sleeving, 'WEC6R0505QG-W%50%' as model, '' as size union all 
				select 'GCMDPT-412' as sleeving, 'WEC6R0505QG-W%60%' as model, '' as size union all 
				select 'GCMDPT-425' as sleeving, 'WEC5R4505QC-O' as model, '' as size union all 
				select 'GCMDPT-425' as sleeving, 'WEC5R4505QC-I' as model, '' as size union all 
				select 'GCMDPT-425' as sleeving, 'WEC5R4505QC-H' as model, '' as size union all 
				select 'GCMDPT-252' as sleeving, 'VEC5R4755QG-I' as model, '' as size union all 
				select 'GCMDPT-252' as sleeving, 'VEC5R4755QG-H' as model, '' as size union all 
				select 'GCMDPT-252' as sleeving, 'VEC5R4755QG-O' as model, '' as size union all 
				select 'GCMDPT-345' as sleeving, 'VEC6R0755QG-I' as model, '' as size union all 
				select 'GCMDPT-439' as sleeving, 'WEC6R0755QG-I' as model, '' as size union all 
				select 'GCMDPT-345' as sleeving, 'VEC6R0755QG-WCI%62%' as model, '' as size union all 
				select 'GCMDPT-345' as sleeving, 'VEC6R0755QG-WCI%35%' as model, '' as size union all 
				select 'GCMDPT-345' as sleeving, 'VEC6R0755QG-H' as model, '' as size union all 
				select 'GCMDPT-345' as sleeving, 'VEC6R0755QG-O' as model, '' as size union all 
				select 'GCMDPT-212' as sleeving, 'VEC5R4256QG-W%C' as model, '' as size union all 
				select 'GCMDPT-250' as sleeving, 'WEC9R0166QG-W%C' as model, '' as size union all 
				select 'GCMDPT-417' as sleeving, 'VEC6R0506QD-W%C' as model, '' as size union all 
				select 'GCMDPT-439' as sleeving, 'WEC6R0755QG-O' as model, '' as size union all 
				select 'GBNKSP-S01' as sleeving, 'WEC5R4126QS-I' as model, '' as size union all 
				select 'GCMDPT-414' as sleeving, 'WEC5R4505QG-O' as model, '' as size union all 
				select 'GCMDPT-360' as sleeving, 'VEC6R0126QG-H' as model, '' as size union all 
			 

				--bá»• sung ngÃ y 11 thÃ¡ng 2 theo email Mr.Bach 
				select 'GCMDPT-473' as sleeving, 'WEC3R0205QA' as model, '' as size union all 
				select 'GCMDPT-208' as sleeving, 'VEC2R7256QG%A' as model, '' as size union all 
				select 'GCMDPT-249' as sleeving, 'VEC3R0506QG' as model, '' as size union all 
				select 'GCMDPT-365' as sleeving, 'VEC3R0156HG%B104T' as model, '' as size union all 
				select 'GCMDPT-444' as sleeving, 'WEC3R05566QC' as model, '' as size union all 
				select 'GCMDPT-406' as sleeving, 'WEC3R0106QA%L' as model, '' as size union all 
				select 'GCMDPT-471' as sleeving, 'WEC3R0356QG' as model, '' as size union all 


				--Mr.back 1359 , ngay 10/11/2022
				select 'GCMDPT-444' as sleeving, 'WEC3R0556QG' as model, '' as size union all --Mr.back 1359 , ngay 10/11/2022
				

				--bá»• sung ngÃ y 7 thÃ¡ng 6 theo Huy anh Kaizen system
				select 'GCMDPT-434' as sleeving, 'WEC6R0255QD-WC%20%' as model, '' as size	union all 
				select 'GCMDPT-476' as sleeving, 'VEC3R0105QD' as model, '' as size	union all    --of 0612 model
				

				----3060
				select 'GCMDPT-S03' as sleeving, 'VEC3R0287QG' as model, '3060' as size	union all  --3060 ngay 23 thang 8 2022
				
				SELECT 'GCMDPT-380' AS sleeving,'WEC3R0106QG' as model, '1030' as size union all --.2020-09-26
				----1346 mr bach 28 thang 8 , 2022
				select 'GCMDPT-320' as sleeving, 'VEC3R0406QC' as model, '1346' as size	union all 
				
		
				---- VPC
				select 'GCMDPT-475' as sleeving , 'VEL08253R8506G-B034' as model,'' as size  union all 
				select 'GCMDPT-475' as sleeving , 'VEL08253R8506G'		as model,'' as size union all 

				select 'GCMDPT-466' as sleeving , 'VEL10403R8157G'		as model,'1040' as size union all   -- add 2025-10-06

				select 'GCMDPT-469' as sleeving , 'VEL13253R8157G'		as model,'1325' as size union all   -- add 2025-11-01


				select 'GCMDPT-320' AS sleeving,   'VEC2R7406QC' as model, '1346' AS size union all
				select 'GCMDPT-459' AS sleeving,   'WEC3R0106QG' as model, '1030' AS size union all
				select 'GCMDPT-468' AS sleeving,   'VEL08203R8306G' as model, '0820' AS size union all		-- 2026-03-06
				--select 'GBRLAC-011' AS sleeving,   'WEC2R7346QA' as model, '' AS size union all		-- 2026-03-06
				select 'GCMDPT-617' as Sleeving , 'WEC3R0505QD' as model,'0825' as size union all
				select 'GCMDPT-242' as Sleeving , 'VEC3R0107QG' as model,'2245' as size union all
				SELECT 'GCMDPT-431'  AS sleeving, 'VEC6R0306QG-WC' as model, '' AS size

				
			)
			,								
				checkLotNo as (
					select '1.KhÃ´ng Ä‘Ãºng LotNo' as infoe
					)
					,
				checkElectrolyte as (
					select si.barcode,mm.MaterialCode,MaterialName,N'2.ChÆ°a thiáº¿t láº­p mÃ£ code Vá» cho sáº£n pháº©m nÃ y: '+mm.MaterialCode+' -> '+MaterialName as infoe from 
					STB_SetInfo si with(nolock) 
					--where barcode=isnull(@pBarcode,'')
					join  STB_MaterialMaster mm with(nolock) on mm.materialcode = si.materialcode					
					where  
						barcode=isnull(@pBarcode,'') --isnull('VVLT292R710706','')
					),
				checkQRCode as (
					select barcode,MaterialCode,MaterialName,Sleev.model,Sleeving,N'3.MÃ£ Vá» Ä‘Æ°á»£c thiáº¿t láº­p, khÃ¡c vá»›i mÃ£ QRCODE nháº­p vÃ o B597: '+@pRawMaterialBarcode as infoe 
					from checkElectrolyte
					join   Sleev on  checkElectrolyte.MaterialName like  '%' + Sleev.model + '%'  and case when upper(@pProductGroupCode)='MODULESLEEVE' and (Sleev.size='' or Sleev.size is  null) then '' else @ModelSize end = Sleev.size 
					),
				checkQRProduct as (
					select '4.OK' as infoe from checkQRCode 					
					join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = checkQRCode.Sleeving				 
				   and Sleeving = substring(isnull(@pRawMaterialBarcode,''),1,10) --isnull('GBCP00-001','') GCMDPT-277
				   and  UPPER(isnull(mm2.ProductGroupCode,'')) = replace(UPPER(isnull(@pProductGroupCode,'')),'MODULE','') --'ELECTROLYTE'
				   )
				   ,
				collectErr as (
				   select infoe from checkLotNo
				   union all
				   select infoe from checkElectrolyte
				   union all
				   select infoe from checkQRCode
				   union all
				   select infoe from checkQRProduct
				   )
				   select @err = max(infoe) from collectErr
						---2. kiem tra loai dung dá»‹ch tÆ°Æ¡ng á»©ng vs BOM  

				if(@err <> '4.OK' or @err not like '%.OK'  )begin	
					set @err = @pBarcode +'_'+substring(@RawMaterialBarcode,1,20)+'...' +' : '+ @err +  isnull(@csleeve,'.') 
					--if(@excluded<1) begin
						raiserror (@err ,16,1) ;
						return;
					--end

					set @err=@err; 
				end					
		end
		
			   		 	  	  	 



	







	
		--Äiá»‡n cá»±c Ã¢m dÆ°Æ¡ng
		if( UPPER(isnull(@pProductGroupCode,'')) in ( 'ELECTRODEP','ELECTRODEM' )  ) begin
			

				select @pRawMaterialBarcode = ltrim(rtrim(@pRawMaterialBarcode));
				 -- Triá»u thÃªm táº¡m Ä‘á»ƒ check mÃ£ nháº­p vÃ o Ä‘iá»‡n cá»±c
				--- Kiá»ƒm tra dÃ nh riÃªng cho con low esr vÃ  hÃ ng thÆ°á»ng
				DECLARE @MaterialCodeNotLowESR VARCHAR(50)
						DECLARE @MaterialCodeBOM VARCHAR(30)
				SELECT TOP 1 @MaterialCodeNotLowESR = MaterialCode 
                FROM STB_SetInfo WITH(NOLOCK) 
                   WHERE Barcode = @pBarcode;
				-- Náº¿u lÃ  1030 thÃ¬ kiá»ƒm tra thÃªm 1 tÃ­ ná»¯a cÃ³ thá»ƒ dÃ¹ng thÃªm cÃ¡c model khÃ¡c náº¿u cÃ³ yáº¿u cáº§u
				if(@MaterialCodeNotLowESR in('ECVT27-388', 'ECVT30-368')) --'ECVT30-372'
					BEGIN
						-- Láº¥y ra mÃ£ NVL Ä‘áº§u vÃ o nháº­p mÃ£ Ä‘iá»‡n cá»±c
						SELECT TOP 1 @MaterialCodeBOM = MaterialCode 
						  FROM STB_SetInfo WITH(NOLOCK) 
						 WHERE Barcode = SUBSTRING(@pRawMaterialBarcode, 1, 14);
						-- Giá» sáº½ check theo BOM
						IF not EXISTS(SELECT 1 FROM STB_BomDetail WHERE MaterialCode=@MaterialCodeNotLowESR AND BomVersion='2001' AND ChildMaterialCode=@MaterialCodeBOM)
						BEGIN
							SET @err = N'Lá»—i BOM ' + @MaterialCodeBOM + 
						   N' khÃ´ng Ä‘Æ°á»£c phÃ©p dÃ¹ng cho Model ' + @MaterialCodeNotLowESR + 
						   N'. Vui lÃ²ng kiá»ƒm tra láº¡i!';
							RAISERROR (@err, 16, 1);
							RETURN;

					END

				ELSE IF (@MaterialCodeNotLowESR in('ECVT30-367'))
					BEGIn
						-- Láº¥y ra mÃ£ NVL Ä‘áº§u vÃ o nháº­p mÃ£ Ä‘iá»‡n cá»±c
						--DECLARE @MaterialCodeBOM VARCHAR(30)
						SELECT TOP 1 @MaterialCodeBOM = MaterialCode 
						  FROM STB_SetInfo WITH(NOLOCK) 
						 WHERE Barcode = SUBSTRING(@pRawMaterialBarcode, 1, 14);
						-- Giá» sáº½ check theo BOM
						IF (@MaterialCodeBOM NOT IN ('CREBO35L', 'CRFYN85L')) OR (not EXISTS(SELECT 1 FROM STB_BomDetail WHERE MaterialCode=@MaterialCodeNotLowESR AND BomVersion='2001' AND ChildMaterialCode=@MaterialCodeBOM))
						BEGIN
							SET @err = N'Lá»—i BOM ' + @MaterialCodeBOM + 
						   N' khÃ´ng Ä‘Æ°á»£c phÃ©p dÃ¹ng cho Model ' + @MaterialCodeNotLowESR + 
						   N'. Vui lÃ²ng kiá»ƒm tra láº¡i!';
							RAISERROR (@err, 16, 1);
							RETURN;
						END
				
					END


				END



			

			   -- Mr.Triá»u cháº·n háº¿t háº¡n sá»­ dá»¥ng NVL Ä‘iá»‡n cá»±c 2025-10-07
			   -- Cháº·n mÃ£ Ä‘iá»‡n cá»±c háº¿t háº¡n sá»­ dá»¥ng dá»±a vÃ o Ä‘áº·c tÃ­nh 10 trÃªn mÃ n F330
			 -- DECLARE @ValidateTime varchar(50);
			 -- DECLARE @MaterialUnit VARCHAR(50)
			 -- select @MaterialUnit=MaterialCode  FROM STB_SetInfo WITH (NOLOCK)
    --          WHERE Barcode = SUBSTRING(@pRawMaterialBarcode, 1, 14)
				--   -- check sá»± tá»“n táº¡i cá»§a thuá»™c tÃ­nh 10
				   
			 --  -- Láº¥y ra ngÃ y nháº­p NVL
			 --select TOP 1 @ValidateTime= LotAttr10 from STB_MaterialDocLotInfo where MaterialCode=(select MaterialCode FROM STB_SetInfo WITH (NOLOCK)
    --         WHERE Barcode = SUBSTRING(@pRawMaterialBarcode, 1, 14) and Lotno=SUBSTRING(@pRawMaterialBarcode, 1, 14)) 
			 --if(@ValidateTime IS NOT NULL AND LTRIM(RTRIM(@ValidateTime)) <> '')
			 --begin
		  --      if (isnull((select  dateadd(day,(ISNULL(MMExtInt01,3) * 30)+ISNULL(MMExtInt01,3)/12*6,@ValidateTime)  from STB_MaterialMaster where MaterialCode= @MaterialUnit),getdate()-1) < getdate())
			 --       begin 
				--	      set @err=N'NgÃ y thÃ¡ng Sáº£n xuáº¥t cá»§a Vendor Lot quÃ¡ háº¡n sá»­ dá»¥ng,  Hoáº·c chÆ°a thiáº¿t láº­p MMExtInt01 trong mÃ n hÃ¬nh A230: ' + 
				--								@pProductGroupCode+' _ '+ @RawMaterialBarcode +' _ '+
				--								@ValidateTime + N'. Vui lÃ²ng kiá»ƒm tra láº¡i!';
				--	      RAISERROR (@err,16,1);
				--	      return;
			 --     end

			 -- end
			
			
				--Mr.Duy Cháº·n háº¿t háº¡n Ä‘iá»‡n cá»±c sx táº¡i VN 2023-12-5

					--kiá»ƒm tra C555
					declare @OpenExpiredELECTRODE bit = 0 ,@locationWarehouseCode varchar(30),@checkoutproduction int =0
	 				;with data1 as (
						select LotID,max(createdatetime) as createdatetime
						from stb_vvt_OpenExpiredMaterial  with(nolock) 
						where (LotID=substring(@pRawMaterialBarcode,1,14)  )
						group by lotid
					)
					select top 1 @OpenExpiredELECTRODE = voem.OpenExpired 
					from stb_vvt_OpenExpiredMaterial voem with(nolock) 
					join data1 on voem.lotid=data1.lotid and voem.createdatetime = data1.createdatetime
					--End kiá»ƒm tra C555
				
				if(isnull(@OpenExpiredELECTRODE,0)=0 or @OpenExpiredELECTRODE=0 or convert(bit,@OpenExpiredELECTRODE)=0)
				 begin 
					if(@pRawMaterialBarcode like 'VV%' or @pRawMaterialBarcode like 'VJ%')
					begin
						DECLARE @time varchar(20)
						DECLARE @nDay int
					    --- LÃ¡y ra NVL mÃ  sx nháº­p vÃ o

						SET @time=dbo.fn_VVT_getdatebyVendorLot('SRFYPK0',@pRawMaterialBarcode)
						-- chexk hÃªt háº¡n 90 ngÃ y
						SET @nDay = Cast(DATEDIFF(dd,@time, GETDATE()) as int)
							if(@nDay>=90)
							begin
								set @err=N'MÃ£ Lot Ä‘Ã£ háº¿t háº¡n.Vui lÃ²ng muá»‘n má»Ÿ liÃªn há»‡ vá»›i QC:' +@pRawMaterialBarcode;
							end
					end
				 end

			   --End code cháº·n
			 
				
     			   --cáº¯t mÃ£  nvl Ä‘iá»‡n cá»±c cho Ä‘Ãºng
					/*
				if(len(@pRawMaterialBarcode)>14)
					select @pRawMaterialBarcode = substring(@pRawMaterialBarcode,1,18);
					*/

				--select * from STB_RawMaterialInputHist where createdatetime >='2024-07-01' and productgroupcode in ('ElectrodeM','ElectrodeP') and lotmaterialcode like '%ML%'
				--declare @fd varchar(20)=@count
				--raiserror (@pProductGroupCode,16,1) ;

				--Kiá»ƒm tra xem lot Ä‘iá»‡n cá»±c Ä‘ang á»Ÿ báº¯c ninh hay báº¯c giang	 
				select  @locationWarehouseCode=WorkCenterCode from STB_ElectrodeSlittingResult where Barcode = @pRawMaterialBarcode
				--kiá»ƒm tra náº¿u á»Ÿ báº¯c giang sáº½ cháº·n láº¡i náº¿u chÆ°a xuáº¥t ra sáº£n xuáº¥t
			
			/*	if(@locationWarehouseCode='VVT_F2')
				begin
						select @checkoutproduction=COUNT(*) from Stb_SlittingStock_VVT where Location like '%SANXUAT%'
						if(@checkoutproduction=0)
						begin
							set @err = N'ChÆ°a xuáº¥t Ä‘iá»‡n cá»±c ra sáº£n xuáº¥t cáº§n báº¯n ra sáº£n xuáº¥t trÃªn há»‡ thá»‘ng slitting, hoáº·c sai mÃ£ Lot Slitting Äiá»‡n cá»±c: ' + @pRawMaterialBarcode ;
						end
				 end 
				 */
				 -- cháº·n mÃ£ NVL theo chuáº©n BOM náº¿u mÃ  k chuáº©n BOM thi sáº½ báº¯n lá»—i

				select @count=count(*) from STB_SetInfo  si			with(nolock) 
					join STB_ElectrodeSlittingInfo esi		with(nolock) on si.Barcode = esi.ElectrodeLotNumber
					join STB_ElectrodeSlittingResult esr	with(nolock) on esi.ElectrodeLotNumber = esr.ElectrodeLotNumber
					where esr.Barcode=@pRawMaterialBarcode 
					-- Ä‘á»ƒ táº¡m Ä‘á»ƒ cho sáº£n xuáº¥t lÆ°u
					declare @IsNextModel NVARCHAR(100)
					select @IsNextModel=MaterialCode from STB_SetInfo with(nolock) where barcode=@pBarcode
					if(@IsNextModel='ECVT30-309')
					BEGIN
					    set @err='';
	                       set @count=1;

					END
				IF (
					(@pBarcode= 'VVQK243R072749'	and @pRawMaterialBarcode='VWQK1620001E06-001' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVPU313R072712'	and @pRawMaterialBarcode='VWPU1720001E07-005' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVPU313R072708'	and @pRawMaterialBarcode='VWPU1820001E10-017' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK243R072747'	and @pRawMaterialBarcode='VWQK1620001E06-004' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK243R072742'	and @pRawMaterialBarcode='VWQK1820001E06-001' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK123R072710'	and @pRawMaterialBarcode='VWQK0420001E07-015' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK243R072745'	and @pRawMaterialBarcode='VWQK1720001E08-009' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK243R072748'	and @pRawMaterialBarcode='VWQK1620001E06-003' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK203R072778'	and @pRawMaterialBarcode='VWQK1520001E10-007' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK173R072716'	and @pRawMaterialBarcode='VWQK1020001E06-001' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK193R072737'	and @pRawMaterialBarcode='VWQK1520001E07-002' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK203R072705'	and @pRawMaterialBarcode='VWQK1520001E07-011' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK183R072776'	and @pRawMaterialBarcode='VWQK0820001E09-009' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK183R072777'	and @pRawMaterialBarcode='VWQK0820001E09-007' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK253R072734'	and @pRawMaterialBarcode='VWQK1820001E05-008' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK203R072784'	and @pRawMaterialBarcode='VWQK1520001E07-006' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK073R072759'	and @pRawMaterialBarcode='VVQK0620001E10-013' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK213R072771'	and @pRawMaterialBarcode='VWQK1420001E13-003' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK203R072785'	and @pRawMaterialBarcode='VWQK1520001E07-010' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQL013R072735'	and @pRawMaterialBarcode='VWQK2220001E09-009' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQL013R072736'	and @pRawMaterialBarcode='VWQK2220001E09-010' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQL013R072734'	and @pRawMaterialBarcode='VWQK2220001E09-007' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK203R072703'	and @pRawMaterialBarcode='VWQK1520001E07-013' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK203R072706'	and @pRawMaterialBarcode='VWQK1520001E07-012' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK203R072736'	and @pRawMaterialBarcode='VWQK1220001E05-010' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK203R072738'	and @pRawMaterialBarcode='VWQK1220001E05-007' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK203R072737'	and @pRawMaterialBarcode='VWQK1220001E05-008' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK203R072789'	and @pRawMaterialBarcode='VWQK1520001E07-008' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK193R072759'	and @pRawMaterialBarcode='VWQK1120001E09-016' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK013R072762'	and @pRawMaterialBarcode='VWQJ2220001E06-012' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK223R072712'	and @pRawMaterialBarcode='VWQK1420001E11-010' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK183R072770'	and @pRawMaterialBarcode='VWQK0820001E09-008' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK203R072710'	and @pRawMaterialBarcode='VWQK1520001E07-015' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK203R072719'	and @pRawMaterialBarcode='VWQK1420001E14-003' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK213R072702'	and @pRawMaterialBarcode='VWQK1420001E14-004' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK193R072738'	and @pRawMaterialBarcode='VWQK1520001E07-003' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK213R072704'	and @pRawMaterialBarcode='VWQK1420001E13-016' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK213R072703'	and @pRawMaterialBarcode='VWQK1420001E13-017' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK093R072784'	and @pRawMaterialBarcode='VWQJ3020001E12-010' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK213R072788'	and @pRawMaterialBarcode='VWQK1820001E01-005' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK203R072786'	and @pRawMaterialBarcode='VWQK1520001E07-009' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK203R072780'	and @pRawMaterialBarcode='VWQK1320001E02-014' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK093R072782'	and @pRawMaterialBarcode='VWQJ3020001E12-009' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK213R072721'	and @pRawMaterialBarcode='VWQK1420001E13-022' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK213R072705'	and @pRawMaterialBarcode='VWQK1420001E13-020' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK213R072706'	and @pRawMaterialBarcode='VWQK1420001E13-018' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQJ313R072703'	and @pRawMaterialBarcode='VWQJ2520001E05-010' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK183R072737'	and @pRawMaterialBarcode='VWQK1020001E06-007' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK183R072733'	and @pRawMaterialBarcode='VWQK0920001E12-005' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK183R072732'	and @pRawMaterialBarcode='VWQK0920001E12-003' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK173R072777'	and @pRawMaterialBarcode='VWQK0620001E07-009' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK183R072712'	and @pRawMaterialBarcode='VWQK1220001E06-002' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK203R072702'	and @pRawMaterialBarcode='VWQK1520001E07-014' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK183R072714'	and @pRawMaterialBarcode='VWQK1220001E06-001' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK123R072734'	and @pRawMaterialBarcode='VWQK0420001E07-007' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK123R072747'	and @pRawMaterialBarcode='VWQK0420001E07-008' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK143R072749'	and @pRawMaterialBarcode='VWQK0820001E09-001' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK173R072776'	and @pRawMaterialBarcode='VWQK0620001E07-007' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK183R072716'	and @pRawMaterialBarcode='VWQK1220001E06-005' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK273R072788'	and @pRawMaterialBarcode='VWQK1920001E06-003' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQL063R072742'	and @pRawMaterialBarcode='VWQK2720001E05-005' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQL053R072748'	and @pRawMaterialBarcode='VWQK2720001E05-010' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQL053R0727A5'	and @pRawMaterialBarcode='VWQK2520001E07-002' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQL063R072746'	and @pRawMaterialBarcode='VWQL0120001E07-008' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQL053R0727A4'	and @pRawMaterialBarcode='VWQK2520001E07-004' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQL043R072731'	and @pRawMaterialBarcode='VWQK2520001E07-010' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQL043R07279B'	and @pRawMaterialBarcode='VWQK2520001E06-008' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQL043R072725'	and @pRawMaterialBarcode='VWQK2520001E07-009' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK183R072713'	and @pRawMaterialBarcode='VWQK1220001E06-004' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK193R072760'	and @pRawMaterialBarcode='VWQK1120001E06-002' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK263R072783'	and @pRawMaterialBarcode='VWQK1720001E07-004' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK253R072789'	and @pRawMaterialBarcode='VWQK1620001E05-001' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK253R072788'	and @pRawMaterialBarcode='VWQK1620001E05-002' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK263R072758'	and @pRawMaterialBarcode='VWQK1720001E07-002' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK263R072759'	and @pRawMaterialBarcode='VWQK1720001E07-001' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK263R072757'	and @pRawMaterialBarcode='VWQK1720001E07-003' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK123R072711'	and @pRawMaterialBarcode='VWQK0420001E07-011' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK023R072752'	and @pRawMaterialBarcode='VWQJ2520001E11-002' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK033R072745'	and @pRawMaterialBarcode='VWQJ2620001E06-001' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVPU303R072729'	and @pRawMaterialBarcode='VWPU1720001E07-001' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQL043R07279C'	and @pRawMaterialBarcode='VWQK2520001E06-010' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQL043R072730'	and @pRawMaterialBarcode='VWQK2520001E07-007' and @pProductGroupCode = 'ELECTRODEP') OR
					(@pBarcode= 'VVQK253R072733'	and @pRawMaterialBarcode='VWQK1620001E05-008' and @pProductGroupCode = 'ELECTRODEP') OR

					(@pBarcode= 'VVQK233R072782'	and @pRawMaterialBarcode='VVQK1920001E08-009' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK233R072787'	and @pRawMaterialBarcode='VVQK2120001E08-006' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVPU313R072712'	and @pRawMaterialBarcode='VWPU2220001E05-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVPU313R072708'	and @pRawMaterialBarcode='VWPU1920001E01-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072759'	and @pRawMaterialBarcode='VVQK2220001E12-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK193R072758'	and @pRawMaterialBarcode='VWQK1520001E04-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072750'	and @pRawMaterialBarcode='VVQK2220001E12-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK233R072796'	and @pRawMaterialBarcode='VVQK1920001E07-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072746'	and @pRawMaterialBarcode='VVQK1420001E11-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK223R072756'	and @pRawMaterialBarcode='VVQK2120001E12-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072753'	and @pRawMaterialBarcode='VVQK1220001E04-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072747'	and @pRawMaterialBarcode='VVQK1220001E04-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072747'	and @pRawMaterialBarcode='VVQK1220001E16-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072749'	and @pRawMaterialBarcode='VVQK1820001E12-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK223R072754'	and @pRawMaterialBarcode='VVQK1820001E13-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK223R072757'	and @pRawMaterialBarcode='VVQK2120001E12-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072710'	and @pRawMaterialBarcode='VVQK2220001E12-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK233R072798'	and @pRawMaterialBarcode='VVQK1920001E07-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072717'	and @pRawMaterialBarcode='VWQK1020001E10-020' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK253R072744'	and @pRawMaterialBarcode='VVQJ2520001E34-011' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ233R072726'	and @pRawMaterialBarcode='VWQJ1620001E10-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ193R072703'	and @pRawMaterialBarcode='VWQJ0620001E02-008' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ183R072715'	and @pRawMaterialBarcode='VWQJ0420001E01-009' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072752'	and @pRawMaterialBarcode='VVQK1820001E06-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072759'	and @pRawMaterialBarcode='VVQK1920001E14-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ213R072716'	and @pRawMaterialBarcode='VJQJ1520001E07-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R07279U'	and @pRawMaterialBarcode='VVQK1820001E12-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R0727A0'	and @pRawMaterialBarcode='VVQK1120001E18-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R07279T'	and @pRawMaterialBarcode='VVQK1420001E05-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK193R072756'	and @pRawMaterialBarcode='VWQK1520001E04-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072725'	and @pRawMaterialBarcode='VWQK1520001E03-009' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072707'	and @pRawMaterialBarcode='VWQK1520001E04-008' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK193R072784'	and @pRawMaterialBarcode='VVQK1220001E16-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072755'	and @pRawMaterialBarcode='VVQK1820001E13-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK223R072744'	and @pRawMaterialBarcode='VVQK1820001E13-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072745'	and @pRawMaterialBarcode='VVQK1820001E06-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072749'	and @pRawMaterialBarcode='VVQK1920001E06-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072751'	and @pRawMaterialBarcode='VVQK1920001E06-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK193R072787'	and @pRawMaterialBarcode='VVQK1320001E06-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK193R072782'	and @pRawMaterialBarcode='VVQK1320001E06-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK193R072781'	and @pRawMaterialBarcode='VVQK1320001E06-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R07279V'	and @pRawMaterialBarcode='VVQK1920001E05-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072768'	and @pRawMaterialBarcode='VVQK2420001E08-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK233R072785'	and @pRawMaterialBarcode='VVQK1920001E08-006' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ203R072710'	and @pRawMaterialBarcode='VWQJ1320001E20-008' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK223R072746'	and @pRawMaterialBarcode='VVQK1920001E15-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK253R072702'	and @pRawMaterialBarcode='VVQK2420001E08-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072786'	and @pRawMaterialBarcode='VVQJ2520001E34-017' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK233R072781'	and @pRawMaterialBarcode='VVQK1920001E08-010' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK253R072703'	and @pRawMaterialBarcode='VVQK2220001E11-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK253R072704'	and @pRawMaterialBarcode='VVQK2420001E21-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072785'	and @pRawMaterialBarcode='VVQJ2520001E34-015' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK253R072713'	and @pRawMaterialBarcode='VVQK2220001E11-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK253R072712'	and @pRawMaterialBarcode='VVQK2220001E11-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072763'	and @pRawMaterialBarcode='VVQK2420001E09-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072781'	and @pRawMaterialBarcode='VVQK2120001E07-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R07279W'	and @pRawMaterialBarcode='VVQK1920001E05-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK253R072711'	and @pRawMaterialBarcode='VVQK2420001E21-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072764'	and @pRawMaterialBarcode='VVQK2420001E09-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072767'	and @pRawMaterialBarcode='VVQJ2520001E34-018' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072766'	and @pRawMaterialBarcode='VVQJ2520001E34-016' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072765'	and @pRawMaterialBarcode='VVQK2420001E09-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK083R072745'	and @pRawMaterialBarcode='VWQJ3020001E01-012' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK253R072714'	and @pRawMaterialBarcode='VVQJ2520001E34-009' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK233R072791'	and @pRawMaterialBarcode='VVQK2220001E20-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK183R072755'	and @pRawMaterialBarcode='VVQK1420001E12-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK223R072755'	and @pRawMaterialBarcode='VVQK2120001E12-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK223R072751'	and @pRawMaterialBarcode='VVQK1820001E12-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK253R072741'	and @pRawMaterialBarcode='VVQK2420001E08-006' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ253R072763'	and @pRawMaterialBarcode='VWQJ1520001E03-012' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK223R072753'	and @pRawMaterialBarcode='VVQK1820001E14-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK233R072795'	and @pRawMaterialBarcode='VVQK1920001E07-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK233R072770'	and @pRawMaterialBarcode='VWQK1020001E10-019' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ223R072757'	and @pRawMaterialBarcode='VVQJ2120001E25-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072704'	and @pRawMaterialBarcode='VWQK1320001E04-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072726'	and @pRawMaterialBarcode='VWQK1520001E03-006' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072734'	and @pRawMaterialBarcode='VWQK1520001E03-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072723'	and @pRawMaterialBarcode='VWQK1520001E03-010' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072708'	and @pRawMaterialBarcode='VWQK1520001E04-007' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072756'	and @pRawMaterialBarcode='VVQK1920001E14-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK193R072757'	and @pRawMaterialBarcode='VWQK1520001E04-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK083R072701'	and @pRawMaterialBarcode='VWQJ3020001E03-010' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK083R072710'	and @pRawMaterialBarcode='VWQJ3020001E03-006' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK083R072708'	and @pRawMaterialBarcode='VWQJ3020001E03-009' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072757'	and @pRawMaterialBarcode='VVQK1120001E18-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK193R072785'	and @pRawMaterialBarcode='VVQK1320001E06-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072748'	and @pRawMaterialBarcode='VVQK1420001E05-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK083R072739'	and @pRawMaterialBarcode='VWQJ3020001E01-015' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK073R072720'	and @pRawMaterialBarcode='VWQJ2920001E01-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK193R072788'	and @pRawMaterialBarcode='VVQK1420001E11-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK183R072796'	and @pRawMaterialBarcode='VWQK1120001E08-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072746'	and @pRawMaterialBarcode='VVQK1220001E04-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072748'	and @pRawMaterialBarcode='VVQK1920001E06-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072743'	and @pRawMaterialBarcode='VVQK1820001E06-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072709'	and @pRawMaterialBarcode='VWQK1520001E04-009' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072754'	and @pRawMaterialBarcode='VVQK1820001E13-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK233R072786'	and @pRawMaterialBarcode='VVQK1920001E08-008' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK223R072770'	and @pRawMaterialBarcode='VWQK1420001E01-010' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK253R072743'	and @pRawMaterialBarcode='VVQK2220001E11-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK233R072784'	and @pRawMaterialBarcode='VVQK2120001E07-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072758'	and @pRawMaterialBarcode='VVQK1920001E14-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK183R072756'	and @pRawMaterialBarcode='VVQK1220001E16-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R07279Z'	and @pRawMaterialBarcode='VVQK1920001E05-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK223R072752'	and @pRawMaterialBarcode='VVQK1920001E15-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072743'	and @pRawMaterialBarcode='VVQK1420001E12-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK183R072754'	and @pRawMaterialBarcode='VVQK1420001E12-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072742'	and @pRawMaterialBarcode='VVQK1420001E12-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK193R072783'	and @pRawMaterialBarcode='VVQK1220001E16-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R07279X'	and @pRawMaterialBarcode='VVQK1920001E05-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072745'	and @pRawMaterialBarcode='VVQK1420001E05-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072741'	and @pRawMaterialBarcode='VVQK1420001E12-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072744'	and @pRawMaterialBarcode='VVQK1420001E05-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK223R072758'	and @pRawMaterialBarcode='VVQK2120001E12-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK213R072744'	and @pRawMaterialBarcode='VVQK1820001E06-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK063R072719'	and @pRawMaterialBarcode='VWQJ2920001E03-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK083R072709'	and @pRawMaterialBarcode='VWQJ3020001E03-008' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK193R072786'	and @pRawMaterialBarcode='VVQK1420001E11-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK083R072717'	and @pRawMaterialBarcode='VWQJ3020001E01-010' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ313R072705'	and @pRawMaterialBarcode='VWQJ2420001E01-007' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ313R072704'	and @pRawMaterialBarcode='VWQJ2420001E01-008' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK053R072787'	and @pRawMaterialBarcode='VWQJ2820001E07-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK053R072745'	and @pRawMaterialBarcode='VWQJ2820001E07-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK053R072779'	and @pRawMaterialBarcode='VWQJ2820001E07-015' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ223R072796'	and @pRawMaterialBarcode='VWQJ1520001E01-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ233R072741'	and @pRawMaterialBarcode='VVQJ2220001E26-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R072733'	and @pRawMaterialBarcode='VWQK1520001E03-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK133R072752'	and @pRawMaterialBarcode='VWQK0320001E04-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK153R072749'	and @pRawMaterialBarcode='VWQK0820001E03-007' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK133R072715'	and @pRawMaterialBarcode='VWQK0320001E04-014' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK153R072748'	and @pRawMaterialBarcode='VWQK0820001E03-006' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072702'	and @pRawMaterialBarcode='VVQK2020001E01-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK253R072742'	and @pRawMaterialBarcode='VVQK2420001E08-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK233R072794'	and @pRawMaterialBarcode='VVQK2220001E20-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072716'	and @pRawMaterialBarcode='VVQK2220001E10-013' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK273R072718'	and @pRawMaterialBarcode='VWQK2220001E04-007' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK233R072783'	and @pRawMaterialBarcode='VVQK2120001E07-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK233R072790'	and @pRawMaterialBarcode='VVQK2120001E08-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQL053R0727A5'	and @pRawMaterialBarcode='VWQL0120001E02-012' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQL053R072705'	and @pRawMaterialBarcode='VWQL0120001E02-006' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQL033R072751'	and @pRawMaterialBarcode='VVQL0120001E03-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQL053R0727A4'	and @pRawMaterialBarcode='VWQL0120001E02-014' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQL053R0727AG'	and @pRawMaterialBarcode='VWQL0120001E02-013' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQL033R072706'	and @pRawMaterialBarcode='VVQL0120001E03-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQL033R072703'	and @pRawMaterialBarcode='VVQL0120001E10-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQL053R072707'	and @pRawMaterialBarcode='VWQL0120001E02-007' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072704'	and @pRawMaterialBarcode='VVQK2120001E05-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQL033R072749'	and @pRawMaterialBarcode='VVQL0120001E10-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK273R072731'	and @pRawMaterialBarcode='VWQK2220001E04-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072701'	and @pRawMaterialBarcode='VVQK2120001E05-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK273R072736'	and @pRawMaterialBarcode='VWQK2220001E04-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072708'	and @pRawMaterialBarcode='VVQK2220001E19-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK233R072769'	and @pRawMaterialBarcode='VWQK1020001E10-018' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK273R072735'	and @pRawMaterialBarcode='VWQK2220001E04-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK223R072745'	and @pRawMaterialBarcode='VVQK1820001E12-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK203R07279Y'	and @pRawMaterialBarcode='VVQK1920001E05-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072703'	and @pRawMaterialBarcode='VVQK2020001E01-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK273R072732'	and @pRawMaterialBarcode='VWQK2220001E04-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK273R072720'	and @pRawMaterialBarcode='VWQK2220001E04-008' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK273R072717'	and @pRawMaterialBarcode='VWQK2220001E04-006' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072705'	and @pRawMaterialBarcode='VVQK2220001E19-006' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK253R072746'	and @pRawMaterialBarcode='VVQK2420001E12-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK223R072747'	and @pRawMaterialBarcode='VVQK1820001E14-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072725'	and @pRawMaterialBarcode='VWQK1020001E10-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK253R072747'	and @pRawMaterialBarcode='VVQK2420001E12-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK223R072749'	and @pRawMaterialBarcode='VVQK1820001E14-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK253R072748'	and @pRawMaterialBarcode='VVQK2420001E12-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072718'	and @pRawMaterialBarcode='VWQK1020001E10-017' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK253R072749'	and @pRawMaterialBarcode='VVQK2420001E12-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK133R072712'	and @pRawMaterialBarcode='VWQK0320001E04-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK133R072703'	and @pRawMaterialBarcode='VWQK0320001E04-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK133R072702'	and @pRawMaterialBarcode='VWQK0320001E04-004' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ303R072715'	and @pRawMaterialBarcode='VVQJ2920001E17-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ253R072795'	and @pRawMaterialBarcode='VWPU1320001E05-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ293R072747'	and @pRawMaterialBarcode='VVQJ2520001E20-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ223R072727'	and @pRawMaterialBarcode='VVQJ2120001E21-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ303R072716'	and @pRawMaterialBarcode='VVQJ2920001E17-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ223R072726'	and @pRawMaterialBarcode='VVQJ2120001E21-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQL033R072705'	and @pRawMaterialBarcode='VVQL0220001E05-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQL033R072753'	and @pRawMaterialBarcode='VVQL0220001E05-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQL033R072701'	and @pRawMaterialBarcode='VVQL0120001E03-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQL033R072704'	and @pRawMaterialBarcode='VVQL0120001E10-001' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQJ023R072712'	and @pRawMaterialBarcode='VWPU0220001E03-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072709'	and @pRawMaterialBarcode='VVQK2220001E19-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK233R072788'	and @pRawMaterialBarcode='VVQK2120001E08-005' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072762'	and @pRawMaterialBarcode='VVQK2420001E09-002' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK243R072761'	and @pRawMaterialBarcode='VVQK2420001E09-003' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQK273R072719'	and @pRawMaterialBarcode='VWQK2220001E04-010' and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVQL193R072753'	and @pRawMaterialBarcode='VWQL1520001E01-004' and @pProductGroupCode = 'ELECTRODEP') OR		--
					(@pBarcode= 'VVQM193R072798'	and @pRawMaterialBarcode='VWQH1520001E05-004' and @pProductGroupCode = 'ELECTRODEM') OR

					(@pBarcode= 'VVQK143R072774'	and @pProductGroupCode = 'ELECTRODEM') OR
					(@pBarcode= 'VVPU293R072705'	) OR
					(@pBarcode= 'VVQK143R072776'	and @pProductGroupCode = 'ELECTRODEP') OR
					(@pRawMaterialBarcode LIKE 'VVQL2520001E07%'	and @pProductGroupCode = 'ELECTRODEP') 
					
					--OR @pRawMaterialBarcode LIKE 'VWQL1520001E%'
					--OR @pRawMaterialBarcode LIKE 'VVQL1520001E%'

					-- Láº¥y danh sÃ¡ch cÃ¡c lot bá»‹ thiáº¿u 
					OR ( @IsNextModel = 'ECVT30-357' AND substring(@pRawMaterialBarcode,1,14) IN (SELECT DISTINCT ElectrodeLotNumber
																									FROM STB_ElectrodeSlittingResult
																									WHERE ElectrodeLotNumber NOT IN (
																										SELECT ElectrodeLotNumber
																										FROM STB_ElectrodeSlittingResult
																										WHERE Seq = 1 OR Seq = 2
																										--and CreateDateTime > '2025-10-01'
																									)
																									and CreateDateTime > '2026-03-15' ))

					)

					begin
						set @err='';
						set @count=1;
						
					end
			 

				if(@count<1 and @err='')  begin	
					set @err = N'ChÆ°a nháº­p thÃ´ng tin Slitting Äiá»‡n cá»±c á»Ÿ mÃ n hÃ¬nh B552, hoáº·c sai mÃ£ Lot Slitting Äiá»‡n cá»±c: ' + @pRawMaterialBarcode + '|' + @pProductGroupCode;
				end

				select  @count=count(*)  from STB_SetInfo with(nolock) where barcode=@pBarcode

				if(@count<1 and @err='')  begin	
					set @err = N'Sai dá»¯ liá»‡u hoáº·c khÃ´ng tá»“n táº¡i LotNo: ' + @pBarcode ;
				end

				select  @count=count(*)  from STB_ModelBasicInfo  with(nolock)  where ModelCode=(select MaterialCode from STB_SetInfo with(nolock) where barcode=@pBarcode)

				if(@count<1 and @err='')  begin	
					set @err = N'ChÆ°a thiáº¿t láº­p thÃ´ng tin cÆ¡ báº£n cho Sáº£n pháº©m: ' + (select MaterialCode from STB_SetInfo with(nolock) where barcode=@pBarcode) ;
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
				--raiserror (@pBarcode ,16,1) ;
					if(@count>0) begin
						update  Stb_SlittingStock_VVT
						set  warehousecode='CHG_VN_WH'
						, Barcode=convert(varchar(6),DATEPART(microsecond,getdate())) + Barcode
						, ElectrodeLotNumber=convert(varchar(6),DATEPART(microsecond,getdate())) + ElectrodeLotNumber					  
						where barcode=@pRawMaterialBarcode ;
					end

					--  pháº§n nÃ y liÃªn quan Ä‘áº¿n tá»“n kho Slitting Zone    http://192.168.1.234:8090/tv  
					-- khi mÃ£ Slitting Äiá»‡n cá»±c báº¯n vÃ o Ä‘Ã¢y, thÃ¬ sáº½ tá»± Ä‘á»™ng trá»« tá»“n kho á»Ÿ    http://192.168.1.234:8090/tv  
					exec usp_Vietnam_SlittingStock_get  @pProcessUserID,'EA_PASS','','',@pRawMaterialBarcode,@pBarcode ;


				end


				DECLARE @pProductGroupCodeM VARCHAR(20) = @pProductGroupCode;
				--Ä‘Ã¢y lÃ  pháº§n ngoáº¡i lá»‡ hÃ ng Bigsize , lÃ  chá»‰ dÃ¹ng Ä‘iá»‡n cá»±c DÆ°Æ¡ng, khÃ´ng dÃ¹ng Ä‘iá»‡n cá»±c Ã‚m, 
				--nÃªn thay Ä‘á»•i biáº¿n  @pProductGroupCode tá»« ELECTRODEM -> ELECTRODEP
				;with texclude as (
				select 'VEC2R7107QG' as model union all
				select 'VEB3R0107QG' as model union all
				--select 'VEC3R0107QG' as model union all
				--select 'VEC3R0107QG' as model union all
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
				
				/*
				Láº¥y ra partno 35105 khÃ¡c vá»›i cÃ¡c loáº¡i cÃ²n láº¡i Ä‘á»ƒ kiá»ƒm tra Ä‘iá»u kiá»‡n
				*/
				declare @partNoEle varchar(50)
				--exec usp_getPartNoElectrone @pRawMaterialBarcode,@partNoEle OUTPUT

				select @partNoEle=materialcode from stb_setinfo where barcode=@pBarcode
				--END
		
				
				if(@partNoEle in ('ECVT30-357')) --náº¿u lÃ  hÃ ng nÃ y thÃ¬ Ä‘iá»‡n cá»±c sáº½ khÃ¡c 1 chÃºt pháº£i check thÃªm
					begin
					select  @count=count(*)  from STB_MaterialMaster  with(nolock)  
						where MaterialCode=(select MaterialCode from STB_SetInfo with(nolock) where barcode=substring(@pRawMaterialBarcode,1,14) )
						and (( MaterialName like  case when  UPPER(isnull(@pProductGroupCode,''))='ELECTRODEP' then '%CY%' else '%YP%' end 
							OR (MaterialName like  '%CEP%'  or  MaterialName like  '%HCE%') )   -- Mr.Manh update 2025-12-29 add HCE

						and ( MaterialName like  case when  UPPER(isnull(@pProductGroupCode,''))='ELECTRODEP' then '%(+)%' else '%(-)%' end 
							or  MaterialName like case when  UPPER(isnull(@pProductGroupCode,''))='ELECTRODEP' then '%Etch%' else '%Form%' end

						AND ( MaterialName like  case when  UPPER(isnull(@pProductGroupCode,''))='ELECTRODEM' then '%(-)%' else '%(+)%' end 
							OR (MaterialName like  '%YP%') ))   -- Mr.Manh update 2026-02-25 
						
						-- ThÃªm danh sÃ¡ch cÃ¡c Ä‘iá»‡n cá»±c Ä‘Æ°á»£c báº¯n láº«n lá»™n Ã¢m dÆ°Æ¡ng cho Ä‘á»¡ pháº£i check má»‡t ngÆ°á»i, vÃ¬ tÃªn há» Ä‘áº·t cháº£ theo tiÃªu chuáº©n gÃ¬ cáº£
						OR (MaterialCode IN ('CRYPK0-016', 'CRECO85-03', 'CREYO85-04', 'CREYO85-02', 'CREYO85-02', 'CRYPK0-016', 'CRYPK0-017', 'CRYPK0-018', 'CRCEK0-268', 'CRCEK0-266', 'CRYPK0-011', 'CRYPK0-022'))

						)
					end

				-- UPDATE model 35105 dÃ¹ng 2 Ä‘iá»‡n cá»±c +
				declare @checkElectrodeM int = 0 
				select @checkElectrodeM = count(*)  from STB_MaterialMaster  with(nolock)  
						where MaterialCode=(select MaterialCode from STB_SetInfo with(nolock) where barcode=substring(@pRawMaterialBarcode,1,14))
							and MaterialName LIKE '%(+)%'
				if(@partNoEle in ('ECVT30-357') and UPPER(isnull(@pProductGroupCode,''))='ELECTRODEM' and @checkElectrodeM <> 0)
					BEGIN
						set @err='';
						set @count=1;
					END
				-- END

				if(@count<1 and @err='')  begin	
					set @err = N'KhÃ´ng Ä‘Ãºng loáº¡i Äiá»‡n cá»±c (DÆ°Æ¡ng)(+Etching) hoáº·c (Ã‚m)(-Forming):  ' 
									+ @pProductGroupCode +' : '
									+ (select MaterialCode from STB_SetInfo with(nolock) where barcode=substring(@pRawMaterialBarcode,1,14)) ;
				end
				-- cháº·n náº¿u mÃ  khÃ¡c NVL Ä‘iá»‡n cá»±c k thuá»™c model nÃ y thÃ¬ báº¯n lá»—i
				DECLARE @modelOfElectrode VARCHAR(50);

            -- Láº¥y model tÆ°Æ¡ng á»©ng cá»§a Ä‘iá»‡n cá»±c (náº¿u Ä‘Ã£ Ä‘Æ°á»£c gÃ¡n trong SetInfo)
           


			set @pProductGroupCode = @pProductGroupCodeM
							
				--raiserror (@pRawMaterialBarcode ,16,1) ;
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
				--set @count=1;		
				if(@pBarcode='VVNK162R812601' and @pRawMaterialBarcode='VJMT1020001E02-018' and @pProductGroupCode = 'ELECTRODEP'
				or @pBarcode='VVNK162R812601' and @pRawMaterialBarcode='VJMU1220001E05-020' and @pProductGroupCode = 'ELECTRODEM'
				or @pBarcode='VVPR013R015601' and @pRawMaterialBarcode='VVPQ2520001E30-001' and @pProductGroupCode = 'ELECTRODEP'   -- add on 2025-09-06
				or @pBarcode='VVPR013R015601' and @pRawMaterialBarcode='VVPQ2520001E30-001' and @pProductGroupCode = 'ELECTRODEM'
				or @Barcode='VVPR013R015601' and @pRawMaterialBarcode='VVPQ2120001E02' -- add on 2025-09-06
				or @pBarcode='VVPS023R010624' and @pRawMaterialBarcode='VVPR2820001E14-003' and @pProductGroupCode = 'ELECTRODEP'   -- add on 2025-10-02
				or @pBarcode='VVPS023R010624' and @pRawMaterialBarcode='VVPR2920001E01-019' and @pProductGroupCode = 'ELECTRODEM'
				or @pBarcode='VVPS023R010601' and @pRawMaterialBarcode='VVPR2920001E36-020' and @pProductGroupCode = 'ELECTRODEM'   -- add on 2025-10-02
				or @pBarcode='VVPS023R010606' and @pRawMaterialBarcode='VVPR2920001E27-001' and @pProductGroupCode = 'ELECTRODEP'
				or @pBarcode='VVQK093R060647' and @pRawMaterialBarcode LIKE 'VVQK0620001E27%' and @pProductGroupCode = 'ELECTRODEP'


				)
					begin
						set @err='';
						set @count=1;
						--cho phep theo email  VÅ¨ HUY, ngay 28 thÃ¡ng 2 nÄƒm 2023
					end
				--1840
				
				-- update 2026-01-07 for 35105 and HCE electrode slitting
				declare @materialCodeCheck varchar(50),
						@rawMaterialCheck Varchar(50),
						@countcheck INT = 0
				select @materialCodeCheck = MaterialCode FROM STB_SetInfo where Barcode = @pBarcode
				select @rawMaterialCheck = MaterialCode FROM STB_SetInfo where barcode = SUBSTRING(@pRawMaterialBarcode,1,14) 
				--select @countcheck=count(*) from STB_SetInfo  si			with(nolock) 
				--	join STB_ElectrodeSlittingInfo esi		with(nolock) on si.Barcode = esi.ElectrodeLotNumber
				--	join STB_ElectrodeSlittingResult esr	with(nolock) on esi.ElectrodeLotNumber = esr.ElectrodeLotNumber
				--	where esr.Barcode=@pRawMaterialBarcode 
				if (@materialCodeCheck IN ('ECVT30-357') and @rawMaterialCheck IN ( 'CRYPK0-018','CRYPK0-017', 'CREHCO85', 'SREHCO0', 'CRYPK0-016', 'CRECO85-03', 'CREYO85-04', 'CREYO85-02', 'CREYO85-04', 'CRYPK0-016', 'CRYPK0-017', 'CRYPK0-018', 'CRCEK0-268', 'CRCEK0-266', 'CRYPK0-016', 'CRECO85-03', 'CREYO85-04', 'CREYO85-02', 'CREYO85-02', 'CRYPK0-016', 'CRYPK0-017', 'CRYPK0-018', 'CRCEK0-268', 'CRYPK0-011', 'CRYPK0-022'))
					begin
						set @count=1;
					end
                --update for 1035
				if(@materialCodeCheck IN ('ECVT30-309') and @rawMaterialCheck IN ('CREYO85-04', 'CRFYO85-02'))
				    begin
					  set @count = 1;
					end
			    --end for 1035

                --update for 1025
				if(@materialCodeCheck IN ('ECVT30-270') and @rawMaterialCheck IN ('CRCEK0-266', 'CRYPK0-022'))
				    begin
					  set @count = 1;
					end
			    --end for 1025

				-- end update


				if(@count<1 and @err='')  begin
					set @err = N'KhÃ´ng tá»“n táº¡i thiáº¿t láº­p Äiá»‡n cá»±c cá»§a LotNo:  ' +@pBarcode + '  PartNo  = ' 
								
								+ isnull((
									select @ModelSize  
									+ ' , Farad = '+MBIExtText05+'F'
									from STB_ModelBasicInfo  with(nolock)  				
									where ModelCode=(select MaterialCode from STB_SetInfo with(nolock) where barcode=@pBarcode)
								    ),'')
								
								+  N'  vá»›i Lot Slitting Äiá»‡n cá»±c:  ' + @pRawMaterialBarcode + N' ,  Chiá»u rá»™ng(Width)  = '
								
								+ isnull((select convert(varchar(8),convert(numeric(5,2),SlittingWidth)) from STB_ElectrodeSlittingResult  with(nolock) where Barcode=@pRawMaterialBarcode),'')
								
								+ isnull((select N' ,  Loáº¡i Äiá»‡n cá»±c  = ' + mm.MaterialSource + N' ,  Ä‘á»™ DÃ y = '+ mm.MaterialThickness +'  ,  code = '+ si.MaterialCode + ' : '+ mm.MaterialName 
									from  STB_SetInfo si with(nolock) 
									left outer join STB_MaterialMaster mm  with(nolock)  on si.MaterialCode=mm.MaterialCode
									where barcode = SUBSTRING(@pRawMaterialBarcode,1,14)  ),'   Thiáº¿t láº­p trong báº£ng  STB_MATERIALMASTER  thiáº¿u dá»¯ liá»‡u  MaterialSource vÃ  MaterialThickness')

								+ N'   .   Dá»¯ liá»‡u trong  STB_SLITTINGLOCATIONCONFIG_VVT  = '
								
								+ isnull((select top 1 SlittingCode+'-'+SlittingSize+N',   Chiá»u rá»™ng(Width)  = '+convert(varchar(8),convert(numeric(5,2),Width))+', Farad ='+convert(varchar(5),convert(INT,Farad))
									from STB_SLITTINGLOCATIONCONFIG_VVT with(nolock) where PartNo in (
									select @ModelSize  + ' , Farad='+MBIExtText05+'F'
									from STB_ModelBasicInfo  with(nolock)  				
									where ModelCode=(select MaterialCode from STB_SetInfo with(nolock) where barcode=@pBarcode)
								    ) ),N'  ChÆ°a  CONFIG  trong báº£ng  :  STB_SLITTINGLOCATIONCONFIG_VVT ') 

				end

		
							   					
				select  @count=count(*)  from Stb_SlittingStock_VVT where barcode=@pRawMaterialBarcode
		


				if(@pBarcode='VVNK162R812601' and @pRawMaterialBarcode='VJMT1020001E02-018' and @pProductGroupCode = 'ELECTRODEP'
				or @pBarcode='VVNK162R812601' and @pRawMaterialBarcode='VJMU1220001E05-020' and @pProductGroupCode = 'ELECTRODEM'
				or @Barcode='VVPR253R010604' and @pRawMaterialBarcode='VVPR2320001E23-019' and @pProductGroupCode = 'ELECTRODEM'
				or @Barcode='VVPR252R710610' and @pRawMaterialBarcode='VVPR2120001E26-006' and @pProductGroupCode = 'ELECTRODEP'
				or @Barcode='VVPR253R050503' and @pRawMaterialBarcode='VVPR2312001E17-010' and @pProductGroupCode = 'ELECTRODEP'
				or @Barcode='VVPR253R050503' and @pRawMaterialBarcode='VVPR2012001E12-003' and @pProductGroupCode = 'ELECTRODEM'
				or @Barcode='VVPR252R710610' and @pRawMaterialBarcode='VVPR1720001E44-023' and @pProductGroupCode = 'ELECTRODEM'
				or @Barcode='VVPR253R070503' and @pRawMaterialBarcode='VVPR1820001E27-001' and @pProductGroupCode = 'ELECTRODEM'
				or @Barcode='VVPR243R033512' and @pRawMaterialBarcode='VVPR2012001E14-002' and @pProductGroupCode = 'ELECTRODEM'
				or @Barcode='VVPR243R033509' and @pRawMaterialBarcode='VVPR2012001E14-004'  and @pProductGroupCode = 'ELECTRODEP'
				or @Barcode='VVPR243R033509' and @pRawMaterialBarcode='VVPR1712001E38-025' and @pProductGroupCode = 'ELECTRODEM'
				or @Barcode='VVPR253R010605' and @pRawMaterialBarcode='VVPR2320001E23-019' and @pProductGroupCode = 'ELECTRODEM'
				or @Barcode='VVPR252R710604' and @pRawMaterialBarcode= 'VVPR2220001E32-009' and @pProductGroupCode = 'ELECTRODEP'
				 or @Barcode='VVPR252R710604' and @pRawMaterialBarcode='VVPR1920001E25-003' and @pProductGroupCode = 'ELECTRODEM'
				 or @Barcode='VVPR253R010606' and @pRawMaterialBarcode='VVPR2320001E23-019' and @pProductGroupCode = 'ELECTRODEM'
				 or @Barcode='VVPR252R710607' and @pRawMaterialBarcode='VVPR2220001E32-003' and @pProductGroupCode = 'ELECTRODEP' --updated 2025-09-25
				 or @Barcode='VVQM193R072798' and @pRawMaterialBarcode='VWQH1520001E05-004' and @pProductGroupCode = 'ELECTRODEM' --updated 2026-04-23

				)
				
				begin
					set @err='';
					set @count=1;
					--cho phep theo email  VÅ¨ HUY, ngay 28 thÃ¡ng 2 nÄƒm 2023
				end


				-- update 2025-10-02 because this model 1030
				--declare @materialCodeCheck2 varchar(50),
				--		@countcheck2 INT = 0
				--select @materialCodeCheck2 = MaterialCode FROM STB_SetInfo where Barcode = @pBarcode
				--select @countcheck2=count(*) from STB_SetInfo  si			with(nolock) 
				--	join STB_ElectrodeSlittingInfo esi		with(nolock) on si.Barcode = esi.ElectrodeLotNumber
				--	join STB_ElectrodeSlittingResult esr	with(nolock) on esi.ElectrodeLotNumber = esr.ElectrodeLotNumber
				--	where esr.Barcode=@pRawMaterialBarcode 
				--if (@materialCodeCheck2 IN ('ECVT30-247', 'ECVT30-197') and @countcheck2 > 0)
				--	begin
				--		set @count=1;
				--	end
				-- end update
				
				-- update 2026-01-07 for 35105 and HCE electrode slitting
				if (@materialCodeCheck IN ('ECVT30-357') and @rawMaterialCheck IN ( 'CRYPK0-018','CRYPK0-017', 'CREHCO85', 'SREHCO0', 'CRYPK0-016', 'CRECO85-03', 'CREYO85-04', 'CREYO85-02', 'CREYO85-04', 'CRYPK0-016', 'CRYPK0-017', 'CRYPK0-018', 'CRCEK0-268', 'CRCEK0-266', 'CRYPK0-016', 'CRECO85-03', 'CREYO85-04', 'CREYO85-02', 'CREYO85-02', 'CRYPK0-016', 'CRYPK0-017', 'CRYPK0-018', 'CRCEK0-268', 'CRYPK0-011', 'CRYPK0-022'))
					begin
						set @count=1;
					end

					--update for 1035
				if (@materialCodeCheck IN ('ECVT30-309') and @rawMaterialCheck IN ('CRFYO85-02','CREYO85-04'))
					begin
						set @count=1;
					end
					--end 1035

				-- end update

				--set @count=1;
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

				--Mr.duy thÃªm dá»¯ liá»‡u xuáº¥t ra line cho Ä‘iá»‡n cá»±c
				
					 exec usp_MaterialWarehouseInOutHist_iud_exportElectr @pProcessUserID,@pProcessLanguage,@BarcodeInsert,@LotMaterialBarcode,0,'insert'
				
				--end
		end		 					

		
		







		--kiá»ƒm tra NVL Tape Pi
if( UPPER(isnull(@pProductGroupCode,'')) in ( 'PiTape' )  /*or upper(@pProductGroupCode) like '%TAPE%'  */) begin	


     select @pRawMaterialBarcode = substring(ltrim(rtrim(@pRawMaterialBarcode)),1,10)
	 
	 if( @pRawMaterialBarcode like '%GBRXPL-001%' 
								 or @pRawMaterialBarcode like '%GBRXPL-002%' 
								 or @pRawMaterialBarcode like '%GBRXPL-003%'
	 )begin
				raiserror (N'KhÃ´ng Ä‘Æ°á»£c phÃ©p sá»­ dá»¥ng RONGXIN Tape, vui lÃ²ng liÃªn há»‡ bá»™ pháº­n QC ' ,16,1) ;
				return;	
	 end
	

	if(@pRawMaterialBarcode like 'GBRBPL-001%' 
	or @pRawMaterialBarcode like 'GBRBPL-002%' 
	or @pRawMaterialBarcode like 'GBRBPL-003%'
	or @pRawMaterialBarcode like 'GBRBPL-004%'
	or @pRawMaterialBarcode like 'GBTPPL-008%' 
	or @pRawMaterialBarcode like 'GBTPPL-001%' 
	or @pRawMaterialBarcode like 'GBTPPL-007%'
	or @pRawMaterialBarcode like 'GBTPPL-002%'
	--or @pRawMaterialBarcode like 'GBRXPL-002%'  --ronxing
	--or @pRawMaterialBarcode like 'GBRXPL-003%' --ronxing
	 )begin
		
			set @pRawMaterialBarcode=@pRawMaterialBarcode; 
	 end
	 else 
	 begin
			--RUIBAI	GBRBPL-001
			--RUIBAI	GBRBPL-002
			--RUIBAI	GBRBPL-003
			--TAPEX	GBTPPL-008
			--TAPEX	GBTPPL-001
			--TAPEX	GBTPPL-007
			--TAPEX	GBTPPL-002
			raiserror (N'Nháº­p sai Ä‘á»‹nh dáº¡ng Tape, khÃ´ng pháº£i Ä‘á»‹nh dáº¡ng RUIBAI hoáº·c TAPEX, vui lÃ²ng liÃªn há»‡ bá»™ pháº­n QC ' ,16,1) ;
			return;	
	 end

		
			;with tapetable1 as ( 				
			  select materialcode as tapecode, replace(replace(replace(replace(replace(replace(semiProductname,'HY-CAP ',''),'HY-CAP',''),'-C',''),'-M',''),'MSP',''),'(CY)','') as models, replace(size,'-L','') as size 
			  from stb_vvt_materialbo with(nolock)
			  where part like '%tape%' and size is not null and semiProductname not like '%Element%'
			  			  union all 
			  select distinct ChildMaterialCode,replace(replace(replace(replace(replace(replace(mbi.modelname,'HY-CAP ',''),'HY-CAP',''),'-C',''),'-M',''),'MSP',''),'(CY)',''),
				--RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) 
				RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) 
				from STB_BomDetail bd with(nolock) 
				join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
				where   modelname like '%HY-CAP%' or  modelname like 'VEL%'
			)
			 ,tapetable as (
			  select 
				case when tapecode in ('GBTPPL-008','GBRBPL-001') then 'GBTPPL-008 , GBRBPL-001'
				when tapecode in ('GBTPPL-001','GBRBPL-002') then 'GBTPPL-001 , GBRBPL-002'
				when tapecode in ('GBTPPL-007','GBRBPL-003') then 'GBTPPL-007 , GBRBPL-003'
				else tapecode end as tapecode
			  , --replace(replace(replace(replace(models,'('+size+')',''),'(',''),')',''),' ','') 
			  replace(replace(models,' ',''),'('+size+')','') models, size 
			  --replace(models,'('+size+')','') models, size 
			  from tapetable1
			  where len(size)=4 or len(size)=5
			)		
			select  @count=count(*) 
			from STB_ModelBasicInfo mbi  with(nolock) 
			join tapetable on   @ModelSize = tapetable.size 
			and (models like '%' + mbi.ModelName + '%' or mbi.ModelName like '%'+models +'%')
			where /*ModelCode=@MaterialCode(select MaterialCode from STB_SetInfo with(nolock) where barcode=@pBarcode) 
			and*/ tapecode like '%'+ @pRawMaterialBarcode +'%'
			and @pRawMaterialBarcode  = 
				(case when 
					ModelName like '%-L%' 
					and @ModelSize='1030' 
				then 
				'GBTPPL-007' 
				else @pRawMaterialBarcode   end 
				)

			--and tapecode=@pRawMaterialBarcode 
			--and (ModelName not like '%-L%' 
			--	or (ModelName like '%-L%' 
			--		and @ModelSize='1030' 
			--		and tapecode ='GBTPPL-007'
			--		)
			--)
			
			if(@count=0)  begin
					set @err = N'KhÃ´ng tá»“n táº¡i thiáº¿t láº­p PiTape cá»§a LotNo: ' +@pBarcode+  N' vá»›i mÃ£ Tape: ' + @pRawMaterialBarcode + @ctape;
			end		
			
			--select *
			--from STB_ModelBasicInfo  with(nolock) 
			--where ModelCode=(select MaterialCode from STB_SetInfo with(nolock) where barcode=@pBarcode) 
			--and @ModelSize='1030' 
			--and ModelName like '%-L%' 


			if(@err <> '' /*and @count>0*/)begin		
	     		set @err = @pBarcode+'_'+substring(@RawMaterialBarcode,1,20)+'...'  +' : '+@err +   isnull(@ctape,'.') 
					raiserror (@err ,16,1) ;
					return;
					set @err=@err; 
			end		

   end



















		-- check Giáº¥y
if( UPPER(isnull(@pProductGroupCode,'')) in ( 'Separator' )  or lower(@pProductGroupCode) like '%separato%'  ) begin	


     select @pRawMaterialBarcode = substring(ltrim(rtrim(@pRawMaterialBarcode)),1,10)
	 DECLARE @MateriaCodeGroupSEPARATOR NVARCHAR(50)
	SELECT @MateriaCodeGroupSEPARATOR=PG.ProductGroupCode from STB_MaterialMaster MM 
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK) ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK) ON MM.ProductGroupCode = PG.ProductGroupCode
	where MM.MaterialCode=@pRawMaterialBarcode
	if((isnull(@MateriaCodeGroupSEPARATOR,'')) not in ( 'SEPARATOR' ))
	begin
	   set @err = N'MÃ£ nÃ y khÃ´ng pháº£i lÃ  giáº¥y cá»§a LotNo: ' +@pBarcode+  N'vá»›i mÃ£ nguyÃªn váº­t liá»‡u: '  + @pRawMaterialBarcode ;
	   raiserror (@err ,16,1) ;
	   return;
	end

	
		;with separatotable as (
		
		 select 'GBNKSP-060' as separatocode, 'HY-CAP VEC2R7506QG (1840),' as models  union all
		-- select 'GBNKSP-054' as separatocode, 'HY-CAP VEC2R7105QG-N (0813),' as models  union all
		select 'GBNKSP-057' as separatocode, 'VEL08203R8306G (0820),' as models  union all
		select 'GBNKSP-062' AS separatocode,'WEC3R0156QD (1035)' as models union all  --Mr.Trieu Update ngÃ y 2025-09-06
		select 'GBNKSP-059' as separatocode,'VET10252R7106G (1025)' as models union all
		 select materialcode , semiProductname
			  from stb_vvt_materialbo with(nolock)
			  where part like '%separato%' and size is not null and semiProductname not like '%Element%'
					  union all 
			  select distinct ChildMaterialCode,mbi.modelname--,
				--RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) 

				from STB_BomDetail bd with(nolock) 
				join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
				where   modelname like '%HY-CAP%' or  modelname like 'VEL%'
		)
			select  @count=count(*) 
			from STB_ModelBasicInfo mbi  with(nolock) 
			join separatotable on models like '%'+@ModelSize +'%' 
			and (models like '%' + mbi.ModelName + '%' or models not like '%HY-CAP%')
			where ModelCode=@MaterialCode 
			and separatocode =  @pRawMaterialBarcode 
			--select top 1 * from STB_ModelBasicInfo where ModelCode='ECVT27-399'
			
			if(@count=0 --and (@MaterialCode='ECVT27-369' or @ModelSize='1859')
			)  begin
					set @err = N'KhÃ´ng tá»“n táº¡i thiáº¿t láº­p Giáº¥y NgÄƒn cá»§a LotNo: ' +@pBarcode+  N' vá»›i mÃ£ Giáº¥y: ' + @pRawMaterialBarcode ;
			end
				

			if(@err <> '' )begin		
				set  @err = @pBarcode+'_'+substring(@RawMaterialBarcode,1,20)+'...' +' : '+ @err
					raiserror (@err ,16,1) ;
					return;
					set @err=@err;        
			end		

   end


 

















   
if( UPPER(isnull(@pProductGroupCode,'')) in ( 'RubberPad' )  /*or lower(@pProductGroupCode) like '%rubberpad%' */ ) begin	
   

     select @pRawMaterialBarcode = substring(ltrim(rtrim(@pRawMaterialBarcode)),1,10)
	  DECLARE @MateriaCodeGroupRubberPad NVARCHAR(50)
	SELECT @MateriaCodeGroupRubberPad=PG.ProductGroupCode from STB_MaterialMaster MM 
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK) ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK) ON MM.ProductGroupCode = PG.ProductGroupCode
	where MM.MaterialCode=@pRawMaterialBarcode
	if((UPPER(isnull(@MateriaCodeGroupRubberPad,'')) not in ( 'RUBBER-PAD' )))
	begin
	   set @err = N'MÃ£ nÃ y khÃ´ng pháº£i lÃ  cao su cá»§a LotNo: ' +@pBarcode+  N'vá»›i mÃ£ nguyÃªn váº­t liá»‡u: '  + @pRawMaterialBarcode ;
	   raiserror (@err ,16,1) ;
	   return;
	end
		--select * from STB_SetInfo
						--where Barcode = SUBSTRING('VVPR2311601E15-063',1,14)
		;with rubbertable as (
		
		 select 'GBSN00-003' as rubbercode, 'HY-CAP VEC2R7506QG (1840),' as models  union all
		 select 'GBNKSP-057' as rubbercode, 'HY-CAP WEC3R0105QG (0813),' as models  union all -- 2025-05-31
		 select 'GBNKSP-057' as rubbercode, 'HY-CAP WEC3R0505QD (0825),' as models  union all
		 select 'GBSN00-004' as rubbercode, 'WEC3R0106QG (1030)' as models union all
	     select 'GBSN00-004' as rubbercode, 'HY-CAP VET10252R7106G (1025)' as models
				 union all
		-- select 'GBSN00-005' as separatocode, 'HY-CAP VEC2R7105QG-N (0813),' as models  union all
		 select materialcode , semiProductname
			  from stb_vvt_materialbo with(nolock)
			  where part like '%rubber%' and size is not null and semiProductname not like '%Element%'
			  			  union all 
			  select distinct ChildMaterialCode,mbi.modelname--,
				--RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) 
				from STB_BomDetail bd with(nolock) 
				join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
				where   modelname like '%HY-CAP%' or  modelname like 'VEL%'
		)
			select  @count=count(*) 
			from STB_ModelBasicInfo mbi  with(nolock) 
			join rubbertable on models like '%'+@ModelSize +'%' 
			and (models like '%' + mbi.ModelName + '%' or models not like '%HY-CAP%')
			where ModelCode=@MaterialCode 
			and rubbercode =  @pRawMaterialBarcode 
			

			if(@count=0  --and (@MaterialCode='ECVT27-369' or @ModelSize='1859'			)
			)  begin
					set @err = N'KhÃ´ng tá»“n táº¡i thiáº¿t láº­p CAO SU cá»§a LotNo: ' +@pBarcode+  N' vá»›i mÃ£ CAO SU: ' + @pRawMaterialBarcode ;
			end
				

			if(@err <> '' )begin		
			    set @err = @pBarcode +'_'+substring(@RawMaterialBarcode,1,20)+'...' +' : '+ @err;
					raiserror (@err ,16,1) ;
					return;
					set @err=@err;       
			end		

   end
















   --Cháº·n vá» nhÃ´m
if( UPPER(isnull(@pProductGroupCode,'')) in ( 'Case' )  /*or lower(@pProductGroupCode) like '%case%' */ ) begin	

 

     select @pRawMaterialBarcode = substring(ltrim(rtrim(@pRawMaterialBarcode)),1,10)
	 --raiserror(@pRawMaterialBarcode,16,1)
	 -- Mr.Triá»u chuáº©n bá»‹ audit cháº·n khÃ´ng cho OP nháº­p nháº§m vá» nhÃ´m 	
	DECLARE @MateriaCodeGroupCASE NVARCHAR(50)
	SELECT @MateriaCodeGroupCASE=PG.ProductGroupCode from STB_MaterialMaster MM 
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK) ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK) ON MM.ProductGroupCode = PG.ProductGroupCode
	where MM.MaterialCode=@pRawMaterialBarcode
	if((isnull(@MateriaCodeGroupCASE,'')) not in ( 'CASE', 'AL-CASE' )) -- Mr.Manh add AL-CASE
	begin
	   set @err = N'MÃ£ nÃ y khÃ´ng pháº£i lÃ  vá» nhÃ´m cá»§a LotNo: ' +@pBarcode+  N'vá»›i mÃ£ nguyÃªn váº­t liá»‡u: '  + @pRawMaterialBarcode ;
	   raiserror (@err ,16,1) ;
	   return;
	end

		;with casetable1 as ( 				
					
			  select materialcode as casecode, replace(replace(replace(replace(replace(replace(semiProductname,'HY-CAP ',''),'HY-CAP',''),'-C',''),'-M',''),'MSP',''),'(CY)','') as models, replace(size,'-L','') as size 
			  from stb_vvt_materialbo with(nolock)
			  where part like '%case%' and size is not null and semiProductname not like '%Element%'
			  			  union all 
						    select 'GBAKAC-048' as casecode , 'VEB2R8126HC' as models,'1030' as size  union all
							  select 'GBLYAC-004' as casecode , 'VEC3R0227QG' as models,'2570' as size  union all 
							  select 'GBRLAC-004' as casecode , 'WEC2R7106QG' as models,'1030' as size  union all		-- add 2025-05-29
							  select 'GBRLAC-004' as casecode , 'WEC3R0106QG' as models,'1030' as size  union all		-- add 2025-05-29
							  select 'GBRLAC-004' as casecode , 'VEC3R0106QG' as models,'1030' as size  union all		-- add 2025-05-31
							  select 'GBRLAC-004' as casecode , 'VEC2R7106QG' as models,'1030' as size  union all		-- add 2025-06-05
							  select 'GBRLAC-004' as casecode , 'VEC2R7106ZG' as models,'1030' as size  union all		-- add 2025-06-11
							  select 'GBRLAC-004' as casecode , 'WEC3R0126HC' as models,'1030' as size  union all		-- add 2025-06-13
							  select 'GBRLAC-007' as casecode , 'VEC3R0705QG' as models,'1020' as size  union all		-- add 2025-06-20
							  select 'GBRLAC-007' as casecode , 'WEC3R0505QG' as models,'1020' as size  union all		-- add 2025-06-27
							  select 'GBAKAC-V03' as Sleeving , 'VEC3R0107QG-L'as model,'2245' as size  union all 
							  select 'GBRLAC-006' as Sleeving,  'WEC3R0156QG' as model,'1325' as size union all  -- add 2025-06-28
							  select 'GBRLAC-007' as Sleeving,  'VEC2R7505QG' as model,'1020' as size union all  -- add 2025-06-29
							  select 'GBRLAC-007' as Sleeving,  'WEC3R0705QG' as model,'1020' as size union all  -- add 2025-07-09
							  select 'GBRLAC-006' as Sleeving,  'WEC3R0186QC' as model,'1325' as size union all  -- add 2025-07-11
							  select 'GBLYAC-002' as Sleeving,  'WEC3R0106QA' as model,'1025' as size union all  -- add 2025-07-21
							  select 'GBRLAC-012' as Sleeving,  'VEC3R0606QG' as model,'1840' as size union all  -- add 2025-08-07
							  select 'GBLYAC-002' as Sleeving,  'VEC2R7106QA' as model,'1025' as size union all  -- add 2025-08-08
							  select 'GBRLAC-012' as Sleeving,  'WEC3R0506QG' as model,'1840' as size union all  -- add 2025-08-09
							  select 'GBRLAC-012' as Sleeving,  'VEC2R7506QG' as model,'1840' as size union all  -- add 2025-08-09
							  select 'GBRLAC-009' as Sleeving,  'WEC3R0256QG' as model,'1625' as size union all  -- add 2025-08-27
							  select 'GBRLAC-009' as Sleeving,  'WEC2R7256QG' as model,'1625' as size union all  -- add 2025-08-30
							  select 'GBAKAC-060' as Sleeving,  'VEL08203R8306G (0820)' as model,'0820' as size union all  -- add 2025-09-03
							  select 'GBRLAC-012' as Sleeving,  'WEC3R0606QG' as model,'1840' as size union all  -- add 2025-09-18
							  select 'GBLYAC-002' as Sleeving, 'VET10252R7106G' as model,'0825' as size union all
							  select 'GBRLAC-008' as Sleeving, 'WEC3R0106QD' as model,'1320' as size union all -- add 2025-10-06
							  select 'GBRLAC-006' as Sleeving, 'VEL13253R8157G' as model,'1325' as size union all  -- add 2025-11-03
							  select 'GBRLAC-007' as Sleeving, 'VEC3R0505QG' as model,'1020' as size union all	-- add 2025-11-03
							  select 'GBLYAC-006' as Sleeving, 'VEL10403R8157D' as model,'1040' as size union all	-- add 2025-11
							  select 'GBRLAC-011' as casecode, 'WEC2R7346QA' as model,'1830' as size union all	-- add 2025-11
							  select 'GBDYAC-006' as casecode, 'VEC3R0727QG' as model,'35105' as size union all	-- add 2026-03-30
                                select 'GBRLAC-007' as casecode, 'VEC2R7705QG' as models, '1020' as size  union all
								select 'GBDYAC-001' as casecode, 'WEC3R0335QG' as models, '0820' as size  union all

			  select distinct ChildMaterialCode,replace(replace(replace(replace(replace(replace(mbi.modelname,'HY-CAP ',''),'HY-CAP',''),'-C',''),'-M',''),'MSP',''),'(CY)',''),
				--RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) 
				RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
				from STB_BomDetail bd with(nolock) 
				join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
				where   modelname like '%HY-CAP%' or  modelname like 'VEL%'
			)
			 ,casetable as (
			  select casecode, --replace(replace(replace(replace(models,'('+size+')',''),'(',''),')',''),' ','') 
			  replace(replace(models,' ',''),'('+size+')','') models, size 
			  --replace(models,'('+size+')','') models, size 
			  from casetable1
			 where len(size)=4 or len(size)=5
			)	
			select  @count=count(*) 
			from STB_ModelBasicInfo mbi  with(nolock) 
			join casetable on size like '%'+@ModelSize +'%' 
			and (models like '%' + mbi.ModelName + '%' or mbi.ModelName like '%' + models + '%')
			where ModelCode=@MaterialCode 
			and casecode =  @pRawMaterialBarcode 

			if(@pBarcode='VVPT013R815708' and @pRawMaterialBarcode='GBRLAC-006')
			begin
			  set @err='';
	           set @count=1;

			end

			-- BEGIN UPDATE 2025-10-14 Mr.Manh update for 1030 Low ESR --- following Ms.Hoa's request
			if (@MaterialCode = 'ECVT30-367' and @pRawMaterialBarcode <> 'GBRLAC-004') 
			begin
	           set @count=0;
			end
			-- END UPDATE


			if(@count=0  --and (@MaterialCode='ECVT27-369' or @ModelSize='1859') 
			)  begin
					set @err = N'KhÃ´ng tá»“n táº¡i thiáº¿t láº­p Vá» NhÃ´m cá»§a LotNo: ' +@pBarcode+  N' vá»›i mÃ£ Vá» NhÃ´m: ' + @pRawMaterialBarcode ;
			end
				

			if(@err <> '' )begin		
			    set @err = @pBarcode +'_'+substring(@RawMaterialBarcode,1,20)+'...' +' : '+@err +   isnull(@ccase,'.') 
					raiserror (@err ,16,1) ;
					return;
					set @err=@err;        
			end		

   end

-------------------------------------------------------------------------------------------------------------------------------------------------------

   -- Mr.Duy thiáº¿t láº­p Ä‘iá»u kiá»‡n cho nhÃ  mÃ¡y hÃ  nam
   	-- Danh sÃ¡ch biáº¿n
		DECLARE @pRawMaterialBarcode1 NVARCHAR(200) =  @pRawMaterialBarcode  --barcode cá»§a sáº£n xuáº¥t
		 , @SizeCode                 VARCHAR(20)   -- láº¥y sizecode Ä‘á»ƒ so sÃ¡nh ra tÃªn tiáº¿ng viá»‡t vá»›i cÃ¡c mÃ£ nguyÃªn liá»‡u lá»—i
		 , @NameVVT					nvarchar(200)
		DECLARE @ProductGroupCodeHNCheck NVARCHAR(200) =  @pProductGroupCode -- nhÃ³m mÃ£ nguyÃªn liá»‡u
		DECLARE @LotMaterialBarcodeHNCheck NVARCHAR(200) =  @LotMaterialBarcode	--barcode nguyÃªn liá»‡u nháº­p vÃ o mÃ n hÃ¬nh
		DECLARE @countcheckHN int =  0
	--end


     --Cháº·n gáº§n nhÆ° táº¥t cáº£ nguyÃªn váº­t liá»‡u Ä‘áº§u vÃ o trá»« dung dá»‹ch,Tapping do 2 cÃ¡i cÃ³ @pProductGroupCode giá»‘ng nhau
	if( UPPER(isnull(@pProductGroupCode,'')) in ( 'ANODE-FOIL-1','CATHODE-FOIL-1','CON-PAPER-1','HEATING-TAPE-1' ,'RUBBER-1','AL-CASE-1','BASE-PLATE-1','CARRIER-TAPE-1','COVER-TAPE-1','REEL-1','INNER-BOX-1','OUTER-BOX-1')  ) 
	begin	
		
		--láº¥y ra size hÃ ng Ä‘Æ°á»£c config á»Ÿ A410
		  SELECT @SizeCode = CASE	
								WHEN MBIExtText07 = 'CHIP_HN' THEN 'CHIP_HN'
								WHEN MBIExtText07 = 'NORMAL_HN' THEN 'NORMAL_HN'
								WHEN MBIExtText07 = 'TAPPING_HN' THEN 'TAPPING_HN'
										ELSE NULL END
	  FROM STB_ModelBasicInfo with(nolock) 
	 WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo with(nolock)  WHERE Barcode  =@pBarcode )

	 -- Láº¥y ra tÃªn tiáº¿ng viá»‡t
	 select @NameVVT=ProductGroupName_VVT from STB_RawMaterialBaiscInfo where SizeCode = @SizeCode and ProductGroupCode = @pProductGroupCode


		select @pRawMaterialBarcode = ltrim(rtrim(@mmmaterialcode)) --mÃ£ code cá»§a nguyÃªn liá»‡u
			--declare @ModelSize1 varchar(10)=@ModelSize
	 		--raiserror(@pProductGroupCode,16,1)
			--return;
		
			;with getListMaterialBom as ( 				

			 -- Láº¥y danh sÃ¡ch cÃ¡c nguyÃªn liá»‡u Ä‘Æ°á»£c cáº¥u hÃ¬nh trong bom chá»‰ láº¥y á»Ÿ nhÃ  mÃ¡y hÃ  nam theo tÃªn Polymer.
			  select distinct ChildMaterialCode,bd.materialcode,replace(mbi.modelname,'Polymer ','') as models,
				RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) as size
				from STB_BomDetail bd with(nolock) 
				join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
				where   modelname like '%Polymer%' or modelname like '%Hybrid%'
		
			)
			 ,getSizeCode as (
			  select ChildMaterialCode, materialcode,
			  --replace(replace(models,' ',''),'('+size+')','') models, size 
			  replace(models,'('+size+')','') models, size 
			  from getListMaterialBom
			 where len(size)=3 or len(size)=4 or len(size)=5 --chá»‰ láº¥y 4 vÃ  5 kÃ­ tá»±
			),
			checkInfomationBarcode as ( -- TÃ¬m kiáº¿m trong thÃ´ng tin cá»§a barcode nháº­p vÃ o
					select si.barcode,mm.MaterialCode,MaterialName,N'2.ChÆ°a thiáº¿t láº­p mÃ£ code '+@NameVVT+ N'cho sáº£n pháº©m nÃ y: '+mm.MaterialCode+' -> '+MaterialName as infoe from 
					STB_SetInfo si with(nolock) 
					join  STB_MaterialMaster mm with(nolock) on mm.materialcode = si.materialcode					
					where  
						barcode=isnull(@pBarcode,'') 
					),
				checkConfigBOMBarode as ( -- láº¥y ra cÃ¡c thiáº¿t láº­p cÃ³ sáºµn vá»›i mÃ£ hÃ ng vÃ  size
					select barcode,cibc.MaterialCode,MaterialName,gsc.models,ChildMaterialCode,N'3.'+@NameVVT+ N' Ä‘Æ°á»£c thiáº¿t láº­p, khÃ¡c vá»›i mÃ£ QRCODE nháº­p vÃ o B597: '+@pRawMaterialBarcode1 as infoe 
					from checkInfomationBarcode cibc
					join   getSizeCode gsc on  cibc.MaterialCode = gsc.MaterialCode 
					
					),
				checkConfigBOMBarode1 as ( -- láº¥y ra cÃ¡c thiáº¿t láº­p cÃ³ sáºµn vá»›i mÃ£ hÃ ng vÃ  size
					select barcode,cibc.MaterialCode,cibc.MaterialName,gsc.models,ChildMaterialCode,mm2.ProductGroupCode
					,N'3.'+@NameVVT+N' Ä‘Æ°á»£c thiáº¿t láº­p, khÃ¡c vá»›i mÃ£ QRCODE nháº­p vÃ o B597: '+@pRawMaterialBarcode1+ CHAR(10) +
					+N'MÃ£ Ä‘Ãºng sáº½ lÃ  :'+gsc.ChildMaterialCode	
					 as infoe
					
					from checkInfomationBarcode cibc
					join   getSizeCode gsc on  cibc.MaterialCode = gsc.MaterialCode 
					join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = gsc.ChildMaterialCode	
					where mm2.ProductGroupCode = UPPER(isnull( SUBSTRING(@pProductGroupCode, 1, LEN(@pProductGroupCode) - 2),'')) ),

				checkQRProduct as ( -- kiá»ƒm tra xem cÃ¡c mÃ£ thiáº¿t láº­p trong bom vÃ  nháº­p vÃ o cÃ³ khá»›p nhau khÃ´ng náº¿u cÃ³ thÃ¬ sáº½ cÃ³ OK Ä‘á»ƒ k bÃ¡o lá»—i
					select '4.OK' as infoe from checkConfigBOMBarode  ccgbb					
					join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = ccgbb.ChildMaterialCode			 
				   and ccgbb.ChildMaterialCode = @pRawMaterialBarcode --isnull('GBCP00-001','') GCMDPT-277
				   and  UPPER(isnull(mm2.ProductGroupCode,'')) = UPPER(isnull( SUBSTRING(@pProductGroupCode, 1, LEN(@pProductGroupCode) - 2),'')) 
				   )
				   ,
				collectErr as (
				   select infoe from checkInfomationBarcode
				   union all
				   select infoe from checkConfigBOMBarode
				   union all
				      select infoe from checkConfigBOMBarode1
				   union all
				   select infoe from checkQRProduct
				   )
				  select @err = max(infoe) from collectErr -- láº¥y loáº¡i lá»—i cao nháº¥t

		-- Kiá»ƒm tra xem mÃ£ nguyÃªn liá»‡u tÆ°Æ¡ng á»©ng vá»›i mÃ£ nguyÃªn liá»‡u bom hay khÃ´ng

		if(@err <> '4.OK' or @err not like '%.OK'  )begin
						
					set @err = @pBarcode +'_'+substring(@RawMaterialBarcode,1,20)+'...' + CHAR(10) +@err 
						raiserror (@err ,16,1) ;
						return;
						set @err=@err;        
				end		

	end

	--Cháº·n nguyÃªn váº­t liá»‡u vá»›i tancha cá»§a hÃ  nam
	if( UPPER(isnull(@pProductGroupCode,'')) in ('LEAD-WIRE-1','LEAD-WIRE-2' )  ) 
	begin	
		--láº¥y ra size hÃ ng Ä‘Æ°á»£c config á»Ÿ A410
		  SELECT @SizeCode = CASE	
								WHEN MBIExtText07 = 'CHIP_HN' THEN 'CHIP_HN'
								WHEN MBIExtText07 = 'NORMAL_HN' THEN 'NORMAL_HN'
								WHEN MBIExtText07 = 'TAPPING_HN' THEN 'TAPPING_HN'
										ELSE NULL END
							  FROM STB_ModelBasicInfo with(nolock) 
							 WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo with(nolock)  WHERE Barcode  =@pBarcode )

	 -- Láº¥y ra tÃªn tiáº¿ng viá»‡t
	 select @NameVVT=ProductGroupName_VVT from STB_RawMaterialBaiscInfo where SizeCode = @SizeCode and ProductGroupCode = @pProductGroupCode


		select @pRawMaterialBarcode = ltrim(rtrim(@mmmaterialcode)) --mÃ£ code cá»§a nguyÃªn liá»‡u
			--declare @ModelSize1 varchar(10)=@ModelSize
	 		--raiserror(@pProductGroupCode,16,1)
			--return;

			;with getListMaterialBom as ( 				

			 -- Láº¥y danh sÃ¡ch cÃ¡c nguyÃªn liá»‡u Ä‘Æ°á»£c cáº¥u hÃ¬nh trong bom chá»‰ láº¥y á»Ÿ nhÃ  mÃ¡y hÃ  nam theo tÃªn Polymer.
			  select distinct ChildMaterialCode,bd.materialcode,replace(mbi.modelname,'Polymer ','') as models,
				RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) as size
				from STB_BomDetail bd with(nolock) 
				join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
				where  modelname like '%Polymer%' or modelname like '%Hybrid%'
			
			)
			 ,getSizeCode as (
			  select ChildMaterialCode, materialcode,
			  replace(replace(models,' ',''),'('+size+')','') models, size 
			  --replace(models,'('+size+')','') models, size 
			  from getListMaterialBom
			 where len(size)=3 or len(size)=4 or len(size)=5 --chá»‰ láº¥y 4 vÃ  5 kÃ­ tá»±
			),
			checkInfomationBarcode as ( -- TÃ¬m kiáº¿m trong thÃ´ng tin cá»§a barcode nháº­p vÃ o
					select si.barcode,mm.MaterialCode,MaterialName,N'2.ChÆ°a thiáº¿t láº­p mÃ£ code '+@NameVVT+ N'cho sáº£n pháº©m nÃ y: '+mm.MaterialCode+' -> '+MaterialName as infoe from 
					STB_SetInfo si with(nolock) 
					join  STB_MaterialMaster mm with(nolock) on mm.materialcode = si.materialcode					
					where  
						barcode=isnull(@pBarcode,'') 
					),
				checkConfigBOMBarode as ( -- láº¥y ra cÃ¡c thiáº¿t láº­p cÃ³ sáºµn vá»›i mÃ£ hÃ ng vÃ  size
					select barcode,cibc.MaterialCode,MaterialName,gsc.models,ChildMaterialCode,N'3.'+@NameVVT+ N' Ä‘Æ°á»£c thiáº¿t láº­p, khÃ¡c vá»›i mÃ£ QRCODE nháº­p vÃ o B597: '+@pRawMaterialBarcode1 as infoe 
					from checkInfomationBarcode cibc
					join   getSizeCode gsc on  cibc.MaterialCode = gsc.MaterialCode 
					
					),
				checkConfigBOMBarode1 as ( -- láº¥y ra cÃ¡c thiáº¿t láº­p cÃ³ sáºµn vá»›i mÃ£ hÃ ng vÃ  size
					select barcode,cibc.MaterialCode,cibc.MaterialName,gsc.models,ChildMaterialCode,mm2.ProductGroupCode
					,N'3.'+@NameVVT+N' Ä‘Æ°á»£c thiáº¿t láº­p, khÃ¡c vá»›i mÃ£ QRCODE nháº­p vÃ o B597: '+@pRawMaterialBarcode1+ CHAR(10) +
					+N'MÃ£ Ä‘Ãºng sáº½ lÃ  :'+gsc.ChildMaterialCode	
					 as infoe
					
					from checkInfomationBarcode cibc
					join   getSizeCode gsc on  cibc.MaterialCode = gsc.MaterialCode 
					join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = gsc.ChildMaterialCode	
					where mm2.ProductGroupCode = UPPER(isnull( SUBSTRING(@pProductGroupCode, 1, LEN(@pProductGroupCode) - 2),'')) 
					),
				checkamduong as( -- kiá»ƒm tra xem Ä‘Ãºng loáº¡i tancha Ã¢m dÆ°Æ¡ng khÃ´ng dá»±a vÃ o tÃªn nvl
					select barcode,cibc.MaterialCode,cibc.MaterialName,N'4. KhÃ´ng Ä‘Ãºng loáº¡i Tancha (DÆ°Æ¡ng)(PT) hoáº·c (Ã‚m)(NT): '+@pProductGroupCode as infoe 			
					from checkConfigBOMBarode1 cibc
					join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = cibc.ChildMaterialCode				 
					   and mm2.MaterialName like case when  UPPER(isnull(@pProductGroupCode,''))='LEAD-WIRE-1' then '%NT%' else '%PT%' end  
					   and  UPPER(isnull(mm2.ProductGroupCode,'')) like '%LEAD-WIRE%'				
					),
				checkQRProduct as ( -- kiá»ƒm tra xem cÃ¡c mÃ£ thiáº¿t láº­p trong bom vÃ  nháº­p vÃ o cÃ³ khá»›p nhau khÃ´ng náº¿u cÃ³ thÃ¬ sáº½ cÃ³ OK Ä‘á»ƒ k bÃ¡o lá»—i
					select '4.OK' as infoe from checkConfigBOMBarode  ccgbb					
					join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = ccgbb.ChildMaterialCode			 
				   and ccgbb.ChildMaterialCode = @pRawMaterialBarcode --isnull('GBCP00-001','') GCMDPT-277
				   and  UPPER(isnull(mm2.ProductGroupCode,'')) = UPPER(isnull( SUBSTRING(@pProductGroupCode, 1, LEN(@pProductGroupCode) - 2),'')) 
				      and mm2.MaterialName like case when  UPPER(isnull(@pProductGroupCode,''))='LEAD-WIRE-1' then '%NT%' else '%PT%' end  
					   and  UPPER(isnull(mm2.ProductGroupCode,'')) like '%LEAD-WIRE%'	
				   )
				   ,
				collectErr as (
				   select infoe from checkInfomationBarcode
				   union all
				   select infoe from checkConfigBOMBarode
				   union all
				      select infoe from checkConfigBOMBarode1
				   union all
				   select infoe from checkQRProduct
				   )
				  select @err = max(infoe) from collectErr -- láº¥y loáº¡i lá»—i cao nháº¥t

		-- Kiá»ƒm tra xem mÃ£ nguyÃªn liá»‡u tÆ°Æ¡ng á»©ng vá»›i mÃ£ nguyÃªn liá»‡u bom hay khÃ´ng

		if(@err <> '4.OK' or @err not like '%.OK'  )begin
						
					set @err = @pBarcode +'_'+substring(@RawMaterialBarcode,1,20)+'...' + CHAR(10) +@err 
						raiserror (@err ,16,1) ;
						return;
						set @err=@err;        
				end		

	end --end cháº·n tancha


	--Cháº·n nguyÃªn váº­t liá»‡u vá»›i chemical
	if( UPPER(isnull(@pProductGroupCode,'')) in ('CHEMICAL-1','CHEMICAL-2','CHEMICAL-3','CHEMICAL-4' )  ) 
	begin	
		
		
		--láº¥y ra size hÃ ng Ä‘Æ°á»£c config á»Ÿ A410
		  SELECT @SizeCode = CASE	
								WHEN MBIExtText07 = 'CHIP_HN' THEN 'CHIP_HN'
								WHEN MBIExtText07 = 'NORMAL_HN' THEN 'NORMAL_HN'
								WHEN MBIExtText07 = 'TAPPING_HN' THEN 'TAPPING_HN'
										ELSE NULL END
				FROM STB_ModelBasicInfo with(nolock) 
				WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo with(nolock)  WHERE Barcode  =@pBarcode )

	 -- Láº¥y ra tÃªn tiáº¿ng viá»‡t
	 select @NameVVT=ProductGroupName_VVT from STB_RawMaterialBaiscInfo where SizeCode = @SizeCode and ProductGroupCode = @pProductGroupCode


		select @pRawMaterialBarcode = ltrim(rtrim(@mmmaterialcode)) --mÃ£ code cá»§a nguyÃªn liá»‡u
			--declare @ModelSize11 varchar(10)=@pProductGroupCode +'---'+@MaterialCode
	 		--raiserror(@pRawMaterialBarcode,16,1)
			--return;

		
			;with getListMaterialBom as ( 				

			 -- Láº¥y danh sÃ¡ch cÃ¡c nguyÃªn liá»‡u Ä‘Æ°á»£c cáº¥u hÃ¬nh trong bom chá»‰ láº¥y á»Ÿ nhÃ  mÃ¡y hÃ  nam theo tÃªn Polymer.
			  select distinct ChildMaterialCode,bd.materialcode,replace(mbi.modelname,'Polymer ','') as models,
				RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) as size
				from STB_BomDetail bd with(nolock) 
				join STB_ModelBasicInfo mbi  with(nolock) on bd.MaterialCode = mbi.ModelCode
				where  modelname like '%Polymer%' or modelname like '%Hybrid%'
			
			)
			 ,getSizeCode as (
			  select ChildMaterialCode, materialcode,
			  replace(replace(models,' ',''),'('+size+')','') models, size 
			  --replace(models,'('+size+')','') models, size 
			  from getListMaterialBom
			 where len(size)=3 or len(size)=4 or len(size)=5 --chá»‰ láº¥y 4 vÃ  5 kÃ­ tá»±
			),
			
			checkInfomationBarcode as ( -- TÃ¬m kiáº¿m trong thÃ´ng tin cá»§a barcode nháº­p vÃ o
					select si.barcode,mm.MaterialCode,MaterialName,N'1.ChÆ°a thiáº¿t láº­p mÃ£ code '+@NameVVT+ N'cho sáº£n pháº©m nÃ y: '+mm.MaterialCode+' -> '+MaterialName as infoe from 
					STB_SetInfo si with(nolock) 
					join  STB_MaterialMaster mm with(nolock) on mm.materialcode = si.materialcode					
					where  
						barcode=isnull(@pBarcode,'') 
					),
				checkConfigBOMBarode as ( -- láº¥y ra cÃ¡c thiáº¿t láº­p cÃ³ sáºµn vá»›i mÃ£ hÃ ng vÃ  size
					select barcode,cibc.MaterialCode,MaterialName,gsc.models,ChildMaterialCode,N'2.'+@NameVVT+ N' Ä‘Æ°á»£c thiáº¿t láº­p, khÃ¡c vá»›i mÃ£ QRCODE nháº­p vÃ o B597: '+@pRawMaterialBarcode1 as infoe 
					from checkInfomationBarcode cibc
					join   getSizeCode gsc on  cibc.MaterialCode = gsc.MaterialCode 
					
					),
				checkConfigBOMBarode1 as ( -- láº¥y ra cÃ¡c thiáº¿t láº­p cÃ³ sáºµn vá»›i mÃ£ hÃ ng vÃ  size
				select barcode,cibc.MaterialCode,cibc.MaterialName,gsc.models,ChildMaterialCode,mm2.ProductGroupCode
					,N'3.'+@NameVVT+N' Ä‘Æ°á»£c thiáº¿t láº­p, khÃ¡c vá»›i mÃ£ QRCODE nháº­p vÃ o B597: '+ CHAR(10) 
					+N'MÃ£ Ä‘Ãºng sáº½ lÃ  :'+@ChildMaterialCode	
					 as infoe
					
					from checkInfomationBarcode cibc
					join   getSizeCode gsc on  cibc.MaterialCode = gsc.MaterialCode 
					join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = gsc.ChildMaterialCode
						
					where mm2.ProductGroupCode = UPPER(isnull( SUBSTRING(@pProductGroupCode, 1, LEN(@pProductGroupCode) - 2),'')) 
					 and @ChildMaterialCode <> @pRawMaterialBarcode
					),

			/*	getInputMaterial as ( -- kiá»ƒm tra xem mÃ£ nguyÃªn liá»‡u Ä‘Ã£ nháº­p lÃªn há»‡ thá»‘ng chÆ°a náº¿u nháº­p rá»“i sáº½ bÃ¡o lá»—i
				
					select materialcode,N'MÃ£ nguyÃªn liá»‡u nÃ y Ä‘Ã£ nháº­p rá»“i ! ' as infoe from stb_materialdoclotinfo where 
					materialcode  in (
					select md.materialcode  from STB_RawMaterialInputHist rm
					inner join stb_materialdoclotinfo  md on rm.LotMaterialCode = md.lotid
					 where barcode=@pBarcode and ProductGroupCode like '%CHEMICAL%'
					 )
					 and  lotid=@LotMaterialBarcode

				)
				,	 */
		
				checkQRProduct as ( -- kiá»ƒm tra xem cÃ¡c mÃ£ thiáº¿t láº­p trong bom vÃ  nháº­p vÃ o cÃ³ khá»›p nhau khÃ´ng náº¿u cÃ³ thÃ¬ sáº½ cÃ³ OK.
					/* -- láº§n lÃ m 1 Ä‘á»ƒ check dá»¯ liá»‡u Ä‘Ãºng hay k
					select '4.OK' as infoe  from checkConfigBOMBarode1  cibc1
					join stb_materialdoclotinfo mdli on cibc1.ChildMaterialCode = mdli.materialcode where 
					mdli.materialcode not in (
					select md.materialcode  from STB_RawMaterialInputHist rm
					inner join stb_materialdoclotinfo  md on rm.LotMaterialCode = md.lotid
					 where barcode=@pBarcode and ProductGroupCode like '%CHEMICAL%'
					 )
					 and  lotid=@LotMaterialBarcode
					 */
				 select '4.OK' as infoe from checkConfigBOMBarode  ccgbb					
					join  STB_MaterialMaster mm2 with(nolock) on mm2.MaterialCode = ccgbb.ChildMaterialCode			 
				   and @ChildMaterialCode = @pRawMaterialBarcode --isnull('GBCP00-001','') GCMDPT-277
				   and  UPPER(isnull(mm2.ProductGroupCode,'')) = UPPER(isnull( SUBSTRING(@pProductGroupCode, 1, LEN(@pProductGroupCode) - 2),'')) 
				   	and @ChildMaterialCode = @pRawMaterialBarcode
				   )
				   ,
				collectErr as (
				   select infoe from checkInfomationBarcode
				   union all
				   select infoe from checkConfigBOMBarode
				   union all
				      select infoe from checkConfigBOMBarode1
			
				   union all
				   select infoe from checkQRProduct
				   )
				  select @err = max(infoe) from collectErr -- láº¥y loáº¡i lá»—i cao nháº¥t

				  -- usp_Vietnam_RawMaterialInputHist_uid  '','','','VE241231-001','LEAD-WIRE-1','ML20250102000023','','',''
			--print (@ModelSize +' '+ @MaterialCode+'_'+ @pRawMaterialBarcode  +'_____________'+@mmmaterialcode +'__'+@pProductGroupCode)

		-- Kiá»ƒm tra xem mÃ£ nguyÃªn liá»‡u tÆ°Æ¡ng á»©ng vá»›i mÃ£ nguyÃªn liá»‡u bom hay khÃ´ng

				if(@err <> '4.OK' or @err not like '%.OK'  )begin
						
					set @err = @pBarcode +'_'+substring(@RawMaterialBarcode,1,20)+'...' + CHAR(10) +@err 
						raiserror (@err ,16,1) ;
						return;
						set @err=@err;        
				end		

	END -- end cháº·n chemical

   		set @RawMaterialBarcode  = substring(case when @pLotID_Warehouse_Created <>'' and @pLotID_Warehouse_Created is not null
											then isnull(@pLotID_Warehouse_Created,'') +'~'+isnull(@pRawMaterialBarcode,'')
											else @RawMaterialBarcode
											end,1,200)

END


END

-- NhÃ  mÃ¡y Báº¯c Giang 2
ELSE IF @checkWorkCenterCode IN ('VVT_F4')
BEGIN		-- BEGIN BG2
	print('bg2')

	set @pRawMaterialBarcode = ltrim(rtrim(isnull(@pRawMaterialBarcode,''))); 
	set @pLotID_Warehouse_Created =ltrim(rtrim( isnull(@pLotID_Warehouse_Created,'')));


	exec usp_VVT_checkHOLD_Material @lotid=@pRawMaterialBarcode        -- check  NVL thÃ´, mÃ£ LÃ³t ML.... náº¿u bá»‹ HOLD thÃ¬ khÃ´ng thá»ƒ LÆ°u láº¡i
	
	exec usp_VVT_checkHOLD_Material @lotid=@pLotID_Warehouse_Created   -- check  NVL thÃ´, mÃ£ LÃ³t ML.... náº¿u bá»‹ HOLD thÃ¬ khÃ´ng thá»ƒ LÆ°u láº¡i
	


	select @count=count(*) from stb_materialdoclotinfo
	where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'')<>''
	-- check táº¡m cho bÃªn Ä‘iá»‡n cá»±c
	-- khi mÃ£ cÃ³ Ä‘áº§u lÃ  sp má»›i kiá»ƒm tra
	if(@count <1 and (@RawMaterialBarcode like '%SP%' or @RawMaterialBarcode like '%SL%' or @RawMaterialBarcode like '%SM%'))
	begin
		select @count=count(*) from STB_MaterialLotInfo
		where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'')<>''
	end
	

	--declare @fd varchar(20) = @count
	
	--RAISERROR(@pRawMaterialBarcode,16,1)
	 -- Náº¿u Ä‘Ãºng lÃ  mÃ£ LÃ³t ML.... cá»§a Kho NVL thÃ¬ sáº½ Ä‘Æ°á»£c phÃ©p Ä‘i qua Äoáº¡n nÃ y
	 -- Náº¿u khÃ´ng pháº£i mÃ£ LÃ³t ML , khÃ´ng pháº£i mÃ£ Äiá»‡n cá»±c , thÃ¬ sáº½ bÃ¡o lá»—i
	if(@count>0) begin   



		-- Äoáº¡n nÃ y lÃ  Ä‘iá»u kiá»‡n ngoáº¡i lá»‡ bá» qua ko check Háº¿t háº¡n  NGÃ y thÃ¡ng ná»¯a , 
		-- chá»‰ cáº§n thÃªm LÃ³t Ngoáº¡i lá»‡ vÃ o mÃ n hÃ¬nh C555 lÃ  sáº½ Ä‘c loáº¡i trá»« Cháº·n háº¿t háº¡n
		--declare @OpenExpiredBG2 bit = 0 
	 	;with data1 as (
			select LotID,max(createdatetime) as createdatetime
			from stb_vvt_OpenExpiredMaterial  with(nolock) 
			where (LotID=@pRawMaterialBarcode)
			group by lotid
		)
		select top 1 @OpenExpired = voem.OpenExpired 
		from stb_vvt_OpenExpiredMaterial voem with(nolock) 
		join data1 on voem.lotid = data1.lotid and voem.createdatetime = data1.createdatetime

		
		--declare @mmmaterialcodeBG2 varchar(30)='';
		select top 1  @validDate=isnull(LotAttr10,'2010-01-01'),@mmmaterialcode=isnull(MaterialCode,''),@RawMaterialBarcode= isnull(LotNo ,'')
		from stb_materialdoclotinfo
		where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'')<>''

		 --kiá»ƒm tra Ä‘Ã£ tÃ¡ch nvl thÃ¬ váº«n cho nháº­p
		if(@mmmaterialcode ='' and  (@RawMaterialBarcode like '%SP%' or @RawMaterialBarcode like '%SL%'or @RawMaterialBarcode like '%SM%'))
		 begin 
		--RAISERROR('jf',16,1)
			 select top 1  @validDate=isnull(LotAttr10,'2010-01-01'),@mmmaterialcode=isnull(MaterialCode,''),@RawMaterialBarcode= isnull(LotNo ,'')
			from stb_materiallotinfo
			where lotid in (@pRawMaterialBarcode,@pLotID_Warehouse_Created) and isnull(lotid,'')<>''
		 end
		 
		 set @pRawMaterialBarcode =  @mmmaterialcode +'#'+ @RawMaterialBarcode +' ; '+ @pRawMaterialBarcode +';'+@pLotID_Warehouse_Created
		 set @RawMaterialBarcode = @pRawMaterialBarcode
		 

		--RAISERROR(@validDate,16,1)
		--return
		
		 -- Náº¿u khÃ´ng má»Ÿ cháº·n á»Ÿ mÃ n hÃ¬nh C555 , khÃ´ng pháº£i LÃ³t NVL Ngoáº¡i lá»‡ , thÃ¬ sáº½ vÃ o cáº£nh bÃ¡o Háº¿t háº¡n 
		if((isnull(@OpenExpired,0)=0 or @OpenExpired=0 or convert(bit,@OpenExpired)=0) and @mmmaterialcode not in ('TRAY1320-B015'))
		 begin try	
			if  isnull((select  dateadd(day,(ISNULL(MMExtInt01,3) * 30)+ISNULL(MMExtInt01,3)/12*6,@validDate)  from STB_MaterialMaster where MaterialCode= @mmmaterialcode),getdate()-1)
				< getdate()
			begin 
						set @err=N'NgÃ y thÃ¡ng Sáº£n xuáº¥t cá»§a Vendor Lot quÃ¡ háº¡n sá»­ dá»¥ng,  Hoáº·c chÆ°a thiáº¿t láº­p MMExtInt01 trong mÃ n hÃ¬nh A230: ' + 
												@pProductGroupCode+' _ '+ @RawMaterialBarcode +' _ '+
												@validDate + N'. Vui lÃ²ng kiá»ƒm tra láº¡i!';
					RAISERROR (@err,16,1);
					return;
			end
				
		 end try
		 begin catch

					set @err=N'KhÃ´ng thá»ƒ chuyá»ƒn Ä‘á»•i kÃ­ tá»± thÃ nh NgÃ y thÃ¡ng,  (Lotattr10)Äáº·c tÃ­nh 10 mÃ n hÃ¬nh F330:' + 
									@pProductGroupCode+' _ '+ @RawMaterialBarcode +' _ '+
									@validDate ;

					SET @err = isnull(ERROR_MESSAGE(),'')  +'_...............................'+ @err;

					RAISERROR (@err,16,1);
					return;
		 end catch
		 

	 end

	 	 
    else 
		-- Náº¿u lÃ  hÃ ng PCB nháº­p tá»« vendor thÃ¬ khÃ´ng cáº§n báº¯t Ä‘áº§u báº±ng ML
  
	 IF isnull(@RawMaterialBarcode,'')<>'' and UPPER(isnull(@pProductGroupCode,''))='PWB164180'
	 begin
				set @err=N'KhÃ´ng Ä‘Æ°á»£c sá»­ dá»¥ng mÃ£ Vendor LÃ³t khÃ´ng pháº£i cá»§a Kho NguyÃªn liá»‡u báº¯t Ä‘áº§u = kÃ­ tá»±   ML.... ' + 
									isnull(@pProductGroupCode,'') +' _ ' + isnull(@RawMaterialBarcode,'') +' _ '+
									isnull(@validDate,'') ;
									
					RAISERROR (@err,16,1);
					return;
	 end

	 
	 -- check loai NVL
	 
	 select @pRawMaterialBarcode = ltrim(rtrim(@pRawMaterialBarcode))
	 declare @MaterialWarehouse VARCHAR(20) = null
	 SELECT @MaterialWarehouse = MaterialWarehouseCode FROM STB_MaterialLotInfo where LotID = @pRawMaterialBarcode
	 IF @MaterialWarehouse <> 'ROUTE_BG2_WH'
		begin
		   raiserror (N'Lot nÃ y chÆ°a Ä‘Æ°á»£c xuáº¥t ra sáº£n xuáº¥t. HÃ£y kiá»ƒm tra láº¡i' ,16,1) ;
		   return;
		end

		declare @MaterialBG2 VARCHAR(20) = null,
				@TrueMaterialBG2 VARCHAR(20) = NULL
		--Capacitor35105
		--Header145354
		--Header145355
		--Header145802
		--Label029766
		--MiscElectrical135474
		--PWB164180
		--RTVCoating
		--TerminalBlock135474
	 if(isnull(@pProductGroupCode,'') in (
		'Capacitor35105',
		'Header145354',
		'Header145355',
		'Header145802',
		'Label029766',
		'MiscElectrical135474',
		'PWB164180',
		'TerminalBlock135474',
		'Cable166555',
		'Insulator165275',
		'Label021111',
		'Label021112',
		'Label021113',
		'Label102536',
		'Label130298',
		'Screw112752',
		'Screw126611',
		'Screw136544',
		'SheetMetalPart164081',
		'SheetMetalPart164083',
		'SheetMetalPart164085'


	 )  ) 
	 begin	


		 select @pRawMaterialBarcode = ltrim(rtrim(@pRawMaterialBarcode))
		 
		
		SELECT @MaterialBG2 = MaterialCode FROM STB_MaterialLotInfo where LotID = @pRawMaterialBarcode
		SELECT @TrueMaterialBG2 = MaterialCode FROM STB_MaterialMaster WHERE MaterialName LIKE (RIGHT(@pProductGroupCode, 6))

		if(@MaterialBG2 <> @TrueMaterialBG2)
		begin
		   set @err = N'MÃ£ lot Ä‘Ã£ nháº­p ' +@pRawMaterialBarcode+ ' - ' + @MaterialBG2 +  N' khÃ¡c NVL há»‡ thá»‘ng: '  + @TrueMaterialBG2 + N'. Vui lÃ²ng kiá»ƒm tra láº¡i';
		   raiserror (@err ,16,1) ;
		   return;
		end
	end


		if(isnull(@pProductGroupCode,'') in (
			'Nut17412',
			'Screw18496',
			'Screw18501',
			'Screw18502',
			'Washer21121',
			'Washer21122'


	 )  ) 
	 begin	


		select @pRawMaterialBarcode = ltrim(rtrim(@pRawMaterialBarcode))
		 

		SELECT @MaterialBG2 = MaterialCode FROM STB_MaterialLotInfo where LotID = @pRawMaterialBarcode
		SELECT @TrueMaterialBG2 = MaterialCode FROM STB_MaterialMaster WHERE MaterialName LIKE (RIGHT(@pProductGroupCode, 5))

		if(@MaterialBG2 <> @TrueMaterialBG2)
		begin
		   set @err = N'MÃ£ lot Ä‘Ã£ nháº­p ' +@pRawMaterialBarcode+ ' - ' + @MaterialBG2 +  N' khÃ¡c NVL há»‡ thá»‘ng: '  + @TrueMaterialBG2 + N'. Vui lÃ²ng kiá»ƒm tra láº¡i';
		   raiserror (@err ,16,1) ;
		   return;
		end
	end

		-- 153_CHATPHUBM-02
		if(isnull(@pProductGroupCode,'') in ( 'RTVCoating' )  ) 
		begin	


		select @pRawMaterialBarcode = ltrim(rtrim(@pRawMaterialBarcode))
		 

		SELECT @MaterialBG2 = MaterialCode FROM STB_MaterialLotInfo where LotID = @pRawMaterialBarcode
		SELECT @TrueMaterialBG2 = MaterialCode FROM STB_MaterialMaster WHERE MaterialName LIKE 'DOWSILâ„¢ 3140 RTV Coating'

		if(@MaterialBG2 <> '153_CHATPHUBM-02')
			begin
			   set @err = N'MÃ£ lot Ä‘Ã£ nháº­p ' +@pRawMaterialBarcode+ ' - ' + @MaterialBG2 +  N' khÃ¡c NVL há»‡ thá»‘ng: '  + @TrueMaterialBG2 + N'. Vui lÃ²ng kiá»ƒm tra láº¡i';
			   raiserror (@err ,16,1) ;
			   return;
			end
		end

		-------------------------------------
		if(isnull(@pProductGroupCode,'') in ( 
				'CapacitorBoard',
				'Fan531',
				'LEDBoard',
				'MonitoringBoard',
				'RelayBoard',
				'SNSBoard' )  ) 
		begin	


		select @pRawMaterialBarcode = ltrim(rtrim(@pRawMaterialBarcode))
		

		SELECT @MaterialBG2 = MaterialCode FROM STB_MaterialLotInfo where LotID = @pRawMaterialBarcode
		SELECT @TrueMaterialBG2 = MaterialCode FROM STB_MaterialMaster WHERE MaterialName LIKE (Select ProductGroupName from STB_RawMaterialBaiscInfo where ProductGroupCode LIKE @pProductGroupCode)

		if(@MaterialBG2 <> @TrueMaterialBG2)
			begin
			   set @err = N'MÃ£ lot Ä‘Ã£ nháº­p ' +@pRawMaterialBarcode+ ' - ' + @MaterialBG2 +  N' khÃ¡c NVL há»‡ thá»‘ng: '  + @TrueMaterialBG2 + N'. Vui lÃ²ng kiá»ƒm tra láº¡i';
			   raiserror (@err ,16,1) ;
			   return;
			end
		end

END		-- END BG@

		-- Start Mr.Duc EA 2026-04-14 - Luu nhi?u mï¿½ barcode NVL trï¿½n cï¿½ng 1 lot s?n ph?m
		DECLARE @existingRawBarcode NVARCHAR(200) = ''
		SELECT @existingRawBarcode = ISNULL(RawMaterialBarcode, '') FROM STB_RawMaterialInputHist WITH(NOLOCK) WHERE RawMaterialInputHistNo = @pRawMaterialInputHistNo
		IF @existingRawBarcode <> '' AND CHARINDEX(ISNULL(@RawMaterialBarcode, ''), @existingRawBarcode) = 0
			SET @RawMaterialBarcode = @existingRawBarcode + ' ; ' + ISNULL(@RawMaterialBarcode, '')
		-- End Mr.Duc
					
		UPDATE STB_RawMaterialInputHist
			SET
				RawMaterialInputHistNo =   ISNULL(@pRawMaterialInputHistNo,RawMaterialInputHistNo),
				Barcode =   ISNULL(@pBarcode,@pBarcode),
				ProductGroupCode =   ISNULL(@pProductGroupCode,ProductGroupCode),
				RawMaterialBarcode =   ISNULL(@RawMaterialBarcode,RawMaterialBarcode),
				LotMaterialCode =  ISNULL(@LotMaterialBarcode,@LotMaterialBarcode),
				CreateDateTime =   ISNULL(CreateDateTime,@pCreateDateTime),
				CreateUserID =   ISNULL(CreateUserID,@pProcessUserID),
				ChangeDateTime = GETDATE(),
				ChangeUserID = @pProcessUserID
		WHERE   RawMaterialInputHistNo = @pRawMaterialInputHistNo

		--Mr Truong update add history save raw material input 2025-12-13
		IF @@ROWCOUNT > 0
		BEGIN 
		  IF @pProductGroupCode IN ('ELECTRODEP', 'ELECTRODEM')
		  BEGIN
		    IF NOT EXISTS (
               SELECT 1 
               FROM STB_InputMaterialHistory
               WHERE RawMaterialBarcode = @RawMaterialBarcode 
                     AND Barcode = @Barcode
            )
			BEGIN
			   INSERT INTO STB_InputMaterialHistory (Barcode, RawMaterialBarcode,CreateUserID,ProductGroupCode,CreatedDate)
			   VALUES (@Barcode, @RawMaterialBarcode,@pProcessUserID,@pProductGroupCode,GETDATE())
		    END
          END
       END
	   --end
END   




--select * from STB_MaterialLotInfo where LotId='ML2026020900052'

--SELECT * from STB_MaterialDocLotInfo where LotID='ML2026020900052'