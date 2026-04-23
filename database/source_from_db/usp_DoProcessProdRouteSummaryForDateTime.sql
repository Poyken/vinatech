-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : false
-- Group : 현장용
-- Create date: 2018-08-02
-- Description:	공정별 실적 처리
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessProdRouteSummaryForDateTime]
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pLineCode VARCHAR(20),
	@pRouteCode VARCHAR(20),
	@pPONo VARCHAR(20),
	@pProcessDateTime DATETIME,
	@pSubRouteCode VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pMoldNumber VARCHAR(20) = NULL,
	@pInputQty NUMERIC(20,5) = NULL,
	@pProdQty NUMERIC(20,5) = NULL,
	@pDefectQty NUMERIC(20,5) = NULL,
	@pRepairQty NUMERIC(20,5) = NULL,
	@pLossQty NUMERIC(20,5) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ShiftDateTime VARCHAR(20) = dbo.fnGetJobDateShiftTime(@pProcessDateTime,@pCompanyCode, @pWorkCenterCode, @pLineCode,@pRouteCode,NULL)
	DECLARE @JobDate DATE = SUBSTRING(@ShiftDateTime,1,8)
	DECLARE @ShiftCode VARCHAR(1) = SUBSTRING(@ShiftDateTime,9,1)
	DECLARE @TimeCode VARCHAR(2) = SUBSTRING(@ShiftDateTime,10,2)

	EXEC usp_DoProcessProdRouteSummary	@pCompanyCode = @pCompanyCode,
										@pWorkCenterCode = @pWorkCenterCode,
										@pLineCode = @pLineCode,
										@pRouteCode = @pRouteCode,
										@pPONo = @pPONo,
										@pJobDate = @JobDate,
										@pShiftCode = @ShiftCode,
										@pTimeCode = @TimeCode,
										@pSubRouteCode = @pSubRouteCode,
										@pMachineCode = @pMachineCode,
										@pMoldNumber = @pMoldNumber,
										@pInputQty = @pInputQty,
										@pProdQty = @pProdQty,
										@pDefectQty = @pDefectQty,
										@pRepairQty = @pRepairQty,
										@pLossQty = @pLossQty
END
