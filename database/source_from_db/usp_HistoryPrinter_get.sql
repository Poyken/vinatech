-- =============================================
-- Author:		Nguyen Hai Trieu
-- Create date: 2028-05-06
-- Description:	Information Save History Printer
-- =============================================
CREATE PROCEDURE [dbo].[usp_HistoryPrinter_get]
	-- Add the parameters for the stored procedure here
	@pPackingID  varchar(50)=NULL,
    @pPackingOutPutFinishGoodsID  varchar(50)=NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SELECT * FROM [STB_CreateTemFakeForHaNam]
	SET NOCOUNT ON;

     SELECT
	 HP.PackingID,
	 HP.PackingOutPutFinishGoodsID,
	 HP.LotNo,
	 HP.MarkingLetter,
	 HP.MaterialCode,
	 HP.Lotqty,
	 HP.CreateDateTime, 
	 HP.CreateUserID
	 FROM STB_CreateTemFakeForHaNam HP
	 WHERE
         (@pPackingID IS NULL OR HP.PackingID = @pPackingID)
        --AND (@pPackingOutPutFinishGoodsID IS NULL OR HP.PackingOutPutFinishGoodsID = @pPackingOutPutFinishGoodsID)
END
