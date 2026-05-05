-- Procedure: GetDatefromVENDORLOT1840
--  exec GetDatefromVENDORLOT1840 'VVPM082R750609','Separator','GBNKSP-060#4Y21N06B;ML20250225000112'
/*
				select mdi.SourceCustomerCode from 
			STB_MaterialdocLotInfo mdli with(nolock)
			left outer join STB_MaterialDocInfo mdi  with(nolock) on mdli.MaterialDocNo = mdi.MaterialDocNo
			where  mdli.LotID='ML20231226000243'
			*/

CREATE Procedure [dbo].[GetDatefromVENDORLOT1840]
(
	@pBarCode varchar(20), 
    @pProductGroupCode varchar(20), 
	@pRawMaterialBarcode NVARCHAR(200) 
)

---set @tmpdate = S DATE   select  LineCode, LineName, routename, endcode, beginOccur, finishTime, DuringOP  from stb_linesituation_vvt

AS

BEGIN

   
	---set nocount on;
	--kiểm tra xem có phải hàng hela hay không
	declare @count int = (select count(*) from STB_SetInfo with(nolock) where Barcode= @pBarCode and MaterialCode='ECVT27-369' );
	
	set @pProductGroupCode = upper( ltrim(rtrim(@pProductGroupCode)) ) ;
	
declare @imonth varchar(10) ='';
declare @SourceCustomerCode varchar(20) ='';
	--nếu không phải thì return luôn
	if( @pProductGroupCode like '%MODULE%' or @count=0) begin 

		return; 
	end 
	
   set @pRawMaterialBarcode = upper( (ltrim(rtrim(@pRawMaterialBarcode))) ) ;
		
   declare   @RawMaterialBarcode varchar(10) = substring(@pRawMaterialBarcode,1,10) ;




begin try

   declare   @tmpdate nvarchar(200) = replace(replace(
											replace(replace(@pRawMaterialBarcode,' ',''),
													@RawMaterialBarcode,
													'')
											,'#'
											,'')											
											,'£'
											,''
											) ;
	 declare   @tmpdate1 varchar(10)=''
	
	 
   if(@pProductGroupCode like '%CASE%' --and @RawMaterialBarcode='GBAKAC-063'
   ) begin
		
		--Mr duy thêm mới để đọc ncc mới VV033
		declare @getLotID varchar(50)= Replace((Right(@tmpdate,17)),';','')
			select @SourceCustomerCode=mdi.SourceCustomerCode from 
			STB_MaterialdocLotInfo mdli with(nolock)
			left outer join STB_MaterialDocInfo mdi  with(nolock) on mdli.MaterialDocNo = mdi.MaterialDocNo
			where  mdli.LotID=@getLotID
		if(@SourceCustomerCode in ('VV033'))
		begin

				set @imonth  =  substring(@tmpdate,7,2)
				set @imonth = case when @imonth='A' or @imonth='a' then '10'
				when @imonth='B' or @imonth='B' then '11'
				when @imonth='C' or @imonth='c' then '12'
				else @imonth
				end

				set @tmpdate1 = '202'+substring(@tmpdate,6,1) +'-'+@imonth+'-' + substring(@tmpdate,9,2)
				set @tmpdate1 =  (dateadd(month,24,convert(date,@tmpdate1,120)))

		end
		--hết thêm mới nhà cc
		else
		begin
			set @imonth  =  substring(@tmpdate,3,1)
			set @imonth = case when @imonth='A' or @imonth='a' then '10'
			when @imonth='B' or @imonth='B' then '11'
			when @imonth='C' or @imonth='c' then '12'
			else @imonth
			end

			set @tmpdate1 = '202'+substring(@tmpdate,2,1) +'-'+@imonth+'-' + substring(@tmpdate,4,2)
			set @tmpdate1 =  (dateadd(month,24,convert(date,@tmpdate1,120)))
		end
   end

   
   if(@pProductGroupCode like '%RUBBER%' and @RawMaterialBarcode='GBSN00-003'
   ) begin
		set @imonth  =  substring(@tmpdate,9,1)
		set @imonth = case when @imonth='O' or @imonth='a' then '10'
		when @imonth='B' or @imonth='N' then '11'
		when @imonth='C' or @imonth='D' then '12'
		else @imonth
		end

		set @tmpdate1 = '202'+substring(@tmpdate,8,1) +'-'+@imonth+'-' + substring(@tmpdate,10,2)
		set @tmpdate1 =  (dateadd(month,24,convert(date,@tmpdate1,120)))
   end


     

   if(@pProductGroupCode like '%SEPA%' and @RawMaterialBarcode in ('GBNKSP-060'
							,'GBNKSP-066'
							,'GBNKSP-067'
							,'GBNKSP-068'
							,'GBNKSP-080'
							,'GBNKSP-081') 
   ) begin
		set @imonth  =  substring(@tmpdate,2,1)
		set @imonth = case when @imonth='X' or @imonth='X' then '10'
		when @imonth='Y' or @imonth='Y' then '11'
		when @imonth='Z' or @imonth='Z' then '12'
		else @imonth
		end

		set @tmpdate1 = '202'+substring(@tmpdate,1,1) +'-'+@imonth+'-' + substring(@tmpdate,3,2)
		set @tmpdate1 =  (dateadd(month,24,convert(date,@tmpdate1,120)))
   end
   	 
   
   if(@pProductGroupCode like '%TERMINA%' and @RawMaterialBarcode in ('GBHB00-043','GBHB00-042') 
   ) begin
		set @imonth  =  substring(@tmpdate,3,2)
		set @imonth = case when @imonth='A' or @imonth='a' then '10'
		when @imonth='B' or @imonth='B' then '11'
		when @imonth='C' or @imonth='c' then '12'
		else @imonth
		end

		set @tmpdate1 = '20'+substring(@tmpdate,1,2) +'-'+@imonth+'-' + substring(@tmpdate,5,2)
		set @tmpdate1 =  (dateadd(month,24,convert(date,@tmpdate1,120)))
   end

   
  -- if(@pProductGroupCode like '%SLEEVE%' and @RawMaterialBarcode='GCMDPT-199'
  -- ) begin
		--set @imonth  =  substring(@tmpdate,8,2)
		--set @imonth = case when @imonth='A' or @imonth='a' then '10'
		--when @imonth='B' or @imonth='B' then '11'
		--when @imonth='C' or @imonth='c' then '12'
		--else @imonth
		--end

		--set @tmpdate1 = '20'+substring(@tmpdate,6,2) +'-'+ @imonth+'-' + substring(@tmpdate,10,2)
		--set @tmpdate1 =  (dateadd(month,12,convert(date,@tmpdate1,120)))
  -- end


  --Code Mr.Duy sửa 2023-12-08
     if(@pProductGroupCode like '%SLEEVE%' and @RawMaterialBarcode='GCMDPT-199'
   ) begin
		set @imonth  =  substring(@tmpdate,3,2)
		set @imonth = case when @imonth='A' or @imonth='a' then '10'
		when @imonth='B' or @imonth='B' then '11'
		when @imonth='C' or @imonth='c' then '12'
		else @imonth
		end

		set @tmpdate1 = '20'+substring(@tmpdate,1,2) +'-'+ @imonth+'-' + substring(@tmpdate,5,2)
		set @tmpdate1 =  (dateadd(month,12,convert(date,@tmpdate1,120)))
   end
   --end code Mr.Duy sửa

   if(@pProductGroupCode like '%TAPE%' and @RawMaterialBarcode='GBRBPL-003'
   ) begin
		set @imonth  =  substring(@tmpdate,11,2)
		set @imonth = case when @imonth='A' or @imonth='a' then '10'
		when @imonth='B' or @imonth='B' then '11'
		when @imonth='C' or @imonth='c' then '12'
		else @imonth
		end

		set @tmpdate1 = '20'+substring(@tmpdate,9,2) +'-'+@imonth +'-'+ substring(@tmpdate,13,2)
		set @tmpdate1 =  (dateadd(month,12,convert(date,@tmpdate1,120)))
   end

   
   if(@pProductGroupCode like '%ELECTROLYTE%' --and @RawMaterialBarcode='GBCP00-001'
   ) begin


		set @tmpdate = SUBSTRING(@tmpdate,CHARINDEX('LOTNO',@tmpdate,1),20)
		set @tmpdate = replace(replace(@tmpdate,'LOTNO',''),':','')

				set @imonth  =  substring(@tmpdate,5,2)
		set @imonth = case when @imonth='A' or @imonth='a' then '10'
		when @imonth='B' or @imonth='B' then '11'
		when @imonth='C' or @imonth='c' then '12'
		else @imonth
		end

		set @tmpdate1 = '20'+substring(@tmpdate,3,2) +'-'+@imonth +'-'+ substring(@tmpdate,7,2)
		set @tmpdate1 =  (dateadd(month,6,convert(date,@tmpdate1,120)))
   end
 
   if(@tmpdate1='') return;

   if( convert(date,@tmpdate1,120) < getdate() and @pProductGroupCode not like '%ELECTRODE%') begin
		declare @err2 nvarchar(100)=N'Ngày tháng Sản xuất của Vendor Lot quá hạn sử dụng,  Hoặc chưa thiết lập MMExtInt01 trong màn hình A230: ' + 
									@pProductGroupCode+' _. '+ @pRawMaterialBarcode +' _. '+
									@tmpdate1 + N'. Vui lòng kiểm tra lại!';
		RAISERROR (@err2,16,1);
		return;
   end

end try
begin catch

		declare @err6 nvarchar(2000)=N'Không thể chuyển đổi kí tự thành Ngày tháng: ' + 
									@pProductGroupCode+' _. '+ @pRawMaterialBarcode +' _. '+
									@tmpdate1 ;
		
		SELECT @err6 = @err6 +'_........................................................'+ ERROR_MESSAGE();

		RAISERROR (@err6,16,1);
end catch

END 


--=select  (dateadd(month,12,convert(date,'2024-',120)))
--ML20231226000243
/*
declare @pRawMaterialBarcode varchar(50)='GBAKAC-063#20231125036;ML20231226000243;'

set @pRawMaterialBarcode = upper( (ltrim(rtrim(@pRawMaterialBarcode))) ) ;
	
  declare   @RawMaterialBarcode varchar(10) = substring(@pRawMaterialBarcode,1,10) ;


   declare   @tmpdate nvarchar(200) = replace(replace(
											replace(replace(@pRawMaterialBarcode,' ',''),
													@RawMaterialBarcode,
													'')
											,'#'
											,'')											
											,'£'
											,''
											) ;
		print @tmpdate
	 declare   @tmpdate1 varchar(10)=''


 declare @imonth varchar(10) ='';
 
		declare @imonth3 varchar(100) ='20231125036;ML20231226000243;'
		declare @tach varchar(50)= Replace((Right(@imonth3,17)),';','')
		
	set @imonth  =  substring(@tmpdate,5,2)
		set @imonth = case when @imonth='A' or @imonth='a' then '10'
		when @imonth='B' or @imonth='B' then '11'
		when @imonth='C' or @imonth='c' then '12'
		else @imonth
		end

		set @tmpdate1 = '202'+substring(@tmpdate,4,1) +'-'+@imonth+'-' + substring(@tmpdate,6,2)
		set @tmpdate1 =  (dateadd(month,24,convert(date,@tmpdate1,120)))
		print @tmpdate1

		print @tach*/
GO

