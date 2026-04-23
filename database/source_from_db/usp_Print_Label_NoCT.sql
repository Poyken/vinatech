-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_Print_Label_NoCT
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20)=null,
		@pProcessLanguage VARCHAR(20)=null,
		@pPO VARCHAR(50)=NULL,
		@pInvoiceNo VARCHAR(100)=NULL, -- No.&Date of Invoice neu in CT
		@pNumber INT=1 -- so luong can in
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #tmp (Num INT)
	-- TAO LIST TU 1 - NUMBEROFTOTAL
	DECLARE @i INT=1
	WHILE @i<=@pNumber
	BEGIN
	    INSERT INTO #tmp VALUES(@i)
		SET @i=@i+1
	END
	SELECT 
			@pInvoiceNo AS DateOfInvoice,
			CAST(Num AS VARCHAR) + '/' + CAST(@pNumber AS VARCHAR) AS NoCT,
			'Report' AS CommandType
	FROM #tmp
END
