-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-07-11
-- Description:	Export Slitting Knife
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_ExportSlittingKnife_iud]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pSlittingKnifeCode VARCHAR(30),
		@pMachineCode VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Error NVARCHAR(500)
	DECLARE @StartNumber INT = 1
	DECLARE @NewLotID VARCHAR(50)
	DECLARE @Barcode VARCHAR(30)
	DECLARE @SlittingKnifeLotID VARCHAR(50)
	DECLARE @count INT = 1

	IF(@pSlittingKnifeCode NOT IN (SELECT SlittingKnifeCode FROM STB_VN_SlittingKnifeInfo))  -- nếu nhập mã khác trên hệ thống
		BEGIN
			set @Error=N'Mã Dao cắt không có trên hệ thống, vui lòng kiểm tra lại!'
			RAISERROR(@Error,16, 1)
			return;
		END

	IF(@pMachineCode NOT IN (SELECT MachineCode FROM STB_ProductMachine WHERE RouteCode = 'V-11_BG'))  -- nếu nhập mã khác trên hệ thống
		BEGIN
			set @Error=N'Mã Máy cắt không có trên hệ thống, vui lòng kiểm tra lại!'
			RAISERROR(@Error,16, 1)
			return;
		END
	

	EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_VN_SlittingKnifeInUse', @NewLotID OUTPUT
		set @SlittingKnifeLotID = @NewLotID

	-- Kết thúc sử dụng dao cũ
	UPDATE STB_VN_SlittingKnifeInUse
	SET UsingStatus = 0,
		EndDate = GETDATE()
	WHERE 
		MachineCode = @pMachineCode
		AND UsingStatus = 1


	INSERT INTO	                -- Tạo dao đang sử dụng
				STB_VN_SlittingKnifeInUse
					(
						SlittingKnifeLotID,
						SlittingKnifeCode,
						MachineCode,
						UsingStatus,
						CreateDateTime,
						CreateUserID									
					)

			VALUES
					(
						@SlittingKnifeLotID,
						@pSlittingKnifeCode,
						@pMachineCode,
						1,
						GETDATE(),
						@pProcessUserID
					)
	

END
