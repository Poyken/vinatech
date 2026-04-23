-- =============================================
-- Author:		Nguyên Hải Triều
-- Create date: 2025-07-12
-- Description:	Cho phép tạo dánh sách các kiểu nhập 
-- =============================================
CREATE PROCEDURE usp_Type_inpuT_HN
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #T
(
	ID INT PRIMARY KEY(ID) IDENTITY(1,1) NOT NULL,
	TypeInput NVARCHAR(50) NULL,
	Isued BIT NULL
)
INSERT INTO #T (TypeInput,Isued) VALUES(N'Tem nhỏ',1)
INSERT INTO #T (TypeInput,Isued) VALUES(N'Tem túi bóng',1)

SELECT
		*
FROM
		#T
WHERE
		Isued = 1

		DROP TABLE #T
END
