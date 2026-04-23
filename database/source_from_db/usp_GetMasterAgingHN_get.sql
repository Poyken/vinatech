-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMasterAgingHN_get] -- exec usp_GetMasterAgingHN_get '', '', '2025-08-19', '2025-08-19', ''
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pFromDate DATETIME = NULL,
			@pToDate DATETIME = NULL,
			@pLotNo VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @FromDate VARCHAR(30) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00.000'
	DECLARE @ToDate VARCHAR(30) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00.000'
	DECLARE @LotNo VARCHAR(50) = CASE WHEN ISNULL(@pLotNo,'') = '' THEN '%' ELSE @pLotNo END

	--raiserror(@ToDate, 16, 1)
	--return
	IF (@LotNo = '%' OR @LotNo IS NULL)
		BEGIN
			SELECT DISTINCT
				MACHINES,
				LOTNO AS Lot,
				SPEC,
				DATES,
				COMPUTER
				--CREATEDATE
			FROM stb_MasterAgaingHN WITH(NOLOCK)
			WHERE 1=1 AND
				CONVERT(DATETIME, LEFT(DATES, LEN(DATES) - 3), 103) BETWEEN @FromDate AND @ToDate
		END
	ELSE
		BEGIN
			SELECT DISTINCT
				MACHINES,
				LOTNO AS Lot,
				SPEC,
				DATES,
				COMPUTER
				--CREATEDATE
			FROM stb_MasterAgaingHN WITH(NOLOCK)
			WHERE 
				LOTNO = @LotNo
		END


END
