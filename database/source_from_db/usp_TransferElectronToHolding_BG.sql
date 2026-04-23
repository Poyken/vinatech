-- =============================================
-- Author:		MR.DUY
-- Create date: 2024-10-04
-- Description:	Chuyển điện cực vào kho Holding cho bắc giang
-- =============================================
CREATE PROCEDURE usp_TransferElectronToHolding_BG
		@pProcessUserID varchar(20),
		@pProcessLanguage varchar(20),
		@pBarcode varchar(20) = NULL
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @count int =0
	select @count=count(*) from Stb_SlittingStock_VVT where barcode=@pBarcode
	if(@count<1)
		begin
				DECLARE @errNullData  nvarchar(200)
				set @errNullData = N'Bạn chưa bắn vị trí cho lot này!...';
				RAISERROR(@errNullData,16,1)
				return;
		end
	else
		begin
			update Stb_SlittingStock_VVT
			set warehouseCode='HOLDING_BG_WH'
			where barcode=@pBarcode
		end
END
