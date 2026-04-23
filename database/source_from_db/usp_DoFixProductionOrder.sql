-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2018-07-27
-- Description : 생산계획을 확정합니다.
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoFixProductionOrder]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20),
	@pBasicRoutingCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@PONo VARCHAR(20) = @pPONo,
			@BasicRoutingCode VARCHAR(20) = @pBasicRoutingCode,
			@IsFix BIT

	SELECT
			@IsFix = POI.IsFix
	FROM
			STB_ProductionOrderInfo POI
			LEFT OUTER JOIN STB_MaterialMaster MM
				ON MM.MaterialCode = POI.MaterialCode
	WHERE
			POI.PONo = @PONo

	IF ISNULL(@IsFix,0) = 1 BEGIN
			EXEC usp_RaiseLocalizedError @ProcessLanguage, '이미 확정된 PO입니다'
			RETURN
	END

	UPDATE	STB_ProductionOrderInfo
	SET
			IsFix = 1,
			FixDateTime = GETDATE(),
			FixUserID = @ProcessUserID,
			ChangeDateTime = GETDATE(),
			ChangeUserID = @ProcessUserID
	WHERE
			PONo = @PONo


END
