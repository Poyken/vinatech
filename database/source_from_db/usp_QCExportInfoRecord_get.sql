-- =============================================
-- Author:		DinhManh
-- Create date: 2025-04-04
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_QCExportInfoRecord_get]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pFromDate DATETIME,
		@pToDate DATETIME
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 00:00:00'


	SELECT 
			ID,
		    [Model],
			Size,
			LotNo,
			Qty,
			DateShip,
			Customer,
			Korea,
			Note,
			Grade,
			CreateDateTime,
			CreateUserID,
			ChangeDateTime,
			ChangeUserID

			FROM
				STB_QCExportInfoRecord

			WHERE	DateShip > @FromDate
			AND		DateShip < @ToDate


END
