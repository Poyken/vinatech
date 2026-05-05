-- Procedure: usp_ClaimOverRepairMachineToSendMail
-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2026-01-07
-- Description:	Viết chức năng cập nhật là gửi Mail nếu mà quá 60 phút kế từ lúc báo lỗi không sửa xong
-- =============================================
CREATE PROCEDURE [dbo].[usp_ClaimOverRepairMachineToSendMail] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE DefectReportsAndon_BG
	SET IsMailSent=1
	--- Tự động thêm vào bảng tạm sử dụng trigger
	OUTPUT inserted.*
    WHERE Status=0 and IsMailSent=0 and CreatedAt <= DATEADD(HOUR, -1, GETDATE())

END

GO

