CREATE PROC [dbo].[usp_VN_VendorFOQC]
AS
BEGIN
		CREATE TABLE #TF
		(
			ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY(ID),
			NameVerdor NVARCHAR(50) NULL
		)

		INSERT INTO #TF (NameVerdor) VALUES ('Javis')
		INSERT INTO #TF (NameVerdor) VALUES ('Mectron')
		INSERT INTO #TF (NameVerdor) VALUES ('TNS')
		INSERT INTO #TF (NameVerdor) VALUES ('Lianyi')
		INSERT INTO #TF (NameVerdor) VALUES ('Dongyong')
		INSERT INTO #TF (NameVerdor) VALUES ('Aoxing')
		INSERT INTO #TF (NameVerdor) VALUES ('Kohoku')
		INSERT INTO #TF (NameVerdor) VALUES ('Nantong nanping')
		INSERT INTO #TF (NameVerdor) VALUES ('Shunpeng')
		INSERT INTO #TF (NameVerdor) VALUES ('Moodueng')
		INSERT INTO #TF (NameVerdor) VALUES ('J-tech')


		SELECT
				NameVerdor
		FROM
				#TF

		DROP TABLE #TF
		
END