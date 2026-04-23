

CREATE  PROCEDURE [usp_VVT_autocompleteBOM]
						@pCode VARCHAR(20) = NULL,
						@pVersion VARCHAR(20) = NULL,
						@pCompanyCode VARCHAR(20) = NULL
						
AS
	
BEGIN


----             usp_VVT_autocompleteBOM  'VVVEC27-001','74'

-- select wipcode,count(*) from stb_vvt_materialbo with(nolock)
--  where wipcode in (
-- 'VVVEC27-001',
-- 'VVWEC30-004',
-- 'VVWEC30-007',
-- 'VNVEC27-008',
-- 'VVWEC30-013',
-- 'MVCE60-002',
-- 'MVCE60-027',
-- 'MVCC60-064')
-- group by wipcode

--select * from STB_SetInfo
--where MaterialCode='ECVT27-322'
--and CreateDateTime between '2022-06-01'  and '2022-08-30' 


-- select * from stb_vvt_materialbo with(nolock)
--where wipcode in ('VVVEC27-004')
---- and type like 'V-%' and wipcode='VNVEC27-008
-- order by wipcode , routecode, materialcode


-- mã kế toán -> fg01 -> mã mes -> a310 bom -> stb_vvt_materialbo


declare @errrr nvarchar(2000)='';
declare @productcode varchar(30)='';		


	select top 1 @productcode = MaterialCode 
	from STB_VN_FINISHGOODS  with(nolock) 
	where PublicCode=@pCode and MaterialCode is not null


	if isnull(@pVersion,'')='' begin
		select top 1 @productcode = fg.MaterialCode 
		from STB_VN_FINISHGOODS fg  with(nolock) 
		join STB_BomDetail bd with(nolock)  on fg.MaterialCode=bd.MaterialCode 		
		where PublicCode=@pCode and fg.MaterialCode is not null and bd.BomVersion=@pVersion
	end


	if(isnull(@productcode,'')='')
			
			select top 1 @productcode = MaterialCode 
			from STB_VN_FINISHGOODS  with(nolock) 
			where PublicCode=@pCode and MaterialCode is not null


			 select top 1 @productcode = a.MaterialCode 
			 from STB_BomDetail a with(nolock) 
			join STB_BomHeader v with(nolock)  on a.MaterialCode = v.MaterialCode
			where BomHeaderDesc like '%'+@pCode+'%' --and a.BomVersion=@pVersion
			-- or (BomHeaderDesc like '%'+@pCode+'%' and a.BomVersion=@pVersion)

			declare @count INT = 0 
			select @count = count(*) 
			from stb_vvt_materialbo
			where wipcode= @pCode

	if(@productcode='' or @productcode is null ) begin 
		 if(@count=0) begin
			set @errrr =N'Không tìm thấy code Hàn của code kế toán ='+@pCode;
		    raiserror(@errrr,16,1);
		 end

	  return;
	end



	declare @size varchar(30)='';
	declare @type varchar(30)='';
	declare @vol varchar(30)='';
	declare @farad varchar(30)='';
	declare @productname nvarchar(300)='';
	
	select @productname = ModelName, 
	@type=MBIExtText03, 
	@vol=MBIExtText04, 
	@farad = MBIExtText05, 
	@size=RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))+ 
	case when ModelName like '%-L%' then '-L' else '' end 
	from STB_ModelBasicInfo  with(nolock) 
	where ModelCode = @productcode  


	if ( isnull(@size,'')=''  or   isnull(@type,'')='' or  isnull(@vol,'')='' ) begin 
		set @errrr =N'Dữ liệu chưa đầy đủ ='+@productcode +' :: '+@pCode+' , size='+@size+' , type='+@type+' , vol='+@vol; 
		  raiserror(@errrr,16,1); 
	      return; 
	end 
	

	update stb_vvt_materialbo 
	set size=@size , type=@type, vol=@vol , semiProductName=@productname,createdatetime=isnull(createdatetime,getdate() )
	where wipcode=@pCode 
	
	if(  @@ROWCOUNT=0   and  isnull(@pVersion,'')<>''   ) begin 
	    insert into stb_vvt_materialbo 
		( wipcode,  materialname, materialcode, usage, unit, qtycell, usageok, semiProductName, size, type, vol, farad, routecode ) 
		select @pCode, (select materialname from STB_MaterialMaster with(nolock)  where MaterialCode=ChildMaterialCode ), 
		ChildMaterialCode, UsedQty,BomUnit,1,UsedQty,@productname,@size,@type,@vol,@farad,RouteCode 
		from  STB_BomDetail with(nolock) 
		where MaterialCode=@productcode and BomVersion = @pVersion 
	end 
	

END
