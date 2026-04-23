-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-07-23
-- Description : 모델정보 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_Model_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProductGroupCode VARCHAR(20) = NULL,
	@pExcludeModelCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END,
			@ExcludeModelCode VARCHAR(50) = ISNULL(@pExcludeModelCode,'')

	SELECT
			MBI.ModelCode,
			MBI.ModelName,
			MBI.MBIExtText06,
			MBI.MBIExtInt01
	FROM
			VW_ModelBasicInfo MBI WITH(NOLOCK)
	WHERE
			(MBI.ProductGroupCode IS NULL OR MBI.ProductGroupCode LIKE @ProductGroupCode) AND
			MBI.IsClosed = 0 AND
			MBI.ModelCode NOT IN (@ExcludeModelCode)
END
