-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-10-15
-- Description:	Lấy ra các lỗi thuộc công đoạn
-- =============================================
CREATE PROCEDURE usp_GetErrorsByProcess 
	-- Add the parameters for the stored procedure here
	@ProcessCode NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 

        e.ErrorName
    FROM ErrorType_BG e
    INNER JOIN Process_BG p ON p.ProcessCode = e.ProcessCode
    WHERE p.IsActive = 1
      AND e.IsActive = 1
      AND e.ProcessCode = @ProcessCode
    ORDER BY e.ErrorName;
END
