
-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-04-09
-- Browsable : true
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_SaveSettingPackLabel]                                  
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotNo VARCHAR(50) = NULL,
						@pOriginalPartno VARCHAR(50) = NULL,
						@pVVorVJ VARCHAR(10) = NULL,
						@pnewPartNo VARCHAR(50) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	declare @count INT=0
	
	select @count = count(*)
	from [STB_Vietnam_SettingPackLabel] WITH(NOLOCK) 
	where [LotNo] = @pLotNo

	if(@count>0)
	begin
		declare @errr VARCHAR(100) = 'Khong the dang ky Lot nay nua, vi da duoc dang ky roi'
		raiserror (@errr, 16,1)
		return
	end



	select @count = count(*)
		from  stb_setinfo  WITH(NOLOCK) 
			where  Barcode = @pLotNo and Barcode like 'VJ%'
	if 	@count = 0 
	begin 
		declare   @errr1 VARCHAR(100) = 'Khong co du lieu tren he thong HanQuoc cua Lot nay' 
		raiserror (@errr1, 16, 1) 
		return 
	end 



	insert into [STB_Vietnam_SettingPackLabel] ([LotNo]      ,[OriginalPartno]      ,[VVorVJ], [newPartNo])
	values(@pLotNo,@pOriginalPartno,@pVVorVJ,@pnewPartNo)

END
