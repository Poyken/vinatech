-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2025-03-04
-- Browsable : true
-- Group : 박스 수량 나누기
-- Description: 
-- =============================================
CREATE Proc [dbo].[usp_SplitPackingBox]
     @pProcessLanguage VARCHAR(20)
	,@pProcessUserID VARCHAR(20)
	,@pLotID VARCHAR(50)
	,@pSplitQty NUMERIC(20,2)
AS
BEGIN
	Declare @LotID VARCHAR(50) = @pLotID 
	Declare @SplitQty NUMERIC(20,2) = @pSplitQty
	Declare @MaterialLotNo VARCHAR(20)

	SELECT TOP 1 @MaterialLotNo = MaterialLotNo FROM STB_MaterialLotInfo WHERE LotID = @LotID

	--exec usp_DoSplitLot @pProcessLanguage, @pProcessUserID, @MaterialLotNo, @SplitQty
	exec usp_DoSplitLotWithAllNewPackingID @pProcessLanguage, @pProcessUserID, @MaterialLotNo, @SplitQty
END