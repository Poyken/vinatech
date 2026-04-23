-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2018-07-26
-- Description : BOM 버전조회
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_BomVersion_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@MaterialCode VARCHAR(20) = @pMaterialCode

	SELECT
			BH.BomVersion,
			BH.BomHeaderDesc
	FROM
			STB_BomHeader BH WITH(NOLOCK)
	WHERE
			BH.MaterialCode = @MaterialCode AND
			BH.IsUsed = 1
	ORDER BY BH.BomVersion ASC
END
