-- =============================================
-- Author: Nguyễn Hải Triều(Dev)
-- Create date: 2026-03-10
-- Description:	Huỷ Link vị trí và cập nhật vị trí cho kho thành phẩm
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_LocationMapFinishGoodHN] 
	-- Add the parameters for the stored procedure here
	@pProcessLanguage VARCHAR(20), 
	@pProcessUserID VARCHAR(20), 
	@pLocation VARCHAR(20) = NULL, 
	@pLotNo VARCHAR(20) = NULL 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @Locations VARCHAR(50) = '';
    DECLARE @cout INT = 0;

-- Lấy thông tin vị trí và kiểm tra sự tồn tại của PackingID
   SELECT @Locations = Locations, @cout = COUNT(*) 
   FROM STB_VN_FINISHGOODS_HN_New 
   WHERE LotNo = @pLotNo 
   GROUP BY Locations;

  -- Kiểm tra tồn tại: Nếu không tìm thấy dòng nào
  IF (@cout = 0) 
  BEGIN 
       RAISERROR (N'Mã LotNo này không tồn tại trên hệ thống. Vui lòng kiểm tra lại!', 16, 1); 
       RETURN; 
  END 
  -- Kiểm tra trạng thái: Nếu đã được link với kho khác
   IF (@Locations IS NOT NULL AND RTRIM(LTRIM(@Locations)) <> '')
   BEGIN 
       DECLARE @errr1 NVARCHAR(100) = N'Mã LotNo đã Link với kho: ' + @Locations + N'. Vui lòng sử dụng chức năng Hủy Link mã Vị trí trước!';
       RAISERROR (@errr1, 16, 1); 
       RETURN; 
   END 

   --Cập nhật: Thực hiện link vị trí mới
    UPDATE STB_VN_FINISHGOODS_HN_New 
    SET Locations = @pLocation 
    WHERE LotNo = @pLotNo;  

  -- Trả về kết quả thành công
   SELECT 
        N'Link thành công vị trí: ' + @pLocation AS MaterialLotNo, 
        * FROM STB_VN_FINISHGOODS_HN_New 
    WHERE LotNo = @pLotNo;
END
