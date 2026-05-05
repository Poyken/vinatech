-- Procedure: usp_BloomBoxLabalPrintHist_iud

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-09-12
-- Browsable : true
-- Group : 생산관리
-- Description: 블룸向 박스라벨 출력
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_BloomBoxLabalPrintHist_iud]
						@pProcessUserID VARCHAR(20)
					   ,@pProcessLanguage VARCHAR(20)
					   ,@pMaterialCode VARCHAR(20) = NULL
                       ,@pMaterialName NVARCHAR(200) = NULL
                       ,@pLotID VARCHAR(20) = NULL
                       ,@pPackingID VARCHAR(20) = NULL
                       ,@pLabelQty NUMERIC(20,4) = NULL
                       ,@pLotQty NUMERIC(20,4) = NULL
                       ,@pCurrentQty NUMERIC(20,4) = NULL
                       ,@pLotNo VARCHAR(20) = NULL
                       ,@pVoltage VARCHAR(10) = NULL
                       ,@pFarad VARCHAR(10) = NULL
                       ,@pRating VARCHAR(10) = NULL
                       ,@pPartNo VARCHAR(50) = NULL
                       ,@pStockAttrib1 VARCHAR(20) = NULL
                       ,@pDC VARCHAR(10) = NULL
                       ,@pMarkingLetter VARCHAR(50) = NULL
					   ,@pSalesPONo VARCHAR(50) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE  @MaterialCode VARCHAR(20) = @pMaterialCode
            ,@MaterialName NVARCHAR(200) = @pMaterialName
            ,@LotID VARCHAR(20) = @pLotID
            ,@PackingID VARCHAR(20) = @pPackingID
            ,@LabelQty NUMERIC(20,4) = @pLabelQty
            ,@LotQty NUMERIC(20,4) = @pLotQty
            ,@CurrentQty NUMERIC(20,4) = @pCurrentQty
            ,@LotNo VARCHAR(20) = @pLotNo
            ,@Voltage VARCHAR(10) = @pVoltage
            ,@Farad VARCHAR(10) = @pFarad
            ,@Rating VARCHAR(10) = @pRating
            ,@PartNo VARCHAR(50) = @pPartNo
            ,@StockAttrib1 VARCHAR(20) = @pStockAttrib1
            ,@DC VARCHAR(10) = @pDC
            ,@MarkingLetter VARCHAR(50) = @pMarkingLetter
			,@SalesPONo VARCHAR(50) = @pSalesPONo

	INSERT INTO STB_BloomBoxLabalPrintHist (MaterialCode
                                           ,MaterialName
                                           ,LotID
                                           ,PackingID
                                           ,LabelQty
                                           ,LotQty
                                           ,CurrentQty
                                           ,LotNo
                                           ,Voltage
                                           ,Farad
                                           ,Rating
                                           ,PartNo
                                           ,StockAttrib1
                                           ,DC
                                           ,MarkingLetter
										   ,SalesPONo)
	SELECT @MaterialCode
          ,@MaterialName
          ,@LotID
          ,@PackingID
          ,@LabelQty
          ,@LotQty
          ,@CurrentQty
          ,@LotNo
          ,@Voltage
          ,@Farad
          ,@Rating
          ,@PartNo
          ,@StockAttrib1
          ,@DC
          ,@MarkingLetter
		  ,@SalesPONo
			
END
GO

