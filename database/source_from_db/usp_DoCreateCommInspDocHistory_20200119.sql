-- =============================================
-- Author : Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Group : 품질관리 > [C141] 공정검사(LotNo) 화면에서 조회시 호출되는 프로시저 
-- 설명 : usp_GetCommInspectionHistoryForBarcode ->  [usp_DoCreateCommInspDocHistory]  ->  [usp_DoCreateSerial] + [usp_DoCreateCommInspDocItem] 호출
-- Browsable : True
-- Create date: 2018-09-03
-- Description : 공용검사문서 검사항목을 생성합니다.
-- 프로시저 실행 : usp_DoCreateCommInspDocHistory 'Korean','kilee2','ROUTE_QUALITY','VNT','VNT_F1','ECVT27-150','20180829000058','','ECVT27-150','','E-24','','','','20180912000001'
-- 프로시저 실행 : usp_DoCreateCommInspDocHistory 'Korean','kilee2','ROUTE_TEST_VPC','VNT','VNT_F1','LIVT38-018','20211229000052','','LIVT38-018','','E-24','','','','20211229000052'
-- ===========================================================================================================================
Create PROCEDURE [dbo].[usp_DoCreateCommInspDocHistory_20200119]
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
						@pCommInspDocNo VARCHAR(20) = NULL OUTPUT
AS

BEGIN

	SET NOCOUNT ON;

    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessDateTime DATETIME = GETDATE(),
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
							WHERE 1=1
							  AND CII.CommInspTypeCode = @CommInspTypeCode 
							  AND CII.CompanyCode = @CompanyCode 
							  AND	 CII.WorkCenterCode = @WorkCenterCode 
							  AND	 ((CII.LineCode = '') OR (CII.LineCode = @LineCode)) 
						   -- AND	 ((CII.RouteCode = '') OR (CII.RouteCode LIKE @RouteCode)) 
							  AND	 ((CII.MachineCode = '') OR (CII.MachineCode = @MachineCode)) 
							  AND	 ((CII.MoldNumber = '') OR (CII.MoldNumber = @MoldNumber)) 
							  AND	 ((CII.ProductGroupCode = '') OR (CII.ProductGroupCode = @ProductGroupCode)) 
							  AND	 ((CII.MaterialCode = '') OR (CII.MaterialCode = @MaterialCode)) 
							  AND	 ((CII.CategoryName = '') OR (CII.CategoryName = @CategoryName))
					     ) 
					
	BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage, '^해당 유형의 검사항목이 등록되어있지 않습니다^', @ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@CommInspTypeCode)
			RETURN
	END

	EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspDocHistory', @CommInspDocNo OUTPUT

	SET @JobDateShift = dbo.fnGetJobDateShiftTimeV3(@ProcessDateTime,@WorkCenterCode)
	SET @JobDate = SUBSTRING(@JobDateShift,1,8)
	SET @ShiftCode = SUBSTRING(@JobDateShift,9,1)
	SET @TimeCode = SUBSTRING(@JobDateShift,10,2)

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
		@ProcessDateTime,
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

