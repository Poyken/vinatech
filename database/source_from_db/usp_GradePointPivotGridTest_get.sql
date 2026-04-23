-- ==================================================================
-- Author      : 
-- Create date : 2020-03-10
-- Browsable   : True
-- Group       : 인사관리
-- Description : 
-- Modified    :   
-- ==================================================================
CREATE PROC [dbo].[usp_GradePointPivotGridTest_get]
				@pProcessUserID		VARCHAR(20),
				@pProcessLanguage   VARCHAR(20),
				@pProcessViewName VARCHAR(50) = NULL,
				@pXml NVARCHAR(MAX) = NULL

AS
BEGIN
	DECLARE @iDoc INT

	DECLARE @ProcessViewName VARCHAR(50) = CASE WHEN @pProcessViewName IS NULL THEN 'EmployeeInfo' ELSE @pProcessViewName END
	DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_INSERT'
	DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_UPDATE'
	DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_DELETE'

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

	SELECT
			EmployeeNo AS empName
		   ,EmployeeName AS eventName
		   ,100 AS totPoint
	FROM
			OPENXML(@iDoc , @InsertTableName , 2)
			WITH  (
						EmployeeNo   VARCHAR(20),
						EmployeeName VARCHAR(20),
						JobClassCode VARCHAR(10),
						JobClassName VARCHAR(100)
					) 
    UNION ALL
	SELECT
			EmployeeNo
		   ,EmployeeName
		   ,90

	FROM
			OPENXML(@iDoc , @UpdateTableName , 2)
			WITH  (
						EmployeeNo   VARCHAR(20),
						EmployeeName VARCHAR(20),
						JobClassCode VARCHAR(10),
						JobClassName VARCHAR(100)
					) 
    UNION ALL
	SELECT
			EmployeeNo
		   ,EmployeeName
		   ,80
	FROM
			OPENXML(@iDoc , @DeleteTableName , 2)
			WITH  (
						EmployeeNo   VARCHAR(20),
						EmployeeName VARCHAR(20),
						JobClassCode VARCHAR(10),
						JobClassName VARCHAR(100)
					) 

    EXEC sp_xml_removedocument @iDoc
END