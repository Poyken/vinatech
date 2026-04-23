-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-29
-- Description:	Xem lại lịch sử đẩy dữ liệu excel
-- =============================================
CREATE PROCEDURE [dbo].[usp_getFinishGood_ImportExcel_HN]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20) =NULL,
	@pProcessLanguage VARCHAR(20) =NULL,
	@pFromdate datetime = NULL,
	@pTodate datetime = NULL,
	@pLotNo VARCHAR(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @LotNo VARCHAR(20) = CASE WHEN ISNULL(@pLotNo,'') = '' THEN '%' ELSE @pLotNo END

	DECLARE	@FromDate   VARCHAR(30) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'
	DECLARE @ToDate		VARCHAR(30) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, @pToDate), 120) + ' 10:00:00'
	IF (@LotNo <> '%')
		BEGIN
				SELECT 
					SPN.ID,
					SPN.MaterialCode,
					SPN.Voltage,
					SPN.Farad,
					SPN.MBISizeW,
					SPN.MBISizeH,
					SPN.Marking,
					SPN.Unit,
					SPN.Quantity,
					SPN.Unit,
					SPN.PackingID,
					SPN.LotNo,
					SPN.CreateDateTime,
					SPN.CreateUserID,
					SPN.ChangeDateTime,
					SPN.ChangeUserID

			FROM
				FinishGoodMESInstock_HN SPN WITH(NOLOCK)
			WHERE 
				SPN.LotNo LIKE @LotNo
				--select * from  FinishGoodMESInstock_HN

    END
	ELSE

	BEGIN
	     SELECT 
					SPN.ID,
					SPN.MaterialCode,
					SPN.Voltage,
					SPN.Farad,
					SPN.MBISizeW,
					SPN.MBISizeH,
					SPN.Marking,
					SPN.Unit,
					SPN.Quantity,
					SPN.Unit,
					SPN.PackingID,
					SPN.LotNo,
					SPN.CreateDateTime,
					SPN.CreateUserID,
					SPN.ChangeDateTime,
					SPN.ChangeUserID

			FROM
				FinishGoodMESInstock_HN SPN WITH(NOLOCK)
			WHERE 
				SPN.CreateDateTime BETWEEN @FromDate AND @ToDate
	   


	END
END
