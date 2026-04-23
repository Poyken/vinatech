-- =============================================
-- Author:		DinhManh
-- Create date: 2025-07-08
-- Description:	get history import of Slitting Knife
-- =============================================
CREATE PROCEDURE usp_VN_SlittingKnifeExportHist_get
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pFromDate date,
		@pToDate date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SET @pToDate = DATEADD(DAY, 1, @pToDate)
	DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'
	DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), @pToDate, 120) + ' 10:00:00'

	SELECT
		SKIO.ID,
		SKI.SlittingKnifeCode,
		SKI.SlittingKnifeName,
		SKIO.IOQty,
		SKIO.CreateDateTime,
		SKIO.CreateUserID

	FROM 
		STB_VN_SlittingKnifeIOHist SKIO WITH(NOLOCK) 
		LEFT JOIN STB_VN_SlittingKnifeInfo SKI WITH(NOLOCK) ON SKIO.SlittingKnifeCode = SKI.SlittingKnifeCode
		LEFT JOIN STB_VN_SlittingKnifeLotInfo SKLI WITH(NOLOCK) ON SKLI.SlittingKnifeLotID = SKIO.SlittingKnifeLotID
	WHERE 1=1 
		AND SKI.IsUsed = 1 AND
		SKIO.IOType = 'OUT' AND
		SKIO.CreateDateTime BETWEEN @FromDate AND @ToDate	
END
