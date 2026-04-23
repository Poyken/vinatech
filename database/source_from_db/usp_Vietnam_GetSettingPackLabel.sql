
-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-04-09
-- Browsable : true
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_GetSettingPackLabel]                                  
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotNo VARCHAR(100) = NULL
AS

BEGIN
	SET NOCOUNT ON;


	declare @count INT=0

	declare @barcode VARCHAR(20) = dbo.fn_VVT_getLastestBarCode(@pLotNo)


	select LOTNO , CODEPRODUCTION, QTYLOTNO, MarkingLetters, replace(MarkingLetters,'','') as PartNo,
	'VVT_MarkingLabel' LabelType,
	1 LabelQty,
	'VVT_MarkingLabel' FormatName,
	'' PrinterName,
	'Report' CommandType

	FROM STB_VN_BENDING_TAPPING WITH(NOLOCK) 
	where lotno in (
			select @pLotNo as lotno
			union
			select lotno from STB_MaterialLotInfo  WITH(NOLOCK) where PackingID in (
				select PackingID from STB_MaterialLotInfo WITH(NOLOCK)  where lotno in (@pLotNo,@barcode)
		)
	)

	----select @count = count(*)
	----	from   STB_Vietnam_SettingPackLabel WITH(NOLOCK) 
	----		where  LotNo = @pLotNo
	----if 	@count > 0 
	----begin
	----	declare   @errr VARCHAR(100) = 'Khong the dang ky Lot nay nua, vi da duoc dang ky roi'
	----	raiserror (@errr, 16, 1)
	----	return
	----end


	--select @count = count(*)
	--	from  stb_setinfo  WITH(NOLOCK) 
	--		where  Barcode = @pLotNo and Barcode like 'VJ%'
	--if 	@count = 0 
	--begin 
	--	declare   @errr1 VARCHAR(100) = 'Khong co du lieu tren he thong HanQuoc cua Lot nay' 
	--	raiserror (@errr1, 16, 1) 
	--	return 
	--end 

	
	--  select Barcode as LotNo,
	--  RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12))) as OriginalPartno,
	--  vspl.VVorVJ,
	--  vspl.newLotNo,
	--  vspl.newPartNo,
	--  vspl.PrintTime
	--  from stb_setinfo si WITH(NOLOCK) 
	--  left outer join STB_Vietnam_SettingPackLabel   vspl WITH(NOLOCK)  on vspl.lotno = si.barcode
	--  left outer join stb_materialMaster mm  WITH(NOLOCK) on si.materialcode = mm.MaterialCode
	--  where Barcode=@pLotNo

END

