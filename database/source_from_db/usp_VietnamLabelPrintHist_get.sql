-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-08-18
-- Browsable : true
-- Group : 생산관리
-- Description: 베트남 바코드 정보 변경 및 출력이력
-- Modified:
-- =============================================
CREATE PROCEDURE usp_VietnamLabelPrintHist_get
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pOriginalBarcode VARCHAR(20) = NULL
   ,@pMaterialCode VARCHAR(20) = NULL
   ,@pChangeBarcode VARCHAR(20) = NULL
   ,@pFromDate DATE = NULL
   ,@pToDate DATE = NULL
AS
BEGIN
	Declare @OriginalBarcode VARCHAR(20) = CASE WHEN ISNULL(@pOriginalBarcode, '') = '' THEN '*' ELSE @pOriginalBarcode END
	       ,@MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
		   ,@ChangeBarcode VARCHAR(20) = CASE WHEN ISNULL(@pChangeBarcode, '') = '' THEN '*' ELSE @pChangeBarcode END
		   ,@FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 08:30:00'
		   ,@ToDate DATETIME = CONVERT(CHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'

	SELECT VLPH.VietnamLabelPrintHistNo
          ,VLPH.OriginalBarcode
          ,VLPH.MaterialCode
          ,VLPH.MaterialName
          ,VLPH.ChangeBarcode
          ,VLPH.Voltage
          ,VLPH.Farad
          ,VLPH.Rating
          ,VLPH.PartNo
          ,VLPH.PackingID
          ,VLPH.LotQty
          ,VLPH.LabelQty
          ,VLPH.CreateDateTime
          ,VLPH.CreateUserID
          ,VLPH.ChangeDateTime
          ,VLPH.ChangeUserID
	  FROM STB_VietnamLabelPrintHist VLPH
	 WHERE 1=1
	   AND (@OriginalBarcode = '*' OR VLPH.OriginalBarcode = @OriginalBarcode)
	   AND (@ChangeBarcode = '*' OR VLPH.ChangeBarcode = @ChangeBarcode)
	   AND (@MaterialCode = '*' OR VLPH.MaterialCode = @MaterialCode)
	   AND CreateDateTime BETWEEN @FromDate AND @ToDate
	 ORDER BY VietnamLabelPrintHistNo
END