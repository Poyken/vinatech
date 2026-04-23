CREATE PROC [dbo].[usp_VN_Code2]
AS
BEGIN
		CREATE TABLE #T1
		(
			ID INT IDENTITY(1,1) NOT NULL,
			Names NVARCHAR(50) NULL
		)

		INSERT INTO #T1 (Names) VALUES('Sagemcom Part Number')

		SELECT
				Names
		FROM
			#T1

	DROP TABLE #T1	
END

