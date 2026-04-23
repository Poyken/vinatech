CREATE PROC [dbo].[usp_update_description_lotnomodlue] 
@pDateBasic DATETIME = NULL,
@pDesction NVARCHAR(500) = NULL,
@pPersonCheck NVARCHAR(50) = NULL,
@pBarcode NVARCHAR(50) = NULL
AS
BEGIN
	--RAISERROR(@pDesction, 16, 1,'' )
	update STB_QC_LOTNO_MODULE set Descriptions=@pDesction where LOTNO=@pBarcode 
END