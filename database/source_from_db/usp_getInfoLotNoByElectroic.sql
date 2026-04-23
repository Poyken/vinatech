-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-12-02
-- Description: Lấy thông tin máy điện cực và mã Lot theo NVL điện cực nhập vào
-- =============================================
CREATE PROCEDURE [dbo].[usp_getInfoLotNoByElectroic]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20)=null,
	@pProcessLanguage VARCHAR(20)=null,
	@pBarcode VARCHAR(100)=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT T2.MaterialCode,T1.Barcode,T2.MaterialName from STB_RawMaterialInputHist T1 
	left join STB_SetInfo T3 on T3.Barcode=T1.Barcode
		left join STB_MaterialMaster T2 on T3.MaterialCode=T2.MaterialCode
	where T1.RawMaterialBarcode=@pBarcode
END
