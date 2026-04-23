-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-04-26
-- Description:	Lưu lại lịch sử in tem ở màn hình HN709.
-- =============================================
CREATE PROCEDURE [dbo].[usp_SaveHistoryPrinter]
		@pProcessUserID VARCHAR(20),
	    @pProcessLanguage VARCHAR(20),
		@pPackingID  varchar(50)=NULL,
		@pPackingOutPutFinishGoodsID  varchar(50)=NULL,
		@pCurrentQty  int=0,
		@pLotNo  varchar(50)=NULL,
		@pMarkingLetter varchar(50)=NULL,
		@pMaterialCode varchar(50)=NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @IsAutoKey BIT
    DECLARE @IsLoopIUD BIT
	DECLARE @PackingID VARCHAR(20)
	if NOT EXISTS (
    SELECT 1
    FROM STB_CreateTemFakeForHaNam
    WHERE PackingID = @pPackingID
	)
	BEGIN
		if(@pPackingOutPutFinishGoodsID is null or @pPackingOutPutFinishGoodsID = '')
		BEGIN
			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CreateTemFakeForHaNam',@PackingID OUTPUT
		END
		-- Insert statements for procedure here
		INSERT INTO [dbo].[STB_CreateTemFakeForHaNam]
			   ([PackingID]
			   ,[PackingOutPutFinishGoodsID]
			   ,[LotNo]
			   ,[MarkingLetter]
			   ,[MaterialCode]
			   ,[LotQty]
			   ,[CreateDateTime]
			   ,[CreateUserID])
		 VALUES
			   (@PackingID
			   ,@pPackingOutPutFinishGoodsID
			   ,@pLotNo
			   ,@pMarkingLetter
			   ,@pMaterialCode
			   ,@pCurrentQty
			   ,getdate()
			   ,@pProcessUserID
			   )
	END
END


