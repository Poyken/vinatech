-- Procedure: usp_BasicMaterialType_popup
-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-07-23
-- Description : 자재기준유형 popup
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_BasicMaterialType_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT
			V.BasicMaterialType
	FROM
			VW_BasicMaterialType V
END

GO

