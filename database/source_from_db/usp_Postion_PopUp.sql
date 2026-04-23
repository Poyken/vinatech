-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-11-15
-- Description:	Danh sách các vị trí kho
-- =============================================
CREATE PROCEDURE usp_Postion_PopUp 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	   CREATE TABLE #PositionList
    (
        Id INT IDENTITY(1,1),
        Position NVARCHAR(200)
    );

    -- Insert 2 công ty mẫu
    INSERT INTO #PositionList (Position)
    VALUES (N'A1-1'),
           (N'A1-2'),
		   (N'A2-1'),
		   (N'A2-2'),
		   (N'B1-1'),
		   (N'B1-2'),
		   (N'B1-3'),
		   (N'B1-4'),
		   (N'B2-1'),
		   (N'B2-2'),
			(N'B2-3'),
			(N'B2-4'),
			(N'C1-1'),
			(N'C1-2'),
			(N'C1-3'),
			(N'C1-4'),
			 (N'C2-1'),
		   (N'C2-2'),
			(N'C2-3'),
			(N'C2-4'),
			 (N'D1-1'),
		   (N'D1-2'),
		   (N'D1-3'),
		   (N'D1-4'),
		    (N'D2-1'),
		   (N'D2-2'),
			(N'D2-3'),
			(N'D2-4'),
			  (N'E1-1'),
		   (N'E1-2'),
		   (N'E1-3'),
		   (N'E1-4'),
		    (N'E2-1'),
		   (N'E2-2'),
			(N'E2-3'),
			(N'E2-4')
    -- Trả dữ liệu ra ngoài
    SELECT Id, Position
    FROM #PositionList;
END
