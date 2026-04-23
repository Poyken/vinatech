CREATE PROC usp_VN_location
AS
BEGIN
		CREATE TABLE #Tbl(WorkCenterCode NVARCHAR(10) NULL, WorkCenterName NVARCHAR(50) NULL)

		INSERT INTO #Tbl (WorkCenterCode, WorkCenterName) VALUES ('VVT_F1',N'Bắc Ninh')
		INSERT INTO #Tbl (WorkCenterCode, WorkCenterName) VALUES ('VVT_F2',N'Bắc Giang')

		SELECT WorkCenterCode, WorkCenterName FROM #Tbl

		DROP TABLE #Tbl
END