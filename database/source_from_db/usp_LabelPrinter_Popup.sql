-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_LabelPrinter_Popup

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    CREATE TABLE #T
     (
	ID INT PRIMARY KEY(ID) IDENTITY(1,1) NOT NULL,
	TypeInput NVARCHAR(50) NULL,
	Isued BIT NULL
)
INSERT INTO #T (TypeInput,Isued) VALUES(N'In tem Foxconn',1)
INSERT INTO #T (TypeInput,Isued) VALUES(N'In tem xuất C/T',1)
INSERT INTO #T (TypeInput,Isued) VALUES(N'In tem PAC',1)

SELECT
		*
FROM
		#T
WHERE
		Isued = 1

		DROP TABLE #T
END
