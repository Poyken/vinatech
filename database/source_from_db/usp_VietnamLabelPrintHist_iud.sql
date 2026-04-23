-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-08-18
-- Browsable : true
-- Group : 생산관리
-- Description: 베트남 바코드 정보 변경 및 출력이력
-- Modified:
-- =============================================
CREATE PROCEDURE usp_VietnamLabelPrintHist_iud
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pOriginalBarcode VARCHAR(20)
   ,@pMaterialCode VARCHAR(20)
   ,@pMaterialName NVARCHAR(100)
   ,@pChangeBarcode VARCHAR(20)
   ,@pVoltage VARCHAR(10)
   ,@pFarad VARCHAR(10)
   ,@pRating VARCHAR(10)
   ,@pPartNo NVARCHAR(100)
   ,@pLotQty INT
   ,@pLabelQty INT
   ,@pPackingID VARCHAR(20)
AS
BEGIN
	INSERT INTO STB_VietnamLabelPrintHist (OriginalBarcode, MaterialCode, MaterialName, ChangeBarcode, Voltage
	                                      ,Farad, Rating, PartNo, PackingID, LotQty
										  ,LabelQty, CreateUserID
	) VALUES (@pOriginalBarcode, @pMaterialCode, @pMaterialName, @pChangeBarcode, @pVoltage
	         ,@pFarad, @pRating, @pPartNo, @pPackingID, @pLotQty
			 ,@pLabelQty, @pProcessUserID)
END