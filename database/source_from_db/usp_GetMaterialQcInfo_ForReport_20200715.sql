
-- =============================================
-- Author: Lim Dong Seon(dsim@awoo.co.kr)
-- Create date: 2016-09-29
-- Browsable : true
-- Group : 수입검사
-- Description:	시료별 수입검사 "부적합보고서" Report
-- Modified:  


-- test  : exec usp_GetMaterialQcInfo_ForReport @pProcessUserID='kilee',@pProcessLanguage='Korean',@pMaterialQcNo='20070800005'
--          exec usp_GetMaterialQcInfo_ForReport @pProcessUserID='kilee',@pProcessLanguage='Korean',@pMaterialQcNo='VJJN232R733503'
-- 품질부적합 test  : exec usp_GetMaterialQcInfo_ForReport @pProcessUserID='kilee',@pProcessLanguage='Korean',@pMaterialQcNo='20071300002'

-- =============================================
Create PROCEDURE [dbo].[usp_GetMaterialQcInfo_ForReport_20200715]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialQcNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaterialQcNo VARCHAR(20) = @pMaterialQcNo

	--DECLARE @Acknowledgment NVARCHAR(20)
	
	--SELECT
	--		@Acknowledgment = SFC.ConstValue
	--FROM	
	--		STB_SmartFactoryConstCodeInfo SFC WITH(NOLOCK)
	--WHERE
	--		SFC.GroupCode = 'IQC' AND
	--		SFC.ConstName = '승인자명'


	SELECT
			MQI.MaterialQcNo AS OldMaterialIqcNo,
			MQI.MaterialQcNo,
			CASE				WHEN ISNULL(MQI.DecisionResult,'') = 'P' THEN '합격'				WHEN ISNULL(MQI.DecisionResult,'') = 'F' THEN '불합격'				ELSE '미검'			END  AS DecisionResultText,
			MQI.QcQty,
			MQI.InspectionType,
			MQI.TargetSampleQty,
			MQI.ActualSampleQty,
			MQI.DestoryInspectionQty,
			MQI.ProcessQty,
			MQI.MaxAcceptDefectQty,
			MQI.PassedSampleQty,
			MQI.DefectSampleQty,
			MQI.DecisionResult,
			MQI.DecisionDateTime,
			MQI.DecisionUserID,
			PW.UserName,
			MQI.SpecialAcceptDesc,
			MQI.DescText,
			MQI.VendorQcReport,
			--MQD.QcSpecDesc,
			--MQD.QcInspectionItemName,
			--MQD.QcInspectionItemDesc,
			--MQD.InspectionLevel,
			--MQD.AQL,
			--MQD.RequestSampleQty,
			--MQD.SampleQty,
			--MQD.DecisionResult AS DetailDesionResult,
			--CASE				WHEN ISNULL(MQD.DecisionResult,'') = 'P' THEN '합격'				WHEN ISNULL(MQD.DecisionResult,'') = 'F' THEN '불합격'				ELSE '미검'			END   AS DetailDesionResultText,
						
			MDI.SourceCustomerCode,
	        C.CustomerName,
	        C.CustomerNameL,
			MQI.MaterialCode,  --품번
			MM.MaterialName,
			MM.MaterialSpec,   
			MQI.CreateDateTime,
			MQI.CreateUserID,
			MQI.ChangeDateTime,
			MQI.ChangeUserID,
			MVM.InspectionType AS MasterInspectionType,
			MVM.AQL               AS MasterAQL,
			MVM.InspectionLevel AS MasterInspectionLevel
--			, MDD.MaterialIqcNo
           , MQI.MIIExtText04
		   , SIR.DefectReportNo  AS DefectReportNo
	FROM
			STB_MaterialQcInfo MQI WITH(NOLOCK)
			--LEFT OUTER JOIN STB_MaterialQcDetail MQD  WITH(NOLOCK)				ON MQD.MaterialQcNo = MQI.MaterialQcNo
			LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)				ON MDD.MaterialIqcNo = MQI.MaterialQcNo
			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)				ON MDI.MaterialDocNo = MDD.MaterialDocNo
			LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)				ON MQI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN [SmartFramework].[dbo].[STB_UserInfo] PW WITH (NOLOCK)				ON PW.UserID = CASE WHEN ISNULL(MQI.DecisionUserID,'') = '' THEN @pProcessUserID ELSE MQI.DecisionUserID END
			LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)				ON MVM.MaterialCode = MM.MaterialCode

			LEFT OUTER JOIN STB_IQcDefectReport SIR WITH(NOLOCK)				ON SIR.LotNo = MQI.MaterialQcNo              -- 부적합등록화면부분 2020.07.15 추가
	WHERE	1=1	  
	   AND MQI.MaterialQcNo = @MaterialQcNo
	--ORDER BY 			ItemReportPrior ASC
END


-- SELECT * FROM STB_MaterialQcInfo   WHERE MaterialQcNo='VJJN232R733503'
-- SELECT SAMPLEQTY, * FROM STB_MaterialQcDetail  WHERE MaterialQcNo='VJJN232R733503'      --> 샘플수량
-- SELECT * FROM STB_MaterialDocDetail WHERE MaterialIqcNo='VJJN232R733503'
-- SELECT * FROM STB_MaterialDocInfo