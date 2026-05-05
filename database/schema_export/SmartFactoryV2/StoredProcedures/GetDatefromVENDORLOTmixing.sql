-- Procedure: GetDatefromVENDORLOTmixing

CREATE  Procedure [dbo].[GetDatefromVENDORLOTmixing]
(
	@pBarCode varchar(20), 
    @pProductGroupCode varchar(20), 
	@pRawMaterialBarcode NVARCHAR(200),
	@pOut NVARCHAR(2000) OUTPUT
)

---set @tmpdate = S DATE 

AS

BEGIN



	---set nocount on;

	declare @count int = (select count(*) from STB_SetInfo with(nolock) where Barcode= @pBarCode and MaterialCode='ECVT27-369' );
	
	set @pProductGroupCode = upper( ltrim(rtrim(@pProductGroupCode)) ) ;


	--if(@count<=0 or @pProductGroupCode like '%ELECTRODE%') begin 
	--	return; 
	--end 

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
											);


	 declare   @tmpdate1 varchar(10)='' ;

	 	 
      
   if(@pProductGroupCode like '%MSP%20%' or @RawMaterialBarcode='GAKA00-002') begin
		set @tmpdate = SUBSTRING(@tmpdate,CHARINDEX('LOTNO',@tmpdate,1),20)
		set @tmpdate = replace(replace(@tmpdate,'LOTNO',''),':','')

		set @tmpdate1 = '20'+substring(@tmpdate,2,8) --+'-'+substring(@tmpdate,5,2) +'-'+ substring(@tmpdate,7,2)
		set @tmpdate1 =  (dateadd(month,12,convert(date,@tmpdate1,120)))
   end

   	 

    if( @pProductGroupCode like '%YP%50%' or   @RawMaterialBarcode like '%>%' and @RawMaterialBarcode like '%SK%' ) 
	  begin
		set @tmpdate = SUBSTRING(@tmpdate,CHARINDEX('SK',@tmpdate,1),20)
		set @tmpdate = replace(replace(@tmpdate,'SK',''),'#','')

		set @tmpdate1 = '20'+substring(@tmpdate,1,2)+'-'+substring(@tmpdate,3,2) +'-'+ substring(@tmpdate,5,2)
		set @tmpdate1 =  (dateadd(month,12,convert(date,@tmpdate1,120)))
   end
   	  

   
    if( @pProductGroupCode like '%BM%400%' or   @RawMaterialBarcode like 'GAZOCB-001' ) 
	  begin
		set @tmpdate1 = '20'+substring(@tmpdate,1,2)+'-'+substring(@tmpdate,3,2) +'-'+ substring(@tmpdate,5,2)
		set @tmpdate1 =  (dateadd(month,12,convert(date,@tmpdate1,120)))--24 month
   end

   	 

    if( @pProductGroupCode like '%CMC%' or   @RawMaterialBarcode like 'GADACB-001' ) 
	  begin
		declare @year varchar(4) = case when substring(@tmpdate,1,1)='9' then '2022' 
										 when substring(@tmpdate,1,1)='0' then '2023'
										  when substring(@tmpdate,1,1)='1' then '2024'
										   when substring(@tmpdate,1,1)='2' then '2025'
											when substring(@tmpdate,1,1)='3' then '2026'
											 when substring(@tmpdate,1,1)='4' then '2027'
											  when substring(@tmpdate,1,1)='5' then '2028'
											   when substring(@tmpdate,1,1)='6' then '2029'
										else '' end

		set @tmpdate1 = @year+'-'+ (case when substring(@tmpdate,4,1)='A' then '11'
										when substring(@tmpdate,4,1)='B' then '12'
										else + substring(@tmpdate,4,1) 
										end) + '-15'
		set @tmpdate1 =  (dateadd(month,6,convert(date,@tmpdate1,120)))--16month
   end

   	 
  -- if(@pProductGroupCode like '%SUPER%P%'*/  and @RawMaterialBarcode like 'GATCCC-001' ) 
	 -- begin
		--set @tmpdate1 =  (dateadd(month,6,convert(date,@tmpdate1,120)))
  -- end
  --    if(@pProductGroupCode like '%PVP%'*/  and @RawMaterialBarcode like 'GAADCB-001' ) 
	 -- begin
		--set @tmpdate1 =  (dateadd(month,6,convert(date,@tmpdate1,120)))
  -- end
  -- if(@pProductGroupCode like '%PTFE%' or   @RawMaterialBarcode like 'GADPCB-002' ) 
	 -- begin
		--set @tmpdate1 =  (dateadd(month,6,convert(date,@tmpdate1,120)))
  -- end

  

   if( @pProductGroupCode like '%A%200%' or   @RawMaterialBarcode='GAHSCB-001') begin
		set @tmpdate1 = '20'+substring(@tmpdate,6,2) +'-'+substring(@tmpdate,8,2) +'-'+ substring(@tmpdate,10,2)
		set @tmpdate1 =  (dateadd(month,12,convert(date,@tmpdate1,120)))
   end



   	 
   if( @pProductGroupCode like '%CEP%' or   @RawMaterialBarcode='GAPOCA-006') begin
   		declare @month varchar(4) = case when substring(@tmpdate,1,1)='A' then '01' 
										 when substring(@tmpdate,1,1)='B' then '02'
										  when substring(@tmpdate,1,1)='C' then '03'
										   when substring(@tmpdate,1,1)='D' then '04'
											when substring(@tmpdate,1,1)='E' then '05'
											 when substring(@tmpdate,1,1)='F' then '06'
											  when substring(@tmpdate,1,1)='G' then '07'
											   when substring(@tmpdate,1,1)='H' then '08'
											 when substring(@tmpdate,1,1)='J' then '09'
											 when substring(@tmpdate,1,1)='K' then '10'
											  when substring(@tmpdate,1,1)='L' then '11'
											   when substring(@tmpdate,1,1)='M' then '12'
										else '' end

		set @tmpdate1 = '20'+substring(@tmpdate,5,2) + @month + '-15'
		set @tmpdate1 =  (dateadd(month,12,convert(date,@tmpdate1,120)))
   end


   if(@tmpdate1<>'' and convert(date,@tmpdate1,120) < getdate())
   begin
		set @pOut =N'Ngày tháng Sản xuất của Vendor Lot quá hạn sử dụng: ' + 
									@pProductGroupCode+' - '+ @RawMaterialBarcode +' - '+
									@tmpdate1 + N'. Vui lòng kiểm tra lại!';
   end

   
end try
begin catch
		set @pOut=N'Không thể chuyển đổi chuỗi thành Ngày tháng: ' + 
									@pProductGroupCode+' - '+ @RawMaterialBarcode +' - '+
									@tmpdate1 ;
end catch
      
END




   --select top 10*from STB_ElectrodeMixStepInfo
   --where ElectrodeLotNumber='VVMR1212001E24'


   --   select  distinct MaterialLotNumber
	  --from STB_ElectrodeMixStepInfo
   --where MaterialLotNumber like '%>%' and CreateDateTime>'2022-08-01' 

   
--=select  (dateadd(month,12,convert(date,'2024-',120)))
GO

