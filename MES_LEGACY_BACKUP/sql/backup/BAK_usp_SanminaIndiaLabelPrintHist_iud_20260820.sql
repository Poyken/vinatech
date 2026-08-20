-- =============================================
-- BACKUP OF usp_SanminaIndiaLabelPrintHist_iud
-- DATE: 2026-08-20
-- =============================================
CREATE PROCEDURE [dbo].[usp_SanminaIndiaLabelPrintHist_iud]
            @pProcessUserID VARCHAR(20) = NULL,
		    @pProcessLanguage VARCHAR(20) = NULL,
            @pSupplierName VARCHAR(50) = NULL,
            @pSanminaPartNumber VARCHAR(50) = NULL,
            @pPartDesc NVARCHAR(100) = NULL,
            @pMFR VARCHAR(50) = NULL,
            @pMPN VARCHAR(50) = NULL,
            @pQuantity VARCHAR(10) = NULL,
            @pPONumber VARCHAR(50) = NULL,
            @pLotNo VARCHAR(50) = NULL,
            @pLotCode VARCHAR(6) = NULL,
            @pPackingDate VARCHAR(6) = NULL,
            @pInspEmpID VARCHAR(10) = NULL,
            @pInspEmpName NVARCHAR(100) = NULL,
            @pCartonBoxNo VARCHAR(10) = NULL,
            @pBoxSerialNo VARCHAR(50) = NULL,
            @pPartNumber VARCHAR(50) = NULL,
            @pLabelClass VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @pProcessLanguage IS NULL SET @pProcessLanguage = 'vi-VN';
	DECLARE @FinalPartNumber VARCHAR(50) = ISNULL(@pSanminaPartNumber, @pPartNumber);

	-- 1. Lưu vào bảng lịch sử gốc STB_SanminaIndiaLabelPrintHist (Lưu đủ cả Outer và 2 Inner)
	INSERT INTO STB_SanminaIndiaLabelPrintHist (
            SupplierName,
            SanminaPartNumber,
            PartDesc,
            MFR,
            MPN,
            Quantity,
            PONumber,
            LotNo,
            LotCode,
            PackingDate,
            InspEmpID,
            InspEmpName,
            CartonBoxNo,
            PrintTime,
            PrintUserID,
            BoxSerialNo
    )
    VALUES (
            @pSupplierName,
            @FinalPartNumber,
            @pPartDesc,
            @pMFR,
            @pMPN,
            @pQuantity,
            @pPONumber,
            @pLotNo,
            @pLotCode,
            @pPackingDate,
            @pInspEmpID,
            @pInspEmpName,
            @pCartonBoxNo,
            GETDATE(),
            @pProcessUserID,
            @pBoxSerialNo
    );

	-- 2. Đồng bộ tiến độ vào STB_SanminaShipmentPlan & STB_SanminaShipmentPlanLot
	-- CHỈ TĂNG TIẾN ĐỘ THÙNG KHI LÀ NHÃN OUTER (Tránh bị tăng x3 do 1 thùng in 3 tem: 1 Outer + 2 Inner)
	DECLARE @IsOuterLabel BIT = 0;
	IF @pLabelClass = 'Outer' OR @pBoxSerialNo LIKE '%,%' OR (@pCartonBoxNo IS NOT NULL AND @pCartonBoxNo NOT LIKE '02/0[1-9]')
	BEGIN
		SET @IsOuterLabel = 1;
	END

	IF @IsOuterLabel = 1
	BEGIN
		DECLARE @TargetPlanID INT = NULL,
				@CurPrinted INT = 0,
				@TotalBox INT = 0;

		-- Tìm Plan theo PONumber hoặc Plan đang IsActive = 1
		IF @pPONumber IS NOT NULL AND LTRIM(RTRIM(@pPONumber)) <> ''
		BEGIN
			SELECT TOP 1 
				@TargetPlanID = PlanID,
				@CurPrinted = PrintedBoxCount,
				@TotalBox = TotalBox
			FROM STB_SanminaShipmentPlan WITH(NOLOCK)
			WHERE PONumber = LTRIM(RTRIM(@pPONumber)) AND IsActive = 1;
		END

		IF @TargetPlanID IS NULL
		BEGIN
			SELECT TOP 1 
				@TargetPlanID = PlanID,
				@CurPrinted = PrintedBoxCount,
				@TotalBox = TotalBox
			FROM STB_SanminaShipmentPlan WITH(NOLOCK)
			WHERE IsActive = 1
			ORDER BY UpdateDateTime DESC, CreateDateTime DESC;
		END

		IF @TargetPlanID IS NOT NULL
		BEGIN
			DECLARE @NewPrintedCount INT = @CurPrinted + 1;

			-- Cập nhật số thùng đã in (chỉ tăng đúng 1 thùng)
			UPDATE STB_SanminaShipmentPlan
			SET PrintedBoxCount = @NewPrintedCount,
				Status = CASE WHEN @NewPrintedCount >= @TotalBox THEN 'COMPLETED' ELSE 'ACTIVE' END,
				FinishDateTime = CASE WHEN @NewPrintedCount >= @TotalBox THEN GETDATE() ELSE FinishDateTime END,
				UpdateUserID = @pProcessUserID,
				UpdateDateTime = GETDATE()
			WHERE PlanID = @TargetPlanID;

			-- Ghi nhận chi tiết thùng vào STB_SanminaShipmentPlanLot
			INSERT INTO STB_SanminaShipmentPlanLot (
				PlanID,
				LotNo,
				BoxSeq,
				CartonBoxNo,
				BoxSerialNo,
				PrintedTime,
				PrintUserID
			)
			VALUES (
				@TargetPlanID,
				ISNULL(@pLotNo, ''),
				@NewPrintedCount,
				ISNULL(@pCartonBoxNo, ''),
				@pBoxSerialNo,
				GETDATE(),
				@pProcessUserID
			);
		END
	END

END
