-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_vietnam_checkbarcode] 
@pLotPacking1 Varchar(50),
@pLotPacking2 Varchar(50),
@pLotPacking3 Varchar(50),
@pRemark nVarchar(1000)=null
AS
BEGIN
	INSERT INTO  STB_VietNam_CheckBarcode (Barcode1, Barcode2, Barcode3,REMARK)
	VALUES (@pLotPacking1,@pLotPacking2,@pLotPacking3,@pRemark)
	
END
