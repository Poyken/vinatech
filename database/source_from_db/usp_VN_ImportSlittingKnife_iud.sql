-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-07-09
-- Description:	Export Slitting Knife
-- =============================================
CREATE PROCEDURE usp_VN_ImportSlittingKnife_iud
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pSlittingKnifeCode VARCHAR(30),
		@pIOQty INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Error NVARCHAR(500)
	DECLARE @StartNumber INT = 1

	DECLARE @count INT = 1

	IF(@pSlittingKnifeCode NOT IN (SELECT SlittingKnifeCode FROM STB_VN_SlittingKnifeInfo))  -- nếu nhập mã khác trên hệ thống
		BEGIN
			set @Error=N'Mã Dao cắt đã nhập không có trên hệ thống, vui lòng kiểm tra lại!'
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
			STB_VN_SlittingKnifeIOHist
				(
					SlittingKnifeCode,
					IOType,
					IOQty,
					CreateDateTime,
					CreateUserID									
				)

		VALUES
				(
					@pSlittingKnifeCode,
					'IN',
					@pIOQty,
					GETDATE(),
					@pProcessUserID
				)


END
