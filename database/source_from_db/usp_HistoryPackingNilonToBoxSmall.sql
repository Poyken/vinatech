-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-12
-- Description:	Lịch sử đóng thùng to túi bóng
-- =============================================
CREATE PROCEDURE usp_HistoryPackingNilonToBoxSmall 
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMergeNilonToSmallBox varchar(50)=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>

	SELECT PackingNilonToBoxSmallID,CurrentQty,CreateDateTime,CreateUserID,MaterialCode
          FROM STB_PackingNilonToBoxSmall_HN
    WHERE @pMergeNilonToSmallBox IS NULL 
          OR PackingNilonToBoxSmallID = @pMergeNilonToSmallBox;
END
