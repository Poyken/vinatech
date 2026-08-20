IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_SanminaIndiaLabelPrintHist_iud]') AND type in (N'P', N'PC'))
    EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_SanminaIndiaLabelPrintHist_iud] AS SELECT 1 AS Stub;'
GO

ALTER PROCEDURE [dbo].[usp_SanminaIndiaLabelPrintHist_iud]
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
            @pPartNumber VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @pProcessLanguage IS NULL SET @pProcessLanguage = 'vi-VN';
	DECLARE @FinalPartNumber VARCHAR(50) = ISNULL(@pSanminaPartNumber, @pPartNumber);

	-- 1. Lưu vào bảng lịch sử gốc STB_SanminaIndiaLabelPrintHist
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
	DECLARE @TargetPlanID INT = NULL,
			@CurPrinted INT = 0,
			@TotalBox INT = 0;

	-- Tìm Plan theo PONumber hoặc Plan đang ACTIVE
	IF @pPONumber IS NOT NULL AND LTRIM(RTRIM(@pPONumber)) <> ''
	BEGIN
		SELECT TOP 1 
			@TargetPlanID = PlanID,
			@CurPrinted = PrintedBoxCount,
			@TotalBox = TotalBox
		FROM STB_SanminaShipmentPlan WITH(NOLOCK)
		WHERE PONumber = LTRIM(RTRIM(@pPONumber)) AND Status = 'ACTIVE';
	END

	IF @TargetPlanID IS NULL
	BEGIN
		SELECT TOP 1 
			@TargetPlanID = PlanID,
			@CurPrinted = PrintedBoxCount,
			@TotalBox = TotalBox
		FROM STB_SanminaShipmentPlan WITH(NOLOCK)
		WHERE Status = 'ACTIVE'
		ORDER BY UpdateDateTime DESC, CreateDateTime DESC;
	END

	IF @TargetPlanID IS NOT NULL
	BEGIN
		DECLARE @NewPrintedCount INT = @CurPrinted + 1;

		-- Cập nhật số thùng đã in
		UPDATE STB_SanminaShipmentPlan
		SET PrintedBoxCount = @NewPrintedCount,
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

		-- Nếu đã in đủ số thùng -> Tự động chuyển COMPLETED
		IF @NewPrintedCount >= @TotalBox
		BEGIN
			UPDATE STB_SanminaShipmentPlan
			SET Status = 'COMPLETED',
				FinishDateTime = GETDATE(),
				UpdateUserID = @pProcessUserID,
				UpdateDateTime = GETDATE()
			WHERE PlanID = @TargetPlanID;
		END
	END

END
GO