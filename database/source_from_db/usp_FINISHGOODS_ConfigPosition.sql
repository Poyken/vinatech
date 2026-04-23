-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-11-15
-- Description:	Tìm kiếm dữ liệu LotNo
-- =============================================
CREATE PROCEDURE [dbo].[usp_FINISHGOODS_ConfigPosition] 
	-- Add the parameters for the stored procedure here
	@pProcessUserID varchar(20),
	@pProcessLanguage varchar(20),
	@pLotNo varchar(20) = NULL,
	@pQty INT=NULL,
	@pPosition VARCHAR(50)=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	@pLotNo AS LotNo,
	@pQty as Qty,
	@pPosition as Position,
	@pProcessUserID as CreateBy,
	getdate() as CreateDateTime
	   
END
