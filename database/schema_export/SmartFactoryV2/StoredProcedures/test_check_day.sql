-- Procedure: test_check_day
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--ML20230705000255
--exec test_check_day 'VVNU052R750601','TERMINA','GBHB00-042#230221Y022006 ; ML20230918000070;'
--exec test_check_day 'VVNU052R750601','SLEEVE','GCMDPT-199#2306201403 ; ML20230705000255;'
CREATE PROCEDURE [dbo].[test_check_day]
(
	@pBarCodeday varchar(20), 
    @pProductGroupCodeday varchar(20), 
	@pRawMaterialBarcodeday NVARCHAR(200) 
)
AS
BEGIN


	---set nocount on;

	declare @countday int = (select count(*) from STB_SetInfo with(nolock) where Barcode= @pBarCodeday and MaterialCode='ECVT27-369' );
	
	set @pProductGroupCodeday = upper( ltrim(rtrim(@pProductGroupCodeday)) ) ;
	 
	declare @imonthday varchar(10) ='';


	if( @pProductGroupCodeday like '%MODULE%' or @countday=0) begin 
		return; 
	end 

   set @pRawMaterialBarcodeday = upper( (ltrim(rtrim(@pRawMaterialBarcodeday))) ) ;
	
   declare   @RawMaterialBarcodeday varchar(10) = substring(@pRawMaterialBarcodeday,1,10) ;
   

    print @pRawMaterialBarcodeday
	print @RawMaterialBarcodeday
begin try
   declare   @tmpdateday nvarchar(200) = replace(replace(
											replace(replace(@pRawMaterialBarcodeday,' ',''),
													@RawMaterialBarcodeday,
													'')
											,'#'
											,'')											
											,'£'
											,''
											) ;
	 declare   @tmpdate1day varchar(10)=''
	
	 	print '=>>>' +@tmpdateday
	   if(@pProductGroupCodeday like '%SLEEVE%' and @RawMaterialBarcodeday='GCMDPT-199'
   ) begin
	
		set @imonthday  =  substring(@tmpdateday,3,2)
		print '=>>'+@imonthday
		set @imonthday = case when @imonthday='A' or @imonthday='a' then '10'
		when @imonthday='B' or @imonthday='B' then '11'
		when @imonthday='C' or @imonthday='c' then '12'
		else @imonthday
		end
		print '=------------->>'+@tmpdateday
		set @tmpdate1day = '20'+substring(@tmpdateday,1,2) +'-'+ @imonthday+'-' + substring(@tmpdateday,5,2)
			print '=>>'+@tmpdate1day
		set @tmpdate1day =  (dateadd(month,12,convert(date,@tmpdate1day,120)))
	
   end
     print @pProductGroupCodeday
   if(@pProductGroupCodeday like '%TERMINA%' and @RawMaterialBarcodeday in ('GBHB00-043','GBHB00-042') 
   ) begin
		set @imonthday  =  substring(@tmpdateday,3,2)
		print '---------=>>'+@imonthday
		set @imonthday = case when @imonthday='A' or @imonthday='a' then '10'
		when @imonthday='B' or @imonthday='B' then '11'
		when @imonthday='C' or @imonthday='c' then '12'
		else @imonthday
		end
		print '=------------->>'+@tmpdateday
		set @tmpdate1day = '20'+substring(@tmpdateday,1,2) +'-'+@imonthday+'-' + substring(@tmpdateday,5,2)
		print '=>>'+@tmpdate1day
		set @tmpdate1day =  (dateadd(month,24,convert(date,@tmpdate1day,120)))
   end
   if(@tmpdate1day='') return;
  
   if( convert(date,@tmpdate1day,120) < getdate() and @pProductGroupCodeday not like '%ELECTRODE%') begin
		declare @err2day nvarchar(100)=N'Ngày tháng Sản xuất của Vendor Lot quá hạn sử dụng,  Hoặc chưa thiết lập MMExtInt01 trong màn hình A230: ' + 
									@pProductGroupCodeday+' _. '+ @RawMaterialBarcodeday +' _. '+
									@tmpdate1day + N'. Vui lòng kiểm tra lại!';
		RAISERROR (@err2day,16,1);
		return;
   end

end try
begin catch

		declare @err6day nvarchar(2000)=N'Không thể chuyển đổi kí tự thành Ngày tháng 22222222: ' + 
									@pProductGroupCodeday+' _. '+ @RawMaterialBarcodeday +' _. '+
									@tmpdate1day ;

		SELECT @err6day = @err6day +'_........................................................'+ ERROR_MESSAGE();
		print @err6day
		RAISERROR (@err6day,16,1);
end catch
END

GO

