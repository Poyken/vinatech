-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-10-14
-- Description:	In tem sau khi ở công đoạn Aging
-- exec usp_PrinterMarkingAfterAging '','','
-- =============================================
CREATE PROCEDURE [dbo].[usp_PrinterMarkingAfterAging]
	-- Add the parameters for the stored procedure here
	 @pProcessUserID VARCHAR(20) =NULL,
	 @pProcessLanguage VARCHAR(20) =NULL,
     @pLotNo NVARCHAR(50) = NULL,
	 @pDividePackagingQty INT=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SET NOCOUNT ON;

	DECLARE 
		@DividePackagingID NVARCHAR(50),
		@psagemcom VARCHAR(10) = 'sagemcom',
		@LabelType VARCHAR(50) = 'BoxLabel',
		@DividePackagingQty INT = ISNULL(@pDividePackagingQty, 0),
		@ControlNo NVARCHAR(50),
		@ProdQty INT,
		@MaterialCode NVARCHAR(50)

	--  Lấy ControlNo tương ứng LotNo
	SELECT @ControlNo = ControlNo 
	FROM STB_SetInfo 
	WHERE Barcode = @pLotNo

	--IF @ControlNo IS NULL
	--BEGIN
		--RAISERROR(N'Không tìm thấy ControlNo tương ứng LotNo %s trong STB_SetInfo.', 16, 1, @pLotNo)
		--RETURN
	--END

	-- Lấy thông tin sản lượng và mã vật tư
	SELECT TOP (1)
		@ProdQty = ProdQty,
		@MaterialCode = MaterialCode
	FROM STB_ProdRouteHist
	WHERE ControlNo = @ControlNo
	  AND RouteCode = 'VE06'

	--IF @ProdQty IS NULL OR @MaterialCode IS NULL
	--BEGIN
		--RAISERROR(N'Không tìm thấy dữ liệu trong STB_ProdRouteHist với ControlNo %s.', 16, 1, @ControlNo)
		--RETURN
	--END

	--  Tạo DividePackagingID nếu chưa có LotNo trong bảng chia
	IF NOT EXISTS (SELECT 1 FROM STB_DevideLotnoMarking WHERE LotNo = @pLotNo)
	BEGIN
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DevideLotnoMarking', @DividePackagingID OUTPUT

		IF @DividePackagingID IS NULL
		BEGIN
			RAISERROR(N'Lỗi khi tạo DividePackagingID.', 16, 1)
			RETURN
		END

		INSERT INTO STB_DevideLotnoMarking (
			DividePackagingID,
			LotNo,
			Qty,
			MaterialCode,
			CreateDateTime,
			CreateUserID
		)
		VALUES (
			@DividePackagingID,
			@pLotNo,
			@ProdQty,
			@MaterialCode,
			GETDATE(),
			@pProcessUserID
		)
	END

	--  Trả kết quả ra ngoài
	SELECT TOP (1)
		DP.DividePackagingID,
		DP.MaterialCode,
		DP.LotNo,
		DP.Qty,
		@DividePackagingQty AS QtySliptBox,
		0 AS QtySliptBox_Export
	FROM STB_DevideLotnoMarking DP
	WHERE DP.LotNo = @pLotNo
END
