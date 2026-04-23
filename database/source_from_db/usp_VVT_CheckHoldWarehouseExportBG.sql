-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VVT_CheckHoldWarehouseExportBG] 
		@pLotID VARCHAR(500) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;
	Declare @VendorLotNoCount INT = 0
	select @VendorLotNoCount=COUNT(*) from STB_MaterialWarehouseInOutHist where LotID=@pLotID and WarehouseInOutCode='O' and TargetMaterialWarehouseCode in ('ROH_BG_WH') and Status_Confirm_Export=0
	if(@VendorLotNoCount>0)
			 RAISERROR('Lot này đang đợi để xuất đi bắc giang!... ' ,16, 1)   
END
