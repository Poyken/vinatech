-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2026-03-12
-- Description:	Huỷ link vị trí cho kho thành phẩm Hà Nam
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_CanCelLocationMapRawMaterialsAfterMES]
	-- Add the parameters for the stored procedure here
	@pProcessLanguage VARCHAR(20), 
	@pProcessUserID VARCHAR(20), 
	@pLotNo VARCHAR(20) = NULL 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Locations VARCHAR(50) = '';
    DECLARE @cout INT = 0;

-- Lấy thông tin vị trí và kiểm tra sự tồn tại của PackingID
   SELECT @Locations = Locations, @cout = COUNT(*) 
   FROM FinishGoodMESInstock_HN 
   WHERE LotNo = @pLotNo 
   GROUP BY Locations;
   /*
  --Kiểm tra tồn tại: Nếu không tìm thấy dòng nào
   IF (@cout = 0) 
   BEGIN 
      RAISERROR (N'Mã LotNo này không tồn tại trên hệ thống. Vui lòng kiểm tra lại!', 16, 1); 
      RETURN; 
   END 
   */
  -- Cập nhật: Thực hiện link vị trí mới
    UPDATE FinishGoodMESInstock_HN 
    SET Locations = '' 
    WHERE LotNo = @pLotNo;  

-- Trả về kết quả thành công
    SELECT 
        N'Huỷ Link vị trí thành công ' AS MaterialLotNo, 
        * FROM FinishGoodMESInstock_HN 
    WHERE LotNo = @pLotNo;
END
