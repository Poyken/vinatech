-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 모듈관리
-- Browsable : true
-- Create date : 2026-04-22
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE usp_DaifukuManualLabelPrintHist_get
	@pProcessUserID VARCHAR(20)=null,
	@pProcessLanguage VARCHAR(20)=null,
	@pBarcode VARCHAR(50),
	@pVolt VARCHAR(20),
	@pFarad VARCHAR(20),
	@pDate VARCHAR(20)
AS
BEGIN
	Declare @Barcode VARCHAR(50) = @pBarcode
	       ,@Volt VARCHAR(20) = @pVolt
	       ,@Farad VARCHAR(20) = @pFarad
	       ,@Date VARCHAR(20) = @pDate

	SELECT @Barcode AS Barcode
	      ,@Volt AS Volt
		  ,@Farad AS Farad
		  ,@Date AS [Date]
		  ,'Report' AS CommandType
END