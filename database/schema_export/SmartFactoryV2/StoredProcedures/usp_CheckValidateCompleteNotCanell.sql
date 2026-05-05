-- Procedure: usp_CheckValidateCompleteNotCanell
-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-06-12
-- Description:	Chỉ bặt khi có khách hàng Audit,Chặn không cho hoàn thành công đoạn sản xuất nếu không có spepart thay thế
-- =============================================
CREATE PROCEDURE usp_CheckValidateCompleteNotCanell
	-- Add the parameters for the stored procedure here
	@pBarcode varchar(50),
	@pWorkCenterCode nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ErrorMessage NVARCHAR(100) -- xuất ra thông báo lỗi
	DECLARE @LineCode VARCHAR(50) -- xem lot đó đang ở line nào
	 -- Lấy ra line hiện tại của code đó
	SELECT TOP 1 
		@LineCode = s.InputLineCode
	FROM STB_SetInfo s
	WHERE s.Barcode = @pBarcode

	-- Kiẻm tra Line code đó đã hết hạn hay chưa
	IF EXISTS (
		SELECT 1
		FROM STB_VN_SparePartLineUsage SPLU WITH(NOLOCK)
		LEFT JOIN STB_VN_SpecialSparePartInfo SSPLI WITH(NOLOCK) 
			ON SSPLI.SparePartCode = SPLU.SparePartCode
		WHERE SPLU.WorkCenterCode = @pWorkCenterCode
		  AND SPLU.LineCode = @LineCode
		  AND SPLU.IsUsing = 1
		  AND (
			-- Trường hợp đã vượt định mức sử dụng
			(SELECT COUNT(LotID) 
			 FROM STB_VN_SpecialSparePartLotInfo SSPLot 
			 WHERE SSPLot.SparePartLotID = SPLU.SparePartLotID
			) >= FLOOR(ISNULL(SSPLI.CycleReplace, 0) / NULLIF(SSPLI.LotQty, 0))
		  )
	)
	BEGIN
		SET @ErrorMessage = N'Linh kiện (spare part) đã hết tuổi thọ và chưa được thay mới. Không thể hoàn thành công đoạn.'
		RAISERROR(@ErrorMessage, 16, 1)
		RETURN
	END

	

END

GO

