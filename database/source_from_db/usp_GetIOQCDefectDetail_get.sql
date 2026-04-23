-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-02-05
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetIOQCDefectDetail_get]
	-- Add the parameters for the stored procedure here
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pMaterialQcNo VARCHAR(20) = NULL,
				@pMaterialQcDetailNo VARCHAR(20) = NULL,
				@pQcInspectionItemCode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT 
		QCDD.ID,
		QCDD.MaterialQcNo,
		QCDD.InspectionDocType,
		QCDD.MaterialQcDetailNo,
		QCDD.QcInspectionItemCode,
		MQD.QcInspectionItemName,
		QCDD.DefectCode,
		DI.BasicDefectName,
		QCDD.DefectQty,
		QCDD.DefectDesc,
		QCDD.CreateDateTime,
		QCDD.CreateUserID,
		QCDD.ChangeDateTime,
		QCDD.ChangeUserID

	FROM	STB_IOQCDefectDetail QCDD WITH(NOLOCK)
	LEFT JOIN STB_MaterialQcDetail MQD ON	QCDD.MaterialQcNo = MQD.MaterialQcNo 
										AND QCDD.MaterialQcDetailNo = MQD.MaterialQcDetailNo 
										AND QCDD.QcInspectionItemCode = MQD.QcInspectionItemCode
	LEFT JOIN STB_DefectInfo DI ON QCDD.DefectCode = DI.DefectCode
	--LEFT JOIN STB_MaterialQcInfo MQI ON MQI.MaterialQcNo = QCDD.MaterialQcNo

	WHERE 
		QCDD.MaterialQcNo = @pMaterialQcNo AND
		QCDD.MaterialQcDetailNo = @pMaterialQcDetailNo AND
		QCDD.QcInspectionItemCode = @pQcInspectionItemCode
END
