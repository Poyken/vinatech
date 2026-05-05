-- Procedure: usp_CreateMarkingLetterAndQtyForBarcode
-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-03-24
-- Description:	Lấy danh sách các barcode đã lưu lại Marking cho nhà máy hà nam
-- =============================================
CREATE PROCEDURE usp_CreateMarkingLetterAndQtyForBarcode
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pWorkCenterCode VARCHAR(20)= NULL,
		@pBarcode VARCHAR(50) = NULL,
		@pFromDate DATETIME ,
		@pToDate DATETIME 
AS
	DECLARE @WorkCenterCode      VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                           
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'        
	DECLARE	@Barcode          VARCHAR(50) = CASE WHEN ISNULL(@pBarcode, '') = ''         THEN '*' ELSE @pBarcode         END

BEGIN

	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MarkingCode,MarkingName,Barcode,Qty as QtyOfMarking,CreateDateTime,CreateUserID,ChangeDateTime,ChangeUserID,WorkCenterCode
	FROM STB_CreateMarkingLetterAndQtyForBarcode 
	WHERE 1=1
		AND (@Barcode = '*' OR Barcode = @Barcode)
		AND (@WorkCenterCode = '*' OR WorkCenterCode = @WorkCenterCode)
		 AND (
			(@pBarcode IS NOT NULL and @pBarcode<>'')  -- Nếu @Barcode có giá trị, và <> rỗng thì sẽ không cần kiểm tra theo ngày tháng
			OR (CreateDateTime BETWEEN @FromDate AND @ToDate)  -- Nếu không có giá trị, lọc theo ngày
		)
END

GO

