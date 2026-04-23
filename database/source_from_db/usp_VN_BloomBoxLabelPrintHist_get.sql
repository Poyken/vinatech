-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-16
-- Description:	Print History of BloomBox Label get
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_BloomBoxLabelPrintHist_get]
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

    -- Insert statements for procedure here
	--DECLARE @LotID VARCHAR(20) = CASE WHEN ISNULL(@pLotID,'') = '' THEN '%' ELSE @pLotID END
	DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00'
	DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00'

	SELECT 
			BLPH.ID,
			BLPH.LotID,
			BLPH.MaterialCode,
			BLPH.MaterialName,
			BLPH.PackingID,
			BLPH.LabelQty,
			BLPH.LotQty,
			BLPH.CurrentQty,
			BLPH.LotNo,
			BLPH.PartNo,
			BLPH.MarkingLetter,
			BLPH.SN,
			BLPH.DC,
			BLPH.SalesPONo,
			BLPH.StockAttrib1,
			BLPH.PrintTime,
			BLPH.PrintUserID,
			SUI.UserName
		FROM	
			STB_VN_BloomBoxLabelPrintHist BLPH
			INNER JOIN SmartFramework.dbo.STB_UserInfo SUI ON SUI.UserID = BLPH.PrintUserID
		WHERE
			BLPH.PrintTime between @FromDate and @ToDate

		ORDER BY
			BLPH.PrintTime ASC
END
