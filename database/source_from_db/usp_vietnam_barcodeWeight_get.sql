CREATE PROC [dbo].[usp_vietnam_barcodeWeight_get] 
@pFromDate datetime=null,
@pToDate datetime=null
AS
BEGIN

if @pFromDate is null set @pFromDate = getdate()
if @pToDate is null set @pToDate = getdate()

set @pFromDate = convert(datetime,convert(varchar(10),@pFromDate,120) +' 10:00:00',120)
set @pToDate = convert(datetime,convert(varchar(10),dateadd(day,1,@pToDate),120) +' 10:00:00',120)

	SELECT  isnull(bb.MaterialCode,cc.BefMaterialCode) as MaterialCode,dd.MaterialName,aa.*
	FROM STB_VIETNAM_BARCODEWEIGHT aa with(nolock) 
	left outer join STB_SetInfo bb  with(nolock) on aa.Barcode=bb.Barcode
	left outer join STB_LotChangeMaterialHistory cc  with(nolock) on aa.Barcode=cc.OldBarcode 
	left outer join STB_MaterialMaster dd  with(nolock) on isnull(bb.MaterialCode,cc.BefMaterialCode)=dd.MaterialCode
	where aa.CreateDateTime between @pFromDate and @pToDate
	ORDER BY aa.CREATEDATETIME DESC 	

END
