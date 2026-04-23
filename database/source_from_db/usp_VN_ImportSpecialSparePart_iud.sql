-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-05
-- Description:	Import Special Sparepart
-- =============================================
CREATE PROCEDURE usp_VN_ImportSpecialSparePart_iud
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pSparePartCode VARCHAR(30),
		@pIOQty INT,
		@pWorkCenterCode VARCHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Error NVARCHAR(500)
	DECLARE @StartNumber INT = 1

	DECLARE @count INT = 1

	IF(@pSparePartCode NOT IN (SELECT SparePartCode FROM STB_VN_SpecialSparePartInfo))  -- nếu nhập mã khác trên hệ thống
		BEGIN
			set @Error=N'Mã SparePart đã nhập không có trên hệ thống, vui lòng kiểm tra lại!'
			RAISERROR(@Error,16, 1)
			return;
		END

	IF(@pIOQty <=0)  -- nếu nhập số lượng nhỏ hơn 0 thì báo lỗi
		BEGIN
			set @Error=N'Số lượng nhập kho phải lớn hơn 0 !'
			RAISERROR(@Error,16, 1)
			return;
		END


	INSERT INTO	
			STB_VN_SpecialSparePartIOHist
				(
					SparePartCode,
					IOType,
					IOQty,
					WorkCenterCode,
					CreateDateTime,
					CreateUserID									
				)

		VALUES
				(
					@pSparePartCode,
					'IN',
					@pIOQty,
					@pWorkCenterCode,
					GETDATE(),
					@pProcessUserID
				)
END
