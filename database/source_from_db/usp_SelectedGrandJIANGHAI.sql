-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-11-05
-- Description:	Nguyên Hải Triều
-- =============================================
CREATE PROCEDURE usp_SelectedGrandJIANGHAI
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 CREATE TABLE #LevelJIANGHAI
    (
        LevelId INT IDENTITY(1,1),
        LevelName NVARCHAR(200)
    );

    -- Insert 2 công ty mẫu
    INSERT INTO #LevelJIANGHAI (LevelName)
    VALUES (N'K'),
           (N'L'),
		    (N'M'),
			(N'J')

    -- Trả dữ liệu ra ngoài
    SELECT LevelId, LevelName
    FROM #LevelJIANGHAI;
END
