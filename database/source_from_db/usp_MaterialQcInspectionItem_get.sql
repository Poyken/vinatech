

-- =============================================
-- Author:	    Anonymous()
-- Create date: 2018-09-06
-- Browsable : true
-- Group : 품질관리 > 기준정보 > 제품검사 > [C153] 제품별제품검사스펙 > 두번째 Grid 제품별 출하검사스펙
-- Description:	자재별 수입검사스펙을 조회합니다
-- Modified:  usp_MaterialQcInspectionItem_get '','','ECVT27-382'
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialQcInspectionItem_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pMaterialCode VARCHAR(50) = NULL
AS

BEGIN
	SET NOCOUNT ON;
    DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode

	SELECT
			MQIG.MaterialCode AS OldMaterialCode,
			MQIG.MaterialCode,
			MQIG.QcInspectionGroupCode AS OldQcInspectionGroupCode,
			MQIG.QcInspectionGroupCode,
			QIG.QcInspectionGroupName,
			QII.QcInspectionItemCode AS OldQcInspectionItemCode,
			QII.QcInspectionItemCode,
			QII.QcInspectionItemName,
			QII.QcInspectionItemDesc,
			MQII.QcSpecDesc,
			MQII.InspectionLevel,
			MQII.AQL,
			MQII.SpecValue,
			MQII.USL,
			MQII.LSL,
			MQII.UCL,
			MQII.LCL,
			MQII.TextSpecValue,
			MQII.CreateDateTime,
			MQII.CreateUserID,
			MQII.ChangeDateTime,
			MQII.ChangeUserID
	FROM 
			                       STB_MaterialQcInspectionGroup MQIG WITH(NOLOCK)
			LEFT OUTER JOIN STB_QcInspectionItem                 QII WITH(NOLOCK)				ON QII.QcInspectionGroupCode = MQIG.QcInspectionGroupCode
			LEFT OUTER JOIN STB_QcInspectionGroup              QIG WITH(NOLOCK)				ON QIG.QcInspectionGroupCode = MQIG.QcInspectionGroupCode
			LEFT OUTER JOIN STB_MaterialQcInspectionItem     MQII WITH(NOLOCK)				ON MQII.MaterialCode = MQIG.MaterialCode AND				MQII.QcInspectionItemCode = QII.QcInspectionItemCode
	WHERE
			MQIG.MaterialCode = @MaterialCode AND
			QII.IsMaterialSpec = 1
END



-- SELECT * FROM STB_QcInspectionItem WHERE QcInspectionItemCode = 'IQC_GPD_20'