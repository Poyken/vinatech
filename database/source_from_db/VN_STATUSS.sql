CREATE PROC [dbo].[VN_STATUSS]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20)
AS
BEGIN
	 SET NOCOUNT ON;
			
			CREATE TABLE #T
			(
				IDT NVARCHAR(100) PRIMARY KEY(IDT) NOT NULL,
				Names NVARCHAR(100) NULL
			)

			INSERT INTO #T (Names,IDT) VALUES (N'Chờ phế',N'Chờ phế')
			INSERT INTO #T (Names,IDT) VALUES (N'Báo phế',N'Báo phế')

			SELECT
					IDT,
					Names
			FROM
					#T
		
		DROP TABLE #T
END
