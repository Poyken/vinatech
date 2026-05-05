-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-23
-- Description:	Thực hiện thay đổi mã nguyên vật liệu và lịch sử thay đổi code
-- exec usp_ChangeMaterialCode_HN '','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_ChangeMaterialCode_HN] 
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPackingID VARCHAR(50)=NULL,
	@pLotID VARCHAR(50)=null

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- Nếu cả 2 đều NULL -> lấy tất cả
	-- Xử lý chuỗi rỗng thành NULL
	IF @pPackingID = '' SET @pPackingID = NULL;
	IF @pLotID = '' SET @pLotID = NULL;

	-- Nếu cả 2 đều NULL -> lấy tất cả
	IF @pPackingID IS NULL AND @pLotID IS NULL
	BEGIN
		SELECT * FROM STB_ChangeMaterialCode_HN
	END
	ELSE
	BEGIN
		SELECT * 
		FROM STB_ChangeMaterialCode_HN
		WHERE 
			(PackingID = @pPackingID OR LotID = @pLotID)
			
			
	END
END
