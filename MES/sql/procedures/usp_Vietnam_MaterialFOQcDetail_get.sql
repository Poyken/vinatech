USE [SmartFactoryV2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-17
-- Browsable : true
-- Group : 품질관리 > 시료별수입검사 & 시료별입고검사 > 2번째 Grid화면
--            품질관리 > 제품검사 > 2번째 Grid
-- Description:	Outgoing QC (FOQC) Detail retrieval and initialization
-- Modified: 
--  vanduc 2026-06-04: Fixed missing block for DetailNo = 2 (OCV) to ensure 50 sample result rows are pre-created for manual or automatic population.
-- =======================================================================================================================
ALTER PROCEDURE [dbo].[usp_Vietnam_MaterialFOQcDetail_get]
								@pProcessUserID VARCHAR(20),
								@pProcessLanguage VARCHAR(20),
								@pMaterialQcNo VARCHAR(20) = 'MaterialQcNo' 
AS

BEGIN

	SET NOCOUNT ON;
	
	DECLARE @MaterialQcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END
	--DECLARE @Barcode         VARCHAR(20) 
	
	DECLARE @FoqcMaterialQcNo VARCHAR(20)
	declare @MaterialCode VARCHAR(50)
	

	DECLARE @LotNonew1 VARCHAR(20) = ''
	DECLARE @LotNonew2 VARCHAR(20) = ''
	DECLARE @LotNonew3 VARCHAR(20) = ''
	DECLARE @LotNonew4 VARCHAR(20) = ''
	DECLARE @LotNonew5 VARCHAR(20) = ''
	DECLARE @LotNonew6 VARCHAR(20) = ''
	select @LotNonew1 = NewBarcode
	from STB_LotChangeMaterialHistory  WITH(NOLOCK)
	where OldBarcode=@MaterialQcNo 
	
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

	select @MaterialCode = materialcode,@MaterialQcNo=barcode
	from STB_SetInfo si with(nolock)
	where barcode in (@pMaterialQcNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew6)

	   	
	if(@MaterialQcNo like 'F%') 
	begin
		 select @FoqcMaterialQcNo  = @MaterialQcNo 
		 select @MaterialQcNo  = stuff(@MaterialQcNo,1,1,'' )
	end

	DECLARE @CharFOQC VARCHAR(1)='F';
	if(@MaterialQcNo not like 'F%') 
	begin
		 select @FoqcMaterialQcNo  = @CharFOQC + @MaterialQcNo 
	end


	DECLARE @sumSampleQty numeric(20,5) = 20
	DECLARE @cCount INT
	
	declare @tung varchar(100) = @MaterialQcNo + '-----' + @FoqcMaterialQcNo


	SELECT  @cCount = count(*)
	  FROM STB_MaterialQcInfo WITH(NOLOCK) 
	 WHERE MaterialQcNo =  (case when @FoqcMaterialQcNo like 'FM%' then 'VVLM063R010620' else @MaterialQcNo end) -- if MODULE product then use again: FVVLM063R010620
	 and (DecisionResult='Pass' or DecisionResult='PASS')
	

	 if(@cCount>0)
	 begin			
	 	 
	 	--check   STB_MaterialQcinfo   table
			SELECT  @cCount = count(*)
			FROM STB_MaterialQcInfo WITH(NOLOCK) 
			WHERE MaterialQcNo =  @FoqcMaterialQcNo

			if(@cCount=0)
			 begin
			 	 select @tung= @tung +'.1'

				  insert into STB_MaterialQcinfo (
				   MaterialQcNo, CompanyCode, WorkCenterCode, InspectionDocType,MaterialCode, 
					QcQty, InspectionType,  BasicDate, TargetSampleQty, ActualSampleQty, DestoryInspectionQty,  ProcessQty, 
					MaxAcceptDefectQty, PassedSampleQty, DefectSampleQty,  DecisionResult,  DecisionDateTime, DecisionUserID, 
					SpecialAcceptDesc, DescText, VendorQcReport, VendorLotNo, MIIExtText01, MIIExtText02, MIIExtText03, 
					MIIExtText04, MIIExtText05, CreateDateTime,  CreateUserID, ChangeDateTime, ChangeUserID, IQCSampleLotList
				  )
					SELECT @FoqcMaterialQcNo as MaterialQcNo, CompanyCode, WorkCenterCode, 'FOQC' as InspectionDocType, 
					(case when @FoqcMaterialQcNo like 'FM%' then '' else MaterialCode end) as MaterialCode, 
					QcQty, InspectionType, convert(date,getdate(),120) as BasicDate, TargetSampleQty, ActualSampleQty, DestoryInspectionQty, 0 as ProcessQty, 
					MaxAcceptDefectQty, PassedSampleQty, DefectSampleQty, NULL as DecisionResult, NULL as DecisionDateTime, NULL as DecisionUserID, 
					SpecialAcceptDesc, DescText, VendorQcReport, VendorLotNo, NULL as MIIExtText01, MIIExtText02, MIIExtText03, 
					MIIExtText04, MIIExtText05, getdate() as CreateDateTime, @pProcessUserID as CreateUserID, NULL as ChangeDateTime, NULL as ChangeUserID, IQCSampleLotList
					FROM
							STB_MaterialQcInfo WITH(NOLOCK) 
					WHERE
							MaterialQcNo = (case when @FoqcMaterialQcNo like 'FM%' then 'VVLM063R010620' else @MaterialQcNo end) -- if MODULE product then use again: FVVLM063R010620 
			end
			
		--check   STB_MaterialQcDetail   table
			SELECT  @cCount = count(*)
			FROM STB_MaterialQcDetail WITH(NOLOCK) 
			WHERE MaterialQcNo =  @FoqcMaterialQcNo

			if(@cCount=0)
			 begin

			 	select @tung= @tung +'.2'

			  insert into STB_MaterialQcDetail 
				( MaterialQcNo,MaterialQcDetailNo,QcInspectionGroupCode,QcInspectionGroupName,
				QcInspectionGroupDesc,QcInspectionItemCode,QcInspectionItemName,QcInspectionItemDesc,
				GroupInspectionPrior,GroupReportPrior,ItemInspectionPrior, ItemReportPrior, QcSpecDesc, 
				InspectionType, IsMaterialSpec, InspectionLevel, AQL,RequestSampleQty, MaxAcceptDefectQty,
				SampleQty, PassedSampleQty, DefectSampleQty, SkipSampleQty, SpecValue,USL,LSL,UCL, LCL, 
				TextSpecValue,DecisionResult,CreateDateTime,CreateUserID, ChangeDateTime, ChangeUserID
				) 
				select 	 @FoqcMaterialQcNo as MaterialQcNo, 19 as  MaterialQcDetailNo, 'FOQC_GPD' as QcInspectionGroupCode, 
				'FOQC검사' as QcInspectionGroupName, N'Kiểm tra FOQC' as QcInspectionGroupDesc, 
				'FOQC_GPD_19' as QcInspectionItemCode, QcInspectionItemName, QcInspectionItemDesc, GroupInspectionPrior, GroupReportPrior, 
				ItemInspectionPrior, ItemReportPrior, QcSpecDesc, InspectionType, IsMaterialSpec, InspectionLevel, AQL, 
				20 as RequestSampleQty, MaxAcceptDefectQty, 20 as SampleQty, PassedSampleQty, DefectSampleQty, SkipSampleQty, SpecValue, 
				(case when @FoqcMaterialQcNo like 'FM%' then 500 else USL end) as USL, 
				(case when @FoqcMaterialQcNo like 'FM%' then 0 else LSL end) as LSL, 
				UCL, LCL, TextSpecValue, NULL as DecisionResult, getdate() as CreateDateTime, 
				@pProcessUserID as CreateUserID, ChangeDateTime, ChangeUserID
				from
						STB_MaterialQcDetail WITH(NOLOCK) 
				WHERE
						MaterialQcNo =  (case when @FoqcMaterialQcNo like 'FM%' then 'VVLM063R010620' else @MaterialQcNo end) -- if MODULE product then use again: FVVLM063R010620  
						and  QcInspectionItemCode = 'IQC_GPD_19' 	
						

					  insert into STB_MaterialQcDetail 
				( MaterialQcNo,MaterialQcDetailNo,QcInspectionGroupCode,QcInspectionGroupName,
				QcInspectionGroupDesc,QcInspectionItemCode,QcInspectionItemName,QcInspectionItemDesc,
				GroupInspectionPrior,GroupReportPrior,ItemInspectionPrior, ItemReportPrior, QcSpecDesc, 
				InspectionType, IsMaterialSpec, InspectionLevel, AQL,RequestSampleQty, MaxAcceptDefectQty,
				SampleQty, PassedSampleQty, DefectSampleQty, SkipSampleQty, SpecValue,USL,LSL,UCL, LCL, 
				TextSpecValue,DecisionResult,CreateDateTime,CreateUserID, ChangeDateTime, ChangeUserID
				) 
				select 	 @FoqcMaterialQcNo as MaterialQcNo,  MaterialQcDetailNo, 'FOQC_GPD' as QcInspectionGroupCode, 
				'FOQC검사' as QcInspectionGroupName, N'Kiểm tra FOQC' as QcInspectionGroupDesc, 
				 replace(QcInspectionItemCode,'PQC','FOQC'), QcInspectionItemName, QcInspectionItemDesc, GroupInspectionPrior, GroupReportPrior, 
				ItemInspectionPrior, ItemReportPrior, QcSpecDesc, InspectionType, IsMaterialSpec, InspectionLevel, AQL, 
				50 as RequestSampleQty, MaxAcceptDefectQty, 50 as SampleQty, PassedSampleQty, DefectSampleQty, SkipSampleQty, SpecValue, 
				(case when @FoqcMaterialQcNo like 'FM%' then 500 else USL end) as USL, 
				(case when @FoqcMaterialQcNo like 'FM%' then 0 else LSL end) as LSL, 
				UCL, LCL, TextSpecValue, NULL as DecisionResult, getdate() as CreateDateTime, 
				@pProcessUserID as CreateUserID, ChangeDateTime, ChangeUserID
				from
						STB_MaterialQcDetail WITH(NOLOCK) 
				WHERE
						MaterialQcNo =  (case when @FoqcMaterialQcNo like 'FM%' then 'VVLM063R010620' else @MaterialQcNo end) -- if MODULE product then use again: FVVLM063R010620  
						and  QcInspectionItemCode ='PQC_V01_07'


									  insert into STB_MaterialQcDetail 
				( MaterialQcNo,MaterialQcDetailNo,QcInspectionGroupCode,QcInspectionGroupName,
				QcInspectionGroupDesc,QcInspectionItemCode,QcInspectionItemName,QcInspectionItemDesc,
				GroupInspectionPrior,GroupReportPrior,ItemInspectionPrior, ItemReportPrior, QcSpecDesc, 
				InspectionType, IsMaterialSpec, InspectionLevel, AQL,RequestSampleQty, MaxAcceptDefectQty,
				SampleQty, PassedSampleQty, DefectSampleQty, SkipSampleQty, SpecValue,USL,LSL,UCL, LCL, 
				TextSpecValue,DecisionResult,CreateDateTime,CreateUserID, ChangeDateTime, ChangeUserID
				) 
				select 	 @FoqcMaterialQcNo as MaterialQcNo,  MaterialQcDetailNo, 'FOQC_GPD' as QcInspectionGroupCode, 
				'FOQC검사' as QcInspectionGroupName, N'Kiểm tra FOQC' as QcInspectionGroupDesc, 
				 replace(QcInspectionItemCode,'PQC','FOQC'), QcInspectionItemName, QcInspectionItemDesc, GroupInspectionPrior, GroupReportPrior, 
				ItemInspectionPrior, ItemReportPrior, QcSpecDesc, InspectionType, IsMaterialSpec, InspectionLevel, AQL, 
				50 as RequestSampleQty, MaxAcceptDefectQty, 50 as SampleQty, PassedSampleQty, DefectSampleQty, SkipSampleQty, SpecValue, 
				(case when @FoqcMaterialQcNo like 'FM%' then 500 else USL end) as USL, 
				(case when @FoqcMaterialQcNo like 'FM%' then 0 else LSL end) as LSL, 
				UCL, LCL, TextSpecValue, NULL as DecisionResult, getdate() as CreateDateTime, 
				@pProcessUserID as CreateUserID, ChangeDateTime, ChangeUserID
				from
						STB_MaterialQcDetail WITH(NOLOCK) 
				WHERE
						MaterialQcNo =  (case when @FoqcMaterialQcNo like 'FM%' then 'VVLM063R010620' else @MaterialQcNo end) -- if MODULE product then use again: FVVLM063R010620  
						and  QcInspectionItemCode ='PQC_V01_08'

		    end

			--check count stop khi du 20
			--check max + 1 cho du 20
		  declare @MaterialQcSampleNo1 INT = (select COUNT(MaterialQcSampleNo) from STB_MaterialQcSampleResult  WITH(NOLOCK) where MaterialQcDetailNo=19 and MaterialQcNo=@FoqcMaterialQcNo) + 1

		  declare @sampleqty int = (select sampleqty from  STB_MaterialQcDetail where MaterialQcDetailNo=19 and MaterialQcNo=@FoqcMaterialQcNo)

		  WHILE @MaterialQcSampleNo1 <= @sampleqty
			BEGIN						
			select @tung= @tung +'.3'	
			 insert into STB_MaterialQcSampleResult
			 ( 
			 MaterialQcNo, MaterialQcDetailNo, MaterialQcSampleNo, SampleSerialNo, TestUserID, TestDateTime, 
			 TestValue, TestResult, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID
			 )
			 values (
			 @FoqcMaterialQcNo, 19, (select isnull(MAX(MaterialQcSampleNo),0) from STB_MaterialQcSampleResult  WITH(NOLOCK) where MaterialQcDetailNo=19 and MaterialQcNo=@FoqcMaterialQcNo) + 1 , 
			 NULL, NULL, NULL, NULL, NULL, getdate(), @pProcessUserID, NULL, NULL
			 )
			 SELECT @MaterialQcSampleNo1 = (select COUNT(MaterialQcSampleNo) from STB_MaterialQcSampleResult  WITH(NOLOCK) where MaterialQcDetailNo=19 and MaterialQcNo=@FoqcMaterialQcNo) + 1
		  END

		  -- vanduc 2026-06-04: Fixed missing block for DetailNo = 2 (OCV) to ensure 50 sample result rows are pre-created for manual or automatic population
		  set @MaterialQcSampleNo1  = (select COUNT(MaterialQcSampleNo) from STB_MaterialQcSampleResult  WITH(NOLOCK) where MaterialQcDetailNo=2 and MaterialQcNo=@FoqcMaterialQcNo) + 1

		  set @sampleqty  = (select sampleqty from  STB_MaterialQcDetail where MaterialQcDetailNo=2 and MaterialQcNo=@FoqcMaterialQcNo)

		  WHILE @MaterialQcSampleNo1 <= @sampleqty
			BEGIN						
			select @tung= @tung +'.3'	
			 insert into STB_MaterialQcSampleResult
			 ( 
			 MaterialQcNo, MaterialQcDetailNo, MaterialQcSampleNo, SampleSerialNo, TestUserID, TestDateTime, 
			 TestValue, TestResult, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID
			 )
			 values (
			 @FoqcMaterialQcNo, 2, (select isnull(MAX(MaterialQcSampleNo),0) from STB_MaterialQcSampleResult  WITH(NOLOCK) where MaterialQcDetailNo=2 and MaterialQcNo=@FoqcMaterialQcNo) + 1 , 
			 NULL, NULL, NULL, NULL, NULL, getdate(), @pProcessUserID, NULL, NULL
			 )
			 SELECT @MaterialQcSampleNo1 = (select COUNT(MaterialQcSampleNo) from STB_MaterialQcSampleResult  WITH(NOLOCK) where MaterialQcDetailNo=2 and MaterialQcNo=@FoqcMaterialQcNo) + 1
		  END

		  -- ESR Block (DetailNo = 3)
		  set @MaterialQcSampleNo1  = (select COUNT(MaterialQcSampleNo) from STB_MaterialQcSampleResult  WITH(NOLOCK) where MaterialQcDetailNo=3 and MaterialQcNo=@FoqcMaterialQcNo) + 1

		  set @sampleqty  = (select sampleqty from  STB_MaterialQcDetail where MaterialQcDetailNo=3 and MaterialQcNo=@FoqcMaterialQcNo)

		  WHILE @MaterialQcSampleNo1 <= @sampleqty
			BEGIN						
			select @tung= @tung +'.3'	
			 insert into STB_MaterialQcSampleResult
			 ( 
			 MaterialQcNo, MaterialQcDetailNo, MaterialQcSampleNo, SampleSerialNo, TestUserID, TestDateTime, 
			 TestValue, TestResult, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID
			 )
			 values (
			 @FoqcMaterialQcNo, 3, (select isnull(MAX(MaterialQcSampleNo),0) from STB_MaterialQcSampleResult  WITH(NOLOCK) where MaterialQcDetailNo=3 and MaterialQcNo=@FoqcMaterialQcNo) + 1 , 
			 NULL, NULL, NULL, NULL, NULL, getdate(), @pProcessUserID, NULL, NULL
			 )
			 SELECT @MaterialQcSampleNo1 = (select COUNT(MaterialQcSampleNo) from STB_MaterialQcSampleResult  WITH(NOLOCK) where MaterialQcDetailNo=3 and MaterialQcNo=@FoqcMaterialQcNo) + 1
		  END


		  -- DetailNo = 4 Block
		  set @MaterialQcSampleNo1  = (select COUNT(MaterialQcSampleNo) from STB_MaterialQcSampleResult  WITH(NOLOCK) where MaterialQcDetailNo=4 and MaterialQcNo=@FoqcMaterialQcNo) + 1

		  set @sampleqty  = (select sampleqty from  STB_MaterialQcDetail where MaterialQcDetailNo=4 and MaterialQcNo=@FoqcMaterialQcNo)

		  WHILE @MaterialQcSampleNo1 <= @sampleqty
			BEGIN						
			select @tung= @tung +'.3'	
			 insert into STB_MaterialQcSampleResult
			 ( 
			 MaterialQcNo, MaterialQcDetailNo, MaterialQcSampleNo, SampleSerialNo, TestUserID, TestDateTime, 
			 TestValue, TestResult, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID
			 )
			 values (
			 @FoqcMaterialQcNo, 4, (select isnull(MAX(MaterialQcSampleNo),0) from STB_MaterialQcSampleResult  WITH(NOLOCK) where MaterialQcDetailNo=4 and MaterialQcNo=@FoqcMaterialQcNo) + 1 , 
			 NULL, NULL, NULL, NULL, NULL, getdate(), @pProcessUserID, NULL, NULL
			 )
			 SELECT @MaterialQcSampleNo1 = (select COUNT(MaterialQcSampleNo) from STB_MaterialQcSampleResult  WITH(NOLOCK) where MaterialQcDetailNo=4 and MaterialQcNo=@FoqcMaterialQcNo) + 1
		  END

		 

	 end	 


	
	if(@pProcessUserID='nguyentung') begin	
		select @tung= @tung +'.4'	
	end


	SELECT
			MQD.MaterialQcNo AS OldMaterialIqcNo,
			MQD.MaterialQcDetailNo AS OldMaterialIqcDetailNo,
			MQD.MaterialQcNo,
			MQD.MaterialQcDetailNo,
			MQD.QcInspectionGroupCode,
			MQD.QcInspectionGroupName,
			MQD.QcInspectionGroupDesc,
			MQD.QcInspectionItemCode,
			MQD.QcInspectionItemName,
			MQD.QcInspectionItemDesc,
			MQD.GroupInspectionPrior,
			MQD.GroupReportPrior,
			MQD.ItemInspectionPrior,
			MQD.ItemReportPrior,
			MQD.QcSpecDesc,
			MQD.InspectionType,
			MQD.IsMaterialSpec,
			MQD.InspectionLevel,
			MQD.AQL,
			MQD.RequestSampleQty,
			MQD.MaxAcceptDefectQty,
			MQD.SampleQty as SampleQty, --Vietnam FOQC check 20 value of ESR
			--CASE WHEN ISNULL(MQD.SampleQty, 0) > 0 THEN MQD.SampleQty ELSE MQD.RequestSampleQty END  AS SampleQty,       --2019.03.28 kilee (대상샘플수량과 샘플수량 동일하게)
			--CASE WHEN MQD.QcInspectionItemCode = 'IQC_GPD_20' THEN 10 ELSE MQD.SampleQty END AS SampleQty,
			MQD.PassedSampleQty,
			MQD.DefectSampleQty,
			MQD.SkipSampleQty,
			MQD.SpecValue,
			MQD.USL,
			--Case When MQD.USL is null then 10000 Else MQD.USL End AS USL, -- 박진호 대리요청 (2020-07-15)
			MQD.LSL,
			MQD.UCL,
			MQD.LCL,
			MQD.TextSpecValue,
			MQD.DecisionResult,
			MQD.CreateDateTime,
			MQD.CreateUserID,
			MQD.ChangeDateTime,
			MQD.ChangeUserID
	FROM  STB_MaterialQcDetail MQD WITH(NOLOCK)
	WHERE 1=1  AND ((@FoqcMaterialQcNo = '*') 
		  OR (MQD.MaterialQcNo = @FoqcMaterialQcNo))
	ORDER BY ItemReportPrior ASC

END
