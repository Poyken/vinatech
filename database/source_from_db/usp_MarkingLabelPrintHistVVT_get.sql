-- =============================================
-- Author:		DinhManh
-- Create date: 2025-11-24
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_MarkingLabelPrintHistVVT_get]
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
	DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00'
	DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00'

	

    SELECT
		ML.ID,
		--ML.MenuCode,
		CASE	WHEN ML.TypePrint IS NULL THEN ML.MenuCode
				ELSE CONCAT(ML.MenuCode, '-' ,ML.TypePrint)
		END AS MenuCode,
		ML.LotNo1,
		ML.MarkingLetter,
		ML.LotNo2,
		ML.LotNo3,
		ML.LabelQty,
		ML.PrintTime,
		ML.PrintUserID

	from STB_MarkingLabelPrintHist ML WITH(NOLOCK)
	where ML.PrintTime BETWEEN @FromDate AND @ToDate

	ORDER BY ML.PrintTime asc
END
