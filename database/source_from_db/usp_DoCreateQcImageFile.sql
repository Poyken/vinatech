CREATE PROC usp_DoCreateQcImageFile
AS
BEGIN
	Declare @DefectReportNo VARCHAR(20)
	       ,@DefectImagePath VARCHAR(200)
		   ,@sql VARCHAR(MAX)

	DECLARE cur CURSOR FOR

	SELECT NCNFRMITY_NO, NCNFRMITY_IMG_PATH
	  FROM ERPSVR.VINATECH.DBO.VECS_QC_RPT
	 WHERE NCNFRMITY_IMG_PATH <> '/_images/common/noimg.png'
	   AND NCNFRMITY_IMG_PATH IS NOT NULL

	OPEN cur

	FETCH NEXT FROM cur INTO @DefectReportNo, @DefectImagePath

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @DefectImagePath = 'D:\Dev' + REPLACE(@DefectImagePath, '/', '\')

		SET @sql = 'INSERT INTO STB_QcDefectReportFileTemp (DefectReportNo, DefectImageFile) '
		SET @sql = @sql + 'SELECT ''' + @DefectReportNo + ''', * '
		SET @sql = @sql + 'FROM OPENROWSET(BULK ''' + @DefectImagePath + ''', SINGLE_BLOB) AS Document'

		execute (@sql)

		FETCH NEXT FROM cur INTO @DefectReportNo, @DefectImagePath
	END

	CLOSE cur
	DEALLOCATE cur
END
