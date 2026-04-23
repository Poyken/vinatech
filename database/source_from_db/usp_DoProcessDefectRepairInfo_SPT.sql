-- =============================================
-- Author:		<소병운>
-- Create date: 2025-10-18
-- Description:	지지체 전용 불량 수량 입력 및 합격 처리
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessDefectRepairInfo_SPT]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pControlNo VARCHAR(20),
	@pBarcode VARCHAR(50),
	@pInputLineCode VARCHAR(20),
	@pRouteCode VARCHAR(20),
	@pDefectQty NUMERIC(20,5)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DefectCode VARCHAR(20)
	DECLARE @LineCode VARCHAR(20) = @pInputLineCode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @Barcode VARCHAR(50) = @pBarcode
	DECLARE @DefectQty NUMERIC(20,5) = @pDefectQty

	DECLARE @DefectSummaryNo VARCHAR(20)
	DECLARE @OrgDefectQty NUMERIC(20,5)

	IF @DefectQty < 1
	BEGIN
		exec usp_RaiseLocalizedError @pProcessLanguage, '불량수량은 0보다 커야합니다'
		RETURN
	END

	SELECT
		 @DefectSummaryNo = DefectSummaryNo
		,@OrgDefectQty = DefectQty
	FROM
		STB_DefectRepairInfo WITH(NOLOCK)
	WHERE
		ControlNo = @pControlNo
		AND
		FindRouteCode = @pRouteCode
		AND
		FindLineCode = @pInputLineCode

	IF @@ROWCOUNT > 0
		BEGIN
			--기존에 등록된 불량이 있는 경우, 삭제 처리
			DELETE
			FROM
				STB_DefectRepairInfo
			WHERE
				DefectSummaryNo = @DefectSummaryNo
			
			--LOT 불량 정보 업데이트
			UPDATE	STB_SetInfo
			SET
				 IsDefect = CASE WHEN DefectQty - @OrgDefectQty > 0 THEN 1 ELSE 0 END
				,DefectQty = DefectQty - @OrgDefectQty
			WHERE
				ControlNo = @pControlNo
		END

	-- 불량 조회
	SELECT
		TOP 1
		@DefectCode = DefectCode
	FROM
		STB_DefectInfo WITH(NOLOCK)
	WHERE
		DefectGroupCode = @RouteCode

	IF @@ROWCOUNT > 0
		BEGIN
			EXEC usp_DoProcessDefectRepairInfoByBarcode_SmartApp 	 @pProcessUserID 
																	,@pProcessLanguage
																	,@LineCode
																	,@RouteCode 
																	,@Barcode
																	,@DefectCode
																	,@DefectQty
		END
END
