
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-17
-- Browsable : true
-- Group : 품질관리
-- Description:	시료별수입검사 결과 테이블을 조회합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialIqcSampleResult_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialQcNo VARCHAR(20) = NULL,
    @pMaterialQcDetailNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialIqcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END
	DECLARE @MaterialIqcDetailNo VARCHAR(20) = @pMaterialQcDetailNo

	SELECT
	        MISR.MaterialQcNo AS OldMaterialIqcNo,
	        MISR.MaterialQcDetailNo AS OldMaterialIqcDetailNo,
	        MISR.MaterialQcSampleNo AS OldMaterialIqcSampleNo,
	        MISR.MaterialQcNo,
	        MISR.MaterialQcDetailNo,
	        MISR.MaterialQcSampleNo,
	        MISR.SampleSerialNo,
	        MISR.TestUserID,
	        MISR.TestDateTime,
	        MISR.TestValue,
	        MISR.TestResult,
	        MISR.CreateDateTime,
	        MISR.CreateUserID,
	        MISR.ChangeDateTime,
	        MISR.ChangeUserID
	FROM
	        STB_MaterialQcSampleResult MISR WITH(NOLOCK)
	WHERE
	        ((@MaterialIqcNo = '*') OR (MISR.MaterialQcNo = @MaterialIqcNo)) AND
	        (MISR.MaterialQcDetailNo = @MaterialIqcDetailNo)

END

