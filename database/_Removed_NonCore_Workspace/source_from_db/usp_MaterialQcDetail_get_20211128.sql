
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
--             베트남 Tung이 remove IQC & HYCAP condition on 22-June-2021
--             Mr.Tung add on 2021-July-17

-- 프로시저 실행문 :  EXEC usp_MaterialQcDetail_get '','','VJLT193R850605'
-- =======================================================================================================================
CREATE PROCEDURE [dbo].[usp_MaterialQcDetail_get_20211128]
								@pProcessUserID VARCHAR(20),
								@pProcessLanguage VARCHAR(20),
								@pMaterialQcNo VARCHAR(20) = 'MaterialQcNo' 
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialQcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END
	DECLARE @Barcode         VARCHAR(20) 
	DECLARE @CompanyCode VARCHAR(20)
    
	SELECT  @Barcode = Barcode
	  FROM STB_SetInfo
	WHERE LotNumber  = @MaterialQcNo

	SELECT @CompanyCode = CompanyCode
	  FROM STB_MaterialQcInfo
	 WHERE MaterialQcNo = @MaterialQcNo

			--	SELECT   Barcode, LotNumber, *
			--  FROM STB_SetInfo
			--WHERE LotNumber  = '20092100004'




	-- IF @MaterialQcNo LIKE 'VV%'    -- 베트남 바코드의 경우   -- 기존 소스 백업
	  IF @CompanyCode LIKE 'VVT'    -- 베트남 바코드의 경우

	   BEGIN 


		-- 베트남  부문창님 of QC require to check 20 SD value and 20 ESR value
		-- Mr.Tung EA 베트남 modified updating this area 
		-- Date:  28-August-2020
		-- START
		DECLARE @sumSampleQtyESR numeric(20,5) = 20
		DECLARE @sumSampleQtySD numeric(20,5) = 10
		DECLARE @sumSampleQtyCAP numeric(20,5) = 3
		DECLARE @cCount INT

		------select @cCount = count(*)
		------from Stb_materialMaster
		------where MaterialCode in
		------ (	SELECT  MaterialCode
		------	FROM STB_MaterialQcInfo
		------	WHERE MaterialQcNo = @MaterialQcNo and InspectionDocType='IQC') and upper(MaterialName) like 'HY-CAP%' and MaterialCode like 'ECVT%'


		--CAP
		select @cCount = count(*)
		  from 
		  stb_modelbasicinfo
		  where modelcode=(select materialcode from STB_SetInfo where Barcode=@MaterialQcNo) 
		  and ModelName like '%VEC2R7%1840%' and convert(numeric(10,2),isnull(MBIExtText05,0))=50

	 	 if (@cCount>0  )
	 	 begin
			select @sumSampleQtyESR  = 50
			select @sumSampleQtySD   = 30
			select @sumSampleQtyCAP  = 30
		 end
		 
		 
		 update  STB_MaterialQcDetail 
			set SampleQty = @sumSampleQtyCAP
			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('IQC_GPD_20')


		--ESR
		   update  STB_MaterialQcDetail 
			set SampleQty = @sumSampleQtyESR
			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('IQC_GPD_19')

			 
		--SD Mr.Tung add on 2021-July-17 for SD measure , IQC inspection of HY-CAP import from HeadQuarter
		   update  STB_MaterialQcDetail 
			set SampleQty = 5                 --5 values of SD
			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('IQC_GPD_18')
			 and (select top 1 InspectionDocType from STB_MaterialQcInfo where MaterialQcNo = @MaterialQcNo)='IQC'

		-- END by Mr.Tung
			   		 


		--SD add by loan change quality sd=10 ea
	    	update  STB_MaterialQcDetail 
			set SampleQty = @sumSampleQtySD
			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('IQC_GPD_18')




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
				MQD.SampleQty ,                -- 베트남의 경우는 SD는 측정수량이 20
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
		WHERE 1=1
			 AND ((@MaterialQcNo = '*') OR (MQD.MaterialQcNo = @MaterialQcNo)) 
		ORDER BY ItemReportPrior ASC

	END 

 -- IF @MaterialQcNo LIKE 'VJ%'    -- 기존 소스 백업

	
 
    IF @CompanyCode LIKE 'VNT'     -- 본사 바코드의 경우

	BEGIN 
			PRINT 'This!!!!'

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
					CASE WHEN ISNULL(MQD.SampleQty, 0) > 0 THEN MQD.SampleQty ELSE MQD.RequestSampleQty END  AS SampleQty,       --2019.03.28 kilee (대상샘플수량과 샘플수량 동일하게)
					--CASE WHEN MQD.QcInspectionItemCode = 'IQC_GPD_20' THEN 10 ELSE MQD.SampleQty END AS SampleQty,           --10개 고정
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
					MQD.ChangeUserID,
					MQD.Cpk
			FROM  STB_MaterialQcDetail MQD WITH(NOLOCK)
			WHERE 1=1
				 AND ((@MaterialQcNo = '*') OR (MQD.MaterialQcNo = @MaterialQcNo)) 
			ORDER BY ItemReportPrior ASC

	END

 
 ELSE    --그 밖의 모든것 (lot합침 등)
		 

	BEGIN 
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
					CASE WHEN ISNULL(MQD.SampleQty, 0) > 0 THEN MQD.SampleQty ELSE MQD.RequestSampleQty END  AS SampleQty,       --2019.03.28 kilee (대상샘플수량과 샘플수량 동일하게)
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
			WHERE 1=1
				 AND ((@MaterialQcNo = '*') OR (MQD.MaterialQcNo = @MaterialQcNo)) 
			ORDER BY ItemReportPrior ASC

	END 


END
