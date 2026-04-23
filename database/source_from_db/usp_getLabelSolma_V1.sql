-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-27
-- Description:	In tem cho khách hàng solma
-- =============================================
CREATE PROCEDURE [dbo].[usp_getLabelSolma_V1] 
	-- Add the parameters for the stored procedure here
    @pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pSolumCode VARCHAR(100)=NULL,
	@pVendorCode VARCHAR(100)=NULL,
	@pLotNo VARCHAR(100)=NULL,
	@pVendorPN VARCHAR(100)=NULL,
	@pDateCode DATETIME,
	@pQty int=1

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
    DECLARE @DateFormatted VARCHAR(20);
    DECLARE @Barcode NVARCHAR(500);
    DECLARE @QRCode NVARCHAR(500);

    -- Chuyển từ yyyyMMdd sang yymmdd
    SET @DateFormatted = FORMAT(@pDateCode, 'yyMMdd')

    -- Barcode chỉ gồm SolumCode, VendorCode, DateFormatted, Qty
    SET @Barcode = CONCAT(@pSolumCode, ' ', @pVendorCode, ' ', @DateFormatted, ' ', @pQty);

    -- QRCode gồm đầy đủ SolumCode, VendorCode, LotNo, VendorPN, DateFormatted, Qty
    SET @QRCode = CONCAT(@pSolumCode, ' ', @pVendorCode, ' ', @pLotNo, ' ', @pVendorPN, ' ', @DateFormatted, ' ', @pQty);

    SELECT  
        @pSolumCode AS SolumCode,
        @pVendorCode AS VendorCode,
        @pLotNo AS LotNo,
        @pVendorPN AS VendorPN,
        @DateFormatted AS DateCode,
        @pQty AS Qty,
        @Barcode AS Barcode,
        @QRCode AS QRCode,
		'Report' AS CommandType
END
