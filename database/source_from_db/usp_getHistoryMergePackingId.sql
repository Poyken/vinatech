-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2026-01-15
-- Description:	Xem lại lịch sử gộp packing
-- =============================================
CREATE PROCEDURE usp_getHistoryMergePackingId 
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPackingID VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT LotNo,PackingId,Qty,Marking,MaterialCode,CreateUserId,CreateDateTime,CombiPackkingAndMarking from STB_PackingHN710_HN
	where @pPackingID is null or PackingId=@pPackingID
END
