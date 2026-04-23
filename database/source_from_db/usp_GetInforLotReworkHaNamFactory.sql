-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-12-15
-- Description:	Xem các lot Rework
-- exec [usp_GetInforLotReworkHaNamFactory] '','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetInforLotReworkHaNamFactory]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20)=NULL,
	@pProcessLanguage VARCHAR(20)=NULL,
	@pLotNo VARCHAR(20)=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT LotNo,LotNoRework,MaterialCode,ReworkQty,CreateUserID,CreateDateTime from STB_LotReworkInfo_HN where (@pLotNo='' OR LotNo = @pLotNo);
END
