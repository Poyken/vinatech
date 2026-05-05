
-- =============================================
-- Author : Kangs(kilee@vina.co.kr)
-- Create date: 2021-05-13
-- Browsable : true
-- Group : PowerBI용 (박진호 요청)
-- Description:	시료별수입검사 하단 검사항목과 측정값을 보여줍니다.

-- Modified: 상단의 수입검사번호와 시료별 수입검사항목의 QcDetailNo을 
-- Procedure :   usp_MaterialQcSampleResult_PowerBI
-- ==============================================================
Create PROCEDURE [dbo].[usp_MaterialQcSampleResult_PowerBI_Backup]
	--@pProcessUserID VARCHAR(20),
	--@pProcessLanguage VARCHAR(20)
 --   @pMaterialQcNo VARCHAR(20) = NULL
  --  @pMaterialQcDetailNo VARCHAR(20) = NULL
AS


BEGIN
	SET NOCOUNT ON;
	
	--DECLARE @MaterialQcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END
	--DECLARE @MaterialQcDetailNo VARCHAR(20) = @pMaterialQcDetailNo

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
	DECLARE @cntinfor varchar(10)
	DECLARE @value1 int
	DECLARE @value2 int
	DECLARE @value7 int
	DECLARE @materialqcnooldvalue varchar(20)
	DECLARE @value3 varchar(20)

	DECLARE @value4 numeric(20,5)
	DECLARE @value5 numeric(20,5)
	DECLARE @value6 numeric(20,5)


	DECLARE @valueT1 varchar(10)
	DECLARE @valueT2 varchar(10)

	--select @materialqcnooldvalue=OldBarCode  FROM STB_LotChangeMaterialHistory WHERE NewBarcode =@MaterialQcNo

	--select @valueT1 =count(*) from STB_SDINFORBYLOT where lotno=@materialqcnooldvalue and attribute1 is null
	--select @valueT2 = count(*) from Stb_ESRValueMonitor where lotno = @materialqcnooldvalue and UploadToMes is null


	--if (@materialqcnooldvalue is not null and   @valueT1 > 0) or  (@materialqcnooldvalue is not null and @valueT2 > 0)

	--begin 
	--	set @value3=@materialqcnooldvalue

	--end
	--else
	--begin
	--	set @value3=@MaterialQcNo
	--end
	--if @materialqcnooldvalue is null
	--begin
	--	set @value3=@MaterialQcNo
	--end



	--		RAISERROR(@pMaterialQcNo,16,1)
    --IQC_GPD_18 = SD IQC_GPD_20=DUNGLUONG
	--select @companycode=CompanyCode from STB_MaterialQcInfo where materialqcno=@pMaterialQcNo
	select @cntexit =count(*) from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null
	select @cntexit1 = count(*) from Stb_ESRValueMonitor where lotno = @value3 and UploadToMes is null

	if(@companycode='VVT' and (@cntexit > 0 or @cntexit1 > 0))
	begin
		-- check value ok or not to update attribute='OK'
		
		--if (@pMaterialQcDetailNo = 20)
		--begin
		--	select @value1=count(*) from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and (pattern like '%DUNGLUONG%' OR pattern like '%용량%')
		--	if(@value1 > 0)
		--	begin
		--		  delete top(@value1) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo and TestValue is null
		--	end
		--end

		--if (@pMaterialQcDetailNo = 19)
		--begin
		--	select @value7=count(*)  from Stb_ESRValueMonitor where lotno=@value3 and UploadToMes is null
		--	if(@value7 > 0)
		--	begin
		--		  delete top(@value7) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo and TestValue is null
		--	end
		--end
		

		--if (@pMaterialQcDetailNo = 18)
		--begin

		--	select @value2=count(*)  from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and pattern like '%SD%' 
		--	if(@value2 > 0)
		--	begin
		--		  delete top(@value2) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo and TestValue is null
		--	end
		--end



		--select @cnt= count(*) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo

		--select @SampleQty=sampleQty,@PatternID=QcInspectionItemCode,@LSL=LSL,@USL=USL  from STB_MaterialQcDetail where MaterialQcNo=@MaterialQcNo and MaterialQcDetailNo=@pMaterialQcDetailNo

		--if (@PatternID='IQC_GPD_18' OR @PatternID='IQC_GPD_20' OR @PatternID='IQC_GPD_19' )
		--begin
		--	while @cnt < @SampleQty 
		--	begin

				
		--		select @SampleNo = COALESCE(max(materialqcsampleno),0) from STB_MaterialQcSampleResult where MaterialQcNo=@MaterialQcNo and MaterialQcDetailNo=@pMaterialQcDetailNo
					
					
						if (@PatternID='IQC_GPD_18')
						begin
							--select top(1) @value=sd  from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and pattern like '%SD%' 
							select top(1) @value=sd ,@value8=concat(substring(sd,0,CHARINDEX( '.', sd, 2)),substring(sd,CHARINDEX( '.', sd, 0),3) )   from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and pattern like '%SD%' 

						    select @cntinfor = count(*) from STB_SDINFORBYLOT where lotno=@value3 and attribute1 is null and pattern like '%SD%' 
							
							if(@LSL <= @value and  @value <= @USL and @cntinfor > 0 )
						--	begin
							
						--		insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value8, DATEADD(HH, -2, GETDATE()),'system')
						--		update top(1) STB_SDINFORBYLOT set attribute1='OK'  where lotno=@value3 and attribute1 is null and pattern like '%SD%' and sd=@value
						--	end
						--	else begin
						--		update top(1) STB_SDINFORBYLOT set attribute1='FAIL'  where lotno=@value3 and attribute1 is null and pattern like '%SD%' and sd=@value
						--	end
						--end


					if (@PatternID='IQC_GPD_20')
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
						
						--begin	
						    
						--	insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value, DATEADD(HH, -2, GETDATE()),'system')
						--	update top(1) STB_SDINFORBYLOT set attribute1='OK'  where lotno=@value3 and attribute1 is null and (pattern like '%'+'DUNGLUONG'+'%' OR pattern like '%'+'용량'+'%') and capacity=@value
						--end


						

					end


					
					if (@PatternID='IQC_GPD_19')
					begin
						select top(1) @value = value from Stb_ESRValueMonitor where lotno = @value3 and UploadToMes is null
						select @cntinfor = COUNT(*) from Stb_ESRValueMonitor  where lotno = @value3 and UploadToMes is null
						set @value4 = @LSL
						set @value5 = @USL
						set @value6 = @value
						
					--	if (@value4 <=@value6 and @value6<=@value5  and @cntinfor > 0 )
					--	begin
					--		insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value, DATEADD(HH, -2, GETDATE()),'system')
					--		update top(1) Stb_ESRValueMonitor set UploadToMes='OK' where lotno=@value3 and UploadToMes is null  and value =@value
					--	end
					--	else
					--		begin
					--			update top(1) Stb_ESRValueMonitor set UploadToMes='FAIL' where lotno=@value3 and UploadToMes is null and value = @value
					--		end

					--end
					
				
				SET @cnt = @cnt + 1;
				--select @cnt= count(*) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo
			
				--SET @value=0;
			end
		end
   end


   -- 이부분이 핵심
	SELECT
	         MQI.MaterialCode,
			 MQI.CompanyCode,
			  Case When MQI.CompanyCode = 'VNT' Then '한국본사'
			          When MQI.CompanyCode = 'VVT' Then '베트남법인' Else '기타' End AS CompanyName , 
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
			MQD.QcInspectionItemDesc      
		   , MQD.QcInspectionItemCode 
		      , MQD.QcInspectionGroupName
		  
	FROM                       STB_MaterialQcSampleResult MQSR WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MaterialQcDetail MQD	  ON MQSR.MaterialQcNo = MQD.MaterialQcNo	 AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
	    	LEFT OUTER JOIN     STB_MaterialQcInfo MQI  ON MQI.MaterialQcNo = MQSR.MaterialQcNo 
	WHERE 1=1
	--   AND  ((@pMaterialQcNo = '*') OR (MQSR.MaterialQcNo = @pMaterialQcNo)) 
	  -- AND  (MQSR.MaterialQcDetailNo = @pMaterialQcDetailNo)
	     and MQD.QcInspectionGroupCode in ('IQC_G01','IQC_G03','IQC_G05','IQC_G02', 'IQC_G09')
	   and MQD.CreateDateTime > '2021-01-01 00:00:00'
	   
    ORDER BY MQSR.MaterialQcSampleNo


END

/*
select * from STB_MaterialQcDetail where MaterialQcNo = '21051200004'




*/