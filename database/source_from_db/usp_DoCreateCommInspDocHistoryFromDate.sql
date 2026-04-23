-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Group :	품질관리
-- Browsable : true
-- Create date: 2018-09-03
-- Description: 공용검사문서 검사항목을 생성합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateCommInspDocHistoryFromDate]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pCommInspTypeCode VARCHAR(50) = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pRefDoc VARCHAR(20) = NULL,
	@pProdNo VARCHAR(50) = NULL,
	@pProductGroupCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pMoldNumber VARCHAR(50) = NULL,
	@pCategoryName VARCHAR(50) = NULL,
	@pMeasureDate DATE = NULL,
	@pCommInspDocNo VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessDateTime DATETIME = ISNULL(@pMeasureDate, GETDATE()),
			@CommInspTypeCode VARCHAR(50) = @pCommInspTypeCode,
			@CompanyCode VARCHAR(20) = @pCompanyCode,
			@WorkCenterCode VARCHAR(20) = @pWorkCenterCode,
			@LineCode VARCHAR(20) = ISNULL(@pLineCode,''),
			@RouteCode VARCHAR(20) = ISNULL(@pRouteCode,''),
			@MachineCode  VARCHAR(20) = ISNULL(@pMachineCode,''),
			@MoldNumber  VARCHAR(20) = ISNULL(@pMoldNumber,''),
			@MaterialCode  VARCHAR(20) = ISNULL(@pMaterialCode,''),
			@CategoryName  VARCHAR(20) = ISNULL(@pCategoryName,''),
			@ProductGroupCode  VARCHAR(20) = ISNULL(@pProductGroupCode,''),
			@RefDocNo VARCHAR(20) = ISNULL(@pRefDoc,''),
			@ProdNo VARCHAR(20) = ISNULL(@pProdNo,'')
	
	DECLARE @CommInspDocNo VARCHAR(20)
	DECLARE @JobDateShift VARCHAR(20)
	DECLARE @JobDate DATE
	DECLARE @ShiftCode VARCHAR(1)
	DECLARE @TimeCode VARCHAR(2)
	DECLARE @ErrorMessage NVARCHAR(500)

	IF NOT EXISTS (
					SELECT	1
					FROM
							STB_CommInspItem CII
					WHERE
							CII.CommInspTypeCode = @CommInspTypeCode AND
							CII.CompanyCode = @CompanyCode AND
							CII.WorkCenterCode = @WorkCenterCode AND
							((CII.LineCode = '') OR (CII.LineCode = @LineCode)) AND
							((CII.RouteCode = '') OR (CII.RouteCode LIKE @RouteCode)) AND
							((CII.MachineCode = '') OR (CII.MachineCode = @MachineCode)) AND
							((CII.MoldNumber = '') OR (CII.MoldNumber = @MoldNumber)) AND
							((CII.ProductGroupCode = '') OR (CII.ProductGroupCode = @ProductGroupCode)) AND
							((CII.MaterialCode = '') OR (CII.MaterialCode = @MaterialCode)) AND
							((CII.CategoryName = '') OR (CII.CategoryName = @CategoryName))
					) BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																'^해당 유형의 검사항목이 등록되어있지 않습니다^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@CommInspTypeCode)
			RETURN
	END

	EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspDocHistory', @CommInspDocNo OUTPUT

	SET @JobDateShift = CONVERT(CHAR(10), @ProcessDateTime, 121) --측정일자가 시간이 존재하지 않으므로 --dbo.fnGetJobDateShiftTimeV3(@ProcessDateTime,@WorkCenterCode)
	SET @JobDate = @JobDateShift --SUBSTRING(@JobDateShift,1,8)
	SET @ShiftCode = '1' --측정시점은 주간고정 --SUBSTRING(@JobDateShift,9,1)
	SET @TimeCode = '*' --타임코드는 * --SUBSTRING(@JobDateShift,10,2)

	INSERT INTO STB_CommInspDocHistory
	(
		CommInspDocNo,
		CommInspTypeCode,
		CompanyCode,
		WorkCenterCode,
		LineCode,
		RouteCode,
		MachineCode,
		MoldNumber,
		ProductGroupCode,
		MaterialCode,
		CategoryName,
		RefDocNo,
		ProdNo,
		JobDate,
		ShiftCode,
		InspTimeCode,
		IsFinished,
		CreateDateTime,
		CreateUserID
	)
	VALUES
	(
		@CommInspDocNo,
		@CommInspTypeCode,
		@CompanyCode,
		@WorkCenterCode,
		@LineCode,
		@RouteCode,
		@MachineCode,
		@MoldNumber,
		@ProductGroupCode,
		@MaterialCode,
		@CategoryName,
		@RefDocNo,
		@ProdNo,
		@JobDate,
		@ShiftCode,
		@TimeCode,
		0,
		GETDATE(),
		@ProcessUserID
	)

	EXEC usp_DoCreateCommInspDocItem	@pProcessLanguage = @ProcessLanguage,
										@pProcessUserID = @ProcessUserID,
										@pCommInspDocNo = @CommInspDocNo,
										@pCompanyCode = @CompanyCode,
										@pWorkCenterCode = @WorkCenterCode,
										@pLineCode = @LineCode,
										@pRouteCode = @RouteCode,
										@pMachineCode = @MachineCode,
										@pMoldNumber = @MoldNumber,
										@pMaterialCode = @MaterialCode,
										@pCategoryName = @CategoryName,
										@pProductGroupCode = @ProductGroupCode

	SET @pCommInspDocNo = @CommInspDocNo
END

