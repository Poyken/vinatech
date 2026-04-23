-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-12
-- Description:	Lịch sử đóng thùng to tem thường
-- =============================================
CREATE PROCEDURE [dbo].[usp_HistoryPackingOutPutFinishGoods]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMergeParentId varchar(50)=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT PackingOutPutFinishGoodsID,CurrentQty,CreateDateTime,CreateUserID,MaterialCode,StatusExport
          FROM STB_PackingOutPutFinishGoods_HN
    WHERE @pMergeParentId IS NULL 
          OR PackingOutPutFinishGoodsID = @pMergeParentId;
END
