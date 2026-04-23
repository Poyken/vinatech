
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-17
-- Browsable : true
-- Group : 품질관리 > [C530] 제품검사(Lot No) > 3번째 Grid
-- Description:	시료별수입검사 결과 테이블을 조회합니다.
-- Modified:
-- =============================================
--exec usp_UpdateMaterialQcSampleResult 'VVLJ303R010620',18

CREATE PROCEDURE [dbo].[usp_UpdateMaterialQcSampleResult]
    @pMaterialQcNo VARCHAR(20) = NULL,
    @pMaterialQcDetailNo VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialQcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END
	DECLARE @MaterialQcDetailNo VARCHAR(20) = @pMaterialQcDetailNo
	DECLARE @PatternID varchar(20)
	DECLARE @PatternName varchar(100)
	DECLARE @LSL varchar(10)
	DECLARE @USL varchar(10)
	DECLARE @cnt numeric
	DECLARE @SampleQty numeric
	DECLARE @value varchar(20)
	DECLARE @SampleNo numeric
	DECLARE @companycode varchar(10)
	DECLARE @cntinfor varchar(10)
	DECLARE @cntexit numeric

    --IQC_GPD_18 = SD IQC_GPD_20=DUNGLUONG
	select @companycode=CompanyCode from STB_MaterialQcInfo where materialqcno=@pMaterialQcNo
	select @cntexit =count(*) from STB_SDINFORBYLOT where lotno=@MaterialQcNo and attribute1 is null
	if(@companycode='VVT' and @cntexit > 0)
	begin
		
		-- check value ok or not to update attribute='OK'

		delete  from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo and TestValue is null

		select @cnt= count(*) 
		from STB_MaterialQcSampleResult  
		where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo

		select @SampleQty=sampleQty,@PatternID=QcInspectionItemCode,@LSL=LSL,@USL=USL  from STB_MaterialQcDetail where MaterialQcNo=@MaterialQcNo and MaterialQcDetailNo=@pMaterialQcDetailNo

		if (@PatternID='IQC_GPD_18' OR @PatternID='IQC_GPD_20')
		begin
			while @cnt < @SampleQty 
			begin

				
				select @SampleNo = COALESCE(max(materialqcsampleno),0) from STB_MaterialQcSampleResult where MaterialQcNo=@MaterialQcNo and MaterialQcDetailNo=@pMaterialQcDetailNo
				select @cntinfor = lotno from STB_SDINFORBYLOT where lotno=@MaterialQcNo and attribute1 is null and pattern like '%SD%' 
			
					
					if (@cntinfor is not null )
					begin
						
						if (@PatternID='IQC_GPD_18')
						begin
							select top(1) @value=SD   from STB_SDINFORBYLOT where lotno=@MaterialQcNo and attribute1 is null and pattern like '%SD%' 
						
							if(@LSL <= @value and  @value <= @USL )
							begin
							
								insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value, DATEADD(HH, -2, GETDATE()),'system')
								update top(1) STB_SDINFORBYLOT set attribute1='OK'  where lotno=@MaterialQcNo and attribute1 is null and pattern like '%SD%' and sd=@value
							end
							else begin
								update top(1) STB_SDINFORBYLOT set attribute1='FAIL'  where lotno=@MaterialQcNo and attribute1 is null and pattern like '%SD%' and sd=@value
							end
					end

					end

					if (@PatternID='IQC_GPD_20')
					begin
						select @value=capacity from STB_SDINFORBYLOT where lotno=@MaterialQcNo and attribute1 is null and (pattern like '%DUNGLUONG%' OR pattern like '%용량%')
						if(@LSL <= @value and  @value <= @USL)
						begin	
							insert into STB_MaterialQcSampleResult(MaterialQCNo, MaterialQCDetailNo,materialqcsampleno, testvalue,createdatetime, CreateUserID ) values(@MaterialQcNo,@pMaterialQcDetailNo,@SampleNo+1,@value, DATEADD(HH, -2, GETDATE()),'system')
							update top(1) STB_SDINFORBYLOT set attribute1='OK'  where lotno=@MaterialQcNo and attribute1 is null and (pattern like '%'+'DUNGLUONG'+'%' OR pattern like '%'+'용량'+'%') and capacity=@value
						end
						else
						begin
							update top(1) STB_SDINFORBYLOT set attribute1='FAIL'  where lotno=@MaterialQcNo and attribute1 is null and (pattern like '%'+'DUNGLUONG'+'%' OR pattern like '%'+'용량'+'%') and capacity=@value
						end
							

					end
				
				--SET @cnt = @cnt + 1;
				select @cnt= count(*) from STB_MaterialQcSampleResult  where MaterialQcNo=@pMaterialQcNo and MaterialQcDetailNo = @pMaterialQcDetailNo
			
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
	FROM
	        STB_MaterialQcSampleResult MQSR WITH(NOLOCK)
	LEFT OUTER JOIN STB_MaterialQcDetail MQD	  ON MQSR.MaterialQcNo = MQD.MaterialQcNo	 AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
	WHERE
	        ((@pMaterialQcNo = '*') OR (MQSR.MaterialQcNo = @pMaterialQcNo)) AND
	        (MQSR.MaterialQcDetailNo = @pMaterialQcDetailNo)
    ORDER BY MQSR.MaterialQcSampleNo
END