
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-17
-- Browsable : true
-- Group : 품질관리 > 시료별수입검사 & 시료별입고검사 > 2번째 Grid화면
-- Description:	수입검사 상세를 조회합니다
-- Modified: 
--             @pMaterialQcNo 기본값 변경, 기존처럼 기본값이 NULL인 경우 해외법인입고현황 등의 화면에서는 Detail 테이블의 전체조회가 일어남. 2020.09.07 By Jackaroe
--              2020-09-21  kilee수정 (베트남 Tung이 Update문 수정한것 잘못되어, @LotNumber추가하여 조건변경)

-- 프로시저 실행문 :  EXEC usp_MaterialQcDetail_get '','','20092100004'
-- =======================================================================================================================
Create PROCEDURE [dbo].[usp_MaterialQcDetail_get_20200922]
								@pProcessUserID VARCHAR(20),
								@pProcessLanguage VARCHAR(20),
								@pMaterialQcNo VARCHAR(20) = 'MaterialQcNo' 
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialQcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END
	--DECLARE @LotNumber VARCHAR(30) 
    

	--SELECT  @LotNumber = LotNumber
	--  FROM STB_SetInfo
	--WHERE Barcode  = @MaterialQcNo

	--SELECT LotNumber
	--  FROM STB_SetInfo
	--WHERE Barcode  = 'VJKR133r060609'



	IF @MaterialQcNo LIKE 'VV%'    -- 베트남 바코드의 경우
	--IF @LotNumber LIKE 'VV%'    -- 베트남 바코드의 경우

	BEGIN 

		-- 베트남  부문창님 of QC require to check 20 SD value and 20 ESR value
		-- Mr.Tung EA 베트남 modified updating this area 
		-- Date:  28-August-2020
		-- START
		update  STB_MaterialQcDetail 
			set SampleQty = 20
			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('IQC_GPD_18','IQC_GPD_19')
		-- END by Mr.Tung

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
				CASE WHEN MQD.QcInspectionItemCode = 'IQC_GPD_18' THEN 20 ELSE MQD.SampleQty END AS SampleQty,                -- 베트남의 경우는 SD는 측정수량이 20
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


    IF @MaterialQcNo LIKE 'VJ%'  
   -- IF @LotNumber LIKE 'VJ%'  

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
					MQD.ChangeUserID
			FROM  STB_MaterialQcDetail MQD WITH(NOLOCK)
			WHERE 1=1
				 AND ((@MaterialQcNo = '*') OR (MQD.MaterialQcNo = @MaterialQcNo)) 
			ORDER BY ItemReportPrior ASC

	END

 
 ELSE    --그밖의 모든것
		 

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
