-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2019-07-22
-- Description : 패킹수량 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE usp_PackingQtyPerSize_popup
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@Barcode VARCHAR(20) = @pBarcode,
			@ProdSize VARCHAR(10)

	SELECT @ProdSize = RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBISizeH))
	  FROM STB_ModelBasicInfo
	 WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo WHERE Barcode = @Barcode)

	SELECT  ROW_NUMBER() OVER ( ORDER BY PQPS.ProdSize, PQPS.PackingQty ASC) AS Seq,
			PQPS.ProdSize,
			PQPS.PackingQty
	FROM
			STB_PackingQtyPerSize PQPS
	WHERE
			PQPS.ProdSize = @ProdSize
    ORDER BY PQPS.PackingQty
END