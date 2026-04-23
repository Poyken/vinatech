-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-03-26
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateHelaOutBoxBarcode]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBatchID VARCHAR(20),
	@pLotQty INT
AS
BEGIN
	SET NOCOUNT ON;

	Declare @BatchID VARCHAR(20) = @pBatchID
	Declare @LotQty INT = @pLotQty
	--Declare @CountQtyHela INT =0 --Mr.Duy add khi tạo tem thùng

	
	--select @CountQtyHela=count(*) from STB_HelaBarcode where BatchID=@BatchID
	DELETE FROM STB_HelaBarcodeOutBoxHist WHERE LotNo = @BatchID

	INSERT INTO STB_HelaBarcodeOutBoxHist (LotNo, LotQty) VALUES (@BatchID, @LotQty)

END


