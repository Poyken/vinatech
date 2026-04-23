
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-17
-- Browsable : true
-- Group : 품질관리 > 시료별수입검사 & 시료별입고검사 > 2번째 Grid화면
--            품질관리 > 제품검사 > 2번째 Grid
-- Description:	수입검사 및 제품검사 상세를 조회합니다
-- Modified: 
--             @pMaterialQcNo 기본값 변경, 기존처럼 기본값이 Null인 경우 해외법인 입고현황 등의 화면에서는 Detail 테이블의 전체조회가 일어남. 2020.09.07 By Jackaroe
--             베트남 Tung이 Update문 수정한 것 잘못되어, @LotNumber추가하여 조건 변경함. (2020-09-21  kilee 수정)

-- 프로시저 실행문 :  EXEC usp_MaterialQcDetail_get '','','20092100004'
-- =======================================================================================================================
CREATE  PROCEDURE [dbo].[usp_Vietnam_MaterialAgingDetail_get]
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


	
	if(@MaterialQcNo like 'A%') 
	begin
		 select @FoqcMaterialQcNo  = @MaterialQcNo 
		 select @MaterialQcNo  = stuff(@MaterialQcNo,1,1,'' )
	end

	DECLARE @CharFOQC VARCHAR(1)='A';
	if(@MaterialQcNo not like 'A%') 
	begin
		 select @FoqcMaterialQcNo  = @CharFOQC + @MaterialQcNo 
	end


	DECLARE @sumSampleQty numeric(20,5) = 20
	DECLARE @cCount INT
	
	declare @tung varchar(100) = @MaterialQcNo + '-----' + @FoqcMaterialQcNo


	--SELECT  @Barcode = Barcode
	--  FROM STB_SetInfo
	--WHERE LotNumber  = @MaterialQcNo
	 



----;with newbar as (
----	SELECT  NewBarcode,OldBarcode,AftMaterialCode FROM STB_LotChangeMaterialHistory  WITH(NOLOCK) 
----	WHERE OldBarcode in (
----		select replace(MaterialQcNo,'AV','V')  
----		from	STB_MaterialQcInfo  WITH(NOLOCK) 
----		where DecisionResult='Pass' and InspectionDocType='AOQC'
----		and CreateDateTime>=DATEADD(DAY,-10,getdate())
----		)and CreateDateTime>=DATEADD(DAY,-10,getdate())
----	)
----	,
----newbar1 as (
----	select replace(MaterialQcNo,'AV','V') as MaterialQcNo
----	from	STB_MaterialQcInfo  WITH(NOLOCK) 
----	where   replace(MaterialQcNo,'AV','V') in (			
----			SELECT  NewBarcode FROM STB_LotChangeMaterialHistory  WITH(NOLOCK) 
----			WHERE OldBarcode in (
----				select replace(MaterialQcNo,'AV','V')  
----				from	STB_MaterialQcInfo  WITH(NOLOCK) 
----				where DecisionResult='Pass' and InspectionDocType='AOQC'
----				and CreateDateTime>=DATEADD(DAY,-10,getdate())
----			)and CreateDateTime>=DATEADD(DAY,-10,getdate())
----		)
----		and MaterialQcNo like 'A%'
----	)
----	,
----newbar2 as (
----		SELECT  NewBarcode,OldBarcode,AftMaterialCode FROM STB_LotChangeMaterialHistory  WITH(NOLOCK) 
----		WHERE newbarcode in (
----				select newbarcode from newbar
----				except
----				select MaterialQcNo from newbar1
----			)
----	)
----insert into STB_MaterialQcInfo
----select 
----		'A'+newbar2.NewBarcode as  MaterialQcNo, CompanyCode, WorkCenterCode, InspectionDocType, 
----					newbar2.AftMaterialCode as MaterialCode, 
----					QcQty, InspectionType,  BasicDate, TargetSampleQty, ActualSampleQty, DestoryInspectionQty,  ProcessQty, 
----					MaxAcceptDefectQty, PassedSampleQty, DefectSampleQty,  DecisionResult,  DecisionDateTime,  DecisionUserID, 
----					SpecialAcceptDesc, DescText, VendorQcReport, VendorLotNo,  MIIExtText01, MIIExtText02, MIIExtText03, 
----					MIIExtText04, MIIExtText05,  CreateDateTime,  CreateUserID,  ChangeDateTime,  ChangeUserID, IQCSampleLotList
----		from	STB_MaterialQcInfo mqi  WITH(NOLOCK)  
----		 join newbar2 on mqi.MaterialQcNo = 'A'+newbar2.OldBarcode
----		 where mqi.CreateDateTime>=DATEADD(DAY,-10,getdate())





	SELECT  @cCount = count(*)
	  FROM STB_MaterialQcInfo WITH(NOLOCK) 
	 WHERE MaterialQcNo =  (case when @FoqcMaterialQcNo like 'AM%' then 'VVLM063R010620' else @MaterialQcNo end) -- if MODULE product then use again: FVVLM063R010620
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

				  insert into STB_MaterialQcinfo
				  (
				   MaterialQcNo, CompanyCode, WorkCenterCode, InspectionDocType,MaterialCode, 
					QcQty, InspectionType,  BasicDate, TargetSampleQty, ActualSampleQty, DestoryInspectionQty,  ProcessQty, 
					MaxAcceptDefectQty, PassedSampleQty, DefectSampleQty,  DecisionResult,  DecisionDateTime, DecisionUserID, 
					SpecialAcceptDesc, DescText, VendorQcReport, VendorLotNo, MIIExtText01, MIIExtText02, MIIExtText03, 
					MIIExtText04, MIIExtText05, CreateDateTime,  CreateUserID, ChangeDateTime, ChangeUserID, IQCSampleLotList
				  )
					SELECT @FoqcMaterialQcNo as MaterialQcNo, CompanyCode, WorkCenterCode, 'AOQC' as InspectionDocType, 
					(case when @FoqcMaterialQcNo like 'AM%' then '' else MaterialCode end) as MaterialCode, 
					QcQty, InspectionType, convert(date,getdate(),120) as BasicDate, TargetSampleQty, ActualSampleQty, DestoryInspectionQty, 0 as ProcessQty, 
					MaxAcceptDefectQty, PassedSampleQty, DefectSampleQty, NULL as DecisionResult, NULL as DecisionDateTime, NULL as DecisionUserID, 
					SpecialAcceptDesc, DescText, VendorQcReport, VendorLotNo, NULL as MIIExtText01, MIIExtText02, MIIExtText03, 
					MIIExtText04, MIIExtText05, getdate() as CreateDateTime, @pProcessUserID as CreateUserID, NULL as ChangeDateTime, NULL as ChangeUserID, IQCSampleLotList
					FROM
							STB_MaterialQcinfo WITH(NOLOCK) 
					WHERE
							MaterialQcNo = (case when @FoqcMaterialQcNo like 'AM%' then 'VVLM063R010620' else @MaterialQcNo end) -- if MODULE product then use again: FVVLM063R010620 
			end
			
		--check   STB_MaterialQcDetail   table
			SELECT  @cCount = count(*)
			FROM STB_MaterialQcDetail WITH(NOLOCK) 
			WHERE MaterialQcNo =  @FoqcMaterialQcNo

			if(@cCount=0)
			 begin

			 	select @tung= @tung +'.2'

			  insert into STB_MaterialQcDetail ( 
			    MaterialQcNo,MaterialQcDetailNo,QcInspectionGroupCode,QcInspectionGroupName,
				QcInspectionGroupDesc,QcInspectionItemCode,QcInspectionItemName,QcInspectionItemDesc,
				GroupInspectionPrior,GroupReportPrior,ItemInspectionPrior, ItemReportPrior, QcSpecDesc, 
				InspectionType, IsMaterialSpec, InspectionLevel, AQL,RequestSampleQty, MaxAcceptDefectQty,
				SampleQty, PassedSampleQty, DefectSampleQty, SkipSampleQty, SpecValue,USL,LSL,UCL, LCL, 
				TextSpecValue,DecisionResult,CreateDateTime,CreateUserID, ChangeDateTime, ChangeUserID
			  )
				select 	 @FoqcMaterialQcNo as MaterialQcNo, 19 as  MaterialQcDetailNo, 'AOQC_GPD' as QcInspectionGroupCode, 
				'AOQC검사' as QcInspectionGroupName, N'Kiểm tra FOQC' as QcInspectionGroupDesc, 
				'AOQC_GPD_19' as QcInspectionItemCode, QcInspectionItemName, QcInspectionItemDesc, GroupInspectionPrior, GroupReportPrior, 
				ItemInspectionPrior, ItemReportPrior, QcSpecDesc, InspectionType, IsMaterialSpec, InspectionLevel, AQL, 
				20 as RequestSampleQty, MaxAcceptDefectQty, 20 as SampleQty, PassedSampleQty, DefectSampleQty, SkipSampleQty, SpecValue, 
				(case when @FoqcMaterialQcNo like 'AM%' then 500 else USL end) as USL, 
				(case when @FoqcMaterialQcNo like 'AM%' then 0 else LSL end) as LSL, 
				----(case when @FoqcMaterialQcNo like 'FM%' then 500 else USL end) as USL, 
				--(SELECT USL  FROM [STB_MaterialQcInspectionItem]  where MaterialCode=@MaterialCode and QcInspectionItemCode='IQC_GPD_19') as USL, 
				----(case when @FoqcMaterialQcNo like 'FM%' then 0 else LSL end) as LSL, 
				--(SELECT LSL  FROM [STB_MaterialQcInspectionItem]  where MaterialCode=@MaterialCode and QcInspectionItemCode='IQC_GPD_19') as LSL, 
				UCL, LCL, TextSpecValue, NULL as DecisionResult, getdate() as CreateDateTime, 
				@pProcessUserID as CreateUserID, ChangeDateTime, ChangeUserID
				from
						STB_MaterialQcDetail WITH(NOLOCK) 
				WHERE
						MaterialQcNo =  (case when @FoqcMaterialQcNo like 'AM%' then 'VVLM063R010620' else @MaterialQcNo end) -- if MODULE product then use again: FVVLM063R010620  
						and  QcInspectionItemCode = 'IQC_GPD_19' 				
		    end

			--check count stop khi du 20
			--check max + 1 cho du 20
		  declare @MaterialQcSampleNo1 INT = (select COUNT(MaterialQcSampleNo) from STB_MaterialQcSampleResult  WITH(NOLOCK) where MaterialQcNo=@FoqcMaterialQcNo) + 1

		  WHILE @MaterialQcSampleNo1 <= 20
			BEGIN						
			select @tung= @tung +'.3'	
			 insert into STB_MaterialQcSampleResult
			 ( 
			 MaterialQcNo, MaterialQcDetailNo, MaterialQcSampleNo, SampleSerialNo, TestUserID, TestDateTime, 
			 TestValue, TestResult, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID
			 )
			 values (
			 @FoqcMaterialQcNo, 19, (select isnull(MAX(MaterialQcSampleNo),0) from STB_MaterialQcSampleResult  WITH(NOLOCK) where MaterialQcNo=@FoqcMaterialQcNo) + 1 , 
			 NULL, NULL, NULL, NULL, NULL, getdate(), @pProcessUserID, NULL, NULL
			 )
			 SELECT @MaterialQcSampleNo1 = (select COUNT(MaterialQcSampleNo) from STB_MaterialQcSampleResult  WITH(NOLOCK) where MaterialQcNo=@FoqcMaterialQcNo) + 1
		  END

	 end	 

			--	SELECT   Barcode, LotNumber, *
			--  FROM STB_SetInfo
			--WHERE LotNumber  = '20092100004'
			
	-- IF @MaterialQcNo LIKE 'VV%'    -- 베트남 바코드의 경우   -- 기존 소스 백업
		
		-- 베트남  부문창님 of QC require to check 20 SD value and 20 ESR value
		-- Mr.Tung EA 베트남 modified updating this area 
		-- Date:  28-August-2020
		-- START			
		-- esr IQC_GPD_19

		-- END by Mr.Tung
		
	
	if(@pProcessUserID='nguyentung') begin	
		select @tung= @tung +'.4'	
		--raiserror (@tung,16,1)
		--return
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
