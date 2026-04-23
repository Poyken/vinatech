-- =============================================
-- Author:		DinhManh
-- Create date: 2025-04-23
-- Description:	usp_VVT_showOQCrefer_separated_VVT_get
-- =============================================
CREATE PROCEDURE [dbo].[usp_VVT_showOQCrefer_separated_VVT_get]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pFromDate DATETIME = NULL,
		@pToDate DATETIME = NULL,
		@pLotNo VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:30:00' 
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:30:00'         
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END


	IF (@LotNo='*' or @LotNo='') 
		BEGIN 
			SELECT a.*,c.MaterialCode,c.MaterialName 
			FROM VVT_OQC_REFER  a  with(nolock)
			join STB_SetInfo  b  WITH(NOLOCK) on a.mergeid = b.Barcode 
			join STB_MaterialMaster  c  WITH(NOLOCK) on b.MaterialCode = c.MaterialCode 
			where	mergedate >= @FromDate AND
					mergedate<=@ToDate AND 
					(finished is not null or finished<>'') AND
					a.isSeparated = '1'

		END 
	ELSE 
		BEGIN 
	 		SELECT a.*,c.MaterialCode,c.MaterialName 
			FROM VVT_OQC_REFER  a  with(nolock)
			join STB_SetInfo  b  WITH(NOLOCK) on a.mergeid = b.Barcode 
			join STB_MaterialMaster  c  WITH(NOLOCK) on b.MaterialCode = c.MaterialCode 
			WHERE  (finished is not null or finished<>'')  
			and a.isSeparated = '1'
			and  mergeid = CASE WHEN (CHARINDEX('-', @LotNo) > 0) THEN SUBSTRING(@LotNo, 1, CHARINDEX('-', @LotNo) - 1) ELSE @LotNo END
		END 

END
