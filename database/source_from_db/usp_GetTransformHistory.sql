-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-08-28
-- Group : 제품관리
-- Description:	기종변경 이력을 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetTransformHistory]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE = NULL,
	@pToDate DATE,
	@pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE	@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@FromDate VARCHAR(20) = @pFromDate,
			@ToDate VARCHAR(20) = @pToDate,
			@MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END

	SELECT
			MDI.MaterialDocNo,
			MDI.BasicDate,
			MDD.MaterialCode AS SourceMaterialCode,
			SMM.MaterialName AS SourceMaterialName,
			MDD.MRMDExtText01 AS TargetMaterialCode,
			TMM.MaterialName AS TargetMaterialName,
			MDD.ProcessFixQty,
			MDI.CreateDateTime,
			MDI.CreateUserID,
			UI.UserName AS CreateUserName
	FROM
			STB_MaterialDocInfo MDI
			INNER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)
				ON	MDD.MaterialDocNo = MDI.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialMaster SMM WITH(NOLOCK)
				ON	SMM.MaterialCode = MDD.MaterialCode
			LEFT OUTER JOIN STB_MaterialMaster TMM WITH(NOLOCK)
				ON	TMM.MaterialCode = MDD.MaterialCode
			LEFT OUTER JOIN VW_UserInfo UI WITH(NOLOCK)
				ON	UI.UserID = MDI.CreateUserID
	WHERE
			@FromDate <= MDI.BasicDate AND
			MDI.BasicDate <= @ToDate AND
			MDI.MaterialDocTypeCode = 'MV_TRANSFORM' AND
			MDD.MaterialCode LIKE @MaterialCode
END

