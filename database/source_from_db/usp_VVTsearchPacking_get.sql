
CREATE PROCEDURE [dbo].[usp_VVTsearchPacking_get]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pUtcOffset INT,
				@pPONo VARCHAR(20) = NULL,
				@pDayPlanNo VARCHAR(20) = NULL,
				@pLabelType NVARCHAR(30) = NULL,
				@pLotNo VARCHAR(20) = NULL,
				@pQuantity VARCHAR(20) = NULL,
				@pDate datetime=null,
				@pLabelQty INT = NULL
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @LotNo VARCHAR(20) =  CASE WHEN ISNULL(@pLotNo,'') = '' THEN '%' ELSE @pLotNo END
	DECLARE @LotNonew1 VARCHAR(20) = ''
	DECLARE @LotNonew2 VARCHAR(20) = ''
	DECLARE @LotNonew3 VARCHAR(20) = ''
	DECLARE @LotNonew4 VARCHAR(20) = ''
	DECLARE @LotNonew5 VARCHAR(20) = ''
	DECLARE @LotNonew6 VARCHAR(20) = ''
	DECLARE @DayPlanNo VARCHAR(20) = CASE WHEN ISNULL(@pDayPlanNo,'') = '' THEN '%' ELSE @pDayPlanNo END
	DECLARE @LabelType NVARCHAR(30) = 'AssembleLabel'
		
	select @LotNonew1 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNo
	
	select @LotNonew2 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew1

	select @LotNonew3 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew2

	select @LotNonew4 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew3

	select @LotNonew5 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew4

	select @LotNonew6 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@LotNonew5

	select @LotNo =  CASE WHEN ISNULL(@LotNo,'') = '' THEN '%' ELSE @LotNo END
	select @LotNonew1 =  CASE WHEN ISNULL(@LotNonew1,'') = '' THEN '%' ELSE @LotNonew1 END
	select @LotNonew2 =  CASE WHEN ISNULL(@LotNonew2,'') = '' THEN '%' ELSE @LotNonew2 END
	select @LotNonew3 =  CASE WHEN ISNULL(@LotNonew3,'') = '' THEN '%' ELSE @LotNonew3 END
	select @LotNonew4 =  CASE WHEN ISNULL(@LotNonew4,'') = '' THEN '%' ELSE @LotNonew4 END
	select @LotNonew5 =  CASE WHEN ISNULL(@LotNonew5,'') = '' THEN '%' ELSE @LotNonew5 END
	select @LotNonew6 =  CASE WHEN ISNULL(@LotNonew6,'') = '' THEN '%' ELSE @LotNonew6 END
	


	if( (@pLotNo<>'' and @pLotNo is not  null) and 
		(@pQuantity<>'' and @pQuantity is not  null) and 
	  (@pLabelQty<>'' and @pLabelQty is not  null) and 
		(@pDate<>'' and @pDate is not null)  
	) 
	begin

		declare @packingID varchar(30) = ''
		declare @errr nvarchar(300) = ''

		select @LotNo = Barcode 
		from stb_setinfo  with(nolock)
		where Barcode in (@LotNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)


		if(@LotNo='' or @LotNo is null) begin
			set @errr = N'LotNo bị sai hoặc không có trong hệ thống!  '+@pLotNo;
			raiserror(@errr,16,1)
			return
		end


		select @packingID = PackingID
		from stb_materiallotinfo  with(nolock)
		where Lotno=@LotNo

		if(@packingID='' or @packingID is null) begin
			set @errr = N'PackingID bị sai hoặc Lót hàng chưa được đóng gói ở B523 !  '+@pLotNo;
			raiserror(@errr,16,1)
			return
		end

     ;with Table1 as (
		select 
			top (convert(INT,@pLabelQty) )
			@LotNo as BatchNo
			,'H00.047-53' as CustomerPartNo
			,replace(convert(varchar(10),dateadd(year,2,@pDate),120),'-','') as ExpiryDate
			,replace(convert(varchar(10),@pDate,120),'-','') as ManufacturingDate
			,'VIETNAM' as ManufacturingLocation			
			,'S'+@packingID + right('0' + convert(varchar(5),row_number() over (order by materialcode)) ,2) as PackageID
			,@pQuantity as Quantity
			,'VEC3R0107QG-C' as SupplierPartNo
		from stb_setinfo with(nolock)
			 where createdatetime>dateadd(day,-100,getdate())
		)
		select  
		 * 
		  ,'Report' as CommandType
		 , 'KlemoveVietnam' as FormatName
		  ,'KlemoveMATLabel' as LabelType
		 , '' PrinterName
		,  1 as LabelQty 
		,'[)>@06@12S0002@P'+CustomerPartNo+
		'@1P'+SupplierPartNo+'@31P'+CustomerPartNo+
		'@12V295@10V'+ManufacturingLocation+
		'@2P@20P@6D'+ManufacturingDate+
		'@14D'+ExpiryDate+
		'@30PY@Z3@K4500065436@16KTJ3791082@V48400020@3S'+PackageID+
		'@Q'+Quantity+
		'NAR000@20T1@1T'+BatchNo+'@2T@1Z139991873@@' as MATLabel
		from Table1

		return;
   end
	

	--select @LotNo+'.'+	@LotNonew1+'.'+	@LotNonew2+'.'+	@LotNonew3+'.'+	@LotNonew4+'.'+	@LotNonew5+'.'+	@LotNonew6 as PackingID
	--return
	
	-- Search Date  and No paramenter LotNo
	-- Author:Nguyễn Hải Triều (09/04/2025)

	--IF (ISNULL(@pLotNo, '') = '') AND @pDate IS NOT NULL
	if @LotNo='%' and @pDate is not null
	begin
		select mli.PackingID,mli.LotNo,mli.MaterialCode,mm.MaterialName,mli.CurrentQty,
			mli.CompanyCode,mli.InitialQty,mli.ProductionDate,mli.CreateDateTime,mli.CreateUserID
			from STB_MaterialLotInfo mli with (nolock)
			left outer join STB_MaterialMaster mm with (nolock) on mli.MaterialCode=mm.MaterialCode
			where  CompanyCode='VVT' 
			and LotID not like 'ML%'
			AND CAST(mli.CreateDateTime AS DATE) >= DATEFROMPARTS(YEAR(@pDate), MONTH(@pDate), 1)
            AND CAST(mli.CreateDateTime AS DATE) <  DATEADD(MONTH, 1, DATEFROMPARTS(YEAR(@pDate), MONTH(@pDate), 1))
			

			--and ProductionDate> CONVERT(varchar(10),dateadd(month,-6,GETDATE() ),120)		
		return
	end

	 -- Default Search
	select mli.PackingID,mli.LotNo,mli.MaterialCode,mm.MaterialName,mli.CurrentQty,
		mli.CompanyCode,mli.InitialQty,mli.ProductionDate,mli.CreateDateTime,mli.CreateUserID
	from STB_MaterialLotInfo mli with (nolock)
	left outer join STB_MaterialMaster mm with (nolock) on mli.MaterialCode=mm.MaterialCode
	where PackingID in (
			select  PackingID 
			from STB_MaterialLotInfo
			where  (LotNo in (@LotNo,	@LotNonew1,	@LotNonew2,	@LotNonew3,	@LotNonew4,	@LotNonew5,	@LotNonew6) or PackingID=@LotNo) 
			and CompanyCode='VVT' 
			and LotID not like 'ML%'

		)
     

END