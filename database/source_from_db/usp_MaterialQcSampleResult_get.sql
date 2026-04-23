
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-17
-- Browsable : true
-- Group : 품질관리 > [C530] 제품검사(Lot No) > 3번째 Grid
-- Description:	시료별수입검사 결과 테이블을 조회합니다.
-- Modified:
--  [usp_MaterialQcSampleResult_get] 'kilee2','Korean',,'VJLT193R850605',''

--exec usp_MaterialQcSampleResult_get '','','VVNM143R010703','19'

--select * from STB_MaterialQcDetail where MaterialQcNo='VVNM143R010703'

--select CompanyCode from STB_MaterialQcInfo WITH(NOLOCK) where materialqcno='VVNM143R010703'

--select *  FROM STB_LotChangeMaterialHistory WHERE NewBarcode ='VVNM143R010703'

--		select count(*) from STB_SDINFORBYLOT where lotno=@materialqcnooldvalue and attribute1 is null
--		select count(*) from Stb_ESRValueMonitor where lotno = @materialqcnooldvalue and UploadToMes is null
--		select count(*) from Stb_ESRValueMonitor where lotno = @materialqcnooldvalue and UploadOCVToMess is null
--usp_MaterialQcSampleResult_get'','','FVVOO123R825704',3
--usp_MaterialQcSampleResult_get'','','VVOO123R825704',2
--usp_MaterialQcSampleResult_get'','','VVOU183R060633',19
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialQcSampleResult_get] 
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialQcNo VARCHAR(20) = NULL,
    @pMaterialQcDetailNo VARCHAR(20) = NULL

WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialQcNo VARCHAR(20) = @pMaterialQcNo
	DECLARE @MaterialQcDetailNo VARCHAR(20) = @pMaterialQcDetailNo

    -- Loannt update 20210127 insert from table monitor sd to sample resulte
	DECLARE @PatternID varchar(20)
	DECLARE @PatternName varchar(100)
	DECLARE @LSL varchar(10)
	DECLARE @USL varchar(10)
	DECLARE @cnt numeric
	DECLARE @SampleQty numeric
	DECLARE @value varchar(20)
	DECLARE @value8 varchar(20)
	DECLARE @SampleNo numeric
	DECLARE @companycode varchar(10)
	DECLARE @cntexit varchar(10)
	DECLARE @cntexit1 varchar(10)
	DECLARE @cntexit2 varchar(10)
	DECLARE @cntinfor varchar(10)
	DECLARE @value1 int
	DECLARE @value2 int
	DECLARE @value7 int
	DECLARE @valueocv int

	DECLARE @materialqcnooldvalue varchar(20)
	DECLARE @value3 varchar(20)

	DECLARE @value4 numeric(20,5)
	DECLARE @value5 numeric(20,5)
	DECLARE @value6 numeric(20,5)
	 DECLARE @abc varchar(20)

	DECLARE @valueT1 varchar(10)
	DECLARE @valueT2 varchar(10)
	DECLARE @valueT3 varchar(10)

	-- position move
	select @companycode=CompanyCode from STB_MaterialQcInfo WITH(NOLOCK) where materialqcno=@pMaterialQcNo

	IF @companycode = 'VVT' BEGIN
		
		select @materialqcnooldvalue=OldBarCode  FROM STB_LotChangeMaterialHistory WHERE NewBarcode =@MaterialQcNo

		select @valueT1 =count(*) from STB_SDINFORBYLOT where lotno=@materialqcnooldvalue and attribute1 is null
		select @valueT2 = count(*) from Stb_ESRValueMonitor where lotno = @materialqcnooldvalue and UploadToMes is null
		select @valueT3 = count(*) from Stb_ESRValueMonitor where lotno = @materialqcnooldvalue and UploadOCVToMess is null

		if (@materialqcnooldvalue is not null and   @valueT1 > 0) or  (@materialqcnooldvalue is not null and @valueT2 > 0) or  (@materialqcnooldvalue is not null and @valueT3 > 0)

		begin 
			set @value3=@materialqcnooldvalue

		end
		else
		begin
			set @value3=@MaterialQcNo
		end
		if @materialqcnooldvalue is null
		begin
			set @value3=@MaterialQcNo
		end

		--if @materialqcnooldvalue is null
		--begin
		--	SELECT @value3=Barcode   FROM STB_SetInfo WHERE LotNumber=@MaterialQcNo
		--end
		--RAISERROR(@value3,16,1)


		--RAISERROR('khong',16,1)
			--	RAISERROR(@pMaterialQcDetailNo,16,1)
		--IQC_GPD_18 = SD IQC_GPD_20=DUNGLUONG
		select @cntexit =count(*) from STB_SDINFORBYLOT WITH(NOLOCK) where lotno=@value3 and attribute1 is null
		select @cntexit1 = count(*) from Stb_ESRValueMonitor WITH(NOLOCK) where lotno = @value3 and UploadToMes is null
		select @cntexit2 = count(*) from Stb_ESRValueMonitor WITH(NOLOCK) where lotno = @value3 and UploadOCVToMess is null
	END
	
	if(@companycode='VVT' and (@cntexit > 0 or @cntexit1 > 0 or @cntexit2 > 0))
	--if @cntexit > 0 or @cntexit1 > 0 or @cntexit2 > 0
	begin


		-- check value ok or not to update attribute='OK'
	 	

		
		 select @SampleQty=sampleQty,@PatternID=QcInspectionItemCode,@LSL=LSL,@USL=USL  from STB_MaterialQcDetail where MaterialQcNo=@MaterialQcNo and MaterialQcDetailNo=@pMaterialQcDetailNo
			
		if (@PatternID='IQC_GPD_20' or @PatternID='PQC_V01_09')
		--if (@pMaterialQcDetailNo = 20)
		begin
			select @value1=count(*) from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and (pattern like '%DUNGLUONG%' OR pattern like '%용량%')
			if(@value1 > 0)
			begin
				  delete top(@value1) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo and TestValue is null
				
			end
			set  @SampleQty = 3 
		end
		
		if (@PatternID='IQC_GPD_19' or @PatternID='PQC_V01_08')
		--if (@pMaterialQcDetailNo = 19)
		begin
			
	
			select @value7=count(*)  from Stb_ESRValueMonitor where lotno=@value3 and UploadToMes is null
			if(@value7 > 0 )
			begin
				
				  delete top(@value7) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo and TestValue is null
				 
			end
		set @SampleQty=20
		end


		if (@PatternID='PQC_V01_07' )
		--if (@pMaterialQcDetailNo = 19)
		begin
			
			
			select @valueocv=count(*)  from Stb_ESRValueMonitor where lotno=@value3 and UploadOCVToMess is null
			if(@valueocv > 0 )
			begin
				  delete top(@valueocv) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo and TestValue is null
				 
			end
		 set @SampleQty=20
		end


		
		if (@PatternID='IQC_GPD_18')
		--if (@pMaterialQcDetailNo = 18)
		begin

			
			select @value2=count(*)  from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and pattern like '%SD%' 
			if(@value2 > 0)
			begin
				  delete top(@value2) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo and TestValue is null
				
			end
		set @SampleQty=10
			
		end

		 select @cnt= count(*) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo

		--set @abc = CAST(@SampleQty as varchar(10))
		-- RAISERROR(@abc ,16,1)
		if (@PatternID='IQC_GPD_18' OR @PatternID='IQC_GPD_20' OR @PatternID='IQC_GPD_19' or  @PatternID='PQC_V01_09' or @PatternID='PQC_V01_08' or @PatternID='PQC_V01_07' )
		begin
			while @cnt < @SampleQty 
			begin

				
				select @SampleNo = COALESCE(max(materialqcsampleno),0) from STB_MaterialQcSampleResult where MaterialQcNo=@MaterialQcNo and MaterialQcDetailNo=@pMaterialQcDetailNo
					
					
						if (@PatternID='IQC_GPD_18')
						begin
							--RAISERROR('vaof' ,16,1)
							--select top(1) @value=sd  from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and pattern like '%SD%' 
							select top(1) @value=sd ,@value8=concat(substring(sd,0,CHARINDEX( '.', sd, 2)),substring(sd,CHARINDEX( '.', sd, 0),3) )   from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and pattern like '%SD%' 

						    select @cntinfor = count(*) from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and pattern like '%SD%' 
							
							if(@LSL <= @value and  @value <= @USL and @cntinfor > 0 )
							begin
							
								insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value8, DATEADD(HH, -2, GETDATE()),'system')
								update top(1) STB_SDINFORBYLOT set attribute1='OK'  where lotno=@value3 and attribute1 is null and pattern like '%SD%' and sd=@value
							end
							else begin
								update top(1) STB_SDINFORBYLOT set attribute1='FAIL'  where lotno=@value3 and attribute1 is null and pattern like '%SD%' and sd=@value
							end
						end


					if (@PatternID='IQC_GPD_20' or @PatternID='PQC_V01_09')
					begin

						select @value=capacity from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and (pattern like '%DUNGLUONG%' OR pattern like '%용량%')
						select @cntinfor = count(*) from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and (pattern like '%DUNGLUONG%' OR pattern like '%용량%')
	

						--RAISERROR(@LSL,16,1)
						--RAISERROR(@USL,16,1)
						--RAISERROR(@value,16,1)
						--RAISERROR(@cntinfor,16,1)
						set @value4 = @LSL
						set @value5 = @USL
						set @value6 = @value
						--if (@value4 <=@value6 and @value6<=@value5  and @cntinfor > 0 )
						
						begin	
						    
							insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value, DATEADD(HH, -2, GETDATE()),'system')
							update top(1) STB_SDINFORBYLOT set attribute1='OK'  where lotno=@value3 and attribute1 is null and (pattern like '%'+'DUNGLUONG'+'%' OR pattern like '%'+'용량'+'%') and capacity=@value
						end
						--else
						--begin
						--  -- RAISERROR(@cntinfor,16,1)
						--	update top(1) STB_SDINFORBYLOT set attribute1='FAIL'  where lotno=@value3 and attribute1 is null and (pattern like '%'+'DUNGLUONG'+'%' OR pattern like '%'+'용량'+'%') and capacity=@value
						--end
							

					end


					
					if (@PatternID='IQC_GPD_19'  or @PatternID='PQC_V01_08')
					begin
						select top(1) @value = value from Stb_ESRValueMonitor where lotno = @value3 and UploadToMes is null
						select @cntinfor = COUNT(*) from Stb_ESRValueMonitor  where lotno = @value3 and UploadToMes is null
						set @value4 = @LSL
						set @value5 = @USL
						set @value6 = @value
						
						if (@value4 <=@value6 and @value6<=@value5  and @cntinfor > 0 )
						begin
							insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value, DATEADD(HH, -2, GETDATE()),'system')
							update top(1) Stb_ESRValueMonitor set UploadToMes='OK' where lotno=@value3 and UploadToMes is null  and value =@value
						end
						else
							begin
								update top(1) Stb_ESRValueMonitor set UploadToMes='FAIL' where lotno=@value3 and UploadToMes is null and value = @value
							end

					end

						if (@PatternID='PQC_V01_07' )
					begin
						select top(1) @value = valueocv from Stb_ESRValueMonitor where lotno = @value3 and UploadOCVToMess is null
						select @cntinfor = COUNT(*) from Stb_ESRValueMonitor  where lotno = @value3 and UploadOCVToMess is null
						set @value4 = @LSL
						set @value5 = @USL
						set @value6 = @value
						
						if (@value4 <=@value6 and @value6<=@value5  and @cntinfor > 0 )
						begin
							insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value, DATEADD(HH, -2, GETDATE()),'system')
							update top(1) Stb_ESRValueMonitor set UploadOCVToMess='OK' where lotno=@value3 and UploadOCVToMess is null  and valueocv =@value
							--RAISERROR(@valueocv,16,1)
						end
						else
							begin
								update top(1) Stb_ESRValueMonitor set UploadOCVToMess='FAIL' where lotno=@value3 and UploadOCVToMess is null and valueocv = @value
							end

					end
									
				SET @cnt = @cnt + 1;
				--select @cnt= count(*) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo
			
				--SET @value=0;
			end
		end
   end 

	SELECT
			MQSR.MaterialQcNo AS OldMaterialIqcNo,
			MQSR.MaterialQcDetailNo AS OldMaterialIqcDetailNo,
			MQSR.MaterialQcSampleNo AS OldMaterialIqcSampleNo,
			MQSR.MaterialQcNo,
			MQSR.MaterialQcDetailNo,
			MQSR.MaterialQcSampleNo,
			MQSR.SampleSerialNo,
			MQSR.TestUserID,
			MQSR.TestDateTime,
			MQSR.TestValue,
			MQSR.TestResult,
			MQSR.CreateDateTime,
			MQSR.CreateUserID,
			MQSR.ChangeDateTime,
			MQSR.ChangeUserID,
			MQD.LSL,
			MQD.USL,
			MQD.QcInspectionItemDesc           --2020.02.15 추가			
	FROM STB_MaterialQcSampleResult MQSR WITH(NOLOCK)
	LEFT OUTER JOIN STB_MaterialQcDetail MQD WITH(NOLOCK)	  
		ON MQSR.MaterialQcNo = MQD.MaterialQcNo	 
		AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
	WHERE MQSR.MaterialQcNo = @MaterialQcNo
		AND MQSR.MaterialQcDetailNo = @MaterialQcDetailNo
	ORDER BY MQSR.MaterialQcSampleNo
END
