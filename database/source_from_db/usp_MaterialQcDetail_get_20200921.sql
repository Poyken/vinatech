
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-17
-- Browsable : true
-- Group : 품질관리 > 시료별수입검사 & 시료별입고검사
-- Description:	수입검사 상세를 조회합니다
-- Modified: 2번째 Tab
-- @pMaterialQcNo 기본값 변경, 기존처럼 기본값이 NULL인 경우 해외법인입고현황 등의 화면에서는 Detail 테이블의 전체조회가 일어남. 2020.09.07 By Jackaroe

-- EXEC usp_MaterialQcDetail_get '','','20073000003'
-- EXEC usp_MaterialQcDetail_get '','','20092100004'
-- =============================================

--select * from STB_MaterialQcDetail where MaterialQcNo = '20092100004'


Create PROCEDURE [dbo].[usp_MaterialQcDetail_get_20200921]
																	@pProcessUserID VARCHAR(20),
																	@pProcessLanguage VARCHAR(20),
																	@pMaterialQcNo VARCHAR(20) = 'MaterialQcNo' 
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialQcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END

    
	IF @MaterialQcNo LIKE 'VJ%' 

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
					--CASE WHEN ISNULL(MQD.SampleQty, 0) > 0 THEN MQD.SampleQty ELSE MQD.RequestSampleQty END  AS SampleQty,       --2019.03.28 kilee (대상샘플수량과 샘플수량 동일하게)
					CASE WHEN MQD.QcInspectionItemCode = 'IQC_GPD_20' THEN 10 ELSE MQD.SampleQty END AS SampleQty,
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


	ELSE 


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


END

--   SELECT RequestSampleQty,  SampleQty, * FROM STB_MaterialQcDetail WHERE MATERIALQCNO = 'VJJN232R733502'                            -- 1TAB에서 출하검사번호(MATERIALQCNO)로 조회 
--    SELECT RequestSampleQty,  SampleQty, * FROM STB_MaterialQcDetail ORDER BY CreateDateTime DESC


-- 베트남 바코드 : select * from STB_MaterialQcDetail  where  MATERIALQCNO = 'VVJU163R036710'                              --  ECVT30-197

--select SampleQty, * from STB_MaterialQcDetail  where MATERIALQCNO = 'VVJU202R710608' and QcInspectionItemCode = 'IQC_GPD_18'


--update STB_MaterialQcDetail
--set SampleQty = '5'
-- where MATERIALQCNO = 'VVJU202R710608' and QcInspectionItemCode = 'IQC_GPD_18'


--select * from STB_MaterialQcDetail where MaterialQcNo = '20070200004'

--update STB_MaterialQcDetail 
--set LSL =USL, USL = LSL
--where MaterialQcNo = '20070200004' AND QcInspectionItemCode = 'IQC_G1_068'