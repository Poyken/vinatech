-- =============================================
-- Author:		DinhManh
-- Create date: 2025-10-31
-- Description:	Get Digikey label print history
-- =============================================
CREATE PROCEDURE [dbo].[usp_DigiKeyLabelPrintHist_get]		-- usp_DigiKeyLabelPrintHist_get '', '', '2025-01-01', '2025-10-31'	
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pFromDate DATETIME = NULL,
			@pToDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00'
	DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00'

    SELECT
		DK.ID,
		DK.LotNo,
		CASE 
			WHEN (ISNULL(DK.PONumber, '') = ''  AND  ISNULL(DK.POLineNumber, '') = '' AND ISNULL(DK.PackListNumber, '') = '') THEN N'NHÃN SẢN PHẨM'
			ELSE N'NHÃN LOGISTIC'
		END AS LabelType,
		CASE 
			WHEN (ISNULL(DK.PONumber, '') = ''  AND  ISNULL(DK.POLineNumber, '') = '' AND ISNULL(DK.PackListNumber, '') = '') THEN DK.Qty
			ELSE DK.QtyLogisticBoxc
		END AS BoxQty,
		DK.PN,
		DK.DC,
		DK.PONumber,
		DK.POLineNumber, 
		DK.PackListNumber, 
		DK.LabelQty,
		DK.CREATEDATE,
		DK.CREATEUSERID

	from STB_DigiKeyLabelInnerPrintHist DK WITH(NOLOCK)
	where DK.CREATEDATE BETWEEN @FromDate AND @ToDate

	ORDER BY DK.CREATEDATE asc

	-- select * from STB_DigiKeyLabelInnerPrintHist
END
