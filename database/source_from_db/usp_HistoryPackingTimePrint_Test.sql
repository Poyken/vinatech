-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_HistoryPackingTimePrint_Test]
		@pProcessUserID varchar(20)=NULL,
		@pProcessLanguage varchar(20)=NULL,
		@pLotNo varchar(30) = NULL,
		@pFromDate DATETIME = NULL,
		@pToDate DATETIME = NULL
AS
BEGIN

	SET NOCOUNT ON;

	SELECT top 10 * From STB_SavePackingTime_VVT
END
